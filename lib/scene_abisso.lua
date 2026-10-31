-- ANAMNESI · scene della mente, dell'abisso, e dei luoghi nascosti
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, copy, think, mac, w = H.R, H.pick, H.pan, H.copy, H.think, H.mac, H.w
local KS = K.S

-------------------------------------------------------------------------------
-- LE VOCI NELLA TESTA
-------------------------------------------------------------------------------
local PAROLE_VOCI = {
  { "sempre", "mai", "colpa", "tu", "perché", "basta", "sbagli", "ancora", "nessuno", "tutti", "senti?", "di nuovo", "guarda", "dovevi" },
  { "always", "never", "fault", "you", "why", "enough", "wrong", "again", "nobody", "everyone", "hear?", "once more", "look", "you should" },
}
local HEAD = { 30, 52, 30, 40, 26, 34, 24, 26, 26, 16, 32, 8, 42, 4, 54, 6, 62, 14, 64, 22, 68, 28, 64, 30, 66, 34, 62, 36, 64, 40, 58, 44, 54, 44, 52, 52 }

S.voci = {
  init = function(s)
    s.orbit = {}
    for i = 1, 9 do s.orbit[i] = { w = w(PAROLE_VOCI), a = R(0, 6.28), r = R(20, 46), sp = R(-0.5, 0.5), z = R(0.3, 1) } end
    s.pops = D.parts(6)
    s.fig = D.figura(100, 60, { s = 1.0, l = 8, pose = "cry" })
  end,
  update = function(s, dt, t)
    local nv = 1 + mac("nevrosi") * 1.5
    for _, o in ipairs(s.orbit) do
      o.a = o.a + o.sp * dt * nv
      if random() < dt * 0.05 then o.w = w(PAROLE_VOCI) end
    end
    D.parts_update(s.pops, dt)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "pose", "cry", R(8, 14) } } end
      if r < 0.7 then return { { "pose", "curl", R(10, 18) } } end
      return { { "pose", "head_down", R(6, 10) } }
    end)
    s.fig.y = s.fig.cur.rot > 30 and 61 or 60
    s.fig.shake = 0.2 + 0.3 * D.noise(t * 0.5) + mac("nevrosi") * 0.4
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local j = {}
    local jit = 0.6 + mac("nevrosi") * 1.2
    for i = 1, #HEAD, 2 do j[#j + 1] = HEAD[i] + (D.noise(t * 2 + i) - 0.5) * jit * 1.5; j[#j + 1] = HEAD[i + 1] + (D.noise(t * 2 + i + 50) - 0.5) * jit * 1.5 end
    screen.level(D.lv(4)); screen.move(j[1], j[2])
    for i = 3, #j, 2 do screen.line(j[i], j[i + 1]) end
    screen.stroke()
    local cx, cy = 44, 22
    screen.level(D.lv(2)); screen.move(cx, cy)
    for k = 1, 22 do screen.line(cx + sin(t * 1.3 + k * 1.7) * 12, cy + cos(t * 1.1 + k * 2.3) * 10) end
    screen.stroke()
    screen.font_face(1); screen.font_size(8)
    for _, o in ipairs(s.orbit) do
      local x = cx + cos(o.a) * o.r * 1.4
      local y = cy + sin(o.a) * o.r * 0.6 + 4
      screen.level(D.lv(2 + o.z * 5)); screen.move(floor(x), floor(y)); screen.text(D.tr(o.w))
    end
    for _, p in ipairs(s.pops.list) do
      local f = 1 - p.age / p.life
      screen.level(D.lv(13 * f)); screen.move(floor(p.x), floor(p.y)); screen.text(D.tr(p.w))
    end
    s.fig:draw()
  end,
  note = function(s, ev)
    if ev.str == "whisper" then
      D.spawn(s.pops, { x = 64 + (ev.pan or 0) * 50 - 10, y = R(10, 50), vx = R(-3, 3), vy = R(-3, 3), life = 1.8, w = w(PAROLE_VOCI) })
    end
  end,
}

