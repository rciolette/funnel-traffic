# Benchmark Funnelytics

Oct 3, 2026 · @Raphael

## Resumo executivo

O Funnelytics é um canvas visual de funil que se liga a dados reais de rastreamento: cada etapa desenhada mostra quantas pessoas passaram por ela e a taxa de conversão até a próxima. Hoje ele é vendido em duas linhas — a **Journey Platform** (mapa + analytics, de US$ 39 a US$ 349/mês) e o **Funnelytics Ecom** (app de LTV para Shopify, lançado em 23/06/2026) — e quase toda a evolução recente do produto foi para o lado de e-commerce.

Conclusões principais para a Dose Saudável:

- **O valor está no modelo, não na ferramenta.** O que vale copiar é a ideia de um mapa de jornada onde cada nó é uma regra sobre eventos reais (URL, UTM, ação) e cada linha é uma taxa de conversão. Isso cabe no ds-revenue-dash com Supabase.
- **Encaixe ruim com a nossa stack.** Não há integração nativa com Hotmart, Braip, Assiny, HotWebinar, SendFlow ou WhatsApp; tudo isso entraria só por webhook (plano de US$ 129/mês em diante). GoHighLevel e Meta Ads são nativos, mas só no plano Business (US$ 349/mês).
- **Não existe API de leitura.** Os dados entram por script, webhook e Zapier, mas só saem por CSV, PNG, relatório e e-mail. Não daria para puxar os números do Funnelytics para o nosso painel.
- **"Tempo real" é marketing.** O canvas precisa de um clique em atualizar; eventos de servidor levam cerca de 10–11 minutos para aparecer.
- **Recomendação:** não assinar como fonte de verdade; no máximo um teste de 14 dias do Performance Pro para estudar a UX. Construir no nosso painel uma tela "Jornada" inspirada no canvas, com os eventos que o n8n já grava no Supabase (seção 10).

## Linhas de produto e planos

