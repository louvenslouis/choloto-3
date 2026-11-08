// Manual AdSense unit. The Google tag also delivers the site's published CMP.
(() => {
  const client = 'ca-pub-3796372202478649';
  const listeners = new Set();
  let started = false;
  let allowed = false;

  function updateConsent(value) {
    allowed = value;
    for (const listener of listeners) listener(value);
  }

  function start() {
    started = true;
    const fc = window.googlefc ||= {};
    fc.callbackQueue ||= [];
    fc.callbackQueue.push({CONSENT_API_READY: () => {
      window.__tcfapi?.('addEventListener', 2, (data, success) => {
        const finalChoice = ['tcloaded', 'useractioncomplete'].includes(data?.eventStatus);
        updateConsent(success === true && (data?.gdprApplies === false ||
          (data?.gdprApplies === true && finalChoice &&
           data.purpose?.consents?.[1] === true && data.vendor?.consents?.[755] === true)));
      });
    }});
    const script = document.createElement('script');
    script.async = true;
    script.crossOrigin = 'anonymous';
    script.src = `https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${client}`;
    script.onerror = () => {
      started = false;
      script.remove();
      updateConsent(false);
    };
    document.head.append(script);
  }

  window.cholotoDrawAds = {
    watchConsent(listener) {
      listeners.add(listener);
      if (!started) start();
      listener(allowed);
      return () => listeners.delete(listener);
    },
    mount(host, unavailable) {
      const slot = document.createElement('ins');
      slot.className = 'adsbygoogle';
      slot.style.cssText = 'display:block;width:100%;height:100%';
      slot.dataset.adClient = client;
      slot.dataset.adSlot = '4696004385';
      let disposed = false;
      const status = new MutationObserver(() => {
        if (slot.dataset.adStatus === 'unfilled') {
          cleanup();
          unavailable();
        }
      });
      const size = new ResizeObserver(() => {
        if (disposed || !allowed || !host.isConnected || host.clientWidth < 300 || !host.clientHeight) return;
        size.disconnect();
        status.observe(slot, {attributes: true, attributeFilter: ['data-ad-status']});
        host.append(slot);
        try {
          (window.adsbygoogle ||= []).push({});
        } catch (_) {
          cleanup();
          unavailable();
        }
      });
      function cleanup() {
        disposed = true;
        size.disconnect();
        status.disconnect();
        slot.remove();
      }
      size.observe(host);
      return cleanup;
    },
  };
})();
