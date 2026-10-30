-- ANAMNESI · scene del cielo e delle alture
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, copy, think, mac = H.R, H.pick, H.pan, H.copy, H.think, H.mac

-------------------------------------------------------------------------------
-- IL MARE DI STELLE
-------------------------------------------------------------------------------
S.mare_stelle = {
  init = function(s)
    s.stars = D.stars_gen(180, 11, 0, 64)
    s.fig = D.figura(64, 42, { s = 1.0, l = 11, pose = "float" })
    s.ft = copy(D.POSE.float)
    s.fig.tgt = s.ft
    s.comets = D.parts(4)
    s.neb = { { 30, 20, 18 }, { 96, 40, 22 }, { 70, 12, 12 } }
  end,
  update = function(s, dt, t)
    s.ft.rot = 18 * sin(t * 0.13); s.ft.lean = -4 + 8 * sin(t * 0.21)
    s.ft.ua1 = 60 + 25 * sin(t * 0.3); s.ft.ua2 = -50 - 25 * sin(t * 0.27); s.ft.th1 = 18 + 10 * sin(t * 0.25)
    s.fig.tgt = s.ft
    if s.fig.idle then s.fig:act({ { "glide", R(44, 84), R(34, 48), R(10, 18) }, { "wait", R(2, 6) } }) end
    s.fig:update(dt)
    if random() < dt * (0.05 + mac("stelle") * 0.2) then
      D.spawn(s.comets, { x = R(0, 128), y = R(0, 20), vx = R(30, 50) * pick({ -1, 1 }), vy = R(8, 16), life = 1.2 })
    end
    D.parts_update(s.comets, dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 1 + mac("stelle") * 0.4, t * 0.6, sin(t * 0.05) * 2)
    for _, c in ipairs(s.comets.list) do
      local f = 1 - c.age / c.life
      D.line(c.x, c.y, c.x - c.vx * 0.12, c.y - c.vy * 0.12, 6 * f)
      D.px(c.x, c.y, 15 * f)
    end
    s.fig:draw()
  end,
  note = function(s, ev) if ev.str == "bell" or ev.str == "celesta" then for i = 1, 3 do D.flare_star(s.stars) end end end,
}

-------------------------------------------------------------------------------
-- LA ROSA DI LUCE
-------------------------------------------------------------------------------
S.empireo = {
  init = function(s)
    s.rings = {}
    for i = 1, 6 do
      local r = 4 + i * 5.6
      local n = 6 + i * 5
      local souls = {}
      for k = 1, n do souls[k] = { a = k / n * pi * 2 + R(-0.1, 0.1), b = R(0.3, 1) } end
      s.rings[i] = { r = r, souls = souls, sp = (i % 2 == 0 and 1 or -1) * (0.05 + 0.03 / i), glow = 0 }
    end
    s.fig = D.figura(64, 62, { s = 0.7, l = 9, pose = "look_up" })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "look_up", "reach_up", "arms_open", "pray", "stand" }), R(8, 16) } } end)
    s.fig:update(dt)
    for _, r in ipairs(s.rings) do r.glow = max(0, r.glow - dt * 0.5) end
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local cx, cy = 64, 25
    for k = 0, 11 do
      local a = k / 12 * pi * 2 + t * 0.02
      D.line(cx + cos(a) * 6, cy + sin(a) * 6, cx + cos(a) * 70, cy + sin(a) * 70, 1)
    end
    for i = #s.rings, 1, -1 do
      local r = s.rings[i]
      D.circle(cx, cy, r.r, (2 + (6 - i) * 0.6 + r.glow * 5) * 0.5, true)
      for _, so in ipairs(r.souls) do
        local a = so.a + t * r.sp
        local x, y = cx + cos(a) * r.r, cy + sin(a) * r.r * 0.92
        D.px(x, y, 4 + so.b * 7 * (0.5 + 0.5 * sin(t * 1.5 + so.a * 5)) + r.glow * 4)
        if so.b > 0.7 then D.line(x, y, cx + cos(a + 0.12) * (r.r - 3), cy + sin(a + 0.12) * (r.r - 3) * 0.92, 2 + r.glow * 3) end
      end
    end
    D.circle(cx, cy, 7 + sin(t * 0.7), 2); D.circle(cx, cy, 4.5, 6); D.circle(cx, cy, 2.6, 12); D.circle(cx, cy, 1.2, 15)
    D.rect(0, 62, 128, 2, 1)
    s.fig:draw()
  end,
  note = function(s, ev)
    s.rings[random(#s.rings)].glow = 1
    if ev.str == "choir" then for _, r in ipairs(s.rings) do r.glow = max(r.glow, 0.4) end end
  end,
}

-------------------------------------------------------------------------------
-- SOPRA OGNI COSA (nascosto)
-------------------------------------------------------------------------------
S.trono = {
  init = function(s)
    s.fig = D.figura(64, 30, { s = 0.85, l = 2, dark = true, pose = "sit_ground" })
    s.lights = {}
    for i = 1, 40 do s.lights[i] = { a = R(-1.1, 1.1), b = R(0, 1), ph = R(0, 6) } end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "sit_ground", "sit_think", "stand", "arms_open" }), R(14, 26) } } end)
    s.fig.y = (s.fig.cur.hy < 4) and 30 or 30
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.gradient(0, 30, 10, 13)
    D.rect(0, 30, 128, 2, 15)
    -- la terra, laggiù, curva
    D.gradient(32, 64, 4, 1)
    for i, L in ipairs(s.lights) do
      local x = 64 + sin(L.a) * 90
      local y = 44 + (1 - cos(L.a)) * 30 + L.b * 18
      if y < 64 then D.px(x, y, 5 + 4 * (0.5 + 0.5 * sin(t + L.ph))) end
    end
    screen.level(D.lv(7)); screen.move(-10, 46); screen.curve(30, 34, 98, 34, 138, 46); screen.stroke()
    -- la scala di luce
    for k = 0, 6 do D.rect(64 - 16 + k * 2, 31 + k * 2, 32 - k * 4, 1, 14 - k) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA PACE
