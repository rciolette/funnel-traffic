# Mapa n8n → Funnel Traffic (gerado em 2026-10-14)

Gerado por `scripts/mapa-instancia.mjs` a partir de `n8n-fluxos-2026-10-14.json`. Não editar à mão: mude as regras e gere de novo.

Fluxos: 298 · ativos: 152 · ativos sem classificação: 1

## Conectores que os fluxos ativos indicam

| Conector | Plataforma | No catálogo | Fluxos ativos | Negócios | Eventos propostos |
| --- | --- | --- | --- | --- | --- |
| `sellflux` | Sellflux | **não** | 27 | E-cont, ROI Club, Sem negócio identificado, Sessão Estratégica, Vendas AE (pipeline extinto) | Cadência Iniciada, Mensagem Enviada, Mensagem Falhou, Conectado |
| `assiny` | Assiny | sim | 26 | Consultoria & Mentoria, E-cont, IniciAmazon / Perpétuo, Lançamentos (L06–L08), Loot, North, Sem negócio identificado, Transversal (reembolso e suporte) | Compra Aprovada, PIX Gerado, Carrinho Abandonado, Compra Recusada, Reembolso, Assinatura Cancelada |
| `typeform` | Typeform | sim | 17 | Consultoria & Mentoria, E-cont, IniciAmazon / Perpétuo, Lançamentos (L06–L08), North, ROI Club, Sessão Estratégica, Transversal (reembolso e suporte) | Levantou a Mão, Formulário Respondido, Aplicação Enviada, Onboarding Respondido, Plano Entregue |
| `memberclass` | MemberClass | sim | 8 | IniciAmazon / Perpétuo, Lançamentos (L06–L08), ROI Club | Acesso Liberado, Acesso Removido |
| `docusign` | DocuSign | sim | 7 | Consultoria & Mentoria, E-cont, Sem negócio identificado | Contrato Enviado, Contrato Assinado |
| `n8n` | Suporte / CS | sim | 7 | E-cont, Loot, Transversal (reembolso e suporte) | Atendimento Registrado, Reembolso Solicitado |
| `memberkit` | MemberKit | sim | 6 | Consultoria & Mentoria, Lançamentos (L06–L08) | Acesso Liberado, Acesso Removido |
| `webhook` | Página de captura | sim | 5 | E-cont, Lançamentos (L06–L08), Sem negócio identificado, Sessão Estratégica | Lead Captado |
| `zoom` | Zoom | sim | 5 | E-cont, Importação (Stock) | Inscreveu-se na Live, Entrou na Live |
| `digisac` | Digisac | **não** | 4 | Interno / transversal, North, Sem negócio identificado | Contato Criado no WhatsApp, Mensagem Enviada |
| `gerador-links` | Gerador de Links | **não** | 3 | Consultoria & Mentoria, Interno / transversal | Venda Registrada, Venda Concluída, Reembolso Solicitado |
| `asaas` | Asaas | **não** | 3 | Importação (Stock) | Cobrança Criada, Pagamento Confirmado, Pagamento Recebido |
| `cakto` | Cakto | sim | 2 | IniciAmazon / Perpétuo, Transversal (reembolso e suporte) | Compra Aprovada, Reembolso |
| `manychat` | ManyChat (Direct) | **não** | 2 | Sem negócio identificado | Conversa Iniciada, Lead Triado |
| `hubla` | Hubla | sim | 2 | IniciAmazon / Perpétuo, Transversal (reembolso e suporte) | Compra Aprovada, Reembolso |
| `applyfy` | Applyfy | **não** | 1 | IniciAmazon / Perpétuo | Compra Aprovada, Reembolso |
| `clicksign` | ClickSign | **não** | 1 | Consultoria & Mentoria | Contrato Enviado, Contrato Assinado |
| `greatpages` | GreatPages | **não** | 1 | Lançamentos (L06–L08) | Formulário Respondido, Aplicação Enviada |
| `sendflow` | SendFlow | sim | 1 | Lançamentos (L06–L08) | Entrou no Grupo, Saiu do Grupo |
| `yayforms` | YayForms | **não** | 1 | IniciAmazon / Perpétuo | Formulário Respondido |
| `unnichat` | UnniChat | **não** | 1 | Lançamentos (L06–L08) | Mensagem Enviada, Respondeu |
| `wordpress` | WordPress | **não** | 1 | ROI Club | Formulário Respondido, Aplicação Enviada |

