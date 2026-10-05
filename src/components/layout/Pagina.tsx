import type { ReactNode } from "react";

/** Cabeçalho padrão de página: título, descrição e ações à direita. */
export function Pagina({ titulo, descricao, acoes, children }: { titulo: string; descricao?: string; acoes?: ReactNode; children: ReactNode }) {
  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold">{titulo}</h1>
          {descricao && <p className="text-sm text-muted-foreground">{descricao}</p>}
        </div>
        {acoes && <div className="flex gap-2">{acoes}</div>}
      </div>
      {children}
    </div>
  );
}
