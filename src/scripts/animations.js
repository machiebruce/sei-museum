import { animate, stagger } from 'animejs';

export function animateHomepage() {
  const logo = document.querySelector('.home-logo') ;
  const cards = document.querySelectorAll('.home-card');
  const credits = document.querySelector('.home-credits');

  if (logo) {
    logo.style.opacity = '0';
    logo.style.transform = 'translateY(-30px)';
    animate(logo, { opacity: [0, 1], translateY: [-30, 0], duration: 800, easing: 'easeOutExpo' });
  }

  if (cards.length) {
    cards.forEach(card => { card.style.opacity = '0'; card.style.transform = 'translateY(60px)'; });
    animate(cards, { opacity: [0, 1], translateY: [60, 0], duration: 1000, delay: stagger(200, { start: 400 }), easing: 'easeOutExpo' });
  }

  if (credits) {
    credits.style.opacity = '0';
    animate(credits, { opacity: [0, 1], duration: 800, delay: 1200, easing: 'easeOutExpo' });
  }
}

export function animateMenuPage() {
  const items = document.querySelectorAll('.menu-item');
  if (!items.length) return;
  items.forEach(item => { item.style.opacity = '0'; item.style.transform = 'translateX(-40px)'; });
  animate(items, { opacity: [0, 1], translateX: [-40, 0], duration: 900, delay: stagger(150, { start: 300 }), easing: 'easeOutExpo' });
}

export function animateLangSwitch() {
  const ls = document.querySelector('.lang-switch');
  if (!ls) return;
  ls.style.opacity = '0';
  ls.style.transform = 'translateX(30px)';
  animate(ls, { opacity: [0, 1], translateX: [30, 0], duration: 600, delay: 300, easing: 'easeOutExpo' });
}

export function animateNav() {
  const nav = document.querySelector('.nav-sidebar');
  if (!nav) return;
  nav.style.opacity = '0';
  nav.style.transform = 'translateX(-30px)';
  animate(nav, { opacity: [0, 1], translateX: [-30, 0], duration: 700, easing: 'easeOutExpo' });
}
