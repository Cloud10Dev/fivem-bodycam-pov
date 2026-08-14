const hud = document.getElementById('hud');
const title = document.getElementById('title');
const unit = document.getElementById('unit');
const street = document.getElementById('street');
const speed = document.getElementById('speed');
const direction = document.getElementById('direction');
const timestamp = document.getElementById('timestamp');
const noise = document.querySelector('.noise');

function setVisible(value) {
  hud.style.display = value ? 'block' : 'none';
  hud.setAttribute('aria-hidden', value ? 'false' : 'true');
}

window.addEventListener('DOMContentLoaded', () => setVisible(true));
window.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.action === 'visibility') setVisible(Boolean(data.visible));
  if (data.action !== 'update') return;
  setVisible(Boolean(data.visible));
  if (data.color) document.documentElement.style.setProperty('--green', data.color);
  if (data.title) title.textContent = data.title;
  unit.textContent = data.unit || '';
  street.textContent = data.street || 'UNKNOWN';
  speed.textContent = `${data.speed || 0} KM/H`;
  direction.textContent = data.direction || 'N';
  timestamp.textContent = data.timestamp || '';
  noise.style.opacity = data.noise ? (data.moving ? '.12' : '.06') : '0';
});
