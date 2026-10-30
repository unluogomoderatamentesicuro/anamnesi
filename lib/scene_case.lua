-- ANAMNESI · scene delle case
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, copy, think, mac = H.R, H.pick, H.pan, H.copy, H.think, H.mac

D.POSE.play = { lean = 6, nod = 14, ua1 = 48, ua2 = 42, fa1 = 92, fa2 = 88, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.cradle = { lean = 2, nod = 26, ua1 = 30, ua2 = 26, fa1 = 100, fa2 = 96, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.sit_edge = { lean = 18, nod = 30, ua1 = 20, ua2 = 14, fa1 = 60, fa2 = 50, th1 = 88, th2 = 84, sh1 = 2, sh2 = -2, hy = 4.4, rot = 0 }
D.POSE.type = { lean = 10, nod = 18, ua1 = 40, ua2 = 36, fa1 = 88, fa2 = 84, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }

local KS = K.S

-------------------------------------------------------------------------------
-- PIOGGIA SUL TETTO
-------------------------------------------------------------------------------
S.pioggia = {
  init = function(s)
    s.win = {}
    s.glass = {}
    for i = 1, 10 do s.glass[i] = { x = R(9, 31), y = R(16, 34), v = 0, len = 0 } end
    s.keys = {}
    s.atpiano = false
    s.fig = D.figura(46, 58, { s = KS, l = 11, pose = "sit_read", speed = 6, on_step = H.steps("legno", 0.35),
      prop = function(x, y, f) if not s.atpiano and f.cur.fa1 > 100 and f.cur.hy < 6 then D.rect(x - 2, y - 3, 5, 4, 13); D.line(x, y - 3, x, y, 9) end end })
    s.drip = { y = 8, rip = 0 }
  end,
  update = function(s, dt, t)
    for _, g in ipairs(s.glass) do
      if g.v == 0 and random() < dt * 0.2 then g.v = R(4, 12) end
      if g.v > 0 then
        g.y = g.y + g.v * dt; g.len = min(5, g.len + g.v * dt * 0.3)
        if random() < dt * 2 then g.v = 0 end
        if g.y > 34 then g.y = R(16, 22); g.x = R(9, 31); g.len = 0 end
      end
    end
    think(s.fig, function()
      if random() < 0.55 then return { { "pose", "sit_read", R(20, 40) }, { "pose", "sit", R(4, 8) } } end
      return { { "pose", "stand", 2 }, { "walk", 78 }, { "face", 1 }, { "fn", function() s.atpiano = true end }, { "pose", "play", R(30, 50) },
        { "fn", function() s.atpiano = false end }, { "pose", "stand", 2 }, { "walk", 46 }, { "face", 1 }, { "pose", "sit_read", 10 } }
    end)
    s.fig:update(dt)
    for k, v in pairs(s.keys) do s.keys[k] = v - dt * 3; if s.keys[k] <= 0 then s.keys[k] = nil end end
    s.drip.y = s.drip.y + dt * 30
    if s.drip.y > 58 then s.drip.y = 8; s.drip.rip = 1; S.env.sfx("drop", R(1100, 1500), 0.04, 0.25, -0.6, 0.5) end
    s.drip.rip = max(0, s.drip.rip - dt)
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 3, paper = "fiori", ceil = 5,
      lights = { { x = 60, y = 24, r = 20, l = 2 } } }, t)
    K.window(8, 15, 24, 20, K.views.rain, t, s.win, 6)
    for _, g in ipairs(s.glass) do
      D.px(g.x, g.y, 12)
      if g.len > 1 then D.line(g.x, g.y - g.len, g.x, g.y - 1, 6) end
    end
    D.poly({ 4, 12, 8, 12, 7 + sin(t * 0.3) * 0.5, 40, 3, 40 }, 5)
    D.poly({ 32, 12, 36, 12, 37, 40, 33 + sin(t * 0.3 + 1) * 0.5, 40 }, 5)
    local cx, kb = K.piano(82, 58, 1, s.keys)
    K.lamp(64, 58, 4, 1, t)
    K.armchair(46, 58, 1, 4)
    K.rug(30, 70, 58, 4)
    -- la pentola e la goccia
    D.poly({ 14, 59, 22, 59, 21, 63, 15, 63 }, 6)
    D.line(14, 59, 22, 59, 9)
    D.px(18, s.drip.y, 12)
    if s.drip.rip > 0 then D.ripple(18, 59, (1 - s.drip.rip) * 4, 10 * s.drip.rip) end
    s.fig:draw()
  end,
  note = function(s, ev) if ev.str == "piano" then s.keys[floor(ev.midi) % 9] = 1 end end,
}

