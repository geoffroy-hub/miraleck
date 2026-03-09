/* ============================================================
   Institut MiraLocks — Service Worker v3
   Stratégie : Cache-first images/css/js, Network-first HTML
   Offline : redirection automatique vers offline.html
   ============================================================ */

const CACHE_V = 'miralocks-v3';
const STATIC  = [
  '/',
  '/index.html',
  '/gallery.html',
  '/services.html',
  '/rendezvous.html',
  '/contact.html',
  '/about.html',
  '/avis.html',
  '/blog.html',
  '/faq.html',
  '/mentions-legales.html',
  '/confidentialite.html',
  '/offline.html',
  '/css/styles.css',
  '/js/main.js',
  '/js/supabase.js',
  '/assets/logo-transparent.avif',
  '/assets/logo-transparent.webp',
  '/assets/logo-transparent.png',
  '/assets/favicon.ico',
  '/assets/favicon-32.png',
  '/assets/apple-touch-icon.png',
  '/images/locks1.avif',
  '/images/locks2.avif',
  '/images/locks3.avif',
  '/images/locks4.avif',
  '/images/locks5.avif',
  '/images/locks6.avif',
];

// Install : précache assets critiques
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_V)
      .then(c => c.addAll(STATIC))
      .then(() => self.skipWaiting())
  );
});

// Activate : nettoyer anciens caches
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE_V).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Fetch : stratégie adaptée
self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // Ignorer non-GET et requêtes externes (Supabase, fonts…)
  if (e.request.method !== 'GET') return;
  if (url.origin !== self.location.origin) return;

  const ext = url.pathname.split('.').pop().toLowerCase();
  const isStaticAsset = ['avif','webp','jpg','jpeg','png','gif','svg',
                         'css','js','woff','woff2','ico'].includes(ext);
  const isHTML = ext === 'html' || ext === '' || !url.pathname.includes('.');

  if (isStaticAsset) {
    // Cache-first
    e.respondWith(
      caches.match(e.request).then(cached => {
        if (cached) return cached;
        return fetch(e.request).then(res => {
          const clone = res.clone();
          caches.open(CACHE_V).then(c => c.put(e.request, clone));
          return res;
        }).catch(() => new Response('', { status: 503 }));
      })
    );
  } else if (isHTML) {
    // Network-first → cache → offline.html
    e.respondWith(
      fetch(e.request)
        .then(res => {
          const clone = res.clone();
          caches.open(CACHE_V).then(c => c.put(e.request, clone));
          return res;
        })
        .catch(() =>
          caches.match(e.request)
            .then(cached => cached || caches.match('/offline.html'))
        )
    );
  }
});