-------------------------------------------------------------------------------
S.pace = {
  init = function(s)
    s.hills = D.ridge_gen(31, 40, 7, 0.6)
    s.grass = D.grass_gen(32, 40, 0, 128, 1, 4)
    s.fig = D.figura(46, 41, { s = 0.9, l = 1, dark = true, pose = "sit_ground" })
    s.ripples = {}
    s.motes = D.parts(10)
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.55 then return { { "pose", "sit_ground", R(20, 40) }, { "pose", "sit_think", R(8, 16) } } end
      if r < 0.8 then return { { "pose", "stand", 3 }, { "pose", "arms_open", R(5, 9) }, { "pose", "look_up", 6 }, { "pose", "sit_ground", 20 } } end
      return { { "walk", R(30, 70), 4 }, { "pose", "stand", 5 }, { "walk", 46, 4 }, { "face", 1 }, { "pose", "sit_ground", 25 } }
    end)
    s.fig:update(dt)
    for i = #s.ripples, 1, -1 do
      local r = s.ripples[i]; r.r = r.r + dt * 4
      if r.r > 22 then table.remove(s.ripples, i) end
    end
    D.motes_update(s.motes, dt, 0.25, { 0, 20, 128, 20 }, t)
  end,
  draw = function(s, t)
    D.gradient(0, 39, 2, 6)
    D.circle(92, 33, 12, 6); D.circle(92, 33, 8, 8); D.circle(92, 33, 5.5, 11)
    D.ridge(s.hills, 4, 40)
    D.rect(0, 39, 128, 3, 2)
    D.gradient(42, 63, 3, 1)
    D.reflection(92, 43, 62, 10, t, 7)
    D.waves(43, 64, t * 0.5, 3, 2, 9)
    for _, r in ipairs(s.ripples) do D.ripple(r.x, r.y, r.r, 3 + 5 * (1 - r.r / 22)) end
    D.tree(30, 41, 26, 1, 5, sin(t * 0.6) * (0.8 + mac("vento") * 2))
    D.grass(s.grass, 41, t, 2, 0.6 + mac("vento") * 1.5)
    s.fig:draw()
    D.motes_draw(s.motes, 10)
  end,
  note = function(s, ev)
    if ev.str == "coppa" or ev.str == "piano" then s.ripples[#s.ripples + 1] = { x = R(20, 120), y = R(46, 60), r = 0.5 } end
  end,
}

-------------------------------------------------------------------------------
-- SOPRA LE NUVOLE
-------------------------------------------------------------------------------
S.nuvole = {
  init = function(s)
    s.fig = D.figura(52, 44, { s = 0.95, l = 3, dark = true })
    s.off = 0
    s.mode, s.timer = "walk", R(15, 30)
  end,
  update = function(s, dt, t)
    local f = s.fig
    s.timer = s.timer - dt
    if s.mode == "walk" then
      local old = f.ph
      f.ph = f.ph + dt * 3.5
      f.q = {}; f:update(dt); f.walking = true
      if floor(old / pi) ~= floor(f.ph / pi) then S.env.step("nuvola", -0.1, 0.4) end
      s.off = s.off + dt * 4
      if s.timer < 0 then s.mode = "rest"; s.timer = R(10, 18); f.walking = false
        f:act({ { "pose", pick({ "arms_open", "look_up", "sit_ground" }), R(8, 14) }, { "pose", "stand", 30 } }) end
    else
      f:update(dt)
      if s.timer < 0 then s.mode = "walk"; s.timer = R(20, 40); f:clear() end
    end
    f.y = 44 + sin(t * 0.4) * 0.5
  end,
  draw = function(s, t)
    D.gradient(0, 40, 6, 12)
    D.circle(100, 16, 14, 11); D.circle(100, 16, 9, 13); D.circle(100, 16, 6, 15)
    -- tre strati di nuvole che scorrono
    for layer = 1, 3 do
      local y0 = 30 + layer * 7
      local sp = s.off * (0.3 + layer * 0.4) + t * 0.5 * layer
      for i = 0, 10 do
        local x = (i * 19 - sp) % 160 - 16
        D.circle(x, y0 + sin(i * 2.3 + layer) * 2, 6 + (i * 3 + layer) % 5, 8 + layer)
      end
      D.rect(0, y0 + 3, 128, 64 - y0, 8 + layer)
    end
    for i = 0, 6 do
      local x = (i * 23 - s.off * 1.6) % 150 - 10
      D.px(x, 46 + (i % 3), 15)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'AURORA BOREALE
-------------------------------------------------------------------------------
S.aurora = {
  init = function(s)
    s.stars = D.stars_gen(90, 41, 0, 40)
    s.ground = D.ridge_gen(43, 50, 3, 0.4)
    s.fig = D.figura(70, 54, { s = 0.85, l = 1, dark = true, pose = "lie" })
    s.glow = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.6 then return { { "pose", "lie", R(20, 40) } } end
      return { { "pose", "sit_ground", 6 }, { "pose", "stand", 3 }, { "pose", "look_up", R(10, 16) }, { "pose", "sit_ground", 5 }, { "pose", "lie", 10 } }
    end)
    s.fig:update(dt)
    s.glow = max(0, s.glow - dt * 0.4)
  end,
  draw = function(s, t)
    D.gradient(0, 50, 0, 2)
    D.stars(s.stars, t, 0.8 + mac("stelle") * 0.4)
    -- le tende di luce
    for x = 0, 127, 2 do
      local w1 = sin(x * 0.05 + t * 0.3) + sin(x * 0.11 - t * 0.17) * 0.6
      local top = 6 + w1 * 4
      local h = 14 + sin(x * 0.07 + t * 0.21) * 6
      local int = 0.5 + 0.5 * sin(x * 0.09 + t * 0.4)
      local l = (3 + int * 6 + s.glow * 3) * (0.7 + mac("stelle") * 0.4)
      D.line(x, top, x, top + h, l * 0.6)
      D.line(x, top + h * 0.3, x, top + h * 0.7, l)
    end
    D.ridge(s.ground, 11, 64)
    for i, x in ipairs({ 8, 18, 104, 116, 124 }) do D.pine(x, s.ground[x], 14 + (i % 2) * 6, 1, 0) end
    s.fig:draw()
  end,
  note = function(s, ev) if ev.ruolo == "accordo" then s.glow = 1 end end,
}