-------------------------------------------------------------------------------
-- GIORNO DOPO GIORNO (la cucina dei nonni)
-------------------------------------------------------------------------------
S.nonni = {
  init = function(s)
    s.steam = D.parts(10)
    s.win = { cloud = 5 }
    s.nonna = D.figura(100, 58, { s = KS, l = 3, dark = true, dress = true, bun = true, bent = 6, speed = 4, pose = "bend" })
    s.nonno = D.figura(40, 58, { s = KS, l = 2, dark = true, pose = "sit_read",
      prop = function(x, y, f) if f.cur.fa1 > 100 then D.rect(x - 4, y - 6, 9, 7, 12); D.line(x - 4, y - 3, x + 4, y - 3, 8) end end })
    s.kid = D.figura(20, 62, { s = 0.75, l = 3, dark = true, child = true, coat = false, pose = "dig", speed = 5 })
    s.car = { x = 26, v = 0 }
    s.call = 0
  end,
  update = function(s, dt, t)
    D.smoke_update(s.steam, dt, 104, 30, 2, t, 0.5)
    think(s.nonna, function()
      local r = random()
      if r < 0.5 then return { { "pose", "bend", R(6, 12) }, { "pose", "carry", 2 }, { "pose", "bend", 4 } } end
      if r < 0.7 then return { { "face", -1 }, { "fn", function() s.call = 3 end }, { "pose", "stand", 4 }, { "face", 1 }, { "pose", "bend", 4 } } end
      return { { "walk", 70 }, { "pose", "carry", 3 }, { "walk", 100 }, { "face", 1 }, { "pose", "bend", 4 } }
    end)
    think(s.nonno, function()
      if random() < 0.3 then return { { "pose", "sit", 3 }, { "pose", "sit_read", R(10, 20) } } end
      return { { "pose", "sit_read", R(12, 24) } }
    end)
    think(s.kid, function()
      if random() < 0.6 then return { { "pose", "dig", R(4, 9) }, { "fn", function() s.car.v = R(10, 20) * pick({ -1, 1 }) end } } end
      return { { "pose", "stand", 2 }, { "walk", R(10, 30) }, { "pose", "dig", 4 } }
    end)
    s.nonna:update(dt); s.nonno:update(dt); s.kid:update(dt)
    s.car.x = D.clamp(s.car.x + s.car.v * dt, 4, 40); s.car.v = s.car.v * (1 - dt * 1.5)
    s.call = max(0, s.call - dt)
  end,
  draw = function(s, t)
    K.room({ wall = 6, fy = 58, floor = "scacchi", floor_l = 4, paper = "piastrelle", tile_y = 36, ceil = 4 }, t)
    K.window(6, 10, 20, 16, K.views.day, t, s.win, 4)
    D.poly({ 3, 8, 8, 8, 7 + sin(t * 0.4), 28, 2, 28 }, 9)
    D.rect(44, 22, 24, 2, 3)
    K.radio(48, 22, 3, t)
    K.clock(76, 12, t, 5, true)
    local top = K.stove(92, 58, 2, t)
    D.rect(100, top - 5, 9, 5, 3); D.line(99, top - 5, 110, top - 5, 5)
    D.smoke_draw(s.steam, 12)
    -- il lavello e i piatti
    D.rect(120, 46, 8, 12, 7)
    for k = 0, 2 do D.circle(124, 44 - k * 1.5, 3, 11 - k) end
    local ty = K.table(28, 58, 2.2, 5, 9)
    D.circle(52, ty - 2, 1.5, 12); D.rect(54, ty - 3, 2, 3, 10)
    K.chair(38, 58, 1, 3)
    D.rect(s.car.x, 60, 5, 2, 13); D.rect(s.car.x + 1, 59, 3, 1, 11)
    D.px(s.car.x + 1, 62, 1); D.px(s.car.x + 4, 62, 1)
    s.nonno:draw(); s.kid:draw(); s.nonna:draw()
    if s.call > 0 then
      local a = s.call / 3
      local nx, ny = s.nonna.x - 8, s.nonna.y - 26
      D.line(nx, ny, nx - 3, ny - 1, 3 * a + 1); D.line(nx, ny + 3, nx - 4, ny + 3, 3 * a + 1)
    end
  end,
}

