import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";

export type Workspace = { id: string; nome: string; slug: string; papel: "dono" | "admin" | "editor" | "visualizador" };

const demo: Workspace[] = [{ id: "ws-demo", nome: "My Workspace", slug: "my-workspace", papel: "dono" }];

/** Workspaces do usuário logado. RLS já filtra pelo papel; o front não decide permissão. */
export function useWorkspaces() {
  return useQuery({
    queryKey: ["workspaces"],
    queryFn: async (): Promise<Workspace[]> => {
      if (!supabase) return demo;
      const { data, error } = await supabase
        .from("workspace_membros")
        .select("papel, workspaces(id, nome, slug)")
        .order("criado_em", { ascending: true });
      if (error) throw error;
      type Linha = { papel: Workspace["papel"]; workspaces: { id: string; nome: string; slug: string } | null };
      return ((data ?? []) as unknown as Linha[])
        .filter((l) => l.workspaces)
        .map((l) => ({ ...l.workspaces!, papel: l.papel }));
    },
    staleTime: 5 * 60_000,
  });
}
