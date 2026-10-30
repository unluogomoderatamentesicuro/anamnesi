-- ANAMNESI · scene dei ricordi nuovi (v3), dal cielo all'infanzia
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

D.POSE.caress = { lean = 10, nod = 20, ua1 = 85, ua2 = 16, fa1 = 105, fa2 = 66, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.stir = { lean = 8, nod = 22, ua1 = 50, ua2 = 30, fa1 = 95, fa2 = 70, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.trace = { lean = -2, nod = -4, ua1 = 95, ua2 = 8, fa1 = 95, fa2 = 4, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.hold = { lean = 4, nod = 20, ua1 = 45, ua2 = 40, fa1 = 100, fa2 = 95, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }

-- un'erbetta di primo piano, mossa dal vento
local function prato(s, y, l, wind, t)
  s.grass = s.grass or D.grass_gen(random(999), 70, 0, 128, 2, 5)
  D.grass(s.grass, y, t, l, wind)
end

-------------------------------------------------------------------------------
-- LA FELICITÀ: un pomeriggio qualunque, un aquilone, l'erba
-------------------------------------------------------------------------------
S.felicita = {
  init = function(s)
    s.clouds = { { 10, 12, 22, 0.6 }, { 70, 8, 18, 0.4 }, { 120, 18, 26, 0.5 } }
    s.fig = D.figura(44, 54, { s = 1.05, l = 3, dark = true, pose = "lie" })
    s.kid = D.figura(86, 54, { s = 0.85, l = 3, dark = true, child = true, speed = 9, on_step = H.steps("erba", 0.25) })
    s.kite = { x = 100, y = 16 }
    s.flowers = {}
    for i = 1, 24 do s.flowers[i] = { x = R(0, 128), y = R(50, 62), l = pick({ 13, 15, 11 }), ph = R(0, 6) } end
    s.sw = {}
    for i = 1, 4 do s.sw[i] = { x = R(0, 128), y = R(10, 30), v = R(18, 30), p = R(0, 6) } end
    s.bell = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.45 then return { { "pose", "lie", R(8, 14) } } end
      if r < 0.75 then return { { "pose", "sit_ground", R(6, 10) }, { "pose", "look_up", 4 } } end
      return { { "pose", "sit_ground", 3 }, { "pose", "arms_open", 4 }, { "pose", "lie", 6 } }
    end)
    think(s.kid, function() return { { "walk", R(70, 118), 9 }, { "pose", "look_up", R(2, 4) }, { "walk", R(70, 118), 7 } } end)
    s.fig:update(dt); s.kid:update(dt)
    local tx = s.kid.x + 14 + sin(t * 0.3) * 8
    local ty = 14 + sin(t * 0.7) * 4
    s.kite.x = s.kite.x + (tx - s.kite.x) * dt * 0.8
    s.kite.y = s.kite.y + (ty - s.kite.y) * dt * 0.8
    for _, b in ipairs(s.sw) do b.x = b.x + b.v * dt; if b.x > 140 then b.x = -10; b.y = R(8, 30) end end
    if random() < dt * mac("campane") * 0.08 then s.bell = 1 end
    s.bell = max(0, s.bell - dt * 0.3)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 40, 8 + lu * 3, 12 + lu * 2)
    D.circle(24, 12, 6, 15); D.circle(24, 12, 8, 13 + lu)
    K.clouds(s.clouds, t, 14)
    -- colline e il campanile lontano
    D.rect(0, 38, 128, 26, 7)
    for x = 0, 127 do local h = 4 + sin(x * 0.05) * 3 + sin(x * 0.13) * 1.5; D.rect(x, 38 - h, 1, h, 8) end
    D.rect(112, 22, 4, 14, 6); D.poly({ 111, 22, 117, 22, 114, 17 }, 6)
    local bs = sin(t * 4) * s.bell * 0.6
    D.rect(113 + bs, 24, 2, 2, 12)
    D.rect(0, 46, 128, 18, 9)
    for _, f in ipairs(s.flowers) do D.px(f.x + sin(t + f.ph), f.y, f.l) end
    -- il filo e l'aquilone
    local hx, hy = s.kid.hand[1] or s.kid.x, s.kid.hand[2] or 46
    screen.level(D.lv(5)); screen.move(hx, hy); screen.curve(hx + 6, hy - 14, s.kite.x - 6, s.kite.y + 10, s.kite.x, s.kite.y + 4); screen.stroke()
    D.poly({ s.kite.x, s.kite.y - 4, s.kite.x + 3, s.kite.y, s.kite.x, s.kite.y + 4, s.kite.x - 3, s.kite.y }, 2)
    for i = 1, 4 do D.px(s.kite.x - i + sin(t * 3 + i) * 1.5, s.kite.y + 4 + i * 2, 4) end
    for _, b in ipairs(s.sw) do
      local w = sin(t * 10 + b.p) * 1.5
      D.line(b.x - 2, b.y - w, b.x, b.y, 3); D.line(b.x, b.y, b.x + 2, b.y - w, 3)
    end
    s.fig:draw(); s.kid:draw()
    prato(s, 64, 6, 0.6, t)
  end,
}

-------------------------------------------------------------------------------
-- IL GIARDINO: le rose della nonna, la canna dell'acqua, il cane
-------------------------------------------------------------------------------
S.giardino = {
  init = function(s)
    s.nonna = D.figura(78, 56, { s = 1.2, l = 3, dark = true, dress = true, bun = true, pose = "stir", speed = 4, on_step = H.steps("erba", 0.25) })
    s.fig = D.figura(28, 56, { s = 1.2, l = 3, dark = true, pose = "sit" })
    s.water = D.parts(60)
    s.bf = { x = 60, y = 30, tx = 60, ty = 30 }
    s.roses = {}
    for i = 1, 7 do s.roses[i] = { x = 88 + (i % 4) * 9 + R(-2, 2), y = 44 + floor(i / 4) * 6, ph = R(0, 6) } end
    s.dog = 0
  end,
  update = function(s, dt, t)
    think(s.nonna, function()
      local r = random()
      if r < 0.6 then return { { "pose", "stir", R(8, 14) } } end
      if r < 0.85 then return { { "walk", R(70, 96), 4 }, { "face", 1 }, { "pose", "stir", R(6, 10) } } end
      return { { "pose", "bend", 4 }, { "pose", "stand", 3 } }
    end)
    think(s.fig, function() return pick({ { { "pose", "sit", R(8, 14) } }, { { "pose", "sit_think", R(6, 10) } }, { { "pose", "look_up", 4 }, { "pose", "sit", 6 } } }) end)
    s.nonna:update(dt); s.fig:update(dt)
    if s.nonna.cur.ua1 > 40 and not s.nonna.walking then
      local hx, hy = s.nonna.hand[1], s.nonna.hand[2]
      for i = 1, 2 do D.spawn(s.water, { x = hx + 2, y = hy, vx = R(14, 20), vy = R(-8, -4), life = 1.2 }) end
    end
    D.parts_update(s.water, dt, function(p, d) p.vy = p.vy + 40 * d; if p.y > 56 then p.dead = true end end)
    if random() < dt * 0.5 then s.bf.tx = R(20, 110); s.bf.ty = R(18, 44) end
    s.bf.x = s.bf.x + (s.bf.tx - s.bf.x) * dt * 0.6 + sin(t * 3) * 0.3
    s.bf.y = s.bf.y + (s.bf.ty - s.bf.y) * dt * 0.6 + cos(t * 4) * 0.3
    s.dog = s.dog + dt
  end,
  draw = function(s, t)
    local lu, w, warm = mac("luce"), mac("vento"), mac("calore")
    D.gradient(0, 36, 8 + lu * 3, 11 + lu * 2 + warm)
    D.circle(108, 10, 5, 15)
    -- il muro di casa con la finestra e la pergola
    D.rect(0, 14, 40, 42, 6); D.rect(0, 12, 42, 2, 5)
    D.window(10, 22, 12, 12, 3, 10)
    for x = 40, 126, 10 do D.line(x, 16, x, 56, 4) end
    D.rect(40, 14, 88, 2, 4)
    for i = 0, 16 do D.circle(42 + i * 5 + sin(t + i) * w, 15 + (i % 3), 2.5, 5 + (i % 2)) end
    D.rect(0, 56, 128, 8, 7)
    -- le rose
    for _, r in ipairs(s.roses) do
      local sw = sin(t * 1.2 + r.ph) * (0.5 + w)
      D.line(r.x, 56, r.x + sw, r.y, 3)
      D.circle(r.x + sw, r.y, 2.4, 11); D.px(r.x + sw, r.y, 15)
      D.px(r.x + sw - 2, r.y + 3, 4); D.px(r.x + sw + 2, r.y + 4, 4)
    end
    -- la panchina
    D.rect(18, 50, 22, 2, 3); D.rect(19, 52, 2, 4, 2); D.rect(37, 52, 2, 4, 2)
    -- il cane che dorme all'ombra
    local br = sin(s.dog * 1.6) * 0.5
    D.poly({ 46, 56, 62, 56, 61, 52 - br, 50, 51 - br }, 3)
    D.circle(62, 53, 2.5, 3); D.poly({ 63, 51, 65, 50, 64, 53 }, 2)
    s.fig:draw(); s.nonna:draw()
    for _, p in ipairs(s.water.list) do D.px(p.x, p.y, 13) end
    -- la farfalla
    local f = abs(sin(t * 14)) * 2
    D.line(s.bf.x - f, s.bf.y - 1, s.bf.x, s.bf.y, 14); D.line(s.bf.x, s.bf.y, s.bf.x + f, s.bf.y - 1, 14)
    prato(s, 64, 5, 0.4 + w, t)
  end,
}

-------------------------------------------------------------------------------
-- LA RINASCITA: un'alba che non finisce, i germogli, lui che si alza
-------------------------------------------------------------------------------
S.rinascita = {
  init = function(s)
    s.fig = D.figura(64, 52, { s = 1.3, l = 2, dark = true, pose = "curl" })
    s.sprouts = {}
    for i = 1, 26 do s.sprouts[i] = { x = R(2, 126), h = 0, max = R(3, 10), sp = R(0.3, 1.2), d = R(0, 20) } end
    s.cyc = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    think(s.fig, function()
      return { { "pose", "curl", R(8, 12) }, { "pose", "kneel", 5 }, { "pose", "kneel_one", 4 }, { "pose", "stand", 4 },
        { "pose", "look_up", 5 }, { "pose", "arms_open", R(8, 12) }, { "pose", "stand", 4 }, { "pose", "sit_ground", 6 } }
    end)
    s.fig:update(dt)
    for _, p in ipairs(s.sprouts) do
      if s.cyc > p.d then p.h = min(p.max, p.h + dt * p.sp) end
    end
    if s.cyc > 90 then s.cyc = 0; for _, p in ipairs(s.sprouts) do p.h = 0; p.d = R(0, 20) end end
  end,
  draw = function(s, t)
    local lu, co = mac("luce"), mac("coro")
    local k = min(1, s.cyc / 40)
    D.gradient(0, 46, 2 + k * 5 + lu * 2, 6 + k * 6 + lu * 2)
    local sy = 52 - k * 14
    -- i raggi, netti, che si aprono
    local n = 5 + floor(co * 6)
    for i = 0, n - 1 do
      local a = pi + (i + 0.5) / n * pi + sin(t * 0.1) * 0.05
      D.line(64, sy, 64 + cos(a) * 90, sy + sin(a) * 90, 5 + k * 4)
    end
    D.circle(64, sy, 8, 12 + k * 3)
    D.rect(0, 46, 128, 18, 3 + k * 2)
    D.line(0, 46, 127, 46, 6 + k * 4)
    for _, p in ipairs(s.sprouts) do
      if p.h > 0.3 then
        local sw = sin(t * 0.8 + p.x) * 0.5
        D.line(p.x, 58, p.x + sw, 58 - p.h, 7 + k * 4)
        if p.h > 3 then D.px(p.x + sw - 1, 58 - p.h + 1, 10 + k * 3); D.px(p.x + sw + 1, 58 - p.h + 2, 10 + k * 3) end
      end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- ACCETTARE: il sentiero che sale piano, sopra le nuvole
-------------------------------------------------------------------------------
S.risalita = {
  init = function(s)
    s.fig = D.figura(-4, 58, { s = 1.05, l = 2, dark = true, speed = 4, on_step = H.steps("erba", 0.3), bent = 3 })
    s.clouds = { { 0, 46, 30, 0.3 }, { 50, 50, 26, 0.25 }, { 100, 44, 34, 0.35 } }
    s.ridge = D.ridge_gen(31, 24, 8, 0.6)
  end,
  update = function(s, dt, t)
    local f = s.fig
    think(f, function()
      if f.x > 126 then return { { "fn", function(g) g.x = -4; g.y = 58 end } } end
      local y = function(x) return 58 - x * 0.22 end
      local x1 = min(130, f.x + R(30, 50))
      local r = random()
      if r < 0.4 then return { { "walk", x1, 4, y(x1) }, { "face", -1 }, { "pose", "stand", 3 }, { "face", 1 } } end
      if r < 0.7 then return { { "walk", x1, 4, y(x1) }, { "pose", "sit_ground", R(5, 9) }, { "pose", "stand", 1 } } end
      return { { "walk", x1, 4, y(x1) }, { "pose", "look_up", 4 } }
    end)
    f:update(dt)
  end,
  draw = function(s, t)
    local w, ar = mac("vento"), mac("archi")
    D.gradient(0, 40, 6 + ar * 3, 10 + ar * 3)
    D.circle(106, 12, 5, 14 + ar)
    D.ridge(s.ridge, 7, 64)
    K.clouds(s.clouds, t * 0.5, 13)
    -- il pendio, il sentiero a tornanti
    D.poly({ 0, 58, 128, 30, 128, 64, 0, 64 }, 4)
    for x = 0, 127, 2 do D.px(x, 58 - x * 0.22 + 1, 8) end
    for i = 0, 12 do
      local x = i * 11 + 3
      local sw = sin(t * 1.4 + i) * (0.5 + w * 1.5)
      D.line(x, 62 - x * 0.22, x + sw, 58 - x * 0.22, 6)
    end
    -- un sasso per sedersi, un ometto di pietre
    D.circle(70, 44, 2.5, 3); D.circle(100, 38, 1.5, 3); D.circle(100, 36, 1.2, 4); D.px(100, 34, 5)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'OSSERVATORIO: la cupola si apre, il telescopio ruota
-------------------------------------------------------------------------------
S.osservatorio = {
  init = function(s)
    s.stars = D.stars_gen(60, 9, 2, 40)
    s.fig = D.figura(84, 56, { s = KS, l = 9, pose = "window", face = -1, speed = 4, on_step = H.steps("pietra", 0.3) })
    s.open = 0
    s.ang = 0.6
    s.shoot = nil
  end,
  update = function(s, dt, t)
    s.open = min(1, s.open + dt * 0.05)
    s.ang = 0.55 + sin(t * 0.03) * 0.2
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "window", R(10, 16) } } end
      if r < 0.8 then return { { "walk", R(90, 104), 3 }, { "face", -1 }, { "pose", "look_up", 6 }, { "walk", 84, 3 }, { "face", -1 } } end
      return { { "pose", "stand", 4 }, { "pose", "head_down", 3 } }
    end)
    s.fig:update(dt)
    if not s.shoot and random() < dt * (0.03 + mac("stelle") * 0.1) then s.shoot = { x = R(30, 90), y = R(4, 14), k = 0 } end
    if s.shoot then s.shoot.k = s.shoot.k + dt * 1.6; if s.shoot.k > 1 then s.shoot = nil end end
  end,
  draw = function(s, t)
    local st = mac("stelle")
    D.rect(0, 0, 128, 64, 0)
    -- la fenditura della cupola: dentro, il cielo
    local w = 6 + s.open * 22
    screen.level(0)
    D.poly({ 64 - w / 2, 0, 64 + w / 2, 0, 64 + w / 2, 40, 64 - w / 2, 40 }, 1)
    for _, sr in ipairs(s.stars) do
      if abs(sr.x - 64) < w / 2 - 1 then
        local tw = 0.5 + 0.5 * sin(t * sr.sp + sr.ph)
        D.px(sr.x, sr.y, 3 + sr.b * 10 * tw + st * 3)
      end
    end
    if s.shoot and abs(s.shoot.x - 64) < w then
      local x, y = s.shoot.x - 64 + 64 - 10 + s.shoot.k * 20, s.shoot.y + s.shoot.k * 8
      if abs(x - 64) < w / 2 then D.line(x, y, x - 4, y - 2, 13 * (1 - s.shoot.k)) end
    end
    -- la cupola, a spicchi
    for x = 0, 127 do
      local h = 40 - (((x - 64) / 70) ^ 2) * 28
      if abs(x - 64) >= w / 2 then D.rect(x, 0, 1, h, 3 + ((floor((x + 4) / 14)) % 2)) end
    end
    D.rect(0, 40, 128, 18, 2)
    for x = 0, 127, 16 do D.line(x, 40, x, 56, 3) end
    D.rect(0, 56, 128, 8, 1)
    -- il telescopio
    local bx, by = 60, 44
    local ex, ey = bx - cos(s.ang) * 36, by - sin(s.ang) * 36
    D.thick(bx, by, ex, ey, 4, 7); D.thick(bx, by, bx + cos(s.ang) * 6, by + sin(s.ang) * 6, 2.5, 8)
    D.rect(56, 44, 8, 12, 4); D.rect(52, 55, 16, 2, 5)
    -- la radio sul tavolo
    local ra = mac("radio")
    D.rect(100, 46, 14, 2, 4); D.rect(102, 48, 2, 8, 3)
    K.radio(102, 46, 5, t)
    if ra > 0.1 and floor(t * 2) % 2 == 0 then D.px(112, 41, 8 + ra * 7) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- I TETTI: le tegole tiepide, la città che accende le finestre
-------------------------------------------------------------------------------
S.tetti = {
  init = function(s)
    s.stars = D.stars_gen(40, 5, 0, 22)
    s.bld = {}
    local x = 0
    while x < 128 do
      local w, h = R(9, 18), R(10, 26)
      local b = { x = x, w = w, h = h, win = {} }
      for wy = 0, floor(h / 5) - 1 do for wx = 0, floor((w - 2) / 4) - 1 do b.win[#b.win + 1] = { x = x + 2 + wx * 4, y = 46 - h + 3 + wy * 5, on = false, t = R(0, 60) } end end
      s.bld[#s.bld + 1] = b
      x = x + w + R(0, 2)
    end
    s.fig = D.figura(36, 50, { s = 1.15, l = 2, dark = true, pose = "sit_ground" })
    s.smoke = D.parts(30)
    s.train = -60
    s.cig = 0
  end,
  update = function(s, dt, t)
    for _, b in ipairs(s.bld) do for _, w in ipairs(b.win) do if t > w.t and not w.on then w.on = true end; if w.on and random() < dt * 0.004 then w.on = false; w.t = t + R(5, 40) end end end
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(8, 14) } }, { { "pose", "sit_think", R(6, 10) } }, { { "pose", "look_up", 5 }, { "pose", "sit_ground", 5 } } }) end)
    s.fig:update(dt)
    s.cig = (s.cig + dt) % 6
    local hx, hy = s.fig.hand[1], s.fig.hand[2]
    D.smoke_update(s.smoke, dt, hx, hy - 1, 2, t, 1)
    D.parts_update(s.smoke, 0)
    s.train = s.train + dt * (8 + mac("treno") * 16)
    if s.train > 200 then s.train = -60 - R(0, 80) end
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.gradient(0, 46, 0, 3 - nt * 2)
    D.stars(s.stars, t, 0.6 + nt * 0.6)
    D.moon(108, 10, 3, 13, 0)
    -- il treno lontano sull'orizzonte
    if mac("treno") > 0.05 then for i = 0, 5 do local x = s.train + i * 9; D.rect(x, 33, 8, 2, 3); D.px(x + 3, 33, 11) end end
    -- il campanile
    D.rect(92, 12, 6, 34, 2); D.poly({ 91, 12, 99, 12, 95, 6 }, 2); D.rect(94, 16, 2, 3, 6 + mac("campane") * 6)
    for _, b in ipairs(s.bld) do
      D.rect(b.x, 46 - b.h, b.w, b.h, 1)
      for _, w in ipairs(b.win) do if w.on then D.rect(w.x, w.y, 2, 2, 10) end end
    end
    -- il tetto in primo piano, le tegole
    D.poly({ 0, 52, 128, 44, 128, 64, 0, 64 }, 3)
    for i = 0, 6 do local y = 54 + i * 2; D.line(0, y, 128, y - 8, 2) end
    for x = 0, 127, 5 do D.line(x, 52 - x / 16, x, 64, 2) end
    D.rect(16, 36, 7, 14, 3); D.rect(15, 35, 9, 2, 4)
    s.fig:draw()
    -- la brace della sigaretta
    local hx, hy = s.fig.hand[1], s.fig.hand[2]
    D.px(hx + 1, hy - 1, s.cig < 1 and 15 or 10)
    D.smoke_draw(s.smoke, 6)
  end,
}