-------------------------------------------------------------------------------
-- LA NINNA NANNA
-------------------------------------------------------------------------------
S.ninna = {
  init = function(s)
    s.stars = D.stars_gen(60, 51, 0, 64)
    s.kid = D.figura(0, 0, { s = 0.55, l = 6, child = true, coat = false, pose = "curl" })
    s.mob = {}
    for i = 1, 5 do s.mob[i] = { x = 30 + i * 14, len = 8 + (i % 3) * 6, ph = R(0, 6) } end
  end,
  update = function(s, dt, t)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    D.gradient(0, 64, 0, 3)
    D.stars(s.stars, t, 0.8)
    -- la luna che dondola
    local a = sin(t * 0.5) * 0.18
    local cx, cy = 64 + sin(a) * 4, 34
    D.circle(cx, cy, 18, 2)
    D.circle(cx, cy, 15, 12)
    D.circle(cx + cos(a + 1.2) * 0, cy - 7, 15, 2)
    s.kid.x = cx + 2; s.kid.y = cy + 12; s.kid:draw()
    -- stelle appese ai fili
    for i, m in ipairs(s.mob) do
      local sw = sin(t * 0.8 + m.ph) * 2
      D.line(m.x, 0, m.x + sw, m.len, 3)
      local x, y = m.x + sw, m.len + 2
      D.px(x, y - 2, 12); D.px(x - 2, y, 12); D.px(x + 2, y, 12); D.px(x, y + 2, 12); D.px(x, y, 15)
    end
    D.cloud((t * 1.5) % 180 - 30, 56, 30, 3, 5)
  end,
}

