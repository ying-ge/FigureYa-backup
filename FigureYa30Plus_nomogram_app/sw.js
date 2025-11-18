/**
 * Service Worker for Nomogram App
 * 提供离线功能和缓存管理
 */

const CACHE_NAME = 'nomogram-app-v2.1.0';
const STATIC_CACHE = 'static-cache-v2.1';
const RUNTIME_CACHE = 'runtime-cache-v2.1';

// 需要缓存的静态资源
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/css/style.css',
  '/css/ios-enhancements.css',
  '/js/nomogram.js',
  '/js/app.js',
  '/js/nomogram-viz.js',
  '/js/csv-export.js',
  '/js/ios-enhancements.js',
  '/manifest.json',
  '/images/icon.svg',
  '/images/icon-192.png',
  '/images/icon-512.png',
  'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap'
];

// 安装事件
self.addEventListener('install', (event) => {
  console.log('Service Worker installing...');

  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then((cache) => {
        console.log('Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
      .then(() => {
        console.log('Service Worker installed');
        return self.skipWaiting();
      })
  );
});

// 激活事件
self.addEventListener('activate', (event) => {
  console.log('Service Worker activating...');

  event.waitUntil(
    Promise.all([
      // 清理旧缓存
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== STATIC_CACHE && cacheName !== RUNTIME_CACHE) {
              console.log('Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      }),
      // 立即控制所有页面
      self.clients.claim()
    ])
  );
});

// 网络请求拦截
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // 只处理同源请求
  if (url.origin !== self.location.origin) {
    return;
  }

  event.respondWith(handleRequest(request));
});

/**
 * 处理请求
 */
async function handleRequest(request) {
  const url = new URL(request.url);

  // 静态资源：使用缓存优先策略
  if (isStaticAsset(url.pathname)) {
    return handleStaticAsset(request);
  }

  // 导航请求：使用网络优先策略
  if (request.mode === 'navigate') {
    return handleNavigation(request);
  }

  // 其他请求：直接网络请求
  return fetch(request);
}

/**
 * 处理静态资源
 */
function handleStaticAsset(request) {
  return caches.match(request)
    .then((cachedResponse) => {
      if (cachedResponse) {
        // 更新缓存（后台更新）
        updateCache(request);
        return cachedResponse;
      }

      // 没有缓存，从网络获取
      return fetch(request)
        .then((response) => {
          // 检查响应是否有效
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }

          // 缓存响应
          const responseToCache = response.clone();
          caches.open(STATIC_CACHE)
            .then((cache) => {
              cache.put(request, responseToCache);
            });

          return response;
        });
    });
}

/**
 * 处理导航请求
 */
function handleNavigation(request) {
  return fetch(request)
    .then((response) => {
      // 缓存导航响应
      const responseToCache = response.clone();
      caches.open(RUNTIME_CACHE)
        .then((cache) => {
          cache.put(request, responseToCache);
        });

      return response;
    })
    .catch(() => {
      // 网络失败，尝试从缓存获取
      return caches.match(request)
        .then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }

          // 最后的fallback：返回离线页面
          return caches.match('/index.html');
        });
    });
}

/**
 * 后台更新缓存
 */
function updateCache(request) {
  return fetch(request)
    .then((response) => {
      if (response && response.status === 200) {
        const responseToCache = response.clone();
        caches.open(STATIC_CACHE)
          .then((cache) => {
            cache.put(request, responseToCache);
          });
      }
    })
    .catch((error) => {
      console.log('Background update failed:', error);
    });
}

/**
 * 判断是否为静态资源
 */
function isStaticAsset(pathname) {
  const staticExtensions = ['.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.woff', '.woff2'];
  const isStaticFile = staticExtensions.some(ext => pathname.endsWith(ext));
  const isManifestFile = pathname.endsWith('manifest.json');

  return isStaticFile || isManifestFile;
}

// 消息处理（用于缓存控制）
self.addEventListener('message', (event) => {
  const { type, payload } = event.data;

  switch (type) {
    case 'SKIP_WAITING':
      self.skipWaiting();
      break;

    case 'UPDATE_CACHE':
      updateCache(new Request(payload.url));
      break;

    case 'CLEAR_CACHE':
      clearCache(payload.cacheName);
      break;
  }
});

/**
 * 清理指定缓存
 */
function clearCache(cacheName) {
  if (cacheName) {
    caches.delete(cacheName);
  } else {
    // 清理所有缓存
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map(cacheName => caches.delete(cacheName))
      );
    });
  }
}

// 后台同步（可选功能）
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

/**
 * 后台同步任务
 */
function doBackgroundSync() {
  // 这里可以添加需要后台同步的任务
  console.log('Background sync completed');
}

// 推送通知（可选功能）
self.addEventListener('push', (event) => {
  const options = {
    body: event.data ? event.data.text() : 'Nomogram应用有新的更新',
    icon: '/images/icon-192.png',
    badge: '/images/icon-72.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: '查看详情',
        icon: '/images/icon-96.png'
      },
      {
        action: 'close',
        title: '关闭',
        icon: '/images/icon-96.png'
      }
    ]
  };

  event.waitUntil(
    self.registration.showNotification('Nomogram Calculator', options)
  );
});

// 通知点击处理
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  if (event.action === 'explore') {
    // 打开应用
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

console.log('Service Worker loaded');