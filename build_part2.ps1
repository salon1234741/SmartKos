$part3 = @'

<script>
// ── Tab Switching ──
function switchTab(tab) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
  document.getElementById('tab-' + tab).classList.add('active');
  document.getElementById('nav-' + tab).classList.add('active');
}

// ── UI Helpers ──
function setLampuUI(state) {
  const dot = document.getElementById('status-lampu-dot');
  dot.className = 'status-dot ' + (state === 'ON' ? 'on' : 'off');
}
function setKipasUI(state) {
  const dot = document.getElementById('status-kipas-dot');
  dot.className = 'status-dot ' + (state === 'ON' ? 'on' : 'off');
}
let isInitialKipasSetup = false;
function setKipasStatus(state, save) {
  const s = state === 'ON' ? 'ON' : 'OFF';
  setKipasUI(s);
  if (save) localStorage.setItem('statusKipas', s);
}

function kirimLampu(state) {
  if (!client.connected) { alert('Koneksi terputus.'); return; }
  client.publish('smartkos/lampu', state);
  localStorage.setItem('statusLampu', state);
  setLampuUI(state);
}
function kirimKipas(state) {
  if (!client.connected) { alert('Koneksi terputus.'); return; }
  client.publish('smartkos/kipas', state);
  setKipasStatus(state, true);
}

function syncAlarmUI(waktu, isActive) {
  ['','_-2'].forEach(suffix => {
    const s = suffix === '_-2' ? '-2' : '';
    const dotEl = document.getElementById('alarm-dot' + s);
    const textEl = document.getElementById('alarm-status-text' + s);
    const inputEl = document.getElementById('waktu-alarm' + s);
    if (isActive && waktu) {
      if (dotEl) dotEl.className = 'alarm-ring-dot aktif';
      if (textEl) textEl.innerText = 'Aktif · ' + waktu + ' WIB';
      if (inputEl) inputEl.value = waktu;
      // Update schedule hero
      const heroTime = document.getElementById('schedule-alarm-time');
      const heroStatus = document.getElementById('schedule-alarm-status');
      if (heroTime) heroTime.innerHTML = waktu + '<span class="ampm">WIB</span>';
      if (heroStatus) heroStatus.innerHTML = '<span class="material-symbols-outlined mat-filled" style="font-size:14px;color:var(--tertiary)">check_circle</span><span style="color:var(--tertiary)">Alarm Aktif</span>';
    } else {
      if (dotEl) dotEl.className = 'alarm-ring-dot';
      if (textEl) textEl.innerText = 'Alarm Mati';
      const heroTime = document.getElementById('schedule-alarm-time');
      const heroStatus = document.getElementById('schedule-alarm-status');
      if (heroTime) heroTime.innerHTML = '--:--<span class="ampm">WIB</span>';
      if (heroStatus) heroStatus.innerHTML = '<span class="material-symbols-outlined mat-filled" style="font-size:14px">info</span><span>Belum ada alarm aktif</span>';
    }
  });
}

function setAlarm() {
  const waktu = document.getElementById('waktu-alarm').value;
  if (!waktu) { alert('Silakan pilih waktu alarm'); return; }
  if (!client.connected) { alert('Koneksi terputus.'); return; }
  client.publish('smartkos/alarm', waktu);
  localStorage.setItem('alarmWaktu', waktu);
  syncAlarmUI(waktu, true);
}
function nonaktifkanAlarm() {
  if (!client.connected) { alert('Koneksi terputus.'); return; }
  client.publish('smartkos/alarm', 'OFF');
  localStorage.removeItem('alarmWaktu');
  syncAlarmUI(null, false);
}
function setAlarmFromSchedule() {
  const waktu = document.getElementById('waktu-alarm-2').value;
  if (!waktu) { alert('Silakan pilih waktu alarm'); return; }
  if (!client.connected) { alert('Koneksi terputus.'); return; }
  client.publish('smartkos/alarm', waktu);
  localStorage.setItem('alarmWaktu', waktu);
  syncAlarmUI(waktu, true);
}
function nonaktifkanAlarmFromSchedule() {
  if (!client.connected) { alert('Koneksi terputus.'); return; }
  client.publish('smartkos/alarm', 'OFF');
  localStorage.removeItem('alarmWaktu');
  syncAlarmUI(null, false);
}

// ── Init LocalStorage ──
if (localStorage.getItem('versi') !== '3') {
  localStorage.removeItem('statusKipas');
  localStorage.removeItem('alarmWaktu');
  localStorage.removeItem('alarmSkipDate');
  localStorage.setItem('versi', '3');
}
const savedLampu = localStorage.getItem('statusLampu');
if (savedLampu) setLampuUI(savedLampu);
if (localStorage.getItem('statusKipas') === null) {
  localStorage.setItem('statusKipas', 'ON');
  isInitialKipasSetup = true;
}
setKipasStatus(localStorage.getItem('statusKipas'), false);
const savedAlarm = localStorage.getItem('alarmWaktu');
if (savedAlarm) { syncAlarmUI(savedAlarm, true); }