-------------------------------------------------------------------------------
-- IL SENTIERO DI MONTAGNA
-------------------------------------------------------------------------------
S.sentiero = {
  init = function(s)
    s.far = D.ridge_gen(41, 32, 20, 1.2)
    s.mid = D.ridge_gen(42, 44, 14, 1)
    s.off = 0
    s.fig = D.figura(52, 50, { s = 0.95, l = 1, dark = true })
    s.mode, s.timer = "walk", R(20, 40)
    s.pines = {}
    for i = 1, 9 do s.pines[i] = { x = i * 18 + R(-5, 5), h = R(10, 20) } end
    s.birds = {}
    for i = 1, 3 do s.birds[i] = { x = R(0, 128), y = R(6, 16), ph = R(0, 6) } end
    s.clouds = { { 10, 8, 30 }, { 70, 14, 22 } }
  end,
  update = function(s, dt, t)
    s.timer = s.timer - dt
    local f = s.fig
    if s.mode == "walk" then
      local old = f.ph
      f.ph = f.ph + dt * 4.2 * (1 + (mac("tempo")) * 0.4)
      if floor(old / pi) ~= floor(f.ph / pi) then S.env.step("ghiaia", -0.1, 0.35) end
      s.off = s.off + dt * 5
      f.q = {}; f:update(dt); f.walking = true
      if s.timer < 0 then
        s.mode = "rest"; s.timer = R(10, 18); f.walking = false
        f:act({ { "pose", "stand", 2 }, { "pose", pick({ "look_up", "arms_open", "head_down" }), R(4, 8) }, { "pose", "stand", 30 } })
      end
    else
      f:update(dt)
      if s.timer < 0 then s.mode = "walk"; s.timer = R(25, 50); f:clear() end
    end
    f.flap = mac("vento") * 1.2
    f.y = 52 - (f.x * 0.1)
    for _, b in ipairs(s.birds) do b.x = (b.x + dt * 6) % 140 end
  end,
  draw = function(s, t)
    D.gradient(0, 40, 5, 9)
    K.clouds({ { s.clouds[1][1], 8, 30, 1.2 + mac("vento") * 3 }, { s.clouds[2][1], 14, 22, 1.2 + mac("vento") * 3 } }, t, 11)
    D.ridge(s.far, 6, 64, s.off * 0.15)
    for x = 0, 127, 2 do
      local y = s.far[floor(x + s.off * 0.15) % 129]
      if y < 18 then D.px(x, y, 12) end
    end
    D.ridge(s.mid, 4, 64, s.off * 0.4)
    for _, b in ipairs(s.birds) do
      local w = sin(t * 6 + b.ph) * 1.5
      D.line(b.x - 2, b.y - w, b.x, b.y, 3); D.line(b.x, b.y, b.x + 2, b.y - w, 3)
    end
    screen.level(D.lv(2))
    screen.move(0, 52); screen.line(128, 52 - 12.8); screen.line(128, 64); screen.line(0, 64); screen.close(); screen.fill()
    for x = 0, 127, 3 do if ((x + floor(s.off)) % 7) < 4 then D.px(x, 54 - x * 0.1, 5) end end
    for i = 0, 12 do local x = (i * 13 - s.off) % 140 - 6; D.rect(x, 58 - x * 0.1, 2, 1, 4) end
    for _, p in ipairs(s.pines) do
      local x = (p.x - s.off) % 170 - 20
      D.pine(x, 50 - x * 0.1, p.h, 1, sin(t * 0.8 + p.x) * (0.8 + mac("vento") * 2))
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA VETTA
-------------------------------------------------------------------------------
S.vetta = {
  init = function(s)
    s.fig = D.figura(56, 41, { s = 0.9, l = 1, dark = true })
    s.streaks = D.parts(8)
    s.peaks = { { 14, 40, 6 }, { 104, 41, 9 }, { 120, 40, 5 } }
    s.eagle = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "pose", "stand", R(8, 14) }, { "pose", "look_up", R(5, 9) } } end
      if r < 0.65 then return { { "pose", "arms_open", R(6, 10) }, { "pose", "stand", 4 } } end
      if r < 0.85 then return { { "pose", "sit_ground", R(18, 30) }, { "pose", "stand", 3 } } end
      return { { "pose", "kneel_one", R(6, 10) }, { "pose", "stand", 4 } }
    end)
    local w = 0.4 + mac("vento")
    s.fig.flap = w * (0.6 + 0.6 * D.noise(t * 0.5))
    s.fig:update(dt)
    if random() < dt * 2 * w then
      D.spawn(s.streaks, { x = -5, y = R(4, 38), vx = R(50, 90), vy = 0, life = 3, len = R(3, 7) })
    end
    D.parts_update(s.streaks, dt)
    s.eagle = s.eagle + dt * 0.25
  end,
  draw = function(s, t)
    D.gradient(0, 42, 1, 7)
    for _, p in ipairs(s.peaks) do
      D.poly({ p[1] - p[3] * 1.4, p[2] + 2, p[1], p[2] - p[3], p[1] + p[3] * 1.4, p[2] + 2 }, 3)
      D.px(p[1], p[2] - p[3], 9)
    end
    D.rect(0, 42, 128, 22, 9)
    for i = 0, 22 do D.circle((i * 9 + t * 1.5) % 150 - 10, 42 + (i % 3) * 2 + sin(t * 0.3 + i), 4 + (i % 4), 11) end
    for i = 0, 10 do D.circle((i * 17 - t * 0.8) % 150 - 10, 54 + (i % 2) * 4, 6, 8) end
    D.poly({ 30, 64, 46, 48, 58, 42, 66, 37, 76, 44, 96, 64 }, 2)
    D.line(46, 48, 58, 42, 4); D.line(58, 42, 66, 37, 5); D.line(66, 37, 76, 44, 4)
    D.line(60, 50, 64, 56, 1); D.line(70, 47, 74, 55, 1)
    D.rect(67, 23, 1, 15, 1); D.rect(64, 27, 7, 1, 1); D.px(67, 22, 3)
    local ex, ey = 64 + cos(s.eagle) * 40, 14 + sin(s.eagle) * 6
    local w = sin(t * 2)
    D.line(ex - 3, ey - w, ex, ey, 2); D.line(ex, ey, ex + 3, ey - w, 2)
    for _, k in ipairs(s.streaks.list) do D.line(k.x, k.y, k.x - k.len, k.y, 6 * (1 - k.age / k.life)) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA BAITA (omaggio a ERMO)
-------------------------------------------------------------------------------
local OGGETTI = { "tazza", "libro", "sasso", "candela", "chiave", "lettera", "pigna", "orologio" }
local function oggetto(o, x, y, t)
  if o == "tazza" then D.rect(x, y - 3, 3, 3, 9); D.px(x + 3, y - 2, 7)
  elseif o == "libro" then D.rect(x, y - 2, 5, 2, 6); D.line(x, y - 2, x + 4, y - 2, 10)
  elseif o == "sasso" then D.circle(x + 1.5, y - 1.2, 1.6, 7)
  elseif o == "candela" then D.candle(x + 1, y, t, 9, 3)
  elseif o == "chiave" then D.line(x, y - 1, x + 4, y - 1, 9); D.px(x + 4, y - 2, 9)
  elseif o == "lettera" then D.rect(x, y - 1, 5, 1, 12)
  elseif o == "pigna" then D.circle(x + 1, y - 2, 1.4, 5); D.px(x + 1, y - 4, 4)
  else D.circle(x + 1.5, y - 2, 1.8, 8, true); D.px(x + 1, y - 2, 12) end
