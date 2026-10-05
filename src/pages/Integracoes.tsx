import { Pagina } from "@/components/layout/Pagina";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

/** Estado vazio obrigatório: os três caminhos de entrada. A tela self-service de 5 passos entra na Fase 1. */
const caminhos = [
  ["Pixel", "Um script no site cria a pessoa e envia page view, clique, scroll, formulário e vídeo."],
  ["Webhook + mapper", "A plataforma (Hotmart, HighLevel, Typeform…) chama a URL do conector; um mapper traduz o payload."],
  ["n8n", "Qualquer coisa fora do catálogo: um workflow envia o evento canônico pronto."],
];

export default function Integracoes() {
  return (
    <Pagina titulo="Integrações" descricao="Conecte as fontes de eventos deste workspace." acoes={<Button>Novo conector</Button>}>
      <div className="grid gap-4 md:grid-cols-3">
        {caminhos.map(([t, d]) => (
          <Card key={t}>
            <CardHeader><CardTitle>{t}</CardTitle><CardDescription>{d}</CardDescription></CardHeader>
            <CardContent><Button variant="outline" size="sm">Começar</Button></CardContent>
          </Card>
        ))}
      </div>
    </Pagina>
  );
}