-------------------------------------------------------------------------------
-- IL SOTTOSCALA
-------------------------------------------------------------------------------
S.sottoscala = {
  init = function(s)
    s.kid = D.figura(88, 61, { s = 0.7, l = 5, child = true, coat = false, pose = "sit_ground" })
    s.feet = { x = -20, dir = 1, active = false, wait = R(6, 14) }
    s.motes = D.parts(16)
  end,
  update = function(s, dt, t)
    local f = s.feet
    if f.active then
      local old = f.x
      f.x = f.x + f.dir * dt * 10
      if floor(old / 9) ~= floor(f.x / 9) then S.env.step("legno", f.x / 64 - 1, 0.6) end
      if f.x > 140 or f.x < -20 then f.active = false; f.wait = R(10, 30) end
    else
      f.wait = f.wait - dt
      if f.wait < 0 then f.active = true; f.dir = pick({ 1, -1 }); f.x = f.dir > 0 and -10 or 136 end
    end
    think(s.kid, function()
      local r = random()
      if r < 0.6 then return { { "pose", "sit_ground", R(15, 30) } } end
      if r < 0.85 then return { { "pose", "sit_think", R(8, 14) } } end
      return { { "pose", "curl", R(10, 18) }, { "pose", "sit_ground", 4 } }
    end)
    s.kid.y = s.kid.cur.rot > 30 and 62 or 61
    s.kid:update(dt)
    D.motes_update(s.motes, dt, 1.2, { 60, 30, 40, 30 }, t)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 5)
    D.rect(0, 0, 128, 3, 4)
    K.frame(8, 4, 14, 10, 4, 3)
    screen.level(D.lv(0))
    screen.move(0, 64)
    for k = 0, 13 do local x, y = k * 10, 64 - k * 5; screen.line(x, y); screen.line(x + 10, y) end
    screen.line(130, -6); screen.line(130, 64); screen.close(); screen.fill()
    local feet = s.feet
    for k = 0, 13 do
      local x, y = k * 10, 64 - k * 5
      D.rect(x, y - 1, 10, 1, 10); D.rect(x, y, 10, 2, 4)
      local shade = (feet.active and abs(feet.x - x - 5) < 8) and 0.15 or 1
      if k >= 2 and k <= 12 then
        D.line(x + 10, y + 2, x + 10, y - 3, 8 * shade)
        D.line(x + 9, y + 3, x - 2, y + 26, 2 * shade)
        D.line(x + 10, y + 3, x, y + 26, 1 * shade)
      end
    end
    for k = 0, 12 do D.line(k * 10 + 10, 64 - k * 5 + 2, k * 10 + 20, 64 - k * 5 - 3, 1) end
    if feet.active then
      local k = D.clamp(feet.x / 10, 0, 13)
      local y = 64 - floor(k) * 5 - 1
      local ph = sin(feet.x * 0.6)
      D.thick(feet.x, y - 1, feet.x + ph * 2, y - 16, 2, 2); D.thick(feet.x + 3, y - 1, feet.x + 3 - ph * 2, y - 16, 2, 2)
      D.rect(feet.x - 1, y - 1, 4, 1, 1); D.rect(feet.x + 2, y - 1, 4, 1, 1)
    end
    D.motes_draw(s.motes, 6)
    D.circle(100, 60, 1.8, 3); D.circle(100, 57, 1.4, 3); D.px(99, 55, 3); D.px(101, 55, 3)
    s.kid:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL NONNO TRA LE STANZE
