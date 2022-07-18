const appVersion = 'v0.0.1';
const cachedFiles = [
    'index.html',
    'main.js',
];


self.addEventListener('install', (event) => {
    console.log('[SW] Install');
    event.waitUntil((async () => {
        const cache = await caches.open(appVersion);
        console.log('[SW] Caching all files:');
        for (const file of cachedFiles) {
            console.log(`[SW]   "${file}"`);
        }
        await cache.addAll(cachedFiles);
    })());
});


self.addEventListener('fetch', (event) => {
    event.respondWith((async () => {
        const cacheResponse = await caches.match(event.request);
        console.log(`[SW] Fetching resource: ${event.request.url}`);
        if (cacheResponse) {
            return cacheResponse;
        }

        const response = await fetch(event.request);
        //TODO: We probably don't want to cache anything not in `cachedFiles`
        // const cache = await caches.open(cacheName);
        // console.log(`[SW] Caching new resource: ${event.request.url}`);
        // cache.put(event.request, response.clone());
        return response;
    })());
});


self.addEventListener('activate', (event) => {
    event.waitUntil((async () => {
        const cacheNames = await caches.keys();
        await cacheNames
            .filter(n => n != appVersion)
            .map(async n => { await caches.delete(n) });
    })());
});