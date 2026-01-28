# PWA Skill

Progressive Web App 구현 가이드를 실행합니다.

## PWA 핵심 요소

```
1. Web App Manifest - 앱 정보
2. Service Worker - 오프라인, 캐싱
3. HTTPS - 보안
4. Responsive - 반응형 디자인
```

## Web App Manifest

### manifest.json
```json
{
  "name": "My PWA App",
  "short_name": "MyApp",
  "description": "앱 설명",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/desktop.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide"
    },
    {
      "src": "/screenshots/mobile.png",
      "sizes": "640x1136",
      "type": "image/png",
      "form_factor": "narrow"
    }
  ],
  "shortcuts": [
    {
      "name": "새 항목",
      "url": "/new",
      "icons": [{ "src": "/icons/new.png", "sizes": "192x192" }]
    }
  ]
}
```

### HTML 연결
```html
<head>
  <link rel="manifest" href="/manifest.json">
  <meta name="theme-color" content="#000000">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <link rel="apple-touch-icon" href="/icons/icon-192x192.png">
</head>
```

## Service Worker

### 등록
```javascript
// app.js
if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    try {
      const registration = await navigator.serviceWorker.register('/sw.js');
      console.log('SW registered:', registration.scope);
    } catch (error) {
      console.error('SW registration failed:', error);
    }
  });
}
```

### Service Worker 구현
```javascript
// sw.js
const CACHE_NAME = 'my-app-v1';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/styles.css',
  '/app.js',
  '/icons/icon-192x192.png',
];

// 설치 - 정적 자원 캐시
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS);
    })
  );
  self.skipWaiting();
});

// 활성화 - 이전 캐시 삭제
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      );
    })
  );
  self.clients.claim();
});

// Fetch - 캐시 전략
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      // Cache First
      if (cached) return cached;

      return fetch(event.request).then((response) => {
        // 성공적인 응답만 캐시
        if (!response || response.status !== 200) {
          return response;
        }

        const responseClone = response.clone();
        caches.open(CACHE_NAME).then((cache) => {
          cache.put(event.request, responseClone);
        });

        return response;
      });
    })
  );
});
```

## 캐싱 전략

### Cache First (오프라인 우선)
```javascript
// 정적 자원에 적합
event.respondWith(
  caches.match(event.request).then((cached) => {
    return cached || fetch(event.request);
  })
);
```

### Network First (최신 데이터 우선)
```javascript
// API 응답에 적합
event.respondWith(
  fetch(event.request)
    .then((response) => {
      const clone = response.clone();
      caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, clone);
      });
      return response;
    })
    .catch(() => caches.match(event.request))
);
```

### Stale While Revalidate
```javascript
// 빠른 응답 + 백그라운드 업데이트
event.respondWith(
  caches.open(CACHE_NAME).then((cache) => {
    return cache.match(event.request).then((cached) => {
      const fetchPromise = fetch(event.request).then((response) => {
        cache.put(event.request, response.clone());
        return response;
      });
      return cached || fetchPromise;
    });
  })
);
```

## Workbox (권장)

### 설정
```javascript
// sw.js with Workbox
importScripts('https://storage.googleapis.com/workbox-cdn/releases/6.5.4/workbox-sw.js');

const { precacheAndRoute } = workbox.precaching;
const { registerRoute } = workbox.routing;
const { CacheFirst, NetworkFirst, StaleWhileRevalidate } = workbox.strategies;
const { ExpirationPlugin } = workbox.expiration;

// Precache
precacheAndRoute(self.__WB_MANIFEST);

// 이미지 - Cache First
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [
      new ExpirationPlugin({ maxEntries: 50, maxAgeSeconds: 30 * 24 * 60 * 60 }),
    ],
  })
);

// API - Network First
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api',
    plugins: [
      new ExpirationPlugin({ maxEntries: 100, maxAgeSeconds: 24 * 60 * 60 }),
    ],
  })
);
```

## Push Notifications

### 구독
```javascript
async function subscribePush() {
  const registration = await navigator.serviceWorker.ready;

  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY),
  });

  // 서버에 구독 정보 전송
  await fetch('/api/push/subscribe', {
    method: 'POST',
    body: JSON.stringify(subscription),
    headers: { 'Content-Type': 'application/json' },
  });
}
```

### 수신 (Service Worker)
```javascript
self.addEventListener('push', (event) => {
  const data = event.data.json();

  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icons/icon-192x192.png',
      badge: '/icons/badge.png',
      data: { url: data.url },
    })
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(clients.openWindow(event.notification.data.url));
});
```

## Next.js PWA

### next-pwa
```javascript
// next.config.js
const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  register: true,
  skipWaiting: true,
});

module.exports = withPWA({
  // Next.js config
});
```

## 체크리스트

### 필수
- [ ] HTTPS
- [ ] Web App Manifest
- [ ] Service Worker
- [ ] 아이콘 (192x192, 512x512)

### 권장
- [ ] 오프라인 페이지
- [ ] 설치 프롬프트
- [ ] Push Notifications
- [ ] 백그라운드 동기화

### 테스트
- [ ] Lighthouse PWA 감사
- [ ] 오프라인 테스트
- [ ] 설치 테스트

## 출력 형식

```
## PWA Implementation

### Manifest
```json
{ "name": "...", ... }
```

### Service Worker
- 캐싱 전략: [Cache First/Network First/etc]
- Workbox 사용: [Yes/No]

### Features
- [x] 오프라인 지원
- [x] 설치 가능
- [ ] Push Notifications

### Lighthouse Score
- PWA: 100
- Performance: 90+
```

---

요청에 맞는 PWA를 구현하세요.
