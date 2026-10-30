-- ANAMNESI · scene dell'infanzia
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, copy, think, mac = H.R, H.pick, H.pan, H.copy, H.think, H.mac

-------------------------------------------------------------------------------
-- IN RIVA AL MARE
-------------------------------------------------------------------------------
S.mare = {
  init = function(s)
    s.child = D.figura(70, 57, { s = 0.6, l = 2, dark = true, child = true, coat = false, pose = "dig" })
    s.fig = D.figura(104, 56, { s = 0.95, l = 1, dark = true, face = -1, speed = 5, on_step = H.steps("sabbia", 0.3) })
    s.castle = 0
    s.gulls = {}
    for i = 1, 4 do s.gulls[i] = { x = R(0, 128), y = R(6, 20), ph = R(0, 6), v = R(4, 9) } end
  end,
  update = function(s, dt, t)
    think(s.child, function()
      local r = random()
      if r < 0.6 then return { { "pose", "dig", R(4, 8) }, { "fn", function() s.castle = min(6, s.castle + 1) end } } end
      if r < 0.8 then return { { "pose", "stand", 2 }, { "walk", R(55, 80), 6 }, { "walk", 70, 6 }, { "face", -1 }, { "pose", "dig", 4 } } end
      return { { "pose", "stand", 1 }, { "pose", "arms_open", 3 }, { "pose", "dig", 3 } }
    end)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "stand", R(10, 20) }, { "face", -1 } } end
      if r < 0.75 then return { { "walk", R(84, 112) }, { "face", -1 }, { "pose", "look_up", 5 }, { "pose", "stand", 8 } } end
      return { { "pose", "sit_ground", R(20, 30) }, { "pose", "stand", 2 } }
    end)
    s.child:update(dt); s.fig:update(dt)
    for _, g in ipairs(s.gulls) do g.x = (g.x + g.v * dt) % 150 end
    if s.castle >= 6 and random() < dt * 0.02 then s.castle = 0 end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 6 + lu * 2, 10 + lu * 2)
    D.circle(30, 25, 9, 11); D.circle(30, 25, 5, 14)
    D.gradient(30, 46, 4, 6)
    D.reflection(30, 31, 45, 8, t, 12)
    D.waves(31, 46, t, 10, 5 + mac("mare") * 6, 3)
    local swell = (0.5 + 0.5 * sin(t * 2 * pi / 8.9)) ^ 2
    local sy = 46 + swell * (3 + mac("mare") * 3)
    D.rect(0, 46, 128, 18, 8)
    D.rect(0, 46, 128, floor(sy - 46 + 1), 6)
    for x = 0, 127, 2 do if D.noise(x * 0.3 + t) > 0.4 then D.px(x, sy + 1, 13) end end
    for i = 0, 40 do D.px((i * 31) % 128, 50 + (i * 7) % 14, 6) end
    for k = 1, s.castle do D.rect(60 - k * 0.4, 58 - k, 5 - k * 0.5, 1, 5) end
    D.poly({ 76, 58, 80, 58, 79.5, 54, 76.5, 54 }, 3)
    D.line(76, 54, 78, 52, 3); D.line(78, 52, 80, 54, 3)
    for _, g in ipairs(s.gulls) do
      local w = sin(t * 5 + g.ph) * 1.5
      D.line(g.x - 2, g.y - w, g.x, g.y, 3); D.line(g.x, g.y, g.x + 2, g.y - w, 3)
    end
    s.child:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL FARO (nascosto)
