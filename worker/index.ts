/**
 * Cloudflare Worker: serve o SPA (assets) e rotas próprias.
 * MANTER SINCRONIZADO com wrangler.jsonc (binding ASSETS) e, quando existir, com public/track.js.
 */
export interface Env {
  ASSETS: { fetch(request: Request): Promise<Response> };
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    if (url.pathname === "/saude") {
      return Response.json({ ok: true, em: new Date().toISOString() });
    }
    // Pixel: no Funnel Traffic, /track.js é servido daqui com cache longo (Fase 1).
    return env.ASSETS.fetch(request);
  },
};
