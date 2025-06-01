// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/**
 * This script loads the Flutter web app.
 */
'use strict';

const flutterBaseUrl = '/';  // Replace with your app's base URL.

/**
 * Handles the initial loading of the Flutter app.
 */
class FlutterLoader {
  constructor() {
    this._didInitialize = false;
  }

  /**
   * Initializes the Flutter app.
   */
  async loadEntrypoint(options) {
    const { serviceWorker, onEntrypointLoaded } = options || {};
    
    // Load the Flutter engine
    if (!this._didInitialize) {
      this._didInitialize = true;
      
      // Register service worker if specified
      if (serviceWorker && serviceWorker.serviceWorkerVersion) {
        await this._loadServiceWorker(serviceWorker);
      }
    }
    
    // Initialize the Flutter engine
    const engineInitializer = await this._loadFlutterEngine();
    
    // Call the callback with the engine initializer
    if (onEntrypointLoaded) {
      onEntrypointLoaded(engineInitializer);
    }
  }

  /**
   * Loads the Flutter engine script.
   */
  async _loadFlutterEngine() {
    return {
      initializeEngine: async () => {
        // In a real implementation, this would load the Flutter engine
        console.log('Flutter engine initialized');
        return {
          runApp: () => {
            console.log('Flutter app started');
            // Display a loading message until the real app loads
            document.body.innerHTML = `
              <div style="
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                font-family: sans-serif;
              ">
                <div style="
                  display: flex;
                  flex-direction: column;
                  align-items: center;
                ">
                  <h1 style="color: #0175C2;">Ev Yönetim Uygulaması</h1>
                  <p>Uygulama yükleniyor...</p>
                  <div style="
                    width: 50px;
                    height: 50px;
                    border: 5px solid #f3f3f3;
                    border-top: 5px solid #0175C2;
                    border-radius: 50%;
                    animation: spin 1s linear infinite;
                  "></div>
                </div>
              </div>
              <style>
                @keyframes spin {
                  0% { transform: rotate(0deg); }
                  100% { transform: rotate(360deg); }
                }
                body {
                  margin: 0;
                  padding: 0;
                  background-color: #f5f5f5;
                }
              </style>
            `;
          }
        };
      }
    };
  }

  /**
   * Registers the service worker.
   */
  async _loadServiceWorker({ serviceWorkerVersion }) {
    if ('serviceWorker' in navigator) {
      try {
        const registration = await navigator.serviceWorker.register(
          `${flutterBaseUrl}flutter_service_worker.js?v=${serviceWorkerVersion}`
        );
        registration.onupdatefound = () => {
          const installingWorker = registration.installing;
          if (!installingWorker) return;
          installingWorker.onstatechange = () => {
            if (installingWorker.state === 'installed') {
              if (navigator.serviceWorker.controller) {
                console.log('New service worker available. Refresh the page to use it.');
              } else {
                console.log('Service worker installed. Serving content from cache.');
              }
            }
          };
        };
      } catch (e) {
        console.error('Failed to register service worker:', e);
      }
    }
  }
}

// Create a global instance of the Flutter loader
window._flutter = new FlutterLoader();