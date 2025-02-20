// Service worker for sqflite web
self.addEventListener('install', (event) => {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('message', (event) => {
  // Handle database operations
  event.source.postMessage({
    type: 'response',
    data: 'Database operation completed'
  });
});
