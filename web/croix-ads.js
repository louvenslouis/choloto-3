// One rewarded slot per visit. The app calls prepare only for a confirmed free account.
(() => {
  let script;
  let servicesEnabled = false;

  window.cholotoCroixAds = {prepare(path, ready, done) {
    const gpt = window.googletag ||= {cmd: []};
    let slot, service, stopConsent;
    let requested = false, finished = false, showing = false, granted = false;
    const handlers = new Map();
    const timeout = setTimeout(() => finish(true), 6500);

    function cancel() {
      if (finished) return;
      finished = true;
      clearTimeout(timeout);
      stopConsent?.();
      for (const [event, handler] of handlers) service.removeEventListener(event, handler);
      if (slot) gpt.destroySlots([slot]);
    }

    function finish(open) {
      if (finished) return;
      cancel();
      done(open);
    }

    function listen(event, callback) {
      const handler = data => {
        if (!finished && data.slot === slot) callback(data);
      };
      handlers.set(event, handler);
      service.addEventListener(event, handler);
    }

    function requestSlot() {
      if (finished) return;
      try {
        slot = gpt.defineOutOfPageSlot(path, gpt.enums.OutOfPageFormat.REWARDED);
        if (!slot) return finish(true);
        service = gpt.pubads();
        slot.addService(service);
        listen('slotRenderEnded', event => { if (event.isEmpty) finish(true); });
        listen('rewardedSlotReady', event => {
          clearTimeout(timeout);
          ready(() => {
            if (finished || showing) return;
            showing = true;
            try {
              if (!event.makeRewardedVisible()) finish(true);
            } catch (_) { finish(true); }
          });
        });
        listen('rewardedSlotGranted', () => { if (showing) granted = true; });
        listen('rewardedSlotClosed', () => finish(granted));
        if (!servicesEnabled) {
          gpt.enableServices();
          servicesEnabled = true;
        }
        gpt.display(slot);
      } catch (_) { finish(true); }
    }

    stopConsent = window.cholotoDrawAds.watchConsent(allowed => {
      if (finished) return;
      if (!allowed) {
        if (requested) finish(true);
        return;
      }
      if (requested) return;
      requested = true;
      gpt.cmd.push(requestSlot);
      if (!script && !gpt.apiReady && !finished) {
        script = document.createElement('script');
        script.async = true;
        script.crossOrigin = 'anonymous';
        script.src = 'https://securepubads.g.doubleclick.net/tag/js/gpt.js';
        script.onerror = () => {
          script.remove();
          script = null;
          finish(true);
        };
        document.head.append(script);
      }
    });
    if (finished) stopConsent();
    return cancel;
  }};
})();
