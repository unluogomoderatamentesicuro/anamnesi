-- ANAMNESI · scene del paese
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, copy, think, mac, w = H.R, H.pick, H.pan, H.copy, H.think, H.mac, H.w

D.POSE.phone = { lean = 4, nod = 14, ua1 = 125, ua2 = 10, fa1 = 172, fa2 = 20, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }

-------------------------------------------------------------------------------
-- LA SOGLIA (v7)
-- Il buio. Dietro di lui la porta da cui è entrato, sola, con le stelle dentro.
-- Davanti i sentieri: una scala di luce che sale, gradini che scendono nel nero,
-- due strade di lumini a destra e a sinistra. Quando ne scegli uno, si accende,
-- e i lumini corrono verso dove andrai.
-------------------------------------------------------------------------------
S.soglia = {
  init = function(s)
    s.fig = D.figura(64, 52, { s = 1.15, l = 14, pose = "stand", speed = 3, on_step = H.steps("pietra", 0.3) })
    s.stars = D.stars_gen(26, 61, 10, 38)
    s.motes = D.parts(14)
    s.embers = D.parts(8)
    s.lit = { su = 0, giu = 0, sx = 0, dx = 0, segreto = 0 }
    s.door = 0
  end,
  update = function(s, dt, t)
    local sel = S.env.sel and S.env.sel()
    for k, v in pairs(s.lit) do s.lit[k] = D.lerp(v, (sel == k) and 1 or 0, min(1, dt * 3)) end
    -- lui si gira verso il sentiero scelto
    if sel and s.fig.idle then
      if sel == "sx" then s.fig.face = -1 elseif sel == "dx" then s.fig.face = 1 end
      if sel == "su" then s.fig:act({ { "pose", "look_up", 2 } }) elseif sel == "giu" then s.fig:act({ { "pose", "head_down", 2 } }) end
    end
    think(s.fig, function()
      local r = random()
      if r < 0.35 then return { { "pose", "stand", R(8, 14) }, { "pose", "look_up", R(4, 7) } } end
      if r < 0.55 then return { { "face", -1 }, { "pose", "stand", 3 }, { "face", 1 }, { "pose", "stand", R(6, 10) } } end
      if r < 0.75 then return { { "walk", R(54, 74) }, { "face", pick({ 1, -1 }) }, { "pose", "stand", R(6, 10) } } end
      return { { "pose", "sit_ground", R(14, 24) }, { "pose", "stand", 3 } }
    end)
    s.fig:update(dt)
    s.door = s.door + dt
    if random() < dt * 1.5 then D.spawn(s.motes, { x = R(56, 72), y = R(18, 50), vx = R(-1, 1), vy = -R(1, 3), life = R(3, 6) }) end
    D.parts_update(s.motes, dt)
    if random() < dt * (1 + mac("fuoco") * 2) then D.spawn(s.embers, { x = R(10, 18), y = 56, vx = R(-2, 2), vy = -R(6, 12), life = R(1, 2.5) }) end
    D.parts_update(s.embers, dt)
  end,
  draw = function(s, t)
    local L = s.lit
    -- la porta dietro di lui: solo il telaio, e dentro le stelle da cui viene
    local dx0, dx1, dy0 = 52, 76, 12
    screen.level(D.lv(6)); screen.move(dx0 + 0.5, 52); screen.line(dx0 + 0.5, dy0 + 0.5); screen.line(dx1 + 0.5, dy0 + 0.5); screen.line(dx1 + 0.5, 52); screen.stroke()
    for _, st in ipairs(s.stars) do
      local x = dx0 + 2 + (st.x / 128) * (dx1 - dx0 - 4)
      local y = dy0 + 2 + ((st.y - 10) / 28) * (52 - dy0 - 6)
      local tw = 0.5 + 0.5 * sin(t * st.sp + st.ph)
      D.px(x, y, 2 + st.b * 9 * tw)
    end
    -- la luce che filtra sotto e cade sul pavimento
    for i = 0, 4 do D.line(dx0 + 3 + i * 5, 53, dx0 - 6 + i * 9, 60, 2 + (i % 2)) end
    for _, m in ipairs(s.motes.list) do D.px(m.x, m.y, 6 * (1 - m.age / m.life)) end
    -- il pavimento: una linea, e il fuoco alle spalle, piccolo
    D.line(20, 52, 108, 52, 3)
    -- il fuoco: poche lingue di luce, niente alone
    local fh = 5 + mac("fuoco") * 4
    for i = 0, 4 do
      local x = 11 + i * 1.6
      local h = fh * (0.4 + 0.6 * D.noise(t * 6 + i * 3)) * (1 - abs(i - 2) / 3.5)
      D.line(x, 56, x + (D.noise(t * 4 + i) - 0.5) * 2, 56 - h, 9 + i % 2 * 5)
    end
    D.line(8, 57, 22, 57, 5)
    for _, e in ipairs(s.embers.list) do D.px(e.x, e.y, 10 * (1 - e.age / e.life)) end

    -- i sentieri. Ogni lumino respira; quello scelto si accende e corre.
    local function lumini(pts, k, base)
      local n = #pts
      for i, p in ipairs(pts) do
        local run = k > 0.05 and ((t * 6 - i) % n < 1.5) and 6 or 0
        local l = base + 1.5 * sin(t * 0.8 + i) + k * (6 + run)
        D.px(p[1], p[2], l)
      end
    end
    -- su: la scala di luce, a destra della porta
    local up = {}
    for i = 0, 9 do up[#up + 1] = { 86 + i * 3.5, 50 - i * 5 } end
    for i, p in ipairs(up) do D.line(p[1] - 2, p[2], p[1] + 2, p[2], 2 + L.su * 9 * (1 - i / 14)) end
    lumini(up, L.su, 3)
    -- giù: i gradini che scendono nel nero, a sinistra in basso
    local dn = {}
    for i = 0, 6 do dn[#dn + 1] = { 40 - i * 4, 56 + i * 1.2 } end
    for i, p in ipairs(dn) do D.line(p[1] - 3, p[2], p[1] + 1, p[2], 2 + L.giu * 7 * (1 - i / 9)) end
    lumini(dn, L.giu, 2)
    -- sinistra e destra: due strade di lumini che vanno fuori dallo schermo
    local sx, dxp = {}, {}
    for i = 1, 7 do sx[#sx + 1] = { 50 - i * 7, 52 - i * 0.6 + sin(i) * 0.8 }; dxp[#dxp + 1] = { 78 + i * 7, 52 - i * 0.6 + sin(i + 2) * 0.8 } end
    lumini(sx, L.sx, 3); lumini(dxp, L.dx, 3)
    -- il sentiero nascosto: un luccichio vicino a lui, solo quando c'è
    if L.segreto > 0.05 then
      for i = 1, 8 do local a = t * 2 + i * 0.8; D.px(s.fig.x + cos(a) * 9, s.fig.y - 10 + sin(a) * 4, L.segreto * 12) end
    end
    -- le stelle vere, poche, in alto
    for i = 1, 7 do D.px((i * 37 + 11) % 128, 4 + (i * 13) % 10, 3 + 2 * sin(t * 0.4 + i)) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA STAZIONE DESERTA
-------------------------------------------------------------------------------
local TABELLONE = { { "ROMA", "TERNI", "ORTE", "ANCONA", "DOMANI", "IERI", "MAI", "CASA", "SOPPRESSO", "RITARDO" },
  { "ROME", "TERNI", "ORTE", "ANCONA", "TOMORROW", "YESTERDAY", "NEVER", "HOME", "CANCELLED", "DELAYED" } }

S.stazione = {
  init = function(s)
    s.fig = D.figura(64, 56, { s = 1.05, l = 9, pose = "sit", on_step = H.steps("pietra", 0.4) })
    s.board = { txt = w(TABELLONE), flip = 0, next = R(8, 20) }
    s.moths = D.parts(6)
    s.train = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.6 then return { { "pose", "sit", R(15, 30) }, { "pose", "sit_slump", R(8, 14) } } end
      return { { "pose", "stand", 2 }, { "walk", R(96, 108) }, { "face", 1 }, { "pose", "stand", R(8, 14) }, { "walk", 64 }, { "face", 1 }, { "pose", "sit", 10 } }
    end)
    s.fig:update(dt)
    local b = s.board
    b.next = b.next - dt
    if b.next < 0 then b.flip = 1.2; b.next = R(12, 30) end
    if b.flip > 0 then
      b.flip = b.flip - dt
      if b.flip <= 0 then b.txt = w(TABELLONE); S.env.sfx("glitch", 900, 0.04, 0.12, -0.3, 0.2) end
    end
    D.motes_update(s.moths, dt, 1, { 14, 8, 14, 8 }, t)
    if s.train <= 0 and random() < dt * (0.02 + mac("treno") * 0.05) then s.train = 12 end
    s.train = max(0, s.train - dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local vx, vy = 124, 38
    D.line(0, 57, vx, vy, 4); D.line(0, 63, vx, vy + 1, 4)
    for k = 1, 12 do
      local x = (k / 12) ^ 2 * vx
      D.line(x, 57 + (vy - 57) * (x / vx) + 1, x, 63 + (vy + 1 - 63) * (x / vx), 2)
    end
    if s.train > 0 then
      local a = sin(s.train / 12 * pi)
      D.circle(vx, vy - 1, 1 + a * 2, 3 * a); D.px(vx, vy - 1, 15 * a)
    end
    D.poly({ 0, 46, 100, 46, 128, 50, 128, 52, 0, 56 }, 3)
    D.line(0, 46, 100, 46, 6)
    D.rect(0, 0, 128, 6, 2)
    for x = 10, 120, 36 do D.rect(x, 6, 2, 40, 2) end
    for i, lx in ipairs({ 22, 58, 94 }) do
      local fl = (i == 2 and D.noise(t * 4) < 0.15) and 0.4 or 1
      for k = -3, 3 do D.line(lx, 9, lx + k * 5, 46 + abs(k), 1 + fl * (1.5 - abs(k) * 0.3)) end
      D.poly({ lx - 9, 47, lx + 9, 47, lx + 12, 50, lx - 12, 50 }, 2 + 2 * fl)
      D.rect(lx - 2, 6, 5, 2, 8 * fl); D.glow(lx, 9, 6, 5 * fl); D.px(lx, 8, 15 * fl)
    end
    D.motes_draw(s.moths, 8)
    D.rect(30, 12, 44, 11, 1)
    screen.level(D.lv(2)); screen.rect(30.5, 12.5, 43, 10); screen.stroke()
    screen.font_face(1); screen.font_size(8)
    local txt = s.board.txt
    if s.board.flip > 0 then
      local c = {}
      for i = 1, #txt do c[i] = string.char(65 + random(0, 25)) end
      txt = table.concat(c)
    end
    screen.level(D.lv(11)); screen.move(52, 20); screen.text_center(txt)
    K.clock(90, 16, t, 7)
    D.rect(52, 50, 24, 2, 6); D.line(54, 52, 54, 56, 5); D.line(74, 52, 74, 56, 5); D.rect(52, 44, 24, 1, 4)
    D.rect(77, 50, 7, 6, 5); D.line(79, 49, 82, 49, 7)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- DOMENICA AL PAESE
-------------------------------------------------------------------------------
S.domenica = {
  init = function(s)
    s.people = {}
    for i = 1, 5 do s.people[i] = D.figura(R(0, 128), R(57, 61), { s = R(0.6, 0.8), l = 2, dark = true, dress = random() < 0.5, speed = R(4, 7) }) end
    s.kid = D.figura(80, 61, { s = 0.5, l = 2, dark = true, child = true, coat = false, speed = 6,
      prop = function(x, y) D.rect(x - 1, y - 1, 3, 2, 12); D.line(x - 1, y - 2, x + 1, y - 2, 9) end })
    s.swing = 0
    s.pigeons = {}
    for i = 1, 9 do s.pigeons[i] = { x = R(60, 120), y = 61, vy = 0, vx = 0, fly = false } end
  end,
  update = function(s, dt, t)
    local crowd = 0.4 + mac("folla")
    for i, p in ipairs(s.people) do
      if i <= 2 + floor(crowd * 3) then
        think(p, function() return { { "walk", R(-10, 138), nil, R(56, 62) }, { "pose", pick({ "stand", "look_up", "stand" }), R(2, 6) } } end)
      end
      p:update(dt)
    end
    think(s.kid, function() return { { "walk", R(70, 120) }, { "pose", "stand", R(2, 5) } } end)
    s.kid:update(dt)
    s.swing = max(0, s.swing - dt * 0.08)
    for _, p in ipairs(s.pigeons) do
      if p.fly then
        p.x = p.x + p.vx * dt; p.y = p.y + p.vy * dt; p.vy = p.vy - 4 * dt
        if p.y < -10 then p.fly = false; p.y = 61; p.x = R(60, 120) end
      elseif s.swing > 0.8 and random() < 0.5 then
        p.fly = true; p.vx = R(-20, 20); p.vy = -R(15, 30)
      end
    end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 52, 8 + lu, 11 + lu)
    D.cloud((t * 1.5) % 180 - 40, 8, 26, 13, 4)
    D.rect(16, 18, 42, 34, 5)
    D.poly({ 14, 18, 60, 18, 37, 6 }, 6)
    D.circle(37, 26, 4, 3); D.circle(37, 26, 2, 7)
    D.circle(37, 38, 5, 2); D.rect(32, 38, 10, 14, 2)
    D.rect(60, 2, 14, 50, 4); D.poly({ 58, 2, 76, 2, 67, -6 }, 5); D.rect(62, 8, 10, 10, 1)
    local a = sin(t * 2.4) * s.swing * 0.9
    for k, bx in ipairs({ 65, 70 }) do
      local aa = k == 1 and a or -a
      local x, y = bx + sin(aa) * 2, 10 + cos(aa) * 2
      D.line(bx, 9, x, y, 6)
      D.poly({ x - 2, y, x + 2, y, x + 2.5 - sin(aa) * 3, y + 4, x - 2.5 - sin(aa) * 3, y + 4 }, 9)
    end
    D.circle(67, 26, 3, 9); D.line(67, 26, 67, 24, 2); D.line(67, 26, 68, 27, 2)
    for i, h in ipairs({ { 78, 26, 14 }, { 94, 20, 12 }, { 108, 30, 20 } }) do
      D.rect(h[1], 52 - h[2], h[3], h[2], 6 + (i % 2)); D.rect(h[1] - 1, 51 - h[2], h[3] + 2, 2, 4)
      for wy = 52 - h[2] + 4, 46, 7 do for wx = h[1] + 2, h[1] + h[3] - 4, 5 do D.rect(wx, wy, 3, 4, 3) end end
    end
    D.rect(0, 52, 128, 12, 8)
    for i = 0, 60 do D.px((i * 37) % 128, 53 + (i * 3) % 11, 6) end
    D.rect(98, 56, 14, 3, 5); D.rect(104, 50, 2, 6, 5)
    for k = 0, 4 do D.px(105 + sin(t * 3 + k) * (k * 0.8), 50 + k * 1.2, 12) end
    for _, p in ipairs(s.pigeons) do
      if p.fly then local g = sin(t * 14 + p.x); D.line(p.x - 1, p.y - g, p.x + 1, p.y + g, 3)
      else D.px(p.x, p.y, 3); D.px(p.x + 1, p.y - 1, 3) end
    end
    for _, p in ipairs(s.people) do p:draw() end
    s.kid:draw()
  end,
  note = function(s, ev) if ev.str == "campana" then s.swing = 1 end end,
}

-------------------------------------------------------------------------------
-- IL PARCO GIOCHI
-------------------------------------------------------------------------------
S.parco = {
  init = function(s)
    s.sw = { { a = 0.4, v = 0 }, { a = 0, v = 0 } }
    s.gir, s.horse, s.lastdir = 0, 0, 1
    s.fig = D.figura(130, 57, { s = 0.95, l = 2, dark = true, face = -1, speed = 4, on_step = H.steps("ghiaia", 0.35) })
    s.onswing = false
    s.leaves = D.parts(8)
  end,
  update = function(s, dt, t)
    local wind = 0.15 + mac("vento") * 0.5
    for i, sw in ipairs(s.sw) do
      local acc = -9 / 1.6 * sin(sw.a) * 0.25
      sw.v = (sw.v + acc * dt) * (1 - 0.04 * dt)
      if i == 1 and random() < dt * wind then sw.v = sw.v + R(-0.15, 0.15) end
      if i == 2 and s.onswing and abs(sw.a) < 0.1 and abs(sw.v) < 0.8 then sw.v = sw.v + 0.05 * (sw.v >= 0 and 1 or -1) end
      local old = sw.v
      sw.a = sw.a + sw.v * dt
      if i == 1 and (old > 0) ~= (s.lastdir > 0) and abs(sw.a) > 0.25 then S.env.sfx("breath", R(1800, 2400), 0.025, 0.18, -0.6, 0, 0.02) end
      if i == 1 then s.lastdir = old end
    end
    s.gir = s.gir + dt * 0.35
    s.horse = s.horse * (1 - dt * 0.6)
    local f = s.fig
    think(f, function()
      local r = random()
      if r < 0.45 then return { { "walk", 34 }, { "fn", function() s.onswing = true end }, { "pose", "swing", R(20, 35) }, { "fn", function() s.onswing = false end }, { "pose", "stand", 2 } } end
      if r < 0.7 then return { { "walk", 84 }, { "pose", "bend", 2 }, { "fn", function() s.horse = 1 end }, { "pose", "stand", 5 } } end
      if r < 0.88 then return { { "walk", 96 }, { "face", 1 }, { "pose", "look_up", R(5, 9) }, { "pose", "stand", 3 } } end
      return { { "walk", 62 }, { "pose", "stand", R(6, 10) } }
    end)
    f:update(dt)
    if s.onswing then
      local sw = s.sw[2]
      f.x = 34 + sin(sw.a) * 22; f.y = 17 + cos(sw.a) * 22 + 4.6 * f.s
    elseif f.y < 57 then f.y = min(57, f.y + dt * 20) end
    if random() < dt * (0.6 + wind) then D.spawn(s.leaves, { x = -2, y = R(30, 60), vx = R(10, 20), vy = R(-2, 2), ph = R(0, 6), life = 14 }) end
    D.parts_update(s.leaves, dt, function(p, d) p.y = p.y + sin(t * 3 + p.ph) * 4 * d end)
  end,
  draw = function(s, t)
    D.gradient(0, 50, 6, 8)
    D.rect(0, 50, 128, 14, 5)
    for i = 0, 50 do D.px((i * 29) % 128, 51 + (i * 7) % 12, 3 + (i % 3)) end
    D.line(6, 56, 14, 16, 3); D.line(22, 56, 14, 16, 3); D.line(54, 56, 46, 16, 3); D.line(38, 56, 46, 16, 3)
    D.rect(13, 15, 35, 2, 3)
    for i, sw in ipairs(s.sw) do
      local ox = i == 1 and 18 or 34
      local x, y = ox + sin(sw.a) * 22, 17 + cos(sw.a) * 22
      D.line(ox - 1, 17, x - 2, y, 4); D.line(ox + 1, 17, x + 2, y, 4)
      D.rect(x - 3, y, 6, 1, 6)
    end
    local gx, gy = 66, 55
    D.poly({ gx - 12, gy, gx + 12, gy, gx + 10, gy + 3, gx - 10, gy + 3 }, 4)
    for k = 0, 5 do
      local a = s.gir + k * pi / 3
      local x = gx + cos(a) * 11
      D.line(gx, gy - 6, x, gy - 1 + sin(a) * 1.5, 5 - sin(a) * 1.5)
      D.line(x, gy - 1 + sin(a) * 1.5, x, gy - 4 + sin(a) * 1.5, 5 - sin(a) * 1.5)
    end
    D.rect(gx - 1, gy - 8, 2, 8, 6)
    local ha = sin(t * 6) * s.horse * 0.3
    D.line(84, 57, 84 + sin(ha) * 2, 52, 3)
    local hx, hy = 84 + sin(ha) * 3, 49
    D.poly({ hx - 4, hy, hx + 3, hy - 1, hx + 4, hy - 4, hx + 6, hy - 4, hx + 5, hy - 1, hx + 3, hy + 2, hx - 4, hy + 2 }, 6)
    D.poly({ 104, 56, 104, 26, 108, 14, 112, 26, 112, 56 }, 4)
    D.poly({ 100, 56, 104, 46, 104, 56 }, 3); D.poly({ 116, 56, 112, 46, 112, 56 }, 3)
    D.circle(108, 30, 2, 2); D.circle(108, 30, 1, 7); D.circle(108, 40, 2, 2)
    for y = 28, 54, 3 do D.line(113, y, 116, y, 3) end
    D.line(116, 28, 116, 56, 3)
    screen.level(D.lv(5)); screen.move(104, 30); screen.curve(96, 34, 94, 50, 86, 55); screen.stroke()
    for _, l in ipairs(s.leaves.list) do D.px(l.x, l.y, 9) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- DA MASSIMO
-------------------------------------------------------------------------------
local PAROLE_MASSIMO = {
  { "ciao Massimo", "sono io", "ti racconto", "a novembre esce GTA 6", "secondo me", "tu ci stai già giocando",
    "ho giocato a Mother", "il tuo gioco", "quello che avevi fatto tu", "c'eri dentro tutto", "mi manchi",
    "vorrei parlarti", "ancora un po'", "te lo ricordi?", "ridevamo", "a domenica" },
  { "hi Massimo", "it's me", "let me tell you", "GTA 6 comes out in November", "I think", "you're already playing it",
    "I played Mother", "your game", "the one you made", "you were all in it", "I miss you",
    "I'd like to talk", "a little longer", "remember?", "we used to laugh", "see you Sunday" },
}

S.massimo = {
  init = function(s)
    s.words = D.parts(3)
    s.leaf = nil
    s.rain = D.parts(50)
    s.fig = D.figura(-6, 57, { s = 1.0, l = 2, dark = true, speed = 4, on_step = H.steps("ghiaia", 0.35) })
    s.fig:act({ { "walk", 40 } })
    s.flowers = 0.6
    s.game = 0
    s.gx = 0
  end,
  update = function(s, dt, t)
    local f = s.fig
    think(f, function()
      local r = random()
      if r < 0.25 then
        return { { "walk", 42 }, { "face", 1 }, { "pose", "kneel_one", 2 }, { "fn", function()
          s.leaf = { x = 60, y = 46, vx = -R(6, 12), vy = -R(2, 6), age = 0 }
        end }, { "pose", "kneel_one", 2 }, { "pose", "bend", 3 }, { "fn", function() s.flowers = 1 end }, { "pose", "stand", 3 } }
      elseif r < 0.75 then
        return { { "walk", 44 }, { "face", 1 }, { "pose", "sit", 1 }, { "pose", "talk", R(16, 28) }, { "pose", "sit_slump", R(5, 9) }, { "pose", "talk", R(10, 16) }, { "pose", "stand", 2 } }
      elseif r < 0.88 then
        return { { "pose", "look_up", R(6, 10) }, { "pose", "head_down", 5 } }
      end
      return { { "walk", R(10, 30) }, { "face", 1 }, { "pose", "stand", R(8, 14) }, { "walk", 40 } }
    end)
    local seated = f.cur.hy < 6 and f.cur.rot == 0 and f.cur.th1 > 60
    f.y = seated and 52 or 57
    f:update(dt)
    local a = f.q[1]
    if a and a[1] == "pose" and a[2] == "talk" and random() < dt * 0.3 and #s.words.list < 2 then
      local word = w(PAROLE_MASSIMO)
      D.spawn(s.words, { x = f.x + R(-6, 12), y = f.y - 20, vx = R(0.5, 1.5), vy = -R(1.2, 2), life = 8, w = word, l = 13 })
      if word:find("Mother") then s.game = 9 end
    end
    D.float_words_update(s.words, dt)
    if s.leaf then
      local l = s.leaf
      l.age = l.age + dt; l.x = l.x + l.vx * dt; l.y = l.y + l.vy * dt; l.vy = l.vy + 6 * dt
      l.vx = l.vx + sin(t * 4) * 8 * dt
      if l.y > 64 or l.age > 6 then s.leaf = nil end
    end
    local rain = 0.15 + mac("pioggia")
    if rain > 0.2 then D.rain_update(s.rain, dt, rain, 64, -4) else D.parts_update(s.rain, dt) end
    s.flowers = max(0.6, s.flowers - dt * 0.002)
    s.game = max(0, s.game - dt)
    s.gx = (s.gx + dt * 4) % 14
  end,
  draw = function(s, t)
    D.gradient(0, 40, 5, 7)
    D.cloud((t * 0.8) % 170 - 30, 6, 40, 8, 9)
    for i = 0, 9 do
      local x = 4 + i * 13
      D.rect(x, 36 - (i % 3), 5, 6 + (i % 3), 4)
      if i % 3 == 0 then D.cross(x + 2, 34 - (i % 3), 5, 4) end
    end
    D.cypress(10, 42, 30, 2, sin(t * 0.5) * 0.6); D.cypress(24, 42, 22, 2, sin(t * 0.5 + 1) * 0.6)
    D.cypress(110, 42, 34, 2, sin(t * 0.5 + 2) * 0.6); D.cypress(122, 42, 24, 2, sin(t * 0.5 + 3) * 0.6)
    D.rect(0, 42, 128, 22, 6)
    for i = 0, 70 do D.px((i * 17) % 128, 43 + (i * 7) % 21, 4 + (i % 3)) end
    -- la sua lapide
    D.rect(52, 18, 26, 30, 9); D.rect(53, 19, 24, 1, 12); D.rect(52, 16, 26, 2, 10)
    D.circle(65, 26, 4.5, 11); D.circle(65, 26, 3.6, 4); D.circle(65, 25, 1.5, 7); D.rect(63, 27, 5, 2, 6)
    for k = 0, 2 do D.line(57, 34 + k * 3, 73 - k * 2, 34 + k * 3, 6) end
    D.rect(42, 48, 46, 6, 10); D.rect(42, 48, 46, 1, 13); D.rect(44, 54, 42, 2, 7)
    D.rect(56, 44, 3, 4, 7)
    for k = 0, 4 do
      local fx = 55 + k * 1.2 + sin(t * 0.7 + k) * 0.4
      D.line(57, 44, fx, 39 - k % 2, 4); D.px(fx, 38 - k % 2, 13 * s.flowers)
    end
    D.rect(74, 44, 3, 4, 5); D.candle(75.5, 44, t, 8, 0.1, false)
    -- il suo gioco, che per un momento si accende sul marmo
    if s.game > 0 then
      local a = min(1, s.game / 1.5, (9 - s.game) / 1.5)
      local gx, gy = 66, 41
      D.rect(gx, gy, 18, 12, 1 + a * 2)
      D.rect(gx + 2, gy + 2, 14, 7, 2 + a * 4)
      D.line(gx + 2, gy + 7, gx + 15, gy + 7, 3 + a * 6)
      local px = gx + 2 + s.gx
      D.px(px, gy + 5, 6 + a * 9); D.px(px, gy + 6, 6 + a * 9); D.px(px + 1, gy + 4, 5 + a * 8)
      D.px(gx + 13, gy + 4, 4 + a * 6)
      D.px(gx + 4, gy + 10, 3 + a * 6); D.px(gx + 13, gy + 10, 3 + a * 6)
    end
    if s.leaf then D.px(s.leaf.x, s.leaf.y, 4); D.px(s.leaf.x + 1, s.leaf.y, 3) end
    s.fig:draw()
    D.float_words_draw(s.words)
    D.rain_draw(s.rain, 0.7)
  end,
}

-------------------------------------------------------------------------------
-- FORNOLE, AL TRAMONTO
-------------------------------------------------------------------------------
S.fornole = {
  init = function(s)
    s.far = D.ridge_gen(161, 28, 10, 0.8)
    s.hill = D.ridge_gen(162, 40, 12, 0.6)
    s.olives = {}
    for i = 1, 9 do s.olives[i] = { x = R(0, 128), y = R(50, 62), h = R(7, 11), seed = i * 7 } end
    table.sort(s.olives, function(a, b) return a.y < b.y end)
    s.sw = {}
    for i = 1, 8 do s.sw[i] = { x = R(0, 128), y = R(4, 20), a = R(0, 6) } end
    s.fig = D.figura(110, 60, { s = 0.9, l = 1, dark = true, face = -1, speed = 3.5, on_step = H.steps("ghiaia", 0.3) })
    s.bell = 0
  end,
  update = function(s, dt, t)
    for _, w2 in ipairs(s.sw) do
      w2.a = w2.a + (D.noise(t * 0.8 + w2.x) - 0.5) * 5 * dt
      w2.x = (w2.x + cos(w2.a) * 20 * dt) % 140; w2.y = D.clamp(w2.y + sin(w2.a) * 8 * dt, 2, 26)
    end
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(10, 118), 3.5, R(58, 62) }, { "pose", "stand", R(6, 12) } } end
      return { { "pose", "look_up", R(6, 10) }, { "pose", "stand", 6 } }
    end)
    s.fig:update(dt)
    s.bell = max(0, s.bell - dt * 0.3)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 40, 3 + lu * 2, 11 + lu * 2)
    D.circle(96, 30, 10, 12); D.circle(96, 30, 6, 15)
    -- Amelia, lontana sul suo colle, con le mura e la torre
    D.ridge(s.far, 4, 40)
    D.rect(18, 20, 30, 6, 3)
    for x = 18, 46, 4 do D.rect(x, 18 + (x % 3), 3, 3, 3) end
    D.rect(36, 12, 3, 9, 3)
    -- la collina di Fornole
    D.ridge(s.hill, 3, 64)
    for i, h in ipairs({ { 60, 34 }, { 68, 32 }, { 76, 35 }, { 84, 33 }, { 72, 38 } }) do
      D.rect(h[1], h[2], 7, 5, 5 + (i % 2)); D.poly({ h[1] - 1, h[2], h[1] + 8, h[2], h[1] + 3.5, h[2] - 3 }, 4)
      if lu < 0 or (i % 2 == 0) then D.px(h[1] + 3, h[2] + 2, 11) end
    end
    D.rect(78, 24, 3, 9, 4); D.poly({ 77, 24, 82, 24, 79.5, 21 }, 4)
    D.px(79, 26 + s.bell * sin(t * 6), 9)
    -- gli ulivi d'argento
    for _, o in ipairs(s.olives) do
      D.line(o.x, o.y, o.x + 1, o.y - o.h * 0.5, 2)
      local r = D.lcg(o.seed)
      for k = 1, 6 do D.circle(o.x + (r() - 0.5) * o.h * 0.9 + sin(t * 0.6 + k) * 0.4, o.y - o.h * 0.6 + (r() - 0.5) * o.h * 0.5, o.h * 0.2, 5 + r() * 2) end
    end
    for _, w2 in ipairs(s.sw) do
      local g = sin(t * 12 + w2.x)
      D.line(w2.x - 2, w2.y + g, w2.x, w2.y, 2); D.line(w2.x, w2.y, w2.x + 2, w2.y + g, 2)
    end
    s.fig:draw()
  end,
  note = function(s, ev) if ev.str == "campana" then s.bell = 1 end end,
}

-------------------------------------------------------------------------------
-- LA CHIESA DI NOTTE
-------------------------------------------------------------------------------
S.chiesa = {
  init = function(s)
    s.fig = D.figura(40, 60, { s = 1.15, l = 9, pose = "pray" })
    s.cand = {}
    for i = 1, 14 do s.cand[i] = { x = 84 + (i % 7) * 4, y = 50 - floor(i / 7) * 4, on = random() < 0.7, ph = R(0, 6) } end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "pray", "pray", "sit_slump", "head_down" }), R(14, 26) } } end)
    s.fig.y = (s.fig.cur.hy < 4) and 60 or 60
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local vx, vy = 64, 26
    D.rect(0, 0, 128, 64, 0)
    -- la navata in prospettiva
    for k = 1, 5 do
      local f = k / 6
      local dx = 10 + f * f * 52
      local top = vy - 6 - f * f * 26
      local bot = vy + 6 + f * f * 36
      D.rect(vx - dx - 3 * f, top, 2 + 3 * f, bot - top, 2 + f)
      D.rect(vx + dx, top, 2 + 3 * f, bot - top, 2 + f)
      screen.level(D.lv(2)); screen.arc(vx, top, dx, pi, 2 * pi); screen.stroke()
    end
    -- l'altare lontano, la vetrata
    D.rect(vx - 6, vy - 2, 12, 8, 3)
    D.circle(vx, vy - 14, 5, 3)
    for a = 0, 7 do D.px(vx + cos(a * pi / 4) * 3, vy - 14 + sin(a * pi / 4) * 3, 5 + (a % 3) * 2) end
    D.px(vx, vy - 14, 9)
    -- le panche
    for k = 0, 4 do
      local y = 40 + k * 5
      local half = 10 + k * 10
      D.rect(vx - half, y, half - 4, 2, 3 + k * 0.4); D.rect(vx + 4, y, half - 4, 2, 3 + k * 0.4)
    end
    -- le candele votive
    D.rect(82, 52, 30, 2, 3)
    for _, c in ipairs(s.cand) do
      D.rect(c.x, c.y, 1, 2, 7)
      if c.on then D.px(c.x, c.y - 1, 11 + D.noise(t * 6 + c.ph) * 4) end
    end
    D.glow(97, 46, 15, 4)
    for _, c in ipairs(s.cand) do if c.on then D.px(c.x, c.y - 1, 11 + D.noise(t * 6 + c.ph) * 4) end end
    s.fig:draw()
  end,
  note = function(s, ev)
    if ev.str == "organ" or ev.str == "choir" then local c = s.cand[random(#s.cand)]; c.on = true end
  end,
}

-------------------------------------------------------------------------------
-- LA PIAZZA D'ESTATE
-------------------------------------------------------------------------------
S.piazza = {
  init = function(s)
    s.sitters = {}
    for i, x in ipairs({ 22, 36, 70, 84 }) do
      s.sitters[i] = D.figura(x, 58, { s = 0.95, l = 9, pose = "sit", face = (i % 2 == 1) and 1 or -1, bent = 10 })
    end
    s.kids = {}
    for i = 1, 2 do s.kids[i] = D.figura(R(0, 128), 60, { s = 0.55, l = 10, child = true, coat = false, speed = 10 }) end
    s.moths = D.parts(8)
  end,
  update = function(s, dt, t)
    for _, p in ipairs(s.sitters) do
      think(p, function() return { { "pose", pick({ "sit", "talk", "sit_read", "talk" }), R(3, 8) } } end)
      p:update(dt)
    end
    for _, k in ipairs(s.kids) do
      think(k, function() return { { "walk", R(0, 128), 12, R(58, 62) }, { "pose", pick({ "stand", "arms_open" }), R(1, 3) } } end)
      k:update(dt)
    end
    D.motes_update(s.moths, dt, 2, { 100, 8, 14, 10 }, t)
  end,
  draw = function(s, t)
    local n = mac("notte")
    D.gradient(0, 40, 0, 2 + (1 - n) * 2)
    D.rect(0, 10, 128, 32, 2)
    for x = 4, 124, 12 do D.rect(x, 16, 6, 8, (x % 24 == 4) and 8 or 1); D.rect(x, 28, 6, 8, (x % 36 == 16) and 7 or 1) end
    -- il bar e la tenda
    D.rect(4, 36, 40, 14, 4); D.rect(6, 38, 36, 9, 9)
    D.poly({ 2, 36, 46, 36, 48, 32, 0, 32 }, 6)
    for x = 2, 44, 6 do D.rect(x, 32, 3, 4, 8) end
    -- il lampione
    D.line(106, 54, 106, 14, 3); D.glow(106, 16, 14, 6)
    D.poly({ 102, 11, 110, 11, 108, 15, 104, 15 }, 4); D.rect(104, 15, 4, 1, 14)
    D.motes_draw(s.moths, 9)
    -- lucine appese
    for i = 0, 25 do D.px(i * 5, 30 + sin(i / 25 * pi) * 4, ((i + floor(t * 2)) % 4 == 0) and 7 or 12) end
    D.rect(0, 50, 128, 14, 3)
    for i = 0, 50 do D.px((i * 23) % 128, 51 + (i * 7) % 12, 4) end
    -- i tavolini
    for _, x in ipairs({ 29, 77 }) do D.rect(x - 6, 50, 12, 2, 8); D.line(x, 52, x, 58, 6); D.rect(x - 1, 48, 2, 2, 12) end
    for _, p in ipairs(s.sitters) do p:draw() end
    for _, k in ipairs(s.kids) do k:draw() end
  end,
}

-------------------------------------------------------------------------------
-- LA CABINA TELEFONICA
-------------------------------------------------------------------------------
S.cabina = {
  init = function(s)
    s.rain = D.parts(70)
    s.fig = D.figura(62, 56, { s = 1.05, l = 2, dark = true, pose = "phone" })
    s.car = { x = -40, on = false, wait = R(10, 25) }
  end,
  update = function(s, dt, t)
    D.rain_update(s.rain, dt, 2 + mac("pioggia") * 4, 62, -6)
    think(s.fig, function() return { { "pose", pick({ "phone", "phone", "head_down", "cry" }), R(8, 16) } } end)
    s.fig:update(dt)
    local c = s.car
    if c.on then c.x = c.x + dt * 45; if c.x > 180 then c.on = false; c.wait = R(15, 35) end
    else c.wait = c.wait - dt; if c.wait < 0 then c.on = true; c.x = -40 end end
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    D.rect(0, 50, 128, 14, 2)
    -- riflessi sulla strada bagnata
    D.reflection(62, 52, 63, 10, t, 6)
    D.reflection(106, 52, 63, 6, t, 4)
    -- il lampione
    D.line(106, 50, 106, 10, 3); D.glow(106, 13, 12, 5)
    D.poly({ 102, 7, 110, 7, 108, 11, 104, 11 }, 4); D.rect(104, 11, 4, 1, 13)
    -- la cabina
    D.rect(50, 10, 26, 42, 4)
    D.rect(52, 14, 22, 36, 8)
    for y = 14, 50, 9 do D.line(52, y, 73, y, 5) end
    D.line(63, 14, 63, 50, 5)
    D.rect(50, 8, 26, 3, 6)
    D.rect(66, 26, 5, 8, 3)
    s.fig:draw()
    D.line(s.fig.hand[1], s.fig.hand[2], 67, 32, 2)
    -- la macchina che passa coi fari
    if s.car.on then
      local x = s.car.x
      D.poly({ x, 50, x + 10, 42 - 2, x + 34, 50 }, 13 * 0.15 + 1)
      D.rect(x - 30, 44, 30, 6, 1); D.rect(x - 26, 40, 18, 4, 1)
      D.px(x, 46, 15)
    end
    D.rain_draw(s.rain, 0.9)
  end,
}

-------------------------------------------------------------------------------
-- LA BOTTEGA (le fotocopie di notte)
-------------------------------------------------------------------------------
S.bottega = {
  init = function(s)
    s.fig = D.figura(70, 58, { s = K.S, l = 10, pose = "bend", speed = 6, on_step = H.steps("piastrelle", 0.35) })
    s.scan = 0
    s.stack = 2
    s.sheet = nil
  end,
  update = function(s, dt, t)
    s.scan = (s.scan + dt / 4.5) % 1
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "walk", 72 }, { "face", -1 }, { "pose", "bend", R(6, 12) } } end
      if r < 0.75 then return { { "walk", 24 }, { "face", -1 }, { "pose", "carry", 2 }, { "walk", 72 }, { "face", -1 }, { "pose", "bend", 4 } } end
      return { { "walk", 100 }, { "face", 1 }, { "pose", "sit_read", R(10, 16) } }
    end)
    s.fig:update(dt)
    if s.scan < 0.02 and not s.sheet then s.sheet = { x = 32, y = 38 } end
    if s.sheet then
      s.sheet.x = s.sheet.x - dt * 10
      if s.sheet.x < 22 then s.sheet = nil; s.stack = (s.stack % 9) + 1 end
    end
  end,
  draw = function(s, t)
    K.room({ wall = 4, fy = 58, floor = "piastrelle", floor_l = 3, paper = nil, ceil = 4 }, t)
    D.rect(30, 4, 40, 1, 12)
    K.window(98, 14, 22, 18, K.views.night, t, s, 6)
    -- scaffali di risme
    for k = 0, 2 do
      D.rect(4, 18 + k * 10, 20, 1, 6)
      for i = 0, 3 do D.rect(5 + i * 5, 14 + k * 10, 4, 4, 12 - (i % 2) * 2) end
    end
    -- la fotocopiatrice
    local x, fy = 30, 58
    D.rect(x, fy - 24, 30, 24, 7)
    D.rect(x, fy - 26, 30, 2, 9)
    D.rect(x + 2, fy - 20, 26, 1, 5)
    D.rect(x + 2, fy - 12, 26, 1, 5); D.rect(x + 2, fy - 6, 26, 1, 5)
    D.rect(x + 22, fy - 22, 6, 3, 2)
    D.px(x + 23, fy - 21, 12); D.px(x + 25, fy - 21, 5 + (floor(t * 2) % 2) * 8)
    -- la luce che scorre sotto il coperchio
    local sx = x + 2 + s.scan * 26
    D.rect(sx, fy - 27, 2, 1, 15)
    D.circle(sx, fy - 27, 4, 6)
    -- il vassoio coi fogli
    D.rect(x - 8, fy - 16, 8, 1, 8)
    for i = 1, s.stack do D.line(x - 8, fy - 16 - i * 0.6, x - 1, fy - 16 - i * 0.6, 13) end
    if s.sheet then D.rect(s.sheet.x, fy - 17, 6, 1, 14) end
    -- il banco
    D.rect(92, 44, 30, 2, 8); D.rect(92, 46, 30, 12, 5)
    D.rect(100, 40, 8, 4, 2); D.rect(101, 41, 6, 2, 9)
    K.clock(64, 14, t, 6)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL CIMITERO DI NOTTE