-------------------------------------------------------------------------------
-- LA PAURA DEL BUIO
-------------------------------------------------------------------------------
S.buio = {
  init = function(s)
    s.kid = D.figura(94, 52, { s = 0.85, l = 4, child = true, coat = false, pose = "lie", face = -1 })
    s.eyes = {}
    s.pulse = 0
  end,
  update = function(s, dt, t)
    if random() < dt * (0.2 + mac("profondita") * 0.3) then s.eyes[#s.eyes + 1] = { x = R(30, 70), y = R(10, 44), life = R(1.5, 4), age = 0 } end
    for i = #s.eyes, 1, -1 do local e = s.eyes[i]; e.age = e.age + dt; if e.age > e.life then table.remove(s.eyes, i) end end
    think(s.kid, function()
      local r = random()
      if r < 0.5 then return { { "pose", "lie", R(14, 24) } } end
      if r < 0.8 then return { { "pose", "curl", R(10, 18) } } end
      return { { "pose", "sit_ground", R(5, 8) }, { "pose", "lie", 6 } }
    end)
    s.kid:update(dt)
    s.pulse = max(0, s.pulse - dt * 2)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local door = 2 + D.noise(t * 0.2) * 1.5
    D.rect(6, 4, 16, 54, 1)
    D.rect(22, 4, door, 54, 9)
    D.poly({ 22, 58, 22 + door, 58, 60 + door * 6, 64, 40, 64 }, 3)
    local m = D.noise(t * 0.1)
    screen.level(D.lv(1)); screen.rect(40.5, 6.5, 22, 50); screen.stroke()
    D.line(51, 7, 51, 56, 1)
    if m > 0.6 then D.circle(51, 13, 3, 1, true) end
    K.bed(68, 58, 3.4, 1, 2)
    s.kid:draw()
    D.rect(76, 47, 36, 4, 1); D.line(76, 47, 112, 47, 2)
    for _, e in ipairs(s.eyes) do
      local f = min(1, e.age, e.life - e.age)
      local blink = (sin(e.age * 3) > 0.95) and 0 or 1
      D.px(e.x, e.y, 5 * f * blink); D.px(e.x + 3, e.y, 5 * f * blink)
    end
    if s.pulse > 0 then screen.level(D.lv(s.pulse * 2)); screen.rect(0.5, 0.5, 127, 63); screen.stroke() end
  end,
  note = function(s, ev) s.pulse = 1 end,
}

-------------------------------------------------------------------------------
-- L'INCUBO
-------------------------------------------------------------------------------
S.incubo = {
  init = function(s)
    s.fig = D.figura(30, 58, { s = KS, l = 9, pose = "lie", speed = 7, on_step = H.steps("legno", 0.4) })
    s.clouds = {}
    for i = 1, 5 do s.clouds[i] = { x = R(86, 118), y = R(10, 26), w = R(6, 12), v = R(8, 16) } end
    s.flash = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      return { { "pose", "lie", R(10, 20) }, { "pose", "sit", 0.6 }, { "fn", function() s.flash = 1 end }, { "pose", "sit", 2 },
        { "pose", "stand", 1 }, { "walk", 92 }, { "face", 1 }, { "pose", "bend", R(6, 12) }, { "walk", 36 }, { "face", 1 }, { "pose", "sit_slump", R(8, 14) } }
    end)
    local lying = s.fig.cur.rot > 45 or (s.fig.cur.hy < 6 and s.fig.x < 60)
    s.fig.y = lying and 51 or 58
    s.fig:update(dt)
    for _, c in ipairs(s.clouds) do c.x = c.x - c.v * dt * (1 + mac("nevrosi")); if c.x < 84 then c.x = 120 end end
    s.flash = max(0, s.flash - dt * 1.5)
  end,
  draw = function(s, t)
    local jit = (0.4 + mac("nevrosi") * 1.4 + s.flash * 2)
    local function j() return (random() - 0.5) * jit end
    K.room({ wall = 1, fy = 58, floor = "assi", floor_l = 2, ceil = 4 }, t)
    D.rect(86, 8, 34, 24, 2)
    D.moon(108, 17, 4, 12, 2)
    for _, c in ipairs(s.clouds) do if c.x > 86 and c.x < 119 then D.rect(c.x, c.y, min(c.w, 119 - c.x), 2, 4) end end
    K.window(86, 8, 34, 24, nil, t, nil, 4)
    -- l'angolo della stanza, fermo
    D.line(78, 4, 78, 57, 2)
    K.bed(4, 58, 3.2, 3, 5)
    s.fig:draw()
    local cy = K.crib(88, 58, 5)
    D.circle(98, cy - 2, 2, 8)
    if s.flash > 0 then D.flash(s.flash * 6); s.fig:draw() end
  end,
}

