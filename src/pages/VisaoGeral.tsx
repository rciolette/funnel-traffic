import { Pagina } from "@/components/layout/Pagina";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { formatarCentavos, formatarPercentual, statusMeta, taxaConversao } from "@/lib/regras/conversao";

/** Dados de exemplo marcados como tal. No app real, vêm de monitor_kpis(workspace_id, de, ate). */
const exemplo = { pessoas: 15500, inscricoes: 4310, compras: 212, receitaCentavos: 6296400 };

export default function VisaoGeral() {
  const meta = statusMeta({ realizado: exemplo.compras, alvo: 300, diasPassados: 24, diasTotais: 30 });
  const rotulo = { no_ritmo: "no ritmo", fora_do_ritmo: "fora do ritmo", critico: "crítico" }[meta.status];
  const variante = { no_ritmo: "ok", fora_do_ritmo: "alerta", critico: "critico" }[meta.status] as "ok" | "alerta" | "critico";
  const kpis = [
    ["Pessoas rastreadas", exemplo.pessoas.toLocaleString("pt-BR")],
    ["Inscrições", exemplo.inscricoes.toLocaleString("pt-BR")],
    ["Compras", exemplo.compras.toLocaleString("pt-BR")],
    ["Receita", formatarCentavos(exemplo.receitaCentavos)],
    ["Inscrição → compra", formatarPercentual(taxaConversao(exemplo.compras, exemplo.inscricoes))],
  ];
  return (
    <Pagina titulo="Visão geral" descricao="KPIs do período. Dados de exemplo até o primeiro conector ser ativado.">
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
        {kpis.map(([k, v]) => (
          <Card key={k}>
            <CardHeader className="pb-2"><CardTitle className="text-xs uppercase tracking-wide text-muted-foreground">{k}</CardTitle></CardHeader>
            <CardContent className="text-2xl font-bold tabular-nums">{v}</CardContent>
          </Card>
        ))}
      </div>
      <Card>
        <CardHeader className="flex-row items-center justify-between">
          <CardTitle>Meta: 300 compras no mês</CardTitle>
          <Badge variant={variante}>{rotulo}</Badge>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          {exemplo.compras} de 300 · ritmo projeta {meta.projecao}. Cálculo em <code>src/lib/regras/conversao.ts</code>, com teste.
        </CardContent>
      </Card>
    </Pagina>
  );
}
