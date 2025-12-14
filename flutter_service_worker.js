'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "84714bbe70bc1d500636ff6a43e9cfe2",
"index.html": "c9695fe606ccc6b87d78d9f324ce7164",
"/": "c9695fe606ccc6b87d78d9f324ce7164",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "f9e6786b770ad1142d92e473f48d7e09",
"assets/assets/images/%25EC%25B5%259C%25EC%259D%25B8%25EC%259A%25B0.png": "7663d674541794df7760b33e03fec9d6",
"assets/assets/images/%25EC%25A0%259C%25EC%258A%25B9%25EA%25B7%259C.png": "3d18021071168ef9359dd39c88aa62a0",
"assets/assets/images/%25EA%25B0%2595%25EB%258F%2599%25ED%259D%25AC.png": "47c79766e990949219aa1691e09e8718",
"assets/assets/images/%25ED%2599%258D%25EC%25A4%2580%25EC%259A%25B0.png": "c6c768f7c3b35c0a7be9d47e26c393b4",
"assets/assets/images/%25EA%25B9%2580%25EB%258F%2599%25EA%25B7%259C.png": "ae339d83b53daea469fd2339677d1399",
"assets/assets/images/%25EC%259C%25A0%25ED%2598%2584%25EC%25A2%2585.png": "e61d19c1e7f88726efb0b1d3ce4b2e1f",
"assets/assets/images/%25EC%259E%25A5%25EC%2598%2581%25EC%259E%25AC.png": "b69938626280887867b571c48320f482",
"assets/assets/images/%25EB%25B0%25B1%25EC%25A7%2580%25ED%259B%2588.png": "fdb9b703d2052c9ec1f48c616be1bc6c",
"assets/assets/images/%25EA%25B6%258C%25EC%25A7%2580%25EC%2596%25B8.png": "2d1c7f691d2596b74c369c1377096528",
"assets/assets/images/%25EC%259D%25B4%25ED%259D%25AC%25EC%259E%25AC.png": "a39fde18fc15f70bb6dc0bf4551f3761",
"assets/assets/images/%25ED%2599%258D%25EC%259D%25B4%25EC%25A4%2580.png": "af0d0659bf6199f1ab7b0975da01b957",
"assets/assets/images/%25EB%25B0%2595%25EC%259C%25A4%25EC%2584%259C.png": "81e0c619e4a2e964698f926f016f9781",
"assets/assets/images/%25EA%25B9%2580%25EC%258A%25B9%25ED%2598%2584.png": "ab759cc9d5edf00e9e78736b3fd1ebf1",
"assets/assets/images/%25EC%25A1%25B0%25ED%2598%2584%25EC%259A%25B0.png": "3591f0e517db45e0e3cafbb1a72eecf9",
"assets/assets/images/%25EC%2599%2595%25EC%25A4%2580%25EC%2584%25AD.png": "19ba72cfb815ad72d8a945c94ba6760b",
"assets/assets/images/%25EB%2582%2598%25EB%258F%2584%25EC%2597%25B0.png": "efe7cc6950aaa90b836256ccf4f5bcb1",
"assets/assets/images/%25EC%259D%25B4%25EC%2584%25B1%25ED%2598%2584.png": "d359138ba2beff73c1850fec60d47dc6",
"assets/assets/images/%25EC%25B5%259C%25EA%25B1%25B4%25ED%2595%2598.png": "2569d92fdc8911833d5b292a14d62d11",
"assets/assets/images/%25EA%25B9%2580%25EC%2597%25AC%25EC%25A0%2595.png": "d22792bb121f99f2d14629cfa665999e",
"assets/assets/images/%25EA%25B9%2580%25ED%2583%259C%25EC%258A%25B9.png": "f2de331763002d17b1d2dad6def96b32",
"assets/assets/images/%25EC%25B5%259C%25EC%25A7%2584%25ED%2598%2584.png": "fdf16228d8abe4f75a79fa3e471143e5",
"assets/assets/images/%25EC%2586%25A1%25EC%25A4%2580%25EC%2598%2581.png": "671f302d29d4bb3d9dae6f5b3e24b1ca",
"assets/assets/images/%25EC%259D%25B4%25ED%2598%2584%25EB%25AF%25BC.png": "85748d505cc24b4799260e78ef6607f7",
"assets/assets/images/%25EC%25A1%25B0%25EC%259D%2580%25EA%25B0%2595.png": "e5c11ebae672bd4249cdf0de4a91569c",
"assets/assets/images/%25EC%259D%25B4%25EC%2588%2598%25EC%2597%25B0.png": "8ff69ba0c348bf729a1624c308ec8c41",
"assets/assets/images/%25EC%259D%25B4%25EA%25B2%25BD%25EB%25A1%259D.png": "fd1a52be8b88d3aa28d1f82a5efd0b41",
"assets/assets/images/%25EC%259C%25A0%25EC%2598%2581%25EC%25A3%25BC.png": "512241ca9a59cc1b656a0742b832caf8",
"assets/assets/images/%25EA%25B9%2580%25ED%2598%259C%25EC%259D%25B8.png": "23b40dad3bb75faa84b81a22cd0bb06a",
"assets/assets/images/%25EC%259C%25A0%25ED%2583%259C%25EA%25B6%258C.png": "3dd127ae13834004b9912e43ed0e737c",
"assets/assets/images/%25EC%25A0%2584%25ED%2598%2581%25EC%25A4%2580.png": "c2dee06bd56da467d7fcefa55bf3ef89",
"assets/assets/images/%25EA%25B9%2580%25ED%2583%259C%25EB%25A6%25B0.png": "e566405e728102b0b4324f585364cc09",
"assets/assets/images/%25EC%259D%25B4%25EC%25A0%2595%25ED%2599%2598.png": "d74b43ef5b8f2e5228db7868a0c3bfcf",
"assets/assets/images/%25EA%25B0%2595%25EC%25B0%25BD%25EB%25AF%25BC.png": "36524185e82451e8df23d6cc5725e4ba",
"assets/assets/images/%25EC%259E%2584%25EC%25A4%2580%25EC%2584%259C.png": "3814a3c477544b64aec4b6428091bf34",
"assets/assets/images/%25EA%25B9%2580%25EC%2598%2588%25EC%2584%25B1.png": "33b422b8806a08065eb11e7d73b92d56",
"assets/assets/images/%25EC%2597%2584%25EB%25AF%25BC%25EC%259E%25AC.png": "a4c620be84a868d5d00bec9a6ae9e05a",
"assets/assets/images/%25EA%25B9%2580%25EC%2584%25B8%25ED%2598%2584.png": "fc2b3ae288d2ca90f302e3e5ff5c5dd9",
"assets/fonts/MaterialIcons-Regular.otf": "4e38f4132097d091a6387008f9ded5a3",
"assets/NOTICES": "ebd27e157aebfbbe67d4f2d4a4bce6fa",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "6fda7e00d60789f93d56d5805f4616c8",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "3d5eb8461d013d1e964be7d57c0e4f59",
"version.json": "ac78886d0740be3e1e96a137f2ffb06d",
"main.dart.js": "415e09c0e380e62de772c667d3557408"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