-------------------------------------------------------------------------------
-- LA TORRE DEI RICORDI: la scala a chiocciola, una porta per ogni anno
-------------------------------------------------------------------------------
local ANNI = { "1979", "1987", "1994", "2003", "2011", "2019" }
S.torre = {
  init = function(s)
    s.fig = D.figura(18, 58, { s = 1.15, l = 10, speed = 4, on_step = H.steps("pietra", 0.3) })
    s.floor = 0
    s.cam = 0
    s.motes = D.parts(20)
    s.lit = random(1, 6)
  end,
  update = function(s, dt, t)
    local f = s.fig
    think(f, function()
      local fl = s.floor
      local y0 = 58 - fl * 22
      local list = { { "walk", 100, 4, y0 - 22 }, { "fn", function() s.floor = s.floor + 1 end } }
      if (fl + 1) % 6 == 2 then
        table.insert(list, { "pose", "trace", 3 }); table.insert(list, { "pose", "head_down", 4 })
      else
        table.insert(list, { "pose", "stand", R(2, 4) })
      end
      table.insert(list, { "fn", function(g) g.x = 18; s.floor = s.floor end })
      return list
    end)
    f:update(dt)
    local target = (58 - f.y) - 18
    s.cam = s.cam + (target - s.cam) * min(1, dt * 0.8)
    D.motes_update(s.motes, dt, 1.5, { 20, 10, 90, 40 }, t)
    if random() < dt * 0.02 then s.lit = random(1, 6) end
  end,
  draw = function(s, t)
    local ri = mac("ricordo")
    local cam = s.cam
    D.rect(0, 0, 128, 64, 1)
    -- la colonna centrale
    D.rect(58, 0, 10, 64, 3)
    for y = -40, 80, 6 do local yy = (y + cam) % 66 - 2; D.line(58, yy, 67, yy, 2) end
    -- i piani: rampe, pianerottoli, porte con gli anni
    for k = -1, 3 do
      local n = floor(cam / 22) + k
      local fy = 58 - n * 22 + cam
      if fy > -10 and fy < 80 then
        D.line(18, fy, 100, fy - 22, 5)
        for x = 18, 100, 6 do local y = fy - (x - 18) * 22 / 82; D.rect(x, y, 6, 1, 6) end
        D.rect(100, fy - 22, 26, 2, 5)
        local yr = ANNI[(n % 6) + 1]
        local dx = 108
        D.rect(dx, fy - 40, 12, 18, 2)
        D.rect(dx + 1, fy - 39, 10, 17, 3)
        D.px(dx + 9, fy - 30, 9)
        if (n % 6) + 1 == s.lit then D.rect(dx + 1, fy - 23, 10, 1, 13); D.poly({ dx + 1, fy - 22, dx + 11, fy - 22, dx + 14, fy - 20, dx - 2, fy - 20 }, 5) end
        screen.font_face(1); screen.font_size(8)
        screen.level(D.lv(4 + ri * 5)); screen.move(dx - 1, fy - 42); screen.text(yr)
      end
    end
    D.motes_draw(s.motes, 6)
    local fy = s.fig.y
    s.fig.y = fy + cam
    s.fig:draw()
    s.fig.y = fy
  end,
}