-------------------------------------------------------------------------------
S.nonno = {
  init = function(s)
    s.doors = { 14, 56, 98 }
    s.old = D.figura(14, 58, { s = KS * 0.95, l = 9, bent = 26, speed = 2.2,
      on_step = function(f) S.env.step("sabbia", pan(f.x), 0.25) end })
    s.kid = D.figura(108, 58, { s = 0.85, l = 6, child = true, coat = false, face = -1 })
    s.lit = { 1, 0.6, 0.8 }
  end,
  update = function(s, dt, t)
    think(s.old, function()
      local tx = s.doors[random(#s.doors)] + R(-2, 8)
      return { { "walk", tx }, { "pose", "window", R(3, 6) }, { "pose", "head_down", R(3, 6) }, { "pose", "stand", 2 } }
    end)
    s.old:update(dt)
    if not s.old.walking then s.old.cur.lean = s.old.cur.lean + (26 - s.old.cur.lean) * dt end
    think(s.kid, function()
      if random() < 0.5 then return { { "pose", "stand", R(6, 12) } } end
      return { { "walk", 114 }, { "pose", "stand", R(4, 8) }, { "walk", 108 }, { "face", -1 }, { "pose", "hug", 6 } }
    end)
    s.kid:update(dt)
    for i = 1, 3 do s.lit[i] = 0.6 + 0.4 * D.noise(t * 0.3 + i * 10) end
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "piastrelle", floor_l = 3, paper = "righe", ceil = 4 }, t)
    for i, dx in ipairs(s.doors) do
      local l = s.lit[i]
      local w, h = K.U * 0.9, K.U * 2.1
      D.rect(dx - 1, 58 - h - 1, w + 2, h + 1, 4)
      D.rect(dx, 58 - h, w, h, 6 * l)
      D.rect(dx, 58 - h, w, 8, 7 * l)
      if i == 1 then D.rect(dx, 48, 9, 6, 3 * l); D.rect(dx, 45, 3, 3, 4 * l)
      elseif i == 2 then D.rect(dx + 3, 32, 6, 7, 10 * l); D.rect(dx + 1, 48, 10, 10, 3 * l)
      else D.rect(dx + 2, 34, 8, 24, 3 * l) end
      D.poly({ dx, 58, dx + w, 58, dx + w + 6, 64, dx - 4, 64 }, 4 * l)
    end
    K.frame(36, 18, 10, 8, 3, 2); K.frame(80, 16, 12, 9, 3, 2)
    s.kid:draw()
    s.old:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'OSPEDALE DI NOTTE
-------------------------------------------------------------------------------
S.ospedale = {
  init = function(s)
    s.fig = D.figura(28, 57, { s = 1.05, l = 9, pose = "sit_slump", speed = 4, on_step = H.steps("piastrelle", 0.35) })
    s.blip = 0
    s.ecg = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.55 then return { { "pose", "sit_slump", R(18, 30) }, { "pose", "sit", R(6, 10) } } end
      if r < 0.8 then return { { "pose", "stand", 2 }, { "walk", 88 }, { "face", 1 }, { "pose", "stand", R(5, 8) }, { "walk", 28 }, { "face", 1 }, { "pose", "sit", 4 } } end
      return { { "pose", "stand", 2 }, { "walk", 60 }, { "face", 1 }, { "pose", "look_up", 6 }, { "walk", 28 }, { "face", 1 }, { "pose", "sit_slump", 10 } }
    end)
    s.fig:update(dt)
    s.blip = max(0, s.blip - dt * 2)
    s.ecg = (s.ecg + dt * 18 * (1 + mac("battito"))) % 20
  end,
  draw = function(s, t)
    local vx, vy = 64, 28
    D.rect(0, 0, 128, 64, 3)
    D.poly({ 0, 0, 128, 0, vx + 10, vy - 6, vx - 10, vy - 6 }, 2)
    D.poly({ 0, 64, 128, 64, vx + 10, vy + 6, vx - 10, vy + 6 }, 4)
    D.poly({ 0, 0, vx - 10, vy - 6, vx - 10, vy + 6, 0, 64 }, 3)
    D.poly({ 128, 0, vx + 10, vy - 6, vx + 10, vy + 6, 128, 64 }, 3)
    D.rect(vx - 10, vy - 6, 20, 12, 1); D.rect(vx - 3, vy - 4, 6, 6, 6)
    for k = -6, 6 do D.line(vx + k * 2, vy + 6, vx + k * 22, 64, 3) end
    local y, g = vy + 8, 1.5
    while y < 64 do D.line(0, y, 127, y, 3); y = y + g; g = g * 1.4 end
    for k = 1, 4 do
      local f = k / 5
      local ww = 4 + f * 40
      local cy = vy - 6 - f * f * 26
      local flick = (k == 2 and D.noise(t * 6) < 0.25) and 0.3 or 1
      D.rect(vx - ww / 2, cy, ww, 1 + f * 2, 12 * flick)
    end
    D.poly({ 12, 16, 22, 20, 22, 46, 12, 52 }, 1)
    D.poly({ 104, 22, 112, 18, 112, 50, 104, 44 }, 1)
    D.rect(105, 26, 6, 5, 0)
    for k = 0, 5 do
      local h = (abs(((s.ecg + k * 3) % 20) - 4) < 1) and 3 or 0
      D.px(105 + k, 29 - h * (1 + s.blip), 9 + s.blip * 5)
    end
    D.poly({ 92, 16, 102, 13, 102, 56, 92, 54 }, 2)
    D.rect(94, 18, 6, 18, 8 + D.noise(t) * 2)
    for k = 0, 3 do D.rect(94, 39 + k * 3, 6, 1, 5) end
    for k = 0, 2 do
      local x = 10 + k * 13
      D.rect(x, 49, 10, 2, 6); D.rect(x + 8, 40, 2, 10, 6)
      D.line(x + 1, 51, x + 1, 56, 5); D.line(x + 9, 51, x + 9, 56, 5)
    end
    s.fig:draw()
  end,
  note = function(s, ev) if ev.ruolo == "pulsazione" then s.blip = 1 end end,
}