// ── MQTT ──
const broker = 'wss://276d9e54084e4a99b7b863492b06212b.s1.eu.hivemq.cloud:8884/mqtt';
const options = { username: 'Rafifirdaus', password: '@Gresik123', clientId: 'webClient_' + Math.random().toString(16).substr(2, 8) };
const client = mqtt.connect(broker, options);
const allBtns = ['btn-on','btn-off','btn-kipas-on','btn-kipas-off','btn-set','btn-nonaktif','btn-set-2','btn-nonaktif-2'];

client.on('connect', () => {
  allBtns.forEach(id => { const el = document.getElementById(id); if(el) el.disabled = false; });
  client.subscribe('smartkos/status');
  if (isInitialKipasSetup) { client.publish('smartkos/kipas', 'ON'); isInitialKipasSetup = false; }
});
client.on('disconnect', () => { allBtns.forEach(id => { const el = document.getElementById(id); if(el) el.disabled = true; }); });
client.on('error', () => { allBtns.forEach(id => { const el = document.getElementById(id); if(el) el.disabled = true; }); });
client.on('message', (topic, message) => {
  if (topic === 'smartkos/status' && message.toString() === 'ALARM_BUNYI') { setKipasStatus('OFF', true); }
});

// ── Clock ──
let prevDigits = ['','','','','',''];
function updateJam() {
  const now = new Date();
  const jamStr = new Intl.DateTimeFormat('id-ID', { timeZone:'Asia/Jakarta', hour:'2-digit', minute:'2-digit', second:'2-digit', hour12:false }).format(now).replace(/\./g,':').replace(/:/g,'');
  jamStr.split('').forEach((digit, i) => {
    if (digit !== prevDigits[i]) {
      const el = document.getElementById('d' + i);
      el.classList.remove('slide-in'); void el.offsetWidth;
      el.textContent = digit; el.classList.add('slide-in');
      prevDigits[i] = digit;
    }
  });
  const tgl = new Intl.DateTimeFormat('id-ID', { timeZone:'Asia/Jakarta', weekday:'long', day:'numeric', month:'long', year:'numeric' }).format(now);
  document.getElementById('tanggal').innerText = tgl;
}
setInterval(updateJam, 1000); updateJam();

// ── Weather ──
const WEATHER_KEY = 'fcf807bd760344b5a57124817261204';
const CUACA_URL = 'https://api.weatherapi.com/v1/current.json?key=' + WEATHER_KEY + '&q=Surabaya&lang=id';
function weatherIcon(code, isDay) {
  const iconMap = {1000:'wb_sunny',1003:'partly_cloudy_day',1006:'cloud',1009:'cloud',1030:'mist',1135:'mist',1147:'mist'};
  if (code === 1000 && !isDay) return 'dark_mode';
  return iconMap[code] || ([1063,1150,1153,1168,1171,1180,1183].includes(code) ? 'grain' :
    [1186,1189,1192,1195,1198,1201,1240,1243,1246].includes(code) ? 'rainy' :
    [1087,1273,1276,1279,1282].includes(code) ? 'thunderstorm' : 'thermostat');
}
async function ambilCuaca() {
  const el = document.getElementById('cuaca-content');
  el.innerHTML = '<div class="weather-loading">Memuat data cuaca...</div>';
  try {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), 5000);
    const res = await fetch(CUACA_URL, { signal: ctrl.signal });
    clearTimeout(timer);
    if (!res.ok) throw new Error('Gagal');
    const data = await res.json();
    const c = data.current;
    const suhu = Math.round(c.temp_c), humidity = Math.round(c.humidity), angin = Math.round(c.wind_kph);
    const kondisi = c.condition.text, icon = weatherIcon(c.condition.code, c.is_day);
    el.innerHTML = '<div class="weather-card"><div class="weather-left"><span class="material-symbols-outlined mat-filled" style="font-size:3rem;color:var(--secondary)">' + icon + '</span><div><div class="weather-temp">' + suhu + '°C</div><div class="weather-cond">' + kondisi + '</div></div></div><div class="weather-right"><div class="weather-detail"><span>Humidity ' + humidity + '%</span><span class="material-symbols-outlined">humidity_low</span></div><div class="weather-detail"><span>Wind ' + angin + ' km/h</span><span class="material-symbols-outlined">air</span></div></div></div>';
  } catch (e) {
    el.innerHTML = '<div class="weather-loading" style="color:var(--error)">Gagal memuat cuaca.</div>';
  }
}
ambilCuaca(); setInterval(ambilCuaca, 10 * 60 * 1000);