end
S.oggetto = oggetto

S.baita = {
  init = function(s)
    s.fig = D.figura(44, 58, { s = K.S, l = 11, pose = "sit", speed = 7, on_step = H.steps("legno", 0.4) })
    s.objs = { { o = "tazza", x = 52 } }
    s.flare = 0
    s.cat = 0
    s.win = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.45 then
        return { { "pose", "sit", R(4, 8) }, { "pose", "carry", 1.2 }, { "fn", function()
          table.insert(s.objs, { o = pick(OGGETTI), x = R(38, 60) })
          if #s.objs > 6 then table.remove(s.objs, 1) end
          S.env.play("musicbox", S.env.chord_midi(1), 0.12, 3, 0, 0.2, 0.001)
        end }, { "pose", "sit", R(6, 12) } }
      elseif r < 0.6 then
        return { { "pose", "stand", 1 }, { "walk", 34 }, { "face", -1 }, { "pose", "window", R(10, 18) }, { "walk", 44 }, { "face", 1 }, { "pose", "sit", 8 } }
      elseif r < 0.75 then
        return { { "pose", "stand", 1 }, { "walk", 80 }, { "face", 1 }, { "pose", "bend", 2 }, { "fn", function() s.flare = 1 end }, { "pose", "stand", 3 }, { "walk", 44 }, { "face", 1 }, { "pose", "sit", 8 } }
      end
      return { { "pose", "sit_read", R(14, 24) } }
    end)
    s.fig:update(dt)
    s.flare = max(0, s.flare - dt * 0.25)
    s.cat = s.cat + dt
  end,
  draw = function(s, t)
    local fire = 0.6 + mac("fuoco") * 0.8 + s.flare * 0.5
    local fl = D.noise(t * 5)
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 3, paper = "assi", ceil = 4,
      lights = { { x = 100, y = 46, r = 26 * fire, l = 2 + fl } } }, t)
    K.window(8, 16, 22, 18, K.views.snow, t, s.win, 6)
    K.clock(60, 13, t, 4, true)
    K.fireplace(86, 58, t, 4, fire)
    for x = 64, 127, 4 do D.rect(x, 58, 4, 6, 3 + (2 + fl * 2) * fire * (1 - abs(x - 107) / 45) ^ 2) end
    -- legna
    for i = 0, 2 do D.circle(122, 56 - i * 3, 1.6, 6) end
    -- il gatto
    local cx = 78
    D.circle(cx, 56, 2.8, 1); D.circle(cx + 3, 55, 1.7, 1); D.px(cx + 2, 53, 1); D.px(cx + 4, 53, 1)
    D.line(cx - 2, 57, cx - 5, 57 - sin(s.cat * 0.7) * (D.noise(s.cat * 0.2) > 0.6 and 2 or 0.3), 1)
    local ty = K.table(30, 58, 1.6, 6)
    D.glow(56, ty - 8, 12, 6)
    D.rect(55, ty - 6, 3, 6, 7); D.px(56, ty - 7, 15); D.px(56, ty - 8, 12)
    for _, o in ipairs(s.objs) do oggetto(o.o, o.x, ty, t) end
    K.chair(40, 58, 1, 5)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA PRIMA NEVE (nascosto)
-------------------------------------------------------------------------------
S.neve = {
  init = function(s)
    s.snow = D.parts(70)
    s.smoke = D.parts(12)
    s.ground = D.ridge_gen(71, 50, 5, 0.4)
    s.prints = {}
    s.fig = D.figura(90, 53, { s = 0.9, l = 1, dark = true, speed = 4,
      on_step = function(f)
        s.prints[#s.prints + 1] = { x = f.x, y = f.y, a = 1 }
        if #s.prints > 40 then table.remove(s.prints, 1) end
        S.env.step("neve", pan(f.x), 0.45)
      end })
  end,
  update = function(s, dt, t)
    D.snow_update(s.snow, dt, 4, 64, -1, t)
    D.smoke_update(s.smoke, dt, 95, 26, 1.2, t, 1.5)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "walk", R(20, 70), 4, R(53, 58) }, { "pose", "reach_up", R(5, 8) }, { "pose", "stand", R(6, 12) } } end
      if r < 0.7 then return { { "pose", "look_up", R(8, 14) }, { "pose", "stand", 4 } } end
      return { { "walk", R(70, 100), 4, R(53, 57) }, { "pose", "head_down", 6 }, { "pose", "stand", 5 } }
    end)
    s.fig:update(dt)
    for _, p in ipairs(s.prints) do p.a = max(0, p.a - dt * 0.012) end
  end,
  draw = function(s, t)
    D.gradient(0, 46, 0, 3)
    D.ridge(s.ground, 10, 64)
    for x = 0, 127, 3 do D.px(x, s.ground[x] + 3 + (x * 7) % 5, 12) end
    D.rect(78, 34, 30, 16, 2)
    D.poly({ 75, 34, 111, 34, 93, 24 }, 3)
    D.line(75, 34, 93, 24, 13); D.line(93, 24, 111, 34, 13)
    D.rect(94, 22, 3, 6, 2)
    D.circle(87, 42, 7, 3)
    D.rect(84, 39, 7, 6, 9 + D.noise(t * 3) * 2)
    D.line(87, 39, 87, 44, 3); D.line(84, 41, 90, 41, 3)
    D.rect(98, 40, 5, 10, 1)
    D.smoke_draw(s.smoke, 5)
    for i, x in ipairs({ 12, 30, 52, 118 }) do
      local h = 18 + (i % 2) * 6
      D.pine(x, s.ground[x], h, 2, 0)
      for k = 1, 4 do D.px(x - 3 + k * 1.5, s.ground[x] - h * (0.25 + k * 0.15), 13) end
    end
    for _, p in ipairs(s.prints) do D.px(p.x, p.y + 1, 7 + (1 - p.a) * 3) end
    s.fig:draw()
    D.snow_draw(s.snow, 14)
  end,
}

