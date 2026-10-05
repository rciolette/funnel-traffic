-- Testes de RLS e regras da migration 0001. Rodam em transação e desfazem tudo no fim.
-- Cada bloco troca de papel (anon / authenticated com um sub) e confere o que pode ver e fazer.
\set ON_ERROR_STOP 1
begin;

-- Usuários de teste (além do dono do seed)
insert into auth.users (id, email) values
  ('aaaaaaaa-0000-4000-8000-00000000000e', 'editor@funnel-traffic.test'),
  ('aaaaaaaa-0000-4000-8000-00000000000f', 'leitor@funnel-traffic.test'),
  ('aaaaaaaa-0000-4000-8000-0000000000ff', 'estranho@funnel-traffic.test');
insert into public.workspace_membros (workspace_id, user_id, papel) values
  ('33333333-3333-4333-8333-333333333331', 'aaaaaaaa-0000-4000-8000-00000000000e', 'editor'),
  ('33333333-3333-4333-8333-333333333331', 'aaaaaaaa-0000-4000-8000-00000000000f', 'visualizador');

-- Dados como superusuário (o worker usa service_role)
insert into public.pessoas (id, workspace_id) values
  ('bbbbbbbb-0000-4000-8000-000000000001', '33333333-3333-4333-8333-333333333331');
insert into public.conectores (id, workspace_id, nome, slug, tipo) values
  ('cccccccc-0000-4000-8000-000000000001', '33333333-3333-4333-8333-333333333331', 'Teste', 'teste', 'webhook');

-- ---------------------------------------------------------------- dono
set role authenticated;
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', false);
do $$ begin
  assert (select count(*) from public.workspaces) = 2, 'dono vê os 2 workspaces';
  assert public.papel_no_workspace('33333333-3333-4333-8333-333333333332') = 'dono', 'papel dono';
  assert (select count(*) from public.pessoas) = 1, 'dono vê pessoas';
  assert (select count(*) from public.conectores) = 1, 'dono vê conectores';
  insert into public.canvases (id, workspace_id, nome) values
    ('dddddddd-0000-4000-8000-000000000001', '33333333-3333-4333-8333-333333333331', 'Lançamento');
  -- nada de histórico apagado: sem policy de delete
  delete from public.canvases where id = 'dddddddd-0000-4000-8000-000000000001';
  assert (select count(*) from public.canvases) = 1, 'delete de canvas não apaga (sem policy)';
  assert (select count(*) from public.auditoria where tabela = 'workspace_membros') >= 2, 'auditoria registra membros';
end $$;

-- ---------------------------------------------------------------- editor
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-4000-8000-00000000000e","role":"authenticated"}', false);
do $$ begin
  assert (select count(*) from public.workspaces) = 1, 'editor vê só o workspace dele';
  assert (select count(*) from public.canvases) = 1, 'editor vê canvas';
  assert (select count(*) from public.conectores) = 1, 'editor vê status de conector';
  assert (select count(*) from public.pessoas) = 0, 'editor não lê pessoas direto';
  assert (select count(*) from public.eventos) = 0, 'editor não lê eventos direto';
  assert (select count(*) from public.auditoria) = 0, 'editor não lê auditoria';
  insert into public.etapas (workspace_id, canvas_id, tipo, nome)
    values ('33333333-3333-4333-8333-333333333331', 'dddddddd-0000-4000-8000-000000000001', 'acao', 'Compra');
  begin
    insert into public.conectores (workspace_id, nome, slug, tipo)
      values ('33333333-3333-4333-8333-333333333331', 'X', 'x', 'webhook');
    raise exception 'FALHOU: editor criou conector';
  exception when insufficient_privilege then null;
  end;
  update public.workspace_membros set papel = 'dono' where user_id = 'aaaaaaaa-0000-4000-8000-00000000000e';
  assert public.papel_no_workspace('33333333-3333-4333-8333-333333333331') = 'editor', 'editor não se promove';
end $$;

-- ---------------------------------------------------------------- visualizador
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-4000-8000-00000000000f","role":"authenticated"}', false);
do $$ begin
  assert (select count(*) from public.canvases) = 1, 'visualizador lê canvas';
  assert (select count(*) from public.etapas) = 1, 'visualizador lê etapas';
  assert (select count(*) from public.conectores) = 0, 'visualizador não vê conectores';
  begin
    insert into public.canvases (workspace_id, nome) values ('33333333-3333-4333-8333-333333333331', 'X');
    raise exception 'FALHOU: visualizador criou canvas';
  exception when insufficient_privilege then null;
  end;
