export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    
    // Serve all static assets via ASSETS binding
    return env.ASSETS.fetch(request);
  }
}
