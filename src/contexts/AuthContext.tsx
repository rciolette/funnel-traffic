import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import type { Session, User } from "@supabase/supabase-js";
import { supabase } from "@/lib/supabase";
import { modoDemo } from "@/lib/env";

type Auth = {
  usuario: User | null;
  carregando: boolean;
  entrarComEmail: (email: string, senha: string) => Promise<string | null>;
  sair: () => Promise<void>;
};

const Ctx = createContext<Auth | null>(null);

const usuarioDemo = { id: "demo", email: "demo@exemplo.com" } as unknown as User;

export function AuthProvider({ children }: { children: ReactNode }) {
  const [sessao, setSessao] = useState<Session | null>(null);
  const [carregando, setCarregando] = useState(!modoDemo);

  useEffect(() => {
    if (!supabase) return;
    supabase.auth.getSession().then(({ data }) => {
      setSessao(data.session);
      setCarregando(false);
    });
    const { data: sub } = supabase.auth.onAuthStateChange((_e, s) => setSessao(s));
    return () => sub.subscription.unsubscribe();
  }, []);

  const valor: Auth = {
    usuario: modoDemo ? usuarioDemo : sessao?.user ?? null,
    carregando,
    async entrarComEmail(email, senha) {
      if (!supabase) return null;
      const { error } = await supabase.auth.signInWithPassword({ email, password: senha });
      return error ? error.message : null;
    },
    async sair() {
      await supabase?.auth.signOut();
    },
  };
  return <Ctx.Provider value={valor}>{children}</Ctx.Provider>;
}

export function useAuth() {
  const v = useContext(Ctx);
  if (!v) throw new Error("useAuth precisa estar dentro de AuthProvider");
  return v;
}
