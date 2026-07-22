/* Remark42 embed — config + loader, externalized from the theme's two
 * inline <script> blocks in partials/post/comments.html so the CSP
 * script-src needs no 'unsafe-inline'. Host/site_id are baked in at build
 * time via resources.ExecuteAsTemplate (see the site-level
 * layouts/partials/post/comments.html override). Loaded with defer, so the
 * DOM (incl. body.dark-theme) is ready when this runs. */
(function() {
  'use strict';

  var themeFromLS = localStorage.getItem("theme");
  var themeFromHugo = document.body.classList.contains("dark-theme") ? "dark" : "light";
  var currentTheme = themeFromLS ? themeFromLS : themeFromHugo;

  window.remark_config = {
    host: {{ site.Params.remark42_host | jsonify }},
    site_id: {{ site.Params.remark42_site_id | jsonify }},
    theme: currentTheme,
    max_shown_comments: 100,
  };

  /* Upstream Remark42 loader (unmodified) */
  !function(e,n){for(var o=0;o<e.length;o++){var r=n.createElement("script"),c=".js",d=n.head||n.body;"noModule"in r?(r.type="module",c=".mjs"):r.async=!0,r.defer=!0,r.src=remark_config.host+"/web/"+e[o]+c,d.appendChild(r)}}(remark_config.components||["embed"],document);
})();
