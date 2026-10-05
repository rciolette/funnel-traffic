import { createContext, useContext, useMemo, useState, type ReactNode } from "react";
import { useWorkspaces, type Workspace } from "@/hooks/use-workspaces";

type Ctx = { workspaces: Workspace[]; atual: Workspace | null; trocar: (id: string) => void; carregando: boolean };
const WorkspaceCtx = createContext<Ctx | null>(null);
const CHAVE = "workspace-atual";

/** Workspace selecionado vale para todo o app; a escolha fica no localStorage só por conveniência. */
export function WorkspaceProvider({ children }: { children: ReactNode }) {
  const { data = [], isLoading } = useWorkspaces();
  const [id, setId] = useState<string | null>(() => {
    try { return localStorage.getItem(CHAVE); } catch { return null; }
  });
  const atual = useMemo(() => data.find((w) => w.id === id) ?? data[0] ?? null, [data, id]);
  const trocar = (novo: string) => {
    setId(novo);
    try { localStorage.setItem(CHAVE, novo); } catch { /* sem storage, segue em memória */ }
  };
  return <WorkspaceCtx.Provider value={{ workspaces: data, atual, trocar, carregando: isLoading }}>{children}</WorkspaceCtx.Provider>;
}

export function useWorkspace() {
  const v = useContext(WorkspaceCtx);
  if (!v) throw new Error("useWorkspace precisa estar dentro de WorkspaceProvider");
  return v;
}