-------------------------------------------------------------------------------
-- I PROFUMI DI UNA VOLTA: la cucina, il sugo, la radio
-------------------------------------------------------------------------------
S.cucina = {
  init = function(s)
    s.win = { cloud = 5 }
    s.nonna = D.figura(42, 58, { s = KS, l = 4, dark = true, dress = true, bun = true, pose = "stir", speed = 5, on_step = H.steps("piastrelle", 0.3) })
    s.kid = D.figura(90, 58, { s = KS * 0.75, l = 10, child = true, pose = "sit", face = -1 })
    s.steam = D.parts(30); s.steam2 = D.parts(20)
    s.leg = 0
  end,
  update = function(s, dt, t)
    think(s.nonna, function()
      local r = random()
      if r < 0.55 then return { { "pose", "stir", R(8, 14) } } end
      if r < 0.8 then return { { "walk", 78, 5 }, { "face", 1 }, { "pose", "talk", 3 }, { "pose", "carry", 2 }, { "walk", 42, 5 }, { "face", -1 } } end
      return { { "walk", 16, 5 }, { "pose", "bend", 3 }, { "pose", "carry", 2 }, { "walk", 42, 5 }, { "face", -1 } }
    end)
    think(s.kid, function() return pick({ { { "pose", "sit", R(6, 10) } }, { { "pose", "talk", 3 }, { "pose", "sit", 5 } }, { { "pose", "sit_think", 6 } } }) end)
    s.nonna:update(dt); s.kid:update(dt)
    s.leg = s.leg + dt
    s.kid.cur.sh1 = 4 + sin(s.leg * 4) * 18; s.kid.cur.sh2 = sin(s.leg * 4 + 1.5) * 18
    local warm = mac("calore")
    D.smoke_update(s.steam, dt, 31, 34, 2 + warm * 3, t, 0.5)
    D.smoke_update(s.steam2, dt, 108, 30, 0.8, t, -0.3)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    K.room({ wall = 6 + warm, fy = 58, floor = "piastrelle", floor_l = 4, paper = "piastrelle", tile_y = 34, ceil = 4,
      lights = { { x = 64, y = 6, r = 10, l = 2 } } }, t)
    K.window(58, 12, 18, 16, K.views.day, t, s.win, 8)
    -- la cucina a legna, la pentola
    local top = K.stove(18, 58, 4, t)
    D.rect(26, top - 6, 10, 6, 3); D.rect(25, top - 7, 12, 1, 5)
    D.smoke_draw(s.steam, 12)
    -- la madia col pane, il forno
    D.rect(98, 38, 22, 20, 4); D.rect(97, 37, 24, 2, 5)
    D.poly({ 102, 36, 112, 36, 110, 33, 104, 33 }, 11)
    D.smoke_draw(s.steam2, 10)
    -- la mensola con la radio
    D.rect(84, 26, 20, 1, 5)
    K.radio(86, 26, 5, t)
    local ra = mac("radio")
    if ra > 0.05 then for i = 1, 3 do local a = (t * 2 + i * 0.6) % 2; D.px(97 + a * 4, 22 - a * 3 - i, 10 * (1 - a / 2) * ra) end end
    -- il tavolo, la sedia del bambino
    K.table(70, 58, 1.1, 4, 11)
    K.chair(90, 58, -1, 4)
    D.circle(78, 46, 2, 13); D.rect(82, 46, 3, 1, 10)
    K.clock(46, 10, t, 5)
    s.nonna:draw(); s.kid:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA MANO DEL NONNO: la poltrona, il fuoco, una carezza
-------------------------------------------------------------------------------
S.mano_nonno = {
  init = function(s)
    s.nonno = D.figura(56, 58, { s = KS * 1.08, l = 4, dark = true, pose = "sit", face = 1 })
    s.kid = D.figura(76, 58, { s = KS * 0.72, l = 11, child = true, pose = "stand", face = -1, speed = 5, on_step = H.steps("legno", 0.2) })
    s.fig = s.kid
    s.stage = 0
  end,
  update = function(s, dt, t)
    think(s.kid, function()
      local r = random()
      if r < 0.5 then
        return { { "walk", 74, 4 }, { "face", -1 }, { "fn", function() s.nonno:act({ { "pose", "caress", 7 }, { "pose", "sit", 1 } }) end }, { "pose", "head_down", 7 }, { "pose", "stand", 2 } }
      elseif r < 0.75 then
        return { { "walk", 70, 4 }, { "face", -1 }, { "pose", "hug", 6 }, { "pose", "stand", 2 } }
      end
      return { { "walk", R(90, 110), 5 }, { "face", -1 }, { "pose", "sit_ground", R(6, 9) }, { "pose", "stand", 1 } }
    end)
    s.kid:update(dt); s.nonno:update(dt)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    K.room({ wall = 4 + warm * 2, fy = 58, floor = "assi", floor_l = 3, paper = "fiori", ceil = 4 }, t)
    K.fireplace(10, 58, t, 4, 0.6 + warm * 0.5)
    K.clock(110, 14, t * (0.5 + mac("tempo")), 5, true)
    K.frame(86, 16, 10, 12, 5, 9)
    K.armchair(56, 58, 1, 3)
    K.rug(30, 100, 58, 3)
    s.nonno:draw(); s.kid:draw()
    -- il riflesso del fuoco sulle mani
    local f = D.noise(t * 6) * 3
    D.px(s.nonno.hand[1], s.nonno.hand[2], 6 + f + warm * 3)
  end,
}

-------------------------------------------------------------------------------
-- GIUGNO: le sere lunghe, le lucciole, un bambino in braccio
-------------------------------------------------------------------------------
S.giugno = {
  init = function(s)
    s.fig = D.figura(-6, 54, { s = 1.15, l = 2, dark = true, pose = "cradle", speed = 3, on_step = H.steps("erba", 0.2),
      prop = function(x, y) D.circle(x - 2, y - 2, 2.6, 3); D.circle(x - 3.5, y - 3.5, 1.5, 3) end })
    s.ff = {}
    for i = 1, 30 do s.ff[i] = { x = R(0, 128), y = R(30, 58), ph = R(0, 6), sp = R(0.4, 1.4) } end
    s.cyc = 0
    s.stars = D.stars_gen(30, 21, 0, 26)
  end,
  update = function(s, dt, t)
    s.cyc = (s.cyc + dt) % 120
    local f = s.fig
    think(f, function()
      if f.x > 126 then return { { "fn", function(g) g.x = -6 end } } end
      local r = random()
      if r < 0.6 then return { { "walk", min(132, f.x + R(25, 40)), 3 }, { "pose", "cradle", R(5, 9) } } end
      return { { "walk", min(132, f.x + R(20, 30)), 3 }, { "pose", "look_up", 4 }, { "pose", "cradle", 4 } }
    end)
    f:update(dt)
    if not f.walking then f.cur.lean = f.cur.lean + sin(t * 1.2) * 0.2 end
    for _, p in ipairs(s.ff) do p.x = p.x + sin(t * p.sp + p.ph) * dt * 4; p.y = p.y + cos(t * p.sp * 0.7 + p.ph) * dt * 3 end
  end,
  draw = function(s, t)
    local lu, nt = mac("luce"), mac("notte")
    local k = min(1, s.cyc / 60) * (0.5 + nt * 0.5)
    D.gradient(0, 40, 6 - k * 6 + lu * 2, 12 - k * 9 + lu * 2)
    if k > 0.4 then D.stars(s.stars, t, (k - 0.4) * 2) end
    D.circle(96, 30 + k * 16, 6, 14 - k * 4)
    D.rect(0, 38, 128, 26, 3 - k * 2)
    for x = 0, 127 do local h = 3 + sin(x * 0.07) * 2; D.rect(x, 38 - h, 1, h, 4 - k * 2) end
    D.house(14, 38, 10, 6, 2, 4); D.rect(18, 34, 2, 2, 8 + k * 6)
    -- il grano, mosso
    for x = 0, 127, 2 do local sw = sin(t * 1.1 + x * 0.1) * 1.2; D.line(x, 58, x + sw, 50 + sin(x) * 2, 5 - k * 3) end
    D.rect(0, 56, 128, 8, 2)
    local fl = k * 0.8 + 0.2 + mac("lacrime") * 0.2
    for _, p in ipairs(s.ff) do
      local b = 0.5 + 0.5 * sin(t * 2 * p.sp + p.ph)
      if b > 0.4 then D.px(p.x % 128, p.y, (b * 15) * fl) end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL CORTILE: i muri alti, la campanella, chi aspetta
-------------------------------------------------------------------------------
S.cortile = {
  init = function(s)
    s.fig = D.figura(30, 56, { s = 1.15, l = 9, child = true, pose = "sit", face = 1 })
    s.kids = {}
    for i = 1, 4 do s.kids[i] = D.figura(R(60, 110), 56, { s = 0.85, l = 6, child = true, speed = R(8, 12), on_step = H.steps("ghiaia", 0.15) }) end
    s.bell = 0
    s.inside = false
    s.nun = 0
  end,
  update = function(s, dt, t)
    local n = 1 + floor(mac("infanzia") * 3.5)
    if random() < dt * 0.012 and not s.inside then
      s.bell = 3; s.inside = true
      for _, k in ipairs(s.kids) do k:clear(); k:act({ { "walk", 118, 12 }, { "wait", R(20, 40) }, { "fn", function() s.inside = false end } }) end
      S.env.sfx("bell", 1568, 0.05, 2, 0.5, 0.6, 0.001)
    end
    for i, k in ipairs(s.kids) do
      if i <= n then think(k, function() return { { "walk", R(54, 116), k.speed }, { "pose", "stand", R(0.5, 2) } } end) end
      k:update(dt)
    end
    think(s.fig, function() return pick({ { { "pose", "sit", R(8, 14) } }, { { "pose", "head_down", 5 }, { "pose", "sit", 1 } }, { { "pose", "sit_think", 8 } } }) end)
    s.fig:update(dt)
    s.bell = max(0, s.bell - dt)
    s.nun = s.nun + dt
  end,
  draw = function(s, t)
    local si, w = mac("silenzio"), mac("vento")
    D.gradient(0, 20, 6, 8)
    -- i muri alti, le finestre con le inferriate
    D.rect(0, 8, 128, 48, 4)
    D.rect(0, 8, 128, 2, 5)
    for i = 0, 4 do
      local x = 8 + i * 26
      D.rect(x, 16, 10, 12, 1)
      for b = 1, 3 do D.line(x + b * 2.5, 16, x + b * 2.5, 27, 4) end
    end
    -- la suora alla finestra
    if floor(s.nun / 20) % 2 == 0 then D.circle(37, 21, 2, 3); D.rect(35, 22, 5, 5, 2) end
    D.circle(118, 14, 2.5, 6 + s.bell * 3)
    D.rect(0, 56, 128, 8, 6)
    for i = 0, 40 do D.px((i * 37) % 128, 57 + (i * 7) % 6, 4) end
    -- l'albero solo, la rete, il pallone sgonfio
    D.bare_tree(52, 56, 26, 2, 4, sin(t * 0.7) * w)
    for x = 100, 126, 3 do D.line(x, 40, x, 56, 3) end
    D.line(100, 40, 126, 40, 3)
    D.poly({ 94, 56, 100, 56, 99, 53, 95, 53 }, 7)
    -- la panchina lungo il muro
    D.rect(16, 50, 26, 2, 3); D.rect(17, 52, 2, 4, 2); D.rect(39, 52, 2, 4, 2)
    for i, k in ipairs(s.kids) do if k.x < 116 then k:draw() end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'AULA: i banchi, la lavagna, l'orologio a scatti
-------------------------------------------------------------------------------
S.aula = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = KS * 0.75, l = 10, child = true, pose = "sit_read", face = -1 })
    s.motes = D.parts(24)
    s.tick = 0
    s.chalk = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "sit_read", R(8, 14) } } end
      if r < 0.8 then return { { "face", 1 }, { "pose", "sit", R(5, 8) }, { "face", -1 } } end
      return { { "pose", "sit_think", R(5, 8) } }
    end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 2 + mac("ricordo") * 2, { 80, 10, 40, 46 }, t)
    s.chalk = (s.chalk + dt * 0.3) % 1.4
  end,
  draw = function(s, t)
    local tm = mac("tempo")
    K.room({ wall = 5, fy = 58, floor = "assi", floor_l = 3, ceil = 4 }, t)
    -- la lavagna, la frase mezza cancellata
    D.rect(8, 14, 46, 24, 1); D.rect(7, 13, 48, 1, 5); D.rect(7, 38, 48, 2, 5)
    for i = 0, 7 do
      local x = 12 + i * 5
      local erased = (i % 3 == 1)
      local l = erased and 2 or 9
      D.line(x, 20, x + 3, 19 + (i % 2), l); D.line(x + 1, 22, x + 4, 22, l)
    end
    for i = 0, 4 do D.line(12 + i * 6, 28, 15 + i * 6, 28 - (i % 2), 6) end
    local cw = min(1, s.chalk) * 26
    D.line(12, 33, 12 + cw, 33, 10)
    -- l'orologio sopra la porta: va avanti a scatti
    local tt = floor(t * (1 + tm * 3))
    K.clock(70, 9, tt * 0.5, 6)
    K.door(64, 58, 0, 4)
    -- la finestra, la luce, la polvere
    K.window(96, 12, 20, 22, K.views.day, t, s, 8)
    for k = 0, 3 do D.line(98 + k * 4, 34, 70 + k * 6, 58, 7) end
    D.motes_draw(s.motes, 11)
    -- i banchi
    for i = 0, 2 do
      local x = 20 + i * 36
      D.rect(x, 46, 16, 2, 6); D.rect(x + 1, 48, 2, 10, 4); D.rect(x + 13, 48, 2, 10, 4)
      D.px(x + 12, 46, 1)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA MACCHININA ROSSA: una mensola, una Ferrari, due mani