-------------------------------------------------------------------------------
S.faro = {
  init = function(s)
    s.stars = D.stars_gen(70, 141, 0, 30)
    s.fig = D.figura(30, 50, { s = 0.85, l = 3, dark = true, pose = "sit_ground" })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "sit_ground", "stand", "look_up" }), R(12, 24) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.gradient(0, 36, 0, 2)
    D.stars(s.stars, t, 0.8)
    D.rect(0, 36, 128, 28, 1)
    D.waves(37, 64, t, 4, 5, 7)
    -- il fascio che gira
    local a = t * 0.9
    local lx, ly = 96, 14
    local c = cos(a)
    if c > -0.2 then
      local w = 6 + c * 10
      local dir = sin(a) > 0 and 1 or -1
      local len = 90 * (0.3 + abs(sin(a)) * 0.7)
      D.poly({ lx, ly, lx + dir * len, ly - w * 0.5 + 6, lx + dir * len, ly + w + 6 }, 2 + c * 3)
      D.reflection(lx + dir * len * 0.5, 38, 60, 6 + c * 6, t, 3 + c * 3)
    end
    D.rect(92, 14, 8, 30, 6)
    for y = 18, 42, 6 do D.rect(92, y, 8, 2, 3) end
    D.rect(91, 10, 10, 4, 3); D.rect(93, 11, 6, 3, 15)
    D.poly({ 90, 10, 102, 10, 96, 6 }, 3)
    D.poly({ 76, 64, 84, 44, 108, 44, 120, 64 }, 2)
    D.poly({ 10, 64, 18, 52, 40, 50, 52, 64 }, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- NOTTE DI SAN LORENZO
-------------------------------------------------------------------------------
S.lorenzo = {
  init = function(s)
    D.POSE.sit_point = { lean = 6, nod = -30, ua1 = 150, ua2 = 50, fa1 = 158, fa2 = 96, th1 = 112, th2 = 108, sh1 = 0, sh2 = -6, hy = 1.7, rot = 0 }
    s.stars = D.stars_gen(130, 21, 0, 44)
    s.met = D.parts(6)
    s.grass = D.grass_gen(22, 70, 0, 128, 2, 6)
    s.ff = D.parts(8)
    s.kid = D.figura(54, 56, { s = 0.7, l = 8, child = true, coat = false, pose = "lie" })
    s.old = D.figura(72, 56, { s = 0.95, l = 7, pose = "sit_ground", face = -1 })
  end,
  meteor = function(s) D.spawn(s.met, { x = R(10, 128), y = R(0, 14), vx = -R(60, 110), vy = R(20, 40), life = R(0.6, 1.1) }) end,
  update = function(s, dt, t)
    if random() < dt * (0.1 + mac("stelle") * 0.3) then S.lorenzo.meteor(s) end
    D.parts_update(s.met, dt)
    D.motes_update(s.ff, dt, 0.4 + mac("notte") * 0.6, { 0, 44, 128, 18 }, t)
    think(s.old, function()
      if random() < 0.4 then return { { "pose", "sit_point", R(3, 6) }, { "pose", "sit_ground", R(8, 16) } } end
      return { { "pose", "sit_ground", R(10, 20) } }
    end)
    s.kid:update(dt); s.old:update(dt)
  end,
  draw = function(s, t)
    D.gradient(0, 44, 0, 2)
    D.stars(s.stars, t, 1 + mac("stelle") * 0.3)
    for _, m in ipairs(s.met.list) do
      local f = 1 - m.age / m.life
      D.line(m.x, m.y, m.x - m.vx * 0.15, m.y - m.vy * 0.15, 5 * f)
      D.line(m.x, m.y, m.x - m.vx * 0.06, m.y - m.vy * 0.06, 12 * f)
      D.px(m.x, m.y, 15)
    end
    D.rect(0, 44, 128, 4, 1)
    D.rect(0, 48, 128, 16, 1)
    D.grass(s.grass, 53, t, 3, 0.4)
    s.old:draw(); s.kid:draw()
    D.motes_draw(s.ff, 9)
  end,
  note = function(s, ev)
    if ev.ruolo == "melodia" and random() < 0.5 then S.lorenzo.meteor(s) end
    if ev.ruolo == "scintille" then D.flare_star(s.stars) end
  end,
}

-------------------------------------------------------------------------------
-- ESTATE DAI NONNI
-------------------------------------------------------------------------------
S.estate = {
  init = function(s)
    s.nonna = D.figura(40, 55, { s = 0.95, l = 2, dark = true, dress = true, bun = true, bent = 8, speed = 4 })
    s.kid = D.figura(100, 57, { s = 0.6, l = 2, dark = true, child = true, coat = false, speed = 9 })
    s.ball = { x = 100, y = 56, vx = 0, vy = 0 }
    s.bread = false
    s.flies = D.parts(5)
  end,
  update = function(s, dt, t)
    think(s.nonna, function()
      if random() < 0.5 then
        return { { "walk", 36 }, { "pose", "carry", 2 }, { "walk", 74 }, { "pose", "bend", 2 }, { "fn", function() s.bread = true end },
          { "pose", "bend", 4 }, { "pose", "stand", 3 }, { "walk", 36 }, { "pose", "stand", R(6, 12) } }
      end
      return { { "pose", "stand", R(6, 10) }, { "pose", "look_up", 3 } }
    end)
    think(s.kid, function()
      local r = random()
      if r < 0.5 then return { { "walk", R(56, 120) }, { "fn", function() s.ball.vx = R(-30, 30); s.ball.vy = -R(20, 35) end }, { "pose", "stand", 2 } } end
      if r < 0.8 then return { { "pose", "sit_ground", R(8, 14) } } end
      return { { "walk", 30 }, { "pose", "hug", 3 }, { "walk", 100 } }
    end)
    s.nonna:update(dt); s.kid:update(dt)
    local b = s.ball
    b.vy = b.vy + 60 * dt
    b.x = D.clamp(b.x + b.vx * dt, 50, 126); b.y = b.y + b.vy * dt
    if b.y > 57 then b.y = 57; b.vy = -b.vy * 0.4; b.vx = b.vx * 0.7 end
    D.motes_update(s.flies, dt, 0.5, { 60, 30, 40, 20 }, t)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    D.gradient(0, 50, 9 + warm, 11 + warm)
    D.circle(112, 8, 7, 13); D.circle(112, 8, 4, 15)
    for i = 0, 3 do
      local y = 14 + i * 7
      for x = 0, 127, 6 do D.px(x + sin(t * 3 + i + x * 0.2) * (2 + warm * 2), y, 12) end
    end
    D.rect(0, 16, 52, 38, 6)
    D.poly({ -2, 16, 54, 16, 46, 8, 0, 8 }, 4)
    for x = 0, 52, 3 do D.line(x, 9, x - 1, 15, 3) end
    for _, wx in ipairs({ 6, 30 }) do
      D.rect(wx, 22, 12, 12, 1)
      D.rect(wx, 22, 5, 12, 4); D.rect(wx + 7, 22, 5, 12, 4)
      for y = 23, 33, 2 do D.line(wx, y, wx + 4, y, 3); D.line(wx + 7, y, wx + 11, y, 3) end
    end
    D.rect(20, 40, 9, 14, 2); D.rect(18, 53, 13, 1, 5)
    D.rect(60, 30, 2, 24, 3); D.rect(96, 30, 2, 24, 3); D.rect(56, 29, 46, 2, 3)
    for x = 56, 100, 2 do D.line(x, 31, x + sin(t * 0.8 + x) * 0.5, 31 + 2 + D.noise(x * 0.4) * 4, 3) end
    D.rect(56, 54, 46, 2, 5)
    D.rect(66, 45, 26, 2, 8); D.line(68, 47, 68, 54, 4); D.line(90, 47, 90, 54, 4)
    if s.bread then D.circle(78, 44, 2, 7); D.px(77, 43, 10) end
    D.line(104, 22, 127, 20, 3)
    local bil = sin(t * 0.9) * 3
    D.poly({ 108, 22, 120, 21, 120 + bil, 35, 108 + bil * 0.6, 36 }, 13)
    D.rect(0, 54, 128, 10, 7)
    for i = 0, 30 do D.px((i * 23) % 128, 56 + (i * 5) % 8, 5) end
    D.circle(s.ball.x, s.ball.y - 1, 1.3, 3)
    s.nonna:draw(); s.kid:draw()
    D.motes_draw(s.flies, 2)
  end,
}

-------------------------------------------------------------------------------
-- LA CONCA NEL BOSCO
-------------------------------------------------------------------------------
local function conca_y(x) local u = (x - 64) / 64; return 54 - u * u * 12 end

S.conca = {
  init = function(s)
    s.leaves = D.parts(14)
    s.trunks = {}
    local r = D.lcg(51)
    for i = 1, 16 do s.trunks[i] = { x = r() * 128, w = 1 + r() * 4, l = 1 + r() * 3 } end
    table.sort(s.trunks, function(a, b) return a.l < b.l end)
    s.fig = D.figura(64, 54, { s = 1.0, l = 12, pose = "sit", speed = 3.5, on_step = H.steps("foglie", 0.3) })
    s.bird = { x = 30, hop = 0 }
  end,
  update = function(s, dt, t)
    if random() < dt * (1.2 + mac("foglie") * 2) then D.spawn(s.leaves, { x = R(0, 128), y = -2, vx = R(-2, 2), vy = R(5, 9), ph = R(0, 6), life = 20 }) end
    D.parts_update(s.leaves, dt, function(p, d)
      p.x = p.x + sin(t * 2 + p.ph) * 6 * d
      if p.y > conca_y(p.x) then p.vy = 0; p.vx = 0 end
    end)
    think(s.fig, function()
      if random() < 0.6 then return { { "pose", "sit", R(15, 30) }, { "pose", "sit_think", R(10, 20) } } end
      return { { "pose", "stand", 2 }, { "walk", R(30, 100), 3.5 }, { "pose", "look_up", 6 }, { "walk", 64, 3.5 }, { "face", 1 }, { "pose", "sit", 10 } }
    end)
    s.fig.y = (s.fig.cur.hy > 4 and s.fig.cur.hy < 6) and 54 or conca_y(s.fig.x)
    s.fig:update(dt)
    s.bird.hop = max(0, s.bird.hop - dt * 4)
    if random() < dt * 0.5 then s.bird.hop = 1; s.bird.x = D.clamp(s.bird.x + R(-4, 4), 10, 50) end
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 3)
    D.gradient(0, 20, 1, 3)
    for i = 0, 18 do
      local x, y = (i * 47) % 128, (i * 13) % 14
      if D.noise(t * 0.4 + i * 3) > 0.35 then D.px(x, y, 8); D.px(x + 1, y, 6) end
    end
    for i = 0, 2 do
      local x0 = 18 + i * 38 + sin(t * 0.1 + i) * 3
      for k = 0, 2 do D.line(x0 + k * 3, 0, x0 + 26 + k * 3, 52, 4) end
    end
    for _, tr in ipairs(s.trunks) do
      local sway = sin(t * 0.7 + tr.x) * (1.5 + mac("foglie") * 3)
      local lv = 3 - tr.l
      if tr.w > 2 then D.rect(tr.x - floor(tr.w / 2), 0, floor(tr.w), 64, lv) else D.line(tr.x, 64, tr.x, 0, lv) end
      D.circle(tr.x + sway, 3, 5 + tr.w, 1)
    end
    screen.level(D.lv(4)); screen.move(0, 64)
    for x = 0, 128, 4 do screen.line(x, conca_y(x)) end
    screen.line(128, 64); screen.close(); screen.fill()
    for i = 0, 60 do local x = (i * 41) % 128; D.px(x, conca_y(x) + 2 + (i % 8), 5 + (i % 3) * 2) end
    D.rect(52, 52, 24, 3, 2); D.line(52, 52, 75, 52, 5); D.circle(52, 53.5, 1.5, 6)
    local by = conca_y(s.bird.x) - 1 - s.bird.hop * 2
    D.circle(s.bird.x, by, 1.1, 1); D.px(s.bird.x + 1, by - 1, 1)
    for _, l in ipairs(s.leaves.list) do D.px(l.x, l.y, l.vy > 0 and 10 or 7) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- STRADA DI CAMPAGNA
-------------------------------------------------------------------------------
S.campagna = {
  init = function(s)
    s.bike = { x = -20, on = false, wait = R(5, 15) }
    s.fig = D.figura(28, 58, { s = 1.0, l = 2, dark = true, speed = 3, on_step = H.steps("ghiaia", 0.3) })
    s.kid = D.figura(-20, 56, { s = 0.6, l = 2, dark = true, child = true, coat = false, pose = "sit" })
  end,
  update = function(s, dt, t)
    local b = s.bike
    if b.on then
      b.x = b.x + dt * 22
      if b.x > 150 then b.on = false; b.wait = R(15, 35) end
    else
      b.wait = b.wait - dt
      if b.wait < 0 then b.on = true; b.x = -20 end
    end
    s.kid.x = b.x; s.kid.y = 54
    s.kid:update(dt)
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(20, 50) }, { "pose", "stand", R(6, 12) } } end
      return { { "pose", "look_up", R(6, 10) }, { "face", 1 }, { "pose", "stand", 8 } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    D.gradient(0, 34, 8 + warm, 11 + warm)
    D.circle(20, 10, 6, 13)
    D.rect(0, 34, 128, 30, 6)
    -- i campi a righe
    for k = 0, 8 do D.line(0, 36 + k * k * 0.4, 127, 36 + k * k * 0.4, 5 + (k % 2) * 2) end
    -- la strada bianca che va verso l'orizzonte
    D.poly({ 60, 34, 68, 34, 128, 64, 30, 64 }, 9)
    for y = 36, 63, 3 do D.px(64 + (y - 34) * 0.9, y, 7) end
    -- i pioppi in fila
    for i = 0, 6 do
      local f = i / 6
      local x = 70 + f * f * 60
      local h = 6 + f * f * 34
      local sway = sin(t * 0.7 + i) * (0.5 + mac("vento") * 2) * f
      D.poly({ x - h * 0.08, 36 + f * f * 26, x + h * 0.08, 36 + f * f * 26, x + sway, 36 + f * f * 26 - h }, 3)
    end
    for i = 0, 4 do
      local f = i / 4
      local x = 56 - f * f * 50
      local h = 6 + f * f * 30
      D.poly({ x - h * 0.08, 36 + f * f * 26, x + h * 0.08, 36 + f * f * 26, x, 36 + f * f * 26 - h }, 3)
    end
    for x = 0, 127, 6 do D.px(x + sin(t * 3 + x) * 2, 30, 12) end
    if s.bike.on then
      local x = s.bike.x
      D.circle(x - 3, 58, 2.5, 2, true); D.circle(x + 4, 58, 2.5, 2, true)
      D.line(x - 3, 58, x + 1, 55, 2); D.line(x + 1, 55, x + 4, 58, 2); D.line(x + 1, 55, x + 3, 53, 2)
      s.kid:draw()
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE LUCCIOLE
-------------------------------------------------------------------------------
S.lucciole = {
  init = function(s)
    s.ff = {}
    for i = 1, 44 do s.ff[i] = { x = R(0, 128), y = R(24, 60), ph = R(0, 6), sp = R(0.8, 2), vx = R(-3, 3), vy = R(-2, 2) } end
    s.kid = D.figura(60, 58, { s = 0.62, l = 3, child = true, coat = false, speed = 7,
      prop = function(x, y) D.rect(x - 1, y - 2, 3, 3, 6); D.px(x, y - 1, 13) end })
    s.fig = D.figura(100, 58, { s = 1.0, l = 2, dark = true, face = -1, pose = "stand" })
    s.trees = D.ridge_gen(151, 30, 8, 1.4)
  end,
  update = function(s, dt, t)
    for _, f in ipairs(s.ff) do
      f.vx = f.vx + (D.noise(t * 0.5 + f.ph * 9) - 0.5) * 8 * dt
      f.vy = f.vy + (D.noise(t * 0.5 + f.ph * 5 + 30) - 0.5) * 8 * dt
      f.x = (f.x + f.vx * dt) % 128; f.y = D.clamp(f.y + f.vy * dt, 20, 62)
    end
    think(s.kid, function() return { { "walk", R(10, 90) }, { "pose", "reach_up", R(1.5, 3) }, { "pose", "carry", 2 } } end)
    think(s.fig, function() return { { "pose", pick({ "stand", "look_up", "sit_ground" }), R(10, 20) } } end)
    s.kid:update(dt); s.fig:update(dt)
  end,
  draw = function(s, t)
    local n = mac("notte")
    D.gradient(0, 36, 2 + (1 - n) * 3, 5 + (1 - n) * 4)
    D.ridge(s.trees, 1, 64)
    D.rect(0, 52, 128, 12, 2)
    for x = 0, 127, 3 do D.line(x, 52, x + sin(t + x) * 0.6, 49 - (x * 7) % 4, 3) end
    s.fig:draw(); s.kid:draw()
    for _, f in ipairs(s.ff) do
      local b = sin(t * f.sp + f.ph)
      if b > 0.3 then
        D.px(f.x, f.y, 7 + b * 8)
        if b > 0.75 then D.glow(f.x, f.y, 3, 5) ; D.px(f.x, f.y, 15) end
      end
    end
  end,
}

-------------------------------------------------------------------------------
-- IL FIENILE
-------------------------------------------------------------------------------
S.fienile = {
  init = function(s)
    s.kid = D.figura(50, 50, { s = 0.85, l = 9, child = true, coat = false, pose = "stand" })
    s.jump = 0
    s.motes = D.parts(20)
    s.vy = 0
  end,
  update = function(s, dt, t)
    local k = s.kid
    think(k, function()
      local r = random()
      if r < 0.4 then return { { "walk", R(36, 70), 6 }, { "pose", "arms_open", 0.6 }, { "fn", function() s.vy = -30 end }, { "pose", "lie", R(4, 8) }, { "pose", "sit_ground", 3 }, { "pose", "stand", 2 } } end
      if r < 0.7 then return { { "pose", "sit_ground", R(8, 14) } } end
      return { { "pose", "lie", R(10, 16) } }
    end)
    s.vy = s.vy + 90 * dt
    k.y = min(50, k.y + s.vy * dt)
    k:update(dt)
    D.motes_update(s.motes, dt, 2, { 70, 10, 40, 40 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 2)
    for x = 0, 127, 7 do D.line(x, 0, x, 63, 1) end
    D.poly({ 0, 0, 64, -20, 128, 0 }, 1)
    -- il portone aperto sul giorno
    D.rect(92, 14, 30, 42, 11 + lu * 2)
    D.rect(92, 44, 30, 12, 8)
    D.circle(110, 22, 3, 14)
    -- lame di sole tra le assi
    for i = 0, 4 do
      local x0 = 16 + i * 14
      for k = 0, 1 do D.line(x0 + k, 0, x0 + 30 + k, 50, 4 + lu * 2) end
    end
    D.motes_draw(s.motes, 9)
    -- le balle di fieno
    for i, b in ipairs({ { 6, 44, 30, 12 }, { 14, 34, 22, 10 }, { 34, 48, 26, 10 }, { 60, 50, 22, 8 } }) do
      D.rect(b[1], b[2], b[3], b[4], 7)
      for y = b[2] + 2, b[2] + b[4] - 1, 3 do D.line(b[1], y, b[1] + b[3] - 1, y, 6) end
      D.line(b[1] + 4, b[2], b[1] + 4, b[2] + b[4] - 1, 5)
    end
    D.rect(0, 58, 128, 6, 5)
    for i = 0, 40 do D.px((i * 17) % 128, 58 + (i % 5), 8) end
    -- il nido delle rondini
    D.circle(20, 8, 3, 4); D.px(20, 6, 1)
    s.kid:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA FIERA DI PAESE
-------------------------------------------------------------------------------
S.fiera = {
  init = function(s)
    s.rot = 0
    s.people = {}
    for i = 1, 4 do s.people[i] = D.figura(R(0, 128), 60, { s = R(0.75, 0.95), l = 2, dark = true, speed = R(3, 6), dress = random() < 0.5 }) end
    s.kid = D.figura(30, 60, { s = 0.6, l = 2, dark = true, child = true, coat = false,
      prop = function(x, y) D.line(x, y, x + 1, y - 9, 6); D.circle(x + 1, y - 11, 2.2, 12) end })
    s.bulbs = 0
  end,
  update = function(s, dt, t)
    s.rot = s.rot + dt * 0.5
    for _, p in ipairs(s.people) do
      think(p, function() return { { "walk", R(-10, 138) }, { "pose", "stand", R(2, 6) } } end)
      p:update(dt)
    end
    think(s.kid, function() return { { "walk", R(10, 50) }, { "pose", "look_up", R(3, 6) } } end)
    s.kid:update(dt)
    s.bulbs = s.bulbs + dt
  end,
  draw = function(s, t)
    D.gradient(0, 50, 0, 3)
    -- fili di lampadine
    for k = 0, 1 do
      for i = 0, 26 do
        local x = i * 5
        local y = 6 + k * 8 + sin(i / 26 * pi) * 6
        local on = ((i + floor(s.bulbs * 3) + k) % 3) ~= 0
        D.px(x, y, on and 13 or 4)
      end
    end
    -- la giostra
    local cx, cy = 70, 30
    D.poly({ cx - 26, cy - 6, cx + 26, cy - 6, cx, cy - 18 }, 5)
    for i = 0, 8 do D.px(cx - 26 + i * 6.5, cy - 6, ((i + floor(s.bulbs * 4)) % 2 == 0) and 14 or 6) end
    D.rect(cx - 1, cy - 6, 2, 24, 7)
    D.rect(cx - 26, cy + 18, 52, 3, 6)
    for k = 0, 7 do
      local a = s.rot + k * pi / 4
      local x = cx + sin(a) * 22
      local z = cos(a)
      local up = sin(t * 2 + k) * 2
      local l = 5 + z * 4
      D.line(x, cy - 6, x, cy + 8 + up, 4 + z * 2)
      D.poly({ x - 4, cy + 10 + up, x + 3, cy + 9 + up, x + 4, cy + 6 + up, x + 6, cy + 6 + up, x + 5, cy + 10 + up, x + 3, cy + 13 + up, x - 4, cy + 13 + up }, l)
    end
    -- la bancarella dello zucchero filato
    D.rect(4, 38, 22, 16, 4); D.poly({ 2, 38, 28, 38, 24, 32, 6, 32 }, 7)
    for x = 6, 24, 4 do D.line(x, 32, x - 1, 38, 10) end
    D.circle(15, 44, 3, 12); D.circle(13, 42, 2, 13)
    D.rect(0, 54, 128, 10, 2)
    for _, p in ipairs(s.people) do p:draw() end
    s.kid:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA SALA GIOCHI
-------------------------------------------------------------------------------
S.sala_giochi = {
  init = function(s)
    s.a = D.figura(38, 58, { s = K.S, l = 9, pose = "window", face = 1 })
    s.b = D.figura(72, 58, { s = K.S, l = 7, pose = "window", face = 1 })
    s.balls = { x = 0, y = 0, vx = 9, vy = 6 }
    s.inv = 0
  end,
  update = function(s, dt, t)
    think(s.a, function() return { { "pose", "window", R(6, 12) }, { "pose", pick({ "stand", "arms_open", "look_up" }), R(1, 2) } } end)
    think(s.b, function() return { { "pose", "window", R(8, 14) }, { "face", -1 }, { "pose", "talk", 0.1 }, { "pose", "stand", 2 }, { "face", 1 } } end)
    s.a:update(dt); s.b:update(dt)
    local b = s.balls
    b.x = b.x + b.vx * dt; b.y = b.y + b.vy * dt
    if b.x < 0 or b.x > 11 then b.vx = -b.vx; b.x = D.clamp(b.x, 0, 11) end
    if b.y < 0 or b.y > 8 then b.vy = -b.vy; b.y = D.clamp(b.y, 0, 8) end
    s.inv = s.inv + dt
  end,
  draw = function(s, t)
    K.room({ wall = 1, fy = 58, floor = "moquette", floor_l = 2, paper = "puntini", ceil = 3 }, t)
    -- neon sul soffitto
    D.rect(20, 4, 30, 1, 9); D.rect(78, 4, 30, 1, 9)
    -- tre cabinati
    for i, x in ipairs({ 44, 78, 108 }) do
      D.rect(x, 22, 16, 36, 3)
      D.poly({ x, 22, x + 16, 22, x + 15, 18, x + 1, 18 }, 4)
      D.rect(x + 1, 18, 14, 3, 10 - i)
      D.rect(x + 2, 26, 12, 10, 0)
      D.rect(x - 1, 38, 18, 3, 5)
      D.px(x + 4, 37, 12); D.px(x + 10, 37, 9)
      local sx, sy = x + 2, 26
      if i == 1 then
        D.px(sx + s.balls.x, sy + s.balls.y + 1, 14)
        D.rect(sx, sy + 3 + sin(t * 2) * 2, 1, 3, 11); D.rect(sx + 11, sy + 3 + sin(t * 2 + 1) * 2, 1, 3, 11)
      elseif i == 2 then
        for k = 0, 3 do D.rect(sx + 1 + k * 3 + (floor(s.inv * 2) % 2), sy + 2, 2, 1, 12) end
        D.rect(sx + 5 + sin(t) * 4, sy + 8, 2, 1, 14)
      else
        for k = 0, 9 do D.px(sx + 6 + sin(t * 2 + k) * 5, sy + 1 + k * 0.9, 6 + (k % 3) * 3) end
      end
    end
    s.a.x = 40; s.b.x = 74
    s.a:draw(); s.b:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL PRIMO RICORDO
-------------------------------------------------------------------------------
S.primo = {
  init = function(s)
    s.lean = 0
    s.blobs = {}
    for i = 1, 8 do s.blobs[i] = { x = R(0, 128), y = R(0, 64), r = R(6, 16), ph = R(0, 6) } end
  end,
  update = function(s, dt, t)
    s.lean = 0.5 + 0.5 * sin(t * 0.12)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 3 + lu)
    -- luci sfocate
    for _, b in ipairs(s.blobs) do
      local r = b.r * (0.9 + 0.1 * sin(t * 0.5 + b.ph))
      D.circle(b.x, b.y, r, 4 + lu); D.circle(b.x, b.y, r * 0.6, 5 + lu)
    end
    -- la giostrina sopra la culla, vista da sotto
    local cx, cy = 64, 16
    D.line(cx, 0, cx, cy, 6)
    for k = 0, 4 do
      local a = t * 0.4 + k * pi * 2 / 5
      local x, y = cx + cos(a) * 18, cy + sin(a) * 5
      D.line(cx, cy, x, y, 5)
      D.line(x, y, x, y + 6, 6)
      local l = 8 + sin(a) * 3
      if k % 2 == 0 then D.circle(x, y + 8, 2.4, l) else D.poly({ x, y + 5, x + 3, y + 10, x - 3, y + 10 }, l) end
    end
    -- qualcuno si china sulla culla: una sagoma grande e morbida, controluce
    local fx = 108 - s.lean * 12
    D.circle(fx, 34, 13, 2 + lu)
    D.poly({ fx - 18, 64, fx - 12, 46, fx + 10, 44, fx + 24, 64 }, 2 + lu)
    D.circle(fx - 9, 30, 5, 2 + lu)
    -- le sbarre della culla, sfocate
    for x = 0, 127, 14 do D.rect(x, 54, 3, 10, 7) end
  end,
}

end