O plano que interessa para uma operação com tráfego, CRM e vendas é o **Performance Business (US$ 349/mês)**: só ele traz custo de anúncios, compras e as integrações nativas com GoHighLevel e Meta. Preços mensais, conferidos em [funnelytics.io/pricing](https://funnelytics.io/pricing) e [/ecom-pricing](https://funnelytics.io/ecom-pricing) em 03/10/2026; a página não mostra opção anual nem limites de pessoas rastreadas.

| Linha | Plano | Preço (US$/mês) | Teste | O que traz |
| --- | --- | --- | --- | --- |
| Journey Platform | Map Pro | 39 | 7 dias | Só planejamento: canvas ilimitados, colaboradores ilimitados, 100+ templates, simulação de lucro. Sem script de rastreamento |
| Journey Platform | Performance Pro | 129 | 14 dias | Rastreamento automático multi-domínio (fontes, páginas, vídeos, botões), formulários e agendas, KPIs com metas e alertas, forecast x real. Integrações: Zapier e Webhook |
| Journey Platform | Performance Business | 349 | 14 dias | Tudo do Pro + Vision AI, compras/negócios/eventos customizados, custo de anúncios (Meta, Google Ads), vários workspaces, HubSpot, GoHighLevel, Shopify |
| Ecom (Shopify) | Free | 0 | — | Sincronização Shopify, LTV Profit Map, filtros de audiência |
| Ecom (Shopify) | Pro | 99 a 349, por volume de pedidos | 7 dias | Alertas por IA, lista semanal de ações, Audience Sync — vários itens ainda "em breve", com lista de espera |

Mudanças recentes que importam:

- **Jan/2025:** reestruturação com quatro planos (Starter US$ 79, Pro US$ 199, Business US$ 499, Agency US$ 999) e limites de 5 mil a ilimitadas pessoas rastreadas. Essa tabela já não vale; a página do anúncio hoje dá 404.
- **Plano gratuito do mapa:** reviews antigos elogiam um plano free; hoje só existe teste de 7 dias no Map Pro.
- **Nov/2025:** último release da Journey Platform no changelog — fuso por workspace, 9 templates de início rápido, página com várias URLs, KPIs nos e-mails de notificação.
- **Jun/2026:** lançamento do app Funnelytics Ecom na Shopify App Store.

A empresa é de Toronto, fundada em 2018 por Mikael Dia (ainda CEO), com cerca de CAD 3,35 milhões em rodadas seed (2020 e 2022). Não achei dados de equipe ou receita posteriores a 2022.

## Canvas: mapeamento e análise

O canvas é o coração do produto: você desenha a jornada com quatro tipos de elemento e cada elemento vira uma regra que casa com eventos reais. O número em cada etapa conta **pessoas únicas** (o modelo é centrado em pessoa, não em sessão) e o número em cada linha é a taxa de conversão entre as duas etapas.

### Elementos e como se ligam aos dados

| Elemento | O que representa | Regra que casa com os dados |
| --- | --- | --- |
| Source (fonte) | Anúncio, e-mail, orgânico, referência | Parâmetros de URL/UTM ou URL de referência; operadores é igual, não é igual, contém, não contém (sem diferenciar maiúsculas). Dá para adicionar em lote todos os anúncios de um conjunto |
| Page (página) | Página de captura, obrigado, checkout | URL com curingas (`*` e `**` para domínio + tudo abaixo), várias URLs por página, filtro por parâmetros de URL (vários pares = E) |
| Action (ação) | Clique, formulário, vídeo, compra, evento customizado | Nome do evento + filtros de atributos (contém, maior/menor que, igual etc.) mostrados como frases |
| Offline | Ligação, WhatsApp, reunião, qualquer etapa fora do site | Ícone próprio; recebe dados por webhook ou Zapier |

Além disso: formas, textos, imagens, miniatura gerada a partir da URL, colar um link cria a etapa e já lê os parâmetros, histórico de versões, exportação em PNG com fundo transparente. Apagar um canvas não apaga os dados rastreados do workspace.

### Conexões

- **Linha sólida (direta):** conta quem fez B como **próxima coisa** depois de A.
- **Linha pontilhada (pular etapas):** conta quem fez A e, em algum momento depois, B, dentro do período.
- Estilo reta ou curva (Bezier).

### Camadas e modos de leitura

- **Numbers:** pessoas e conversões.
- **Flow:** pontos animados nas linhas, de vermelho a verde conforme o volume.
- **Funnel Mode:** só conta quem percorreu a cadeia conectada inteira; é mais lento e avisa quando há loops.
- **Forecast, Checklist, Notes:** camadas de projeção, tarefas e anotações.
- Os dados só aparecem ao clicar em **Refresh Analytics** — atualização manual, não streaming.

### Explorar caminhos

- **Explorer (aba lateral):** lista as fontes, páginas e ações mais frequentes; dá para adicionar as 10 principais de uma vez ou mapear por atributo.
- **Step Explorer:** arrastando a seta direita de uma etapa, ele mostra os próximos passos reais (inclusive "qualquer próxima página"); a seta esquerda mostra de onde as pessoas vieram. Dá para montar o funil de trás para frente a partir da página de obrigado.

### Filtros e janelas

- Período (sempre ativo), país, dispositivo (todos, mobile, desktop).
- **Filtro de pessoa:** isola um indivíduo no mapa.
- **Filtro de etapa ("pessoas que fizeram"):** seleciona etapas com lógica E/OU.
- **Contribution Window:** depois de filtrar por etapa, olha X dias para frente ou para trás, além do período escolhido — funciona como janela de conversão.
- **Comparação:** coorte principal em preto e coorte comparada em roxo, por período ou por grupo de pessoas (país, dispositivo, etapas), com semáforo de limites ajustável.

### Metas e forecast

- **Goals:** atribui um valor em dólar a qualquer etapa ou linha; o valor é multiplicado pelo número de pessoas.
- **Predictive Forecasting (mai/2024):** em cada fonte você informa dois de três valores (investimento, custo por pessoa, pessoas) e o terceiro é calculado; nas linhas entram taxas de conversão; despesas manuais por período. Saem leads, vendas, receita e lucro em cenários conservador, esperado e otimista.
- **Predictive Paths:** taxas de conversão diferentes por fonte de origem.
- Nos planos Performance, o forecast aparece lado a lado com o real.

### Templates

Biblioteca com 100+ funis desmontados (Tony Robbins, Russell Brunson, Frank Kern e outros), filtrável por segmento, tipo de funil e criador. Importar exige plano pago.

## Rastreamento da jornada

A jornada é montada a partir de um script único por workspace, que cria um ID de pessoa em cookie próprio e liga a ele tudo o que chega depois — do navegador, de webhook ou do CRM — pelo ID ou pelo e-mail. Atribuição, aqui, é estrutural (linhas diretas, janelas de contribuição), não um modelo configurável como first-touch ou linear.

### Como a pessoa é identificada

1. **Primeira visita:** o script `track-v3.js` cria a sessão e grava o ID no cookie `_fs` (primeira parte, domínio mais alto possível, expira em 2038), espelhado no localStorage.
2. **Outros domínios:** com o domínio na whitelist, o script reescreve os links de saída com `?_fs=<id>&_fsRef=<origem>`; no destino, o parâmetro vale mais que o cookie.
3. **Formulários de terceiros:** o ID (`window.funnelytics.session`) vai num campo oculto — `_fs` no GoHighLevel, `funnelytics_id` no Typeform — e volta junto com o lead.
4. **E-mail:** qualquer evento ou webhook com o atributo `email` amarra o histórico anônimo à pessoa. O script também captura passivamente qualquer campo que pareça e-mail cerca de 1 segundo depois de digitado (com opção de hash SHA-256).
5. **Eventos de servidor:** webhook ou Zapier casam por `session` ou `email`; e-mail desconhecido cria pessoa nova; sem nenhum dos dois, cada evento vira uma pessoa nova.

### Eventos automáticos

| Evento | Quando dispara | Atributos principais |
| --- | --- | --- |
| Link Click | Clique em link | `clickURL`, `clickText`, `pagePath`, `domain`, `elementId` |
| Button Click | Clique em `<button>`, `.btn` ou classe `.flButton` | `clickText`, `pagePath`, `elementId` |
| Scroll | 10, 25, 50, 75, 90% da página | `scroll`, `pagePath` |
| Form Completed | Envio de formulário HTML (não iframe) e formulários HubSpot | `formId`, campos; e-mail removido se anonimização ligada |
| Meeting Scheduled | Agendamento em HubSpot Meetings | `meetingLink`, nome/e-mail |
| Video View | YouTube, Vimeo, Wistia, HTML5 | `videoAction` (play, pause, 10%…100%), `videoName` |

### Latência real

- Canvas: atualização manual pelo botão Refresh Analytics.
- Zapier: a própria documentação pede para esperar cerca de 10 minutos.
- Webhook e eventos offline: o backend aplica um atraso de cerca de 11 minutos antes de casar o evento com a pessoa.
- O site promete "tempo real", mas não há SLA documentado.

### Visão por pessoa

- O widget **People** lista quem passou no período; clicar abre a jornada completa daquela pessoa, e clicar numa etapa mostra seus atributos. Dá para abrir várias jornadas ao mesmo tempo.
- Em qualquer etapa, a opção People lista quem a executou, com exportação em CSV.

### Atribuição

- Não há modelos nomeados (first-touch, last-touch, linear) documentados na Journey Platform.
- O que existe: linhas diretas x pular etapas, Contribution Window, contribuição de páginas, fontes e anúncios para cada KPI no Monitor.
- "Multi-touch" aparece como promessa de marketing, principalmente no produto Ecom.

### Privacidade e qualidade

- Anonimização de formulários ligada por padrão (nome, e-mail e telefone removidos; senha nunca coletada).
- Não há integração com gestor de consentimento nem artigo de LGPD/GDPR; o script não checa consentimento.
- Lista de IPs bloqueados (vale daqui para frente) e filtro de bots no navegador e no servidor ("Bot Tracking Shield", jul/2024).

## Dashboards, metas e relatórios

Fora do canvas, cada workspace tem um painel de monitoramento com KPIs, metas com semáforo e alertas por e-mail; a camada de "boards personalizados" é essa, não um construtor livre de dashboards. A barra lateral do workspace segue a ordem Monitor → Targets → Canvases → Collaborators → Integrations → Settings.

### Monitor (KPIs)

- KPIs padrão: pessoas rastreadas, formulários concluídos, compras, receita total; comparação com o período anterior (setas para cima ou para baixo) e widget de tendência.
- **KPIs customizados:** categoria (financeiro, conversão, página, outro), local (qualquer lugar ou uma página) e filtros por atributo.
- Abas:
  - **Pages:** as 200 páginas principais e quanto cada uma contribui para cada KPI.
  - **Sources:** por referência ou por UTM.
  - **Ads:** campanha, conjunto e anúncio com impressões, investimento, cliques e contribuição para os KPIs, mais prévia do anúncio.

### Targets (metas)

- Cada meta tem valor-alvo, limite de alerta, valor real e projeção (ritmo).
- Status verde, amarelo ou vermelho ("crítico"), por dia, semana ou mês.

### Visão geral e alertas

- **Workspace Overview:** todos os workspaces (clientes, marcas) numa tela, com status no ritmo, fora do ritmo ou crítico.
- Resumos por e-mail diários, semanais ou mensais, incluindo KPIs customizados desde nov/2025.

### Vision AI

- Botão de chat dentro do app (por exemplo no Monitor) que analisa **só o que está na tela** e devolve insights e recomendações.
- Listado no plano Business; a página de ajuda não diz o plano.

### Relatórios a partir do canvas

- **Widgets:** países, pessoas, metas e tendências (até 4 etapas; diário, 3 dias, semanal ou mensal; exporta PNG e CSV).
- **Report Frames:** quadros desenhados no próprio canvas, cada um vira uma página/slide; exporta com dados, filtros e comparação aplicados. Tipos documentados: relatórios executivos e de impacto por contribuição.
- Exportações em CSV (pessoas, conversões, tráfego) e PNG.

### Compartilhamento e permissões

| Tipo de link | Quem acessa | Uso |
| --- | --- | --- |
| Editável | Só colaboradores do workspace | Trabalho em equipe |
| Duplicar | Quem recebe, no próprio workspace | Entregar um template |
| Somente leitura | Qualquer pessoa, sem login, senha opcional | Mostrar ao cliente ou à diretoria |

- Estrutura: conta → workspaces (cada um com seu ID e script) → canvases organizados por tags.
- **Há um único nível de permissão (leitura e escrita).** Colaboradores veem todos os funis do workspace e não acessam as configurações. Não há perfis como admin, visualizador ou personalizado.

## API e integrações (referência técnica)

O Funnelytics tem três portas de entrada — script JS, webhook HTTP e Zapier — e nenhuma porta de saída programática: **não existe API pública de leitura ou exportação**. Para a Dose Saudável, a porta relevante seria o webhook chamado pelo n8n.

### 1. Script de rastreamento

- Um script por workspace, identificado por um UUID (Workspace ID, chamado de "Project ID" nos tutoriais antigos), visível na URL do workspace ou em Settings > Workspace.
- Instalação recomendada via Google Tag Manager (HTML personalizado em todas as páginas, uma vez por página) ou template "Funnelytics" da galeria do GTM. Há guias para WordPress, Webflow e Shopify (Custom Pixel).
- **Instalar uma vez só por página.** Script duplicado ou de dois workspaces na mesma página distorce os números.
- Conferência no console do navegador: `window.funnelytics.project` devolve o UUID e `window.funnelytics.session` devolve o ID da pessoa.
- **SPA:** segundo argumento do `init` como `true` e uma tag no gatilho "All History Changes" chamando `window.funnelytics.functions.step()`.

### 2. Eventos via JavaScript

Assinatura: `window.funnelytics.events.trigger(nome, atributos)`. Os atributos precisam ser **planos** (texto ou número); objetos aninhados chegam como `[object Object]`. O evento só dispara depois que o script cria o passo da página, por isso as receitas oficiais esperam por ele:

```javascript
var checker = setInterval(function () {
  if (!window.funnelytics || !window.funnelytics.step) return;
  clearInterval(checker);
  window.funnelytics.events.trigger('Call Scheduled', {
    email: 'pessoa@exemplo.com'
  });
}, 400);
```

Compra é um evento reservado, `__commerce_action__`, com um evento por item do pedido:

```javascript
window.funnelytics.events.trigger('__commerce_action__', {
  __total_in_cents__: 19700,   // número, em centavos
  __sku__: 'DIETA-HORMONAL',
  __order__: 'HP123456',
  __currency__: 'BRL',
  __label__: 'Dieta Hormonal',
  email: 'pessoa@exemplo.com'
});
```

### 3. Webhook (servidor → Funnelytics)

- **Endpoint:** `POST https://events.funnelytics.io/api/v1/webhook/{nomeDaAcao}` — o nome vira a ação no canvas. Receita vai **só** para `.../webhook/__commerce_action__`.
- **Cabeçalhos:** `Content-Type: application/json`, `X-PROJECT-ID` e `X-API-KEY`, copiados do cartão Webhook Credentials na aba Integrations.
- **Corpo:** JSON plano, exceto o array `purchase_data`; campos opcionais `session`, `email` e `dateTime` (ISO-8601). Requisições duplicadas são rejeitadas — mandar `dateTime` torna reenvios únicos.

```json
{
  "email": "pessoa@exemplo.com",
  "dateTime": "2026-10-03T21:18:04-03:00",
  "purchase_data": [{
    "__sku__": "THERMODOSE", "__label__": "ThermoDose",
    "__total_in_cents__": 29700, "__order__": "BRP-998877",
    "__currency__": "BRL", "quantity": 1
  }]
}
```

- Não estão documentados: limite de requisições, códigos de erro, formato de resposta, rotação de chave. O n8n é citado nominalmente na documentação do webhook como forma de envio.
- Existe ainda um endpoint específico para formulário do GoHighLevel (`.../api/v1/gohighlevel/webhook/submit`, mesmos cabeçalhos) e um endpoint legado do Make (`track-v3.funnelytics.io/events/commerce`), que deve ser tratado como substituído.
- Os endpoints internos que o navegador usa (`/sessions`, `/steps`, `/events/trigger` em `track-v3.funnelytics.io`) não são documentados e podem mudar a qualquer momento.

### 4. Zapier (só ações)

- Credenciais: App ID (igual ao Workspace ID) e App Key.
- Ações: Custom Action (até 3 pares chave/valor), Form Submission, Deal Pipeline Action, Transaction Action. **Não há gatilhos**, ou seja, o Zapier só manda dados para dentro.
- Stripe aparece só como exemplo de gatilho do lado do Zapier; não há integração nativa.

### 5. Integrações nativas

| Integração | Plano | Como conecta | O que traz |
| --- | --- | --- | --- |
| Meta Ads | Business | OAuth + parâmetros na URL do anúncio | Impressões, investimento, cliques por campanha, conjunto e anúncio, com prévia, cruzados com visitas e compras |
| Google Ads | Business | OAuth; o Funnelytics grava um modelo de rastreamento na conta, campanha ou grupo | Impressões e investimento + conversões. Não aceita conta de administrador (MCC); anúncios do YouTube não aparecem na tabela |
| GoHighLevel | Business | OAuth em uma Location | Oportunidades, agendamentos e pedidos. **Formulários não vêm nativos:** precisa de workflow do GHL com webhook + campo oculto `_fs` |
| HubSpot | Business | App instalado no HubSpot | Contatos (`__contact__`) e negócios ganhos ("Deal Won" vira etapa) + formulários e reuniões embutidos |
| Shopify | Business | Custom Pixel em Customer events | Visualizações, carrinho, etapas do checkout e compra por item |
| Zapier e Webhook | Pro e Business | Credenciais do workspace | Qualquer evento externo |

Parâmetros próprios para anúncios: `fl_adsrc` (meta ou google), `fl_adntw` (rede/posicionamento) e `fl_adid` (ID do anúncio ou criativo). No Meta, o sufixo é `fl_adsrc=meta&fl_adntw={{site_source_name}}&fl_adid={{ad.id}}`, depois das UTMs existentes. A documentação avisa que o atualizador automático de URLs pode zerar a prova social do anúncio se ele não usar uma publicação existente.

Via contêineres de GTM fornecidos pelo Funnelytics: ThriveCart, WooCommerce, SamCart, Calendly, Contact Form 7, Gravity Forms, Typeform e Vidalytics. **Não há guia atual** para ClickFunnels, Kajabi, Hotmart, Braip, Kiwify, Assiny ou Eduzz.

## Modelo de documentação

A documentação do Funnelytics se divide em dois lugares com papéis diferentes, e esse desenho serve bem de modelo para a pasta de docs do ds-revenue-dash: uma **central de ajuda** curta e procedural (Intercom) e um **hub** de treinamento e comunidade (Circle) com vídeo, receitas e changelog.

### Central de ajuda (help.funnelytics.io)

| Coleção | Artigos | Conteúdo |
| --- | --- | --- |
| Integrations | 20 | Subdividida em instalação do script, integrações diretas e configuração avançada |
| Dashboard | 10 | Monitor, KPIs, metas, visão geral, Vision AI |
| Getting Started | 8 | Primeiros passos, workspace, canvas |
| FAQ | 5 | Dúvidas recorrentes |
| Account Management | 4 | Conta, cobrança, colaboradores |
| How-To Guides | 2 | Casos de uso |

Padrões de título: "How to Connect Your X Account to Funnelytics", "Install Funnelytics on X", "Track X in Funnelytics", "Understanding \<recurso>" e prefixo de plataforma ("Go High Level – \<tarefa>").

Modelo de artigo, sempre na mesma ordem:

1. Propósito em 1–2 frases.
2. Avisos de limitação destacados.
3. "Antes de começar" (o que separar).
4. Passos numerados, cada um com verbo no título, cliques curtos e uma captura de tela.
5. Blocos de código para payloads.
6. Passo final de verificação ("confira no Funnelytics").
7. Contato do suporte e artigos relacionados.

### Hub (hub.funnelytics.io)

- **Platform Training:** aulas numeradas de 00 a 19, cada uma com gancho, 3–5 bullets do que se aprende, vídeo, chamada para ação e tutorial escrito com um subtítulo por recurso.
- **Tracking Setup:** um post por ferramenta, com um post fixado "comece aqui" para o script base. Receitas de GTM trazem link do contêiner, vídeo mostrando o contêiner e o inventário de variáveis, gatilhos e tags com propósito e código.
- **Product Updates:** notas de versão por tema, com seções novos recursos, melhorias, correções e prévia, cada item marcado com o plano que o recebe e links para demo e tutorial.
- Também: anúncios, perguntas da comunidade, pedidos de recurso, treinamentos ao vivo, masterclass e biblioteca privada de funis.

### Convenções de nomes que vale copiar

- Nome de evento em Title Case ("Call Scheduled", "Form Submit"); chave de atributo em camelCase (`pagePath`, `formId`).
- Nomes reservados do sistema entre dois sublinhados: `__commerce_action__`, `__contact__`, `__total_in_cents__`, `__dataOrigin__`.
- Valores monetários sempre em centavos inteiros.
- Ativos de GTM com prefixo por tipo: "Funnelytics – \<Ferramenta> – \<Evento>" para tags, "DLV – …", "URL Query – …" para variáveis.

## Reviews e limitações

Quem usa elogia o mapa visual e o forecast; as críticas se concentram em preço, curva de aprendizado, integrações limitadas e cobrança. As notas divergem muito entre sites de software (4,2–4,4) e o Trustpilot (2,5).

| Site | Nota | Avaliações | Observação |
| --- | --- | --- | --- |
| [Capterra](https://www.capterra.com/p/200577/Funnelytics/reviews/) | 4,4 / 5 | 31 | Facilidade de uso 4,0, suporte 4,1; muitas avaliações de 2023 |
| [G2](https://www.g2.com/products/funnelytics/reviews) | 4,2 / 5 | 35 | Maioria de empresas com até 50 pessoas |
| [Trustpilot](https://ca.trustpilot.com/review/funnelytics.io) | 2,5 / 5 | 138 | Reclamações de cobrança e upsell; a empresa responde a todas as negativas |

**O que elogiam:** mapa rápido de montar e bom para apresentar a cliente; templates; simulação de resultados; dados ao vivo sobre o mapa. Agências e consultores são os mais satisfeitos.

**O que criticam:**

- Caro para quem opera sozinho; o salto do free para o pago incomoda.
- Instalação e onboarding difíceis.
- Poucas integrações de CRM e e-mail.
- Upsells insistentes, cobrança indevida e reembolso difícil (Trustpilot).
- Suporte irregular e interface considerada datada.
- Atraso nos dados em funis de alto tráfego e exportação limitada (review da The Digital Project Manager).

**Limitações que confirmamos na documentação:**

- Sem API de leitura ou exportação programática.
- Uma única permissão (leitura e escrita) por workspace.
- Atualização manual do canvas e atraso de cerca de 10–11 minutos para eventos de servidor.
- Sem modelos de atribuição configuráveis.
- Sem gestão de consentimento.
- Formulários do GoHighLevel não chegam pela integração nativa.
- Custo de anúncio só via Meta e Google, nada de TikTok ou YouTube na tabela.

## Alternativas de mercado

Nenhuma ferramenta junta mapa visual e rastreamento como o Funnelytics; o mercado se divide entre atribuição de anúncios, analytics de produto e ferramentas de mapa sem dados. No Brasil, a referência para infoproduto é a Utmify, que integra com as plataformas de pagamento, mas não desenha jornada. Preços conferidos nas páginas oficiais em 03/10/2026, salvo indicação.

| Ferramenta | Posicionamento | Preço | Diferencial | Integra com Hotmart/Braip? |
| --- | --- | --- | --- | --- |
| [Utmify](https://utmify.com.br) | Rastreamento de vendas e UTMs para infoproduto BR | Grátis até 30 vendas; R$ 119,90 a R$ 5.399,90/mês por volume (fonte: concorrente Escalafy) | Webhooks em tempo real com Hotmart, Kiwify, Eduzz; envio server-side para Meta, Google, TikTok; ROAS por campanha | Hotmart sim; Braip citada no site, não confirmada |
| [Tintim](https://tintim.app/) | Atribuição de vendas no WhatsApp | R$ 197 a R$ 297/mês | Detecta venda na conversa e devolve conversão ao Meta e Google | Não é o foco |
| [SegMetrics](https://segmetrics.io/pricing/) | Funil e atribuição para cursos e infoproduto (EUA) | US$ 57 a 397/mês | LTV por fonte de lead, jornada do cliente, 100+ integrações | Não documentado |
| [Hyros](https://hyros.com/updates/info-product-tracking/) | Atribuição para infoproduto e high ticket | Sob consulta, contrato anual (mediana estimada \~US$ 25 mil/ano) | Janela de 90 dias, matching determinístico no servidor | Não citado |
| [RedTrack](https://www.redtrack.io/pricing/) | Rastreador de anúncios para afiliados e lead gen | US$ 69 a 833/mês | Postbacks e Conversion API para 8 plataformas | Via postback |
| [Cometly](https://www.cometly.com/pricing) | Atribuição server-side com gestor de anúncios por IA | Sob consulta | Multi-touch, jornada por conta, servidor MCP no Enterprise | Não citado |
| [Wicked Reports](https://www.wickedreports.com/pricing) | Atribuição de receita e coortes de LTV | US$ 499 a 999/mês | Cohorts, Meta CAPI | Não citado |
| [Triple Whale](https://www.triplewhale.com/pricing) / [Northbeam](https://www.northbeam.io/pricing) | Atribuição para e-commerce (Shopify) | Free a US$ 3.500+/mês | Multi-touch, MMM, IA | Não |
| [PostHog](https://posthog.com/pricing) / [Mixpanel](https://mixpanel.com/pricing/) / [Amplitude](https://amplitude.com/pricing) | Analytics de produto | Grátis até 1–2 milhões de eventos/mês | Funis, caminhos, retenção, replay; sem custo de anúncio nem mapa | Via API/webhook |
| [GERU](https://www.capterra.com/p/238054/GERU/reviews/) | Blueprint e projeção de funil (o mais parecido com o mapa) | Não encontrado | Projeções e OKRs; avaliações citam interface datada | Não |
| [Miro](https://miro.com/pricing/) / [Whimsical](https://whimsical.com/pricing) | Só mapa, sem dados | Grátis a US$ 20/usuário | Diagramação geral (já temos Miro conectado) | Não |

Leitura para nós: o Funnelytics (US$ 129–349/mês) custa várias vezes uma Utmify e resolve outro problema. A Utmify responde "qual anúncio vendeu"; o Funnelytics responde "por onde as pessoas passaram". Para a Dose Saudável, o segundo depende de eventos de webinário, grupo e WhatsApp que nenhuma das duas captura sozinha.

## Aplicação à Dose Saudável

A proposta é trazer o modelo do Funnelytics para dentro do ds-revenue-dash: uma tela **Jornada** em que cada etapa é uma regra sobre a tabela de eventos que o n8n já alimenta no Supabase, e cada linha mostra a conversão entre etapas. Isso cobre o que o Funnelytics não alcança na nossa operação (webinário, grupos, WhatsApp, Hotmart, Braip, Assiny) e mantém os dados com a gente. Tudo abaixo é sugestão para discutir, não decisão.

&#91;embedded content: fluxo de dados proposto · 6 fontes, 1 banco, 1 painel\]

As fontes que o Funnelytics não lê nativamente já passam pelo n8n; gravadas como eventos no Supabase, viram etapas e conversões no painel. Se ainda quisermos testar o Funnelytics, o mesmo n8n pode duplicar os eventos para o webhook dele.

### O que copiar e onde entra

| Recurso do Funnelytics | Equivalente no ds-revenue-dash | Prioridade sugerida |
| --- | --- | --- |
| Etapa = regra sobre eventos (fonte, página, ação, offline) | Tabela de etapas com tipo + filtro em JSON sobre a tabela de eventos | Alta |
| Linha direta x pular etapas | Duas formas de calcular conversão no SQL: próxima ação da pessoa ou ação posterior dentro do período | Alta |
| Contagem por pessoa única | Contar `pessoa_id`, com a pessoa resolvida por e-mail **e** telefone (já está no plano de cruzar Hotmart com telefone) | Alta |
| Ícone offline + webhook | Eventos de grupo SendFlow, presença HotWebinar, botões do GHL e comentários do YouTube entram como ações offline | Alta |
| Metas com semáforo e ritmo | Meta de 15 vendas/dia dos gravados como Target com projeção e status verde/amarelo/vermelho | Média |
| Comparação de coortes | Comparar edições de webinário e ofertas do pitch (encaixa na página Webinar KPI) | Média |
| Step Explorer (próximos passos reais) | Consulta "o que as pessoas fizeram depois de X" para descobrir caminhos não mapeados | Média |
| Forecast com cenários | Simulador por edição: leads × presença × conversão × ticket | Baixa |
| Relatórios e link somente leitura | Exportação ou link para Marina e comercial | Baixa |
| Uma permissão só | **Não copiar** — manter admin, visualizador e personalizado | — |

### Modelo de dados sugerido

- `eventos`: `pessoa_id`, `email`, `telefone`, `nome_evento`, `atributos` (jsonb), `origem` (hotmart, braip, assiny, hotwebinar, sendflow, ghl, youtube, site), `valor_centavos`, `moeda`, `ocorrido_em`, `id_externo` (para descartar duplicados, como o Funnelytics faz com `dateTime`).
- `pessoas`: identidade unificada, com e-mails e telefones conhecidos e primeira origem.
- `jornada_etapas`: canvas, tipo (fonte, página, ação, offline), filtro em JSON, posição no desenho.
- `jornada_conexoes`: etapa de origem, etapa de destino, tipo (direta ou pular etapas).
- Uma view ou função que, dado canvas + período + filtros, devolve pessoas por etapa e conversão por conexão.

### Convenções para adotar já

- Nomes de evento estáveis e legíveis ("Compra Aprovada", "Entrou no Grupo", "Assistiu Pitch"); atributos em camelCase.
- Valores sempre em centavos inteiros, com moeda.
- Um evento por item do pedido, com `id_externo` do pedido.
- Docs de cada integração no formato da central de ajuda deles: propósito, limitações, antes de começar, passos, payload, verificação.

### Próximos passos sugeridos

- [ ] Decidir se vale um teste de 14 dias do Performance Pro só para estudar a interface.
- [ ] Levantar quais eventos o n8n já grava no Supabase e quais faltam para a jornada do webinário gravado.
- [ ] Desenhar o primeiro canvas: anúncio → inscrição → grupo → presença → pitch → compra (Hotmart/Braip/Assiny) → comercial no GHL.
- [ ] Especificar a tela Jornada como PRD para o Claude Code construir no repo.

## Fontes

Páginas consultadas em 03/10/2026. Os detalhes de cookie, endpoints internos e eventos automáticos vêm da leitura do próprio script público, que pode mudar sem aviso.

- Site e preços: [funnelytics.io](https://funnelytics.io/), [pricing](https://funnelytics.io/pricing), [mapping](https://funnelytics.io/mapping), [ecom-pricing](https://funnelytics.io/ecom-pricing), [app na Shopify](https://apps.shopify.com/funnelytics-1)
- Central de ajuda: [help.funnelytics.io](https://help.funnelytics.io/) — webhook (artigo 11725494), Zapier (11581453), Meta Ads (10909925), Google Ads (12092938), GoHighLevel (11328037), formulário GHL (12055210), HubSpot (10435931), Shopify (11202172), SPA (11668446), verificação do script (11586007), Workspace ID (11423975)
- Hub: [hub.funnelytics.io](https://hub.funnelytics.io/) — espaços Platform Training, Tracking Setup e Product Updates (changelog 2022 a nov/2025)
- Script: [cdn.funnelytics.io/track-v3.js](https://cdn.funnelytics.io/track-v3.js)
- Zapier: [app Funnelytics](https://zapier.com/apps/funnelytics/integrations)
- Reviews: [Capterra](https://www.capterra.com/p/200577/Funnelytics/reviews/), [G2](https://www.g2.com/products/funnelytics/reviews), [Trustpilot](https://ca.trustpilot.com/review/funnelytics.io), [The Digital Project Manager](https://thedigitalprojectmanager.com/tools/funnelytics-review/)
- Empresa: [BetaKit, seed 2020](https://betakit.com/?p=283311), [BetaKit, extensão 2022](https://betakit.com/funnelytics-snags-1-85-million-to-launch-version-2-0-of-its-analytics-platform/)
- Alternativas: links na tabela da seção de alternativas; preços da Utmify via [Escalafy](https://www.escalafy.com/blog/utmify-precios) (concorrente), Hyros via [Costbench](https://costbench.com/software/marketing-attribution/hyros/)

Pontos não confirmados: preço da Vision AI por plano, nota real no Trustpilot (2,5 x 3,6 em agregadores), integração da Utmify com a Braip, limites de taxa e códigos de erro do webhook.