-------------------------------------------------------------------------------
S.macchinina = {
  init = function(s)
    s.car = { x = 92, y = 28, on = true }
    s.fig = D.figura(60, 58, { s = KS * 0.72, l = 10, child = true, pose = "stand", speed = 5, on_step = H.steps("legno", 0.2),
      prop = function(x, y, f) if not s.car.on and not s.car.floor then D.rect(x - 2, y - 1, 5, 2, 14) end end })
    s.motes = D.parts(20)
    s.play = 0
  end,
  update = function(s, dt, t)
    local c = s.car
    think(s.fig, function()
      return { { "walk", 88, 4 }, { "face", 1 }, { "pose", "reach_up", 2 }, { "fn", function() c.on = false end }, { "pose", "carry", 1 },
        { "walk", 56, 4 }, { "pose", "sit_ground", 1 }, { "fn", function() c.floor = true; s.play = 0 end }, { "pose", "sit_ground", R(10, 16) },
        { "fn", function() c.floor = false end }, { "pose", "stand", 1 }, { "walk", 88, 4 }, { "face", 1 }, { "pose", "reach_up", 2 },
        { "fn", function() c.on = true end }, { "pose", "stand", 2 }, { "walk", R(30, 60), 4 }, { "pose", "head_down", 5 } }
    end)
    s.fig:update(dt)
    if c.floor then s.play = s.play + dt end
    D.motes_update(s.motes, dt, 1.5, { 70, 10, 40, 40 }, t)
  end,
  draw = function(s, t)
    local di = mac("distanza")
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 2, paper = "righe", ceil = 4 }, t)
    -- la luce che entra di lato: lame sottili
    for k = 0, 3 do D.line(127, 10 + k * 4, 52 + k * 6, 58, 4) end
    D.poly({ 52, 58, 76, 58, 80, 60, 48, 60 }, 4)
    D.motes_draw(s.motes, 9)
    -- la mensola
    D.rect(80, 30, 24, 2, 5); D.line(82, 32, 84, 36, 4); D.line(102, 32, 100, 36, 4)
    local c = s.car
    local function car(x, y, l)
      D.rect(x, y - 2, 8, 2, l); D.rect(x + 2, y - 3, 3, 1, l - 2)
      D.px(x + 1, y, 1); D.px(x + 6, y, 1)
    end
    if c.on then car(88, 30, 12) end
    if c.floor then
      local x = 66 + sin(s.play * 1.3) * 12
      car(x, 58, 12)
      s.fig.face = (cos(s.play * 1.3) > 0) and 1 or -1
    end
    s.fig:draw()
    -- quando è lontano, tornano le sue mani
    if di > 0.35 then
      local a = (di - 0.35) * 1.5
      local hx, hy = 92, 22 + sin(t * 0.4)
      D.circle(hx - 8, hy, 5, 3 * a, true); D.circle(hx + 10, hy, 5, 3 * a, true)
      D.line(hx - 13, hy + 2, hx - 22, hy + 14, 3 * a); D.line(hx + 15, hy + 2, hx + 24, hy + 14, 3 * a)
    end
  end,
}

