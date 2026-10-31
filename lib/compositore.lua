-- ANAMNESI · il compositore
-- Ogni luogo ha la sua musica: una tonica, un modo, una progressione,
-- un tempo e un gruppo di voci che entrano ed escono da sole.
-- Un tema attraversa tutto il viaggio e riaffiora dove meno te lo aspetti.
-- Ogni luogo ha tre macro sue. Nessuna cambia niente di colpo.

local C = {}

local floor, random, abs, min, max = math.floor, math.random, math.abs, math.min, math.max

-------------------------------------------------------------------------------
-- scale
-------------------------------------------------------------------------------
C.MODI = { "lidio", "ionio", "misolidio", "dorico", "eolio", "frigio", "locrio" }
local DIAT = {
  lidio     = { 0, 2, 4, 6, 7, 9, 11 },
  ionio     = { 0, 2, 4, 5, 7, 9, 11 },
  misolidio = { 0, 2, 4, 5, 7, 9, 10 },
  dorico    = { 0, 2, 3, 5, 7, 9, 10 },
  eolio     = { 0, 2, 3, 5, 7, 8, 10 },
  frigio    = { 0, 1, 3, 5, 7, 8, 10 },
  locrio    = { 0, 1, 3, 5, 6, 8, 10 },
}
local SPECIALI = {
  penta     = { 0, 2, 4, 7, 9 },
  penta_m   = { 0, 3, 5, 7, 10 },
  esatonale = { 0, 2, 4, 6, 8, 10 },
  hirajoshi = { 0, 2, 3, 7, 8 },
  quarti    = { 0, 0.5, 2, 3, 3.5, 6, 7, 7.5, 10 },
  cromatico = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 },
}
local MODO_IDX = {}
for i, n in ipairs(C.MODI) do MODO_IDX[n] = i end

local VOICINGS = {
  triade   = { 0, 2, 4 },
  add9     = { 0, 2, 4, 8 },
  sus2     = { 0, 1, 4 },
  quarte   = { 0, 3, 6, 9 },
  settima  = { 0, 2, 4, 6 },
  grappolo = { 0, 1, 2, 4 },
  aperto   = { 0, 4, 7, 9 },
}

local TERRENI = {
  erba = { 0.25, 0.14, 0.9, 0.22 }, ghiaia = { 0.75, 0.16, 1.0, 0.26 },
  pietra = { 0.5, 0.08, 1.4, 0.26 }, legno = { 0.35, 0.10, 1.8, 0.3 },
  neve = { 0.42, 0.28, 0.7, 0.26 }, sabbia = { 0.3, 0.2, 0.6, 0.18 },
  marmo = { 0.62, 0.06, 1.6, 0.24 }, acqua = { 0.62, 0.3, 0.5, 0.2 },
  vuoto = { 0.12, 0.3, 0.4, 0.07 }, piastrelle = { 0.55, 0.07, 1.5, 0.24 },
  foglie = { 0.6, 0.2, 0.8, 0.24 }, nuvola = { 0.2, 0.35, 0.3, 0.06 },
  moquette = { 0.15, 0.12, 0.8, 0.16 }, metallo = { 0.7, 0.05, 2.2, 0.22 },
}

-------------------------------------------------------------------------------
-- il tema: due frasi che tornano in ogni luogo, nel suo modo e nel suo tempo
-------------------------------------------------------------------------------
C.TEMA = {
  { { 0, 2 }, { 1, 1 }, { 2, 3 }, { 4, 2 }, { 3, 1 }, { 2, 2 }, { 1, 1 }, { 0, 5 } },
  { { 4, 2 }, { 5, 1 }, { 4, 1 }, { 2, 3 }, { 1, 1 }, { 0, 2 }, { -1, 1 }, { 0, 6 } },
  { { 2, 2 }, { 1, 2 }, { 0, 2 }, { -1, 1 }, { -3, 1 }, { -2, 6 } },
}

-------------------------------------------------------------------------------
-- macro: ogni luogo ne sceglie tre
-- bip = bipolare (la metà è neutra); i valori arrivano sempre da 0 a 1
-------------------------------------------------------------------------------
local function add(t, k, v) t[k] = (t[k] or 0) + v end
local function mul(t, k, v) t[k] = (t[k] or 0) * v end