end $$;

-- ---------------------------------------------------------------- estranho (logado, sem papel)
select set_config('request.jwt.claims', '{"sub":"aaaaaaaa-0000-4000-8000-0000000000ff","role":"authenticated"}', false);
do $$ begin
  assert (select count(*) from public.workspaces) = 0, 'estranho não vê workspace';
  assert (select count(*) from public.canvases) = 0, 'estranho não vê canvas';
  assert public.papel_no_workspace('33333333-3333-4333-8333-333333333331') is null, 'estranho sem papel';
  begin
    insert into public.canvases (workspace_id, nome) values ('33333333-3333-4333-8333-333333333331', 'X');
    raise exception 'FALHOU: estranho criou canvas';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.workspaces (conta_id, nome, slug) values ('22222222-2222-4222-8222-222222222222', 'X', 'xx-invasor');
    raise exception 'FALHOU: estranho criou workspace na conta do dono';
  exception when insufficient_privilege then null;
  end;
  -- workspace_criar cria conta própria para quem ainda não tem
  perform public.workspace_criar('Meu teste', 'meu-teste-estranho', 'Conta estranho');
  assert (select count(*) from public.workspaces) = 1, 'estranho vê só o workspace que criou';
  assert public.papel_no_workspace((select id from public.workspaces where slug = 'meu-teste-estranho')) = 'dono', 'criador é dono';
end $$;

-- ---------------------------------------------------------------- anon
reset role;
select set_config('request.jwt.claims', '', false);
set role anon;
do $$ begin
  assert (select count(*) from public.workspaces) = 0, 'anon não vê workspace';
  assert (select count(*) from public.conector_templates) = 0, 'anon não lê catálogo';
  insert into public.funnel_traffic_erros_front (app, componente, mensagem) values ('funnel-traffic', 'Login', 'teste');
  assert (select count(*) from public.funnel_traffic_erros_front) = 0, 'anon não lê erros';
  begin
    perform public.papel_no_workspace('33333333-3333-4333-8333-333333333331');
    raise exception 'FALHOU: anon executou papel_no_workspace';
  exception when insufficient_privilege then null;
  end;
end $$;

-- ---------------------------------------------------------------- regras de estrutura
reset role;
do $$ begin
  -- partição sob demanda para histórico antigo
  perform public.eventos_garantir_particao('2019-05-10T12:00:00Z');
  assert to_regclass('public.eventos_p201905') is not null, 'partição criada sob demanda';
  insert into public.eventos (workspace_id, pessoa_id, conector_id, evento, id_externo, ocorrido_em)
    values ('33333333-3333-4333-8333-333333333331', 'bbbbbbbb-0000-4000-8000-000000000001',
            'cccccccc-0000-4000-8000-000000000001', 'Compra Aprovada', 'X1', '2019-05-10T12:00:00Z');
  -- RLS ligado em toda tabela do schema public, inclusive partições
  assert not exists (
    select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public' and c.relkind in ('r', 'p') and not c.relrowsecurity
  ), 'toda tabela com RLS';
  -- dinheiro exige moeda
  begin
    insert into public.eventos (workspace_id, pessoa_id, conector_id, evento, id_externo, ocorrido_em, valor_centavos)
      values ('33333333-3333-4333-8333-333333333331', 'bbbbbbbb-0000-4000-8000-000000000001',
              'cccccccc-0000-4000-8000-000000000001', 'Compra', 'X2', now(), 100);
    raise exception 'FALHOU: valor sem moeda';
  exception when check_violation then null;
  end;
  -- etapa não pode apontar canvas de outro workspace
  begin
    insert into public.etapas (workspace_id, canvas_id, tipo, nome)
      values ('33333333-3333-4333-8333-333333333332', 'dddddddd-0000-4000-8000-000000000001', 'acao', 'X');
    raise exception 'FALHOU: etapa cruzou workspace';
  exception when raise_exception then
    if sqlerrm like 'FALHOU%' then raise; end if;
  end;
end $$;

select 'rls: ok' as resultado;
rollback;
