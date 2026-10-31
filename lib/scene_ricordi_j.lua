-- ANAMNESI · scene dei ricordi (v7): il paese, le case, la mente, l'abisso
-- Fondo nero, persone di luce. Nella fretta la macchina trema e corre;
-- nell'angoscia stringe, taglia, si avvicina troppo. Il ritmo si vede.
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S
local cam, hand, bars, shot, rays, ease, box, tremor = H.cam, H.hand, H.bars, H.shot, H.rays, H.ease, H.box, H.tremor

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(s) else screen.text(s) end
end

D.POSE.hammer_up = { lean = -4, nod = 10, ua1 = 150, ua2 = 40, fa1 = 175, fa2 = 90, th1 = 8, th2 = -8, sh1 = 0, sh2 = -3, hy = 7.1, rot = 0 }
D.POSE.hammer_down = { lean = 22, nod = 26, ua1 = 75, ua2 = 40, fa1 = 95, fa2 = 90, th1 = 12, th2 = -10, sh1 = -2, sh2 = -10, hy = 6.8, rot = 0 }
D.POSE.knead = { lean = 26, nod = 26, ua1 = 60, ua2 = 56, fa1 = 80, fa2 = 76, th1 = 4, th2 = -4, sh1 = 0, sh2 = -2, hy = 7.0, rot = 0 }
D.POSE.knead2 = { lean = 34, nod = 30, ua1 = 80, ua2 = 76, fa1 = 92, fa2 = 88, th1 = 4, th2 = -4, sh1 = 0, sh2 = -2, hy = 6.9, rot = 0 }
D.POSE.run = { lean = 22, nod = 4, ua1 = 60, ua2 = -50, fa1 = 110, fa2 = -10, th1 = 50, th2 = -40, sh1 = 10, sh2 = -70, hy = 6.8, rot = 0 }
D.POSE.march = { lean = -2, nod = 0, ua1 = 60, ua2 = 50, fa1 = 100, fa2 = 95, th1 = 30, th2 = -6, sh1 = 0, sh2 = -6, hy = 7.1, rot = 0 }
D.POSE.cling = { lean = 40, nod = 10, ua1 = 120, ua2 = 110, fa1 = 130, fa2 = 120, th1 = 30, th2 = 10, sh1 = -20, sh2 = -30, hy = 5.5, rot = 0 }
D.POSE.rock = { lean = 20, nod = 30, ua1 = 60, ua2 = 30, fa1 = 70, fa2 = 60, th1 = 4, th2 = -4, sh1 = 0, sh2 = -2, hy = 7.0, rot = 0 }

-- la figura che corre davvero: le braccia e le gambe a tempo veloce
local function corsa(f, dt, sp)
  f.walking = true
  f.ph = f.ph + dt * sp
  local s1, c1 = sin(f.ph), cos(f.ph)
  local p = { th1 = 45 * s1, th2 = -45 * s1, lean = 18, nod = 4, hy = 6.8 - 0.5 * abs(c1), rot = 0 }
  p.sh1 = p.th1 - 50 * max(0, -c1); p.sh2 = p.th2 - 50 * max(0, c1)
  p.ua1 = -50 * s1 + 10; p.ua2 = 50 * s1 + 10; p.fa1 = p.ua1 + 70; p.fa2 = p.ua2 + 70
  local k = min(1, dt * 16)
  for key, v in pairs(p) do f.cur[key] = f.cur[key] + (v - f.cur[key]) * k end
  f.t = f.t + dt
end

-------------------------------------------------------------------------------
-- LA BANDA DEL PAESE: marciano a tempo col tamburo grosso
-------------------------------------------------------------------------------
S.banda = {
  ritmo = true,
  init = function(s)
    s.band = {}
    for i = 1, 6 do s.band[i] = D.figura(-20 - i * 16, 56, { s = 0.95, l = 11 + (i == 1 and 4 or 0), pose = "march", face = 1 }) end
    s.x = 0; s.boom = 0
    s.kids = { D.figura(-150, 58, { s = 0.7, l = 14, child = true, speed = 6 }), D.figura(-162, 58, { s = 0.65, l = 13, child = true, speed = 6 }) }
  end,
  update = function(s, dt, t)
    s.x = s.x + dt * 9
    if s.x > 260 then s.x = 0 end
    s.boom = max(0, s.boom - dt * 5)
    for i, f in ipairs(s.band) do
      f.x = -20 + s.x - i * 16
      f.y = 56 - ((floor(t * 2 + i) % 2 == 0) and 0.6 or 0)
      f:update(dt)
    end
    for i, k in ipairs(s.kids) do k.x = s.band[6].x - 14 - i * 8 + sin(t * 3 + i) * 3; k.walking = true; k.ph = k.ph + dt * 9; k.face = 1; k:update(dt) end
  end,
  draw = function(s, t)
    -- la piazza: le arcate dei portici, le lucine della festa
    for i = 0, 4 do screen.level(D.lv(3)); screen.move(i * 28, 40); screen.line(i * 28, 24); screen.arc(i * 28 + 14, 24, 14, pi, 2 * pi); screen.line(i * 28 + 28, 40); screen.stroke() end
    for i = 0, 30 do D.px(i * 4.2, 6 + sin(i * 0.4) * 3, 5 + 8 * (0.5 + 0.5 * sin(t * 3 + i))) end
    D.line(0, 58, 127, 58, 3)
    for i, f in ipairs(s.band) do
      f:draw()
      -- gli strumenti: il primo ha il tamburo grosso
      if i == 1 then screen.level(D.lv(10 + s.boom * 5)); screen.circle(f.x + 4, f.y - 12, 4); screen.stroke()
      else D.line(f.hand[1], f.hand[2], f.hand[1] + 5, f.hand[2] - 3, 12) end
    end
    for _, k in ipairs(s.kids) do k:draw() end
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.boom = 1 end end,
}

-------------------------------------------------------------------------------
-- IL FABBRO: il martello cade dove cade il ritmo
-------------------------------------------------------------------------------
S.fabbro = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(52, 58, { s = KS, l = 14, pose = "hammer_up", face = 1,
      prop = function(x, y, f) local a = f.cur.ua1 / 180 * pi; local hx, hy = x + sin(a) * 5, y - cos(a) * 5; D.line(x, y, hx, hy, 9); D.rect(hx - 1.5, hy - 2, 4, 3, 13) end })
    s.sparks = D.parts(40)
    s.down = 0; s.heat = 1
  end,
  update = function(s, dt, t)
    s.down = max(0, s.down - dt)
    if s.down <= 0 then s.fig:set("hammer_up") end
    s.heat = max(0.3, s.heat - dt * 0.02)
    if s.heat <= 0.31 then s.heat = 1 end
    s.fig:update(dt)
    D.parts_update(s.sparks, dt, function(p, d) p.vy = p.vy + 60 * d end)
  end,
  draw = function(s, t)
    -- la forgia sullo sfondo: la bocca rossa
    D.line(96, 58, 96, 30, 4); D.line(122, 58, 122, 30, 4); D.line(96, 30, 122, 30, 4)
    for i = 0, 4 do D.line(102 + i * 3, 48, 102 + i * 3 + (D.noise(t * 6 + i) - 0.5) * 2, 48 - 6 * D.noise(t * 4 + i) * (0.5 + mac("fuoco")), 9 + (i % 2) * 5) end
    -- l'incudine
    D.poly({ 62, 44, 84, 44, 80, 47, 66, 47 }, 9); D.line(70, 47, 70, 58, 7); D.line(76, 47, 76, 58, 7); D.line(66, 58, 80, 58, 7)
    -- il ferro rovente sull'incudine
    D.line(68, 43, 80, 43, 8 + s.heat * 7)
    D.line(0, 58, 127, 58, 3)
    s.fig:draw()
    for _, p in ipairs(s.sparks.list) do D.px(p.x, p.y, 15 * (1 - (p.age or 0) / p.life)) end
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" and (ev.o == 1 or ev.o == 2) then
      s.fig:set("hammer_down"); s.down = 0.14
      for i = 1, 6 do D.spawn(s.sparks, { x = 74, y = 42, vx = R(-30, 30), vy = -R(10, 40), life = R(0.3, 0.8) }) end
    end
  end,
}