-------------------------------------------------------------------------------
-- LEI CHE LEGGE
-------------------------------------------------------------------------------
S.lettura = {
  init = function(s)
    s.win = {}
    s.lei = D.figura(52, 58, { s = KS, l = 11, pose = "sit_read", dress = true, face = 1,
      prop = function(x, y, f) if f.cur.fa1 > 100 then D.rect(x - 3, y - 4, 6, 5, 13); D.line(x, y - 4, x, y, 9); if s.page > 0 then D.line(x, y - 4, x + 2 * s.page, y - 6, 15) end end end })
    s.tu = D.figura(96, 58, { s = KS, l = 7, pose = "sit", face = -1 })
    s.page = 0
  end,
  update = function(s, dt, t)
    think(s.lei, function() return { { "pose", "sit_read", R(10, 18) }, { "fn", function() s.page = 1 end }, { "pose", "sit_read", 2 } } end)
    think(s.tu, function()
      local r = random()
      if r < 0.5 then return { { "pose", "sit", R(10, 18) } } end
      if r < 0.8 then return { { "pose", "sit_think", R(8, 14) } } end
      return { { "pose", "sit_read", R(8, 12) } }
    end)
    s.lei:update(dt); s.tu:update(dt)
    s.page = max(0, s.page - dt * 1.5)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    K.room({ wall = 3, fy = 58, floor = "moquette", floor_l = 2, paper = "righe", ceil = 4,
      lights = { { x = 34, y = 26, r = 26 + warm * 6, l = 2 + warm } } }, t)
    local view = mac("pioggia") > 0.2 and K.views.rain or K.views.night
    K.window(72, 12, 20, 18, view, t, s.win, 5)
    K.bookcase(108, 58, 4, 9)
    K.bookcase(4, 58, 4, 3)
    K.lamp(34, 58, 4, 1 + warm, t)
    K.sofa(42, 58, 4, 1.4)
    K.armchair(96, 58, -1, 4)
    -- una pila di libri per terra
    for i = 0, 3 do D.rect(74, 56 - i * 2, 8 - i % 2, 2, 6 + (i % 3) * 2) end
    s.lei:draw(); s.tu:draw()
  end,
}

