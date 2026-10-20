$part1 = @'
<!DOCTYPE html>
<html class="dark" lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Smart Kos Dashboard</title>
<script src="https://unpkg.com/mqtt/dist/mqtt.min.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
<style>
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
:root{
--bg:#0a0e14;--surface:#151a21;--surface-high:#1b2028;--surface-highest:#20262f;
--surface-low:#0f141a;--primary:#82aeff;--primary-dim:#0e71e4;--primary-container:#69a0ff;
--secondary:#fd9000;--tertiary:#b5ffc2;--tertiary-bright:#3fff8b;
--on-surface:#f1f3fc;--on-surface-variant:#a8abb3;--outline:#72757d;--outline-variant:#44484f;
--error:#ff716c;--error-container:#9f0519;--on-error-container:#ffa8a3;
--radius-xl:2rem;--radius-lg:1.5rem;--radius-md:1rem;--radius-sm:0.75rem;
}
html{scroll-behavior:smooth}
body{font-family:'Plus Jakarta Sans',sans-serif;background:var(--bg);color:var(--on-surface);min-height:100dvh;padding-bottom:7rem;-webkit-font-smoothing:antialiased}
.material-symbols-outlined{font-variation-settings:'FILL' 0,'wght' 400,'GRAD' 0,'opsz' 24}
.mat-filled{font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24}

/* Header */
.top-bar{position:sticky;top:0;z-index:50;background:var(--surface);padding:1rem 1.5rem;display:flex;justify-content:space-between;align-items:center}
.top-bar-left{display:flex;align-items:center;gap:0.75rem}
.avatar{width:2.5rem;height:2.5rem;border-radius:50%;background:var(--surface-highest);border:2px solid var(--primary-container);display:flex;align-items:center;justify-content:center;overflow:hidden}
.avatar .material-symbols-outlined{font-size:1.5rem;color:var(--primary)}
.top-bar-info .label{font-size:10px;color:var(--outline);text-transform:uppercase;letter-spacing:0.15em;font-weight:700}
.top-bar-info h1{font-size:1.1rem;font-weight:600;color:var(--primary);margin-top:2px}
.notif-btn{width:2.5rem;height:2.5rem;border-radius:var(--radius-sm);background:var(--surface-highest);border:none;display:flex;align-items:center;justify-content:center;cursor:pointer;transition:all .2s}
.notif-btn:active{transform:scale(.95)}
.notif-btn .material-symbols-outlined{color:var(--primary);font-size:1.3rem}

/* Main */
main{padding:1rem 1.5rem;max-width:480px;margin:0 auto}
.tab-content{display:none}.tab-content.active{display:block}
.section-gap{display:flex;flex-direction:column;gap:1.25rem}

/* Clock Hero */
.clock-hero{position:relative;overflow:hidden;border-radius:var(--radius-xl);padding:2rem;background:var(--surface);border:1px solid rgba(68,72,79,.1);text-align:center}
.clock-hero .glow{position:absolute;right:-3rem;top:-3rem;width:12rem;height:12rem;background:rgba(130,174,255,.1);border-radius:50%;filter:blur(80px)}
.clock-hero .time{font-size:4rem;font-weight:800;letter-spacing:-0.05em;line-height:1;position:relative;z-index:1}
.clock-hero .date{margin-top:.5rem;color:var(--outline);font-weight:500;letter-spacing:.03em;position:relative;z-index:1;font-size:.9rem}
.digit-w{display:inline-block;overflow:hidden;height:1.15em;vertical-align:bottom}
.digit{display:block}.digit.slide-in{animation:slideUp .25s cubic-bezier(.16,1,.3,1) forwards}
@keyframes slideUp{from{transform:translateY(-40%);opacity:0}to{transform:translateY(0);opacity:1}}
.sep{margin:0 2px;color:rgba(255,255,255,.2);font-weight:300}

/* Glass Panel */
.glass{backdrop-filter:blur(20px);background:linear-gradient(135deg,rgba(21,26,33,.7),rgba(15,20,26,.4));border:1px solid rgba(68,72,79,.1);border-radius:var(--radius-xl);padding:1.5rem}