-------------------------------------------------------------------------------
-- IL TRENO CHE PARTE: corri, corri
-------------------------------------------------------------------------------
S.treno_perso = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(40, 58, { s = 1.2, l = 15, face = 1,
      prop = function(x, y, f) D.rect(f.x - 7, f.y - 12, 5, 4, 11) end })
    s.tx = 0; s.tv = 0; s.cyc = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 24 then s.cyc = 0; s.tx = 0; s.tv = 0 end
    if s.cyc > 3 then s.tv = min(40, s.tv + dt * (3 + mac("fretta") * 3)) end
    s.tx = s.tx + s.tv * dt
    corsa(s.fig, dt, 12 + mac("fretta") * 6)
    local old = s.fig.ph
    if floor(old / pi) ~= floor((old + dt * 12) / pi) then S.env.step("pietra", -0.2, 0.5) end
  end,
  draw = function(s, t)
    -- la macchina corre con lui: il marciapiede scorre veloce
    local o = t * 60
    for i = 0, 10 do local x = ((i * 16 - o) % 180) - 20; D.line(x, 60, x + 8, 60, 4) end
    for i = 0, 3 do local x = ((i * 60 - o * 0.7) % 260) - 40; D.line(x, 58, x, 22, 4); D.px(x, 21, 12); D.line(x - 4, 22, x + 4, 22, 5) end
    -- il treno: le carrozze che scivolano via, più veloci di lui
    local x0 = 60 - s.tx
    for c = 0, 3 do
      local x = x0 + c * 46
      if x < 140 and x > -50 then
        box(x, 24, 44, 26, 9)
        for w = 0, 3 do D.rect(x + 3 + w * 10, 28, 7, 7, 4); D.line(x + 3 + w * 10, 28, x + 10 + w * 10, 28, 12) end
        box(x + 40, 30, 3, 18, 6)
      end
    end
    -- le luci rosse in coda, quando se ne va
    local tail = x0 - 2
    if tail > -10 then D.px(tail, 46, 15); D.px(tail, 30, 15) end
    D.line(0, 52, 127, 52, 6)
    local ox, oy = tremor(t, 0.25 + mac("fretta") * 0.3)
    cam(ox, oy, function() s.fig:draw() end)
  end,
}

-------------------------------------------------------------------------------
-- LA BALERA
-------------------------------------------------------------------------------
S.balera = {
  ritmo = true,
  init = function(s)
    s.cp = {}
    for i = 1, 4 do s.cp[i] = { a = i * 1.6, r = R(14, 34), sp = R(0.25, 0.4), f1 = D.figura(0, 0, { s = 0.95, l = 12 + (i % 2) * 2, pose = "dance_a" }), f2 = D.figura(0, 0, { s = 0.9, l = 11 + (i % 2) * 3, pose = "hug", dress = true }) } end
    s.man = D.figura(112, 52, { s = 1.0, l = 12, pose = "lean_rail", face = -1 })
    s.pulse = 0
  end,
  update = function(s, dt, t)
    s.pulse = max(0, s.pulse - dt * 4)
    for _, c in ipairs(s.cp) do
      c.a = c.a + dt * c.sp
      local x, y = 56 + cos(c.a) * c.r * 1.4, 50 + sin(c.a) * 5
      local f = (sin(c.a * 3) > 0) and 1 or -1
      c.f1.x, c.f1.y, c.f1.face = x - 3 * f, y, f
      c.f2.x, c.f2.y, c.f2.face = x + 3 * f, y, -f
      c.f1:update(dt); c.f2:update(dt)
    end
    s.man:update(dt)
  end,
  draw = function(s, t)
    -- le lucine colorate a festoni
    for k = 0, 2 do for i = 0, 16 do local x = i * 8; D.px(x, 4 + k * 4 + sin(i * 0.8) * 2, 4 + 9 * (0.5 + 0.5 * sin(t * 2 + i + k)) + s.pulse * 3) end end
    -- il palco con l'orchestra: sagome piccole e i leggii
    D.line(4, 30, 40, 30, 5)
    for i = 0, 2 do D.circle(10 + i * 12, 24, 1.5, 9); D.line(10 + i * 12, 26, 10 + i * 12, 30, 7) end
    D.line(0, 56, 127, 56, 3)
    table.sort(s.cp, function(a, b) return a.f1.y < b.f1.y end)
    for _, c in ipairs(s.cp) do c.f1:draw(); c.f2:draw() end
    D.line(104, 42, 124, 42, 6); s.man:draw()
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.pulse = 1 end end,
}

-------------------------------------------------------------------------------
-- IL TEMPORALE IN PIAZZA
-------------------------------------------------------------------------------
S.temporale_piazza = {
  ritmo = true,
  init = function(s)
    s.rain = D.parts(90)
    s.people = {}
    for i = 1, 5 do s.people[i] = { f = D.figura(R(0, 128), 58, { s = 0.95, l = 11 + i % 3 * 2 }), v = R(20, 35) * pick({ -1, 1 }) } end
    s.flash = 0
  end,
  update = function(s, dt, t)
    local p = 0.5 + mac("pioggia")
    for i = 1, 4 do if random() < dt * 40 * p then D.spawn(s.rain, { x = R(0, 150), y = -2, vx = -12, vy = R(60, 80), life = 1 }) end end
    D.parts_update(s.rain, dt, function(q) if q.y > 58 then q.life = 0 end end)
    if random() < dt * 0.08 then s.flash = 1; S.env.sfx("sub", 36, 0.1, 2, 0, 0.2, 0.02) end
    s.flash = max(0, s.flash - dt * 3)
    for _, q in ipairs(s.people) do
      q.f.x = q.f.x + q.v * dt * (1 + mac("fretta"))
      q.f.face = q.v > 0 and 1 or -1
      if q.f.x > 140 then q.f.x = -12 elseif q.f.x < -12 then q.f.x = 140 end
      corsa(q.f, dt, 11)
    end
  end,
  draw = function(s, t)
    local f = s.flash
    -- i portici: si vedono davvero solo nel lampo
    for i = 0, 4 do screen.level(D.lv(3 + f * 9)); screen.move(i * 28, 46); screen.line(i * 28, 26); screen.arc(i * 28 + 14, 26, 14, pi, 2 * pi); screen.line(i * 28 + 28, 46); screen.stroke() end
    D.line(0, 58, 127, 58, 4 + f * 6)
    -- le pozzanghere che si increspano
    for i = 0, 5 do local x = 10 + i * 22; D.line(x, 60, x + 8, 60, 3 + 3 * sin(t * 8 + i)) end
    for _, q in ipairs(s.people) do
      q.f:draw()
      -- l'ombrello sopra la testa, a volte rovesciato
      local hx, hy = q.f.x, q.f.y - 24
      local inv = sin(t * 2 + q.f.x) > 0.8
      D.line(hx - 6, hy + (inv and -3 or 3), hx, hy, 10); D.line(hx, hy, hx + 6, hy + (inv and -3 or 3), 10); D.line(hx, hy, hx, hy + 8, 7)
    end
    for _, q in ipairs(s.rain.list) do D.line(q.x, q.y, q.x - 1, q.y + 3, 5 + f * 6) end
  end,
}

