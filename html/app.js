const hud = document.getElementById('hud');
const title = document.getElementById('title');
const unit = document.getElementById('unit');
const street = document.getElementById('street');
const speed = document.getElementById('speed');
const direction = document.getElementById('direction');
const timestamp = document.getElementById('timestamp');
const noise = document.querySelector('.noise');

window.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.action === 'visibility') hud.style.display = data.visible ? 'block' : 'none';
  if (data.action !== 'update') return;
  hud.style.display = data.visible ? 'block' : 'none';
  if (data.color) document.documentElement.style.setProperty('--hud', data.color);
  if (data.title) title.textContent = data.title;
  unit.textContent = data.unit || '';
  street.textContent = data.street || 'UNKNOWN';
  speed.textContent = data.speed == null ? '0' : data.speed;
  direction.textContent = data.direction || 'N';
  timestamp.textContent = data.timestamp || '';
  noise.style.opacity = data.noise ? String(0.06 + ((data.movement || 0) * 0.08)) : '0';
  hud.classList.toggle('moving', Boolean(data.movement > 0.05));
});
