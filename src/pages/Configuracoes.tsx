import { Pagina } from "@/components/layout/Pagina";
import { useWorkspace } from "@/contexts/WorkspaceContext";
export default function Configuracoes() {
  const { atual } = useWorkspace();
  return (
    <Pagina titulo="Configurações" descricao="Workspace, membros, chaves e retenção.">
      <p className="text-sm text-muted-foreground">Workspace atual: <b>{atual?.nome}</b> · papel: {atual?.papel}</p>
    </Pagina>
  );
}
