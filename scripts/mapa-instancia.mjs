#!/usr/bin/env node
/**
 * Mapa de uma instância: classifica os fluxos n8n de um cliente em conectores e eventos do Funnel Traffic.
 * Só lê arquivos locais (exportação feita pelo MCP do n8n, em modo leitura). Não chama nenhuma API.
 *
 * Uso:
 *   node scripts/mapa-instancia.mjs --fluxos <export.json> --regras <regras-mapa.json> \
 *     [--inventario <inventario-n8n.json>] --saida <pasta>
 *
 * Gera <pasta>/mapa-n8n.json e <pasta>/mapa-n8n.md. As regras ficam em JSON (mapa em configuração, nunca no código).
 */
import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const args = Object.fromEntries(
  process.argv.slice(2).reduce((pares, a, i, todos) => (a.startsWith("--") ? [...pares, [a.slice(2), todos[i + 1]]] : pares), []),
);
for (const obrigatorio of ["fluxos", "regras", "saida"]) {
  if (!args[obrigatorio]) {
    console.error(`Falta --${obrigatorio}. Veja o cabeçalho do script.`);
    process.exit(1);
  }
}

const lerJson = (p) => JSON.parse(readFileSync(p, "utf8"));
const exportacao = lerJson(args.fluxos);
const fluxos = exportacao.fluxos ?? exportacao;
const regras = lerJson(args.regras);
const inventario = args.inventario ? new Map(lerJson(args.inventario).map((f) => [f.id, f])) : new Map();

// Slugs que já têm template previsto no catálogo do produto.
const raiz = join(dirname(fileURLToPath(import.meta.url)), "..");
const catalogo = new Set(
  [...readFileSync(join(raiz, "docs/conectores/CATALOGO.md"), "utf8").matchAll(/\|\s*`([a-z0-9-]+)`\s*\|/g)].map((m) => m[1]),
);

const compilar = (lista) => lista.map((r) => ({ ...r, re: new RegExp(r.padrao, "i") }));
const plataformas = compilar(regras.plataformas);
const negocios = compilar(regras.negocios);

const mapa = fluxos.map((f) => {
  const regra = plataformas.find((r) => r.re.test(f.nome));
  const inv = inventario.get(f.id);
  // O inventário traz o negócio em texto livre; normaliza pelas mesmas regras, e o nome do fluxo vale como reforço.
  const negocio =
    negocios.find((r) => r.re.test(`${inv?.negocio ?? ""} ${f.nome}`))?.negocio ?? inv?.negocio ?? "Sem negócio identificado";
  return {
    id: f.id,
    nome: f.nome,
    ativo: f.ativo,
    atualizadoEm: f.atualizadoEm,
    plataforma: regra?.plataforma ?? "Não classificado",
    conector: regra?.conector ?? null,
    noCatalogo: regra?.conector ? catalogo.has(regra.conector) : null,
    categoria: regra?.categoria ?? "nao_classificado",
    papel: regra?.papel ?? "nao_classificado",
    eventos: regra?.eventos ?? [],
    negocio,
    noInventario2909: Boolean(inv),
    divergenciasAltas: inv ? (inv.divergencias ?? []).filter((d) => d.severidade === "alta").length : null,
    execucoes30d: inv?.execucoes_30d ?? null,
  };
});

// Agregados para o resumo.
const contar = (lista, chave) =>
  Object.entries(lista.reduce((acc, x) => ((acc[x[chave] ?? "—"] = (acc[x[chave] ?? "—"] ?? 0) + 1), acc), {})).sort((a, b) => b[1] - a[1]);
const ativos = mapa.filter((x) => x.ativo);
const conectores = new Map();
for (const f of ativos.filter((x) => x.conector)) {
  const c = conectores.get(f.conector) ?? { conector: f.conector, plataforma: f.plataforma, noCatalogo: f.noCatalogo, fluxos: 0, negocios: new Set(), eventos: new Set() };
  c.fluxos += 1;
  c.negocios.add(f.negocio);
  f.eventos.forEach((e) => c.eventos.add(e));
  conectores.set(f.conector, c);
}
const resumoConectores = [...conectores.values()]
  .map((c) => ({ ...c, negocios: [...c.negocios].sort(), eventos: [...c.eventos] }))
  .sort((a, b) => b.fluxos - a.fluxos);

const saida = {
  geradoEm: new Date().toISOString().slice(0, 10),
  fonte: exportacao.fonte ?? args.fluxos,
  totais: { fluxos: mapa.length, ativos: ativos.length, naoClassificadosAtivos: ativos.filter((x) => x.papel === "nao_classificado").length },
  porPapelAtivos: Object.fromEntries(contar(ativos, "papel")),
  porNegocioAtivos: Object.fromEntries(contar(ativos, "negocio")),
  conectores: resumoConectores,
  fluxos: mapa,
};
writeFileSync(join(args.saida, "mapa-n8n.json"), JSON.stringify(saida, null, 1) + "\n");

const linhas = [
  `# Mapa n8n → Funnel Traffic (gerado em ${saida.geradoEm})`,
  "",
  `Gerado por \`scripts/mapa-instancia.mjs\` a partir de \`${args.fluxos.split("/").pop()}\`. Não editar à mão: mude as regras e gere de novo.`,
  "",
  `Fluxos: ${saida.totais.fluxos} · ativos: ${saida.totais.ativos} · ativos sem classificação: ${saida.totais.naoClassificadosAtivos}`,
  "",
  "## Conectores que os fluxos ativos indicam",
  "",
  "| Conector | Plataforma | No catálogo | Fluxos ativos | Negócios | Eventos propostos |",
  "| --- | --- | --- | --- | --- | --- |",
  ...resumoConectores.map((c) => `| \`${c.conector}\` | ${c.plataforma} | ${c.noCatalogo ? "sim" : "**não**"} | ${c.fluxos} | ${c.negocios.join(", ")} | ${c.eventos.join(", ")} |`),
  "",
  "## Fluxos ativos",
  "",
  "| Fluxo | Papel | Conector | Negócio | Atualizado |",
  "| --- | --- | --- | --- | --- |",
  ...ativos
    .sort((a, b) => a.papel.localeCompare(b.papel) || a.nome.localeCompare(b.nome))
    .map((f) => `| ${f.nome.replace(/\|/g, "/")} | ${f.papel} | ${f.conector ? `\`${f.conector}\`` : "—"} | ${f.negocio} | ${f.atualizadoEm} |`),
  "",
];
writeFileSync(join(args.saida, "mapa-n8n.md"), linhas.join("\n"));
console.log(JSON.stringify(saida.totais), JSON.stringify(saida.porPapelAtivos));