C.MACRO = {
  luce = { { "luce", "light" }, { "ombra", "shadow" }, bip = true, fn = function(P, v)
    P.k.shift = P.k.shift - v * 2.4
    mul(P.d, "cut", 2 ^ (v * 1.3)); add(P.d, "air", max(0, v) * 0.25); add(P.d, "sub", max(0, -v) * 0.3)
    add(P.f, "shimmer", v * 0.35); add(P.f, "dark", max(0, -v) * 0.35); P.v.gain = P.v.gain * (1 + v * 0.12)
  end },
  respiro = { { "respiro", "breath" }, { "sospeso", "suspended" }, bip = true, fn = function(P, v)
    P.k.dens = P.k.dens * 2 ^ (v * 1.25); P.k.bpm = P.k.bpm * (1 + v * 0.18)
    add(P.f, "rev", -v * 0.1); add(P.d, "breath", -v * 0.2)
  end },
  fragilita = { { "fragilità", "fragility" }, fn = function(P, v)
    add(P.f, "tape", v * 0.65); add(P.f, "age", v * 0.35); add(P.f, "hiss", v * 0.8); add(P.t, "crackle", v * 0.22)
    add(P.d, "detune", v * 0.6); add(P.d, "wob", v * 0.6); P.k.frag = P.k.frag + v
    add(P.f, "crush", max(0, v - 0.65) * 1.2)
  end },
  vento = { { "vento", "wind" }, fn = function(P, v) add(P.t, "wind", v * 0.8); add(P.d, "air", v * 0.2); P.v.wind = v end },
  pioggia = { { "pioggia", "rain" }, fn = function(P, v) add(P.t, "rain", v * 0.8); add(P.t, "drip", v * 0.25); add(P.f, "dark", v * 0.12); P.v.rain = v end },
  mare = { { "mare", "sea" }, fn = function(P, v) add(P.t, "sea", v * 0.8); add(P.d, "breath", v * 0.3); P.v.sea = v end },
  fuoco = { { "fuoco", "fire" }, fn = function(P, v) add(P.t, "fire", v * 0.7); mul(P.d, "cut", 1 - v * 0.2); add(P.d, "shape", v * 0.1); P.v.fire = v end },
  notte = { { "notte", "night" }, fn = function(P, v)
    add(P.t, "crick", v * 0.45); add(P.t, "owl", v * 0.5); add(P.f, "dark", v * 0.2); P.k.dens = P.k.dens * (1 - v * 0.3)
    P.v.gain = P.v.gain * (1 - v * 0.35); P.v.night = v
  end },
  nebbia = { { "nebbia", "fog" }, fn = function(P, v)
    add(P.f, "dark", v * 0.3); add(P.f, "rev", v * 0.2); add(P.f, "size", v * 0.08); mul(P.d, "cut", 1 - v * 0.4); P.v.fog = v
  end },
  distanza = { { "lontano", "far" }, { "vicino", "near" }, bip = true, fn = function(P, v)
    add(P.f, "rev", v * 0.3); add(P.f, "dark", max(0, v) * 0.3); P.k.amp = P.k.amp * (1 - max(0, v) * 0.35); add(P.f, "size", v * 0.1)
  end },
  battito = { { "battito", "heartbeat" }, fn = function(P, v)
    add(P.t, "heart", v * 0.7); P.sp.hrate = P.sp.hrate * (1 + v * 0.8); P.k.pulse = P.k.pulse + v
  end },
  voci = { { "voci", "voices" }, fn = function(P, v) add(P.t, "voices", v * 0.6); P.k.whisper = P.k.whisper + v end },
  campane = { { "campane", "bells" }, fn = function(P, v) P.k.bells = P.k.bells + v; P.v.bells = v end },
  stelle = { { "stelle", "stars" }, fn = function(P, v) P.k.spark = P.k.spark + v; add(P.f, "shimmer", v * 0.4); P.v.stars = v end },
  coro = { { "coro", "choir" }, fn = function(P, v) P.k.choir = P.k.choir + v end },
  archi = { { "archi", "strings" }, fn = function(P, v) P.k.strings = P.k.strings + v end },
  profondita = { { "profondità", "depth" }, fn = function(P, v)
    add(P.d, "sub", v * 0.5); P.k.oct = P.k.oct - v * 1.5; add(P.f, "dark", v * 0.15); mul(P.d, "cut", 1 - v * 0.3)
  end },
  eco = { { "eco", "echo" }, fn = function(P, v) add(P.f, "echo", v * 0.8); add(P.f, "efb", v * 4) end },
  tempo = { { "più svelto", "faster" }, { "più lento", "slower" }, bip = true, fn = function(P, v) P.k.bpm = P.k.bpm * 2 ^ (v * 0.5) end },
  silenzio = { { "silenzio", "silence" }, fn = function(P, v)
    P.k.dens = P.k.dens * (1 - v * 0.85); mul(P.d, "amp", 1 - v * 0.5); P.k.texmul = P.k.texmul * (1 - v * 0.5); add(P.f, "rev", v * 0.15)
  end },
  nevrosi = { { "nevrosi", "neurosis" }, fn = function(P, v)
    P.k.glitch = P.k.glitch + v; add(P.f, "crush", v * 0.3); add(P.f, "tape", v * 0.4); add(P.d, "detune", v * 0.8)
    add(P.t, "heart", v * 0.35); P.sp.hrate = P.sp.hrate * (1 + v); P.k.pulse = P.k.pulse + v * 0.7; P.v.shake = v
  end },
  calore = { { "caldo", "warm" }, { "freddo", "cold" }, bip = true, fn = function(P, v)
    add(P.d, "shape", v * 0.25); mul(P.d, "cut", 2 ^ (v * 0.6)); add(P.f, "shimmer", -v * 0.2); add(P.f, "damp", v * 0.2)
  end },
  infanzia = { { "infanzia", "childhood" }, fn = function(P, v)
    P.k.doubling = P.k.doubling + v; add(P.f, "age", v * 0.3); add(P.f, "tape", v * 0.25); add(P.t, "crackle", v * 0.1)
  end },
  radio = { { "radio", "radio" }, fn = function(P, v) add(P.t, "radio", v * 0.6); add(P.f, "age", v * 0.2) end },
  folla = { { "gente", "people" }, fn = function(P, v) add(P.t, "crowd", v * 0.7); P.v.crowd = v end },
  lacrime = { { "lacrime", "tears" }, fn = function(P, v)
    P.k.strings = P.k.strings + v * 0.8; add(P.f, "rev", v * 0.15); add(P.d, "breath", v * 0.3); P.k.dens = P.k.dens * (1 - v * 0.2)
  end },
  treno = { { "treno", "train" }, fn = function(P, v) add(P.t, "train", v * 0.7) end },
  foglie = { { "foglie", "leaves" }, fn = function(P, v) add(P.t, "leaves", v * 0.7); add(P.t, "wind", v * 0.2); P.v.wind = v end },
  tormento = { { "tormento", "torment" }, fn = function(P, v)
    -- il dolore che si sente: rumore, fischio, stridore, accordi che battono
    add(P.t, "noise", v * 0.9); add(P.t, "static", v * 0.6); add(P.t, "tinnitus", max(0, v - 0.3) * 0.9)
    add(P.t, "shriek", max(0, v - 0.5) * 0.9); P.k.torment = (P.k.torment or 0) + v
    add(P.f, "crush", v * 0.15); add(P.d, "detune", v * 0.7); add(P.d, "wob", v * 0.4); mul(P.d, "cut", 1 - v * 0.3)
    P.k.dens = P.k.dens * (1 - v * 0.25); P.v.shake = (P.v.shake or 0) + v * 0.6
  end },
  vetro = { { "vetro", "glass" }, fn = function(P, v)
    P.k.glass = (P.k.glass or 0) + v; add(P.f, "shimmer", v * 0.3); add(P.f, "rev", v * 0.1)
  end },
  macchine = { { "macchine", "machines" }, fn = function(P, v)
    add(P.t, "machine", v * 0.9); add(P.d, "shape", v * 0.2); P.k.pulse = P.k.pulse + v * 0.5
  end },
  ricordo = { { "ricordo", "memory" }, fn = function(P, v) P.k.tema = P.k.tema + v * 0.5; add(P.f, "echo", v * 0.3); add(P.f, "age", v * 0.15) end },
}

