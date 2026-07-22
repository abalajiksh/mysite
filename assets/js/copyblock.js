/* Copy-button functionality for the custom code blocks
 * (render-codeblock.html). Was an inline <script> in
 * partials/head/scripts.html; externalized into the JS bundle so the CSP
 * script-src needs no 'unsafe-inline'. Nerd Font glyphs below are literal —
 * keep this file UTF-8. */
(function() {
  'use strict';

  function removePoisonButtons() {
    const poisonButtons = document.querySelectorAll('.copy-button:not(.code-wrapper .copy-code-button), .copy-success');
    poisonButtons.forEach(function(btn) {
      btn.remove();
    });
  }

  function fallbackCopyTextToClipboard(text) {
    const textArea = document.createElement("textarea");
    textArea.value = text;
    textArea.style.position = "fixed";
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.width = "2em";
    textArea.style.height = "2em";
    textArea.style.padding = "0";
    textArea.style.border = "none";
    textArea.style.outline = "none";
    textArea.style.boxShadow = "none";
    textArea.style.background = "transparent";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    let success = false;
    try {
      success = document.execCommand('copy');
    } catch (err) {
      console.error('Fallback copy failed:', err);
    }

    document.body.removeChild(textArea);
    return success;
  }

  function copyToClipboard(text) {
    if (!navigator.clipboard) {
      return Promise.resolve(fallbackCopyTextToClipboard(text));
    }
    return navigator.clipboard.writeText(text).then(
      function() { return true; },
      function() { return fallbackCopyTextToClipboard(text); }
    );
  }

  function initCopyButtons() {
    const copyButtons = document.querySelectorAll('.code-wrapper .copy-code-button');

    copyButtons.forEach(function(button) {
      button.addEventListener('click', function() {
        const wrapper = button.closest('.code-wrapper');
        if (!wrapper) return;

        const codeElement = wrapper.querySelector('code');
        if (!codeElement) return;

        const codeText = codeElement.innerText;
        const copyText = button.querySelector('.copy-text');
        const copyIcon = button.querySelector('.copy-icon');

        copyToClipboard(codeText).then(function(success) {
          if (success) {
            copyIcon.textContent = '󰄬';
            copyText.textContent = 'Copied!';
            setTimeout(function() {
              copyIcon.textContent = '󰆒';
              copyText.textContent = 'Copy';
            }, 2000);
          } else {
            copyIcon.textContent = '󰅙';
            copyText.textContent = 'Failed';
            setTimeout(function() {
              copyIcon.textContent = '󰆒';
              copyText.textContent = 'Copy';
            }, 2000);
          }
        });
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      removePoisonButtons();
      initCopyButtons();
    });
  } else {
    removePoisonButtons();
    initCopyButtons();
  }
})();
