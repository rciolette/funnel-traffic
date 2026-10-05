/**
 * Regras puras de número. Nenhum componente calcula; só chama.
 * Toda função aqui tem teste em conversao.test.ts.
 */

/** Taxa de conversão entre duas etapas, em fração (0–1). Base zero devolve 0, nunca NaN. */
export function taxaConversao(pessoasDestino: number, pessoasOrigem: number): number {
  if (pessoasOrigem <= 0) return 0;
  return Math.min(1, Math.max(0, pessoasDestino / pessoasOrigem));
}

/** Formata fração como percentual pt-BR com 1 casa: 0.4312 → "43,1%". */
export function formatarPercentual(fracao: number): string {
  return (fracao * 100).toLocaleString("pt-BR", { maximumFractionDigits: 1 }) + "%";
}

/** Centavos inteiros → "R$ 1.234,56". Dinheiro sempre chega em centavos. */
export function formatarCentavos(centavos: number, moeda = "BRL"): string {
  return (centavos / 100).toLocaleString("pt-BR", { style: "currency", currency: moeda });
}

export type StatusMeta = "no_ritmo" | "fora_do_ritmo" | "critico";

/**
 * Status de uma meta pelo ritmo: projeta o valor final pelo que já passou do período.
 * - no_ritmo: projeção ≥ alvo
 * - fora_do_ritmo: projeção ≥ limite de alerta (fração do alvo), mas < alvo
 * - critico: projeção < limite de alerta
 */
export function statusMeta(opts: {
  realizado: number;
  alvo: number;
  diasPassados: number;
  diasTotais: number;
  limiteAlerta?: number; // fração do alvo, padrão 0,8
}): { status: StatusMeta; projecao: number } {
  const { realizado, alvo, diasPassados, diasTotais, limiteAlerta = 0.8 } = opts;
  if (alvo <= 0 || diasTotais <= 0) return { status: "critico", projecao: 0 };
  const fracaoPeriodo = Math.min(1, Math.max(1 / diasTotais, diasPassados / diasTotais));
  const projecao = Math.round(realizado / fracaoPeriodo);
  if (projecao >= alvo) return { status: "no_ritmo", projecao };
  if (projecao >= alvo * limiteAlerta) return { status: "fora_do_ritmo", projecao };
  return { status: "critico", projecao };
}