-------------------------------------------------------------------------------
-- IL BLACKOUT: le luci si spengono, le candele si accendono
-------------------------------------------------------------------------------
S.blackout = {
  init = function(s)
    s.win = {}
    for i = 1, 18 do s.win[i] = { x = 6 + (i - 1) % 9 * 13 + R(-1, 1), y = 22 + floor((i - 1) / 9) * 12, c = R(2, 12) } end
    s.cyc = 0
    s.st = D.stars_gen(60, 8, 0, 18)
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 45 then s.cyc = 0 end
  end,
  draw = function(s, t)
    local on = s.cyc < 6
    local out = s.cyc - 6
    if not on then D.stars(s.st, t, min(1, out / 6)) end
    -- le case: tetti e finestre
    for i = 0, 8 do local x = 2 + i * 13; D.line(x, 20, x + 6, 15, 3); D.line(x + 6, 15, x + 12, 20, 3) end
    for _, w in ipairs(s.win) do
      if on then
        D.rect(w.x, w.y, 4, 5, 12)
      elseif out > w.c then
        -- la candela: un punto che trema
        D.px(w.x + 2, w.y + 3, 10 + 5 * D.noise(t * 6 + w.x)); D.px(w.x + 2, w.y + 2, 6)
        box(w.x, w.y, 4, 5, 2)
      end
    end
    -- il lampione che si spegne per ultimo, sfarfallando
    local lamp = on and 1 or ((out < 1.5 and random() < 0.5) and 1 or 0)
    D.line(110, 58, 110, 40, 4); if lamp > 0 then D.px(110, 39, 15); rays(110, 40, 100, 120, 58, 3, 4) end
    D.line(0, 58, 127, 58, 3)
  end,
}

-------------------------------------------------------------------------------
-- DENTRO L'OROLOGIO DELLA TORRE: gli ingranaggi scattano col ritmo
-------------------------------------------------------------------------------
S.torre_orologio = {
  ritmo = true,
  init = function(s)
    s.g = { { x = 40, y = 30, r = 16, n = 12, a = 0, d = 1 }, { x = 70, y = 22, r = 10, n = 8, a = 0, d = -1.6 }, { x = 88, y = 40, r = 13, n = 10, a = 0, d = 1.23 }, { x = 22, y = 48, r = 8, n = 6, a = 0, d = -2 } }
    s.kick = 0
    s.fig = D.figura(110, 60, { s = 1.0, l = 14, pose = "look_up", face = -1 })
  end,
  update = function(s, dt, t)
    s.kick = max(0, s.kick - dt * 6)
    for _, g in ipairs(s.g) do g.a = g.a + dt * 0.15 * g.d + s.kick * dt * g.d * 2 end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    for _, g in ipairs(s.g) do
      screen.level(D.lv(8)); screen.circle(g.x, g.y, g.r); screen.stroke()
      D.circle(g.x, g.y, 1.5, 12)
      for i = 0, g.n - 1 do
        local a = g.a + i / g.n * 2 * pi
        D.line(g.x + cos(a) * g.r, g.y + sin(a) * g.r, g.x + cos(a) * (g.r + 2.5), g.y + sin(a) * (g.r + 2.5), 9)
        if i % 3 == 0 then D.line(g.x, g.y, g.x + cos(a) * g.r, g.y + sin(a) * g.r, 4) end
      end
    end
    -- il pendolo lungo
    local pa = sin(t * 2) * 0.35
    D.line(64, 0, 64 + sin(pa) * 44, cos(pa) * 44, 7); D.circle(64 + sin(pa) * 44, cos(pa) * 44, 3, 12)
    D.line(0, 60, 127, 60, 3)
    s.fig:draw()
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o <= 2 then s.kick = 1 end end,
}

-------------------------------------------------------------------------------
-- IL FORNO DI NOTTE
-------------------------------------------------------------------------------
S.forno = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 14, pose = "knead", face = 1 })
    s.flour = D.parts(20); s.k = 0
  end,
  update = function(s, dt, t)
    s.k = max(0, s.k - dt)
    if s.k <= 0 then s.fig:set("knead") end
    s.fig:update(dt)
    D.parts_update(s.flour, dt, function(p, d) p.vy = p.vy + 4 * d end)
  end,
  draw = function(s, t)
    -- la bocca del forno, rossa, a destra
    screen.level(D.lv(7)); screen.move(86, 46); screen.line(86, 34); screen.arc(102, 34, 16, pi, 2 * pi); screen.line(118, 46); screen.stroke()
    for i = 0, 6 do D.line(90 + i * 4, 46, 90 + i * 4 + (D.noise(t * 5 + i) - 0.5) * 2, 46 - 5 * D.noise(t * 3 + i), 8 + (i % 3) * 2) end
    for i = 0, 2 do D.line(92 + i * 9, 40, 98 + i * 9, 40, 12); D.line(92 + i * 9, 40, 95 + i * 9, 38, 10) end
    -- il tavolo, la pasta, la farina che vola
    D.line(46, 46, 80, 46, 8); D.line(48, 46, 48, 58, 5); D.line(78, 46, 78, 58, 5)
    D.circle(58 + s.k * 2, 44, 3 + s.k, 13)
    for _, p in ipairs(s.flour.list) do D.px(p.x, p.y, 10 * (1 - (p.age or 0) / p.life)) end
    D.line(0, 58, 127, 58, 3)
    -- l'orologio: le tre
    screen.level(D.lv(6)); screen.circle(20, 14, 5); screen.stroke(); D.line(20, 14, 20, 10, 9); D.line(20, 14, 23, 14, 9)
    s.fig:draw()
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" and ev.o == 1 then s.fig:set("knead2"); s.k = 0.2; for i = 1, 3 do D.spawn(s.flour, { x = 58, y = 42, vx = R(-6, 6), vy = -R(2, 6), life = 1.5 }) end end
  end,
}

-------------------------------------------------------------------------------
-- LA SVEGLIA: le sette e quaranta
-------------------------------------------------------------------------------
S.sveglia = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(64, 56, { s = KS, l = 15, speed = 7, on_step = H.steps("legno", 0.5) })
    s.ring = 0; s.min = 40
  end,
  update = function(s, dt, t)
    s.ring = max(0, s.ring - dt * 3)
    s.min = s.min + dt * (0.3 + mac("fretta") * 0.6)
    if s.min >= 60 then s.min = 40 end
    think(s.fig, function()
      return pick({ { { "walk", R(14, 50), 8 }, { "pose", "bend", 0.6 } }, { { "walk", R(70, 112), 8 }, { "pose", "reach_up", 0.5 } },
        { { "walk", R(30, 100), 9 }, { "pose", "hands_face", 0.6 } }, { { "pose", "bend", 0.4 }, { "walk", R(20, 110), 9 } } })
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, 0.15 + mac("fretta") * 0.35 + s.ring * 0.3)
    cam(ox, oy, function()
      D.line(0, 56, 127, 56, 3)
      -- la sveglia sul comodino, che salta quando suona
      local jx = s.ring > 0.3 and sin(t * 70) * 1 or 0
      screen.level(D.lv(12)); screen.circle(18 + jx, 36, 5); screen.stroke()
      D.circle(15 + jx, 30, 1.5, 12); D.circle(21 + jx, 30, 1.5, 12)
      local a = s.min / 60 * 2 * pi
      D.line(18 + jx, 36, 18 + jx + sin(a) * 4, 36 - cos(a) * 4, 14); D.line(18 + jx, 36, 18 + jx + 2, 36 + 1, 11)
      box(10, 41, 16, 15, 4)
      -- la caffettiera che trabocca sul fornello
      D.line(96, 40, 104, 40, 8); D.line(96, 40, 98, 30, 8); D.line(104, 40, 102, 30, 8); D.line(98, 30, 102, 30, 8)
      for i = 0, 2 do D.px(100 + sin(t * 4 + i) * 3, 28 - ((t * 10 + i * 3) % 10), 9) end
      -- le chiavi: un luccichio da qualche parte
      D.px(60 + sin(t * 0.3) * 30, 54, 10 + 5 * sin(t * 6))
      s.fig:draw()
    end)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o >= 3 then s.ring = 1 end end,
}

