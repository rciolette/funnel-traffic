import { createClient } from "@supabase/supabase-js";
import { env, modoDemo } from "./env";

const criarCliente = () =>
  createClient(env.VITE_SUPABASE_URL!, env.VITE_SUPABASE_ANON_KEY!, {
    auth: { persistSession: true, autoRefreshToken: true },
    // Tabelas e funções do produto ficam no schema funnel_traffic (migration de fundação).
    db: { schema: "funnel_traffic" },
  });

/** Cliente único. Em modo demo é null e os hooks devolvem dados de exemplo. */
export const supabase: ReturnType<typeof criarCliente> | null = modoDemo ? null : criarCliente();