/* Weather */
.weather-card{display:flex;align-items:center;justify-content:space-between}
.weather-left{display:flex;align-items:center;gap:1rem}
.weather-left .material-symbols-outlined{font-size:3rem;color:var(--secondary)}
.weather-temp{font-size:1.8rem;font-weight:700}
.weather-cond{font-size:.85rem;color:var(--on-surface-variant);font-weight:500}
.weather-right{text-align:right;display:flex;flex-direction:column;gap:4px}
.weather-detail{font-size:.75rem;color:var(--outline);display:flex;align-items:center;justify-content:flex-end;gap:4px}
.weather-detail .material-symbols-outlined{font-size:14px}
.weather-loading{color:var(--outline);font-size:.85rem;text-align:center;padding:1rem 0}

/* Section Title */
.section-title{display:flex;justify-content:space-between;align-items:center}
.section-title h2{font-size:.8rem;font-weight:700;color:var(--outline);text-transform:uppercase;letter-spacing:.15em}
.section-title span{font-size:.75rem;color:var(--primary);font-weight:500}

/* Prayer Cards */
.prayer-scroll{display:flex;gap:.75rem;overflow-x:auto;padding-bottom:.5rem;scrollbar-width:none}
.prayer-scroll::-webkit-scrollbar{display:none}
.prayer-card{flex-shrink:0;width:6rem;padding:1rem;border-radius:var(--radius-md);background:var(--surface);border:1px solid rgba(68,72,79,.05);text-align:center;transition:all .3s;position:relative}
.prayer-card .p-name{font-size:10px;color:var(--outline);margin-bottom:4px}
.prayer-card .p-time{font-weight:700;font-size:1rem;color:var(--on-surface)}
.prayer-card.aktif{background:rgba(130,174,255,.2);border:2px solid rgba(130,174,255,.5);box-shadow:0 0 15px rgba(181,255,194,.2)}
.prayer-card.aktif .p-name{color:var(--primary)}
.prayer-card.berikutnya{background:rgba(253,144,0,.1);border:1px solid rgba(253,144,0,.3)}
.prayer-card.berikutnya .p-name{color:var(--secondary)}
.prayer-badge{position:absolute;top:-8px;left:50%;transform:translateX(-50%);font-size:8px;padding:2px 8px;border-radius:999px;font-weight:700;text-transform:uppercase;white-space:nowrap}
.prayer-card.aktif .prayer-badge{background:var(--primary);color:#00214d}
.prayer-card.berikutnya .prayer-badge{background:var(--secondary);color:#fff6f1}

/* Smart Controls */
.controls-grid{display:grid;grid-template-columns:1fr 1fr;gap:1rem}
.control-card{background:var(--surface);padding:1.25rem;border-radius:var(--radius-xl);border:1px solid rgba(68,72,79,.1)}
.control-top{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:1.25rem}
.control-icon{width:3rem;height:3rem;border-radius:var(--radius-md);display:flex;align-items:center;justify-content:center}
.control-icon.lamp{background:rgba(253,144,0,.1)}
.control-icon.lamp .material-symbols-outlined{color:var(--secondary)}
.control-icon.fan{background:rgba(130,174,255,.1)}
.control-icon.fan .material-symbols-outlined{color:var(--primary)}
.status-dot{width:8px;height:8px;border-radius:50%;transition:all .3s}
.status-dot.on{background:var(--tertiary);box-shadow:0 0 8px var(--tertiary)}
.status-dot.off{background:var(--outline);box-shadow:none}
.control-name{font-weight:700;font-size:1.1rem;margin-bottom:1rem}
.control-btns{display:flex;gap:.5rem}
.ctrl-btn{flex:1;padding:.5rem;border-radius:var(--radius-sm);font-weight:700;font-size:.75rem;border:none;cursor:pointer;transition:all .2s}
.ctrl-btn:active{transform:scale(.95)}
.ctrl-btn:disabled{opacity:.35;cursor:not-allowed}
.ctrl-btn.on-active{background:var(--tertiary-bright);color:#004820}
.ctrl-btn.on-idle{background:var(--surface-highest);color:var(--outline)}
.ctrl-btn.off-active{background:var(--error-container);color:var(--on-error-container)}
.ctrl-btn.off-idle{background:var(--surface-highest);color:var(--outline)}

/* Alarm Section */
.alarm-section{background:var(--surface-high);border-radius:calc(var(--radius-xl) + .5rem);padding:1.5rem;border:1px solid rgba(68,72,79,.2)}
.alarm-header{display:flex;align-items:center;gap:1rem;margin-bottom:1.5rem}
.alarm-icon-circle{width:2.5rem;height:2.5rem;border-radius:50%;background:rgba(130,174,255,.2);display:flex;align-items:center;justify-content:center}
.alarm-icon-circle .material-symbols-outlined{color:var(--primary);font-size:1.2rem}
.alarm-header h2{font-weight:700;font-size:1.1rem}
.alarm-time-display{display:flex;align-items:center;justify-content:center;gap:1rem;margin-bottom:1.5rem}
.alarm-time-display .big-digit{font-size:2.5rem;font-weight:800}
.alarm-time-display .colon{font-size:1.5rem;font-weight:700;color:var(--outline)}
.alarm-time-display .ampm{background:var(--surface-highest);padding:4px 12px;border-radius:var(--radius-sm);font-size:.75rem;font-weight:700;color:var(--primary)}
input[type="time"]{width:100%;background:var(--surface-highest);border:1px solid var(--outline-variant);border-radius:var(--radius-md);padding:.75rem 1rem;color:var(--on-surface);font-size:1.2rem;font-weight:700;font-family:'Plus Jakarta Sans';text-align:center;letter-spacing:2px;margin-bottom:1rem;transition:border .2s}
input[type="time"]:focus{outline:none;border-color:var(--primary);box-shadow:0 0 0 3px rgba(130,174,255,.15)}
input[type="time"]::-webkit-calendar-picker-indicator{filter:invert(.5);cursor:pointer}
.alarm-status-bar{display:flex;align-items:center;gap:.5rem;margin-bottom:1rem;padding:.75rem 1rem;background:var(--surface);border-radius:var(--radius-sm);font-size:.85rem;color:var(--on-surface-variant)}
.alarm-ring-dot{width:8px;height:8px;border-radius:50%;background:var(--outline);transition:all .3s;flex-shrink:0}
.alarm-ring-dot.aktif{background:var(--tertiary-bright);box-shadow:0 0 8px var(--tertiary-bright);animation:pulseDot 2s infinite}
@keyframes pulseDot{0%,100%{opacity:1;transform:scale(1)}50%{opacity:.5;transform:scale(.8)}}
.alarm-btns{display:grid;grid-template-columns:1fr 1fr;gap:.75rem}
.alarm-btn{padding:1rem;border-radius:var(--radius-md);font-weight:700;border:none;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:.5rem;transition:all .2s;font-family:'Plus Jakarta Sans';font-size:.9rem}
.alarm-btn:active{transform:scale(.95)}
.alarm-btn:disabled{opacity:.35;cursor:not-allowed}
.alarm-btn.set{background:var(--primary);color:#000}
.alarm-btn.off{background:#000;border:1px solid var(--outline-variant);color:var(--error)}

/* Schedule Tab */
.schedule-hero{position:relative;overflow:hidden;border-radius:var(--radius-xl);padding:2rem;border:1px solid rgba(255,255,255,.05)}
.schedule-hero .glass-bg{position:absolute;inset:0;backdrop-filter:blur(20px);background:linear-gradient(135deg,rgba(21,26,33,.7),rgba(15,20,26,.4))}
.schedule-hero .ghost-icon{position:absolute;top:0;right:0;padding:1rem;opacity:.1}
.schedule-hero .ghost-icon .material-symbols-outlined{font-size:6rem}
.schedule-hero .content{position:relative;z-index:1}
.schedule-hero .sub{font-size:.8rem;color:var(--on-surface-variant);font-weight:500;letter-spacing:.15em;text-transform:uppercase;margin-bottom:.5rem}
.schedule-hero .big-time{font-size:3.5rem;font-weight:800;letter-spacing:-.05em;line-height:1;margin-bottom:.75rem}
.schedule-hero .big-time .ampm{font-size:1.2rem;color:var(--primary);margin-left:.5rem;font-weight:700}
.schedule-status{display:flex;align-items:center;gap:.5rem;color:var(--tertiary)}
.schedule-status .material-symbols-outlined{font-size:1rem}
.schedule-status span{font-size:.85rem;font-weight:600}

/* Bottom Nav */
.bottom-nav{position:fixed;bottom:0;left:0;right:0;z-index:50;border-radius:var(--radius-xl) var(--radius-xl) 0 0;background:rgba(10,14,20,.9);backdrop-filter:blur(24px);box-shadow:0 -10px 40px rgba(0,0,0,.6);padding:0 2rem}
.bottom-nav .nav-inner{display:flex;justify-content:space-around;align-items:center;height:5.5rem;padding-bottom:1rem;max-width:480px;margin:0 auto}
.nav-item{display:flex;flex-direction:column;align-items:center;justify-content:center;color:var(--outline);opacity:.6;cursor:pointer;transition:all .3s;padding:.5rem 1.5rem;border-radius:var(--radius-md);border:none;background:none;font-family:'Plus Jakarta Sans'}
.nav-item:active{transform:scale(.9)}
.nav-item .material-symbols-outlined{margin-bottom:4px;font-size:1.4rem}
.nav-item .nav-label{font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.15em}
.nav-item.active{color:var(--primary);opacity:1;background:rgba(130,174,255,.1);box-shadow:0 0 20px rgba(130,174,255,.15)}

/* Animations */
@keyframes fadeIn{from{opacity:0;transform:translateY(16px)}to{opacity:1;transform:translateY(0)}}
.fade-in{animation:fadeIn .5s ease forwards}

/* Responsive */
@media(max-width:420px){
.clock-hero .time{font-size:3rem}
.schedule-hero .big-time{font-size:2.8rem}
}
</style>
</head>
'@

$part2 = @'
<body>
<!-- Top App Bar -->
<header class="top-bar">
<div class="top-bar-left">
<div class="avatar"><span class="material-symbols-outlined mat-filled">person</span></div>
<div class="top-bar-info">
<p class="label">Smart Kos</p>
<h1>Welcome back, Guest</h1>
</div>
</div>
<button class="notif-btn"><span class="material-symbols-outlined">notifications</span></button>
</header>

<main>
<!-- HOME TAB -->
<div class="tab-content active" id="tab-home">
<div class="section-gap">

<!-- Clock Hero -->
<section class="clock-hero fade-in">
<div class="glow"></div>
<div class="time">
<span class="digit-w"><span class="digit" id="d0">-</span></span><span class="digit-w"><span class="digit" id="d1">-</span></span><span class="sep">:</span><span class="digit-w"><span class="digit" id="d2">-</span></span><span class="digit-w"><span class="digit" id="d3">-</span></span><span class="sep">:</span><span class="digit-w"><span class="digit" id="d4">-</span></span><span class="digit-w"><span class="digit" id="d5">-</span></span>
</div>
<p class="date" id="tanggal">--</p>
</section>

<!-- Weather -->
<section class="glass fade-in" style="animation-delay:.1s" id="cuaca-section">
<div id="cuaca-content"><div class="weather-loading">Memuat data cuaca...</div></div>
</section>

<!-- Prayer Times -->
<section class="fade-in" style="animation-delay:.2s">
<div class="section-title" style="margin-bottom:.75rem">
<h2>Jadwal Sholat</h2>
<span>Surabaya, ID</span>
</div>
<div id="sholat-content"><div class="weather-loading">Memuat jadwal sholat...</div></div>
</section>

<!-- Smart Controls -->
<section class="fade-in" style="animation-delay:.3s">
<div class="section-title" style="margin-bottom:.75rem"><h2>Smart Controls</h2></div>
<div class="controls-grid">
<!-- Lampu -->
<div class="control-card">
<div class="control-top">
<div class="control-icon lamp"><span class="material-symbols-outlined mat-filled">lightbulb</span></div>
<div class="status-dot off" id="status-lampu-dot"></div>
</div>
<p class="control-name">Lampu</p>
<div class="control-btns">
<button class="ctrl-btn on-active" onclick="kirimLampu('ON')" id="btn-on" disabled>ON</button>
<button class="ctrl-btn off-idle" onclick="kirimLampu('OFF')" id="btn-off" disabled>OFF</button>
</div>
</div>
<!-- Kipas -->
<div class="control-card">
<div class="control-top">
<div class="control-icon fan"><span class="material-symbols-outlined">cyclone</span></div>
<div class="status-dot off" id="status-kipas-dot"></div>
</div>
<p class="control-name">Kipas</p>
<div class="control-btns">
<button class="ctrl-btn on-idle" onclick="kirimKipas('ON')" id="btn-kipas-on" disabled>ON</button>
<button class="ctrl-btn off-active" onclick="kirimKipas('OFF')" id="btn-kipas-off" disabled>OFF</button>
</div>
</div>
</div>
</section>

<!-- Alarm -->
<section class="alarm-section fade-in" style="animation-delay:.4s">
<div class="alarm-header">
<div class="alarm-icon-circle"><span class="material-symbols-outlined">alarm</span></div>
<h2>Morning Alarm</h2>
</div>
<div class="alarm-status-bar">
<div class="alarm-ring-dot" id="alarm-dot"></div>
<span id="alarm-status-text">Alarm Mati</span>
</div>
<input type="time" id="waktu-alarm" value="00:00">
<div class="alarm-btns">
<button class="alarm-btn set" onclick="setAlarm()" id="btn-set" disabled><span class="material-symbols-outlined" style="font-size:18px">check_circle</span> Set Alarm</button>
<button class="alarm-btn off" onclick="nonaktifkanAlarm()" id="btn-nonaktif" disabled><span class="material-symbols-outlined" style="font-size:18px">alarm_off</span> Matikan</button>
</div>
</section>

</div>
</div>

<!-- SCHEDULE TAB -->
<div class="tab-content" id="tab-schedule">
<div class="section-gap">

<!-- Next Alarm Hero -->
<section class="schedule-hero fade-in">
<div class="glass-bg"></div>
<div class="ghost-icon"><span class="material-symbols-outlined">alarm</span></div>
<div class="content">
<p class="sub">Next Alarm In</p>
<div class="big-time" id="schedule-alarm-time">--:--<span class="ampm">WIB</span></div>
<div class="schedule-status" id="schedule-alarm-status">
<span class="material-symbols-outlined mat-filled" style="font-size:14px">info</span>
<span>Belum ada alarm aktif</span>
</div>
</div>
</section>

<!-- Alarm Controls (Schedule Tab) -->
<section class="alarm-section fade-in" style="animation-delay:.1s">
<div class="alarm-header">
<div class="alarm-icon-circle"><span class="material-symbols-outlined">schedule</span></div>
<h2>Atur Alarm</h2>
</div>
<div class="alarm-status-bar">
<div class="alarm-ring-dot" id="alarm-dot-2"></div>
<span id="alarm-status-text-2">Alarm Mati</span>
</div>
<input type="time" id="waktu-alarm-2" value="00:00">
<div class="alarm-btns">
<button class="alarm-btn set" onclick="setAlarmFromSchedule()" id="btn-set-2" disabled><span class="material-symbols-outlined" style="font-size:18px">check_circle</span> Set Alarm</button>
<button class="alarm-btn off" onclick="nonaktifkanAlarmFromSchedule()" id="btn-nonaktif-2" disabled><span class="material-symbols-outlined" style="font-size:18px">alarm_off</span> Matikan</button>
</div>
</section>

</div>
</div>
</main>

<!-- Bottom Nav -->
<nav class="bottom-nav">
<div class="nav-inner">
<button class="nav-item active" onclick="switchTab('home')" id="nav-home">
<span class="material-symbols-outlined">home</span>
<span class="nav-label">Home</span>
</button>
<button class="nav-item" onclick="switchTab('schedule')" id="nav-schedule">
<span class="material-symbols-outlined">alarm</span>
<span class="nav-label">Schedule</span>
</button>
</div>
</nav>
'@

Set-Content -Path "index_new.html" -Value $part1 -Encoding UTF8 -NoNewline
Add-Content -Path "index_new.html" -Value $part2 -Encoding UTF8 -NoNewline
Write-Output "Parts 1-2 written."
