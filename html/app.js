const hud = document.getElementById('hud');
const title = document.getElementById('title');
const unit = document.getElementById('unit');
const street = document.getElementById('street');
const speed = document.getElementById('speed');
const timestamp = document.getElementById('timestamp');

window.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.action === 'visibility') hud.style.display = data.visible ? 'block' : 'none';
  if (data.action === 'update') {
    hud.style.display = data.visible ? 'block' : 'none';
    if (data.color) document.documentElement.style.setProperty('--hud', data.color);
    if (data.title) title.textContent = data.title;
    if (data.unit) unit.textContent = data.unit;
    street.textContent = data.street || 'UNKNOWN';
    speed.textContent = data.speed == null ? '' : `${data.speed} KM/H`;
    timestamp.textContent = data.timestamp || '';
  }
});