-------------------------------------------------------------------------------
-- CAMMINARE NEL BOSCO
-------------------------------------------------------------------------------
S.bosco = {
  init = function(s)
    s.off = 0
    s.trees = {}
    local r = D.lcg(101)
    for i = 1, 22 do s.trees[i] = { x = r() * 200, z = r(), w = 1 + r() * 4, seed = i } end
    table.sort(s.trees, function(a, b) return a.z < b.z end)
    s.fig = D.figura(56, 56, { s = 1.05, l = 2, dark = true })
    s.mode, s.timer = "walk", R(18, 30)
    s.leaves = D.parts(12)
    s.birds = 0
  end,
  update = function(s, dt, t)
    local f = s.fig
    s.timer = s.timer - dt
    if s.mode == "walk" then
      local old = f.ph
      f.ph = f.ph + dt * 3.4
      if floor(old / pi) ~= floor(f.ph / pi) then S.env.step("foglie", -0.1, 0.35) end
      s.off = s.off + dt * 4
      f.q = {}; f:update(dt); f.walking = true
      if s.timer < 0 then
        s.mode = "rest"; s.timer = R(12, 20); f.walking = false
        f:act({ { "pose", pick({ "look_up", "window", "head_down", "arms_open" }), R(6, 10) }, { "pose", "stand", 30 } })
      end
    else
      f:update(dt)
      if s.timer < 0 then s.mode = "walk"; s.timer = R(20, 40); f:clear() end
    end
    if random() < dt * (0.8 + mac("foglie") * 2) then
      D.spawn(s.leaves, { x = R(0, 128), y = -2, vx = R(-3, 3), vy = R(5, 9), ph = R(0, 6), life = 12 })
    end
    D.parts_update(s.leaves, dt, function(p, d) p.x = p.x + sin(t * 2 + p.ph) * 6 * d end)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 64, 5 + lu * 2, 3)
    -- lame di sole
    for i = 0, 3 do
      local x0 = (i * 40 - s.off * 0.2) % 170 - 20
      for k = 0, 3 do D.line(x0 + k * 2, 0, x0 + 30 + k * 2, 60, 6 + lu * 2) end
    end
    for _, tr in ipairs(s.trees) do
      local x = (tr.x - s.off * (0.3 + tr.z * 1.2)) % 200 - 30
      local w = tr.w * (0.5 + tr.z)
      local l = 4 - tr.z * 3
      D.rect(x, 0, w, 64, l)
      if tr.z > 0.6 then D.line(x, 20 + tr.seed % 10, x - 6, 12 + tr.seed % 7, l) end
    end
    D.rect(0, 56, 128, 8, 2)
    for i = 0, 40 do D.px((i * 29 - s.off * 1.6) % 128, 57 + (i * 7) % 7, 4 + (i % 3)) end
    for x = 0, 127, 4 do if ((x + floor(s.off * 1.6)) % 9) < 5 then D.px(x, 57, 6) end end
    for _, l in ipairs(s.leaves.list) do D.px(l.x, l.y, 9) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL LAGO DI MONTAGNA