-------------------------------------------------------------------------------
-- LA STANZA DELLA MOQUETTE: la carta a fiori, il dito che cerca la fine
-------------------------------------------------------------------------------
S.moquette = {
  init = function(s)
    s.fig = D.figura(20, 58, { s = KS * 0.72, l = 10, child = true, pose = "trace", speed = 1.4, on_step = H.steps("moquette", 0.15) })
    s.strips = {}
    for i = 1, 5 do s.strips[i] = { x = R(10, 120), len = R(6, 18), ph = R(0, 6) } end
  end,
  update = function(s, dt, t)
    local f = s.fig
    think(f, function()
      if f.x > 100 then return { { "pose", "stand", 3 }, { "walk", 20, 5 }, { "face", 1 }, { "pose", "trace", 2 } } end
      return { { "fn", function(g) g:set("trace") end }, { "walk", f.x + R(10, 18), 1.4 }, { "pose", "trace", R(1, 2) } }
    end)
    f:update(dt)
    if f.walking and f.x > 20 then f.cur.ua1 = 95; f.cur.fa1 = 95; f.cur.lean = -2 end
  end,
  draw = function(s, t)
    local ri = mac("ricordo")
    K.room({ wall = 4, fy = 58, floor = "moquette", floor_l = 3, paper = "fiori", ceil = 4 }, t)
    -- le lingue di carta che si staccano
    for _, st in ipairs(s.strips) do
      local sw = sin(t * 0.5 + st.ph) * 1.5
      D.poly({ st.x, 4, st.x + 6, 4, st.x + 5 + sw, 4 + st.len, st.x + 1 + sw * 0.6, 4 + st.len - 2 }, 6)
      D.rect(st.x, 4, 6, st.len - 2, 2)
    end
    -- la moquette consumata dove passavano sempre
    D.poly({ 30, 58, 98, 58, 110, 64, 18, 64 }, 4)
    -- il tavolino col centrino, la poltrona, la radio
    D.rect(96, 46, 14, 2, 5); D.rect(100, 48, 2, 10, 4); D.rect(106, 48, 2, 10, 4)
    D.circle(103, 45, 3, 12); D.px(103, 44, 15)
    K.armchair(118, 58, -1, 3)
    K.frame(52, 14, 14, 10, 4, 7 + ri * 4)
    K.clock(84, 12, t, 5)
    s.fig:draw()
    -- il dito sulla carta: un puntino più chiaro dove tocca
    if s.fig.cur.ua1 > 80 then D.px(s.fig.hand[1] + 1, s.fig.hand[2], 13) end
  end,
}

end