## Fluxos ativos

| Fluxo | Papel | Conector | Negócio | Atualizado |
| --- | --- | --- | --- | --- |
| [CS] Distribuição Departamentos Digisac | cadencia | `digisac` | Sem negócio identificado | 2026-05-14 |
| [DASH] Sync Digisac → Supabase | cadencia | `digisac` | Interno / transversal | 2026-10-02 |
| [NORTH] Distribuição Departamentos Digisac | cadencia | `digisac` | North | 2026-03-30 |
| [ROI] Digisac Gateway | cadencia | `digisac` | Interno / transversal | 2026-08-10 |
| [SELLFLUX] [TAGS] - ae-conectado | cadencia | `sellflux` | Vendas AE (pipeline extinto) | 2026-08-24 |
| [SELLFLUX] [TAGS] - cadencia-iniciada | cadencia | `sellflux` | ROI Club | 2026-08-24 |
| [SELLFLUX] [TAGS] - cadencia-iniciada-falha | cadencia | `sellflux` | E-cont | 2026-05-27 |
| [SELLFLUX] [TAGS] - econt-cadencia-iniciada | cadencia | `sellflux` | E-cont | 2026-08-14 |
| [SELLFLUX] [TAGS] - econt-conectado | cadencia | `sellflux` | E-cont | 2026-08-30 |
| [SELLFLUX] [TAGS] - econt-primeira-enviada | cadencia | `sellflux` | E-cont | 2026-08-14 |
| [SELLFLUX] [TAGS] - econt-segunda-enviada | cadencia | `sellflux` | E-cont | 2026-08-14 |
| [SELLFLUX] [TAGS] - econt-terceira-enviada | cadencia | `sellflux` | E-cont | 2026-08-14 |
| [SELLFLUX] [TAGS] - inside-conectado | cadencia | `sellflux` | E-cont | 2026-09-01 |
| [SELLFLUX] [TAGS] - primeira-enviada | cadencia | `sellflux` | ROI Club | 2026-08-03 |
| [SELLFLUX] [TAGS] - primeira-enviada-falha | cadencia | `sellflux` | E-cont | 2026-08-03 |
| [SELLFLUX] [TAGS] - quarta-enviada | cadencia | `sellflux` | E-cont | 2026-07-31 |
| [SELLFLUX] [TAGS] - quarta-enviada-falha | cadencia | `sellflux` | E-cont | 2026-08-03 |
| [SELLFLUX] [TAGS] - quinta-enviada | cadencia | `sellflux` | E-cont | 2026-06-08 |
| [SELLFLUX] [TAGS] - quinta-enviada-falha | cadencia | `sellflux` | E-cont | 2026-06-08 |
| [SELLFLUX] [TAGS] - segunda-enviada | cadencia | `sellflux` | E-cont | 2026-07-31 |
| [SELLFLUX] [TAGS] - segunda-enviada-falha | cadencia | `sellflux` | E-cont | 2026-08-03 |
| [SELLFLUX] [TAGS] - setima-enviada | cadencia | `sellflux` | E-cont | 2026-06-08 |
| [SELLFLUX] [TAGS] - setima-enviada-falha | cadencia | `sellflux` | E-cont | 2026-06-08 |
| [SELLFLUX] [TAGS] - sexta-enviada | cadencia | `sellflux` | E-cont | 2026-06-08 |
| [SELLFLUX] [TAGS] - sexta-enviada-falha | cadencia | `sellflux` | E-cont | 2026-06-08 |
| [SELLFLUX] [TAGS] - terceira-enviada | cadencia | `sellflux` | E-cont | 2026-07-31 |
| [SELLFLUX] [TAGS] - terceira-enviada-falha | cadencia | `sellflux` | E-cont | 2026-08-12 |
| [SELLFLUX] [TAGS] [SESSAO ESTRATEGICA] - cadencia-iniciada | cadencia | `sellflux` | Sessão Estratégica | 2026-08-30 |
| [SELLFLUX] > [ROI CLUB DB] | cadencia | `sellflux` | ROI Club | 2026-08-03 |
| [UTIL][L08] UnniChat - Auditoria, Reprocesso e Limpeza | cadencia | `unnichat` | Lançamentos (L06–L08) | 2026-09-29 |
| 🥇 [SELLFLUX] [TAGS] - Refazer Prioridades | cadencia | `sellflux` | Sem negócio identificado | 2026-06-07 |
| 5️⃣:9️⃣9️⃣ [SELLFLUX] [TAGS] - Refazer '5:99Club' | cadencia | `sellflux` | ROI Club | 2026-05-22 |
| [AE][IS] North / Levantada de Mão | entrada | `typeform` | North | 2026-04-06 |
| [APPLYFY] Compra Aprovada - Funil Nath (Front+OB e UP/DW) | entrada | `applyfy` | IniciAmazon / Perpétuo | 2026-10-14 |
| [ASSINY] [LOOT] - Assinatura Cancelada e Compra Recusada (Cartão) | entrada | `assiny` | Loot | 2026-09-12 |
| [ASSINY] [LOOT] - Compra Aprovada | entrada | `assiny` | Loot | 2026-10-08 |
| [ASSINY] [ROI Ventures Ltda] - Carrinho Abandonado | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-04-25 |
| [ASSINY] [ROI Ventures Ltda] - Compra Aprovada | entrada | `assiny` | Sem negócio identificado | 2026-07-15 |
| [ASSINY] Compra Aprovada - Funil Coelho | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-10-08 |
| [Assiny] Compra Aprovada - Mentoria [L06] - Lançamento e Consultoria Estratégica | entrada | `assiny` | Lançamentos (L06–L08) | 2026-10-08 |
| [Assiny] Compra Aprovada - Mentoria [L08] - Lançamento e Consultoria Estratégica | entrada | `assiny` | Lançamentos (L06–L08) | 2026-10-08 |
| [ASSINY] Compra Aprovada e Recuperação de Carrinho <> Nath e Tomé | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-10-14 |
| [ASSINY][AFILIADOS] Compra Aprovada e Recuperação de Carrinho | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-10-14 |
| [Assiny][Consult & Ment] - Agência ROI | entrada | `assiny` | Consultoria & Mentoria | 2026-10-05 |
| [Assiny][Consult & Ment] - Mentoria ROI | entrada | `assiny` | Consultoria & Mentoria | 2026-10-08 |
| [Assiny][Consult & Ment] - Mentoria ROI Pacote | entrada | `assiny` | Consultoria & Mentoria | 2026-10-08 |
| [Assiny][Consult & Ment] - Método ROI | entrada | `assiny` | Consultoria & Mentoria | 2026-09-16 |
| [Assiny][Consult & Ment] Compra Aprovada - Consultoria Estratégica | entrada | `assiny` | Consultoria & Mentoria | 2026-10-08 |
| [Assiny][NORTH] - NORTH MARKETING | entrada | `assiny` | North | 2026-10-08 |
| [ASSINY][ORG][NATH] Compra Aprovada e Recuperação de Carrinho | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-10-14 |
| [ASSINY][VICTORIA PAZINI] Compra Aprovada e Recuperação de Carrinho | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-10-14 |
| [CAKTO] Compra Aprovada - Funil Nath (Front+OB e UP/DW) | entrada | `cakto` | IniciAmazon / Perpétuo | 2026-10-14 |
| [Captura] - Plano Personalizado | entrada | `webhook` | Sem negócio identificado | 2026-07-13 |
| [CS] [TYPEFORM] FORMULÁRIO ONBOARDING / CS - MENTORIA | entrada | `typeform` | Consultoria & Mentoria | 2026-09-30 |
| [DM][MANYCHAT] Atualiza Negócio pós Triagem - Anúncio DM | entrada | `manychat` | Sem negócio identificado | 2026-09-17 |
| [DM][MANYCHAT] Leads Anúncio DM > Hubspot | entrada | `manychat` | Sem negócio identificado | 2026-09-17 |
| [E-CONT] [TYPEFORM] - Levantada de Mão Área de Membros | entrada | `typeform` | E-cont | 2026-09-29 |
| [E-CONT] [TYPEFORM] - Levantada de Mão Instagram Nath | entrada | `typeform` | E-cont | 2026-09-29 |
| [E-CONT] [TYPEFORM] - Levantada de Mão Live Econt | entrada | `typeform` | E-cont | 2026-10-12 |
| [E-Cont][ZOOM] Inscritos na Live - Segmentar | entrada | `zoom` | E-cont | 2026-09-24 |
| [ECONT-BH] - [ASSINY] [CNPJ] Compra Aprovada | entrada | `assiny` | E-cont | 2026-10-08 |
| [ECONT-BH] - [ASSINY] Compra Aprovada | entrada | `assiny` | E-cont | 2026-10-08 |
| [econt] - Todas as Assinys | entrada | `assiny` | E-cont | 2026-08-30 |
| [GERADOR <> Assiny] sale.rembolso — Valida etapa HubSpot (síncrono) [C] | entrada | `assiny` | Consultoria & Mentoria | 2026-09-15 |
| [GERADOR] sale.created — Valida etapa HubSpot (síncrono) [A] | entrada | `gerador-links` | Consultoria & Mentoria | 2026-09-23 |
| [GERADOR] Sincroniza agendamentos (60 min) | entrada | `gerador-links` | Interno / transversal | 2026-09-15 |
| [GERADOR][Stock-Asaas] sale.concluded — Valida etapa HubSpot (síncrono) [B] | entrada | `asaas` | Importação (Stock) | 2026-09-16 |
| [GERADOR][Stock-Asaas] sale.created — Valida etapa HubSpot (síncrono) [A] | entrada | `asaas` | Importação (Stock) | 2026-09-16 |
| [GERADOR][Stock-Asaas] Worker da fila HubSpot [C] | entrada | `asaas` | Importação (Stock) | 2026-08-07 |
| [GERAL] Cria Leads do Formulario Native Ads | entrada | `webhook` | E-cont | 2026-09-03 |
| [GreatPages][L08] - Funil de Aplicação | entrada | `greatpages` | Lançamentos (L06–L08) | 2026-10-02 |
| [HUBLA] Compra Aprovada - Funil Nath (Front+OB e UP/DW) | entrada | `hubla` | IniciAmazon / Perpétuo | 2026-10-14 |
| [IMPORTACAO] Inscritos na Live Mentoria ROI | entrada | `zoom` | Importação (Stock) | 2026-09-29 |
| [L08] [Captura] - VDV | entrada | `webhook` | Lançamentos (L06–L08) | 2026-09-30 |
| [L08] [SENDFLOW] Entrou no Grupo - Lançamento | entrada | `sendflow` | Lançamentos (L06–L08) | 2026-09-29 |
| [L08] [TYPEFORM] [TRÁFEGO / CANAL INTERNO / DISPAROS] Pesquisas Lançamento | entrada | `typeform` | Lançamentos (L06–L08) | 2026-09-29 |
| [Lead Score][YayForms]Formulário Preenchido -> Hubspot | entrada | `yayforms` | IniciAmazon / Perpétuo | 2026-08-31 |
| [link-generator] -> CONVITE NOVO USUÁRIO | entrada | `gerador-links` | Interno / transversal | 2026-08-24 |
| [REEMBOLSO] Assiny - Compra Reembolsada | entrada | `assiny` | Transversal (reembolso e suporte) | 2026-10-09 |
| [REEMBOLSO] Assiny - Reembolso Solicitado | entrada | `assiny` | Transversal (reembolso e suporte) | 2026-10-09 |
| [REEMBOLSO] Atualiza ticket para "Em Tratamento" | entrada | `n8n` | Transversal (reembolso e suporte) | 2026-03-30 |
| [REEMBOLSO] Cakto - Solicitado e Realizado (Funil Nath) | entrada | `cakto` | Transversal (reembolso e suporte) | 2026-10-02 |
| [REEMBOLSO] Hubla - Solicitado e Realizado (Funil Nath) | entrada | `hubla` | Transversal (reembolso e suporte) | 2026-10-02 |
| [REEMBOLSO] Hubspot - Reembolso Ticket Aberto | entrada | `n8n` | Transversal (reembolso e suporte) | 2026-03-30 |
| [REEMBOLSO] SLA 48h em Solicitado | entrada | `n8n` | Transversal (reembolso e suporte) | 2026-09-29 |
| [REEMBOLSO] Typeform → Slack List | entrada | `typeform` | Transversal (reembolso e suporte) | 2026-09-29 |
| [Reversão] Assiny Reembolso solicitado / Realizado -> Hubspot | entrada | `assiny` | Transversal (reembolso e suporte) | 2026-03-30 |
| [Sessão] Captação de Oportunidades | entrada | `webhook` | Sessão Estratégica | 2026-09-16 |
| [STOCK] Cria oportunidades inscritos na Live de Importação | entrada | `zoom` | Importação (Stock) | 2026-09-24 |
| [STOCK] Respostas formulário live importação | entrada | `zoom` | Importação (Stock) | 2026-09-24 |
| [SUPORTE] - BASE REEMBOLSO SOLICITADO | entrada | `n8n` | Transversal (reembolso e suporte) | 2026-10-02 |
| [Typeform][IniciAmazon 2.0] Onboarding - Pesquisa Respondida IniciAmazon 2.0 | entrada | `typeform` | IniciAmazon / Perpétuo | 2026-10-13 |
| [Typeform][ROI Club] - Funil de Aplicação | entrada | `typeform` | ROI Club | 2026-10-10 |
| [Typeform][ROI Club] - Funil de Aplicação Coelho | entrada | `typeform` | ROI Club | 2026-10-10 |
| [Typeform][Sessão Estratégica][Captação]  - Plano Personalizado | entrada | `typeform` | Sessão Estratégica | 2026-09-03 |
| [Typeform][Unificado][Leadscore] Onboarding - Pesquisa Respondida | entrada | `typeform` | IniciAmazon / Perpétuo | 2026-10-13 |
| [WordPress][ROI Club] - Funil de Aplicação | entrada | `wordpress` | ROI Club | 2026-09-16 |
| [ZOOM] Roteador de Lives (Importacao x E-cont) | entrada | `zoom` | E-cont | 2026-09-24 |
| Captação Sessão Estratégica - SE-F01E01V00TYPEFORM | entrada | `typeform` | Sessão Estratégica | 2026-09-16 |
| Captação-Ralph Leads Live 18/05/26 | entrada | `webhook` | Sem negócio identificado | 2026-05-18 |
| Carrinho Abandonado Assiny Perpétuo [297] | entrada | `assiny` | IniciAmazon / Perpétuo | 2026-10-07 |
| DIGISAC <> ASSINY - CRIAÇÃO DE CONTATOS | entrada | `assiny` | Consultoria & Mentoria | 2026-09-12 |
| [CS] [CLICKSIGN]  Mentoria - Gerar Contrato | entrega | `clicksign` | Consultoria & Mentoria | 2026-06-11 |
| [CS] [DOCUSIGN <> MemberKit] Liberar Acesso - Contrato Assinado <> MemberKit | entrega | `memberkit` | Consultoria & Mentoria | 2026-07-10 |
| [CS] Criar Acesso MemberKit - Mentoria [TIERS] | entrega | `memberkit` | Consultoria & Mentoria | 2026-10-07 |
| [CS] FORMULÁRIO ONBOARDING / CNPJ - MENTORIA | entrega | `typeform` | Consultoria & Mentoria | 2026-09-03 |
| [CS] FORMULÁRIO ONBOARDING / CS - MENTORIA | entrega | `typeform` | Consultoria & Mentoria | 2026-06-08 |
| [CS] Remover Acesso MemberKit - Mentoria [TIERS] | entrega | `memberkit` | Consultoria & Mentoria | 2026-08-05 |
| [D.S] - [ECONT] GERAR TERMO DE AUTORIZAÇÃO | entrega | `docusign` | E-cont | 2026-09-16 |
| [D.S] - GERAR CONTRATO ASSESSORIA CONTÁBIL [ECONTBH] | entrega | `docusign` | E-cont | 2026-08-28 |
| [D.S] - GERAR CONTRATO CONSULTORIA - ROI | entrega | `docusign` | Consultoria & Mentoria | 2026-07-08 |
| [D.S] - GERAR CONTRATO MENTORIA - ROI | entrega | `docusign` | Consultoria & Mentoria | 2026-08-24 |
| [Docusign] - Assinatura de Contrato Confirmada <> Redirecionar | entrega | `docusign` | Consultoria & Mentoria | 2026-08-31 |
| [EMAIL] [Econt formulário Preenchido] | entrega | `n8n` | E-cont | 2026-09-03 |
| [l06] CS - Boas Vindas - Acesso MemberKit - Mentoria | entrega | `memberkit` | Lançamentos (L06–L08) | 2026-06-15 |
| [l07] CS - Acesso MemberKit - Método ROI | entrega | `memberkit` | Lançamentos (L06–L08) | 2026-08-07 |
| [l07] CS - Acesso MemberKit - Método ROI + Extenção | entrega | `memberkit` | Lançamentos (L06–L08) | 2026-08-07 |
| [MemberClass] Assento Vip — Liberar Entrega | entrega | `memberclass` | Lançamentos (L06–L08) | 2026-09-25 |
| [MemberClass] Boas Vindas — Liberar Entrega | entrega | `memberclass` | IniciAmazon / Perpétuo | 2026-10-14 |
| [MemberClass] Froms Onboarding + IniciAmazon - Liberação de Acesso | entrega | `memberclass` | IniciAmazon / Perpétuo | 2026-08-28 |
| [MemberClass] IniciAmazon - Remoção de Acesso | entrega | `memberclass` | IniciAmazon / Perpétuo | 2026-10-02 |
| [MemberClass] IniciAmazon 2.0 — Liberar Entrega | entrega | `memberclass` | IniciAmazon / Perpétuo | 2026-09-29 |
| [MemberClass] Liberação de Acesso - [Up/DW] | entrega | `memberclass` | IniciAmazon / Perpétuo | 2026-09-03 |
| [MemberClass] ROI_Club — Liberar Entrega Sistema Código F.B.A | entrega | `memberclass` | ROI Club | 2026-10-13 |
| [MemberClass] ROI_Club — Liberar Entrega UP/DW Loja Pronta | entrega | `memberclass` | ROI Club | 2026-08-31 |
| [Onboarding] - Plano Personalizado | entrega | `typeform` | IniciAmazon / Perpétuo | 2026-07-28 |
| [Sendbox][D.S] - GERAR CONTRATO ASSESSORIA CONTÁBIL [ECONTBH] | entrega | `docusign` | E-cont | 2026-07-25 |
| [Sessão Estratégica] [Entrega] - Plano Personalizado | entrega | `typeform` | Sessão Estratégica | 2026-07-31 |
| Contract Generator Engine | entrega | `docusign` | Sem negócio identificado | 2026-03-10 |
| Loot - Verificação de Email | entrega | `n8n` | Loot | 2026-04-14 |
| Suporte [MENTORIA] Acesso E-mail | entrega | `n8n` | Transversal (reembolso e suporte) | 2026-07-22 |
| [AUDITORIA] Duplicidade por telefone · somente leitura | infra | — | Interno / transversal | 2026-08-31 |
| [DM][MANYCHAT] Error Trigger | infra | — | Sem negócio identificado | 2026-09-17 |
| [ROI] Proxy - API Monitor | infra | — | Sem negócio identificado | 2026-04-09 |
| 🧠 [SENTINELA] ACIstente v2 — Classificador de Erros | infra | — | Interno / transversal | 2026-06-18 |
| 🚨 [SELLFLUX] [TAGS] - Error Trigger | infra | — | Interno / transversal | 2026-06-18 |
| teste onecode | infra | — | North | 2026-09-04 |
| vou mudar o nome - TO ESPERANDO | infra | — | Sem negócio identificado | 2026-08-04 |
| [LN] Recuperação | nao_classificado | — | Lançamentos (L06–L08) | 2026-08-30 |
| [ECONT] - Atualizar Contatos Hubspot <> Planilhas Contabilidade SUL | saida | — | E-cont | 2026-07-30 |
| [IA] - Chat Forecast | saida | — | Interno / transversal | 2026-08-11 |
| [LOOT] Automação Clickup | saida | — | Loot | 2026-04-14 |
| [North] - Criação de Fatura | saida | — | North | 2026-04-14 |
| [North] - Webhook Invoice | saida | — | North | 2026-04-14 |
| [NOTIF] Notificador Slack ROI | saida | — | Interno / transversal | 2026-09-07 |
| [Ntfy] -> Organico Nath | saida | — | IniciAmazon / Perpétuo | 2026-08-30 |
| [ROI][ALERTA] Falha nos fluxos de tag L08 | saida | — | Lançamentos (L06–L08) | 2026-09-24 |
| [SUPORTE E RETENÇÃO][DASHBOARD V1] | saida | — | Transversal (reembolso e suporte) | 2026-08-12 |
| [TESTE] email notificação - nao identificado hubspot | saida | — | Consultoria & Mentoria | 2026-08-30 |
| HealthScore HubSpot → Google Sheets | saida | — | Sem negócio identificado | 2026-09-12 |
| Resumo de Agendamentos SDR (3x ao dia) | saida | — | Sem negócio identificado | 2026-10-02 |
| Resumo de Vendas — Receita (7h e 13h) | saida | — | Sem negócio identificado | 2026-10-06 |