-------------------------------------------------------------------------------
-- LA NINNA NANNA: la culla dondola
-------------------------------------------------------------------------------
S.culla = {
  init = function(s)
    s.fig = D.figura(50, 58, { s = KS, l = 14, pose = "rock", face = 1 })
    s.a = 0
  end,
  update = function(s, dt, t)
    s.a = sin(t * 1.2)
    s.fig.x = 50 + s.a * 1.5
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- la finestra con la città che dorme
    box(90, 10, 26, 22, 4); D.line(103, 10, 103, 32, 3); D.line(90, 21, 116, 21, 3)
    for i = 0, 6 do D.px(92 + i * 3.5, 30 - (i % 3) * 2, 4 + (i % 2) * 6) end
    D.circle(110, 14, 1.5, 13)
    -- la culla: le stecche, la base a dondolo
    local cx, cy = 70, 52
    local r = s.a * 0.12
    local function P(dx, dy) return cx + dx * cos(r) - dy * sin(r), cy + dx * sin(r) + dy * cos(r) end
    local x1, y1 = P(-10, 0); local x2, y2 = P(10, 0); D.line(x1, y1, x2, y2, 11)
    local x3, y3 = P(-10, -8); local x4, y4 = P(10, -8); D.line(x3, y3, x4, y4, 9)
    for i = -10, 10, 3 do local a1, b1 = P(i, 0); local a2, b2 = P(i, -8); D.line(a1, b1, a2, b2, 6) end
    screen.level(D.lv(8)); screen.move(cx - 13, cy + 4 + s.a * 1.5); screen.curve(cx - 5, cy + 7, cx + 5, cy + 7, cx + 13, cy + 4 - s.a * 1.5); screen.stroke()
    -- il fagottino dentro, e il suo respiro
    local b = 0.5 + 0.5 * sin(t * 1.6)
    local bx, by = P(0, -3)
    D.circle(bx + 3, by, 1.6, 13); D.line(bx - 5, by + 1, bx + 1, by + 1 - b * 0.6, 11)
    D.line(0, 58, 127, 58, 3)
    s.fig:draw()
    -- le note della ninna nanna che salgono piano
    for i = 0, 2 do local k = ((t * 0.3 + i / 3) % 1); D.px(s.fig.x + 4 + sin(k * 6 + i) * 4, 30 - k * 24, 10 * (1 - k)) end
  end,
}

-------------------------------------------------------------------------------
-- LA LAVATRICE: i panni girano a tempo
-------------------------------------------------------------------------------
S.lavatrice = {
  ritmo = true,
  init = function(s)
    s.kid = D.figura(30, 60, { s = 1.2, l = 15, child = true, pose = "sit_ground", face = 1 })
    s.a = 0; s.spin = 0; s.cyc = 0; s.shake = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 50 then s.cyc = 0 end
    local spin = s.cyc > 36 and 1 or 0
    s.spin = D.lerp(s.spin, spin, dt * 0.5)
    s.a = s.a + dt * (1 + s.spin * 12 + mac("macchine") * 2)
    s.shake = max(0, s.shake - dt * 5)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, s.spin * 0.6 + s.shake * 0.2)
    cam(ox, oy, function()
      box(56, 16, 40, 42, 8)
      D.line(56, 24, 96, 24, 5); D.px(90, 20, 14)
      local cx, cy = 76, 40
      screen.level(D.lv(10)); screen.circle(cx, cy, 12); screen.stroke()
      screen.level(D.lv(4)); screen.circle(cx, cy, 10); screen.stroke()
      -- i panni dentro: tre cose che girano, una rossa (più chiara)
      for i = 0, 2 do
        local a = s.a + i * 2.1
        local r = 6 + sin(s.a * 0.7 + i) * 2 * (1 - s.spin)
        D.circle(cx + cos(a) * r, cy + sin(a) * r, 2, i == 0 and 14 or 7)
      end
    end)
    D.line(0, 58, 127, 58, 3)
    s.kid:draw()
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.shake = 1 end end,
}

-------------------------------------------------------------------------------
-- LA CENA IN SILENZIO: solo le forchette
-------------------------------------------------------------------------------
S.cena_silenzio = {
  ritmo = true,
  init = function(s)
    s.f = {}
    local xs = { 24, 44, 84, 104 }
    for i, x in ipairs(xs) do s.f[i] = D.figura(x, 54, { s = KS * 0.8, l = 11 + (i == 2 and 4 or 0), pose = "sit_read", face = x < 64 and 1 or -1, child = i == 2 }) end
    s.tick = {}
    for i = 1, 4 do s.tick[i] = 0 end
  end,
  update = function(s, dt, t)
    for i = 1, 4 do s.tick[i] = max(0, s.tick[i] - dt * 4) end
    for _, f in ipairs(s.f) do think(f, function() return pick({ { { "pose", "sit_read", R(4, 8) } }, { { "pose", "head_down", R(3, 6) } }, { { "pose", "sit", 3 } } }) end); f:update(dt) end
  end,
  draw = function(s, t)
    -- la lampada sopra la tavola: l'unica luce, un cono di linee
    D.line(64, 0, 64, 10, 5); D.line(58, 12, 70, 12, 10); D.line(58, 12, 61, 10, 8); D.line(70, 12, 67, 10, 8)
    rays(64, 12, 20, 108, 40, 2, 7)
    D.line(14, 40, 114, 40, 9)
    for i, f in ipairs(s.f) do
      f:draw()
      local px = f.x + f.face * 7
      D.line(px - 2, 39, px + 2, 39, 8)
      -- la forchetta che tocca il piatto: un lampo piccolo
      if s.tick[i] > 0 then D.px(px, 38, 15); D.line(px, 37, px + 1, 34, 12) end
    end
    -- il bicchiere, l'orologio
    D.line(64, 39, 64, 35, 9)
    screen.level(D.lv(5)); screen.circle(110, 14, 4); screen.stroke(); D.line(110, 14, 110 + sin(t * 0.1) * 3, 14 - cos(t * 0.1) * 3, 8)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" then s.tick[random(4)] = 1 end end,
}

-------------------------------------------------------------------------------
-- LA PORTA CHIUSA: le voci dall'altra parte
-------------------------------------------------------------------------------
S.porta_chiusa = {
  ritmo = true,
  init = function(s)
    s.kid = D.figura(30, 58, { s = 1.1, l = 15, child = true, pose = "curl", face = 1 })
    s.voice = 0; s.cyc = 0; s.beat = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 50 then s.cyc = 0 end
    local loud = s.cyc < 34 and (0.5 + 0.5 * sin(t * 0.9)) * (0.4 + mac("voci")) or 0
    s.voice = D.lerp(s.voice, loud, dt * 3)
    s.beat = max(0, s.beat - dt * 4)
    think(s.kid, function()
      if s.cyc > 40 then return { { "pose", "stand", 3 }, { "pose", "look_up", 3 } } end
      return pick({ { { "pose", "curl", R(3, 6) } }, { { "pose", "hands_face", R(3, 5) } }, { { "pose", "sit_ground", 3 } } })
    end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, s.voice * 0.25 + s.beat * 0.2)
    cam(ox, oy, function()
      -- la porta, e la luce sotto che trema con le voci
      box(70, 8, 26, 50, 7)
      D.px(92, 34, 12)
      D.line(71, 57, 95, 57, 6 + s.voice * 9)
      for i = 0, 3 do D.line(72 + i * 7, 58, 66 + i * 9, 63, 2 + s.voice * 5) end
      -- le voci: righe corte che escono dalla fessura e si spezzano
      for i = 0, 5 do
        if s.voice > 0.15 then
          local y = 12 + i * 7
          local w = s.voice * 10 * (0.5 + 0.5 * sin(t * 13 + i * 2))
          D.line(97, y, 97 + w, y + sin(t * 20 + i), 4 + s.voice * 8)
        end
      end
      D.line(0, 58, 127, 58, 3)
      -- se la porta si apre
      if s.cyc > 40 and s.cyc < 47 then D.line(70, 8, 64, 6, 10); D.line(64, 6, 64, 60, 10); rays(83, 30, 40, 70, 62, 6, 5) end
      s.kid:draw()
    end)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.beat = 1 end end,
}

