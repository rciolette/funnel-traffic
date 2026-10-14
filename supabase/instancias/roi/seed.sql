-- GERADO por scripts/seed-instancia.mjs roi em 2026-10-14. Não editar à mão.
-- Versão de testes LOCAL da instância "ROI Ventures (teste local)". Nunca roda em produção.
-- Sem pessoas e sem eventos: só a estrutura (conta, workspaces, conectores em sombra, canvases).

insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
values ('00000000-0000-0000-0000-000000000000', '44444444-4444-4444-8444-444444444441', 'authenticated', 'authenticated', 'roi-dono@funnel-traffic.test',
        extensions.crypt('senha-local-dono', extensions.gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}')
on conflict (id) do nothing;

insert into funnel_traffic.contas (id, nome, dono_user_id) values ('44444444-4444-4444-8444-444444444442', 'ROI Ventures (teste local)', '44444444-4444-4444-8444-444444444441') on conflict (id) do nothing;

-- Workspaces: um por negócio do mapa
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'E-cont', 'roi-econt') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'IniciAmazon · Perpétuo', 'roi-iniciamazon') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Consultoria & Mentoria', 'roi-consultoria-mentoria') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'ROI Club', 'roi-club') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Sessão Estratégica', 'roi-sessao-estrategica') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Lançamentos', 'roi-lancamentos-teste') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'North', 'roi-north') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Importação · Stock', 'roi-importacao') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Loot', 'roi-loot') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Comercial · Pré Vendas e Closer''s', 'roi-comercial') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Compras · todas as ofertas', 'roi-compras') on conflict (slug) do nothing;
insert into funnel_traffic.workspaces (conta_id, nome, slug) values ('44444444-4444-4444-8444-444444444442', 'Reembolsos e suporte', 'roi-reembolsos') on conflict (slug) do nothing;

