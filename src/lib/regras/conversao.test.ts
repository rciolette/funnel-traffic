import { describe, expect, it } from "vitest";
import { formatarCentavos, formatarPercentual, statusMeta, taxaConversao } from "./conversao";

describe("taxaConversao", () => {
  it("divide destino por origem", () => expect(taxaConversao(4310, 9820)).toBeCloseTo(0.4389, 3));
  it("base zero devolve 0, nunca NaN", () => expect(taxaConversao(10, 0)).toBe(0));
  it("nunca passa de 1", () => expect(taxaConversao(12, 10)).toBe(1));
});

describe("formatação", () => {
  it("percentual pt-BR com 1 casa", () => expect(formatarPercentual(0.4312)).toBe("43,1%"));
  it("centavos em reais", () => expect(formatarCentavos(29700).replace(/ /g, " ")).toBe("R$ 297,00"));
});

describe("statusMeta", () => {
  const base = { alvo: 300, diasTotais: 30 };
  it("no ritmo quando a projeção bate o alvo", () =>
    expect(statusMeta({ ...base, realizado: 150, diasPassados: 15 })).toEqual({ status: "no_ritmo", projecao: 300 }));
  it("fora do ritmo entre o limite de alerta e o alvo", () =>
    expect(statusMeta({ ...base, realizado: 212, diasPassados: 24 }).status).toBe("fora_do_ritmo"));
  it("crítico abaixo do limite de alerta", () =>
    expect(statusMeta({ ...base, realizado: 50, diasPassados: 20 }).status).toBe("critico"));
  it("alvo zero é crítico", () => expect(statusMeta({ ...base, alvo: 0, realizado: 1, diasPassados: 1 }).status).toBe("critico"));
});