-------------------------------------------------------------------------------
-- LE TRE DI NOTTE
-------------------------------------------------------------------------------
S.tre_notte = {
  init = function(s)
    s.fig = D.figura(64, 52, { s = KS, l = 8, pose = "lie" })
    s.sweep = nil
    s.wait = R(4, 10)
    s.digits = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "lie", "lie", "curl", "sit_edge" }), R(14, 26) } } end)
    s.fig.y = s.fig.cur.rot > 45 and 51 or 58
    s.fig:update(dt)
    s.wait = s.wait - dt
    if not s.sweep and s.wait < 0 then s.sweep = 0 end
    if s.sweep then s.sweep = s.sweep + dt * 0.35; if s.sweep > 1 then s.sweep = nil; s.wait = R(8, 20) end end
    s.digits = s.digits + dt
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- il soffitto, e i fari delle macchine che lo attraversano
    D.rect(0, 0, 128, 8, 0)
    if s.sweep then
      local x = -40 + s.sweep * 210
      D.poly({ x, 0, x + 14, 0, x + 34, 8, x + 20, 8 }, 5)
      D.poly({ x - 30, 8, x - 10, 8, x + 4, 30, x - 16, 30 }, 3)
    end
    K.floor(58, "assi", 1, 64)
    K.bed(30, 58, 4.2, 2, 3)
    -- la sveglia: 3:17
    D.rect(98, 46, 14, 8, 2); D.rect(99, 47, 12, 5, 0)
    screen.font_face(1); screen.font_size(8)
    screen.level(D.lv(9 + (floor(s.digits) % 2))); screen.move(100, 52); screen.text("3:17")
    D.rect(96, 54, 18, 4, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL PAVIMENTO GELIDO
-------------------------------------------------------------------------------
S.pavimento = {
  init = function(s)
    s.fig = D.figura(62, 55, { s = 1.2, l = 7, pose = "lie_face", face = 1 })
    s.motes = D.parts(10)
    s.phone = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.25 then return { { "pose", "curl", R(12, 20) }, { "pose", "lie_face", R(20, 40) } } end
      return { { "pose", "lie_face", R(20, 40) } }
    end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 0.6, { 46, 10, 36, 30 }, t)
    if s.phone <= 0 and random() < dt * 0.01 then s.phone = 4 end
    s.phone = max(0, s.phone - dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 30, 1)
    D.rect(52, 6, 24, 20, 6 + lu * 2)
    K.window(52, 6, 24, 20, nil, t, nil, 3)
    D.rect(0, 30, 128, 34, 2)
    D.floor_persp(30, 64, 64, 3, 14)
    local o = (t * 0.15) % 40 - 10
    D.poly({ 48 + o, 38, 74 + o, 38, 84 + o * 1.4, 60, 50 + o * 1.4, 60 }, 4 + lu * 2)
    D.motes_draw(s.motes, 7)
    local pl = s.phone > 0 and (6 + 6 * sin(s.phone * 6)) or 4
    D.rect(88, 57, 5, 3, 3); D.rect(89, 57, 3, 2, pl)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA RABBIA
-------------------------------------------------------------------------------
S.rabbia = {
  init = function(s)
    s.rain = D.parts(80)
    s.hill = D.ridge_gen(181, 50, 8, 0.6)
    s.fig = D.figura(60, 52, { s = 1.05, l = 2, dark = true, pose = "kneel" })
    s.flash = 0
    s.bolt = nil
  end,
  update = function(s, dt, t)
    D.rain_update(s.rain, dt, 2.5 + mac("pioggia") * 3, 60, -14 - mac("vento") * 20)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "pose", "arms_open", R(3, 5) }, { "pose", "kneel", R(6, 10) } } end
      if r < 0.7 then return { { "pose", "cry", R(6, 10) } } end
      return { { "pose", "dig", R(4, 6) }, { "pose", "kneel", 6 } }
    end)
    s.fig.flap = 0.8 + mac("vento")
    s.fig:update(dt)
    if random() < dt * (0.06 + mac("nevrosi") * 0.2) then
      s.flash = 1
      local x = R(10, 118)
      s.bolt = { x }
      for k = 1, 6 do s.bolt[#s.bolt + 1] = x + R(-6, 6); x = s.bolt[#s.bolt] end
      S.env.sfx("sub", R(40, 55), 0.25, 4, R(-0.5, 0.5), 0.2, 0.2)
    end
    s.flash = max(0, s.flash - dt * 2)
  end,
  draw = function(s, t)
    D.gradient(0, 50, 1 + s.flash * 8, 3 + s.flash * 6)
    D.cloud((t * 4) % 180 - 30, 6, 50, 2 + s.flash * 6, 3)
    D.cloud((t * 6 + 70) % 180 - 30, 14, 40, 3 + s.flash * 5, 8)
    if s.bolt and s.flash > 0.5 then
      for k = 1, #s.bolt - 1 do D.line(s.bolt[k], (k - 1) * 8, s.bolt[k + 1], k * 8, 15) end
    end
    D.ridge(s.hill, 1 + s.flash * 3, 64)
    D.bare_tree(100, s.hill[100], 22, 2 + s.flash * 4, 7, sin(t * 3) * (2 + mac("vento") * 3))
    s.fig:draw()
    D.rain_draw(s.rain, 0.8)
  end,
}