-------------------------------------------------------------------------------
S.cimitero = {
  init = function(s)
    s.stars = D.stars_gen(50, 171, 0, 24)
    s.lumi = {}
    for row = 1, 6 do
      local f = row / 6
      local y = 30 + f * f * 30
      local n = 6 + row * 2
      for i = 1, n do
        s.lumi[#s.lumi + 1] = { x = 64 + (i - n / 2 - 0.5) * (6 + f * 14), y = y, f = f, ph = R(0, 6) }
      end
    end
    s.fig = D.figura(64, 62, { s = 1.0, l = 1, dark = true, speed = 3, on_step = H.steps("ghiaia", 0.3) })
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(30, 98), 3, R(58, 63) }, { "pose", "head_down", R(6, 10) } } end
      return { { "pose", "kneel_one", R(6, 10) }, { "pose", "stand", 4 } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.gradient(0, 30, 0, 2)
    D.stars(s.stars, t, 0.7)
    D.moon(100, 9, 3, 12, 1, 0)
    D.rect(0, 28, 128, 36, 1)
    for _, x in ipairs({ 8, 22, 104, 120 }) do D.cypress(x, 32, 22, 1, sin(t * 0.4 + x) * 0.5) end
    for _, L in ipairs(s.lumi) do
      local h = 2 + L.f * 6
      D.rect(L.x - 1 - L.f, L.y - h, 2 + L.f * 2, h, 2 + L.f)
      if L.f > 0.5 then D.cross(L.x, L.y - h, 3 + L.f * 3, 3) end
      local fl = D.noise(t * 5 + L.ph)
      D.px(L.x, L.y - h - 1, 6 + fl * 7 * (0.5 + L.f))
      if L.f > 0.6 then D.glow(L.x, L.y - h - 1, 3 + L.f * 2, 4); D.px(L.x, L.y - h - 1, 9 + fl * 6) end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LO STUDIO (le macchine che suonano)
-------------------------------------------------------------------------------
S.studio = {
  init = function(s)
    s.fig = D.figura(48, 58, { s = K.S, l = 9, pose = "sit", face = 1 })
    s.cone = 0
    s.leds = {}
    for i = 1, 16 do s.leds[i] = 0 end
    s.win = { moon = true }
    s.mini = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.6 then return { { "pose", "talk", R(4, 8) }, { "pose", "sit", R(3, 6) } } end
      if r < 0.8 then return { { "pose", "sit_think", R(6, 10) } } end
      return { { "pose", "sit_read", R(6, 10) } }
    end)
    s.fig:update(dt)
    s.cone = max(0, s.cone - dt * 4)
    for i = 1, 16 do s.leds[i] = max(0, s.leds[i] - dt * 2) end
    s.mini = s.mini + dt
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "moquette", floor_l = 2, paper = "righe", ceil = 4,
      lights = { { x = 66, y = 36, r = 22, l = 2 } } }, t)
    K.window(6, 14, 20, 16, K.views.night, t, s.win, 5)
    -- le casse, che respirano con la musica
    for _, x in ipairs({ 30, 104 }) do
      D.rect(x, 22, 12, 18, 2)
      D.circle(x + 6, 34, 3.5 + s.cone * 0.8, 5); D.circle(x + 6, 34, 1.5, 1)
      D.circle(x + 6, 26, 1.6, 5)
    end
    -- la scrivania con le macchine
    local ty = K.desk(54, 58, 5)
    D.rect(54, ty - 4, 26, 4, 3)
    for i = 0, 11 do D.rect(55 + i * 2, ty - 2, 1, 2, 11) end
    for i = 1, 8 do D.px(56 + i * 3, ty - 4, 3 + s.leds[i] * 12) end
    -- il norns, col suo piccolo schermo
    D.rect(84, ty - 5, 14, 5, 6)
    D.rect(86, ty - 4, 7, 3, 1)
    local fx = 86 + (s.mini * 2) % 7
    D.px(fx, ty - 3, 11)
    D.circle(95, ty - 2.5, 0.8, 9); D.circle(96.5, ty - 4, 0.6, 9)
    -- i cavi
    screen.level(D.lv(4)); screen.move(60, ty - 4); screen.curve(62, ty - 14, 82, ty - 14, 86, ty - 5); screen.stroke()
    screen.level(D.lv(3)); screen.move(70, ty - 4); screen.curve(72, ty - 10, 90, ty - 12, 92, ty - 5); screen.stroke()
    K.chair(46, 58, 1, 4)
    s.fig:draw()
  end,
  note = function(s, ev)
    s.cone = 1
    s.leds[random(1, 8)] = 1
  end,
}

end