-------------------------------------------------------------------------------
-- TUO FIGLIO
-------------------------------------------------------------------------------
S.figlio = {
  init = function(s)
    s.win = { cloud = 3 }
    s.fig = D.figura(56, 58, { s = KS, l = 3, dark = true, pose = "cradle",
      prop = function(x, y) D.circle(x - 2, y - 2, 3.2, 13); D.circle(x - 4, y - 4, 1.8, 14) end })
    s.motes = D.parts(18)
    s.sway = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.6 then return { { "pose", "cradle", R(14, 26) } } end
      if r < 0.85 then return { { "walk", R(40, 70), 3 }, { "pose", "cradle", 10 } } end
      return { { "walk", 24, 3 }, { "face", -1 }, { "pose", "cradle", 12 }, { "face", 1 } }
    end)
    s.fig:update(dt)
    if not s.fig.walking then s.fig.cur.lean = s.fig.cur.lean + sin(t * 1.1) * 0.15 end
    D.motes_update(s.motes, dt, 2, { 14, 14, 50, 40 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    K.room({ wall = 7 + lu, fy = 58, floor = "assi", floor_l = 6, paper = "puntini", ceil = 4 }, t)
    K.window(8, 12, 26, 22, K.views.day, t, s.win, 9)
    -- lame di luce del mattino di giugno
    for k = 0, 4 do D.line(14 + k * 4, 34, 40 + k * 6, 58, 10 + lu) end
    K.pool(36, 58, 26, 9 + lu)
    D.poly({ 4, 10, 9, 10, 8 + sin(t * 0.5) * 1.5, 38, 3, 38 }, 12)
    D.poly({ 33, 10, 38, 10, 39, 38, 34 + sin(t * 0.5 + 1) * 1.5, 38 }, 12)
    local cy = K.crib(92, 58, 5)
    D.rect(94, cy - 3, 16, 3, 12)
    K.frame(70, 16, 10, 12, 5, 9)
    D.motes_draw(s.motes, 13)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA SOFFITTA
-------------------------------------------------------------------------------
S.soffitta = {
  init = function(s)
    s.fig = D.figura(58, 58, { s = KS, l = 10, pose = "kneel", speed = 4, on_step = H.steps("legno", 0.4) })
    s.motes = D.parts(20)
    s.photos = D.parts(3)
    s.lid = 1
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "walk", 58 }, { "face", 1 }, { "pose", "kneel", R(4, 6) }, { "pose", "dig", 2 }, { "fn", function()
        D.spawn(s.photos, { x = 70, y = 48, vx = R(-2, 2), vy = -R(1, 3), life = 7 })
      end }, { "pose", "pray", R(6, 10) } } end
      if r < 0.8 then return { { "walk", 96 }, { "face", 1 }, { "pose", "look_up", R(6, 10) } } end
      return { { "walk", 30 }, { "face", -1 }, { "pose", "window", R(5, 8) } }
    end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 2.5, { 70, 6, 40, 50 }, t)
    D.parts_update(s.photos, dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 2)
    -- il tetto spiovente
    D.poly({ 0, 0, 128, 0, 128, 10, 64, -30, 0, 26 }, 1)
    for k = 0, 6 do D.line(0, 26 - k * 4, 64 - k * 2, -30, 3) end
    D.line(0, 26, 64, -30, 4); D.line(64, -30, 128, 10, 4)
    -- il lucernario e la sua lama di luce
    D.poly({ 84, 2, 98, 6, 96, 12, 82, 8 }, 11 + lu * 2)
    D.poly({ 82, 8, 96, 12, 116, 58, 86, 58 }, 4 + lu)
    D.motes_draw(s.motes, 10)
    K.floor(58, "assi", 3, 64)
    -- il baule aperto
    D.rect(64, 48, 20, 10, 5); D.rect(64, 48, 20, 1, 8)
    D.poly({ 64, 48, 84, 48, 86, 38, 66, 38 }, 4)
    for i = 0, 2 do D.rect(67 + i * 5, 46, 4, 2, 11 - i) end
    -- il cavallo a dondolo, il manichino
    local rk = sin(t * 0.6) * 0.15
    D.line(14, 58, 22, 56 + rk * 10, 4); D.line(22, 56 + rk * 10, 30, 58, 4)
    D.poly({ 16, 50, 28, 49, 30, 44, 33, 44, 31, 50, 28, 53, 16, 53 }, 5)
    D.circle(110, 30, 4, 4); D.poly({ 104, 34, 116, 34, 114, 48, 106, 48 }, 4); D.line(110, 48, 110, 58, 3)
    for _, p in ipairs(s.photos.list) do
      local f = min(1, p.age, (p.life - p.age) / 2)
      D.rect(p.x, p.y, 5, 4, 12 * f); D.rect(p.x + 1, p.y + 1, 3, 2, 5 * f)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL VECCHIO LETTO
