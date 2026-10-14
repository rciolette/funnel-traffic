# Como usar o Funnel Traffic

Passo a passo de uso, do cliente novo até ler os números do canvas. Descreve o produto **como vai funcionar ao fim do MVP**. Cada passo indica o bloco do `docs/ROTEIRO.md` que o entrega; o que ainda não existe está marcado como *(previsto)*.

## 1. Conceitos em uma linha

- **Conta**: um cliente ou agência, com marca e domínio próprios.
- **Workspace**: um projeto do cliente (uma marca, um lançamento, um produto). Os dados nunca se misturam entre workspaces.
- **Conector**: uma porta de entrada de eventos (pixel, webhook de plataforma, n8n).
- **Evento**: algo que uma pessoa fez ("Page View", "Compra Aprovada").
- **Pessoa**: alguém único, reconhecido por ID externo, e-mail, telefone ou cookie, nessa ordem.
- **Etapa**: um bloco no canvas, que é uma regra sobre eventos ("visitou /obrigado", "comprou o produto X").
- **Conexão**: a linha entre duas etapas. **Direta** conta quem fez B logo em seguida; **pular** conta quem fez B em qualquer momento depois.
- **Canvas**: o mapa com etapas e conexões; cada etapa mostra pessoas únicas e cada linha mostra a conversão.

## 2. Ligar um cliente novo *(Bloco 8, previsto)*

1. O superadmin cria a conta e convida o dono do cliente por e-mail.
2. O dono entra, aceita o termo de operador de dados e, em **Configurações → Marca**, envia logo, cores e nome do produto.
3. Em **Configurações → Domínio**, cadastra `funil.cliente.com.br` e cria o CNAME que a tela mostra. Quando o certificado fica pronto, o painel passa a abrir nesse endereço, com a marca do cliente.
4. Cria um workspace por projeto e convida a equipe com papel: admin, editor ou visualizador.

## 3. Conectar as fontes *(Blocos 3, 4 e 5, previstos)*

Tela **Integrações**, sempre no mesmo fluxo: escolher a plataforma → copiar URL e chave → mandar um evento de teste → conferir o mapeamento → deixar em **sombra** → **ativar**. Em sombra, os eventos aparecem na prévia, mas não entram no canvas.

### 3.1 Pixel no site

```html
<!-- Snippet previsto: o endereço final é o domínio de coleta do cliente -->
<script async src="https://t.cliente.com.br/s.js" data-ws="CHAVE-DO-WORKSPACE"></script>
```

- Envia sozinho: page view, clique em link e botão, scroll (25/50/75/90 %), formulário e vídeo.
- Evento próprio: `ft.track("Assistiu Pitch", { webinario: "ed-12" })`.
- Identificar quem preencheu um formulário de outra ferramenta: `ft.identify({ email })`.
- Consentimento: com o modo "exigir", nada sai antes de `ft.consent(true)` ou do aceite no banner.
- Instalação: GTM (uma tag em todas as páginas), plugin WordPress ou colar no `<head>`. **Só uma vez por página.**

### 3.2 Plataforma com webhook (Hotmart, Braip, HighLevel…)

Copiar a URL do conector para a tela de webhooks da plataforma. O template traduz o payload. Plataforma sem template: usar o **Webhook genérico** e montar o mapper no editor, com a prévia do payload real ao lado.

### 3.3 Qualquer outra coisa: n8n

O workflow chama `POST` na URL do conector `n8n` com o evento canônico:

```json
{ "evento": "Entrou no Grupo", "ocorridoEm": "2026-10-04T21:18:04-03:00", "idExterno": "sendflow-998877",
  "pessoa": { "email": "pessoa@exemplo.com", "telefone": "+5511999999999" },
  "atributos": { "origem": "sendflow", "grupo": "Lançamento 12" } }
```

Regras: `idExterno` é obrigatório (o reenvio não duplica); dinheiro em `valorCentavos` com `moeda`; uma compra com 2 itens são 2 eventos.

## 4. Montar o canvas *(Bloco 6, previsto)*

1. Arrastar os blocos: **Fonte** (anúncio, UTM), **Página** (URL com `*`), **Ação** (evento + filtros) e **Offline** (WhatsApp, ligação, reunião).
2. Editar a regra em frases: "evento **é igual a** Compra Aprovada **e** produto **contém** Dieta".
3. Ligar as etapas e escolher **direta** ou **pular** (com janela em dias, opcional).
4. Escolher o período e os filtros (país, dispositivo, origem, "pessoas que fizeram").
5. Ler: o número no bloco é pessoas únicas; o número na linha é a conversão. "Dados até HH:MM:SS" mostra a frescura (meta: até 60 s).
6. **Modo funil**: só conta quem percorreu a cadeia inteira. **Comparar**: põe outro período ou grupo ao lado.
7. Salvar a versão; compartilhar por link de leitura (sem login, com senha opcional, só números agregados).

## 5. Explorar *(Bloco 7, previsto)*

- Clicar numa etapa: pessoas por dia, lista de pessoas (completa para admin, mascarada para editor, ausente para visualizador).
- Seta à direita da etapa: o que as pessoas fizeram depois. Seta à esquerda: de onde vieram. Um clique adiciona o passo ao canvas.
- Aba **Explorer**: as fontes, páginas e ações mais comuns do período.
- **Pessoas**: buscar por e-mail ou telefone e ver a linha do tempo completa (admin).

## 6. Acompanhar *(Fase 2, previsto)*

- **Monitor**: KPIs do workspace com comparação com o período anterior.
- **Metas**: alvo por etapa, ritmo projetado e status no ritmo, fora do ritmo ou crítico (regra em `src/lib/regras/conversao.ts`, `statusMeta`).
- Alertas por e-mail e Slack.

## 7. Papéis

| Papel | Vê | Faz |
| --- | --- | --- |
| Dono (da conta) | Tudo de todos os workspaces da conta | Marca, domínio, membros, chaves |
| Admin | Tudo no workspace, dado pessoal completo | Conectores, membros, canvas |
| Editor | Canvas e números; dado pessoal mascarado | Cria e edita canvas |
| Visualizador | Só números agregados | Lê |
| Link de leitura | Só números agregados do canvas compartilhado | Lê, sem login |

## 8. Problemas comuns

| Sintoma | Causa provável | O que fazer |
| --- | --- | --- |
| Etapa com zero | Conector em sombra, ou regra com texto diferente do evento real | Ativar o conector; conferir o nome do evento na prévia de Integrações |
| Números dobrados | Pixel instalado duas vezes na página | Deixar uma instalação só |
| Mesma pessoa contada duas vezes | Visita anônima sem e-mail no formulário | Passar o e-mail no `identify` ou o ID do cookie em campo oculto |
| Venda sem origem | Checkout em outro domínio sem `?ft=` | Cadastrar o domínio do checkout na lista de domínios do workspace |
| Linha direta baixa | Algum evento entre as duas etapas | Marcar esse evento como ruído ou usar conexão "pular" |
