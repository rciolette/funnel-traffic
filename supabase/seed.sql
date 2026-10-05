-- Seed LOCAL (supabase db reset / scripts/testar-banco.sh). Nunca roda em produção.
-- Em produção, o dono entra pelo Auth e cria os workspaces pela função workspace_criar().
-- Usuário de teste local: dono@funnel-traffic.test / senha-local-dono (valor só de desenvolvimento).

insert into auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
                        created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
values ('00000000-0000-0000-0000-000000000000', '11111111-1111-4111-8111-111111111111', 'authenticated',
        'authenticated', 'dono@funnel-traffic.test',
        extensions.crypt('senha-local-dono', extensions.gen_salt('bf')), now(), now(), now(),
        '{"provider":"email","providers":["email"]}', '{}')
on conflict (id) do nothing;

insert into public.contas (id, nome, dono_user_id)
values ('22222222-2222-4222-8222-222222222222', 'Conta do dono', '11111111-1111-4111-8111-111111111111')
on conflict (id) do nothing;

insert into public.workspaces (id, conta_id, nome, slug) values
  ('33333333-3333-4333-8333-333333333331', '22222222-2222-4222-8222-222222222222', 'My Workspace', 'my-workspace'),
  ('33333333-3333-4333-8333-333333333332', '22222222-2222-4222-8222-222222222222', 'ROI Ventures · Lançamentos', 'roi-lancamentos')
on conflict (id) do nothing;

insert into public.workspace_membros (workspace_id, user_id, papel) values
  ('33333333-3333-4333-8333-333333333331', '11111111-1111-4111-8111-111111111111', 'dono'),
  ('33333333-3333-4333-8333-333333333332', '11111111-1111-4111-8111-111111111111', 'dono')
on conflict do nothing;
