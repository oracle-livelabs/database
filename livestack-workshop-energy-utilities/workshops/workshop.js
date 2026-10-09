/* Add mobile menu state to the shared LiveLabs renderer without changing it. */
(() => {
  const smallScreen = window.matchMedia('(max-width: 900px)');
  let activeLesson = '';
  let zoomTrigger = null;
  let zoomOpen = false;
  function syncMenu() {
    const nav = document.querySelector('#leftNav');
    const button = document.querySelector('#openNav');
    const content = document.querySelector('#contentBox');
    const lesson = document.querySelector('#module-content h1')?.textContent;
    if (!nav || !button || !content || !lesson || !document.querySelector('#leftNav-toc')) return;
    if (activeLesson !== lesson) {
      activeLesson = lesson;
      if (smallScreen.matches) {
        [nav, content, document.querySelector('#leftNav-toc')].forEach(element => {
          element.classList.remove('open');
          element.classList.add('close');
        });
      }
    }
    const expanded = nav.classList.contains('open');
    button.setAttribute('aria-expanded', String(expanded));
    button.setAttribute('aria-controls', 'leftNav');
    button.setAttribute('aria-label', expanded ? 'Close Menu' : 'Open Menu');
    document.querySelectorAll('#module-content h2[tabindex]').forEach(heading => {
      heading.setAttribute('role', 'button');
      heading.setAttribute('aria-expanded', String(heading.classList.contains('minus')));
    });
    document.querySelectorAll('#leftNav .toc-item').forEach(item => {
      if (!item.querySelector('a')) {
        item.tabIndex = 0;
        item.setAttribute('role', 'button');
      }
    });
    document.querySelectorAll('#module-content img[src]').forEach(image => {
      if (image.id !== 'modalImg' && !image.closest('a')) {
        image.tabIndex = 0;
        image.setAttribute('role', 'button');
        image.setAttribute('aria-label', 'Enlarge image: ' + (image.alt || 'Workshop screenshot'));
      }
    });
    const modal = document.querySelector('#modalWindow');
    const close = document.querySelector('#modalClose');
    const shown = modal?.classList.contains('show');
    if (modal && close) {
      modal.setAttribute('role', 'dialog');
      modal.setAttribute('aria-modal', 'true');
      modal.setAttribute('aria-labelledby', 'modalCaption');
      close.tabIndex = 0;
      close.setAttribute('role', 'button');
      close.setAttribute('aria-label', 'Close enlarged image');
      if (shown && !zoomOpen) close.focus();
      if (!shown && zoomOpen) zoomTrigger?.focus();
    }
    zoomOpen = !!shown;
  }
  document.addEventListener('click', event => {
    if (smallScreen.matches && event.target.closest('#openNav')) {
      event.preventDefault();
      event.stopImmediatePropagation();
      const open = !document.querySelector('#leftNav').classList.contains('open');
      ['#leftNav', '#contentBox', '#leftNav-toc'].forEach(selector => {
        const element = document.querySelector(selector);
        element.classList.toggle('open', open);
        element.classList.toggle('close', !open);
      });
      syncMenu();
      return;
    }
    if (event.target.matches('#module-content img:not(#modalImg)')) zoomTrigger = event.target;
  }, true);
  document.addEventListener('keydown', event => {
    const target = event.target;
    const modalShown = document.querySelector('#modalWindow.show');
    if (modalShown && (event.key === 'Escape' || event.key === 'Tab')) {
      event.preventDefault();
      event.stopImmediatePropagation();
      const close = document.querySelector('#modalClose');
      if (event.key === 'Escape') close.click();
      else close.focus();
      return;
    }
    const menu = target.id === 'openNav';
    const section = target.matches('#module-content h2[tabindex], #leftNav .toc-item[role="button"], #module-content img[role="button"], #modalClose');
    if ((event.key === 'Enter' || event.key === ' ') && (menu || section)) {
      event.preventDefault();
      event.stopImmediatePropagation();
      target.click();
      return;
    }
    if (event.key === 'Escape' && smallScreen.matches && document.querySelector('#leftNav.open')) {
      const button = document.querySelector('#openNav');
      button.click();
      button.focus();
    }
  }, true);
  const observer = new MutationObserver(syncMenu);
  observer.observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['class'] });
  document.addEventListener('DOMContentLoaded', syncMenu);
})();
