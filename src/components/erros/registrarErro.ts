import { supabase } from "@/lib/supabase";
import { appConfig } from "../../../app.config";

/**
 * Todo erro de front vai para a tabela `<app>_erros_front` (criar na migration 0001).
 * Em modo demo só loga no console. Nunca lança: registrar erro não pode gerar erro.
 */
export async function registrarErroFront(d: { erro: Error; componente: string; stack: string }) {
  const linha = {
    app: appConfig.slug,
    componente: d.componente,
    mensagem: d.erro.message,
    stack: d.stack.slice(0, 4000),
    url: window.location.href,
    user_agent: navigator.userAgent,
  };
  if (!supabase) {
    console.error("[erro front]", linha);
    return;
  }
  try {
    await supabase.from(`${appConfig.slug.replace(/-/g, "_")}_erros_front`).insert(linha);
  } catch (e) {
    console.error("[erro front] falha ao registrar", e, linha);
  }
}
