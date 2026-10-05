import { Component, type ErrorInfo, type ReactNode } from "react";
import { registrarErroFront } from "./registrarErro";

type Nivel = "tela" | "conteudo" | "silencioso";

type Props = { nivel: Nivel; children: ReactNode; nome?: string };
type State = { erro: Error | null };

/**
 * Três níveis, por regra da Fábrica de Apps:
 * - tela: só em main.tsx; último recurso, mostra página de erro inteira.
 * - conteudo: envolve a área de conteúdo; o menu continua vivo.
 * - silencioso: enfeites (gráficos, badges) somem sem derrubar nada.
 * Nenhum componente novo pode derrubar o app.
 */
export class ErrorBoundary extends Component<Props, State> {
  state: State = { erro: null };

  static getDerivedStateFromError(erro: Error): State {
    return { erro };
  }

  componentDidCatch(erro: Error, info: ErrorInfo) {
    void registrarErroFront({ erro, componente: this.props.nome ?? this.props.nivel, stack: info.componentStack ?? "" });
  }

  render() {
    const { erro } = this.state;
    if (!erro) return this.props.children;
    if (this.props.nivel === "silencioso") return null;
    const recarregar = () => window.location.reload();
    return (
      <div className={this.props.nivel === "tela" ? "grid min-h-screen place-items-center p-6" : "p-6"} role="alert">
        <div className="max-w-md space-y-3 rounded-xl border bg-card p-6">
          <h2 className="text-base font-semibold">Algo deu errado nesta área</h2>
          <p className="text-sm text-muted-foreground">
            O erro foi registrado. Você pode recarregar a página; se continuar, avise o responsável.
          </p>
          <button className="rounded-md bg-primary px-3 py-1.5 text-sm text-primary-foreground" onClick={recarregar}>
            Recarregar
          </button>
        </div>
      </div>
    );
  }
}