-------------------------------------------------------------------------------
S.lago = {
  init = function(s)
    s.peaks = D.ridge_gen(111, 30, 18, 1.1)
    s.near = D.ridge_gen(112, 36, 6, 0.5)
    s.fig = D.figura(28, 52, { s = 0.85, l = 2, dark = true, pose = "sit_ground" })
    s.rip = {}
    s.stone = nil
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "sit_ground", R(16, 30) } } end
      if r < 0.8 then return { { "pose", "stand", 2 }, { "pose", "carry", 1 }, { "fn", function()
        s.stone = { x = 32, y = 44, vx = 30, vy = -12, hops = 3 }
      end }, { "pose", "stand", 6 }, { "pose", "sit_ground", 10 } } end
      return { { "pose", "look_up", R(8, 12) } }
    end)
    s.fig:update(dt)
    local st = s.stone
    if st then
      st.vy = st.vy + 40 * dt; st.x = st.x + st.vx * dt; st.y = st.y + st.vy * dt
      if st.y > 46 + (st.x - 32) * 0.05 then
        s.rip[#s.rip + 1] = { x = st.x, y = st.y, r = 0.5 }
        S.env.sfx("drop", R(900, 1300), 0.04, 0.2, pan(st.x), 0.5)
        st.hops = st.hops - 1; st.vy = -10 * st.hops / 3; st.vx = st.vx * 0.8
        if st.hops <= 0 then s.stone = nil end
      end
    end
    for i = #s.rip, 1, -1 do s.rip[i].r = s.rip[i].r + dt * 4; if s.rip[i].r > 16 then table.remove(s.rip, i) end end
  end,
  draw = function(s, t)
    local fog = mac("nebbia")
    D.gradient(0, 40, 4, 9)
    D.ridge(s.peaks, 5, 40)
    for x = 0, 127, 2 do if s.peaks[x] < 18 then D.px(x, s.peaks[x] + 1, 12) end end
    D.ridge(s.near, 3, 40)
    -- il lago: lo specchio delle montagne
    D.rect(0, 40, 128, 24, 6)
    for x = 0, 127 do
      local wob = sin(t * 1.2 + x * 0.3) * 0.6
      local h1 = 40 - s.peaks[x]
      local h2 = 40 - s.near[x]
      if h1 > 0 then D.rect(x, 40, 1, min(24, h1 * 0.8 + wob), 4) end
      if h2 > 0 then D.rect(x, 40, 1, min(24, h2 * 0.8 + wob), 2) end
    end
    for k = 0, 5 do D.line(0, 44 + k * 3, 127, 44 + k * 3, 5 + (k % 2)) end
    for _, r in ipairs(s.rip) do D.ripple(r.x, r.y, r.r, 10 * (1 - r.r / 16)) end
    if s.stone then D.px(s.stone.x, s.stone.y, 1) end
    -- la riva
    D.poly({ 0, 46, 40, 50, 46, 64, 0, 64 }, 2)
    for i = 0, 6 do D.circle(6 + i * 5, 56 + (i % 3) * 2, 1.6, 3) end
    -- nebbia
    if fog > 0.05 then for k = 0, 2 do local x0 = (t * (2 + k)) % 50 - 50; for i = 0, 5 do D.rect(x0 + i * 30, 35 + k * 4, 20, 1, 7 + fog * 4) end end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL RIFUGIO
-------------------------------------------------------------------------------
S.rifugio = {
  init = function(s)
    s.win = { moon = true }
    s.people = {}
    for i, x in ipairs({ 30, 46, 74, 90 }) do
      s.people[i] = D.figura(x, 58, { s = K.S * 0.95, l = 10 - (i % 2), pose = "sit", face = x < 60 and 1 or -1, dress = i == 2, bun = i == 2 })
    end
    s.player = s.people[4]
    s.nod = 0
  end,
  update = function(s, dt, t)
    for i, p in ipairs(s.people) do
      if p ~= s.player then
        think(p, function() return { { "pose", pick({ "sit", "talk", "sit", "sit_read" }), R(5, 12) } } end)
      else
        p.tgt = D.POSE.carry
      end
      p:update(dt)
    end
    s.nod = max(0, s.nod - dt * 3)
  end,
  draw = function(s, t)
    local fl = D.noise(t * 4)
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "assi", ceil = 4 }, t)
    K.window(8, 14, 18, 16, K.views.snow, t, s.win, 6)
    K.window(104, 14, 18, 16, K.views.night, t, s.win, 6)
    -- trave e lanterna appesa
    D.rect(0, 8, 128, 3, 2)
    D.line(60, 11, 60, 18, 5); D.glow(60, 21, 16, 7 + fl); D.rect(58, 18, 5, 6, 10 + fl * 4)
    local ty = K.table(24, 58, 5.6, 6, 8)
    for i, x in ipairs({ 34, 50, 66, 82 }) do D.rect(x, ty - 3, 3, 3, 10); D.px(x + 3, ty - 2, 8) end
    D.rect(57, ty - 6, 2, 6, 6)
    for _, p in ipairs(s.people) do p:draw() end
    -- la fisarmonica
    local p = s.player
    local sq = 2 + sin(t * 3) * 1.5 + s.nod
    D.rect(p.hand[1] - 3 - sq, p.hand[2] - 3, 3, 5, 11)
    D.rect(p.hand[1] - sq, p.hand[2] - 3, sq, 5, 6)
    D.rect(p.hand[1], p.hand[2] - 3, 3, 5, 11)
  end,
  note = function(s, ev) if ev.str == "accordion" then s.nod = 1 end end,
}

