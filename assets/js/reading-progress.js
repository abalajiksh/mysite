/* Reading-progress bar for published posts.
 *
 * The bar element (#reading-progress) is rendered only on single post
 * pages — see the guard in layouts/_default/baseof.html — so this script
 * simply no-ops on every other page even though it ships in the global
 * bundle. Externalized into the JS bundle (never an inline <script>) so the
 * CSP script-src needs no 'unsafe-inline'. */
(function () {
  'use strict';

  function init() {
    var bar = document.getElementById('reading-progress');
    if (!bar) return; // not a post page — nothing to track

    var article = document.querySelector('.post') || document.documentElement;
    var ticking = false;

    function update() {
      ticking = false;

      var scrollTop = window.scrollY || document.documentElement.scrollTop || 0;
      var start = article.offsetTop || 0;
      var span = article.offsetHeight - window.innerHeight;

      var progress;
      if (span <= 0) {
        // Article is shorter than the viewport: fill once its top is reached.
        progress = scrollTop >= start ? 1 : 0;
      } else {
        progress = (scrollTop - start) / span;
      }

      if (progress < 0) progress = 0;
      if (progress > 1) progress = 1;

      bar.style.transform = 'scaleX(' + progress + ')';
    }

    function onScroll() {
      if (!ticking) {
        ticking = true;
        window.requestAnimationFrame(update);
      }
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll, { passive: true });
    update();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
