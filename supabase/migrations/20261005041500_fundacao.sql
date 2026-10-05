-- =====================================================================================
-- 0001 · Fundação do Funnel Traffic
-- Tabelas, papéis, RLS, partição de eventos, auditoria e configuração.
-- Regras (CLAUDE.md): workspace_id em toda tabela de dados; RLS em todas; papel conferido
-- no banco por papel_no_workspace(); nada de histórico apagado (sem policy de DELETE
-- em tabela de dados); dinheiro em centavos inteiros; contagem por pessoa única.
-- =====================================================================================

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

-- -------------------------------------------------------------------------------------
-- Utilitários
-- -------------------------------------------------------------------------------------

-- atualizado_em sempre preenchido pelo banco, nunca pelo front.
create or replace function public.tocar_atualizado_em()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.atualizado_em := now();
  return new;
end $$;

-- -------------------------------------------------------------------------------------
-- Configuração (mapas que mudam com o negócio vivem em tabela, nunca no código)
-- -------------------------------------------------------------------------------------

create table public.config_papeis (
  papel text primary key,
  nivel int not null unique,           -- maior = mais poder; usado em tem_papel()
  ve_dado_pessoal text not null check (ve_dado_pessoal in ('completo', 'mascarado', 'nao')),
  descricao text not null
);
insert into public.config_papeis values
  ('dono',         40, 'completo',  'Tudo, inclusive membros e chaves'),
  ('admin',        30, 'completo',  'Tudo no workspace; convida membros'),
  ('editor',       20, 'mascarado', 'Cria e edita canvas; vê status de conectores'),
  ('visualizador', 10, 'nao',       'Só lê canvas e agregados');

create table public.config_operadores (
  op text primary key,
  rotulo text not null,                 -- frase usada no editor de regra
  tipo_valor text not null check (tipo_valor in ('texto', 'numero', 'lista', 'nenhum'))
);
insert into public.config_operadores values
  ('eq',           'é igual a',        'texto'),
  ('neq',          'é diferente de',   'texto'),
  ('contains',     'contém',           'texto'),
  ('not_contains', 'não contém',       'texto'),
  ('gt',           'maior que',        'numero'),
  ('gte',          'maior ou igual a', 'numero'),
  ('lt',           'menor que',        'numero'),
  ('lte',          'menor ou igual a', 'numero'),
  ('in',           'é um de',          'lista'),
  ('exists',       'existe',           'nenhum');

create table public.config_nomes_reservados (
  nome text primary key check (nome ~ '^__[a-z0-9_]+__$'),
  descricao text not null
);
insert into public.config_nomes_reservados values
  ('__compra__',  'Qualquer evento de compra aprovada, de qualquer conector'),
  ('__contato__', 'Qualquer evento que identifica a pessoa (formulário, cadastro, contato no CRM)');

-- -------------------------------------------------------------------------------------
-- Contas, workspaces e membros
-- -------------------------------------------------------------------------------------

