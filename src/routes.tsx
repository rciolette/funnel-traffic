import { Navigate, Outlet, createBrowserRouter } from "react-router-dom";
import { AppShell } from "@/components/layout/AppShell";
import { useAuth } from "@/contexts/AuthContext";
import Login from "@/pages/Login";
import VisaoGeral from "@/pages/VisaoGeral";
import Canvas from "@/pages/Canvas";
import Integracoes from "@/pages/Integracoes";
import Pessoas from "@/pages/Pessoas";
import Configuracoes from "@/pages/Configuracoes";
import NaoEncontrado from "@/pages/NaoEncontrado";

function Protegida() {
  const { usuario, carregando } = useAuth();
  if (carregando) return <div className="grid min-h-screen place-items-center text-sm text-muted-foreground">Carregando…</div>;
  return usuario ? <Outlet /> : <Navigate to="/login" replace />;
}

/** Para adicionar página: criar em src/pages, registrar aqui e no menu em app.config.ts. */
export const router = createBrowserRouter([
  { path: "/login", element: <Login /> },
  {
    element: <Protegida />,
    children: [
      {
        element: <AppShell />,
        children: [
          { path: "/", element: <VisaoGeral /> },
          { path: "/canvas", element: <Canvas /> },
          { path: "/integracoes", element: <Integracoes /> },
          { path: "/pessoas", element: <Pessoas /> },
          { path: "/configuracoes", element: <Configuracoes /> },
        ],
      },
    ],
  },
  { path: "*", element: <NaoEncontrado /> },
]);
