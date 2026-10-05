import { NavLink, Outlet } from "react-router-dom";
import { LayoutDashboard, LogOut, Plug, Settings, Users, Workflow, type LucideIcon } from "lucide-react";
import { appConfig } from "../../../app.config";
import { useAuth } from "@/contexts/AuthContext";
import { useWorkspace } from "@/contexts/WorkspaceContext";
import { ErrorBoundary } from "@/components/erros/ErrorBoundary";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { modoDemo } from "@/lib/env";
import { cn } from "@/lib/utils";

const icones: Record<string, LucideIcon> = { LayoutDashboard, Workflow, Plug, Users, Settings };

/** Casca do app: menu lateral fixo + cabeçalho + conteúdo. O ErrorBoundary de conteúdo mantém o menu vivo. */
export function AppShell() {
  const { usuario, sair } = useAuth();
  const { workspaces, atual, trocar } = useWorkspace();
  return (
    <div className="grid min-h-screen grid-cols-[232px_1fr] max-md:grid-cols-1">
      <aside className="flex flex-col gap-4 bg-sidebar p-4 text-sidebar-foreground max-md:hidden">
        <div className="flex items-center gap-2 px-2 font-bold">
          <span className="inline-block size-6 rounded-md bg-primary" />
          {appConfig.nome}
        </div>
        <label className="px-2 text-xs uppercase tracking-wide opacity-70">Workspace</label>
        <select
          id="seletor-workspace"
          className="rounded-md bg-white/10 px-2 py-1.5 text-sm outline-none"
          value={atual?.id ?? ""}
          onChange={(e) => trocar(e.target.value)}
        >
          {workspaces.map((w) => (
            <option key={w.id} value={w.id} className="text-black">{w.nome}</option>
          ))}
        </select>
        <nav className="flex flex-col gap-1">
          {appConfig.menu.map((item) => {
            const Icone = icones[item.icone] ?? LayoutDashboard;
            return (
              <NavLink
                key={item.caminho}
                to={item.caminho}
                end={item.caminho === "/"}
                className={({ isActive }) =>
                  cn("flex items-center gap-2 rounded-md px-2 py-1.5 text-sm hover:bg-white/10", isActive && "bg-white/15 font-semibold")
                }
              >
                <Icone className="size-4" /> {item.rotulo}
              </NavLink>
            );
          })}
        </nav>
        <div className="mt-auto space-y-2 px-2 text-xs opacity-80">
          <div className="truncate">{usuario?.email}</div>
          {modoDemo && <Badge variant="alerta">modo demo</Badge>}
          <Button variant="ghost" size="sm" className="w-full justify-start text-sidebar-foreground" onClick={sair}>
            <LogOut /> Sair
          </Button>
        </div>
      </aside>
      <main className="flex min-w-0 flex-col">
        <header className="flex h-14 items-center justify-between border-b px-6">
          <span className="text-sm text-muted-foreground">{atual?.nome ?? "Sem workspace"}</span>
          <span className="text-xs text-muted-foreground">{appConfig.empresa}</span>
        </header>
        <div className="min-w-0 flex-1 p-6">
          <ErrorBoundary nivel="conteudo" nome="conteudo">
            <Outlet />
          </ErrorBoundary>
        </div>
      </main>
    </div>
  );
}
