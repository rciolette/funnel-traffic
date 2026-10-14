# White label e multi-cliente

Como o Funnel Traffic atende várias empresas, cada uma com a própria marca, sem mudar código. Pedido do dono em 14/10/2026.

## 1. Hierarquia

```
Plataforma (RC Digitais — superadmin)
└── Conta (uma por cliente/agência: ROI Ventures, Dose Saudável, …) → marca, domínio, e-mail, limites
    └── Workspace (um por projeto/marca do cliente) → conectores, pessoas, eventos, canvases
        └── Membros com papel (dono, admin, editor, visualizador) + links de leitura
```

O que já existe no banco: `contas` → `workspaces` → `workspace_membros`, RLS por workspace e o dono da conta como dono de todos os workspaces dela (`papel_no_workspace`). O que falta: a marca e o domínio da conta, o superadmin da plataforma e os limites por conta.

## 2. Duas formas de rodar

| | Instância compartilhada (padrão) | Instância dedicada |
| --- | --- | --- |
| O que é | Um Supabase e um Worker para muitas contas | Um Supabase e um Worker só para um cliente |
| Isolamento | RLS por workspace (já pronto) | Banco separado |
| Quando usar | Clientes pequenos e médios, agências | Exigência contratual ou de LGPD, volume alto (> 10 M eventos/mês) |
| Exemplo | Instância RC Digitais | Instância ROI Ventures (decisão de 05/10) |
| Custo de manter | Uma migration e um deploy | Repetir migration e deploy por instância (script) |

Nas duas formas o banco fica no schema `funnel_traffic`, o que permite instalar o produto também num Supabase que já tem outros apps (como o `roi-apps`).

**O código é o mesmo nas duas.** Nenhum nome de cliente entra no código: a marca vem do banco (instância compartilhada) ou de variáveis de ambiente (instância dedicada).

## 3. O que vira configuração da conta

Tabela nova `conta_marcas` (uma linha por conta, RLS: lê quem é membro de algum workspace da conta, escreve o dono da conta):

| Campo | Uso |
| --- | --- |
| `nome_produto` | Nome mostrado no lugar de "Funnel Traffic" |
| `logo_url`, `logo_escuro_url`, `favicon_url` | Arquivos no Storage, bucket `marcas` |
| `cor_primaria`, `cor_destaque`, `raio` | Tokens do tema. O front grava como variáveis CSS (`--primary` etc.) |
| `fonte` | Família do Google Fonts, de uma lista permitida |
| `dominio_app` | `funil.cliente.com.br` (domínio próprio do painel) |
| `dominio_pixel` | `t.cliente.com.br` (pixel e coleta em 1ª parte) |
| `email_remetente`, `email_nome` | Remetente dos e-mails de login, convite e alertas |
| `suporte_url`, `termos_url`, `privacidade_url` | Rodapé e banner de consentimento |
| `esconder_marca_plataforma` | Remove "feito com Funnel Traffic" |

`app.config.ts` continua sendo o padrão da plataforma e o fallback quando a conta não tem marca.

## 4. Como cada peça vira white label

### 4.1 Painel (SPA)

1. O Worker recebe a requisição e lê o `Host`.
2. Ele consulta uma função pública `marca_por_dominio(host)`, que devolve só o tema (sem dado pessoal), com cache no KV do Worker por 5 min.
3. Ele injeta o tema no `index.html` (`<title>`, favicon e `<style>:root{…}</style>`), sem piscar a marca padrão.
4. Depois do login, o front confere se o usuário pertence à conta daquele domínio. Se não pertence, mostra "conta não encontrada".

### 4.2 Domínio próprio do cliente

