/**
 * Identidade do app. É o único lugar com nome, slug e cor de marca.
 * Para reusar este modelo em outro app: rode `scripts/novo-app.sh <slug> "<Nome>"` ou edite aqui.
 */
export const appConfig = {
  nome: "Funnel Traffic",
  slug: "funnel-traffic",
  descricao: "Mapa de funil ligado a eventos reais.",
  empresa: "RC Digitais",
  /** Rotas do menu lateral. Adicione páginas em src/pages e registre aqui + em src/routes.tsx */
  menu: [
    { rotulo: "Visão geral", caminho: "/", icone: "LayoutDashboard" },
    { rotulo: "Canvas", caminho: "/canvas", icone: "Workflow" },
    { rotulo: "Integrações", caminho: "/integracoes", icone: "Plug" },
    { rotulo: "Pessoas", caminho: "/pessoas", icone: "Users" },
    { rotulo: "Configurações", caminho: "/configuracoes", icone: "Settings" },
  ],
} as const;
