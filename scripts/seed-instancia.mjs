#!/usr/bin/env node
/**
 * Gera o seed LOCAL de uma instância (versão de testes) a partir do mapa e da configuração dela.
 *   node scripts/seed-instancia.mjs roi
 * Lê docs/instancias/<slug>/mapa-n8n.json e instancia.json; escreve supabase/instancias/<slug>/seed.sql.
 * O seed cria conta, workspaces, templates (rascunho), conectores em modo sombra e canvases de exemplo.
 * Não cria pessoa nem evento: nenhum dado real sai da instância do cliente.
 */
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const slug = process.argv[2];
if (!slug) {
  console.error("Uso: node scripts/seed-instancia.mjs <slug-da-instancia>");
  process.exit(1);
}
const raiz = join(dirname(fileURLToPath(import.meta.url)), "..");
const pasta = join(raiz, "docs/instancias", slug);
const mapa = JSON.parse(readFileSync(join(pasta, "mapa-n8n.json"), "utf8"));
const inst = JSON.parse(readFileSync(join(pasta, "instancia.json"), "utf8"));

const q = (v) => (v === null || v === undefined ? "null" : `'${String(v).replace(/'/g, "''")}'`);
const qj = (v) => `${q(JSON.stringify(v))}::jsonb`;
const qa = (lista) => `array[${lista.map(q).join(", ")}]::text[]`;
const papeisQueEntram = new Set(["entrada", "entrega", "cadencia"]);

// Conectores por workspace, a partir dos fluxos ativos do mapa.
const wsPorNegocio = new Map(inst.workspaces.map((w) => [w.negocio, w]));
const porWorkspace = new Map(inst.workspaces.map((w) => [w.slug, new Map()]));
const templates = new Map();
for (const f of mapa.fluxos.filter((x) => x.ativo && x.conector && papeisQueEntram.has(x.papel))) {
  const ws = wsPorNegocio.get(f.negocio);
  if (!ws) continue; // negócio fora (transversal, interno) — listado no README da instância
  const conectores = porWorkspace.get(ws.slug);
  const c = conectores.get(f.conector) ?? { plataforma: f.plataforma, categoria: f.categoria, eventos: new Set(), fluxos: [] };
  f.eventos.forEach((e) => c.eventos.add(e));
  c.fluxos.push(f.id);
  conectores.set(f.conector, c);
  const t = templates.get(f.conector) ?? { plataforma: f.plataforma, categoria: f.categoria, eventos: new Set() };
  f.eventos.forEach((e) => t.eventos.add(e));
  templates.set(f.conector, t);
}
for (const extra of inst.conectores_extras ?? []) {
  const alvos = extra.workspaces === "todos" ? inst.workspaces.map((w) => w.slug) : extra.workspaces;
  for (const s of alvos) {
    porWorkspace.get(s).set(extra.conector, { plataforma: extra.plataforma, categoria: extra.categoria, eventos: new Set(extra.eventos), fluxos: [] });
  }
  templates.set(extra.conector, { plataforma: extra.plataforma, categoria: extra.categoria, eventos: new Set(extra.eventos) });
}

const sql = [];
sql.push(
  `-- GERADO por scripts/seed-instancia.mjs ${slug} em ${new Date().toISOString().slice(0, 10)}. Não editar à mão.`,
  `-- Versão de testes LOCAL da instância "${inst.conta}". Nunca roda em produção.`,
  `-- Sem pessoas e sem eventos: só a estrutura (conta, workspaces, conectores em sombra, canvases).`,
  "",
  "insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)",
  `values ('00000000-0000-0000-0000-000000000000', ${q(inst.dono.id)}, 'authenticated', 'authenticated', ${q(inst.dono.email)},`,
  "        extensions.crypt('senha-local-dono', extensions.gen_salt('bf')), now(), now(), now(), '{\"provider\":\"email\",\"providers\":[\"email\"]}', '{}')",
  "on conflict (id) do nothing;",
  "",
  `insert into public.contas (id, nome, dono_user_id) values (${q(inst.conta_id)}, ${q(inst.conta)}, ${q(inst.dono.id)}) on conflict (id) do nothing;`,
  "",
);

