import { z } from "zod";

/**
 * Variáveis públicas do front (prefixo VITE_). Sem Supabase configurado o app roda em modo demo,
 * com dados de exemplo e sem login — útil para o modelo e para preview sem banco.
 */
const schema = z.object({
  VITE_SUPABASE_URL: z.string().url().optional(),
  VITE_SUPABASE_ANON_KEY: z.string().min(10).optional(),
});

const parsed = schema.safeParse(import.meta.env);
if (!parsed.success) {
  // Variável inválida é erro de configuração; não escondemos.
  throw new Error("Variáveis de ambiente inválidas: " + JSON.stringify(parsed.error.flatten().fieldErrors));
}

export const env = parsed.data;
export const modoDemo = !env.VITE_SUPABASE_URL || !env.VITE_SUPABASE_ANON_KEY;