-------------------------------------------------------------------------------
-- LA VALIGIA
-------------------------------------------------------------------------------
S.valigia = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 14, speed = 3, on_step = H.steps("legno", 0.3) })
    s.items = 0; s.lid = 1; s.cyc = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    think(s.fig, function()
      if s.items < 6 then return { { "walk", R(96, 112), 3 }, { "pose", "reach_up", 1.2 }, { "walk", 66, 3 }, { "face", 1 }, { "pose", "bend", 1 }, { "fn", function() s.items = s.items + 1 end } } end
      return { { "pose", "head_down", 2 }, { "fn", function() s.lid = 0 end }, { "pose", "sit", 3 }, { "pose", "stand", 2 }, { "pose", "head_down", 6 }, { "fn", function() s.items = 0; s.lid = 1 end } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- l'armadio aperto, la finestra con la pioggia
    box(98, 10, 22, 48, 5); D.line(109, 10, 109, 58, 3)
    box(14, 12, 22, 18, 4); for i = 0, 6 do D.px(16 + (i * 5) % 20, 14 + ((t * 8 + i * 4) % 15), 6) end
    -- il letto e la valigia sopra
    D.line(54, 46, 92, 46, 6); D.line(54, 46, 54, 56, 5); D.line(92, 46, 92, 56, 5)
    box(62, 40, 22, 6, 11)
    for i = 1, s.items do D.line(64 + (i - 1) * 3, 41 + (i % 2), 66 + (i - 1) * 3, 41 + (i % 2), 13 - i) end
    if s.lid > 0 then D.line(62, 40, 60, 30, 10); D.line(60, 30, 82, 30, 9); D.line(84, 40, 82, 30, 9)
    else D.line(62, 39, 84, 39, 12) end
    D.line(0, 58, 127, 58, 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL GIRADISCHI: balla da solo
-------------------------------------------------------------------------------
S.giradischi = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(76, 58, { s = KS, l = 15, pose = "dance_a", face = -1 })
    s.a = 0; s.bump = 0
  end,
  update = function(s, dt, t)
    s.a = s.a + dt * 3.4
    s.bump = max(0, s.bump - dt * 4)
    s.fig.x = 76 + sin(t * 0.4) * 10
    if floor(t * 0.5) % 2 == 0 then s.fig.face = -1 else s.fig.face = 1 end
    s.fig.y = 58 - s.bump * 0.8
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- il mobile, il piatto che gira, il braccio con la puntina
    box(8, 40, 34, 18, 6)
    screen.level(D.lv(10)); screen.circle(24, 40, 10); screen.stroke()
    for i = 0, 2 do local a = s.a + i * 2.1; D.line(24 + cos(a) * 3, 40 + sin(a) * 1.2, 24 + cos(a) * 9, 40 + sin(a) * 3.6, 5) end
    D.circle(24, 40, 1.5, 14)
    D.line(38, 32, 30, 38, 11); D.px(30, 38, 15)
    -- le note che escono: righe ondulate
    for i = 0, 3 do local k = ((t * 0.25 + i * 0.25) % 1); D.px(36 + k * 30, 30 - sin(k * 6 + i) * 6 - k * 10, 11 * (1 - k)) end
    D.line(0, 58, 127, 58, 3)
    K.rug(56, 100, 58, 4)
    s.fig:draw()
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o <= 2 then s.bump = 1 end end,
}

-------------------------------------------------------------------------------
-- LA CODA INFINITA
-------------------------------------------------------------------------------
S.coda_infinita = {
  ritmo = true,
  init = function(s)
    s.q = {}
    for i = 1, 12 do s.q[i] = D.figura(30 + i * 9, 56, { s = 0.9 - i * 0.02, l = i == 3 and 15 or 8, pose = "stand", face = -1 }) end
    s.n = 112; s.next = 99; s.tick = 0; s.closed = 0
  end,
  update = function(s, dt, t)
    s.tick = s.tick + dt
    if s.tick > 14 then s.tick = 0; s.next = s.next + 1 end
    s.closed = max(0, s.closed - dt)
    for i, f in ipairs(s.q) do
      think(f, function() return pick({ { { "pose", "stand", R(3, 6) } }, { { "pose", "head_down", 3 } }, { { "face", 1 }, { "pose", "stand", 1 }, { "face", -1 } } }) end)
      f:update(dt)
    end
  end,
  draw = function(s, t)
    -- lo sportello in fondo a sinistra, il tabellone, la fila che sfuma a destra
    box(4, 24, 18, 20, 7); D.line(4, 34, 22, 34, 5)
    if s.closed > 0 then txt(13, 31, "X", 12, true) end
    box(4, 8, 22, 10, 6); txt(15, 16, tostring(s.next), 13, true)
    box(98, 6, 26, 10, 4); txt(111, 14, tostring(s.n), 7, true)
    D.line(0, 56, 127, 56, 3)
    for i = #s.q, 1, -1 do s.q[i]:draw() end
    -- i fogli in mano a lui
    local f = s.q[3]; D.rect(f.hand[1] - 1, f.hand[2] - 3, 3, 4, 13)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 and random() < 0.05 then s.closed = 3 end end,
}

-------------------------------------------------------------------------------
-- L'ESAME: il foglio bianco, l'orologio che corre
-------------------------------------------------------------------------------
S.esame = {
  ritmo = true,
  init = function(s)
    s.me = D.figura(64, 58, { s = KS, l = 15, pose = "hands_face", face = 1 })
    s.others = {}
    for i = 1, 4 do s.others[i] = D.figura(pick({ 18, 30, 98, 110 }) + i, 58, { s = KS * 0.75, l = 8, pose = "sit_read", face = 1 }) end
    s.others[1].x, s.others[2].x, s.others[3].x, s.others[4].x = 16, 32, 96, 112
    s.clock = 0; s.beat = 0
  end,
  update = function(s, dt, t)
    s.clock = s.clock + dt * (0.5 + mac("fretta") * 1.5)
    s.beat = max(0, s.beat - dt * 4)
    think(s.me, function() return pick({ { { "pose", "hands_face", R(2, 4) } }, { { "pose", "sit_read", R(1, 2) } }, { { "pose", "look_up", 1 } } }) end)
    s.me:update(dt)
    for _, f in ipairs(s.others) do f:update(dt) end
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, s.beat * 0.4 + mac("fretta") * 0.2)
    -- l'orologio sopra la lavagna, che corre
    local zoom = 1 + mac("battito") * 0.3
    box(34, 4, 60, 18, 3)
    screen.level(D.lv(12)); screen.circle(64, 13, 6 * zoom); screen.stroke()
    D.line(64, 13, 64 + sin(s.clock) * 5 * zoom, 13 - cos(s.clock) * 5 * zoom, 15)
    D.line(64, 13, 64 + sin(s.clock / 12) * 3, 13 - cos(s.clock / 12) * 3, 12)
    cam(ox, oy, function()
      for _, f in ipairs(s.others) do
        f:draw()
        -- le loro penne che scrivono: righe che si allungano
        local k = (t * 0.2 + f.x * 0.1) % 1
        D.line(f.x + 4, 44, f.x + 4 + k * 8, 44, 6)
      end
      -- il banco, il foglio bianco: l'unica cosa luminosa oltre a lui
      D.line(52, 46, 80, 46, 6)
      D.rect(60, 43, 10, 3, 14)
      s.me:draw()
    end)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.beat = 1 end end,
}

-------------------------------------------------------------------------------
-- IN RITARDO: corridoi, porte che si spostano
-------------------------------------------------------------------------------
S.ritardo = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(44, 58, { s = 1.25, l = 15, face = 1 })
    s.o = 0; s.cut = 0; s.n = random(100, 400)
  end,
  update = function(s, dt, t)
    local sp = 30 + mac("fretta") * 40
    s.o = s.o + dt * sp
    corsa(s.fig, dt, 10 + mac("fretta") * 8)
    s.cut = max(0, s.cut - dt)
  end,
  draw = function(s, t)
    if s.cut > 0 then return end
    -- il corridoio in prospettiva che scorre: porte tutte uguali, numeri che saltano
    local ox, oy = tremor(t, 0.3 + mac("nevrosi") * 0.4)
    cam(ox, oy, function()
      D.line(0, 10, 127, 10, 3); D.line(0, 58, 127, 58, 4)
      for i = 0, 7 do
        local x = ((i * 26 - s.o) % 210) - 30
        box(x, 18, 14, 40, 7)
        D.px(x + 11, 38, 12)
        txt(x + 7, 16, tostring((s.n + i * 7 + floor(s.o / 210) * 3) % 999), 6, true)
      end
      for i = 0, 3 do local x = ((i * 50 - s.o * 1.6) % 240) - 30; D.line(x, 10, x + 6, 12, 6) end
      s.fig:draw()
    end)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 and random() < 0.08 then s.cut = 0.12; s.n = random(100, 900) end end,
}