-------------------------------------------------------------------------------
-- LO SPECCHIO
-------------------------------------------------------------------------------
S.specchio = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 10, pose = "stand", face = 1 })
    s.ghost = D.figura(88, 58, { s = KS, l = 6, pose = "stand", face = -1 })
    s.hist = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", pick({ "stand", "head_down", "window", "look_up", "cry", "reach_up" }), R(5, 10) } } end)
    s.fig:update(dt)
    -- il riflesso arriva in ritardo: e a volte non obbedisce
    table.insert(s.hist, 1, copy(s.fig.cur))
    local delay = floor(4 + mac("eco") * 30 + D.noise(t * 0.2) * 10)
    local h = s.hist[min(#s.hist, delay)]
    if #s.hist > 60 then table.remove(s.hist) end
    if h then s.ghost.cur = copy(h) end
    if random() < dt * mac("fragilita") * 0.5 then s.ghost.cur.nod = s.ghost.cur.nod + 30 end
    s.ghost.t = s.fig.t
  end,
  draw = function(s, t)
    K.room({ wall = 5, fy = 58, floor = "piastrelle", floor_l = 4, paper = "piastrelle", tile_y = 34, ceil = 4 }, t)
    -- la cornice dello specchio
    D.rect(62, 6, 54, 52, 8)
    D.rect(64, 8, 50, 50, 2)
    for k = 0, 6 do D.line(70 + k * 6, 8, 64 + k * 6, 20, 3) end
    s.ghost:draw()
    D.rect(60, 56, 58, 2, 9)
    D.rect(66, 24, 2, 3, 13); D.rect(104, 12, 4, 2, 10)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA FUGA
-------------------------------------------------------------------------------
S.fuga = {
  init = function(s)
    s.off = 0
    s.fig = D.figura(46, 58, { s = KS, l = 10 })
    s.pace = 1
  end,
  update = function(s, dt, t)
    local f = s.fig
    s.pace = 0.6 + 0.5 * D.noise(t * 0.2) + mac("tempo") * 0.5 + mac("nevrosi") * 0.5
    local old = f.ph
    f.ph = f.ph + dt * 6 * s.pace
    if floor(old / pi) ~= floor(f.ph / pi) then S.env.step("piastrelle", -0.2, 0.45) end
    f.q = {}; f:update(dt); f.walking = true
    f.cur.lean = 14
    s.off = s.off + dt * 26 * s.pace
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- un corridoio che non finisce: porte che passano
    for i = 0, 5 do
      local x = (i * 34 - s.off) % 204 - 30
      D.rect(x, 20, 14, 38, 1)
      D.rect(x - 1, 19, 16, 1, 4)
      D.px(x + 11, 40, 6)
      D.rect(x + 20, 10, 6, 4, 9)
    end
    for i = 0, 10 do D.rect((i * 16 - s.off * 1.0) % 176 - 16, 4, 8, 1, 10) end
    K.floor(58, "piastrelle", 3, 64 - s.off % 20)
    s.fig:draw()
    -- un'ombra che segue, sempre alla stessa distanza
    D.circle(8 + sin(t) * 3, 40, 10, 1); D.rect(0, 30, 10, 28, 1)
  end,
}

-------------------------------------------------------------------------------
-- LE OCCASIONI PERDUTE
-------------------------------------------------------------------------------
S.occasioni = {
  init = function(s)
    s.doors = {}
    for i = 1, 6 do s.doors[i] = { open = R(0.3, 1), target = 1, glow = R(0.5, 1) } end
    s.fig = D.figura(64, 62, { s = 0.9, l = 2, dark = true, pose = "stand" })
    s.next = R(4, 9)
  end,
  update = function(s, dt, t)
    s.next = s.next - dt
    if s.next < 0 then
      local d = s.doors[random(#s.doors)]
      if d.target > 0.5 then d.target = 0; S.env.sfx("step", 1.6, 0.25, 0.1, R(-0.6, 0.6), 0.4) else d.target = 1 end
      s.next = R(5, 12)
    end
    for _, d in ipairs(s.doors) do d.open = d.open + (d.target - d.open) * dt * 0.8 end
    think(s.fig, function() return { { "pose", pick({ "stand", "reach_up", "head_down", "window" }), R(6, 12) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local vx, vy = 64, 30
    D.rect(0, 0, 128, 64, 0)
    D.poly({ 0, 64, 128, 64, vx + 6, vy + 4, vx - 6, vy + 4 }, 2)
    D.poly({ 0, 0, 128, 0, vx + 6, vy - 4, vx - 6, vy - 4 }, 1)
    for i, d in ipairs(s.doors) do
      local k = (i + 1) / 2
      local f = 1 / (1 + floor(k) * 0.9)
      local side = (i % 2 == 1) and -1 or 1
      local x = vx + side * (8 + 50 * f)
      local h = 40 * f
      local ww = 10 * f
      local top = vy - h * 0.55
      D.rect(x - ww / 2, top, ww, h, 0)
      D.rect(x - ww / 2, top, ww * d.open, h, 6 * d.glow * d.open + 1)
      screen.level(D.lv(3)); screen.rect(x - ww / 2 - 0.5, top - 0.5, ww + 1, h + 1); screen.stroke()
    end
    D.rect(vx - 2, vy - 3, 4, 6, 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL GIUDIZIO
-------------------------------------------------------------------------------
S.giudizio = {
  init = function(s)
    s.judges = {}
    for i = 1, 7 do s.judges[i] = { x = 6 + i * 16, h = R(28, 40), ph = R(0, 6), arm = 0 } end
    s.fig = D.figura(64, 62, { s = 0.9, l = 9, pose = "head_down" })
  end,
  update = function(s, dt, t)
    for _, j in ipairs(s.judges) do
      if random() < dt * (0.15 + mac("voci") * 0.4) then j.arm = 1 end
      j.arm = max(0, j.arm - dt * 0.4)
    end
    think(s.fig, function() return { { "pose", pick({ "head_down", "cry", "curl", "kneel" }), R(8, 14) } } end)
    s.fig.y = s.fig.cur.rot > 45 and 63 or 62
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local dp = mac("profondita")
    D.rect(0, 0, 128, 64, 0)
    D.rect(0, 30, 128, 4, 1 + dp)
    for _, j in ipairs(s.judges) do
      local y = 34
      local sway = sin(t * 0.3 + j.ph) * 1
      D.poly({ j.x - 6, y, j.x + 6, y, j.x + 4 + sway, y - j.h + 8, j.x - 4 + sway, y - j.h + 8 }, 2)
      D.circle(j.x + sway, y - j.h + 5, 4, 2)
      D.px(j.x - 1 + sway, y - j.h + 5, 6); D.px(j.x + 1 + sway, y - j.h + 5, 6)
      if j.arm > 0 then
        local tx, ty = 64, 52
        D.line(j.x + sway, y - j.h + 14, j.x + (tx - j.x) * 0.25 * j.arm, y - j.h + 14 + (ty - y + j.h - 14) * 0.25 * j.arm, 3)
      end
    end
    D.circle(64, 60, 16, 1)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL FIUME DELL'OBLIO
-------------------------------------------------------------------------------
local PAROLE_LETE = {
  { "il nome", "estate", "la strada", "quel giorno", "la sua voce", "il numero", "la canzone", "perché", "il colore", "la casa", "come si chiamava" },
  { "the name", "summer", "the road", "that day", "her voice", "the number", "the song", "why", "the colour", "the house", "what was it called" },
}

S.lete = {
  init = function(s)
    s.bank = D.ridge_gen(81, 32, 5, 0.8)
    s.words = D.parts(5)
    s.fig = D.figura(36, 60, { s = 1.0, l = 6, pose = "kneel" })
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.5 then return { { "pose", "dig", R(4, 7) }, { "fn", function()
        D.spawn(s.words, { x = 44, y = 52, vx = -R(1, 3), vy = -0.4, life = 12, w = w(PAROLE_LETE), l = 9 })
      end }, { "pose", "kneel", R(8, 14) } } end
      return { { "pose", "kneel", R(10, 18) }, { "pose", "pray", R(6, 10) } }
    end)
    s.fig:update(dt)
    D.parts_update(s.words, dt, function(p, d) p.x = p.x - 2 * d; p.vy = p.vy + 0.15 * d end)
  end,
  draw = function(s, t)
    local fog = 0.3 + mac("nebbia")
    D.rect(0, 0, 128, 64, 0)
    D.ridge(s.bank, 1, 36)
    for i, x in ipairs({ 18, 70, 104 }) do D.bare_tree(x, s.bank[x], 16 + i * 3, 3, 30 + i, sin(t * 0.3 + i) * 0.5) end
    D.rect(0, 35, 128, 21, 0)
    D.waves(36, 56, t * 0.3, 3, 2, 8)
    for x = 0, 127, 5 do if D.noise(x * 0.7 + t * 0.6) > 0.7 then D.px(x, 38 + (x * 3) % 16, 6) end end
    for k = 0, 2 do
      local x0 = ((t * (2 + k)) % 60) - 60
      for i = 0, 6 do D.rect(x0 + i * 28, 31 + k * 5, 18, 1, 2 + fog * 2) end
    end
    D.rect(0, 56, 128, 8, 1)
    for i = 0, 10 do D.circle((i * 23) % 128, 58 + (i % 3), 1.5, 2) end
    s.fig:draw()
    D.float_words_draw(s.words)
  end,
  note = function(s, ev)
    if ev.str == "swell" then D.spawn(s.words, { x = R(60, 128), y = R(40, 52), vx = -R(1, 3), vy = 0.3, life = 10, w = w(PAROLE_LETE), l = 6 }) end
  end,
}

-------------------------------------------------------------------------------
-- IL MONDO SOMMERSO
-------------------------------------------------------------------------------
S.sommerso = {
  init = function(s)
    s.bub = D.parts(20)
    s.fig = D.figura(70, 36, { s = 1.0, l = 9, pose = "float" })
    s.ft = copy(D.POSE.float)
    s.bell = 0
    s.fish = {}
    for i = 1, 3 do s.fish[i] = { x = R(0, 128), y = R(14, 40), v = R(3, 7) * pick({ -1, 1 }) } end
    s.weeds = {}
    for i = 1, 10 do s.weeds[i] = { x = R(0, 128), h = R(6, 18), ph = R(0, 6) } end
  end,
  update = function(s, dt, t)
    if random() < dt * 3 then D.spawn(s.bub, { x = R(0, 128), y = 64, vx = 0, vy = -R(6, 14), ph = R(0, 6), r = R(0.4, 1.4) }) end
    D.parts_update(s.bub, dt, function(p, d) p.x = p.x + sin(t * 3 + p.ph) * 4 * d; if p.y < 2 then p.dead = true end end)
    s.ft.rot = 25 * sin(t * 0.11); s.ft.lean = 8 * sin(t * 0.17)
    s.ft.ua1 = 70 + 30 * sin(t * 0.4); s.ft.ua2 = -60 - 20 * sin(t * 0.35)
    s.fig.tgt = s.ft
    if s.fig.idle then s.fig:act({ { "glide", R(30, 100), R(24, 44), R(14, 24) } }) end
    s.fig:update(dt)
    s.bell = max(0, s.bell - dt * 0.15)
    for _, f in ipairs(s.fish) do f.x = f.x + f.v * dt; if f.x > 140 or f.x < -12 then f.v = -f.v end end
  end,
  draw = function(s, t)
    D.gradient(0, 63, 5, 0)
    for k = 0, 5 do
      local x0 = (k * 24 + t * 3) % 150 - 10
      for d = 0, 30, 2 do D.px(x0 + d * 0.5 + sin(t + d * 0.3 + k) * 2, d, 4 - d / 10) end
    end
    for x = 0, 127, 3 do D.px(x, 1 + sin(t * 1.5 + x * 0.2), 7) end
    D.house(4, 60, 16, 12, 1, 5); D.house(22, 60, 12, 16, 1, 4); D.house(88, 60, 18, 10, 1, 5); D.house(108, 60, 16, 14, 1, 4)
    D.rect(44, 26, 12, 34, 1); D.poly({ 42, 26, 58, 26, 50, 18 }, 1); D.rect(46, 30, 8, 8, 0)
    local a = sin(t * 1.4) * s.bell * 0.6
    D.line(50, 30, 50 + sin(a) * 3, 30 + cos(a) * 3, 3)
    D.circle(50 + sin(a) * 4, 30 + cos(a) * 4, 2, 3)
    for i, h in ipairs({ { 9, 51 }, { 26, 49 }, { 94, 54 }, { 114, 51 } }) do D.rect(h[1], h[2], 3, 3, 2 + (i % 2)) end
    for _, wd in ipairs(s.weeds) do
      screen.level(D.lv(2)); screen.move(wd.x, 64)
      for k = 1, 6 do screen.line(wd.x + sin(t * 0.8 + wd.ph + k * 0.6) * k * 0.6, 64 - wd.h * k / 6) end
      screen.stroke()
    end
    for _, f in ipairs(s.fish) do D.circle(f.x, f.y, 1.3, 2); D.px(f.x - (f.v > 0 and 2 or -2), f.y, 2) end
    s.fig:draw()
    for _, b in ipairs(s.bub.list) do if b.r < 0.8 then D.px(b.x, b.y, 7) else D.circle(b.x, b.y, b.r, 6, true) end end
  end,
  note = function(s, ev) if ev.str == "campana" then s.bell = 1 end end,
}

-------------------------------------------------------------------------------
-- IL VUOTO
-------------------------------------------------------------------------------
S.vuoto = {
  init = function(s)
    s.fig = D.figura(40, 46, { s = 1.05, l = 9, speed = 3, on_step = H.steps("vuoto", 0.3) })
    s.ghost = D.figura(70, 46, { s = 1.05, l = 2, pose = "stand", face = -1 })
    s.motes = D.parts(12)
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.35 then return { { "walk", R(20, 56) }, { "face", 1 }, { "pose", "stand", R(6, 10) } } end
      if r < 0.6 then return { { "walk", 60 }, { "face", 1 }, { "pose", "window", R(5, 8) }, { "pose", "head_down", 6 } } end
      if r < 0.8 then return { { "walk", R(84, 110) }, { "face", -1 }, { "pose", "stand", R(6, 10) } } end
      return { { "pose", "sit_ground", R(14, 24) }, { "pose", "stand", 3 } }
    end)
    s.fig:update(dt); s.ghost:update(dt)
    D.motes_update(s.motes, dt, 0.5, { 0, 0, 128, 64 }, t)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    D.line(0, 46, 127, 46, 2)
    screen.level(D.lv(5))
    screen.move(88.5, 46); screen.line(88.5, 28); screen.stroke()
    screen.move(88, 37.5); screen.line(99, 37.5); screen.stroke()
    screen.move(98.5, 37); screen.line(98.5, 46); screen.stroke()
    screen.move(88, 29.5); screen.line(90, 29.5); screen.stroke()
    s.ghost:draw()
    D.motes_draw(s.motes, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- PIANGERE
-------------------------------------------------------------------------------
S.pianto = {
  init = function(s)
    s.rain = D.parts(60)
    s.fig = D.figura(62, 54, { s = 1.1, l = 4, pose = "sit_ground" })
    s.puddle = 0
  end,
  update = function(s, dt, t)
    D.rain_update(s.rain, dt, 1.5 + mac("pioggia") * 3, 56, -3)
    think(s.fig, function() return { { "pose", pick({ "sit_ground", "cry", "sit_think" }), R(10, 20) } } end)
    s.fig.y = s.fig.cur.hy < 4 and 54 or 54
    s.fig.shake = 0.15 + mac("lacrime") * 0.2
    s.fig:update(dt)
    s.puddle = min(1, s.puddle + dt * 0.01)
  end,
  draw = function(s, t)
    D.gradient(0, 54, 1, 3)
    D.rect(0, 54, 128, 10, 2)
    D.reflection(62, 56, 63, 12 + s.puddle * 18, t, 5)
    -- un lampione lontano
    D.line(108, 54, 108, 18, 2); D.glow(108, 18, 10, 5); D.px(108, 16, 12)
    s.fig:draw()
    D.rain_draw(s.rain, 0.8)
  end,
}

-------------------------------------------------------------------------------
-- LA PALUDE
-------------------------------------------------------------------------------
S.palude = {
  init = function(s)
    s.reeds = D.grass_gen(191, 50, 0, 128, 6, 14)
    s.wisp = {}
    for i = 1, 4 do s.wisp[i] = { x = R(10, 118), y = R(30, 48), ph = R(0, 6) } end
    s.fig = D.figura(30, 58, { s = 0.95, l = 3, pose = "stand", speed = 2.5, on_step = H.steps("acqua", 0.3) })
  end,
  update = function(s, dt, t)
    for _, wv in ipairs(s.wisp) do
      wv.x = (wv.x + (D.noise(t * 0.3 + wv.ph * 5) - 0.5) * 8 * dt) % 128
      wv.y = D.clamp(wv.y + (D.noise(t * 0.3 + wv.ph * 3 + 9) - 0.5) * 6 * dt, 26, 50)
    end
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(10, 110), 2.5 }, { "pose", "stand", R(6, 10) } } end
      return { { "pose", "window", R(6, 10) } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local fog = 0.3 + mac("nebbia")
    D.gradient(0, 40, 1, 3)
    D.rect(0, 40, 128, 24, 1)
    D.waves(42, 64, t * 0.2, 2, 1, 4)
    for k = 0, 3 do
      local x0 = ((t * (1 + k * 0.5)) % 60) - 60
      for i = 0, 6 do D.rect(x0 + i * 26, 30 + k * 5, 16, 2, 2 + fog * 2) end
    end
    for _, wv in ipairs(s.wisp) do
      local b = 0.5 + 0.5 * sin(t * 1.3 + wv.ph)
      D.glow(wv.x, wv.y, 4 + b * 2, 3 + b * 3); D.px(wv.x, wv.y, 6 + b * 6)
    end
    D.bare_tree(100, 42, 20, 2, 19, sin(t * 0.3) * 0.5)
    s.fig:draw()
    D.grass(s.reeds, 62, t, 2, 0.4)
  end,
}

-------------------------------------------------------------------------------
-- LA METROPOLITANA CHIUSA
-------------------------------------------------------------------------------
S.metro = {
  init = function(s)
    s.fig = D.figura(40, 56, { s = 1.05, l = 9, pose = "stand", speed = 4, on_step = H.steps("metallo", 0.3) })
    s.ghost = 0
    s.gx = -60
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(20, 100) }, { "pose", "stand", R(6, 12) } } end
      return { { "pose", "sit_slump", R(10, 16) } }
    end)
    s.fig:update(dt)
    if s.ghost <= 0 and random() < dt * (0.02 + mac("treno") * 0.06) then s.ghost = 1; s.gx = -60 end
    if s.ghost > 0 then s.gx = s.gx + dt * 60; if s.gx > 200 then s.ghost = 0 end end
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    D.rect(0, 8, 128, 26, 2)
    for x = 0, 127, 8 do D.rect(x, 8, 7, 4, 3); D.rect(x + 4, 13, 7, 4, 3) end
    -- la scritta della stazione, sbiadita
    D.rect(44, 18, 40, 7, 4); D.rect(46, 20, 36, 3, 6)
    for k = 1, 3 do
      local fl = (k == 2 and D.noise(t * 7) < 0.3) and 0 or 1
      D.rect(k * 36 - 16, 3, 18, 1, 10 * fl)
    end
    D.rect(0, 34, 128, 2, 5)
    D.rect(0, 36, 128, 12, 0)
    if s.ghost > 0 then
      local x = s.gx
      D.rect(x - 60, 36, 60, 11, 3)
      for k = 0, 4 do D.rect(x - 56 + k * 12, 38, 8, 4, 9) end
    end
    D.line(0, 44, 127, 44, 3); D.line(0, 47, 127, 47, 3)
    D.rect(0, 48, 128, 16, 2)
    D.rect(0, 48, 128, 1, 7)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- PRIMA DI NASCERE
-------------------------------------------------------------------------------
S.grembo = {
  init = function(s)
    s.kid = D.figura(64, 38, { s = 1.0, l = 10, child = true, coat = false, pose = "curl" })
    s.beat = 0
  end,
  update = function(s, dt, t)
    s.kid.y = 38 + sin(t * 0.5) * 1.5
    s.kid:update(dt)
    s.beat = max(0, s.beat - dt * 2)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    local b = s.beat
    D.rect(0, 0, 128, 64, 0)
    for k = 5, 1, -1 do D.circle(64, 34, k * 8 + b * 2, 1 + k * 0.25 + warm * 0.8 + b * 0.5) end
    for k = 0, 7 do
      local a = k * pi / 4 + t * 0.05
      screen.level(D.lv(4 + warm)); screen.move(64 + cos(a) * 50, 34 + sin(a) * 50)
      screen.curve(64 + cos(a + 0.3) * 40, 34 + sin(a + 0.3) * 40, 64 + cos(a - 0.2) * 34, 34 + sin(a - 0.2) * 34, 64 + cos(a) * 28, 34 + sin(a) * 28)
      screen.stroke()
    end
    s.kid:draw()
  end,
  note = function(s, ev) if ev.ruolo == "pulsazione" or ev.str == "sub" then s.beat = 1 end end,
}

-------------------------------------------------------------------------------
-- L'ALBA (nascosto)
-------------------------------------------------------------------------------
S.alba = {
  init = function(s)
    s.k = 0
    s.hills = D.ridge_gen(91, 46, 8, 0.6)
    s.grass = D.grass_gen(92, 60, 0, 128, 1, 4)
    s.birds = {}
    s.fig = D.figura(60, 57, { s = 1.0, l = 1, dark = true, pose = "lie_face" })
    s.fig:act({ { "pose", "lie_face", 14 }, { "pose", "sit_ground", 16 }, { "pose", "kneel", 10 }, { "pose", "stand", 5 },
      { "pose", "look_up", 8 }, { "pose", "arms_open", 12 }, { "pose", "stand", 10 } })
  end,
  update = function(s, dt, t)
    s.k = min(1, s.k + dt / 150)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "stand", R(10, 20) }, { "pose", "look_up", R(6, 10) } } end
      if r < 0.75 then return { { "pose", "arms_open", R(6, 10) } } end
      return { { "pose", "sit_ground", R(15, 25) }, { "pose", "stand", 4 } }
    end)
    s.fig:update(dt)
    if #s.birds < floor(s.k * 6) and random() < dt then s.birds[#s.birds + 1] = { x = R(-10, 40), y = R(10, 30), v = R(6, 12), ph = R(0, 6) } end
    for _, b in ipairs(s.birds) do b.x = b.x + b.v * dt; if b.x > 140 then b.x = -10 end end
  end,
  draw = function(s, t)
    local k = s.k
    D.gradient(0, 46, 1 + k * 4, 3 + k * 9)
    local sy = 54 - k * 26
    for a = 0, 11 do
      local ang = -pi / 2 + (a - 5.5) * 0.22 + sin(t * 0.1) * 0.05
      D.line(96, sy, 96 + cos(ang) * 70, sy + sin(ang) * 70, 2 + k * 4)
    end
    D.circle(96, sy, 10 + k * 3, 5 + k * 5); D.circle(96, sy, 6, 10 + k * 5)
    D.ridge(s.hills, 1 + k, 64)
    D.rect(0, 52, 128, 12, 1)
    D.grass(s.grass, 57, t, 2 + k * 2, 0.5)
    for _, b in ipairs(s.birds) do local wg = sin(t * 6 + b.ph) * 1.4; D.line(b.x - 2, b.y - wg, b.x, b.y, 2); D.line(b.x, b.y, b.x + 2, b.y - wg, 2) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL MONDO SENZA SUONO (nascosto)
-------------------------------------------------------------------------------
S.silenzio = {
  init = function(s)
    s.rings = {}
    s.fig = D.figura(64, 56, { s = 1.0, l = 4, pose = "sit_ground", face = 1 })
  end,
  update = function(s, dt, t)
    if random() < dt * 0.08 then s.rings[#s.rings + 1] = 0 end
    for i = #s.rings, 1, -1 do s.rings[i] = s.rings[i] + dt * 3; if s.rings[i] > 70 then table.remove(s.rings, i) end end
    think(s.fig, function() return { { "pose", pick({ "sit_ground", "sit_think", "pray" }), R(20, 40) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    for _, r in ipairs(s.rings) do D.circle(64, 22, r, 2 * (1 - r / 70), true) end
    D.circle(64, 22, 3 + sin(t * 0.5), 2)
    D.px(64, 22, 15)
    s.fig:draw()
  end,
  note = function(s, ev) s.rings[#s.rings + 1] = 0 end,
}

-------------------------------------------------------------------------------
-- ALTROVE: stanze che nascono quando ci entri
-------------------------------------------------------------------------------
S.altrove = {
  init = function(s, place)
    local g = place and place.gen or { seed = random(9999) }
    local r = D.lcg(g.seed)
    s.r = r
    s.kind = g.kind or "stanza"
    s.wall = 1 + floor(r() * 4)
    s.props = {}
    for i = 1, 3 + floor(r() * 4) do s.props[i] = { k = floor(r() * 7), x = 8 + r() * 110, l = 2 + floor(r() * 6) } end
    s.cand = r() < 0.5
    s.photos = r() < 0.5
    s.stairs = r() < 0.35
    s.water = s.kind == "fuori" and r() < 0.5
    s.stars = D.stars_gen(40, g.seed, 0, 30)
    s.fig = D.figura(R(30, 90), 58, { s = s.kind == "fuori" and 1.0 or KS, l = 10, speed = 3, on_step = H.steps("legno", 0.3) })
    s.win = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      if random() < 0.5 then return { { "walk", R(14, 114) }, { "pose", pick({ "stand", "look_up", "window", "head_down" }), R(6, 12) } } end
      return { { "pose", pick({ "sit_ground", "kneel", "hug" }), R(8, 16) } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    if s.kind == "fuori" then
      K.sky("notte", 44, t, s)
      D.rect(0, 44, 128, 20, 2)
      if s.water then D.waves(46, 64, t * 0.4, 5, 2, 3) end
    else
      K.room({ wall = s.wall, fy = 58, floor = "assi", floor_l = s.wall - 1 >= 0 and s.wall - 1 or 0, paper = "righe", ceil = 4 }, t)
    end
    for _, p in ipairs(s.props) do
      local x = p.x
      if p.k == 0 then K.frame(x, 16, 9, 12, p.l, 1)
      elseif p.k == 1 then K.chair(x, 58, 1, p.l)
      elseif p.k == 2 then D.candle(x, 58, t, p.l, 4)
      elseif p.k == 3 then K.window(x, 14, 14, 14, K.views.night, t, s.win, p.l)
      elseif p.k == 4 then K.clock(x, 12, t, p.l)
      elseif p.k == 5 then D.bare_tree(x, 58, 22, p.l, p.l * 5, sin(t * 0.3))
      else K.door(x, 58, 0.5, p.l, 8) end
    end
    if s.photos then for i = 0, 5 do D.rect(20 + i * 15, 30 + sin(i * 2.3) * 4, 6, 5, 7); D.rect(21 + i * 15, 31 + sin(i * 2.3) * 4, 4, 3, 2) end end
    if s.stairs then for k = 0, 6 do D.rect(90 + k * 5, 58 - k * 5, 6, 1, 6) end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- QUALCUNO È VENUTO (nascosto)
-------------------------------------------------------------------------------
S.qualcuno = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = 1.05, l = 4, pose = "sit_ground" })
    s.other = D.figura(150, 58, { s = 1.05, l = 12, speed = 5, face = -1,
      prop = function(x, y) D.circle(x, y + 1, 5, 4); D.rect(x - 1, y - 1, 3, 4, 14) end })
    s.other:act({ { "walk", 56 }, { "pose", "carry", 2 }, { "fn", function() s.fig:act({ { "pose", "stand", 3 } }) end }, { "pose", "hug", 20 } })
    s.light = 0
  end,
  update = function(s, dt, t)
    s.fig:update(dt); s.other:update(dt)
    think(s.other, function() return { { "pose", pick({ "hug", "stand", "carry" }), R(10, 20) } } end)
    think(s.fig, function() return { { "pose", pick({ "hug", "stand", "look_up" }), R(10, 20) } } end)
    s.light = D.clamp((150 - s.other.x) / 90, 0, 1)
  end,
  draw = function(s, t)
    local k = s.light
    D.rect(0, 0, 128, 64, k * 2)
    D.glow(s.other.x, s.other.y - 12, 26 * k + 6, 3 + k * 5)
    D.rect(0, 58, 128, 6, 2 + k)
    s.fig:draw(); s.other:draw()
  end,
}

end
