import { ReactFlow, Background, Controls, MiniMap, type Edge, type Node } from "@xyflow/react";
import "@xyflow/react/dist/style.css";
import { Pagina } from "@/components/layout/Pagina";
import { Badge } from "@/components/ui/badge";

/** Esqueleto do canvas com React Flow. Os nós de etapa (Fonte, Página, Ação, Offline) e as pílulas de conversão
 *  entram na Fase 1; aqui só o palco, para o modelo já abrir com o paradigma certo. */
const nos: Node[] = [
  { id: "a", position: { x: 40, y: 120 }, data: { label: "Anúncio Meta · 12.400 pessoas" } },
  { id: "b", position: { x: 340, y: 120 }, data: { label: "Página de inscrição · 9.820" } },
  { id: "c", position: { x: 640, y: 120 }, data: { label: "Inscrição confirmada · 4.310" } },
];
const arestas: Edge[] = [
  { id: "a-b", source: "a", target: "b", label: "68,1%" },
  { id: "b-c", source: "b", target: "c", label: "43,9%" },
];

export default function Canvas() {
  return (
    <Pagina titulo="Canvas" descricao="Mapa da jornada ligado aos eventos." acoes={<Badge variant="secondary">dados de exemplo</Badge>}>
      <div className="h-[560px] rounded-xl border bg-card">
        <ReactFlow nodes={nos} edges={arestas} fitView proOptions={{ hideAttribution: true }}>
          <Background gap={22} />
          <Controls />
          <MiniMap />
        </ReactFlow>
      </div>
    </Pagina>
  );
}