-- Templates de conector (rascunho até conferir payload real)
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('applyfy', 'Applyfy', 'vendas', 'webhook', array['Compra Aprovada', 'Reembolso']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('asaas', 'Asaas', 'vendas', 'webhook', array['Cobrança Criada', 'Pagamento Confirmado', 'Pagamento Recebido']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('assiny', 'Assiny', 'vendas', 'webhook', array['Compra Aprovada', 'PIX Gerado', 'Carrinho Abandonado', 'Compra Recusada', 'Reembolso', 'Assinatura Cancelada']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('cakto', 'Cakto', 'vendas', 'webhook', array['Compra Aprovada', 'Reembolso']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('clicksign', 'ClickSign', 'entrega', 'webhook', array['Contrato Enviado', 'Contrato Assinado']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('digisac', 'Digisac', 'engajamento', 'webhook', array['Contato Criado no WhatsApp', 'Mensagem Enviada']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('docusign', 'DocuSign', 'entrega', 'webhook', array['Contrato Enviado', 'Contrato Assinado']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('gerador-links', 'Gerador de Links', 'vendas', 'webhook', array['Venda Registrada', 'Venda Concluída', 'Reembolso Solicitado']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('greatpages', 'GreatPages', 'captura', 'webhook', array['Formulário Respondido', 'Aplicação Enviada']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('hubla', 'Hubla', 'vendas', 'webhook', array['Compra Aprovada', 'Reembolso']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('hubspot', 'HubSpot (sincronização de negócios do Gerador)', 'crm', 'webhook', array['Oportunidade Criada', 'Reunião Agendada', 'Negócio Mudou de Etapa', 'Negócio Ganho', 'Negócio Perdido']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('memberclass', 'MemberClass', 'entrega', 'webhook', array['Acesso Liberado', 'Acesso Removido']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('memberkit', 'MemberKit', 'entrega', 'webhook', array['Acesso Liberado', 'Acesso Removido']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('n8n', 'Suporte / CS', 'entrega', 'webhook', array['Atendimento Registrado', 'Reembolso Solicitado']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('sellflux', 'Sellflux', 'engajamento', 'webhook', array['Cadência Iniciada', 'Mensagem Enviada', 'Mensagem Falhou', 'Conectado']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('sendflow', 'SendFlow', 'engajamento', 'webhook', array['Entrou no Grupo', 'Saiu do Grupo']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('typeform', 'Typeform', 'captura', 'webhook', array['Levantou a Mão', 'Formulário Respondido', 'Aplicação Enviada', 'Onboarding Respondido', 'Plano Entregue']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('unnichat', 'UnniChat', 'engajamento', 'webhook', array['Mensagem Enviada', 'Respondeu']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('webhook', 'Native Ads (formulário)', 'captura', 'webhook', array['Lead Captado']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('wordpress', 'WordPress', 'captura', 'webhook', array['Formulário Respondido', 'Aplicação Enviada']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('yayforms', 'YayForms', 'captura', 'webhook', array['Formulário Respondido']::text[], true) on conflict (slug, versao) do nothing;
insert into funnel_traffic.conector_templates (slug, plataforma, categoria, tipo, eventos, rascunho) values ('zoom', 'Zoom', 'reuniao', 'webhook', array['Inscreveu-se na Live', 'Entrou na Live']::text[], true) on conflict (slug, versao) do nothing;

-- Conectores por workspace, todos em modo sombra
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["S8ARqnguP6VYclA4","ti6n6YEW7I6q74TS","1pOznPyQild7PBL2"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'DocuSign', 'docusign', 'webhook', t.id, '{"_rascunho":true,"eventos":["Contrato Enviado","Contrato Assinado"],"fluxosN8n":["9IZH9V6bpzJW6YiE","N5GKAbQN1kpbfGuo","nzuUNUX6T6cXXAQ1"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'docusign' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'HubSpot (sincronização de negócios do Gerador)', 'hubspot', 'webhook', t.id, '{"_rascunho":true,"eventos":["Oportunidade Criada","Reunião Agendada","Negócio Mudou de Etapa","Negócio Ganho","Negócio Perdido"],"fluxosN8n":[],"pipelines":["717654561"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'hubspot' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Suporte / CS', 'n8n', 'webhook', t.id, '{"_rascunho":true,"eventos":["Atendimento Registrado"],"fluxosN8n":["Td8uDRI5Bv00n8Dk"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'n8n' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Sellflux', 'sellflux', 'webhook', t.id, '{"_rascunho":true,"eventos":["Cadência Iniciada","Mensagem Enviada","Mensagem Falhou","Conectado"],"fluxosN8n":["jh6ZE3JPDXuVn49s","W9bUNhf8JZIEX5LY","FHvgNJGjFZqYvyTD","PyTrhrrRmBlpT7lh","0tr1Qg2tFjxk5V5i","fDmWVgbl7Qqx26mJ","5P2N7Dv0flYqjlqS","iYkJpSRMbr72tezQ","BeIj5njWe0R5Bcyj","ENUIRFngFu3aZ2qx","MG9Bfj3cltQKapTk","4BQW2EXYlrrmINnf","sH2SJrsVX4D4jcUk","lCu79ETXHUvLLCP7","wpasZZAPrC3j1Hpl","7GGi9oUDLoU63flk","CiTtbk1VLSU1U8B3","7iFeP80MdZ0U7HiA","timXMbLkCgSA50tC","LsF3SOLHGZ2eypL8"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'sellflux' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Levantou a Mão"],"fluxosN8n":["FDtlOVmzajE7WKlQ","ardntsNvRM6EKJ0p","jSB9bB0PjSKRvkxu"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Native Ads (formulário)', 'webhook', 'webhook', t.id, '{"_rascunho":true,"eventos":["Lead Captado"],"fluxosN8n":["gB0tNiJB7J9c8TOV"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'webhook' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Zoom', 'zoom', 'webhook', t.id, '{"_rascunho":true,"eventos":["Inscreveu-se na Live","Entrou na Live"],"fluxosN8n":["zWSwFTWe5a0pnVMv","7nYfjClxutR3lJE8"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'zoom' and t.versao = 1
 where w.slug = 'roi-econt' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Applyfy', 'applyfy', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["DWdCeqObDR0e7F8I"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'applyfy' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["SsIoM4TuLH23d9G5","VohlaCBrn3wXvNVC","9oR5w4R5YLhzwSLV","wy3xgvumLhtEwzY0","oyfDoTaqsvsMtmqt","mLYUFQPX3WdSYXNp"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Cakto', 'cakto', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["hH73XMxgvX2clSLn"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'cakto' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Hubla', 'hubla', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["w938FUK8KfJBjRxJ"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'hubla' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'MemberClass', 'memberclass', 'webhook', t.id, '{"_rascunho":true,"eventos":["Acesso Liberado","Acesso Removido"],"fluxosN8n":["39rFRh94FuCmV0Yf","WbYHNgGbbMIY2Cg5","zwt2l5Hyq5JG53WW","y4zJARFijFsECnlU","VrSEUaLSVU9OZY5q"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'memberclass' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Onboarding Respondido","Plano Entregue","Formulário Respondido","Levantou a Mão","Aplicação Enviada"],"fluxosN8n":["raNrZb2YIxFGcyx4","HcZXGdxc6E0Ppds3","j1PEpOM3oEIXVmLI"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'YayForms', 'yayforms', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido"],"fluxosN8n":["2V3UyX1caG3YHJx3"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'yayforms' and t.versao = 1
 where w.slug = 'roi-iniciamazon' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["WPM29ueUswqbIAeZ","0gAvV7SHdC2pFx01","6DmZyVbNmNozUOMi","WReWPl2fIKd371wR","ZvPCWomr2PFRJnDx","nrtfXsKWKqOqgnfC","CF30LqPyRV95XZ1e"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-consultoria-mentoria' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'ClickSign', 'clicksign', 'webhook', t.id, '{"_rascunho":true,"eventos":["Contrato Enviado","Contrato Assinado"],"fluxosN8n":["2OXDlzaFjxzwBLhv"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'clicksign' and t.versao = 1
 where w.slug = 'roi-consultoria-mentoria' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'DocuSign', 'docusign', 'webhook', t.id, '{"_rascunho":true,"eventos":["Contrato Enviado","Contrato Assinado"],"fluxosN8n":["eM3YjY8lUB26EmDL","uFv5sjTGkaCftyk1","EKgM6PodWylpMcHv"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'docusign' and t.versao = 1
 where w.slug = 'roi-consultoria-mentoria' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Gerador de Links', 'gerador-links', 'webhook', t.id, '{"_rascunho":true,"eventos":["Venda Registrada","Venda Concluída","Reembolso Solicitado"],"fluxosN8n":["HSvwUAQO3gisevoh"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'gerador-links' and t.versao = 1
 where w.slug = 'roi-consultoria-mentoria' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'MemberKit', 'memberkit', 'webhook', t.id, '{"_rascunho":true,"eventos":["Acesso Liberado","Acesso Removido"],"fluxosN8n":["Yk8XJRnZu3E4eYZX","kp1vVp5jnRyZdDhw","nQadGLFKVSw07TFS"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'memberkit' and t.versao = 1
 where w.slug = 'roi-consultoria-mentoria' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido","Levantou a Mão","Aplicação Enviada","Onboarding Respondido","Plano Entregue"],"fluxosN8n":["HSJ6tkjHYhBgMo9e","AwifH900ty0WoyYa","yIp9gO8FJ778IMGd"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-consultoria-mentoria' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'MemberClass', 'memberclass', 'webhook', t.id, '{"_rascunho":true,"eventos":["Acesso Liberado","Acesso Removido"],"fluxosN8n":["cuTcuZDFUWHIlykR","6u2vtUj69COjja8N"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'memberclass' and t.versao = 1
 where w.slug = 'roi-club' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Sellflux', 'sellflux', 'webhook', t.id, '{"_rascunho":true,"eventos":["Cadência Iniciada","Mensagem Enviada","Mensagem Falhou","Conectado"],"fluxosN8n":["zLbAhvduwh3xla4g","2NFvICSi4hDSCBfY","kfmjsuGvnuKw41PI","NZtxKklm6cXwX83I"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'sellflux' and t.versao = 1
 where w.slug = 'roi-club' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido","Levantou a Mão","Aplicação Enviada"],"fluxosN8n":["lpWkYtTl9Ad6CmAA","JfsnRagGQ6VwTeKR"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-club' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'WordPress', 'wordpress', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido","Aplicação Enviada"],"fluxosN8n":["uktgtx1e7l6gd7yx"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'wordpress' and t.versao = 1
 where w.slug = 'roi-club' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Sellflux', 'sellflux', 'webhook', t.id, '{"_rascunho":true,"eventos":["Cadência Iniciada","Mensagem Enviada","Mensagem Falhou","Conectado"],"fluxosN8n":["tVkAnSYlIiUeFxQr"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'sellflux' and t.versao = 1
 where w.slug = 'roi-sessao-estrategica' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Onboarding Respondido","Plano Entregue","Formulário Respondido","Levantou a Mão","Aplicação Enviada"],"fluxosN8n":["i33Pog89xYO2VhmM","5zeLdcD0l9CcWCrD","zsZ4UuuZuOqIzD7R"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-sessao-estrategica' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Página de captura', 'webhook', 'webhook', t.id, '{"_rascunho":true,"eventos":["Lead Captado"],"fluxosN8n":["gtotJfdEAfVYccB2"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'webhook' and t.versao = 1
 where w.slug = 'roi-sessao-estrategica' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["VqPyFhglqpJJtVNO","3fNUVohNos9MRYfs"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'GreatPages', 'greatpages', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido","Aplicação Enviada"],"fluxosN8n":["686MFW8wnTJlYC18"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'greatpages' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'MemberClass', 'memberclass', 'webhook', t.id, '{"_rascunho":true,"eventos":["Acesso Liberado","Acesso Removido"],"fluxosN8n":["Bl7mVQa6rfgzXRAa"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'memberclass' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'MemberKit', 'memberkit', 'webhook', t.id, '{"_rascunho":true,"eventos":["Acesso Liberado","Acesso Removido"],"fluxosN8n":["mGhNpEZOIJlWEPlE","EZhMg8vIyQsk4Kfj","pH43wgM3YPrQwy1H"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'memberkit' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'SendFlow', 'sendflow', 'webhook', t.id, '{"_rascunho":true,"eventos":["Entrou no Grupo","Saiu do Grupo"],"fluxosN8n":["vUIQVjzWkXmONLvx"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'sendflow' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido","Levantou a Mão","Aplicação Enviada"],"fluxosN8n":["YCT8pd0aqMytmOQc"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'UnniChat', 'unnichat', 'webhook', t.id, '{"_rascunho":true,"eventos":["Mensagem Enviada","Respondeu"],"fluxosN8n":["TRyMyebGNA7SOcC2"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'unnichat' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Página de captura', 'webhook', 'webhook', t.id, '{"_rascunho":true,"eventos":["Lead Captado"],"fluxosN8n":["MHiaWi849bEGMwmW"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'webhook' and t.versao = 1
 where w.slug = 'roi-lancamentos-teste' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["T86EmgUAnQoiAAKH"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-north' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Digisac', 'digisac', 'webhook', t.id, '{"_rascunho":true,"eventos":["Contato Criado no WhatsApp","Mensagem Enviada"],"fluxosN8n":["nLUaTLoMyOudjIEk"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'digisac' and t.versao = 1
 where w.slug = 'roi-north' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Levantou a Mão"],"fluxosN8n":["00eyQpTRi8gLc8Lb"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-north' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Asaas', 'asaas', 'webhook', t.id, '{"_rascunho":true,"eventos":["Cobrança Criada","Pagamento Confirmado","Pagamento Recebido"],"fluxosN8n":["UQAPNSyWj2GOraJg","y6gmmAWN84q07xJW","S1jtMIyQZWihcFGh"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'asaas' and t.versao = 1
 where w.slug = 'roi-importacao' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'HubSpot (sincronização de negócios do Gerador)', 'hubspot', 'webhook', t.id, '{"_rascunho":true,"eventos":["Oportunidade Criada","Reunião Agendada","Negócio Mudou de Etapa","Negócio Ganho","Negócio Perdido"],"fluxosN8n":[],"pipelines":["894137220"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'hubspot' and t.versao = 1
 where w.slug = 'roi-importacao' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Zoom', 'zoom', 'webhook', t.id, '{"_rascunho":true,"eventos":["Inscreveu-se na Live","Entrou na Live"],"fluxosN8n":["onQco8DyHV4wHzME","o38sErXSUcsfc28u","AbLjjO7QOYSG6H0x"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'zoom' and t.versao = 1
 where w.slug = 'roi-importacao' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["Fcn0jw69yfDDHZ18","IjGIisdXwDCSZmVR"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-loot' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Suporte / CS', 'n8n', 'webhook', t.id, '{"_rascunho":true,"eventos":["Atendimento Registrado"],"fluxosN8n":["mIsqPTpbNPSRttKf"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'n8n' and t.versao = 1
 where w.slug = 'roi-loot' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'HubSpot (sincronização de negócios do Gerador)', 'hubspot', 'webhook', t.id, '{"_rascunho":true,"eventos":["Oportunidade Criada","Reunião Agendada","Negócio Mudou de Etapa","Negócio Ganho","Negócio Perdido"],"fluxosN8n":[],"pipelines":["932401505","932402477"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'hubspot' and t.versao = 1
 where w.slug = 'roi-comercial' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Applyfy', 'applyfy', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["DWdCeqObDR0e7F8I"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'applyfy' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Asaas', 'asaas', 'webhook', t.id, '{"_rascunho":true,"eventos":["Cobrança Criada","Pagamento Confirmado","Pagamento Recebido"],"fluxosN8n":["UQAPNSyWj2GOraJg","y6gmmAWN84q07xJW","S1jtMIyQZWihcFGh"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'asaas' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["Fcn0jw69yfDDHZ18","IjGIisdXwDCSZmVR","d99eqmYW4TAOBFTs","pDXLyM9lrldly6KG","SsIoM4TuLH23d9G5","VqPyFhglqpJJtVNO","3fNUVohNos9MRYfs","VohlaCBrn3wXvNVC","9oR5w4R5YLhzwSLV","WPM29ueUswqbIAeZ","0gAvV7SHdC2pFx01","6DmZyVbNmNozUOMi","WReWPl2fIKd371wR","ZvPCWomr2PFRJnDx","T86EmgUAnQoiAAKH","wy3xgvumLhtEwzY0","oyfDoTaqsvsMtmqt","S8ARqnguP6VYclA4","ti6n6YEW7I6q74TS","1pOznPyQild7PBL2","nrtfXsKWKqOqgnfC","OMMUW76oBBGWrrxL","C6teqTHR0r73bO4L","4tRhbwJIDjYianU5","mLYUFQPX3WdSYXNp","CF30LqPyRV95XZ1e"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Cakto', 'cakto', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["hH73XMxgvX2clSLn","olMZUWz1iSdWtq2q"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'cakto' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Gerador de Links', 'gerador-links', 'webhook', t.id, '{"_rascunho":true,"eventos":["Venda Registrada","Venda Concluída","Reembolso Solicitado"],"fluxosN8n":["HSvwUAQO3gisevoh","TJuqpkxWijglh2Nn","4sWw9oIx7jQLT2ay"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'gerador-links' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Hubla', 'hubla', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["w938FUK8KfJBjRxJ","r9EB6f2rWlyXXIuG"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'hubla' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Suporte de reembolso', 'n8n', 'webhook', t.id, '{"_rascunho":true,"eventos":["Reembolso Solicitado"],"fluxosN8n":["fRiKBxXN4amsaEcP","juCjhOL96C3jBMm3","FI7FW27elEQ3AUhE","Wz2KvSu98dtl23N5"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'n8n' and t.versao = 1
 where w.slug = 'roi-compras' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Assiny', 'assiny', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","PIX Gerado","Carrinho Abandonado","Compra Recusada","Reembolso","Assinatura Cancelada"],"fluxosN8n":["OMMUW76oBBGWrrxL","C6teqTHR0r73bO4L","4tRhbwJIDjYianU5"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'assiny' and t.versao = 1
 where w.slug = 'roi-reembolsos' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Cakto', 'cakto', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["olMZUWz1iSdWtq2q"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'cakto' and t.versao = 1
 where w.slug = 'roi-reembolsos' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Hubla', 'hubla', 'webhook', t.id, '{"_rascunho":true,"eventos":["Compra Aprovada","Reembolso"],"fluxosN8n":["r9EB6f2rWlyXXIuG"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'hubla' and t.versao = 1
 where w.slug = 'roi-reembolsos' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Suporte de reembolso', 'n8n', 'webhook', t.id, '{"_rascunho":true,"eventos":["Reembolso Solicitado","Atendimento Registrado"],"fluxosN8n":["fRiKBxXN4amsaEcP","juCjhOL96C3jBMm3","FI7FW27elEQ3AUhE","Wz2KvSu98dtl23N5","C5YiuWZKJ6HVFGMU"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'n8n' and t.versao = 1
 where w.slug = 'roi-reembolsos' on conflict (workspace_id, slug) do nothing;
insert into funnel_traffic.conectores (workspace_id, nome, slug, tipo, template_id, mapper, modo)
select w.id, 'Typeform', 'typeform', 'webhook', t.id, '{"_rascunho":true,"eventos":["Formulário Respondido","Levantou a Mão","Aplicação Enviada"],"fluxosN8n":["c3lKYfoDQ3LCBbJA"]}'::jsonb, 'sombra'
  from funnel_traffic.workspaces w left join funnel_traffic.conector_templates t on t.slug = 'typeform' and t.versao = 1
 where w.slug = 'roi-reembolsos' on conflict (workspace_id, slug) do nothing;

-- Canvases de exemplo (regras em rascunho; formato do filtro fecha no Bloco 2)
do $$
declare v_ws uuid; v_canvas uuid;
begin
  select id into v_ws from funnel_traffic.workspaces where slug = 'roi-econt';
  if exists (select 1 from funnel_traffic.canvases where workspace_id = v_ws and nome = 'Jornada E-cont (rascunho do mapa)') then return; end if;
  insert into funnel_traffic.canvases (workspace_id, nome, tags) values (v_ws, 'Jornada E-cont (rascunho do mapa)', array['teste-local']) returning id into v_canvas;
  create temporary table _etapas (chave text, id uuid) on commit drop;
  with novas as (
    insert into funnel_traffic.etapas (workspace_id, canvas_id, tipo, nome, filtro, pos_x, pos_y)
    select v_ws, v_canvas, e.tipo, e.nome, e.filtro, e.x, e.y from (values
    ('mao', 'acao', 'Levantou a mão', '{"evento":"Levantou a Mão"}'::jsonb, 40, 120),
    ('neg', 'offline', 'Em negociação (HubSpot E-cont)', '{"evento":"Negócio Mudou de Etapa","atributos":[{"campo":"etapa","op":"eq","valor":"1345942844"}]}'::jsonb, 340, 120),
    ('compra', 'acao', 'Compra aprovada', '{"evento":"__compra__"}'::jsonb, 640, 120)
    ) as e(chave, tipo, nome, filtro, x, y)
    returning id, nome
  )
  insert into _etapas select e.chave, n.id from novas n join (values
    ('mao', 'Levantou a mão'),
    ('neg', 'Em negociação (HubSpot E-cont)'),
    ('compra', 'Compra aprovada')
  ) as e(chave, nome) on e.nome = n.nome;
  insert into funnel_traffic.conexoes (workspace_id, canvas_id, de_etapa, para_etapa, tipo, janela_dias)
  select v_ws, v_canvas, d.id, p.id, c.tipo, c.janela from (values
    ('mao', 'neg', 'pular', 30),
    ('neg', 'compra', 'pular', 30)
  ) as c(de, para, tipo, janela) join _etapas d on d.chave = c.de join _etapas p on p.chave = c.para;
  drop table _etapas;
end $$;
do $$
declare v_ws uuid; v_canvas uuid;
begin
  select id into v_ws from funnel_traffic.workspaces where slug = 'roi-iniciamazon';
  if exists (select 1 from funnel_traffic.canvases where workspace_id = v_ws and nome = 'Perpétuo: compra → acesso (rascunho do mapa)') then return; end if;
  insert into funnel_traffic.canvases (workspace_id, nome, tags) values (v_ws, 'Perpétuo: compra → acesso (rascunho do mapa)', array['teste-local']) returning id into v_canvas;
  create temporary table _etapas (chave text, id uuid) on commit drop;
  with novas as (
    insert into funnel_traffic.etapas (workspace_id, canvas_id, tipo, nome, filtro, pos_x, pos_y)
    select v_ws, v_canvas, e.tipo, e.nome, e.filtro, e.x, e.y from (values
    ('pix', 'acao', 'PIX gerado', '{"evento":"PIX Gerado"}'::jsonb, 40, 120),
    ('compra', 'acao', 'Compra aprovada', '{"evento":"__compra__"}'::jsonb, 340, 120),
    ('acesso', 'acao', 'Acesso liberado (MemberClass)', '{"evento":"Acesso Liberado"}'::jsonb, 640, 120),
    ('reembolso', 'acao', 'Reembolso', '{"evento":"Reembolso"}'::jsonb, 640, 300)
    ) as e(chave, tipo, nome, filtro, x, y)
    returning id, nome
  )
  insert into _etapas select e.chave, n.id from novas n join (values
    ('pix', 'PIX gerado'),
    ('compra', 'Compra aprovada'),
    ('acesso', 'Acesso liberado (MemberClass)'),
    ('reembolso', 'Reembolso')
  ) as e(chave, nome) on e.nome = n.nome;
  insert into funnel_traffic.conexoes (workspace_id, canvas_id, de_etapa, para_etapa, tipo, janela_dias)
  select v_ws, v_canvas, d.id, p.id, c.tipo, c.janela from (values
    ('pix', 'compra', 'direta', null),
    ('compra', 'acesso', 'pular', 2),
    ('compra', 'reembolso', 'pular', 30)
  ) as c(de, para, tipo, janela) join _etapas d on d.chave = c.de join _etapas p on p.chave = c.para;
  drop table _etapas;
end $$;
do $$
declare v_ws uuid; v_canvas uuid;
begin
  select id into v_ws from funnel_traffic.workspaces where slug = 'roi-comercial';
  if exists (select 1 from funnel_traffic.canvases where workspace_id = v_ws and nome = 'Comercial: Pré Vendas → Closer''s (rascunho do mapa)') then return; end if;
  insert into funnel_traffic.canvases (workspace_id, nome, tags) values (v_ws, 'Comercial: Pré Vendas → Closer''s (rascunho do mapa)', array['teste-local']) returning id into v_canvas;
  create temporary table _etapas (chave text, id uuid) on commit drop;
  with novas as (
    insert into funnel_traffic.etapas (workspace_id, canvas_id, tipo, nome, filtro, pos_x, pos_y)
    select v_ws, v_canvas, e.tipo, e.nome, e.filtro, e.x, e.y from (values
    ('novo', 'offline', 'Novo lead (Pré Vendas)', '{"evento":"Negócio Mudou de Etapa","atributos":[{"campo":"etapa","op":"eq","valor":"1432137902"}]}'::jsonb, 40, 120),
    ('bastao', 'offline', 'Passagem de bastão', '{"evento":"Negócio Mudou de Etapa","atributos":[{"campo":"etapa","op":"eq","valor":"1431586371"}]}'::jsonb, 300, 120),
    ('realizada', 'offline', 'Reunião realizada (Closer''s)', '{"evento":"Negócio Mudou de Etapa","atributos":[{"campo":"etapa","op":"eq","valor":"1431596972"}]}'::jsonb, 560, 120),
    ('proposta', 'offline', 'Proposta enviada', '{"evento":"Negócio Mudou de Etapa","atributos":[{"campo":"etapa","op":"eq","valor":"1431596973"}]}'::jsonb, 820, 120),
    ('ganho', 'offline', 'Ganho', '{"evento":"Negócio Mudou de Etapa","atributos":[{"campo":"etapa","op":"eq","valor":"1431596975"}]}'::jsonb, 1080, 120)
    ) as e(chave, tipo, nome, filtro, x, y)
    returning id, nome
  )
  insert into _etapas select e.chave, n.id from novas n join (values
    ('novo', 'Novo lead (Pré Vendas)'),
    ('bastao', 'Passagem de bastão'),
    ('realizada', 'Reunião realizada (Closer''s)'),
    ('proposta', 'Proposta enviada'),
    ('ganho', 'Ganho')
  ) as e(chave, nome) on e.nome = n.nome;
  insert into funnel_traffic.conexoes (workspace_id, canvas_id, de_etapa, para_etapa, tipo, janela_dias)
  select v_ws, v_canvas, d.id, p.id, c.tipo, c.janela from (values
    ('novo', 'bastao', 'pular', 60),
    ('bastao', 'realizada', 'pular', 30),
    ('realizada', 'proposta', 'pular', 30),
    ('proposta', 'ganho', 'pular', 30)
  ) as c(de, para, tipo, janela) join _etapas d on d.chave = c.de join _etapas p on p.chave = c.para;
  drop table _etapas;
end $$;