- **Cloudflare for SaaS**, com o Worker como origem ([Worker as origin](https://developers.cloudflare.com/cloudflare-for-platforms/cloudflare-for-saas/start/advanced-settings/worker-as-origin/)). O cliente cria um CNAME `funil.cliente.com.br → clientes.<nosso-dominio>`, a Cloudflare emite o certificado e a rota `*/*` leva tudo ao mesmo Worker.
- Tela "Domínio" em Configurações da conta: mostra o CNAME a criar, verifica pela API de Custom Hostnames e mostra o status do certificado.
- Sem domínio próprio, a conta usa um subdomínio da plataforma: `<slug-da-conta>.<nosso-dominio>`.

### 4.3 Pixel em primeira parte

- `t.cliente.com.br` aponta para o mesmo Worker. O Worker serve `track.js` com nome neutro (por exemplo `/s.js`) e recebe a coleta em `/c`.
- O cookie da pessoa fica no domínio do cliente, então vale entre subdomínios e sobrevive melhor a bloqueadores e às restrições de cookie de terceiros.
- O script não leva o nome da plataforma no código servido.

### 4.4 E-mails (login, convite, alerta)

- **Supabase Auth com Send Email Hook** ([doc](https://supabase.com/docs/guides/auth/auth-hooks/send-email-hook)). Uma Edge Function `auth-email` recebe o pedido, descobre a conta pelo e-mail ou pelo `redirect_to` e envia pelo provedor com o remetente e o logo da conta.
- Provedor: SendPulse (já conectado à RC) ou Resend. Domínio do remetente com SPF e DKIM do cliente, ou um remetente da plataforma com o nome do cliente.
- O link do e-mail aponta para o domínio da conta (`redirect_to` permitido na lista de URLs do Auth; um curinga por domínio da plataforma e os domínios próprios cadastrados).

### 4.5 Link de leitura, exportações, API

- O link de leitura usa o domínio da conta.
- PNG e CSV levam o logo da conta.
- A API pública (Fase 3) aceita `https://api.<dominio_app>` ou o host da plataforma; a chave é por workspace.

## 5. Superadmin da plataforma

Papel fora dos workspaces, numa tabela `plataforma_admins (user_id)`, conferido por função `eh_superadmin()`.

| Tela | O que faz |
| --- | --- |
| Contas | Criar conta (nome, dono por convite), suspender, ver uso |
| Uso | Eventos/mês, pessoas, conectores ativos, erros de ingestão por conta |
| Templates de conector | Publicar e versionar `conector_templates`; analisar `conector_pedidos` |
| Auditoria | Tudo o que o superadmin faz vai para `auditoria`, com `conta_id` |

O superadmin **não** lê dado pessoal de cliente por padrão. O acesso de suporte é um papel temporário com prazo e registro (`acessos_suporte`).

## 6. Limites por conta (sem cobrança)

`conta_limites`: `eventos_mes`, `workspaces`, `membros`, `conectores`, `retencao_meses_max`. A ingestão continua gravando o bruto mesmo acima do limite (nunca descartar) e marca o excesso. O worker para de processar o excedente e avisa o dono da conta. A cobrança, quando vier, só lê esta tabela.

## 7. LGPD com vários clientes

- O cliente é o **controlador** dos dados dos visitantes dele; a plataforma é **operadora**. Precisa de termo de operador (DPA) aceito na criação da conta (`contas.dpa_aceito_em`).
- Consentimento no pixel com modo por workspace: `exigir` (nada é coletado antes do aceite), `basico` (só page view anônimo antes do aceite) ou `desligado`. O banner vem da plataforma, com a marca da conta, ou o cliente usa o próprio CMP e chama `ft.consent(true)`.
- Direitos do titular: buscar a pessoa por e-mail ou telefone, exportar a linha do tempo e **anonimizar**. "Nada é apagado" vale para o histórico de negócio; para dado pessoal pedido pelo titular, a regra é anonimizar (trocar identidades por hash irreversível e limpar atributos pessoais), com registro em `auditoria`.
- Retenção por workspace (`workspaces.retencao_meses`, já existe) e região (`workspaces.regiao`, já existe).

## 8. Migrations previstas

1. `conta_marcas`, `conta_dominios (dominio, tipo app|pixel, status, cloudflare_id)`, `conta_limites`, `plataforma_admins`, `acessos_suporte`, `contas.dpa_aceito_em`, `contas.suspensa_em`.
2. Funções `marca_por_dominio(host)` (pública, só tema), `eh_superadmin()`, `conta_criar(nome, email_dono)`.
3. Policies: `conta_marcas` e `conta_dominios` leitura por membro da conta, escrita pelo dono da conta ou superadmin.

## 9. Checklist para ligar um cliente novo

1. Superadmin cria a conta e convida o dono.
2. Dono aceita o DPA, envia logo e cores e cadastra o domínio (ou usa o subdomínio).
3. Cria os workspaces (um por projeto).
4. Em Integrações: instala o pixel (domínio de coleta próprio) e liga os conectores em modo sombra, depois ativa.
5. Monta o canvas, metas e links de leitura.
