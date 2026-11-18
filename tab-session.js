(() => {
  const storageKey = 'iecms-tab-session';
  const getToken = () => window.sessionStorage.getItem(storageKey) || '';

  window.IECMSTabSession = {
    store(token) {
      if (typeof token !== 'string' || !/^[A-Za-z0-9,-]{16,128}$/.test(token)) {
        throw new Error('The server returned an invalid tab session.');
      }
      window.sessionStorage.setItem(storageKey, token);
    },
    clear() {
      window.sessionStorage.removeItem(storageKey);
    },
    withToken(value) {
      const token = getToken();
      const url = new URL(value, window.location.href);
      if (token && url.origin === window.location.origin) {
        url.searchParams.set('tab_session', token);
      }
      return url.href;
    }
  };

  const originalFetch = window.fetch.bind(window);
  window.fetch = (input, init = {}) => {
    const requestUrl = input instanceof Request ? input.url : input;
    const url = new URL(requestUrl, window.location.href);
    const token = getToken();
    if (token && url.origin === window.location.origin) {
      const headers = new Headers(input instanceof Request ? input.headers : undefined);
      new Headers(init.headers).forEach((value, key) => headers.set(key, value));
      headers.set('X-Tab-Session', token);
      init = { ...init, headers };
    }
    return originalFetch(input, init);
  };

  document.addEventListener('click', event => {
    const anchor = event.target instanceof Element ? event.target.closest('a[href]') : null;
    if (!anchor || !getToken()) return;
    const url = new URL(anchor.href, window.location.href);
    if (url.origin === window.location.origin) {
      url.searchParams.set('tab_session', getToken());
      anchor.href = url.href;
    }
  }, true);

  document.addEventListener('submit', event => {
    const form = event.target;
    if (!(form instanceof HTMLFormElement) || !getToken()) return;
    const url = new URL(form.action || window.location.href, window.location.href);
    if (url.origin !== window.location.origin) return;
    url.searchParams.set('tab_session', getToken());
    form.action = url.href;
  }, true);
})();