-------------------------------------------------------------------------------
-- stato
-------------------------------------------------------------------------------
C.mt = { 0.5, 0.5, 0.5 }      -- le tre macro del luogo (obiettivi, 0..1)
C.mc = { 0.5, 0.5, 0.5 }      -- valori correnti
C.at, C.ac = 0, 0             -- ora / allora
C.spazio = 0
C.vol = 0.8
C.tick_n = 0
C.bpm = 60
C.bpm_t = 60
C.lines = {}
C.pending = {}
C.voices = {}
C.travelling = false
C.chord_i = 1
C.chord = { 0, 2, 4 }
C.chord_root = 0
C.hooks = { note = function() end }
C.sent = {}
C.max_voices = 12
C.fade_in = 0
C.mode_shift = 0
C.vis = { gain = 1 }
C.k = {}
C.mac = {}

local function clamp(x, a, b) return x < a and a or (x > b and b or x) end
local function pick(t) return t[random(#t)] end
local function mtof(m) return 440 * 2 ^ ((m - 69) / 12) end
local function copy(t) local o = {} for k, v in pairs(t or {}) do o[k] = v end return o end
C.mtof = mtof

local function send(cmd, key, v)
  local k = cmd .. key
  local old = C.sent[k]
  if old == nil or abs(old - v) > (abs(v) * 0.004 + 0.0005) then
    C.sent[k] = v
    engine[cmd](key, v)
  end
end

-------------------------------------------------------------------------------
-- scala e accordi
-------------------------------------------------------------------------------
function C.scala()
  local p = C.prof
  if SPECIALI[p.modo] then return SPECIALI[p.modo] end
  local i = (MODO_IDX[p.modo] or 2) + C.mode_shift
  return DIAT[C.MODI[clamp(i, 1, 7)]]
end

local function deg2semi(deg, sc)
  local n = #sc
  local o = floor(deg / n)
  local i = deg - o * n
  return sc[i + 1] + 12 * o
end
C.deg2semi = deg2semi

local function chord_from(rootdeg, voicing)
  local v = VOICINGS[voicing] or VOICINGS.triade
  local t = {}
  for i, o in ipairs(v) do t[i] = rootdeg + o end
  return t
end

local function euclid(k, n, rot)
  local t = {}
  k = clamp(floor(k), 0, n)
  for i = 0, n - 1 do t[((i + (rot or 0)) % n) + 1] = ((i * k) % n) < k end
  return t
end

-------------------------------------------------------------------------------
-- motivi
-------------------------------------------------------------------------------
local STEPS = { -2, -1, -1, -1, 0, 1, 1, 1, 2, 2, 3, -3, 4 }
local LENS = { 1, 2, 2, 2, 3, 4, 4, 6 }

local function gen_motif(lens)
  local n = random(3, 6)
  local m, d = {}, 0
  for i = 1, n do
    if i > 1 then d = d + pick(STEPS) end
    m[i] = { d = d, len = pick(lens or LENS) }
  end
  -- quasi sempre il motivo torna a casa
  if random() < 0.6 then m[n].d = pick({ 0, 0, 2, -1 }); m[n].len = max(m[n].len, 3) end
  return m
end

local function realize(line)
  local out = {}
  -- il tema conduttore
  local pt = (C.prof.tema or 0.16) + (C.k.tema or 0)
  if line.ruolo == "melodia" and random() < pt then
    local th = C.TEMA[random(#C.TEMA)]
    local stretch = (line.lens and line.lens[1] == 1) and 1 or pick({ 1, 1, 2 })
    for i, e in ipairs(th) do out[i] = { deg = e[1], len = e[2] * stretch } end
    line.theme = true
    -- sotto il tema, gli archi si alzano piano
    C.glow = 1
    return out
  end
  line.theme = false
  local mot = line.motif
  local r = random()
  local inv = r < 0.15
  local retro = r > 0.9
  local base = C.chord_root + pick({ 0, 0, 2, 4 }) - (C.chord_root > 3 and 7 or 0)
  for i = 1, #mot do
    local e = retro and mot[#mot - i + 1] or mot[i]
    out[#out + 1] = { deg = base + (inv and -e.d or e.d), len = e.len }
  end
  if random() < 0.25 and #out > 1 then
    local k = random(1, #out - 1)
    table.insert(out, k + 1, { deg = out[k].deg + pick({ -1, 1 }), len = 1 })
  end
  if random() < 0.12 then
    local k = random(#mot)
    mot[k].d = mot[k].d + pick({ -1, 1 })
  end
  -- l'appoggiatura: l'ultima nota arriva dall'alto, come un sospiro
  local last = out[#out]
  if last and last.len >= 3 and random() < 0.4 then
    out[#out] = { deg = last.deg + 1, len = 1, app = true }
    out[#out + 1] = { deg = last.deg, len = last.len - 1 + 1, fine = true }
  elseif last then
    last.fine = true
  end
  return out
end

-------------------------------------------------------------------------------
-- voci
-------------------------------------------------------------------------------
local function prune_voices()
  local t = C.tick_n
  local j = 1
  for i = 1, #C.voices do
    if C.voices[i] > t then C.voices[j] = C.voices[i]; j = j + 1 end
  end
  for i = j, #C.voices do C.voices[i] = nil end
end

function C.play(inst, midi, amp, dur, pan, bright, atk, prio)
  prune_voices()
  if #C.voices >= C.max_voices and (prio or 0) < 1 then return false end
  local frag = C.k.frag or 0
  local det = frag * 1.2 + random() * 0.2
  if random() < frag * 0.35 then midi = midi + (random() * 2 - 1) * frag * 0.45 end
  local f = mtof(midi)
  if inst == "pluck" or inst == "guitar" then f = max(f, 40) end
  bright = clamp((bright or 0.5) + (C.k.bright or 0) - C.ac * 0.2, 0, 1)
  amp = amp * C.fade_in * (C.k.amp or 1)
  if amp < 0.002 then return false end
  engine.note(inst, f, amp, dur, clamp(pan or 0, -1, 1), bright, atk or 0.005, det)
  local rel = (inst == "choir" or inst == "bowed" or inst == "strings") and (atk or 1) * 1.8 or 0.5
  C.voices[#C.voices + 1] = C.tick_n + floor((dur + (atk or 0) + rel) / C.tickdur()) + 1
  return true
end

function C.sfx(inst, freq, amp, dur, pan, bright, atk)
  engine.note(inst, freq, amp, dur, clamp(pan or 0, -1, 1), bright or 0.5, atk or 0.005, C.k.frag or 0)
end

function C.step(terrain, pan, weight)
  local t = TERRENI[terrain] or TERRENI.pietra
  engine.note("step", t[3] * (0.9 + random() * 0.2), t[4] * (weight or 1) * (0.8 + random() * 0.4),
    t[2] * (0.85 + random() * 0.3), pan or 0, t[1], 0, 0)
end

function C.tickdur() return 30 / C.bpm end

local function note_of(line, deg)
  local sc = C.scala()
  local semi = deg2semi(deg, sc)
  local sp = C.prof.speciale or {}
  if sp.nota_sbagliata and line.ruolo == "melodia" and (deg % #sc) == 3 and random() < 0.5 then
    semi = semi + 1
  end
  local oct = (line.ott or 0)
  if line.ruolo == "melodia" or line.ruolo == "arpeggio" or line.ruolo == "scintille" then
    oct = oct + floor((C.k.oct or 0) + 0.5)
    if C.climax and line.ruolo == "melodia" and random() < 0.3 then oct = oct + 1 end
  end
  return C.prof.tonica + 12 * oct + semi
end

local function voice(line, deg, len_ticks, ampmul, prio)
  local sp = C.prof.speciale or {}
  if not line.theme and random() < (C.k.frag or 0) * 0.2 + (sp.oblio or 0) then return end
  local midi = note_of(line, deg)
  if line.ruolo == "melodia" and C.ac > 0.3 and random() < C.ac * 0.6 then
    local dur = max(0.3, len_ticks * C.tickdur() * 2.2)
    C.play("musicbox", midi + 12, line.amp * line.pres * (ampmul or 1) * 0.75, dur, (line.pan or 0) * 0.5, 0.35, 0.001, prio)
    C.hooks.note({ ruolo = line.ruolo, str = "musicbox", deg = deg, midi = midi + 12, amp = line.amp, pan = 0, dur = dur, tema = line.theme })
    return
  end
  local dur = max(0.08, len_ticks * C.tickdur() * (line.legato or 1.5))
  local amp = line.amp * line.pres * (ampmul or 1) * (0.82 + random() * 0.3) * (line.gain or 1)
  local pan = (line.pan or 0) + (random() - 0.5) * (line.spread or 0.5)
  local ok = C.play(line.str, midi, amp, dur, pan, line.bright, line.atk, prio)
  if not ok then return end
  C.hooks.note({ ruolo = line.ruolo, str = line.str, deg = deg, midi = midi, amp = amp, pan = pan, dur = dur, tema = line.theme })
  if line.ruolo == "melodia" and (line.str == "piano" or line.str == "rhodes") and random() < 0.14 then
    C.later(2, function() C.play(line.str, midi + 12, amp * 0.28, dur * 0.6, -pan, 0.2, 0.004) end)
  end
  -- e sotto, una voce che canticchia la stessa nota, piano, quando il luogo è pieno
  if line.ruolo == "melodia" and (C.life or 0) > 0.85 and random() < 0.3 then
    C.play("hum", midi - 12, amp * 0.35, dur * 1.2, pan * 0.5, 0.2, 0.3)
  end
  -- eco del ricordo: un carillon che raddoppia la melodia
  if line.ruolo == "melodia" and random() < (C.ac * 0.45 + (C.k.doubling or 0) * 0.5) then
    C.later(1, function() C.play("musicbox", midi + 12, amp * 0.45, 3, -pan, 0.3, 0.001) end)
  end
  if random() < (C.k.frag or 0) * 0.18 then
    local reps = random(1, 3)
    clock.run(function()
      for r = 1, reps do
        clock.sleep(C.tickdur() * 0.5)
        C.play(line.str, midi, amp * (0.6 / r), dur * 0.5, pan, line.bright, 0.002)
      end
    end)
  end
end

function C.later(ticks, fn)
  local t = C.tick_n + max(1, floor(ticks))
  C.pending[t] = C.pending[t] or {}
  table.insert(C.pending[t], fn)
end

-------------------------------------------------------------------------------
-- ruoli
-------------------------------------------------------------------------------
local R = {}

R.melodia = function(line, ctx)
  if line.wait > 0 then line.wait = line.wait - 1; return end
  if not line.phrase then
    if random() < line.prob * ctx.dens * 0.6 then
      line.phrase = realize(line)
      line.pi = 1
    else
      line.wait = random(1, 4)
      return
    end
  end
  local ev = line.phrase[line.pi]
  local n = #line.phrase
  local pos = n > 1 and (line.pi - 1) / (n - 1) or 0.5
  local arc = 0.72 + 0.5 * math.sin(math.pi * min(1, pos * 1.15))
  if ev.app then arc = arc * 1.12 elseif ev.fine then arc = arc * 0.85 end
  local lenmul = ev.fine and 1.6 or 1
  local late = (line.pi > 1 and random() < 0.6) and random() * 0.06 or 0
  if ev.fine then late = late + 0.05 + random() * 0.08 end
  if late > 0.005 then
    local d, l = ev.deg, ev.len * lenmul
    clock.run(function() clock.sleep(late); voice(line, d, l, arc) end)
  else
    voice(line, ev.deg, ev.len * lenmul, arc)
  end
  line.wait = ev.len - 1
  line.pi = line.pi + 1
  if line.pi > #line.phrase then
    line.phrase = nil
    -- dopo il tema, un silenzio più lungo: lascia il tempo di sentirlo
    local extra = line.theme and 8 or 0
    line.wait = floor((random(3, 12) + (line.riposo or 4) + extra) / clamp(ctx.dens, 0.3, 2.5))
    -- a volte un'altra voce risponde
    if C.answer and C.answer ~= line and random() < 0.35 then C.answer.wait = 0; C.answer.call = true end
  end
end

R.risposta = function(line, ctx)
  if line.call then
    line.call = false
    line.phrase = realize(line); line.pi = 1; line.wait = 2
  end
  if not line.phrase then return end
  if line.wait > 0 then line.wait = line.wait - 1; return end
  local ev = line.phrase[line.pi]
  voice(line, ev.deg + 2, ev.len, 0.8)
  line.wait = ev.len - 1
  line.pi = line.pi + 1
  if line.pi > #line.phrase then line.phrase = nil end
end

R.arpeggio = function(line, ctx)
  if ctx.chord_start or not line.pat then
    local steps = ctx.bar
    local k = clamp(floor((line.prob * 5 + 1) * ctx.dens), 1, steps - 1)
    line.pat = euclid(k, steps, random(0, 3))
    line.tones = {}
    for _, d in ipairs(C.chord) do line.tones[#line.tones + 1] = d end
    for _, d in ipairs(C.chord) do line.tones[#line.tones + 1] = d + #C.scala() end
    line.idx = line.idx or 1
    line.dir = pick({ 1, 1, -1 })
  end
  local pos = (ctx.tick % ctx.bar) + 1
  if line.pat[pos] and random() < 0.55 + ctx.dens * 0.25 then
    local n = #line.tones
    voice(line, line.tones[((line.idx - 1) % n) + 1], 2)
    line.idx = line.idx + line.dir
    if random() < 0.1 then line.dir = -line.dir end
  end
end

R.lamento = function(line, ctx)
  if ctx.chord_start and not line.lam and random() < line.prob then line.lam = 0 end
  if line.lam then
    local step = max(2, floor(ctx.chord_len / 2))
    if line.lam % step == 0 then
      local k = floor(line.lam / step)
      voice(line, -k, step * 1.1, 1 - k * 0.12)
      if k >= 3 then line.lam = nil; return end
    end
    line.lam = line.lam + 1
  end
end

R.basso = function(line, ctx)
  if ctx.chord_start then
    if random() < line.prob + 0.3 then voice(line, C.chord_root, ctx.chord_len * 0.9, 1, 1) end
  elseif ctx.tick % ctx.chord_len == floor(ctx.chord_len / 2) and random() < line.prob * 0.35 * ctx.dens then
    voice(line, C.chord_root + 4, ctx.chord_len * 0.4)
  end
end

R.accordo = function(line, ctx)
  if not ctx.chord_start then return end
  if random() > line.prob + 0.25 then return end
  local n = min(line.voci or 3, #C.chord)
  if C.climax then n = min(n + 1, #C.chord) end
  local order = {}
  for i = 1, #C.chord do order[i] = C.chord[i] end
  local sus = random() < 0.28 and not line.extra
  for i = 1, n do
    local d = table.remove(order, random(#order))
    local off = (i - 1) * random(1, 3)
    if sus and d == C.chord_root + 2 then
      local half = floor(ctx.chord_len * 0.45)
      C.later(off + 0.1, function() voice(line, d + 1, half, 0.85) end)
      C.later(off + half, function() voice(line, d, ctx.chord_len * 1.05 - half, 0.75) end)
    else
      C.later(off + 0.1, function() voice(line, d, ctx.chord_len * 1.05, 0.8) end)
    end
  end
end

R.scintille = function(line, ctx)
  if random() < line.prob * ctx.dens * 0.18 then
    voice(line, pick(C.chord) + pick({ 0, #C.scala() }), 2, 0.8)
  end
end

R.coppa = function(line, ctx)
  if ctx.tick % ctx.bar == 0 and random() < line.prob * 0.35 * ctx.dens then
    voice(line, C.chord_root + pick({ 0, 0, 4, 2 }), 12, 1, 1)
  end
end

R.campane = function(line, ctx)
  if ctx.chord_start and not line.peal and random() < line.prob then
    line.peal = random(2, 4) * ctx.bar
    line.pidx = 0
  end
  if line.peal then
    if ctx.tick % 2 == 0 then
      local n = #C.scala()
      local d = (n - 1) - (line.pidx % n)
      voice(line, d, 6, 1 - (line.pidx % n) * 0.06)
      line.pidx = line.pidx + 1
    end
    line.peal = line.peal - 1
    if line.peal <= 0 then line.peal = nil end
  end
end

R.pulsazione = function(line, ctx)
  if ctx.tick % ctx.bar == 0 or not line.pat then
    local k = clamp(floor(line.prob * ctx.bar * ctx.dens), 1, ctx.bar)
    line.pat = euclid(k, ctx.bar, random(0, ctx.bar - 1))
    line.note = C.chord_root + pick({ 0, 0, 1, 4 })
  end
  if line.pat[(ctx.tick % ctx.bar) + 1] then
    voice(line, line.note, 1, 0.7 + random() * 0.4)
    if random() < 0.25 + (C.k.frag or 0) * 0.3 then
      clock.run(function()
        clock.sleep(C.tickdur() * 0.5)
        voice(line, line.note + pick({ 0, 1 }), 1, 0.5)
      end)
    end
  end
end

R.sussurri = function(line, ctx)
  if random() < line.prob * ctx.dens * 0.12 then voice(line, pick(C.chord), random(2, 5), 1) end
end

R.schegge = function(line, ctx)
  if random() < line.prob * ctx.dens * 0.12 then voice(line, pick(C.chord) + random(-3, 7), 1, 1) end
end

R.onde = function(line, ctx)
  local to = ctx.chord_len - (ctx.tick % ctx.chord_len)
  if to == line.onda_len and random() < line.prob * ctx.dens then
    local nextc = C.next_chord()
    voice(line, pick(nextc), line.onda_len * 1.0 / (line.legato or 1.5), 1)
  end
  if ctx.chord_start then line.onda_len = random(4, 10) end
end

-------------------------------------------------------------------------------
-- progressione
-------------------------------------------------------------------------------
function C.next_chord()
  local p = C.prof
  local i = (C.chord_i % #p.prog) + 1
  return chord_from(p.prog[i] - 1, p.accordo)
end

local function set_drone_chord()
  local p = C.prof
  local sc = C.scala()
  local root = C.chord_root
  local ped = p.pedale
  local t = p.tonica
  local f1 = t - 12 + (ped and 0 or deg2semi(root, sc))
  if f1 > t - 5 then f1 = f1 - 12 end
  local f2 = t - 12 + deg2semi((ped and 0 or root) + 4, sc)
  local c = C.chord
  local f3 = t + deg2semi(c[2] or root + 2, sc)
  local f4 = t + deg2semi(c[#c] or root + 4, sc)
  if f4 - f3 < 3 then f4 = f4 + 12 end
  local o = 12 * (p.drone_ott or 0)
  engine.drone("f1", mtof(f1 + o))
  engine.drone("f2", mtof(f2 + o))
  engine.drone("f3", mtof(f3 + o))
  engine.drone("f4", mtof(f4 + o))
end

local function advance_chord()
  local p = C.prof
  C.chord_i = (C.chord_i % #p.prog) + 1
  if random() < (p.sosta or 0.15) then C.chord_i = max(1, C.chord_i - 1) end
  C.chord_root = p.prog[C.chord_i] - 1
  C.chord = chord_from(C.chord_root, p.accordo)
  set_drone_chord()
end

-------------------------------------------------------------------------------
-- il battito
-------------------------------------------------------------------------------
function C.tick()
  local p = C.prof
  if not p then return end
  C.tick_n = C.tick_n + 1
  local t = C.tick_n
  local bar = (p.metro or 4) * 2
  local chord_len = bar * (p.battute or 2)
  local local_t = t - C.t0

  local pend = C.pending[t]
  if pend then
    for _, f in ipairs(pend) do f() end
    C.pending[t] = nil
  end

  local chord_start = (local_t % chord_len) == 0
  if chord_start and local_t > 0 then advance_chord() end

  -- l'arco del luogo: si apre, arriva al culmine, si svuota fino al silenzio
  local arc = (p.arco or 360)
  local life = 0.6 + 0.4 * math.sin(2 * math.pi * local_t / arc + 0.6)
  C.climax = life > 0.94
  C.life = life

  local k = C.k
  local dens = (p.densita or 1) * (k.dens or 1) * life * (1 - C.ac * 0.2)
  if C.travelling then dens = dens * 0.25 end

  if t % bar == 0 then
    local any = false
    for _, l in ipairs(C.lines) do
      if not l.extra then
        if random() < 0.07 then l.on = random() < (0.35 + l.prob * 0.6) end
        if l.on and l.ruolo ~= "scintille" then any = true end
      end
    end
    if not any and #C.lines > 0 then
      local l = C.lines[random(#C.lines)]
      if not l.extra then l.on = true end
    end
  end

  -- le voci evocate dalle macro
  C.glow = max(0, (C.glow or 0) - 0.006)
  local st = C.place and C.place.strato or 0
  if st <= -2 and not C.travelling then
    local base = (st == -2) and 0.08 or 0.16
    k.torment = (k.torment or 0) + base + max(0, (life - 0.85)) * 2.5 * (st == -3 and 1 or 0.6)
  end
  local swell = C.travelling and 0 or clamp((life - 0.8) * 3.5, 0, 0.75)
  for _, l in ipairs(C.lines) do
    if l.extra then
      local v = k[l.extra] or 0
      if l.extra == "strings" then
        local sw = (C.place and C.place.strato or 0) <= -2 and swell * 0.4 or swell
        v = max(v, sw, (C.glow or 0) * 0.45, C.bridge or 0)
      end
      if l.extra == "choir" then v = max(v, clamp((life - 0.9) * 4, 0, 0.35)) end
      l.on = v > 0.05
      l.gain = clamp(v, 0, 1.5)
    end
  end

  local ctx = { tick = local_t, bar = bar, chord_len = chord_len, chord_start = chord_start, dens = dens }
  for _, l in ipairs(C.lines) do
    local target = l.on and 1 or 0
    l.pres = l.pres + (target - l.pres) * (l.extra and 0.15 or 0.03)
    if l.extra then
      if l.on and not l.was_on and R[l.ruolo] then
        -- l'entrata: chi è chiamato da una manopola si fa sentire subito
        l.pres = max(l.pres, 0.5)
        local c2 = { tick = ctx.tick, bar = ctx.bar, chord_len = ctx.chord_len, chord_start = true, dens = max(1, ctx.dens) }
        R[l.ruolo](l, c2)
      end
      l.was_on = l.on
    end
    if l.pres > 0.02 then
      local f = R[l.ruolo]
      if f then f(l, ctx) end
    end
  end

  if C.fade_in < 1 then C.fade_in = min(1, C.fade_in + 0.02) end
  C.bridge = max(0, (C.bridge or 0) - 0.005)
  C.bpm = C.bpm + (C.bpm_t * (k.bpm or 1) * (1 - C.ac * 0.1) - C.bpm) * 0.03
end

-------------------------------------------------------------------------------
-- parametri continui
-------------------------------------------------------------------------------
local TEXN = { "rain", "wind", "sea", "fire", "crick", "cicada", "birds", "hum", "clock", "heart", "drip",
  "voices", "crowd", "rumble", "crackle", "stream", "bubble", "train", "city", "copier", "leaves", "frogs",
  "owl", "storm", "swallows", "cowbells", "typewriter", "breath", "radio", "arcade",
  "noise", "tinnitus", "static", "machine", "shriek" }
C.TEXN = TEXN

function C.macro_def(i)
  local p = C.place
  if not p or not p.macro then return nil end
  return C.MACRO[p.macro[i]]
end

function C.update(dt)
  -- le macro inseguono il loro obiettivo con calma
  for i = 1, 3 do
    local d = C.mt[i] - C.mc[i]
    local s = 0.45 * dt
    C.mc[i] = abs(d) <= s and C.mt[i] or C.mc[i] + (d > 0 and s or -s)
  end
  do
    local d = C.at - C.ac
    local s = 0.3 * dt
    C.ac = abs(d) <= s and C.at or C.ac + (d > 0 and s or -s)
  end
  local p = C.prof
  if not p then return end

  local P = {
    d = copy(p.drone), t = copy(p.tex), f = copy(p.fx), sp = copy(p.speciale), v = { gain = 1 },
    k = { dens = 1, bpm = 1, shift = 0, frag = 0, oct = 0, glitch = 0, bells = 0, choir = 0, strings = 0,
      spark = 0, whisper = 0, pulse = 0, doubling = 0, tema = 0, amp = 1, texmul = 1, bright = 0 },
  }
  P.sp.hrate = P.sp.hrate or 1.05
  P.d.amp = P.d.amp or 0.4; P.d.cut = P.d.cut or 900
  P.f.efb = P.f.efb or 3; P.f.etime = P.f.etime or 0.45

  C.mac = {}
  for i = 1, 3 do
    local id = p.macro and p.macro[i]
    local M = id and C.MACRO[id]
    if M then
      local v = C.mc[i]
      if M.bip then v = v * 2 - 1 end
      M.fn(P, v)
      C.mac[id] = v
      if id == "luce" then P.k.bright = v * 0.3 end
    end
  end
  -- negli strati più bassi il dolore c'è sempre, sotto, e al culmine sale
  local stv = C.place and C.place.strato or 0
  if stv <= -2 and not C.travelling then
    local peak = max(0, (C.life or 0.6) - 0.85) * 4
    local base = (stv == -2) and 0.05 or 0.1
    add(P.t, "noise", base + peak * 0.35); add(P.t, "static", peak * 0.25)
    if stv == -3 then add(P.t, "tinnitus", peak * 0.4) end
  end
  -- ora / allora
  local a = C.ac
  -- allora: il ricordo com'era. Un nastro consumato, un disco che gracchia,
  -- tutto più lento, più lontano, e un carillon che rifà la melodia.
  add(P.f, "age", a * 0.55); add(P.f, "tape", a * 0.55); add(P.t, "crackle", a * 0.4); add(P.f, "hiss", a * 0.35)
  add(P.f, "rev", a * 0.18); add(P.f, "dark", a * 0.3); mul(P.d, "cut", 1 - a * 0.45)
  P.k.bpm = P.k.bpm * (1 - a * 0.14); P.k.doubling = P.k.doubling + a * 0.6; P.k.tema = P.k.tema + a * 0.15
  -- un poco più avvolgente, sempre
  add(P.f, "rev", 0.04); add(P.d, "breath", 0.05)
  add(P.f, "rev", C.spazio); add(P.f, "size", C.spazio * 0.4)
  C.k = P.k
  C.vis = P.v

  local ms = floor(P.k.shift + 0.5)
  if not SPECIALI[p.modo] then C.mode_shift = ms end

  local d = P.d
  local trav = C.travelling and 0.75 or 1
  send("drone", "amp", clamp(d.amp * trav * min(1, C.fade_in * 1.5 + 0.2) * P.k.amp, 0, 1))
  send("drone", "cut", clamp(d.cut, 80, 12000))
  send("drone", "res", clamp(d.res or 0.2, 0, 0.9))
  send("drone", "detune", clamp(d.detune or 0.1, 0, 1.5))
  send("drone", "shape", clamp(d.shape or 0.3, 0, 1))
  send("drone", "air", clamp(d.air or 0.1, 0, 1))
  send("drone", "sub", clamp(d.sub or 0.3, 0, 1))
  send("drone", "wob", clamp((d.wob or 0.1) + a * 0.45, 0, 1))
  send("drone", "breath", clamp(d.breath or 0.3, 0, 1))

  for _, n in ipairs(TEXN) do
    send("tex", n, clamp((P.t[n] or 0) * (C.tex_gain or 1) * P.k.texmul, 0, 1.5))
  end
  send("tex", "hrate", clamp(P.sp.hrate, 0.5, 3))
  send("tex", "crate", (P.sp.crate or 1) * (1 - a * 0.15))

  local f = P.f
  send("fx", "amp", C.vol)
  send("fx", "rev", clamp(f.rev or 0.5, 0, 1))
  send("fx", "size", clamp(f.size or 0.85, 0.3, 0.99))
  send("fx", "damp", clamp(f.damp or 0.4, 0, 1))
  send("fx", "shimmer", clamp(f.shimmer or 0.1, 0, 1))
  send("fx", "tape", clamp(f.tape or 0.1, 0, 1))
  send("fx", "age", clamp(f.age or 0.05, 0, 1))
  send("fx", "crush", clamp(f.crush or 0, 0, 1))
  send("fx", "hiss", clamp(f.hiss or 0.1, 0, 1.5))
  send("fx", "dark", clamp(f.dark or 0, 0, 0.97))
  send("fx", "echo", clamp(f.echo or 0, 0, 1))
  send("fx", "etime", clamp(f.etime, 0.1, 1.2))
  send("fx", "efb", clamp(f.efb, 0.5, 12))
  send("fx", "speed", 1 - a * 0.4)
end

-------------------------------------------------------------------------------
-- arrivare in un luogo
-------------------------------------------------------------------------------
local EXTRA = {
  { extra = "bells", ruolo = "campane", str = "campana", ott = 0, amp = 0.45, prob = 0.6 },
  { extra = "choir", ruolo = "accordo", str = "choir", ott = 0, amp = 0.2, prob = 0.8, atk = 3, voci = 3 },
  { extra = "strings", ruolo = "accordo", str = "strings", ott = 0, amp = 0.22, prob = 0.8, atk = 3, voci = 3 },
  { extra = "spark", ruolo = "scintille", str = "celesta", ott = 2, amp = 0.16, prob = 0.8, bright = 0.3 },
  { extra = "whisper", ruolo = "sussurri", str = "whisper", ott = 1, amp = 0.32, prob = 0.8 },
  { extra = "glitch", ruolo = "schegge", str = "glitch", ott = 1, amp = 0.2, prob = 0.8 },
  { extra = "pulse", ruolo = "pulsazione", str = "sub", ott = -1, amp = 0.3, prob = 0.3, legato = 0.6 },
  { extra = "torment", ruolo = "accordo", str = "cluster", ott = 0, amp = 0.3, prob = 0.8, atk = 1.5, voci = 2 },
  { extra = "torment", ruolo = "schegge", str = "scrape", ott = 0, amp = 0.28, prob = 0.7, bright = 0.6 },
  { extra = "glass", ruolo = "scintille", str = "fm", ott = 1, amp = 0.2, prob = 0.8, bright = 0.4 },
  { extra = "glass", ruolo = "onde", str = "grain", ott = 1, amp = 0.24, prob = 0.6, legato = 2 },
}

local function build_lines(p)
  local lines = {}
  C.answer = nil
  for i, def in ipairs(p.linee or {}) do
    local l = copy(def)
    l.amp = l.amp or 0.3
    l.prob = l.prob or 0.5
    l.pres = 0
    l.on = (i <= 2) or (random() < l.prob)
    l.wait = random(0, 6)
    l.motif = gen_motif(l.lens)
    l.onda_len = random(4, 10)
    lines[#lines + 1] = l
    if l.ruolo == "risposta" then C.answer = l end
  end
  if (C.place and C.place.strato or 0) <= -1 and not p.no_lamento then
    lines[#lines + 1] = { ruolo = "lamento", str = "bowed", ott = -1, amp = 0.14, prob = 0.3, pres = 0, on = true, wait = 0,
      motif = gen_motif(), onda_len = 6, legato = 1.2, atk = 0.8, bright = 0.2, spread = 0.2 }
  end
  for _, def in ipairs(EXTRA) do
    local l = copy(def)
    l.pres = 0; l.on = false; l.wait = 0; l.motif = gen_motif(); l.onda_len = 6; l.gain = 0
    lines[#lines + 1] = l
  end
  return lines
end

function C.go(place, quick)
  local p = place.musica
  C.prof = p
  C.place = place
  C.bpm_t = p.bpm or 60
  if quick then C.bpm = C.bpm_t end
  C.lines = build_lines(p)
  C.t0 = C.tick_n
  C.chord_i = 1
  C.chord_root = p.prog[1] - 1
  C.chord = chord_from(C.chord_root, p.accordo)
  C.sent = {}
  local defs = place.macro_def or {}
  for i = 1, 3 do
    local M = C.macro_def(i)
    C.mt[i] = defs[i] or ((M and M.bip) and 0.5 or 0.2)
    if quick then C.mc[i] = C.mt[i] end
  end
  engine.drone("glide", quick and 0.1 or (p.glide or 10))
  engine.tex("lag", quick and 0.5 or 7)
  engine.drone("lag", quick and 0.5 or 5)
  engine.fx("lag", quick and 0.5 or 5)
  set_drone_chord()
  C.fade_in = quick and 0 or 0.3
  C.update(0.1)
  if not quick then
    clock.run(function()
      clock.sleep(7)
      engine.drone("glide", p.glide or 10)
      engine.tex("lag", 2.5)
      engine.drone("lag", 2)
      engine.fx("lag", 1.5)
    end)
  end
end

-- all'arrivo, a volte, il tema saluta
function C.saluto()
  if not C.prof or random() > 0.45 then return end
  local mel
  for _, l in ipairs(C.lines) do if l.ruolo == "melodia" and not l.extra then mel = l; break end end
  if not mel then return end
  mel.on = true; mel.pres = math.max(mel.pres, 0.7)
  local th = C.TEMA[1]
  local tt = 0
  for i = 1, 4 do
    local e = th[i]
    C.later(2 + tt, function() voice(mel, e[1], e[2]) end)
    tt = tt + e[2]
  end
end

function C.evoca()
  -- evocare: gli archi si alzano, il tema arriva subito, poi il luogo
  -- ricomincia a raccontare con un altro giro di accordi e altri motivi
  local p = C.prof
  if not p then return end
  C.bridge = 0.75
  local mel
  for _, l in ipairs(C.lines) do if l.ruolo == "melodia" and not l.extra then mel = l; break end end
  mel = mel or { ruolo = "ponte", str = "piano", ott = 0, amp = 0.3, bright = 0.35, legato = 2.2, pan = 0, spread = 0.3 }
  mel.pres = 1; mel.on = true; mel.phrase = nil; mel.wait = 99
  local th = C.TEMA[random(#C.TEMA)]
  local tt = 1
  for i, e in ipairs(th) do
    local fine = i == #th
    C.later(tt, function()
      local was = mel.theme; mel.theme = true
      voice(mel, e[1], e[2] * (fine and 2 or 1), 1.1)
      mel.theme = was
    end)
    tt = tt + e[2]
  end
  C.later(tt + 2, function() mel.wait = 4 end)
  local prog = {}
  for i, v in ipairs(p.prog) do prog[i] = v end
  for i = #prog, 3, -1 do
    local j = random(2, i)
    prog[i], prog[j] = prog[j], prog[i]
  end
  p.prog = prog
  for i, l in ipairs(C.lines) do
    if not l.extra and l ~= mel then
      l.motif = gen_motif(l.lens)
      l.phrase = nil
      l.on = i <= 2 or random() < l.prob
    end
  end
  C.chord_i = 1
  C.chord_root = p.prog[1] - 1
  C.chord = chord_from(C.chord_root, p.accordo)
  set_drone_chord()
end

function C.travel(on) C.travelling = on end

-- il ponte musicale tra due luoghi: un accordo d'archi e il tema, lento
function C.ponte()
  if not C.prof then return end
  local p = C.prof
  C.fade_in = max(C.fade_in, 0.7)
  local sc = C.scala()
  local root = C.chord_root
  for i, d in ipairs({ root, root + 2, root + 4, root + 7 }) do
    local m = p.tonica + deg2semi(d, sc) - (i == 1 and 12 or 0)
    C.later(1 + (i - 1) * 2, function() C.play("strings", m, 0.11, 9, (i - 2.5) * 0.3, 0.3, 2.8, 1) end)
  end
  local line = { ruolo = "ponte", str = (p.ponte or "piano"), ott = 0, amp = 0.3, pres = 1, gain = 1,
    bright = 0.35, legato = 2.2, pan = 0.1, spread = 0.3, theme = true }
  local th = C.TEMA[random(#C.TEMA)]
  local tt = 4
  for i = 1, min(#th, 7) do
    local e = th[i]
    local fine = (i == min(#th, 7))
    C.later(tt, function() voice(line, e[1], e[2] * 2 * (fine and 1.8 or 1), 0.75 + 0.35 * math.sin(math.pi * i / 7)) end)
    tt = tt + e[2] * 2
  end
end

function C.start()
  C.t0 = 0
  C.clock_id = clock.run(function()
    while true do
      clock.sleep(C.tickdur())
      C.tick()
    end
  end)
end

function C.stop()
  if C.clock_id then clock.cancel(C.clock_id) end
end

return C