-------------------------------------------------------------------------------
-- LA FOLLA: spalle, gomiti, niente aria
-------------------------------------------------------------------------------
S.folla_panico = {
  ritmo = true,
  init = function(s)
    s.me = D.figura(64, 60, { s = 1.3, l = 15, pose = "hands_face", face = 1 })
    s.crowd = {}
    for i = 1, 16 do s.crowd[i] = { x = R(0, 128), y = R(50, 66), v = R(4, 10) * pick({ -1, 1 }), h = R(24, 34), l = R(4, 8) } end
    s.beat = 0; s.press = 0
  end,
  update = function(s, dt, t)
    s.beat = max(0, s.beat - dt * 4)
    s.press = 0.5 + 0.5 * sin(t * 0.25)
    for _, c in ipairs(s.crowd) do
      c.x = c.x + c.v * dt * (1 + mac("folla"))
      c.x = c.x + (64 - c.x) * dt * 0.08 * s.press
      if c.x > 140 then c.x = -12 elseif c.x < -12 then c.x = 140 end
    end
    s.me.shake = 0.3 + mac("tormento") * 0.5
    think(s.me, function() return pick({ { { "pose", "hands_face", 2 } }, { { "pose", "look_up", 1.5 } }, { { "pose", "cry", 2 } } }) end)
    s.me:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, 0.2 + s.beat * 0.5 + mac("tormento") * 0.3)
    cam(ox, oy, function()
      -- il cielo, quando c'è: una striscia che si stringe
      local gap = 8 * (1 - s.press)
      if gap > 1 then D.line(64 - gap * 4, 2, 64 + gap * 4, 2, 6) end
      s.me:draw()
      -- la folla: spalle e teste, scure, davanti e dietro
      table.sort(s.crowd, function(a, b) return a.y < b.y end)
      for _, c in ipairs(s.crowd) do
        if abs(c.x - 64) > 6 or c.y > 62 then
          D.line(c.x - 5, c.y - c.h, c.x + 5, c.y - c.h, c.l); D.line(c.x - 5, c.y - c.h, c.x - 4, c.y, c.l - 1); D.line(c.x + 5, c.y - c.h, c.x + 4, c.y, c.l - 1)
          D.circle(c.x, c.y - c.h - 3, 2.6, c.l, true)
        end
      end
    end)
    if s.beat > 0.6 then screen.level(4); screen.rect(0.5, 0.5, 127, 63); screen.stroke() end
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.beat = 1 end end,
}