-------------------------------------------------------------------------------
S.letto_nonni = {
  init = function(s)
    s.win = { moon = true }
    s.fig = D.figura(70, 58, { s = KS, l = 9, pose = "sit_edge", face = -1 })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "sit_edge", "sit_edge", "sit_think", "sit_slump" }), R(12, 24) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 2, paper = "fiori", ceil = 4,
      lights = { { x = 100, y = 40, r = 14, l = 2 } } }, t)
    K.window(8, 14, 18, 18, K.views.night, t, s.win, 4)
    local by = K.bed(30, 58, 2.6, 4, 7)
    for x = 34, 64, 3 do D.px(x, by - 1, 10); D.px(x + 1, by, 9) end
    K.frame(50, 14, 10, 13, 4, 3); D.cross(55, 24, 7, 7)
    -- il comodino con gli occhiali e la corona
    D.rect(94, 48, 12, 10, 4); D.rect(94, 48, 12, 1, 6)
    D.circle(97, 46.5, 1.2, 9, true); D.circle(100, 46.5, 1.2, 9, true)
    D.px(103, 47, 10); D.px(104, 46, 10); D.px(105, 47, 10)
    K.lamp(100, 48, 3, 0.5, t)
    K.wardrobe(108, 58, 3)
    D.rect(110, 26, 6, 20, 5)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA STANZA DI CHI NON C'È PIÙ