// ── Prayer Times ──
let sholatData = [];
function hitungSholat() {
  const LAT=-7.2575,LON=112.7521,TZ=7,FAJR_ANG=20,ISHA_ANG=18;
  const now=new Date(),Y=now.getFullYear(),M=now.getMonth()+1,D=now.getDate();
  const JD=Math.floor(365.25*(Y+4716))+Math.floor(30.6001*(M+1))+D+2-Math.floor(Y/100)+Math.floor(Math.floor(Y/100)/4)-1524.5;
  const T=(JD-2451545)/36525;
  const L0=(280.46646+36000.76983*T)%360;
  const M2=(357.52911+35999.05029*T-0.0001537*T*T)*Math.PI/180;
  const C=(1.914602-0.004817*T)*Math.sin(M2)+0.019993*Math.sin(2*M2);
  const SL=(L0+C)*Math.PI/180;
  const OB=(23.439291-0.013004*T)*Math.PI/180;
  const RA=Math.atan2(Math.cos(OB)*Math.sin(SL),Math.cos(SL))*180/Math.PI;
  const DEC=Math.asin(Math.sin(OB)*Math.sin(SL));
  const EQT=(L0-0.0057183-RA+(125.04-1934.136*T)*Math.PI/180*(-0.00478*Math.sin((125.04-1934.136*T)*Math.PI/180)-0.00417*Math.sin(2*L0*Math.PI/180)))*4;
  const TRANSIT=12+TZ-LON/15-EQT/60;
  function hourAngle(a){const ar=a*Math.PI/180,lr=LAT*Math.PI/180,ch=(Math.sin(ar)-Math.sin(lr)*Math.sin(DEC))/(Math.cos(lr)*Math.cos(DEC));if(ch<-1||ch>1)return null;return Math.acos(ch)*180/Math.PI/15;}
  function asrHA(s){const lr=LAT*Math.PI/180,a=Math.atan(1/(s+Math.tan(Math.abs(lr-DEC)))),ch=(Math.sin(a)-Math.sin(lr)*Math.sin(DEC))/(Math.cos(lr)*Math.cos(DEC));if(ch<-1||ch>1)return null;return Math.acos(ch)*180/Math.PI/15;}
  function toHHMM(d){if(d===null)return'--:--';d=((d%24)+24)%24;let h=Math.floor(d),m=Math.round((d-h)*60);if(m===60){h++;m=0;}return String(h).padStart(2,'0')+':'+String(m).padStart(2,'0');}
  return[{nama:'Subuh',waktu:toHHMM(TRANSIT-hourAngle(-FAJR_ANG))},{nama:'Dzuhur',waktu:toHHMM(TRANSIT+0.017)},{nama:'Ashar',waktu:toHHMM(TRANSIT+asrHA(1))},{nama:'Maghrib',waktu:toHHMM(TRANSIT+hourAngle(-0.8333)+0.033)},{nama:'Isya',waktu:toHHMM(TRANSIT+hourAngle(-ISHA_ANG))}];
}
function tampilSholat() {
  const el = document.getElementById('sholat-content');
  try {
    sholatData = hitungSholat();
    const now = new Date();
    const jamNow = now.toLocaleTimeString('id-ID',{timeZone:'Asia/Jakarta',hour:'2-digit',minute:'2-digit',hour12:false}).replace('.',':');
    let idxAktif = -1;
    for (let i = sholatData.length-1; i >= 0; i--) { if (jamNow >= sholatData[i].waktu) { idxAktif = i; break; } }
    const idxNext = (idxAktif+1) % sholatData.length;
    const cards = sholatData.map((s,i) => {
      const active = i === idxAktif, next = i === idxNext;
      let cls = 'prayer-card';
      let badge = '';
      if (active) { cls += ' aktif'; badge = '<div class="prayer-badge">Sekarang</div>'; }
      else if (next) { cls += ' berikutnya'; badge = '<div class="prayer-badge">Berikutnya</div>'; }
      return '<div class="'+cls+'">'+badge+'<p class="p-name">'+s.nama+'</p><p class="p-time">'+s.waktu+'</p></div>';
    }).join('');
    el.innerHTML = '<div class="prayer-scroll">'+cards+'</div>';
  } catch(e) { el.innerHTML = '<div class="weather-loading" style="color:var(--error)">Gagal menghitung jadwal.</div>'; }
}
tampilSholat(); setInterval(tampilSholat, 60*1000);
</script>
</body>
</html>
'@

Add-Content -Path "index_new.html" -Value $part3 -Encoding UTF8 -NoNewline

# Now replace the original
Copy-Item "index.html" "index_backup.html" -Force
Copy-Item "index_new.html" "index.html" -Force
Write-Output "Done! index.html has been redesigned. Backup saved as index_backup.html."