create table public.contas (
  id uuid primary key default gen_random_uuid(),
  nome text not null check (length(trim(nome)) between 1 and 120),
  plano text not null default 'gratuito',          -- sem cobrança; nada no código depende disto
  dono_user_id uuid not null references auth.users (id),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.contas (dono_user_id);

create table public.workspaces (
  id uuid primary key default gen_random_uuid(),
  conta_id uuid not null references public.contas (id),
  nome text not null check (length(trim(nome)) between 1 and 120),
  slug text not null unique check (slug ~ '^[a-z0-9][a-z0-9-]{1,62}$'),
  fuso text not null default 'America/Sao_Paulo',
  regiao text not null default 'sa-east-1',
  retencao_meses int not null default 24 check (retencao_meses between 1 and 120),
  base_legal text,
  arquivado_em timestamptz,                          -- workspace nunca é apagado
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.workspaces (conta_id);

create table public.workspace_membros (
  workspace_id uuid not null references public.workspaces (id),
  user_id uuid not null references auth.users (id),
  papel text not null references public.config_papeis (papel),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  primary key (workspace_id, user_id)
);
create index on public.workspace_membros (user_id);

-- -------------------------------------------------------------------------------------
-- Papel no workspace: única fonte da verdade para RLS e para as funções do motor.
-- security definer para não recursar nas policies de workspace_membros.
-- -------------------------------------------------------------------------------------

create or replace function public.papel_no_workspace(p_workspace uuid)
returns text language sql stable security definer set search_path = '' as $$
  select coalesce(
    -- o dono da conta é dono de todos os workspaces dela, mesmo sem linha em membros
    (select 'dono' from public.workspaces w join public.contas c on c.id = w.conta_id
      where w.id = p_workspace and c.dono_user_id = (select auth.uid())),
    (select m.papel from public.workspace_membros m
      where m.workspace_id = p_workspace and m.user_id = (select auth.uid()))
  )
$$;

-- tem_papel(ws, 'editor') = papel do usuário é editor ou acima.
create or replace function public.tem_papel(p_workspace uuid, p_minimo text)
returns boolean language sql stable security definer set search_path = '' as $$
  select coalesce(
    (select a.nivel >= b.nivel
       from public.config_papeis a, public.config_papeis b
      where a.papel = public.papel_no_workspace(p_workspace) and b.papel = p_minimo),
    false)
$$;

revoke execute on function public.papel_no_workspace(uuid) from public, anon;
revoke execute on function public.tem_papel(uuid, text) from public, anon;
grant execute on function public.papel_no_workspace(uuid) to authenticated, service_role;
grant execute on function public.tem_papel(uuid, text) to authenticated, service_role;

-- -------------------------------------------------------------------------------------
-- Conectores
-- -------------------------------------------------------------------------------------

-- Catálogo global de templates (mapper JSONata + payload de exemplo + guia). Escrita só pelo service_role.
create table public.conector_templates (
  id uuid primary key default gen_random_uuid(),
  slug text not null check (slug ~ '^[a-z0-9-]+$'),
  plataforma text not null,
  categoria text not null,              -- vendas, crm, captura, engajamento, entrega, assinatura, email, reuniao, universal, site
  tipo text not null check (tipo in ('pixel', 'webhook', 'nativo')),
  versao int not null default 1,
  mapper jsonb not null default '{}'::jsonb,
  payload_exemplo jsonb,
  guia text,
  doc_url text,
  eventos text[] not null default '{}',
  fase int not null default 1,
  rascunho boolean not null default true,   -- true enquanto o payload real não foi conferido
  publico boolean not null default true,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (slug, versao)
);

create table public.conectores (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  nome text not null check (length(trim(nome)) between 1 and 120),
  slug text not null check (slug ~ '^[a-z0-9][a-z0-9-]{0,62}$'),
  tipo text not null check (tipo in ('pixel', 'webhook', 'nativo')),
  template_id uuid references public.conector_templates (id),
  mapper jsonb not null default '{}'::jsonb,
  -- a chave de ingestão nunca é guardada: só hash sha256 (hex) e prefixo para reconhecer na tela
  chave_hash text,
  chave_prefixo text,
  -- sombra: recebe e mapeia, mostra os últimos eventos, mas não entra no canvas
  modo text not null default 'sombra' check (modo in ('sombra', 'ativo', 'pausado')),
  ativado_em timestamptz,
  limite_rps int not null default 100 check (limite_rps between 1 and 10000),
  ultimo_evento_em timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  unique (workspace_id, slug)
);
create index on public.conectores (workspace_id);

create table public.conector_pedidos (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  plataforma text not null check (length(trim(plataforma)) between 1 and 120),
  doc_url text,
  payload_exemplo jsonb,
  eventos_desejados text,
  status text not null default 'novo' check (status in ('novo', 'em_analise', 'publicado', 'recusado')),
  pedido_por uuid default auth.uid() references auth.users (id),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.conector_pedidos (workspace_id);

-- -------------------------------------------------------------------------------------
-- Ingestão: receber ≠ processar. Todo payload fica aqui, válido ou não.
-- -------------------------------------------------------------------------------------

create table public.ingest_bruto (
  id bigint generated always as identity primary key,
  workspace_id uuid not null references public.workspaces (id),
  conector_id uuid not null references public.conectores (id),
  payload jsonb not null,
  cabecalhos jsonb not null default '{}'::jsonb,
  recebido_em timestamptz not null default now(),
  processado_em timestamptz,
  tentativas int not null default 0,
  erro text,
  eventos_gerados int not null default 0
);
create index ingest_bruto_pendentes on public.ingest_bruto (recebido_em) where processado_em is null;
create index on public.ingest_bruto (conector_id, recebido_em desc);
create index on public.ingest_bruto (workspace_id, recebido_em desc);

-- -------------------------------------------------------------------------------------
-- Pessoas e identidade
-- -------------------------------------------------------------------------------------

create table public.pessoas (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  primeira_origem text,
  primeiro_em timestamptz,
  ultimo_em timestamptz,
  atributos jsonb not null default '{}'::jsonb,
  fundida_em uuid references public.pessoas (id),    -- preenchido quando esta pessoa foi fundida em outra
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.pessoas (workspace_id, ultimo_em desc);
create index on public.pessoas (fundida_em) where fundida_em is not null;

create table public.identidades (
  id bigint generated always as identity primary key,
  workspace_id uuid not null references public.workspaces (id),
  pessoa_id uuid not null references public.pessoas (id),
  tipo text not null check (tipo in ('externo', 'email', 'telefone', 'cookie')),
  valor_normalizado text not null check (length(valor_normalizado) between 1 and 320),
  fonte text,
  visto_em timestamptz not null default now(),
  unique (workspace_id, tipo, valor_normalizado)
);
create index on public.identidades (pessoa_id);

create table public.pessoa_fusoes (
  id bigint generated always as identity primary key,
  workspace_id uuid not null references public.workspaces (id),
  pessoa_mantida uuid not null references public.pessoas (id),
  pessoa_fundida uuid not null references public.pessoas (id),
  motivo text not null,
  identidades_movidas jsonb not null default '[]'::jsonb,   -- para reverter sem perder nada
  criado_em timestamptz not null default now(),
  revertida_em timestamptz,
  check (pessoa_mantida <> pessoa_fundida)
);
create index on public.pessoa_fusoes (workspace_id, criado_em desc);

-- -------------------------------------------------------------------------------------
-- Eventos: particionada por mês em ocorrido_em.
-- Dedupe vive em eventos_chaves (sem partição), porque um unique em tabela particionada
-- precisaria incluir ocorrido_em e deixaria passar o mesmo idExterno com outra data.
-- -------------------------------------------------------------------------------------

create table public.eventos (
  id uuid not null default gen_random_uuid(),
  workspace_id uuid not null,
  pessoa_id uuid not null,
  conector_id uuid not null,
  ingest_id bigint,
  evento text not null check (length(evento) between 1 and 200),
  atributos jsonb not null default '{}'::jsonb,
  valor_centavos bigint,
  moeda char(3),
  id_externo text not null,
  ocorrido_em timestamptz not null,
  recebido_em timestamptz not null default now(),
  url text,
  pais text,
  dispositivo text,
  primary key (id, ocorrido_em),
  check (valor_centavos is null or moeda is not null)
) partition by range (ocorrido_em);

create index on public.eventos (workspace_id, pessoa_id, ocorrido_em);
create index on public.eventos (workspace_id, evento, ocorrido_em);
create index on public.eventos using gin (atributos jsonb_path_ops);

create table public.eventos_chaves (
  workspace_id uuid not null,
  conector_id uuid not null,
  id_externo text not null,
  evento text not null,
  evento_id uuid not null,
  ocorrido_em timestamptz not null,
  criado_em timestamptz not null default now(),
  primary key (workspace_id, conector_id, id_externo, evento)
);

-- Eventos de conector em modo sombra: mesma forma, fora do motor. Só os últimos importam para a prévia.
create table public.eventos_sombra (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  conector_id uuid not null references public.conectores (id),
  ingest_id bigint,
  evento text not null,
  pessoa jsonb not null default '{}'::jsonb,
  atributos jsonb not null default '{}'::jsonb,
  valor_centavos bigint,
  moeda char(3),
  id_externo text not null,
  ocorrido_em timestamptz not null,
  criado_em timestamptz not null default now()
);
create index on public.eventos_sombra (conector_id, criado_em desc);

-- Cria a partição do mês de p_quando se ainda não existir. Chamada pelo registro de evento
-- (partição sob demanda cobre importação de histórico antigo) e pelo cron mensal.
create or replace function public.eventos_garantir_particao(p_quando timestamptz)
returns text language plpgsql security definer set search_path = '' as $$
declare
  v_ini date := date_trunc('month', p_quando at time zone 'UTC')::date;
  v_nome text := 'eventos_p' || to_char(v_ini, 'YYYYMM');
begin
  if to_regclass('public.' || v_nome) is null then
    execute format(
      'create table if not exists public.%I partition of public.eventos for values from (%L) to (%L)',
      v_nome, v_ini::timestamptz, (v_ini + interval '1 month')::date::timestamptz);
    execute format('alter table public.%I enable row level security', v_nome);
  end if;
  return v_nome;
end $$;
revoke execute on function public.eventos_garantir_particao(timestamptz) from public, anon, authenticated;

-- Partições iniciais: 2026 e 2027 inteiros.
do $$
declare m date;
begin
  for m in select generate_series('2026-01-01'::date, '2027-12-01'::date, interval '1 month')::date loop
    perform public.eventos_garantir_particao(m::timestamptz);
  end loop;
end $$;

-- -------------------------------------------------------------------------------------
-- Canvas
-- -------------------------------------------------------------------------------------

create table public.canvases (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  nome text not null check (length(trim(nome)) between 1 and 160),
  tags text[] not null default '{}',
  versao int not null default 1,
  arquivado_em timestamptz,
  criado_por uuid default auth.uid() references auth.users (id),
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.canvases (workspace_id);

-- Histórico de versões: cada "salvar versão" grava o snapshot inteiro (etapas + conexões).
create table public.canvas_versoes (
  id bigint generated always as identity primary key,
  workspace_id uuid not null references public.workspaces (id),
  canvas_id uuid not null references public.canvases (id),
  versao int not null,
  snapshot jsonb not null,
  criado_por uuid default auth.uid() references auth.users (id),
  criado_em timestamptz not null default now(),
  unique (canvas_id, versao)
);

create table public.etapas (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  canvas_id uuid not null references public.canvases (id),
  tipo text not null check (tipo in ('fonte', 'pagina', 'acao', 'offline')),
  nome text not null check (length(trim(nome)) between 1 and 160),
  filtro jsonb not null default '{}'::jsonb,
  pos_x double precision not null default 0,
  pos_y double precision not null default 0,
  valor_meta_centavos bigint,
  removida_em timestamptz,               -- etapa removida do desenho continua no histórico
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.etapas (canvas_id) where removida_em is null;

create table public.conexoes (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  canvas_id uuid not null references public.canvases (id),
  de_etapa uuid not null references public.etapas (id),
  para_etapa uuid not null references public.etapas (id),
  tipo text not null default 'direta' check (tipo in ('direta', 'pular')),
  janela_dias int check (janela_dias is null or janela_dias between 1 and 365),
  removida_em timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),
  check (de_etapa <> para_etapa)
);
create index on public.conexoes (canvas_id) where removida_em is null;

-- Etapa e conexão sempre no mesmo workspace e canvas do pai (evita mistura entre tenants).
create or replace function public.conferir_canvas_do_workspace()
returns trigger language plpgsql set search_path = '' as $$
begin
  if not exists (select 1 from public.canvases c where c.id = new.canvas_id and c.workspace_id = new.workspace_id) then
    raise exception 'canvas % não pertence ao workspace %', new.canvas_id, new.workspace_id;
  end if;
  if tg_table_name = 'conexoes' then
    -- plpgsql avalia new.de_etapa só aqui dentro; em etapas o campo não existe
    if (select count(*) from public.etapas e
         where e.id in (new.de_etapa, new.para_etapa) and e.canvas_id = new.canvas_id) <> 2 then
      raise exception 'etapas da conexão precisam estar no mesmo canvas';
    end if;
  end if;
  return new;
end $$;
create trigger etapas_conferir before insert or update on public.etapas
  for each row execute function public.conferir_canvas_do_workspace();
create trigger conexoes_conferir before insert or update on public.conexoes
  for each row execute function public.conferir_canvas_do_workspace();

-- -------------------------------------------------------------------------------------
-- Metas, link de leitura, auditoria, erros de front
-- -------------------------------------------------------------------------------------

create table public.metas (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  nome text not null,
  kpi_regra jsonb not null,
  alvo numeric not null check (alvo > 0),
  limite_alerta numeric not null default 0.8 check (limite_alerta > 0 and limite_alerta <= 1),
  periodo text not null default 'mes' check (periodo in ('dia', 'semana', 'mes')),
  canal_alerta text,
  arquivada_em timestamptz,
  criado_em timestamptz not null default now(),
  atualizado_em timestamptz not null default now()
);
create index on public.metas (workspace_id);

-- Token do link somente leitura: só o hash. Sem policy para anon; a função pública de agregados valida.
create table public.links_leitura (
  id uuid primary key default gen_random_uuid(),
  workspace_id uuid not null references public.workspaces (id),
  canvas_id uuid not null references public.canvases (id),
  token_hash text not null unique,
  token_prefixo text not null,
  senha_hash text,
  expira_em timestamptz,
  revogado_em timestamptz,
  criado_por uuid default auth.uid() references auth.users (id),
  criado_em timestamptz not null default now()
);

create table public.auditoria (
  id bigint generated always as identity primary key,
  workspace_id uuid,
  autor uuid default auth.uid(),
  acao text not null,
  tabela text not null,
  registro_id text,
  antes jsonb,
  depois jsonb,
  criado_em timestamptz not null default now()
);
create index on public.auditoria (workspace_id, criado_em desc);

create table public.funnel_traffic_erros_front (
  id bigint generated always as identity primary key,
  app text not null check (length(app) <= 60),
  componente text check (length(componente) <= 200),
  mensagem text check (length(mensagem) <= 2000),
  stack text check (length(stack) <= 4000),
  url text check (length(url) <= 2000),
  user_agent text check (length(user_agent) <= 500),
  user_id uuid default auth.uid(),
  criado_em timestamptz not null default now()
);

-- Trigger genérico de auditoria: antes/depois em jsonb. Chave nunca aparece (só hash), então pode ir inteira.
create or replace function public.auditar()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_ws uuid;
  v_antes jsonb := case when tg_op in ('UPDATE', 'DELETE') then to_jsonb(old) end;
  v_depois jsonb := case when tg_op in ('INSERT', 'UPDATE') then to_jsonb(new) end;
begin
  v_ws := coalesce(v_depois ->> 'workspace_id', v_antes ->> 'workspace_id',
                   case when tg_table_name = 'workspaces' then coalesce(v_depois ->> 'id', v_antes ->> 'id') end)::uuid;
  insert into public.auditoria (workspace_id, acao, tabela, registro_id, antes, depois)
  values (v_ws, lower(tg_op), tg_table_name,
          coalesce(v_depois ->> 'id', v_antes ->> 'id', v_depois ->> 'user_id', v_antes ->> 'user_id'),
          v_antes, v_depois);
  return coalesce(new, old);
end $$;

create trigger auditar_membros after insert or update or delete on public.workspace_membros
  for each row execute function public.auditar();
create trigger auditar_conectores after insert or update of chave_hash, modo, mapper on public.conectores
  for each row execute function public.auditar();
create trigger auditar_fusoes after insert or update on public.pessoa_fusoes
  for each row execute function public.auditar();
create trigger auditar_links after insert or update on public.links_leitura
  for each row execute function public.auditar();
create trigger auditar_workspaces after insert or update on public.workspaces
  for each row execute function public.auditar();

-- atualizado_em automático
do $$
declare t text;
begin
  foreach t in array array['contas','workspaces','workspace_membros','conector_templates','conectores',
                           'conector_pedidos','pessoas','canvases','etapas','conexoes','metas'] loop
    execute format('create trigger %I before update on public.%I for each row execute function public.tocar_atualizado_em()',
                   t || '_atualizado_em', t);
  end loop;
end $$;

-- Quem cria um workspace vira dono dele (linha explícita em membros, além do dono da conta).
create or replace function public.workspace_registrar_criador()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.uid()) is not null then
    insert into public.workspace_membros (workspace_id, user_id, papel)
    values (new.id, (select auth.uid()), 'dono')
    on conflict do nothing;
  end if;
  return new;
end $$;
create trigger workspaces_criador after insert on public.workspaces
  for each row execute function public.workspace_registrar_criador();

-- Caminho único para o dono criar um workspace: garante a conta dele e devolve o id.
-- Nome e slug são do usuário; nada fixo no produto.
create or replace function public.workspace_criar(p_nome text, p_slug text, p_nome_conta text default null)
returns uuid language plpgsql security invoker set search_path = '' as $$
declare
  v_conta uuid;
  v_ws uuid;
begin
  if (select auth.uid()) is null then
    raise exception 'precisa estar logado';
  end if;
  select id into v_conta from public.contas where dono_user_id = (select auth.uid()) order by criado_em limit 1;
  if v_conta is null then
    insert into public.contas (nome, dono_user_id)
    values (coalesce(p_nome_conta, 'Minha conta'), (select auth.uid()))
    returning id into v_conta;
  end if;
  -- id gerado antes: RETURNING passaria pela policy de leitura, que ainda não enxerga a linha nova
  v_ws := gen_random_uuid();
  insert into public.workspaces (id, conta_id, nome, slug) values (v_ws, v_conta, p_nome, p_slug);
  return v_ws;
end $$;
revoke execute on function public.workspace_criar(text, text, text) from public, anon;
grant execute on function public.workspace_criar(text, text, text) to authenticated;

-- -------------------------------------------------------------------------------------
-- RLS: ligado em TODAS as tabelas. Sem policy de DELETE em tabela de dados.
-- -------------------------------------------------------------------------------------

alter table public.config_papeis enable row level security;
alter table public.config_operadores enable row level security;
alter table public.config_nomes_reservados enable row level security;
alter table public.contas enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_membros enable row level security;
alter table public.conector_templates enable row level security;
alter table public.conectores enable row level security;
alter table public.conector_pedidos enable row level security;
alter table public.ingest_bruto enable row level security;
alter table public.pessoas enable row level security;
alter table public.identidades enable row level security;
alter table public.pessoa_fusoes enable row level security;
alter table public.eventos enable row level security;
alter table public.eventos_chaves enable row level security;
alter table public.eventos_sombra enable row level security;
alter table public.canvases enable row level security;
alter table public.canvas_versoes enable row level security;
alter table public.etapas enable row level security;
alter table public.conexoes enable row level security;
alter table public.metas enable row level security;
alter table public.links_leitura enable row level security;
alter table public.auditoria enable row level security;
alter table public.funnel_traffic_erros_front enable row level security;

-- Configuração: leitura para quem está logado; escrita só service_role (sem policy).
create policy ler on public.config_papeis for select to authenticated using (true);
create policy ler on public.config_operadores for select to authenticated using (true);
create policy ler on public.config_nomes_reservados for select to authenticated using (true);
create policy ler on public.conector_templates for select to authenticated using (publico);

-- Contas: só o dono.
create policy dono_le on public.contas for select to authenticated using (dono_user_id = (select auth.uid()));
create policy dono_cria on public.contas for insert to authenticated with check (dono_user_id = (select auth.uid()));
create policy dono_edita on public.contas for update to authenticated
  using (dono_user_id = (select auth.uid())) with check (dono_user_id = (select auth.uid()));

-- Workspaces
create policy membro_le on public.workspaces for select to authenticated
  using (public.papel_no_workspace(id) is not null);
create policy dono_conta_cria on public.workspaces for insert to authenticated
  with check (exists (select 1 from public.contas c where c.id = conta_id and c.dono_user_id = (select auth.uid())));
create policy admin_edita on public.workspaces for update to authenticated
  using (public.tem_papel(id, 'admin')) with check (public.tem_papel(id, 'admin'));

-- Membros: todo membro vê quem está no workspace; admin+ gerencia; ninguém se promove acima de si.
create policy membro_le on public.workspace_membros for select to authenticated
  using (public.papel_no_workspace(workspace_id) is not null);
create policy admin_cria on public.workspace_membros for insert to authenticated
  with check (public.tem_papel(workspace_id, 'admin')
              and (papel <> 'dono' or public.tem_papel(workspace_id, 'dono')));
create policy admin_edita on public.workspace_membros for update to authenticated
  using (public.tem_papel(workspace_id, 'admin'))
  with check (public.tem_papel(workspace_id, 'admin') and (papel <> 'dono' or public.tem_papel(workspace_id, 'dono')));
create policy admin_remove on public.workspace_membros for delete to authenticated
  using (public.tem_papel(workspace_id, 'admin') and user_id <> (select auth.uid()));

-- Conectores: editor vê (status), admin+ cria e edita.
create policy editor_le on public.conectores for select to authenticated using (public.tem_papel(workspace_id, 'editor'));
create policy admin_cria on public.conectores for insert to authenticated with check (public.tem_papel(workspace_id, 'admin'));
create policy admin_edita on public.conectores for update to authenticated
  using (public.tem_papel(workspace_id, 'admin')) with check (public.tem_papel(workspace_id, 'admin'));

create policy editor_le on public.conector_pedidos for select to authenticated using (public.tem_papel(workspace_id, 'editor'));
create policy editor_cria on public.conector_pedidos for insert to authenticated with check (public.tem_papel(workspace_id, 'editor'));
create policy admin_edita on public.conector_pedidos for update to authenticated
  using (public.tem_papel(workspace_id, 'admin')) with check (public.tem_papel(workspace_id, 'admin'));

-- Dado bruto e pessoal: só admin+. Editor e visualizador leem pelas funções do motor (agregados/mascarado).
create policy admin_le on public.ingest_bruto for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
create policy admin_le on public.pessoas for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
create policy admin_le on public.identidades for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
create policy admin_le on public.pessoa_fusoes for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
create policy admin_le on public.eventos for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
create policy admin_le on public.eventos_sombra for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
-- eventos_chaves: sem policy (só o worker, via service_role).

-- Canvas: qualquer membro lê; editor+ escreve.
create policy membro_le on public.canvases for select to authenticated using (public.papel_no_workspace(workspace_id) is not null);
create policy editor_cria on public.canvases for insert to authenticated with check (public.tem_papel(workspace_id, 'editor'));
create policy editor_edita on public.canvases for update to authenticated
  using (public.tem_papel(workspace_id, 'editor')) with check (public.tem_papel(workspace_id, 'editor'));

create policy membro_le on public.canvas_versoes for select to authenticated using (public.papel_no_workspace(workspace_id) is not null);
create policy editor_cria on public.canvas_versoes for insert to authenticated with check (public.tem_papel(workspace_id, 'editor'));

create policy membro_le on public.etapas for select to authenticated using (public.papel_no_workspace(workspace_id) is not null);
create policy editor_cria on public.etapas for insert to authenticated with check (public.tem_papel(workspace_id, 'editor'));
create policy editor_edita on public.etapas for update to authenticated
  using (public.tem_papel(workspace_id, 'editor')) with check (public.tem_papel(workspace_id, 'editor'));

create policy membro_le on public.conexoes for select to authenticated using (public.papel_no_workspace(workspace_id) is not null);
create policy editor_cria on public.conexoes for insert to authenticated with check (public.tem_papel(workspace_id, 'editor'));
create policy editor_edita on public.conexoes for update to authenticated
  using (public.tem_papel(workspace_id, 'editor')) with check (public.tem_papel(workspace_id, 'editor'));

create policy membro_le on public.metas for select to authenticated using (public.papel_no_workspace(workspace_id) is not null);
create policy editor_cria on public.metas for insert to authenticated with check (public.tem_papel(workspace_id, 'editor'));
create policy editor_edita on public.metas for update to authenticated
  using (public.tem_papel(workspace_id, 'editor')) with check (public.tem_papel(workspace_id, 'editor'));

create policy admin_le on public.links_leitura for select to authenticated using (public.tem_papel(workspace_id, 'admin'));
create policy admin_cria on public.links_leitura for insert to authenticated with check (public.tem_papel(workspace_id, 'admin'));
create policy admin_edita on public.links_leitura for update to authenticated
  using (public.tem_papel(workspace_id, 'admin')) with check (public.tem_papel(workspace_id, 'admin'));

create policy admin_le on public.auditoria for select to authenticated using (public.tem_papel(workspace_id, 'admin'));

-- Erro de front pode acontecer antes do login (tela de entrar): insert aberto, leitura só service_role.
create policy registrar on public.funnel_traffic_erros_front for insert to anon, authenticated
  with check (user_id is null or user_id = (select auth.uid()));

-- Funções-gatilho não são API.
revoke execute on function public.auditar() from public, anon, authenticated;
revoke execute on function public.workspace_registrar_criador() from public, anon, authenticated;
revoke execute on function public.conferir_canvas_do_workspace() from public, anon, authenticated;
revoke execute on function public.tocar_atualizado_em() from public, anon, authenticated;
