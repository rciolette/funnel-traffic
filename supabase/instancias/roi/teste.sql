-- Teste da versão de testes LOCAL da instância ROI. Roda depois de seed.sql (scripts/instancia-local.sh roi).
-- Confere que a estrutura veio inteira do mapa e que nada vaza entre contas.
\set ON_ERROR_STOP 1
begin;

do $$
declare v_conta uuid := '44444444-4444-4444-8444-444444444442';
begin
  assert (select count(*) from public.workspaces where conta_id = v_conta) = 9, '9 workspaces, um por negócio';
  assert not exists (
    select 1 from public.workspaces w where w.conta_id = v_conta
       and not exists (select 1 from public.conectores c where c.workspace_id = w.id)
  ), 'todo workspace tem pelo menos um conector';
  assert not exists (
    select 1 from public.conectores c join public.workspaces w on w.id = c.workspace_id
     where w.conta_id = v_conta and c.modo <> 'sombra'
  ), 'todo conector da instância nasce em sombra';
  assert not exists (
    select 1 from public.conectores c join public.workspaces w on w.id = c.workspace_id
     where w.conta_id = v_conta and c.template_id is null
  ), 'todo conector aponta para um template';
  assert not exists (select 1 from public.conector_templates where rascunho = false and slug in
    (select c.slug from public.conectores c join public.workspaces w on w.id = c.workspace_id where w.conta_id = v_conta)),
    'templates da instância continuam em rascunho';
  assert (select count(*) from public.pessoas p join public.workspaces w on w.id = p.workspace_id where w.conta_id = v_conta) = 0,
    'nenhuma pessoa: o seed não traz dado real';
  assert (select count(*) from public.canvases c join public.workspaces w on w.id = c.workspace_id where w.conta_id = v_conta) = 2,
    '2 canvases de exemplo';
  assert (select count(*) from public.conexoes x join public.workspaces w on w.id = x.workspace_id where w.conta_id = v_conta) = 5,
    '5 conexões de exemplo';
  assert exists (
    select 1 from public.conectores c join public.workspaces w on w.id = c.workspace_id
     where w.slug = 'roi-econt' and c.slug in ('assiny', 'typeform', 'hubspot')
    group by w.id having count(*) = 3
  ), 'E-cont tem Assiny, Typeform e HubSpot';
end $$;

-- O dono da ROI vê os 9 workspaces dele e nenhum da conta do seed padrão.
set role authenticated;
select set_config('request.jwt.claims', '{"sub":"44444444-4444-4444-8444-444444444441","role":"authenticated"}', false);
do $$ begin
  assert (select count(*) from public.workspaces) = 9, 'dono ROI vê só os 9 workspaces da conta dele';
  assert public.papel_no_workspace((select id from public.workspaces where slug = 'roi-econt')) = 'dono', 'papel dono no E-cont';
  assert (select count(*) from public.workspaces where slug = 'my-workspace') = 0, 'não vê My Workspace de outra conta';
end $$;

-- O dono do seed padrão não vê nada da ROI.
select set_config('request.jwt.claims', '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}', false);
do $$ begin
  assert (select count(*) from public.workspaces where slug like 'roi-%' and slug <> 'roi-lancamentos') = 0,
    'outra conta não enxerga a instância ROI';
end $$;
reset role;

select 'instancia roi: ok' as resultado;
rollback;