-------------------------------------------------------------------------------
-- LE MURA DI AMELIA
-------------------------------------------------------------------------------
S.mura = {
  init = function(s)
    s.hills = D.ridge_gen(121, 30, 8, 0.7)
    s.blocks = {}
    local r = D.lcg(122)
    -- le mura poligonali: pietre a più lati, incastrate
    for row = 0, 3 do
      local x = -r() * 10
      while x < 130 do
        local w = 8 + r() * 10
        local y0 = 36 + row * 7
        s.blocks[#s.blocks + 1] = { x, y0 + r() * 2, x + w * 0.4, y0 - 1 + r() * 2, x + w, y0 + r() * 2,
          x + w - r() * 2, y0 + 7 + r(), x + w * 0.5, y0 + 8, x + r() * 2, y0 + 7 + r(), l = 4 + r() * 3 }
        x = x + w
      end
    end
    s.sw = {}
    for i = 1, 14 do s.sw[i] = { x = R(0, 128), y = R(4, 26), a = R(0, 6), v = R(18, 30) } end
    s.fig = D.figura(-6, 64, { s = 0.85, l = 1, dark = true, speed = 4, on_step = H.steps("pietra", 0.3) })
  end,
  update = function(s, dt, t)
    for _, w in ipairs(s.sw) do
      w.a = w.a + (D.noise(t * 0.7 + w.v) - 0.5) * 6 * dt
      w.x = (w.x + cos(w.a) * w.v * dt) % 140
      w.y = D.clamp(w.y + sin(w.a) * w.v * 0.5 * dt, 2, 30)
    end
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(10, 118), 4, 63 }, { "pose", "look_up", R(6, 10) }, { "pose", "stand", 4 } } end
      return { { "walk", 44, 4, 63 }, { "face", 1 }, { "pose", "window", R(6, 10) } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 34, 4 + lu * 2, 10 + lu * 2)
    D.circle(30, 28, 8, 12); D.circle(30, 28, 5, 14)
    D.ridge(s.hills, 4, 40)
    -- la città sopra le mura: tetti e la torre del duomo a dodici lati
    for i, h in ipairs({ { 6, 8 }, { 18, 6 }, { 44, 9 }, { 60, 7 }, { 80, 10 }, { 98, 7 }, { 112, 9 } }) do
      D.rect(h[1], 34 - h[2], 12, h[2], 3); D.poly({ h[1] - 1, 34 - h[2], h[1] + 13, 34 - h[2], h[1] + 6, 31 - h[2] }, 2)
    end
    D.rect(88, 10, 8, 24, 2); D.poly({ 87, 10, 97, 10, 92, 4 }, 2); D.rect(90, 13, 4, 3, 1)
    -- le mura
    D.rect(0, 34, 128, 30, 3)
    for _, b in ipairs(s.blocks) do
      D.poly({ b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9], b[10], b[11], b[12] }, b.l + lu)
      screen.level(D.lv(2)); screen.move(b[1], b[2])
      for k = 3, 11, 2 do screen.line(b[k], b[k + 1]) end
      screen.close(); screen.stroke()
    end
    -- la porta
    D.rect(56, 44, 16, 20, 1); D.circle(64, 44, 8, 1)
    D.rect(0, 62, 128, 2, 2)
    for _, w in ipairs(s.sw) do
      local wg = sin(t * 12 + w.v) * 1
      D.line(w.x - 2, w.y + wg, w.x, w.y, 2); D.line(w.x, w.y, w.x + 2, w.y + wg, 2)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IN CIMA AL CAMPANILE
-------------------------------------------------------------------------------
S.campanile = {
  init = function(s)
    s.bell = 0
    s.hills = D.ridge_gen(131, 34, 6, 0.5)
    s.fig = D.figura(96, 58, { s = K.S * 0.9, l = 2, dark = true, pose = "window" })
    s.birds = {}
    for i = 1, 5 do s.birds[i] = { x = R(0, 128), y = R(10, 30), v = R(6, 12) } end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "window", "stand", "look_up", "arms_open" }), R(8, 16) } } end)
    s.fig:update(dt)
    s.bell = max(0, s.bell - dt * 0.2)
    for _, b in ipairs(s.birds) do b.x = (b.x + b.v * dt) % 150 end
  end,
  draw = function(s, t)
    local far = mac("distanza")
    D.gradient(0, 64, 9, 6)
    -- i tetti del paese, giù
    for i = 0, 14 do
      local x = (i * 13) % 140 - 6
      local y = 40 + (i * 7) % 14
      D.poly({ x, y, x + 12, y, x + 10, y - 4, x + 2, y - 4 }, 4 + (i % 3))
      for k = 0, 2 do D.line(x + 2, y - 3 + k, x + 10, y - 3 + k, 3 + (i % 3)) end
      D.rect(x + 2, y, 9, 6, 6 + (i % 2))
    end
    D.ridge(s.hills, 5, 36)
    for _, b in ipairs(s.birds) do local w = sin(t * 6 + b.v); D.line(b.x - 2, b.y - w, b.x, b.y, 3); D.line(b.x, b.y, b.x + 2, b.y - w, 3) end
    -- l'arco della cella campanaria
    screen.level(D.lv(2))
    screen.move(0, 0); screen.line(0, 64); screen.line(14, 64); screen.line(14, 18)
    screen.arc(64, 18, 50, pi, 2 * pi)
    screen.line(114, 64); screen.line(128, 64); screen.line(128, 0); screen.close(); screen.fill()
    D.rect(14, 58, 100, 6, 3)
    D.rect(14, 46, 100, 2, 4)
    -- la campana grande, appesa alla trave
    D.rect(26, 4, 40, 3, 1)
    local a = sin(t * 2) * s.bell * 0.5
    local px, py = 46, 7
    local ca, sa = cos(a), sin(a)
    local function rot(x, y) return px + x * ca - y * sa, py + x * sa + y * ca end
    local shape = { -3, 1, 3, 1, 5, 6, 6, 14, 10, 19, -10, 19, -6, 14, -5, 6 }
    local pts = {}
    for i = 1, #shape, 2 do local x, y = rot(shape[i], shape[i + 1]); pts[#pts + 1] = x; pts[#pts + 1] = y end
    D.poly(pts, 4)
    local lx1, ly1 = rot(-10, 19); local lx2, ly2 = rot(10, 19)
    D.line(lx1, ly1, lx2, ly2, 6)
    local cx, cy = rot(0, 21)
    D.circle(cx, cy, 1.6, 3)
    s.fig:draw()
  end,
  note = function(s, ev) if ev.str == "campana" then s.bell = 1 end end,
}

end