-------------------------------------------------------------------------------
-- LE CHIAMATE PERSE
-------------------------------------------------------------------------------
S.chiamate = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(30, 58, { s = KS, l = 14, pose = "sit_think", face = 1 })
    s.calls = 6; s.ring = 0; s.edge = 0; s.rt = 0
  end,
  update = function(s, dt, t)
    s.rt = s.rt + dt
    local cyc = s.rt % 9
    s.ring = (cyc < 5) and 1 or 0
    if cyc < dt then s.calls = s.calls + 1; if s.calls > 14 then s.calls = 6; s.edge = 0 end end
    if s.ring > 0 then s.edge = min(1, s.edge + dt * 0.01) end
    think(s.fig, function() return pick({ { { "pose", "sit_think", R(4, 8) } }, { { "pose", "hands_face", 3 } }, { { "pose", "sit_slump", 4 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- il tavolo, il telefono che vibra verso il bordo
    D.line(50, 44, 110, 44, 7); D.line(54, 44, 54, 58, 4); D.line(106, 44, 106, 58, 4)
    local px = 76 + s.edge * 26
    local jx = s.ring > 0 and sin(t * 60) * 0.8 or 0
    box(px + jx, 40, 8, 3, 11)
    -- lo schermo: acceso quando chiama
    if s.ring > 0 then D.line(px + 1 + jx, 41, px + 7 + jx, 41, 15) end
    -- il numero delle chiamate perse, piccolo, sopra
    txt(px + 4, 36, tostring(s.calls), s.ring > 0 and 13 or 6, true)
    if s.ring > 0 then for k = 1, 2 do screen.level(D.lv(6 / k)); screen.circle(px + 4, 41, 4 + k * 3 + (t * 8 % 3)); screen.stroke() end end
    D.line(0, 58, 127, 58, 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ACQUA CHE SALE
-------------------------------------------------------------------------------
S.acqua_sale = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(60, 58, { s = KS, l = 15, speed = 4 })
    s.lvl = 0; s.photo = { x = 40 }
  end,
  update = function(s, dt, t)
    s.lvl = s.lvl + dt * (0.6 + mac("fretta") * 0.8)
    if s.lvl > 44 then s.lvl = 0 end
    s.photo.x = s.photo.x + sin(t * 0.3) * dt * 6
    think(s.fig, function() return pick({ { { "walk", 110, 5 }, { "pose", "push", 1.5 } }, { { "walk", 20, 5 }, { "pose", "reach_up", 1 } }, { { "pose", "look_up", 1 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local wy = 58 - s.lvl
    local ox, oy = tremor(t, 0.1 + s.lvl / 44 * 0.4)
    cam(ox, oy, function()
      -- la stanza: la porta chiusa, la finestra, il tavolo, le sedie
      box(104, 18, 16, 40, 8); D.px(108, 38, 13)
      box(16, 12, 22, 16, 5)
      D.line(50, 44, 80, 44, 7); D.line(52, 44, 52, 58, 5); D.line(78, 44, 78, 58, 5)
      D.line(0, 58, 127, 58, 3)
      s.fig:draw()
      -- l'acqua: la superficie che ondeggia e copre tutto quello che c'è sotto
      local px, py
      for x = 0, 128, 3 do
        local y = wy + sin(x * 0.15 + t * 2) * 1.2
        if px then D.line(px, py, x, y, 11) end
        px, py = x, y
      end
      for r = 1, 4 do local y = wy + r * 4; if y < 64 then for x = (t * 6 + r * 7) % 12, 128, 12 do D.line(x, y, x + 4, y, 4) end end end
      -- la fotografia che galleggia
      local fx = 20 + (s.photo.x % 90)
      box(fx, wy - 2, 6, 3, 13)
    end)
  end,
}

-------------------------------------------------------------------------------
-- IL TRENO CHE NON SI FERMA
-------------------------------------------------------------------------------
S.treno_folle = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(40, 56, { s = 1.6, l = 15, pose = "lean_rail", face = 1 })
    s.o = 0; s.sp = 30; s.flash = 0
  end,
  update = function(s, dt, t)
    s.sp = min(160, s.sp + dt * (3 + mac("fretta") * 6))
    if s.sp >= 160 then s.sp = 40 end
    s.o = s.o + dt * s.sp
    s.flash = max(0, s.flash - dt * 4)
    if floor((s.o - dt * s.sp) / 400) ~= floor(s.o / 400) then s.flash = 1 end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- dentro la carrozza: il finestrino grande, fuori il mondo che scappa
    box(56, 10, 66, 30, 9)
    local o = s.o
    for i = 0, 10 do local x = 56 + ((i * 17 - o * 0.6) % 70); D.line(x, 34, x, 24 - (i % 3) * 3, 4) end
    for i = 0, 20 do local x = 56 + ((i * 7 - o * 1.5) % 66); D.line(x, 38, x + 3, 38, 6) end
    -- la stazione che passa: un lampo bianco con il nome
    if s.flash > 0 then D.line(58, 20, 120, 20, 15 * s.flash); txt(89, 30, H.lang() == 1 and "CASA" or "HOME", 15 * s.flash, true) end
    -- i sedili, la carrozza vuota
    for i = 0, 2 do D.line(4 + i * 16, 44, 4 + i * 16, 56, 5); D.line(4 + i * 16, 44, 12 + i * 16, 44, 6) end
    D.line(0, 58, 127, 58, 3)
    local ox, oy = tremor(t, 0.15 + s.sp / 160 * 0.4)
    cam(ox, oy, function() s.fig:draw() end)
  end,
}

-------------------------------------------------------------------------------
-- LE OMBRE CHE SI ALLUNGANO
-------------------------------------------------------------------------------
S.ombre = {
  init = function(s)
    s.fig = D.figura(84, 56, { s = KS, l = 15, pose = "sit_ground", face = -1 })
    s.cyc = 0; s.lamp = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 50 then s.cyc = 0 end
    s.lamp = D.lerp(s.lamp, (s.cyc > 38) and 1 or 0, dt * 2)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(5, 9) } }, { { "pose", "head_down", 4 } } }) end)
    if s.cyc > 36 and not s.reached then s.reached = true; s.fig:clear(); s.fig:act({ { "pose", "reach_up", 1 } }) end
    if s.cyc < 1 then s.reached = false end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local k = min(1, s.cyc / 34) * (1 - s.lamp)
    -- la finestra a sinistra: il sole che cala, una riga che si abbassa
    box(8, 10, 20, 26, 5)
    D.line(9, 12 + k * 22, 27, 12 + k * 22, 14 * (1 - k * 0.8))
    -- i mobili e le loro ombre, linee che si allungano verso di lui
    local obj = { { 40, 56, 10 }, { 54, 56, 16 }, { 30, 56, 22 } }
    for _, o in ipairs(obj) do
      D.line(o[1], o[2], o[1], o[2] - o[3], 7)
      local len = 10 + k * 70
      for j = 0, 3 do D.line(o[1] + j, o[2] - j * 0.5, o[1] + len + j, o[2] - j * 0.5, 2 + (1 - k) * 2) end
    end
    D.line(0, 56, 127, 56, 3)
    -- la lampada che si accende
    D.line(110, 56, 110, 28, 5); D.line(104, 28, 116, 28, 8)
    if s.lamp > 0.05 then D.px(110, 30, 15 * s.lamp); rays(110, 30, 70, 127, 56, 4 * s.lamp, 6) end
    s.fig.l = 15 - k * 6
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CADUTA: le cose cadono con te
-------------------------------------------------------------------------------
S.caduta_libera = {
  init = function(s)
    s.fig = D.figura(64, 34, { s = 1.3, l = 15, pose = "float", face = 1 })
    s.things = {}
    for i = 1, 8 do s.things[i] = { x = R(4, 124), y = R(0, 64), v = R(-8, 8), k = random(4), r = R(0, 6) } end
    s.streak = {}
    for i = 1, 30 do s.streak[i] = { x = R(0, 128), y = R(0, 64), v = R(60, 120) } end
  end,
  update = function(s, dt, t)
    local f = 1 + mac("fretta")
    for _, st in ipairs(s.streak) do st.y = st.y - st.v * dt * f; if st.y < -6 then st.y = 70; st.x = R(0, 128) end end
    for _, o in ipairs(s.things) do o.y = o.y + o.v * dt; o.r = o.r + dt; if o.y > 70 then o.y = -6 elseif o.y < -6 then o.y = 70 end end
    s.fig.y = 34 + sin(t * 0.7) * 3
    think(s.fig, function() return pick({ { { "pose", "float", R(3, 6) } }, { { "pose", "arms_open", R(3, 5) } }, { { "pose", "curl", 3 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- le righe del vento che sale: noi cadiamo, il mondo va su
    for _, st in ipairs(s.streak) do D.line(st.x, st.y, st.x, st.y + 4, 3) end
    -- le cose che cadono con noi: una sedia, una lettera, un orologio, una scarpa
    for _, o in ipairs(s.things) do
      local c, sn = cos(o.r), sin(o.r)
      if o.k == 1 then D.line(o.x - 3 * c, o.y - 3 * sn, o.x + 3 * c, o.y + 3 * sn, 9); D.line(o.x + 3 * c, o.y + 3 * sn, o.x + 3 * c + 3 * sn, o.y + 3 * sn - 3 * c, 9)
      elseif o.k == 2 then D.line(o.x - 2, o.y, o.x + 2, o.y + sn, 12); D.line(o.x - 2, o.y, o.x, o.y + 1, 9)
      elseif o.k == 3 then screen.level(D.lv(10)); screen.circle(o.x, o.y, 2.5); screen.stroke(); D.line(o.x, o.y, o.x + c * 2, o.y + sn * 2, 13)
      else D.line(o.x - 2, o.y, o.x + 2, o.y, 9); D.line(o.x - 2, o.y, o.x - 2, o.y - 2, 9) end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL MARTELLO: la macchina enorme che batte
-------------------------------------------------------------------------------
S.martello = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(30, 60, { s = 1.2, l = 15, pose = "curl", face = 1 })
    s.y = 0; s.v = 0; s.shake = 0; s.dust = D.parts(30)
  end,
  update = function(s, dt, t)
    s.y = D.lerp(s.y, 0, dt * 1.2)
    s.shake = max(0, s.shake - dt * 3)
    D.parts_update(s.dust, dt, function(p, d) p.vy = p.vy + 30 * d end)
    think(s.fig, function() return pick({ { { "pose", "curl", R(4, 6) } }, { { "pose", "hands_face", 3 } }, { { "pose", "kneel", 3 } } }) end)
    s.fig.shake = s.shake * 0.5
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, s.shake)
    cam(ox, oy, function()
      -- i montanti, la testa del martello che sale e cade
      D.line(70, 0, 70, 58, 5); D.line(104, 0, 104, 58, 5)
      local hy = 6 + (1 - s.y) * 0 + s.y * 40
      box(74, hy, 26, 12, 12)
      D.line(87, 0, 87, hy, 7)
      D.line(66, 58, 108, 58, 9)
      for _, p in ipairs(s.dust.list) do D.px(p.x, p.y, 8) end
      D.line(0, 60, 127, 60, 3)
      s.fig:draw()
    end)
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" and ev.o == 1 then
      s.y = 1; s.shake = 1
      for i = 1, 5 do D.spawn(s.dust, { x = R(76, 98), y = 57, vx = R(-20, 20), vy = -R(5, 15), life = 1 }) end
    end
  end,
}

-------------------------------------------------------------------------------
-- IL FIUME NERO: il traghettatore
-------------------------------------------------------------------------------
S.fiume_nero = {
  init = function(s)
    s.boat = 140; s.wait = 0
    s.me = D.figura(18, 44, { s = 1.15, l = 15, pose = "stand", face = 1 })
    s.old = D.figura(0, 0, { s = 1.0, l = 10, pose = "bend", face = -1, bent = 20 })
  end,
  update = function(s, dt, t)
    if s.wait > 0 then
      s.wait = s.wait - dt
      if s.wait > 4 and s.wait < 6 then s.old:set("wave") else s.old:set("bend") end
    else
      s.boat = s.boat - dt * 4
      if s.boat < 40 and s.boat > 39 then s.wait = 10; s.boat = 38.9 end
      if s.boat < -30 then s.boat = 140 end
    end
    s.old:update(dt); s.me:update(dt)
  end,
  draw = function(s, t)
    -- la riva, il fiume: righe nere che quasi non si muovono
    D.line(0, 44, 30, 44, 5)
    for r = 0, 5 do local y = 48 + r * 3; for x = (t * (1 + r * 0.3)) % 16, 128, 16 do D.line(x, y, x + 6, y, 2 + r * 0.3) end end
    -- la barca con la lanterna, e il vecchio
    local bx, by = s.boat, 48 + sin(t * 0.8) * 0.8
    D.line(bx - 12, by, bx + 12, by, 9); D.line(bx - 12, by, bx - 15, by - 3, 8); D.line(bx + 12, by, bx + 15, by - 3, 8)
    D.line(bx + 10, by, bx + 10, by - 14, 6); D.px(bx + 10, by - 15, 15); rays(bx + 10, by - 14, bx, bx + 20, by + 8, 3, 3)
    s.old.x, s.old.y = bx - 2, by
    s.old:draw()
    -- il remo
    D.line(s.old.hand[1], s.old.hand[2], bx - 10 + sin(t) * 3, by + 6, 7)
    s.me:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ULTIMO TRENO
-------------------------------------------------------------------------------
S.ultimo_treno = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(46, 54, { s = 1.4, l = 14, pose = "sit_slump", face = 1 })
    s.o = 0; s.bump = 0
  end,
  update = function(s, dt, t)
    s.o = s.o + dt * 40
    s.bump = max(0, s.bump - dt * 5)
    think(s.fig, function() return pick({ { { "pose", "sit_slump", R(6, 10) } }, { { "pose", "sit", 4 } }, { { "pose", "head_down", 5 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- fuori: solo i sassi della massicciata illuminati dai finestrini
    for i = 0, 30 do local x = ((i * 9 - s.o * 1.4) % 140) - 6; D.px(x, 60 + (i % 3), 4 + (i % 4) * 2) end
    -- dentro: il finestrino, il sedile, il cappello dimenticato
    box(60, 12, 50, 24, 7)
    for i = 0, 3 do local x = 60 + ((i * 19 - s.o * 0.2) % 50); D.px(x, 30, 9) end
    D.line(32, 30, 32, 44, 6); D.line(32, 44, 60, 44, 6); D.line(36, 44, 36, 54, 4); D.line(56, 44, 56, 54, 4)
    D.line(84, 46, 108, 46, 6); D.line(92, 44, 100, 44, 11); D.line(94, 42, 98, 42, 11)
    D.line(0, 54, 127, 54, 4)
    s.fig.y = 54 - s.bump * 0.6
    s.fig:draw()
    -- la sua testa contro il vetro: il riflesso
    D.circle(64, 22, 2, 4, true)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.bump = 1 end end,
}

-------------------------------------------------------------------------------
-- LA GABBIA: quattro passi, girarsi, quattro passi
-------------------------------------------------------------------------------
S.gabbia = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(50, 58, { s = 1.25, l = 15, speed = 4, on_step = H.steps("metallo", 0.4) })
    s.looks = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.15 then return { { "walk", 74, 4 }, { "face", 1 }, { "pose", "look_up", 4 }, { "pose", "stand", 3 } } end
      return { { "walk", 40, 4 + mac("tormento") * 4 }, { "walk", 74, 4 + mac("tormento") * 4 } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- le sbarre: davanti e dietro, e la porta aperta a destra
    for i = 0, 10 do local x = 30 + i * 6; D.line(x, 14, x, 58, 4) end
    D.line(30, 14, 90, 14, 6); D.line(30, 58, 90, 58, 6)
    s.fig:draw()
    for i = 0, 10 do local x = 28 + i * 6.4; if i ~= 9 then D.line(x, 12, x, 60, 8) end end
    -- la porta: aperta, e dietro di lei il buio con un filo di luce
    D.line(90, 12, 100, 16, 9); D.line(100, 16, 100, 60, 9); D.line(90, 60, 100, 60, 9)
    for i = 0, 3 do D.line(92 + i * 2, 20, 98 + i * 6, 62, 2) end
  end,
}

-------------------------------------------------------------------------------
-- IL VENTO CHE URLA
-------------------------------------------------------------------------------
S.urlo = {
  init = function(s)
    s.fig = D.figura(56, 46, { s = 1.3, l = 15, pose = "cling", face = 1 })
    s.lines = {}
    for i = 1, 30 do s.lines[i] = { x = R(0, 128), y = R(0, 64), v = R(80, 160), w = R(6, 20) } end
    s.calm = 0
  end,
  update = function(s, dt, t)
    local v = mac("vento")
    s.calm = (sin(t * 0.15) > 0.92) and 1 or 0
    for _, l in ipairs(s.lines) do l.x = l.x + l.v * dt * (0.4 + v) * (1 - s.calm * 0.9); if l.x > 140 then l.x = -20; l.y = R(0, 64) end end
    s.fig.shake = (0.4 + v * 0.6) * (1 - s.calm)
    s.fig.flap = 1 - s.calm
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, (0.3 + mac("vento") * 0.5) * (1 - s.calm))
    cam(ox, oy, function()
      -- la roccia: un crinale spezzato
      D.line(0, 50, 30, 46, 8); D.line(30, 46, 62, 48, 8); D.line(62, 48, 90, 54, 8); D.line(90, 54, 127, 52, 8)
      s.fig:draw()
      for _, l in ipairs(s.lines) do D.line(l.x, l.y, l.x + l.w, l.y + sin(l.x * 0.1) * 1.5, 4 + (l.w / 20) * 4) end
    end)
  end,
}

-------------------------------------------------------------------------------
-- LA LUCE IN FONDO
-------------------------------------------------------------------------------
S.luce_fondo = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = 1.2, l = 15, pose = "stand", face = 1 })
    s.z = 0; s.cyc = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    s.z = s.z + dt * (0.02 + s.z * 0.04)
    if s.z > 1 then s.z = 0; s.cyc = 0 end
    s.fig.walking = s.z < 0.92
    if s.fig.walking then s.fig.ph = s.fig.ph + dt * (3 + s.z * 4) end
    if s.z > 0.92 and s.fig.idle then s.fig:act({ { "face", -1 }, { "pose", "wave", 3 }, { "face", 1 } }) end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- il tunnel: anelli che vengono incontro, la luce in fondo che cresce
    local r0 = 3 + s.z * 30
    for i = 0, 7 do
      local k = ((i / 8) + s.z * 3) % 1
      local r = 4 + k * k * 80
      screen.level(D.lv(2 + k * 4)); screen.circle(64, 30, r); screen.stroke()
    end
    -- la luce vera: piena, non spenta come le superfici
    D.bright = true; D.circle(64, 30, r0, min(11, 6 + s.z * 6)); D.bright = false
    if r0 > 6 then rays(64, 30, 64 - r0 * 3, 64 + r0 * 3, 64, 2 + s.z * 6, 7) end
    s.fig:draw()
  end,
}

end