-------------------------------------------------------------------------------
S.stanza_vuota = {
  init = function(s)
    s.win = {}
    s.fig = D.figura(118, 58, { s = KS, l = 3, dark = true, face = -1, pose = "stand", speed = 3, on_step = H.steps("legno", 0.3) })
    s.motes = D.parts(14)
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "stand", R(12, 22) }, { "pose", "head_down", R(6, 10) } } end
      if r < 0.8 then return { { "walk", R(70, 100) }, { "pose", "window", R(4, 8) }, { "walk", 118 }, { "face", -1 } } end
      return { { "walk", 60 }, { "pose", "sit_edge", R(10, 16) }, { "walk", 118 }, { "face", -1 } }
    end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 1.5, { 20, 10, 50, 40 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    K.room({ wall = 4, fy = 58, floor = "assi", floor_l = 3, paper = "righe", ceil = 4 }, t)
    K.window(26, 12, 22, 20, K.views.day, t, s.win, 7)
    local o = (t * 0.1) % 30
    D.poly({ 30 + o, 58, 52 + o, 58, 62 + o, 64, 36 + o, 64 }, 7 + lu * 2)
    D.motes_draw(s.motes, 10)
    K.bed(44, 58, 2.2, 5, 9)
    -- la sedia coi vestiti piegati, le scarpe
    K.chair(86, 58, -1, 5)
    D.rect(83, 49, 7, 2, 10)
    D.rect(92, 56, 3, 2, 3); D.rect(96, 56, 3, 2, 3)
    K.door(110, 58, 0.7, 4, 6)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL LIBRO PER LEI
-------------------------------------------------------------------------------
S.scrivere = {
  init = function(s)
    s.win = { moon = true }
    s.fig = D.figura(46, 58, { s = KS, l = 9, pose = "type" })
    s.pages = D.parts(3)
    s.stack = 3
    s.lamp = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.6 then return { { "pose", "type", R(10, 20) }, { "fn", function()
        s.stack = min(12, s.stack + 1)
        if random() < 0.5 then D.spawn(s.pages, { x = 70, y = 40, vx = R(4, 10), vy = -R(3, 6), life = 6, rot = 0 }) end
      end } } end
      if r < 0.85 then return { { "pose", "sit_think", R(8, 14) } } end
      return { { "pose", "stand", 2 }, { "walk", 24 }, { "face", -1 }, { "pose", "window", R(6, 10) }, { "walk", 46 }, { "face", 1 }, { "pose", "type", 6 } }
    end)
    s.fig:update(dt)
    D.parts_update(s.pages, dt, function(p, d) p.vy = p.vy + 2 * d; p.rot = p.rot + d * 2 end)
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 2, paper = "assi", ceil = 4,
      lights = { { x = 76, y = 34, r = 24, l = 3 } } }, t)
    K.window(14, 12, 20, 18, K.views.night, t, s.win, 5)
    local ty = K.desk(56, 58, 5)
    K.typewriter(58, ty, 4)
    -- la pila di fogli che cresce
    for i = 1, s.stack do D.line(74, ty - i * 0.6, 81, ty - i * 0.6, 13) end
    -- la lampada da tavolo
    D.line(84, ty, 84, ty - 10, 5); D.line(84, ty - 10, 78, ty - 14, 5)
    D.poly({ 75, ty - 16, 81, ty - 13, 78, ty - 11 }, 11)
    D.glow(78, ty - 8, 12, 6)
    for _, p in ipairs(s.pages.list) do
      local f = min(1, (p.life - p.age) / 2)
      local c, sn = cos(p.rot), sin(p.rot)
      D.poly({ p.x, p.y, p.x + 6 * c, p.y + 6 * sn * 0.5, p.x + 6 * c - 2, p.y + 6 * sn * 0.5 + 4, p.x - 2, p.y + 4 }, 13 * f)
    end
    K.chair(44, 58, 1, 4)
    K.bookcase(104, 58, 4, 21)
    s.fig:draw()
  end,
}

end