sql.push("-- Workspaces: um por negócio do mapa");
for (const w of inst.workspaces) {
  sql.push(
    `insert into public.workspaces (conta_id, nome, slug) values (${q(inst.conta_id)}, ${q(w.nome)}, ${q(w.slug)}) on conflict (slug) do nothing;`,
  );
}

sql.push("", "-- Templates de conector (rascunho até conferir payload real)");
for (const [s, t] of [...templates].sort()) {
  sql.push(
    `insert into public.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values (${q(s)}, ${q(t.plataforma)}, ${q(t.categoria)}, 'webhook', ${qa([...t.eventos])}, true) on conflict (slug, versao) do nothing;`,
  );
}

sql.push("", "-- Conectores por workspace, todos em modo sombra");
for (const [wsSlug, conectores] of porWorkspace) {
  for (const [s, c] of [...conectores].sort()) {
    sql.push(
      `insert into public.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)`,
      `select w.id, ${q(c.plataforma)}, ${q(s)}, 'webhook', t.id, ${qj({ _rascunho: true, eventos: [...c.eventos], fluxosN8n: c.fluxos })}, 'sombra'`,
      `  from public.workspaces w left join public.conector_templates t on t.slug = ${q(s)} and t.versao = 1`,
      ` where w.slug = ${q(wsSlug)} on conflict (workspace_id, slug) do nothing;`,
    );
  }
}

sql.push("", "-- Canvases de exemplo (regras em rascunho; formato do filtro fecha no Bloco 2)");
for (const cv of inst.canvases ?? []) {
  const etapas = cv.etapas
    .map((e) => `    (${q(e.chave)}, ${q(e.tipo)}, ${q(e.nome)}, ${qj(e.filtro)}, ${e.x}, ${e.y})`)
    .join(",\n");
  const conexoes = cv.conexoes
    .map((c) => `    (${q(c.de)}, ${q(c.para)}, ${q(c.tipo)}, ${c.janela_dias ?? "null"})`)
    .join(",\n");
  sql.push(
    "do $$",
    "declare v_ws uuid; v_canvas uuid;",
    "begin",
    `  select id into v_ws from public.workspaces where slug = ${q(cv.workspace)};`,
    `  if exists (select 1 from public.canvases where workspace_id = v_ws and nome = ${q(cv.nome)}) then return; end if;`,
    `  insert into public.canvases (workspace_id, nome, tags) values (v_ws, ${q(cv.nome)}, array['teste-local']) returning id into v_canvas;`,
    "  create temporary table _etapas (chave text, id uuid) on commit drop;",
    "  with novas as (",
    "    insert into public.etapas (workspace_id, canvas_id, tipo, nome, filtro, pos_x, pos_y)",
    "    select v_ws, v_canvas, e.tipo, e.nome, e.filtro, e.x, e.y from (values",
    etapas,
    "    ) as e(chave, tipo, nome, filtro, x, y)",
    "    returning id, nome",
    "  )",
    "  insert into _etapas select e.chave, n.id from novas n join (values",
    cv.etapas.map((e) => `    (${q(e.chave)}, ${q(e.nome)})`).join(",\n"),
    "  ) as e(chave, nome) on e.nome = n.nome;",
    "  insert into public.conexoes (workspace_id, canvas_id, de_etapa, para_etapa, tipo, janela_dias)",
    "  select v_ws, v_canvas, d.id, p.id, c.tipo, c.janela from (values",
    conexoes,
    "  ) as c(de, para, tipo, janela) join _etapas d on d.chave = c.de join _etapas p on p.chave = c.para;",
    "  drop table _etapas;",
    "end $$;",
  );
}

const saida = join(raiz, "supabase/instancias", slug);
mkdirSync(saida, { recursive: true });
writeFileSync(join(saida, "seed.sql"), sql.join("\n") + "\n");
const totalConectores = [...porWorkspace.values()].reduce((n, m) => n + m.size, 0);
console.log(`seed: ${inst.workspaces.length} workspaces, ${templates.size} templates, ${totalConectores} conectores, ${(inst.canvases ?? []).length} canvases`);
