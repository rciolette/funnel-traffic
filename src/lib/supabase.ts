import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import { env, modoDemo } from "./env";

/** Cliente único. Em modo demo é null e os hooks devolvem dados de exemplo. */
export const supabase: SupabaseClient | null = modoDemo
  ? null
  : createClient(env.VITE_SUPABASE_URL!, env.VITE_SUPABASE_ANON_KEY!, {
      auth: { persistSession: true, autoRefreshToken: true },
    });
