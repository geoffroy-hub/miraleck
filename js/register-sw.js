// Enregistrement Service Worker MiraLocks
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js')
      .then(r => console.log('[SW] Enregistré:', r.scope))
      .catch(e => console.warn('[SW] Erreur:', e));
  });
}
