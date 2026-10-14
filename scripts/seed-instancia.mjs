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
// Um fluxo vai para o workspace do seu negócio e para os workspaces que agregam a categoria dele
// (ex.: "Compras" recebe todos os conectores de vendas, de qualquer negócio).
const agregadores = inst.workspaces.filter((w) => w.agrega_categorias?.length);
for (const f of mapa.fluxos.filter((x) => x.ativo && x.conector && papeisQueEntram.has(x.papel))) {
  const alvos = new Set();
  const ws = wsPorNegocio.get(f.negocio);
  if (ws) alvos.add(ws.slug); // negócio fora (interno, sem negócio) — listado no README da instância
  agregadores.filter((w) => w.agrega_categorias.includes(f.categoria)).forEach((w) => alvos.add(w.slug));
  for (const alvo of alvos) {
    const conectores = porWorkspace.get(alvo);
    const c = conectores.get(f.conector) ?? { plataforma: f.plataforma, categoria: f.categoria, eventos: new Set(), fluxos: [], config: {} };
    f.eventos.forEach((e) => c.eventos.add(e));
    c.fluxos.push(f.id);
    conectores.set(f.conector, c);
  }
  if (!alvos.size) continue;
  const t = templates.get(f.conector) ?? { plataforma: f.plataforma, categoria: f.categoria, eventos: new Set() };
  f.eventos.forEach((e) => t.eventos.add(e));
  templates.set(f.conector, t);
}
// Conectores que não vêm de fluxo n8n (ex.: HubSpot lido do Supabase do Gerador).
// "workspaces" é "todos", uma lista de slugs ou um objeto { slug: configuração } (ex.: pipelines do HubSpot).
for (const extra of inst.conectores_extras ?? []) {
  const alvos =
    extra.workspaces === "todos"
      ? Object.fromEntries(inst.workspaces.map((w) => [w.slug, {}]))
      : Array.isArray(extra.workspaces)
        ? Object.fromEntries(extra.workspaces.map((w) => [w, {}]))
        : extra.workspaces;
  for (const [s, config] of Object.entries(alvos)) {
    porWorkspace.get(s).set(extra.conector, { plataforma: extra.plataforma, categoria: extra.categoria, eventos: new Set(extra.eventos), fluxos: [], config });
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
  `insert into funnel_traffic.contas (id, nome, dono_user_id) values (${q(inst.conta_id)}, ${q(inst.conta)}, ${q(inst.dono.id)}) on conflict (id) do nothing;`,
  "",
);

sql.push("-- Workspaces: um por negócio do mapa");
for (const w of inst.workspaces) {
  sql.push(
    `insert into funnel_traffic.workspaces (conta_id, nome, slug) values (${q(inst.conta_id)}, ${q(w.nome)}, ${q(w.slug)}) on conflict (slug) do nothing;`,
  );
}

sql.push("", "-- Templates de conector (rascunho até conferir payload real)");
for (const [s, t] of [...templates].sort()) {
  sql.push(
    `insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values (${q(s)}, ${q(t.plataforma)}, ${q(t.categoria)}, 'webhook', ${qa([...t.eventos])}, true) on conflict (slug, versao) do nothing;`,
  );
}

sql.push("", "-- Conectores por workspace, todos em modo sombra");
for (const [wsSlug, conectores] of porWorkspace) {
  for (const [s, c] of [...conectores].sort()) {
    sql.push(
      `insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)`,
      `select w.id, ${q(c.plataforma)}, ${q(s)}, 'webhook', t.id, ${qj({ _rascunho: true, eventos: [...c.eventos], fluxosN8n: c.fluxos, ...c.config })}, 'sombra'`,
      `  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = ${q(s)} and t.versao = 1`,
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
    `  select id into v_ws from funnel_traffic.workspaces where slug = ${q(cv.workspace)};`,
    `  if exists (select 1 from funnel_traffic.canvases where workspace_id = v_ws and nome = ${q(cv.nome)}) then return; end if;`,
    `  insert into funnel_traffic.canvases (workspace_id, nome, tags) values (v_ws, ${q(cv.nome)}, array['teste-local']) returning id into v_canvas;`,
    "  create temporary table _etapas (chave text, id uuid) on commit drop;",
    "  with novas as (",
    "    insert into funnel_traffic.etapas (workspace_id, canvas_id, tipo, nome, filtro, pos_x, pos_y)",
    "    select v_ws, v_canvas, e.tipo, e.nome, e.filtro, e.x, e.y from (values",
    etapas,
    "    ) as e(chave, tipo, nome, filtro, x, y)",
    "    returning id, nome",
    "  )",
    "  insert into _etapas select e.chave, n.id from novas n join (values",
    cv.etapas.map((e) => `    (${q(e.chave)}, ${q(e.nome)})`).join(",\n"),
    "  ) as e(chave, nome) on e.nome = n.nome;",
    "  insert into funnel_traffic.conexoes (workspace_id, canvas_id, de_etapa, para_etapa, tipo, janela_dias)",
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
