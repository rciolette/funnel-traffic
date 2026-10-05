# Catálogo de conectores — Funnel Traffic

Cada conector é um template: `mapper.json` + `GUIA.md` nesta pasta (`docs/conectores/<slug>/`), escritos a partir de um payload real da plataforma. "Webhook" = a plataforma envia eventos, basta mapper. "Via n8n" = um workflow n8n consulta a API e envia o evento canônico ao conector `n8n`.

| Plataforma | Slug | Tipo | Eventos que entram no funil | Fase |
| --- | --- | --- | --- | --- |
| n8n | `n8n` | Universal (payload canônico) | Qualquer evento de qualquer API | 1 |
| Webhook genérico | `webhook` | Webhook + mapper em branco | Qualquer plataforma sem template | 1 |
| Hotmart | `hotmart` | Webhook + mapper | Compra Aprovada, PIX Gerado, Carrinho Abandonado, Reembolso, Assinatura Cancelada | 1 |
| Braip | `braip` | Webhook (postback) + mapper | Compra Aprovada, PIX Gerado, Recusada, Reembolso | 1 |
| Assiny | `assiny` | Webhook + mapper; import CSV | Compra Aprovada, Aguardando Pagamento, Recusada, Reembolso | 1 |
| Cakto | `cakto` | Webhook + mapper | Compra Aprovada, PIX Gerado, Abandono | 1 |
| Hubla | `hubla` | Webhook + mapper | Compra Aprovada, Assinatura, Cancelamento | 1 |
| HighLevel | `highlevel` | Webhook de workflow + mapper | Oportunidade Criada, Mudou de Etapa, Agendamento, Formulário, Tag Adicionada | 1 |
| HubSpot | `hubspot` | Webhook de workflow + mapper | Contato Criado, Deal Mudou de Etapa, Formulário, Reunião Agendada | 1 |
| Typeform | `typeform` | Webhook + mapper, campo oculto com id da pessoa | Form Completed | 1 |
| Inlead | `inlead` | Webhook + mapper | Quiz Respondido, Lead Score, Tier | 1 |
| HotWebinar | `hotwebinar` | Webhook + mapper (ou via n8n) | Inscrição, Presença, Assistiu até X %, Clicou na Oferta | 1 |
| SendFlow | `sendflow` | Webhook + mapper | Entrou no Grupo, Saiu do Grupo, Mensagem Enviada | 1 |
| MemberKit | `memberkit` | Webhook + mapper | Acesso Liberado, Primeiro Login, Aula Concluída, Curso Concluído | 1 |
| Cademi | `cademi` | Webhook + mapper | idem | 1 |
| MemberClass | `memberclass` | Via n8n | idem | 1 |
| DocuSign | `docusign` | Webhook Connect + mapper | Contrato Enviado, Visualizado, Assinado | 1 |
| SendPulse | `sendpulse` | Webhook + mapper | E-mail Aberto, Clicou, Descadastrou | 1 |
| Zoom | `zoom` | Webhook + mapper | Entrou na Reunião, Saiu, Minutos Assistidos | 1 |
| WordPress / sites | `pixel` | Pixel `track.js` (plugin ou GTM) | Page View, Clique, Scroll, Form Completed, Video View | 1 |
| YouTube | `pixel` / `n8n` | Pixel (embed); via n8n para comentários | Video View, Comentou | 1 / 2 |
| Short.io | `n8n` | Via n8n (API de cliques) | Link Click com UTMs | 2 |
| HighLevel e HubSpot nativos | — | OAuth | Mesmos eventos sem webhook | 3 |
| Meta Ads, Google Ads | — | OAuth (custo) | Investimento por campanha | Fora de escopo |

Não são conectores: GitHub, Miro. Saídas (não entrada): Slack, e-mail, webhook de saída.

## Formato do mapper (rascunho, fechar na Fase 0)

```json
{
  "slug": "hotmart",
  "versao": 1,
  "evento": { "caminho": "event", "dePara": { "PURCHASE_APPROVED": "Compra Aprovada", "PURCHASE_REFUNDED": "Reembolso" } },
  "ocorridoEm": "creation_date",
  "idExterno": "data.purchase.transaction",
  "pessoa": { "email": "data.buyer.email", "telefone": "data.buyer.checkout_phone", "idExterno": "data.buyer.ucode" },
  "atributos": { "origem": "'hotmart'", "sku": "data.product.ucode", "valorCentavos": "data.purchase.price.value * 100", "moeda": "data.purchase.price.currency_value" },
  "itens": "data.purchase.offer"
}
```

Expressões em JSONata. Campos e caminhos acima são ilustrativos: confirmar no payload real antes de publicar o template.
