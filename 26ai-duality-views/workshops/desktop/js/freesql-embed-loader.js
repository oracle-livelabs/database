(function () {
  "use strict";

  var ROOT_SELECTOR = "#module-content";
  var FRAME_SELECTOR = 'iframe[data-freesql-src], iframe[src*="freesql.com/embedded"]';
  var MAX_PARALLEL_LOADS = 1;
  var LOAD_TIMEOUT_MS = 20000;

  var activeLoads = 0;
  var queue = [];
  var frameCounter = 0;
  var observedFrames = new WeakSet();

  function isFreesqlUrl(value) {
    return typeof value === "string" && value.indexOf("freesql.com/embedded") !== -1;
  }

  function ensureFrameIdentity(frame) {
    frameCounter += 1;
    if (!frame.id) {
      frame.id = "freesql-embed-" + frameCounter;
    }

    // Avoid duplicate target names used in copied iframe snippets.
    frame.name = "freesql-embed-" + frameCounter;

    if (!frame.title || frame.title === "FreeSQL") {
      frame.title = "FreeSQL Embedded Playground " + frameCounter;
    }
  }

  function isDisplayable(frame) {
    if (!frame || !frame.isConnected) {
      return false;
    }

    var style = window.getComputedStyle(frame);
    if (style.display === "none" || style.visibility === "hidden") {
      return false;
    }

    return frame.getClientRects().length > 0;
  }

  function isNearViewport(frame) {
    var rect = frame.getBoundingClientRect();
    return rect.top < window.innerHeight * 1.3 && rect.bottom > -300;
  }

  function primeFrame(frame) {
    if (frame.dataset.freesqlReady === "1") {
      return;
    }

    var source = frame.getAttribute("data-freesql-src") || frame.getAttribute("src");
    if (!isFreesqlUrl(source)) {
      return;
    }

    frame.dataset.freesqlSrc = source;
    frame.removeAttribute("src");
    frame.removeAttribute("loading");

    frame.dataset.freesqlReady = "1";
    frame.classList.add("freesql-pending");

    ensureFrameIdentity(frame);
  }

  function markLoaded(frame) {
    frame.dataset.freesqlLoaded = "1";
    frame.classList.remove("freesql-loading");
    frame.classList.remove("freesql-pending");
    frame.classList.add("freesql-loaded");
  }

  function pumpQueue() {
    while (activeLoads < MAX_PARALLEL_LOADS && queue.length > 0) {
      var frame = queue.shift();

      if (!frame || !frame.isConnected || frame.dataset.freesqlLoaded === "1") {
        continue;
      }

      var src = frame.dataset.freesqlSrc;
      if (!isFreesqlUrl(src)) {
        continue;
      }

      activeLoads += 1;
      frame.dataset.freesqlQueued = "0";
      frame.classList.remove("freesql-pending");
      frame.classList.add("freesql-loading");

      (function (targetFrame) {
        var finished = false;
        var timeoutId = null;

        function finish() {
          if (finished) {
            return;
          }

          finished = true;
          if (timeoutId) {
            window.clearTimeout(timeoutId);
          }

          activeLoads = Math.max(0, activeLoads - 1);
          markLoaded(targetFrame);
          pumpQueue();
        }

        targetFrame.addEventListener("load", finish, { once: true });
        targetFrame.addEventListener("error", finish, { once: true });

        timeoutId = window.setTimeout(finish, LOAD_TIMEOUT_MS);
        targetFrame.setAttribute("loading", "eager");
        targetFrame.src = targetFrame.dataset.freesqlSrc;
      })(frame);
    }
  }

  function enqueueFrame(frame, prioritize) {
    if (
      !frame ||
      frame.dataset.freesqlReady !== "1" ||
      frame.dataset.freesqlLoaded === "1" ||
      frame.dataset.freesqlQueued === "1"
    ) {
      return;
    }

    frame.dataset.freesqlQueued = "1";
    if (prioritize) {
      queue.unshift(frame);
    } else {
      queue.push(frame);
    }
    pumpQueue();
  }

  function attachObserver(frame, observer) {
    if (observedFrames.has(frame)) {
      return;
    }

    observedFrames.add(frame);

    if (observer) {
      observer.observe(frame);
    } else {
      // Fallback for older browsers: queue immediately.
      enqueueFrame(frame);
    }
  }

  function scanAndPrepare() {
    var root = document.querySelector(ROOT_SELECTOR);
    if (!root) {
      return;
    }

    var frames = root.querySelectorAll(FRAME_SELECTOR);

    var observer = null;
    if (window.IntersectionObserver) {
      if (!window.__freesqlIntersectionObserver) {
        window.__freesqlIntersectionObserver = new IntersectionObserver(
          function (entries) {
            entries.forEach(function (entry) {
              if (!entry.isIntersecting) {
                return;
              }

              var frame = entry.target;
              window.__freesqlIntersectionObserver.unobserve(frame);
              enqueueFrame(frame, true);
            });
          },
          {
            root: null,
            rootMargin: "300px 0px 300px 0px",
            threshold: 0.01,
          }
        );
      }
      observer = window.__freesqlIntersectionObserver;
    }

    frames.forEach(function (frame) {
      primeFrame(frame);
      attachObserver(frame, observer);
    });

    // Ensure any visible frame starts loading quickly.
    frames.forEach(function (frame) {
      if (frame.dataset.freesqlReady !== "1" || frame.dataset.freesqlLoaded === "1") {
        return;
      }

      if (isDisplayable(frame) && isNearViewport(frame)) {
        enqueueFrame(frame, true);
      }
    });
  }

  function boot() {
    scanAndPrepare();

    var root = document.querySelector(ROOT_SELECTOR);
    if (!root) {
      window.setTimeout(boot, 200);
      return;
    }

    var mutationObserver = new MutationObserver(function () {
      scanAndPrepare();
    });

    mutationObserver.observe(root, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ["class", "style"],
    });

    document.addEventListener("click", function (event) {
      var target = event.target;
      var hasToggleClass = !!(target && target.classList && target.classList.contains("hol-ToggleRegions"));
      if (!target) {
        return;
      }

      if (
        target.id === "btn_toggle" ||
        hasToggleClass ||
        target.tagName === "H2"
      ) {
        window.setTimeout(scanAndPrepare, 150);
      }
    });

    window.addEventListener("hashchange", function () {
      window.setTimeout(scanAndPrepare, 150);
    });

    window.addEventListener("resize", function () {
      window.setTimeout(scanAndPrepare, 120);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
