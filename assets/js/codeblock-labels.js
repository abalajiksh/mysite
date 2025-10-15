// 󰅩 Copy button functionality with HTTP fallback
document.addEventListener('DOMContentLoaded', function() {
  const copyButtons = document.querySelectorAll('.copy-code-button');
  
  // Fallback copy function for non-HTTPS
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
  
  // Modern clipboard API with fallback
  function copyToClipboard(text) {
    if (!navigator.clipboard) {
      return fallbackCopyTextToClipboard(text);
    }
    return navigator.clipboard.writeText(text).then(
      () => true,
      () => false
    );
  }
  
  copyButtons.forEach((button) => {
    button.addEventListener('click', function() {
      const wrapper = button.closest('.code-wrapper');
      const codeElement = wrapper.querySelector('code');
      
      if (codeElement) {
        const codeText = codeElement.innerText;
        const copyText = button.querySelector('.copy-text');
        const copyIcon = button.querySelector('.copy-icon');
        
        Promise.resolve(copyToClipboard(codeText)).then((success) => {
          if (success) {
            copyIcon.textContent = '󰄬';
            copyText.textContent = 'Copied!';
            
            setTimeout(() => {
              copyIcon.textContent = '󰆒';
              copyText.textContent = 'Copy';
            }, 2000);
          } else {
            copyIcon.textContent = '󰅙';
            copyText.textContent = 'Failed';
            
            setTimeout(() => {
              copyIcon.textContent = '󰆒';
              copyText.textContent = 'Copy';
            }, 2000);
          }
        });
      }
    });
  });
});
