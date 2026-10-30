-- ANAMNESI · scene dei ricordi (v4): cielo, alture, infanzia, paese
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

D.POSE.point = { lean = -4, nod = -24, ua1 = 140, ua2 = 10, fa1 = 150, fa2 = 4, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.lean_rail = { lean = 16, nod = 24, ua1 = 60, ua2 = 54, fa1 = 100, fa2 = 96, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.throw = { lean = 6, nod = 6, ua1 = 100, ua2 = -20, fa1 = 120, fa2 = -10, th1 = 10, th2 = -10, sh1 = 0, sh2 = -4, hy = 7.0, rot = 0 }
D.POSE.dance = { lean = -4, nod = -8, ua1 = 130, ua2 = 120, fa1 = 160, fa2 = 150, th1 = 14, th2 = -10, sh1 = 0, sh2 = -6, hy = 7.1, rot = 0 }
D.POSE.shovel = { lean = 34, nod = 18, ua1 = 60, ua2 = 50, fa1 = 70, fa2 = 60, th1 = 14, th2 = -8, sh1 = 0, sh2 = -4, hy = 6.8, rot = 0 }

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(D.tr(s)) else screen.text(D.tr(s)) end
end

-------------------------------------------------------------------------------
-- SOTTO LE STELLE: l'erba fredda, l'Orsa Maggiore indicata col dito
-------------------------------------------------------------------------------
local ORSA = { { 70, 14 }, { 78, 12 }, { 86, 14 }, { 93, 17 }, { 96, 24 }, { 106, 25 }, { 108, 18 } }
S.stelle = {
  init = function(s)
    s.stars = D.stars_gen(110, 61, 0, 44)
    s.fig = D.figura(40, 54, { s = 1.15, l = 2, dark = true, pose = "lie" })
    s.nonno = D.figura(62, 54, { s = 1.2, l = 2, dark = true, pose = "sit_ground", face = 1 })
    s.show = 0
    s.fall = nil
  end,
  update = function(s, dt, t)
    think(s.nonno, function() return { { "pose", "sit_ground", R(6, 10) }, { "fn", function() s.show = 6 end }, { "pose", "point", 6 }, { "pose", "sit_ground", 4 } } end)
    think(s.fig, function() return pick({ { { "pose", "lie", R(10, 16) } }, { { "pose", "sit_ground", 5 }, { "pose", "look_up", 4 }, { "pose", "lie", 4 } } }) end)
    s.fig:update(dt); s.nonno:update(dt)
    s.show = max(0, s.show - dt)
    if not s.fall and random() < dt * (0.04 + mac("stelle") * 0.12) then s.fall = { x = R(10, 110), y = R(4, 20), k = 0 } end
    if s.fall then s.fall.k = s.fall.k + dt * 1.5; if s.fall.k > 1 then s.fall = nil end end
  end,
  draw = function(s, t)
    local st, nt = mac("stelle"), mac("notte")
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 0.8 + st * 0.6 + nt * 0.3)
    -- la Via Lattea: una fascia di punti più fitti, netta
    for i = 0, 40 do local x = (i * 37) % 128; local y = 6 + x * 0.25 + ((i * 13) % 7); D.px(x, y, 3 + (i % 3)) end
    local a = min(1, s.show) * min(1, s.show / 1)
    for i, p in ipairs(ORSA) do
      D.px(p[1], p[2], 12 + a * 3); D.px(p[1] + 1, p[2], 7)
      if a > 0.05 and ORSA[i + 1] then D.line(p[1], p[2], ORSA[i + 1][1], ORSA[i + 1][2], 4 * a) end
    end
    if s.fall then local k = s.fall.k; local x, y = s.fall.x + k * 20, s.fall.y + k * 8; D.line(x, y, x - 5, y - 2, 13 * (1 - k)) end
    -- il prato, il profilo dei colli, gli alberi neri
    D.rect(0, 46, 128, 18, 1)
    for x = 0, 127 do local h = 2 + sin(x * 0.06) * 2 + sin(x * 0.17); D.rect(x, 46 - h, 1, h, 1) end
    D.tree(116, 46, 16, 1, 3, 0)
    for x = 0, 127, 3 do D.line(x, 64, x + sin(t * 0.8 + x) * 0.6, 58 + (x % 5) * 0.6, 2) end
    s.nonno:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA NASCITA: il primo grido, la mano che stringe un dito
-------------------------------------------------------------------------------
S.sala_parto = {
  init = function(s)
    s.fig = D.figura(70, 58, { s = KS, l = 9, pose = "cradle",
      prop = function(x, y) D.circle(x - 2, y - 2, 3, 13); D.circle(x - 4, y - 4, 1.8, 14) end })
    s.beat = 0
    s.cry = 3
    s.motes = D.parts(20)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "cradle", R(10, 16) } }, { { "walk", R(60, 84), 2 }, { "pose", "cradle", 8 } }, { { "pose", "hug", 6 }, { "pose", "cradle", 6 } } }) end)
    s.fig:update(dt)
    if not s.fig.walking then s.fig.cur.lean = s.fig.cur.lean + sin(t * 1.3) * 0.25 end
    s.beat = s.beat + dt * 2.2
    s.cry = s.cry - dt
    if s.cry < 0 then s.cry = R(20, 40); S.env.sfx("whisper", 880, 0.02, 0.8, 0.2, 0.7, 0.05) end
    D.motes_update(s.motes, dt, 2, { 10, 6, 50, 30 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    K.room({ wall = 7 + lu * 2, fy = 58, floor = "piastrelle", floor_l = 6, ceil = 4 }, t)
    -- la finestra dell'alba
    K.window(10, 10, 26, 20, K.views.day, t, s, 11)
    for k = 0, 4 do D.line(14 + k * 4, 30, 42 + k * 7, 58, 11 + lu * 2) end
    D.motes_draw(s.motes, 14)
    -- il letto, la flebo, il monitor col battito
    D.rect(92, 44, 32, 4, 9); D.rect(94, 48, 2, 10, 8); D.rect(120, 48, 2, 10, 8)
    D.rect(120, 32, 3, 12, 10)
    D.poly({ 96, 44, 122, 44, 122, 41, 100, 40 }, 12)
    D.rect(100, 14, 20, 12, 3)
    for i = 0, 18 do
      local ph = (s.beat - i * 0.06) % 1
      local y = (ph < 0.08) and -4 or ((ph < 0.14) and 2 or 0)
      D.px(101 + i, 20 + y, 13)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL SILENZIO DEI PENSIERI: lui seduto, le nuvole-pensiero che passano
-------------------------------------------------------------------------------
S.pensieri = {
  init = function(s)
    s.fig = D.figura(36, 50, { s = 1.3, l = 3, dark = true, pose = "sit_ground" })
    s.cl = {}
    for i = 1, 6 do s.cl[i] = { x = R(-20, 140), y = R(8, 34), w = R(10, 22), v = R(2, 5), k = random(4) } end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(10, 16) } }, { { "pose", "sit_think", R(8, 12) } }, { { "pose", "look_up", 6 } } }) end)
    s.fig:update(dt)
    local sp = 1 - mac("silenzio") * 0.6
    for _, c in ipairs(s.cl) do c.x = c.x + c.v * dt * sp; if c.x > 150 then c.x = -30; c.y = R(8, 34); c.k = random(4) end end
  end,
  draw = function(s, t)
    D.gradient(0, 50, 10, 13)
    for _, c in ipairs(s.cl) do
      D.circle(c.x, c.y, c.w * 0.32, 15); D.circle(c.x + c.w * 0.3, c.y + 1, c.w * 0.25, 15); D.circle(c.x - c.w * 0.3, c.y + 1, c.w * 0.22, 15)
      -- dentro ogni nuvola, un pensiero minuscolo
      local x, y = c.x, c.y
      if c.k == 1 then D.house(x - 3, y + 2, 6, 3, 9, 2)
      elseif c.k == 2 then D.circle(x, y, 1.4, 9); D.line(x, y + 1, x, y + 4, 9)
      elseif c.k == 3 then D.px(x - 2, y, 9); D.px(x, y - 1, 9); D.px(x + 2, y, 9)
      else D.line(x - 3, y + 1, x + 3, y + 1, 9) end
    end
    D.rect(0, 50, 128, 14, 12)
    D.line(0, 50, 127, 50, 14)
    -- i pensieri che salgono da lui, piccoli puntini
    for i = 0, 4 do local k = ((t * 0.15 + i * 0.2) % 1); D.px(s.fig.x + 4 + sin(t + i) * 2 + k * 10, 36 - k * 26, 4 * (1 - k)) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ULTIMO PIANO: le finestre rotte, la luce come acqua, le tende come vele
-------------------------------------------------------------------------------
S.ultimo_piano = {
  init = function(s)
    s.fig = D.figura(30, 58, { s = KS, l = 3, dark = true, pose = "stand", speed = 3, on_step = H.steps("legno", 0.3) })
    s.fill = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(40, 70), 3 }, { "face", 1 }, { "pose", "look_up", 5 }, { "pose", "arms_open", R(8, 12) }, { "pose", "stand", 3 } } end)
    s.fig:update(dt)
    s.fill = (s.fill + dt * 0.02 * (0.5 + mac("luce"))) % 1.4
  end,
  draw = function(s, t)
    local lu, w = mac("luce"), mac("vento")
    K.room({ wall = 4, fy = 58, floor = "assi", floor_l = 3, ceil = 4 }, t)
    -- le finestre rotte: dentro il cielo bianco
    for i = 0, 2 do
      local x = 20 + i * 34
      D.rect(x, 10, 22, 30, 13 + lu * 2)
      D.line(x + 3, 10, x + 9, 22, 4); D.line(x + 9, 22, x + 6, 30, 4)
      screen.level(D.lv(5)); screen.rect(x - 0.5, 9.5, 23, 31); screen.stroke()
      -- la tenda che si gonfia
      local c = sin(t * (0.6 + w) + i) * (3 + w * 6)
      D.poly({ x + 18, 10, x + 22, 10, x + 22 + c * 0.5, 40, x + 16 + c, 40 }, 9)
    end
    -- la luce che riempie la stanza dal pavimento, come acqua
    local k = min(1, s.fill)
    local y = 58 - k * 50
    for yy = floor(y), 57, 3 do D.line(0, yy, 127, yy, 6 + lu * 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- DALL'ALTRA PARTE: la luce bianca, le sagome che aspettano
-------------------------------------------------------------------------------
S.oltre = {
  init = function(s)
    s.fig = D.figura(24, 46, { s = 1.15, l = 3, dark = true, speed = 3, pose = "float", on_step = H.steps("nuvola", 0.15) })
    s.ones = {}
    for i = 1, 4 do s.ones[i] = D.figura(80 + i * 10, 44, { s = 1.0, l = 11, face = -1, pose = "stand", bun = (i == 2), dress = (i == 2) }) end
    s.k = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "float", 4 }, { "glide", R(50, 70), 44, 8 }, { "pose", "arms_open", 8 }, { "glide", 24, 46, 6 } } end)
    s.fig:update(dt)
    s.fig.y = s.fig.y + sin(t * 0.8) * 0.03
    for i, o in ipairs(s.ones) do
      think(o, function() return pick({ { { "pose", "stand", R(4, 8) } }, { { "pose", "arms_open", 5 }, { "pose", "stand", 3 } } }) end)
      o:update(dt)
    end
    s.k = s.k + dt
  end,
  draw = function(s, t)
    local lu, vo = mac("luce"), mac("voci")
    D.rect(0, 0, 128, 64, 12 + lu * 2)
    -- i raggi bianchi dal fondo
    for i = 0, 11 do local a = i / 12 * pi * 2 + t * 0.03; D.line(100, 30, 100 + cos(a) * 80, 30 + sin(a) * 60, 15) end
    D.circle(100, 30, 14, 15)
    for i, o in ipairs(s.ones) do o.l = 11 - vo * 4; o:draw() end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'INCONTRO: il bar che chiude, le sedie sui tavoli, voi due che parlate
-------------------------------------------------------------------------------
S.incontro = {
  init = function(s)
    s.fig = D.figura(52, 58, { s = KS, l = 10, pose = "talk", face = 1 })
    s.lei = D.figura(80, 58, { s = KS, l = 7, pose = "talk", face = -1, dress = true })
    s.lights = 3
    s.rain = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "talk", R(3, 6) } }, { { "pose", "sit", R(3, 5) } }, { { "pose", "sit_think", 4 } } }) end)
    think(s.lei, function() return pick({ { { "pose", "talk", R(3, 6) } }, { { "pose", "sit", R(3, 5) } } }) end)
    s.fig:update(dt); s.lei:update(dt)
    if random() < dt * 0.01 and s.lights > 1 then s.lights = s.lights - 1 end
    if s.lights == 1 and random() < dt * 0.005 then s.lights = 3 end
  end,
  draw = function(s, t)
    local warm, nt = mac("calore"), mac("notte")
    K.room({ wall = 3, fy = 58, floor = "scacchi", floor_l = 2, ceil = 4 }, t)
    -- la vetrina, fuori la strada bagnata
    K.window(8, 12, 30, 26, K.views.rain, t, s.rain, 4)
    -- il bancone, le bottiglie
    D.rect(98, 38, 30, 20, 4); D.rect(98, 37, 30, 2, 6)
    for i = 0, 6 do D.rect(100 + i * 4, 18, 2, 6, 6 + (i % 3) * 2) end
    D.rect(98, 25, 30, 1, 5)
    -- le lampade che si spengono una alla volta
    for i = 1, 3 do
      local x = 20 + i * 24
      D.line(x, 4, x, 10, 4)
      local on = i <= s.lights
      D.poly({ x - 3, 10, x + 3, 10, x + 2, 13, x - 2, 13 }, on and (11 + warm * 3) or 3)
    end
    -- le sedie già sui tavoli
    for _, x in ipairs({ 14, 112 }) do D.rect(x, 46, 12, 2, 5); D.rect(x + 1, 48, 2, 10, 4); D.rect(x + 9, 48, 2, 10, 4); D.rect(x + 2, 40, 1, 6, 4); D.rect(x + 2, 40, 7, 1, 4) end
    -- il vostro tavolino, le due tazze
    D.rect(60, 46, 14, 2, 6); D.rect(66, 48, 2, 10, 5)
    D.rect(62, 44, 2, 2, 11); D.rect(70, 44, 2, 2, 11)
    s.fig:draw(); s.lei:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CASCATA: l'acqua che cade dall'alto, la polvere, l'arcobaleno fermo
-------------------------------------------------------------------------------
S.marmore = {
  init = function(s)
    s.drops = {}
    for i = 1, 70 do s.drops[i] = { x = R(52, 76), y = R(0, 50), v = R(40, 80) } end
    s.fig = D.figura(18, 56, { s = 1.15, l = 3, dark = true, pose = "look_up", speed = 3, on_step = H.steps("pietra", 0.3) })
    s.mist = D.parts(40)
  end,
  update = function(s, dt, t)
    local p = 0.7 + mac("profondita") * 0.6
    for _, d in ipairs(s.drops) do d.y = d.y + d.v * dt * p; if d.y > 50 then d.y = R(-4, 4); d.x = R(52, 76) end end
    if random() < dt * 12 then D.spawn(s.mist, { x = R(46, 84), y = 50, vx = R(-6, 6), vy = R(-8, -3), life = 2.5 }) end
    D.parts_update(s.mist, dt)
    think(s.fig, function() return pick({ { { "pose", "look_up", R(8, 12) } }, { { "walk", R(14, 32), 3 }, { "pose", "stand", 5 } }, { { "pose", "arms_open", 5 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 8 + lu * 3, 11 + lu * 2)
    -- le rocce e il bosco ai lati
    D.poly({ 0, 0, 50, 0, 52, 20, 46, 64, 0, 64 }, 4)
    D.poly({ 128, 0, 78, 0, 76, 24, 84, 64, 128, 64 }, 4)
    for i = 0, 5 do D.tree(8 + i * 7, 14 + i * 5, 10, 3, i + 4, sin(t * 0.7 + i) * 0.4); D.tree(120 - i * 7, 16 + i * 5, 10, 3, i + 9, sin(t * 0.7 + i) * 0.4) end
    -- l'acqua: fili bianchi che cadono
    D.rect(52, 0, 24, 50, 9)
    for _, d in ipairs(s.drops) do D.line(d.x, d.y, d.x, d.y + 4, 15) end
    -- l'arcobaleno fermo nella polvere d'acqua
    if lu > 0.2 then
      for k = 0, 2 do
        screen.level(D.lv((8 + k * 2) * lu)); screen.arc(64, 64, 26 + k * 2, pi * 1.15, pi * 1.85); screen.stroke()
      end
    end
    -- la pozza in basso, la polvere che sale
    D.rect(40, 50, 50, 14, 7); D.waves(51, 64, t, 12, 8, 3)
    for _, p in ipairs(s.mist.list) do D.px(p.x, p.y, 14 * (1 - p.age / 2.5)) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CITTÀ CAPOVOLTA: le case appese al cielo, la gente a testa in giù
-------------------------------------------------------------------------------
S.capovolta = {
  init = function(s)
    s.fig = D.figura(30, 56, { s = 1.15, l = 10, pose = "look_up", speed = 4, on_step = H.steps("pietra", 0.3) })
    s.walk = {}
    for i = 1, 4 do s.walk[i] = { x = R(0, 128), v = R(3, 7) * pick({ -1, 1 }) } end
    s.win = {}
    for i = 1, 30 do s.win[i] = R(0, 40) end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "look_up", R(6, 10) } }, { { "walk", R(20, 100), 4 }, { "pose", "look_up", 5 } }, { { "pose", "reach_up", 4 } } }) end)
    s.fig:update(dt)
    for _, w in ipairs(s.walk) do w.x = w.x + w.v * dt; if w.x > 134 then w.x = -6 elseif w.x < -6 then w.x = 134 end end
  end,
  draw = function(s, t)
    D.gradient(0, 64, 3, 7)
    -- la città appesa, a testa in giù
    D.rect(0, 0, 128, 6, 2)
    local i = 0
    for x = 0, 120, 13 do
      i = i + 1
      local h = 10 + (i * 7) % 14
      D.rect(x, 6, 11, h, 2)
      D.poly({ x - 1, 6 + h, x + 12, 6 + h, x + 5.5, 10 + h }, 2)
      for wy = 9, 4 + h, 5 do
        local lit = ((t * 0.5 + i * 3 + wy) % 40) < s.win[(i % 30) + 1]
        D.rect(x + 3, wy, 2, 2, lit and 11 or 1); D.rect(x + 7, wy, 2, 2, (not lit) and 9 or 1)
      end
    end
    -- le persone che camminano sul soffitto
    for _, w in ipairs(s.walk) do
      local x = w.x
      D.circle(x, 12 + 18, 1.3, 1)
      D.rect(x - 1, 6 + 18, 2, 5, 1)
    end
    -- la strada di sotto, dove sta lui
    D.rect(0, 56, 128, 8, 4)
    for x = 0, 127, 8 do D.rect(x, 59, 4, 1, 6) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL FIUME: l'acqua gelata d'agosto, la diga di sassi, il sasso che rimbalza
-------------------------------------------------------------------------------
S.fiume = {
  init = function(s)
    s.fig = D.figura(46, 50, { s = 1.15, l = 3, dark = true, child = true, pose = "stand", speed = 4 })
    s.skip = nil
    s.stones = {}
    for i = 1, 9 do s.stones[i] = { x = 64 + i * 4 + R(-1, 1), y = 50 + R(-1, 1) } end
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "pose", "bend", 3 }, { "pose", "throw", 0.6 }, { "fn", function() s.skip = { x = 52, k = 0, n = 0 } end }, { "pose", "stand", 5 } } end
      if r < 0.7 then return { { "walk", R(30, 60), 3 }, { "pose", "dig", R(5, 8) } } end
      return { { "pose", "look_up", 4 }, { "pose", "stand", 3 } }
    end)
    s.fig:update(dt)
    if s.skip then
      local o = s.skip.k
      s.skip.k = s.skip.k + dt * 1.4
      if floor(o * 4) ~= floor(s.skip.k * 4) and s.skip.k < 1 then S.env.sfx("drop", 1200 + s.skip.k * 600, 0.02, 0.1, 0.4, 0.6, 0.001) end
      if s.skip.k > 1 then s.skip = nil end
    end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 9 + lu * 2, 11 + lu * 2)
    -- gli alberi sulla riva lontana
    for i = 0, 10 do D.tree(i * 13 + 4, 30, 14, 5, i + 1, sin(t * 0.6 + i) * mac("foglie")) end
    D.rect(0, 30, 128, 6, 6)
    -- il fiume che scorre, i riflessi
    D.rect(0, 36, 128, 16, 8)
    for i = 0, 14 do
      local x = (i * 23 + t * 14) % 150 - 10
      D.line(x, 38 + (i % 5) * 3, x + 6, 38 + (i % 5) * 3, 12)
    end
    -- la diga di sassi
    for _, st in ipairs(s.stones) do D.circle(st.x, st.y - 2, 1.8, 5) end
    -- il sasso piatto che rimbalza
    if s.skip then
      local k = s.skip.k
      local x = 54 + k * 70
      local b = abs(sin(k * pi * 4)) * (1 - k) * 6
      D.px(x, 44 - b, 3)
      if b < 0.8 then D.ripple(x, 45, 2 + (k * 4 % 1) * 3, 13) end
    end
    -- la riva di ghiaia
    D.rect(0, 50, 128, 14, 9)
    for i = 0, 50 do D.px((i * 29) % 128, 52 + (i * 7) % 11, 6 + (i % 3) * 2) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA VENDEMMIA: i filari, le cassette, il nonno che canta
-------------------------------------------------------------------------------
S.vendemmia = {
  init = function(s)
    s.nonno = D.figura(40, 56, { s = 1.2, l = 3, dark = true, pose = "bend", speed = 3, on_step = H.steps("erba", 0.25) })
    s.fig = D.figura(80, 56, { s = 1.0, l = 3, dark = true, child = true, pose = "carry", speed = 4, on_step = H.steps("erba", 0.2),
      prop = function(x, y) D.rect(x - 3, y - 2, 6, 3, 6) end })
    s.wasps = {}
    for i = 1, 4 do s.wasps[i] = { x = R(10, 120), y = R(30, 50), ph = R(0, 6) } end
    s.sing = 0
  end,
  update = function(s, dt, t)
    think(s.nonno, function() return pick({ { { "pose", "bend", R(5, 9) } }, { { "walk", R(20, 60), 3 }, { "pose", "bend", 6 } }, { { "pose", "stand", 2 }, { "fn", function() s.sing = 5 end }, { "pose", "talk", 4 } } }) end)
    think(s.fig, function() return { { "walk", R(70, 110), 4 }, { "pose", "carry", 2 }, { "walk", R(60, 100), 4 }, { "pose", "bend", 2 } } end)
    s.nonno:update(dt); s.fig:update(dt)
    s.sing = max(0, s.sing - dt)
  end,
  draw = function(s, t)
    local warm, lu = mac("calore"), mac("luce")
    D.gradient(0, 30, 9 + lu * 3, 12 + warm)
    D.circle(108, 12, 6, 15)
    -- le colline di vigna
    for x = 0, 127 do local h = 6 + sin(x * 0.04) * 3; D.rect(x, 30 - h, 1, h, 7) end
    D.rect(0, 30, 128, 34, 8)
    -- i filari: pali, fili, foglie, grappoli
    for row = 0, 2 do
      local y = 38 + row * 8
      local l = 4 + row
      D.line(0, y - 6, 127, y - 6, l)
      for x = (row * 5) % 14, 127, 14 do
        D.rect(x, y - 8, 1, 8, l - 1)
        D.circle(x + 5, y - 6, 3, l + 1)
        if (x + row) % 3 == 0 then D.circle(x + 4, y - 3, 1.2, 2); D.circle(x + 6, y - 3, 1.2, 2); D.circle(x + 5, y - 2, 1.2, 2) end
      end
    end
    -- le cassette piene
    for i = 0, 2 do D.rect(100 + i * 8, 52, 7, 4, 5); for k = 0, 2 do D.circle(101.5 + i * 8 + k * 2, 51, 1, 2) end end
    for _, w in ipairs(s.wasps) do D.px(w.x + sin(t * 3 + w.ph) * 6, w.y + cos(t * 4 + w.ph) * 3, 2) end
    s.nonno:draw(); s.fig:draw()
    if s.sing > 0 then for i = 1, 3 do local k = ((t * 0.6 + i * 0.33) % 1); D.px(s.nonno.x + 4 + k * 8, s.nonno.y - 20 - k * 10, 3 * (1 - k)) end end
  end,
}

-------------------------------------------------------------------------------
-- LA STANZA CHE NON RICORDAVI: i giocattoli in ordine, il cavallo a dondolo
-------------------------------------------------------------------------------
S.stanza = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, speed = 3, on_step = H.steps("legno", 0.25) })
    s.rock = 0.3
    s.open = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "fn", function() s.open = 0 end }, { "wait", 1 }, { "walk", 30, 3 }, { "pose", "look_up", 3 }, { "walk", 62, 3 }, { "pose", "kneel", R(6, 9) },
      { "pose", "stand", 2 }, { "walk", 96, 3 }, { "pose", "head_down", 4 }, { "walk", -10, 4 }, { "wait", R(4, 8) } } end)
    s.fig:update(dt)
    s.open = min(1, s.open + dt * 0.5)
    s.rock = s.rock * (1 - dt * 0.05)
    if s.fig.x > 80 and s.fig.x < 86 then s.rock = 0.3 end
  end,
  draw = function(s, t)
    local ri = mac("ricordo")
    K.room({ wall = 5, fy = 58, floor = "assi", floor_l = 4, paper = "puntini", ceil = 4 }, t)
    -- la porta che prima non c'era, con la luce dietro
    D.rect(6, 22, 16, 36, 13 + ri * 2)
    D.rect(6, 22, 16 * (1 - s.open), 36, 5)
    -- i giocattoli messi in ordine sulla mensola
    D.rect(36, 24, 50, 1, 7)
    D.circle(40, 22, 2, 11); D.rect(46, 19, 5, 5, 9); D.px(48, 21, 13)
    D.rect(54, 20, 7, 4, 12); D.px(55, 24, 3); D.px(59, 24, 3)
    D.circle(66, 21, 2.5, 8); D.px(66, 20, 14); D.px(67, 20, 14)
    D.rect(72, 18, 3, 6, 10); D.rect(77, 20, 6, 4, 6)
    -- il trenino per terra, il cavallo a dondolo che ancora si muove
    for i = 0, 3 do D.rect(30 + i * 7, 54, 6, 3, 8 - i); D.px(31 + i * 7, 57, 3); D.px(34 + i * 7, 57, 3) end
    local a = sin(t * 2.4) * s.rock
    local cx, cy = 92, 54
    local function rot(x, y) return cx + x * cos(a) - y * sin(a), cy + x * sin(a) + y * cos(a) end
    local p1x, p1y = rot(-9, 2); local p2x, p2y = rot(9, 2)
    D.line(p1x, p1y, p2x, p2y, 8)
    local bx, by = rot(0, -6)
    D.poly({ bx - 6, by, bx + 5, by, bx + 4, by - 4, bx - 5, by - 4 }, 10)
    local hx, hy = rot(6, -10)
    D.circle(hx, hy, 2.4, 10)
    local l1x, l1y = rot(-4, 1); local l2x, l2y = rot(4, 1)
    D.line(bx - 4, by, l1x, l1y, 9); D.line(bx + 3, by, l2x, l2y, 9)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- STARE MALE: la febbre, la stanza che ondeggia, la mano sulla fronte
-------------------------------------------------------------------------------
S.male = {
  init = function(s)
    s.fig = D.figura(42, 46, { s = KS, l = 9, child = true, pose = "lie" })
    s.nonna = D.figura(118, 58, { s = KS, l = 5, dark = false, dress = true, bun = true, speed = 3, on_step = H.steps("legno", 0.2) })
    s.hand = 0
  end,
  update = function(s, dt, t)
    think(s.nonna, function() return { { "wait", R(8, 16) }, { "walk", 74, 3 }, { "face", -1 }, { "pose", "reach_up", 0.5 }, { "fn", function() s.hand = 4 end },
      { "pose", "bend", 4 }, { "pose", "stand", 2 }, { "walk", 118, 3 }, { "face", -1 } } end)
    s.nonna:update(dt); s.fig:update(dt)
    s.hand = max(0, s.hand - dt)
  end,
  draw = function(s, t)
    local fr = mac("fragilita")
    local sway = (s.hand > 0) and 0 or (0.6 + fr * 2.5)
    local wob = sin(t * 0.7) * sway
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "fiori", ceil = 4 }, t)
    -- le cose della stanza che ondeggiano con la febbre
    K.frame(70 + wob, 14, 12, 10, 4, 6)
    K.clock(100 + wob * 1.5, 14, t, 5)
    K.window(8 + wob * 0.5, 10, 20, 18, K.views.night, t, s, 4)
    K.bed(20, 58, 3.2, 3, 6)
    -- il comodino con la camomilla
    D.rect(68, 46, 10, 12, 4); D.rect(72, 42, 3, 4, 10)
    for i = 1, 2 do local k = (t * 0.3 + i * 0.5) % 1; D.px(73 + sin(t * 2 + i) * 1.2, 41 - k * 8, 8 * (1 - k)) end
    s.fig:draw()
    -- la coperta
    D.poly({ 34, 46, 66, 45, 66, 49, 34, 49 }, 6)
    s.nonna:draw()
    if s.hand > 0 then D.circle(44, 37, 2.2, 11) end
  end,
}

-------------------------------------------------------------------------------
-- L'ORTO DEL NONNO: i pomodori sulle canne, l'annaffiatoio, il pero
-------------------------------------------------------------------------------
S.orto = {
  init = function(s)
    s.nonno = D.figura(70, 56, { s = 1.25, l = 3, dark = true, pose = "dig", speed = 3, on_step = H.steps("erba", 0.25) })
    s.fig = D.figura(30, 56, { s = 1.0, l = 3, dark = true, child = true, pose = "stand", speed = 4, on_step = H.steps("erba", 0.2) })
    s.water = D.parts(40)
    s.tree = 0
  end,
  update = function(s, dt, t)
    think(s.nonno, function() return pick({ { { "pose", "dig", R(6, 10) } }, { { "pose", "stand", 2 }, { "pose", "talk", 3 } }, { { "walk", R(60, 90), 3 }, { "pose", "bend", 5 } } }) end)
    think(s.fig, function() return pick({ { { "walk", R(20, 40), 4 }, { "pose", "bend", 4 } }, { { "walk", 56, 4 }, { "face", 1 }, { "pose", "stand", 5 } }, { { "pose", "sit_ground", 6 } } }) end)
    s.nonno:update(dt); s.fig:update(dt)
    if s.fig.cur.lean > 40 then
      local hx, hy = s.fig.hand[1], s.fig.hand[2]
      if random() < 0.6 then D.spawn(s.water, { x = hx + 2, y = hy + 1, vx = R(4, 8), vy = R(0, 4), life = 0.8 }) end
    end
    D.parts_update(s.water, dt, function(p, d) p.vy = p.vy + 40 * d end)
  end,
  draw = function(s, t)
    local lu, w = mac("luce"), mac("vento")
    D.gradient(0, 34, 9 + lu * 3, 12 + lu * 2)
    D.circle(20, 10, 5, 15)
    D.rect(0, 34, 128, 30, 6)
    -- il pero
    D.tree(110, 50, 34, 4, 17, sin(t * 0.7) * (0.5 + w * 2))
    for i = 0, 4 do D.px(104 + i * 3, 30 + (i % 2) * 3, 12) end
    -- le canne coi pomodori
    for i = 0, 5 do
      local x = 48 + i * 9
      D.line(x, 52, x + sin(t + i) * w, 30, 9)
      for k = 0, 2 do D.circle(x + 1 + sin(t * 1.2 + i + k) * w, 36 + k * 5, 2, 4); if (i + k) % 2 == 0 then D.circle(x + 2, 39 + k * 5, 1.2, 12) end end
    end
    -- le file di terra
    for y = 52, 62, 3 do D.line(0, y, 127, y, 4) end
    -- l'annaffiatoio di latta, la zappa al pero
    D.rect(16, 50, 6, 5, 9); D.line(22, 51, 25, 48, 9)
    D.line(102, 52, 106, 30, 5)
    for _, p in ipairs(s.water.list) do D.px(p.x, p.y, 13) end
    s.nonno:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL FRANTOIO: le macine, l'olio verde, il pane abbrustolito
-------------------------------------------------------------------------------
S.frantoio = {
  init = function(s)
    s.nonno = D.figura(88, 58, { s = KS, l = 4, dark = true, pose = "stand", speed = 3 })
    s.fig = D.figura(104, 58, { s = KS * 0.72, l = 9, child = true, pose = "stand", face = -1 })
    s.ang = 0
    s.smoke = D.parts(30)
    s.oil = 0
  end,
  update = function(s, dt, t)
    s.ang = s.ang + dt * 0.4
    s.oil = (s.oil + dt * 3) % 6
    think(s.nonno, function() return pick({ { { "pose", "stand", R(5, 8) } }, { { "pose", "carry", 3 }, { "fn", function() s.fig:act({ { "pose", "reach_up", 2 }, { "pose", "carry", 4 } }) end }, { "pose", "talk", 4 } }, { { "pose", "bend", 4 } } }) end)
    think(s.fig, function() return pick({ { { "pose", "stand", R(5, 8) } }, { { "pose", "look_up", 4 } } }) end)
    s.nonno:update(dt); s.fig:update(dt)
    D.smoke_update(s.smoke, dt, 22, 30, 2 + mac("fuoco") * 3, t, 0.6)
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    K.room({ wall = 2, fy = 58, floor = "pietra", floor_l = 2, ceil = 4 }, t)
    -- il camino con la brace e il pane
    D.rect(10, 30, 26, 28, 3); D.rect(14, 40, 18, 18, 0)
    D.fire(23, 57, 6 + fu * 4, 8 + fu * 6, t, 14)
    D.rect(16, 46, 14, 1, 5); D.rect(18, 44, 4, 2, 9); D.rect(24, 44, 4, 2, 9)
    D.smoke_draw(s.smoke, 4)
    -- la macina di pietra che gira
    D.rect(44, 46, 34, 12, 4); D.rect(43, 45, 36, 2, 6)
    local x = 61 + cos(s.ang) * 10
    local w = 10 * abs(sin(s.ang)) + 3
    D.rect(x - w / 2, 30, w, 15, 7); D.rect(x - 1, 26, 2, 4, 5)
    D.line(61, 26, 61, 8, 4)
    -- l'olio verde che cade nel recipiente
    D.rect(80, 52, 6, 6, 5)
    D.line(83, 46, 83, 52, 11)
    D.px(83, 46 + s.oil, 14)
    -- i sacchi di juta
    for i = 0, 2 do D.poly({ 112 + i * 5, 58, 118 + i * 5, 58, 117 + i * 5, 48, 113 + i * 5, 48 }, 5 + (i % 2)) end
    s.nonno:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- RISVEGLIARSI: in macchina, di notte, la testa contro il finestrino
-------------------------------------------------------------------------------
S.risveglio = {
  init = function(s)
    s.off = 0
    s.lights = {}
    for i = 1, 6 do s.lights[i] = R(0, 300) end
    s.lid = 0
    s.blink = 0
  end,
  update = function(s, dt, t)
    s.off = s.off + dt * 50
    s.blink = s.blink + dt
    local cyc = s.blink % 20
    s.lid = cyc < 14 and min(1, cyc / 10) or max(0, 1 - (cyc - 14) / 1.5)
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.rect(0, 0, 128, 64, 0)
    -- il finestrino posteriore: le luci che scorrono
    for _, L in ipairs(s.lights) do
      local x = (L - s.off) % 300 - 40
      if x > 0 and x < 128 then D.rect(x, 14, 2, 2, 12); D.line(x - 6, 15, x, 15, 6) end
    end
    for i = 0, 6 do local x = (i * 22 - s.off * 0.4) % 150 - 10; D.line(x, 30, x + 1, 22, 2) end
    -- l'interno della macchina, i sedili, la sagoma di chi guida
    D.rect(0, 30, 128, 34, 1)
    D.rect(60, 18, 10, 30, 2); D.circle(65, 18, 5, 2)
    D.circle(100, 24, 4, 2); D.rect(95, 28, 12, 20, 2)
    -- la tua testa contro il vetro, di profilo, gli occhi che si chiudono
    D.circle(22, 40, 7, 3); D.circle(20, 37, 6, 2)
    D.rect(14, 46, 18, 18, 3)
    local lid = s.lid
    D.line(26, 39, 28, 39 + lid * 0.8, 9)
    -- quando gli occhi si chiudono, il buio sale dal basso
    if lid > 0.5 then
      local k = (lid - 0.5) * 2
      D.rect(0, 64 - k * 64, 128, k * 64, 0)
    end
  end,
}

-------------------------------------------------------------------------------
-- LA PERIFERIA: i palazzoni, il campetto, il lampione che sfarfalla
-------------------------------------------------------------------------------
S.periferia = {
  init = function(s)
    s.fig = D.figura(70, 56, { s = 1.15, l = 3, dark = true, pose = "stand", speed = 4, on_step = H.steps("pietra", 0.3) })
    s.ball = { x = 40, v = 0 }
    s.dog = 0
    s.win = {}
    for i = 1, 40 do s.win[i] = random() < 0.4 end
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "walk", s.ball.x + 4, 4 }, { "pose", "throw", 0.5 }, { "fn", function() s.ball.v = R(-30, 30) end }, { "pose", "stand", 4 } } end
      if r < 0.7 then return { { "pose", "sit_ground", R(6, 10) } } end
      return { { "walk", R(30, 100), 3 }, { "pose", "look_up", 4 } }
    end)
    s.fig:update(dt)
    s.ball.x = s.ball.x + s.ball.v * dt
    s.ball.v = s.ball.v * (1 - dt * 0.8)
    if s.ball.x < 8 or s.ball.x > 120 then s.ball.v = -s.ball.v; s.ball.x = max(8, min(120, s.ball.x)) end
    s.dog = s.dog - dt
    if s.dog < 0 then s.dog = R(10, 30); S.env.sfx("drop", 260, 0.02, 0.12, 0.7, 0.3, 0.001) end
    if random() < dt * 0.1 then s.win[random(40)] = random() < 0.5 end
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.gradient(0, 40, 1, 4 - nt * 2)
    -- i palazzoni uguali
    for b = 0, 3 do
      local x = b * 32 + 2
      D.rect(x, 6, 26, 36, 2)
      for r = 0, 4 do for c = 0, 3 do
        local i = b * 10 + r * 2 + c % 2 + 1
        D.rect(x + 3 + c * 6, 9 + r * 7, 3, 4, s.win[(i % 40) + 1] and 10 or 1)
      end end
    end
    -- il campetto di cemento, la porta senza rete
    D.rect(0, 42, 128, 22, 4)
    D.line(0, 50, 127, 50, 6)
    D.rect(6, 36, 1, 14, 8); D.rect(6, 36, 12, 1, 8); D.rect(18, 36, 1, 14, 8)
    -- il lampione che sfarfalla
    local on = D.noise(t * 3) > 0.25
    D.rect(108, 20, 1, 30, 5); D.rect(104, 19, 6, 2, 6)
    if on then D.px(106, 21, 15); D.poly({ 104, 22, 108, 22, 116, 50, 96, 50 }, 5) end
    D.circle(s.ball.x, 53, 1.6, 12)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL CENTRO DI TUTTO: la gente che corre, i treni, tu fermo in mezzo
-------------------------------------------------------------------------------
S.centro = {
  init = function(s)
    s.fig = D.figura(64, 56, { s = 1.25, l = 13, pose = "stand" })
    s.people = {}
    for i = 1, 12 do s.people[i] = { x = R(0, 128), y = R(46, 60), v = R(10, 30) * pick({ -1, 1 }) } end
    s.stop = 0
    s.train = -100
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "stand", R(6, 10) } }, { { "pose", "look_up", 4 } }, { { "pose", "arms_open", 4 }, { "pose", "stand", 2 } } }) end)
    s.fig:update(dt)
    if s.stop <= 0 and random() < dt * 0.02 then s.stop = 3 end
    s.stop = max(0, s.stop - dt)
    local sp = (s.stop > 0 and 0 or 1) * (0.6 + mac("tempo"))
    for _, p in ipairs(s.people) do p.x = p.x + p.v * dt * sp; if p.x > 134 then p.x = -6 elseif p.x < -6 then p.x = 134 end end
    s.train = s.train + dt * 60 * sp
    if s.train > 240 then s.train = -120 end
  end,
  draw = function(s, t)
    local fo = mac("folla")
    D.gradient(0, 28, 3, 6)
    D.rect(0, 28, 128, 36, 4)
    -- la stazione, le strade che arrivano da ogni parte
    for i = 0, 7 do local a = i / 8 * pi * 2; D.line(64, 46, 64 + cos(a) * 90, 46 + sin(a) * 40, 6) end
    D.rect(0, 22, 128, 4, 5)
    for i = 0, 5 do local x = s.train + i * 20; D.rect(x, 16, 18, 6, 7); D.rect(x + 2, 17, 4, 2, 13); D.rect(x + 10, 17, 4, 2, 13) end
    D.rect(0, 26, 128, 2, 8)
    local n = floor(4 + fo * 8)
    for i = 1, n do
      local p = s.people[i]
      local look = s.stop > 0
      D.circle(p.x, p.y - 8, 1.3, look and 12 or 9)
      D.rect(p.x - 1, p.y - 7, 2, 5, look and 11 or 8)
      D.line(p.x, p.y - 2, p.x + (look and 0 or sin(t * 10 + i)), p.y, 8)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA NOTTE DI CAPODANNO: i fuochi riflessi nelle finestre, la piazza
-------------------------------------------------------------------------------
S.capodanno = {
  init = function(s)
    s.fig = D.figura(34, 56, { s = 1.2, l = 3, dark = true, pose = "look_up" })
    s.fw = {}
    s.couple = D.figura(92, 56, { s = 1.1, l = 3, dark = true, pose = "hug", face = -1 })
    s.couple2 = D.figura(97, 56, { s = 1.1, l = 3, dark = true, pose = "hug", face = 1, dress = true })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "look_up", R(6, 10) } }, { { "pose", "stand", 3 }, { "pose", "look_up", 4 } } }) end)
    s.fig:update(dt); s.couple:update(dt); s.couple2:update(dt)
    if random() < dt * (0.9 + mac("folla") * 1.2) then
      local x, y = R(20, 110), R(8, 26)
      local n = random(10, 18)
      local fw = { x = x, y = y, k = 0, n = n, l = pick({ 11, 13, 15 }) }
      s.fw[#s.fw + 1] = fw
      S.env.sfx("drop", 120, 0.03, 0.3, (x - 64) / 64, 0.2, 0.001)
    end
    for i = #s.fw, 1, -1 do local f = s.fw[i]; f.k = f.k + dt * 0.6; if f.k > 1 then table.remove(s.fw, i) end end
  end,
  draw = function(s, t)
    D.gradient(0, 56, 0, 2)
    s.stars = s.stars or D.stars_gen(30, 3, 0, 24)
    D.stars(s.stars, t, 0.5)
    local flash = 0
    for _, f in ipairs(s.fw) do
      local r = f.k * 12
      for i = 1, f.n do
        local a = i / f.n * pi * 2
        local x, y = f.x + cos(a) * r, f.y + sin(a) * r + f.k * f.k * 4
        D.px(x, y, f.l * (1 - f.k)); D.px(x - cos(a), y - sin(a), f.l * 0.5 * (1 - f.k))
      end
      flash = max(flash, (1 - f.k) * 3)
    end
    -- i palazzi della piazza, i fuochi riflessi nelle finestre
    D.rect(0, 26, 40, 30, 3 + flash * 0.5); D.rect(88, 22, 40, 34, 3 + flash * 0.5)
    D.rect(46, 30, 8, 26, 4); D.poly({ 45, 30, 55, 30, 50, 24 }, 4)
    for r = 0, 2 do for c = 0, 3 do
      D.rect(4 + c * 9, 30 + r * 8, 4, 5, ((r + c) % 3 == 0) and 10 or (2 + flash * 2))
      D.rect(92 + c * 9, 26 + r * 9, 4, 5, ((r * c) % 4 == 1) and 10 or (2 + flash * 2))
    end end
    D.rect(0, 56, 128, 8, 4)
    -- il lampione della piazza
    D.rect(70, 34, 1, 22, 6); D.rect(67, 33, 7, 2, 8); D.px(70, 35, 15)
    s.fig:draw(); s.couple:draw(); s.couple2:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA NEVE SUL PAESE: il paese muto, il campanile col cappello, le impronte
-------------------------------------------------------------------------------
S.neve_paese = {
  init = function(s)
    s.snow = D.parts(120)
    s.fig = D.figura(-6, 56, { s = 1.15, l = 2, dark = true, speed = 3, on_step = function(f) S.env.step("neve", pan(f.x), 0.3); s.prints[#s.prints + 1] = f.x end })
    s.prints = {}
    s.nonno = D.figura(100, 56, { s = 1.2, l = 2, dark = true, pose = "shovel" })
  end,
  update = function(s, dt, t)
    D.snow_update(s.snow, dt, 1.5 + mac("silenzio") * 2, 64, -2, t)
    think(s.fig, function() return { { "walk", R(40, 70), 3 }, { "pose", "look_up", 4 }, { "walk", 140, 3 }, { "fn", function(f) f.x = -6; s.prints = {} end }, { "wait", R(4, 9) } } end)
    think(s.nonno, function() return { { "pose", "shovel", 1.2 }, { "pose", "stand", 0.8 } } end)
    s.fig:update(dt); s.nonno:update(dt)
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.gradient(0, 30, 3 - nt * 2, 6 - nt * 2)
    -- le case, i tetti bianchi, le finestre accese
    for i = 0, 5 do
      local x = i * 22 - 4
      local h = 16 + (i * 5) % 9
      D.rect(x, 46 - h, 20, h, 4)
      D.poly({ x - 1, 46 - h, x + 21, 46 - h, x + 10, 40 - h }, 13)
      D.rect(x + 7, 50 - h, 4, 4, (i % 2 == 0) and 11 or 2)
    end
    -- il campanile col cappello di neve
    D.rect(58, 6, 10, 40, 5); D.poly({ 56, 8, 70, 8, 63, 0 }, 14); D.rect(61, 12, 4, 5, 2)
    -- le macchine sepolte, gobbe bianche
    D.rect(0, 46, 128, 18, 13)
    for _, x in ipairs({ 20, 78 }) do D.circle(x, 48, 6, 14); D.rect(x - 8, 48, 16, 4, 14) end
    for _, x in ipairs(s.prints) do D.px(x, 58, 8) end
    s.nonno:draw(); s.fig:draw()
    D.snow_draw(s.snow, 15)
  end,
}

-------------------------------------------------------------------------------
-- IL CIMITERO MONUMENTALE: i viali di cipressi, l'angelo senza una mano
-------------------------------------------------------------------------------
S.monumentale = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = 1.15, l = 2, dark = true, speed = 2.5, on_step = H.steps("ghiaia", 0.3) })
    s.leaves = D.parts(20)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 54, 2.5 }, { "pose", "look_up", 5 }, { "walk", 96, 2.5 }, { "pose", "head_down", 4 }, { "walk", 140, 2.5 }, { "fn", function(f) f.x = -6 end }, { "wait", 4 } } end)
    s.fig:update(dt)
    if random() < dt * (0.5 + mac("vento") * 2) then D.spawn(s.leaves, { x = R(0, 128), y = 0, vx = R(2, 8), vy = R(4, 8), life = 10, ph = R(0, 6) }) end
    D.parts_update(s.leaves, dt)
  end,
  draw = function(s, t)
    local w = mac("vento")
    D.gradient(0, 40, 6, 9)
    -- il viale in prospettiva coi cipressi
    D.poly({ 56, 40, 72, 40, 128, 64, 0, 64 }, 5)
    for i = 0, 5 do
      local d = i / 6
      local xl, xr = 52 - (1 - d) * 50, 76 + (1 - d) * 50
      local h = 8 + (1 - d) * 32
      D.cypress(xl, 40 + (1 - d) * 24, h, 2, sin(t * 0.6 + i) * w)
      D.cypress(xr, 40 + (1 - d) * 24, h, 2, sin(t * 0.6 + i + 1) * w)
    end
    -- la cappella di famiglia con la porta di ferro, l'angelo
    D.rect(56, 26, 16, 14, 7); D.poly({ 54, 26, 74, 26, 64, 20 }, 8)
    D.rect(61, 31, 6, 9, 2); for x = 62, 66, 2 do D.line(x, 31, x, 39, 6) end
    D.circle(40, 38, 1.5, 10); D.rect(39, 40, 3, 6, 10); D.line(38, 41, 34, 38, 10); D.line(41, 41, 46, 34, 10)
    D.poly({ 36, 40, 38, 40, 34, 34 }, 9); D.poly({ 42, 40, 44, 40, 46, 35 }, 9)
    D.rect(37, 46, 7, 4, 8)
    for _, p in ipairs(s.leaves.list) do D.px(p.x + sin(t * 2 + p.ph) * 3, p.y, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CAPPELLA DEI FUNERALI: le vetrate che tremano nella pioggia, Massimo
-------------------------------------------------------------------------------
S.cappella_funebre = {
  init = function(s)
    s.fig = D.figura(54, 58, { s = KS, l = 9, pose = "sit", face = 1 })
    s.flash = 0
    s.talk = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit", R(6, 10) } }, { { "pose", "talk", R(4, 7) }, { "fn", function() s.talk = 5 end }, { "pose", "sit", 3 } }, { { "pose", "pray", R(5, 8) } }, { { "pose", "sit_slump", 6 } } }) end)
    s.fig:update(dt)
    if random() < dt * mac("pioggia") * 0.04 then s.flash = 1; S.env.sfx("drop", 70, 0.05, 1.2, -0.3, 0.1, 0.01) end
    s.flash = max(0, s.flash - dt * 2)
    s.talk = max(0, s.talk - dt)
  end,
  draw = function(s, t)
    local pr = mac("pioggia")
    D.rect(0, 0, 128, 64, 1)
    -- le vetrate colorate che tremano nei piombi
    for i = 0, 2 do
      local x = 14 + i * 40
      local sh = sin(t * 20 + i) * pr * 0.6
      screen.level(D.lv(3)); screen.move(x, 34); screen.line(x, 14); screen.curve(x, 6, x + 16, 6, x + 16, 14); screen.line(x + 16, 34); screen.close(); screen.fill()
      for k = 0, 5 do
        local px, py = x + 2 + (k % 3) * 5 + sh, 14 + floor(k / 3) * 9
        D.rect(px, py, 4, 7, 6 + ((k + i) % 4) * 2 + s.flash * 4)
      end
      D.line(x + 8 + sh, 10, x + 8 + sh, 34, 1)
    end
    -- le gocce sul vetro
    for i = 0, 10 do local x = (i * 37) % 128; local y = (t * 20 + i * 13) % 30 + 6; D.px(x, y, 4) end
    -- le panche, l'altare
    for r = 0, 1 do D.rect(10 + r * 6, 48 + r * 5, 108, 2, 3); D.rect(10 + r * 6, 42 + r * 5, 2, 8, 3) end
    D.rect(104, 36, 18, 22, 4); D.rect(102, 35, 22, 2, 6)
    D.candle(108, 35, t, 9, 4, 5); D.candle(118, 35, t + 1, 9, 4, 5)
    s.fig:draw()
    -- quando parla a Massimo, le parole salgono piano
    if s.talk > 0 then for i = 1, 3 do local k = ((t * 0.5 + i * 0.3) % 1); D.px(s.fig.x + 6 + k * 10, s.fig.y - 20 - k * 12, 7 * (1 - k)) end end
    if s.flash > 0 then D.rect(0, 0, 128, 4, s.flash * 8) end
  end,
}

-------------------------------------------------------------------------------
-- LA CITTÀ ABBANDONATA: il semaforo per nessuno, l'imposta che sbatte
-------------------------------------------------------------------------------
S.citta_abbandonata = {
  init = function(s)
    s.fig = D.figura(-6, 56, { s = 1.15, l = 3, dark = true, speed = 3, on_step = H.steps("pietra", 0.3) })
    s.bang = 0
    s.light = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(40, 70), 3 }, { "pose", "stand", 4 }, { "pose", "look_up", 3 }, { "walk", 140, 3 }, { "fn", function(f) f.x = -6 end }, { "wait", R(5, 10) } } end)
    s.fig:update(dt)
    s.light = (s.light + dt) % 12
    local w = mac("vento")
    s.bang = s.bang + dt * (0.6 + w * 2)
    if s.bang > 4 then s.bang = 0; S.env.sfx("step", 300, 0.05, 0.08, 0.6, 0.5, 0) end
  end,
  draw = function(s, t)
    D.gradient(0, 30, 6, 8)
    -- i negozi con le serrande abbassate
    for i = 0, 3 do
      local x = i * 32
      D.rect(x, 10, 30, 44, 4)
      D.rect(x + 3, 34, 24, 18, 6)
      for y = 35, 51, 2 do D.line(x + 3, y, x + 26, y, 5) end
      D.window(x + 6, 16, 7, 9, 3); D.window(x + 17, 16, 7, 9, 3)
    end
    -- l'imposta che sbatte
    local a = abs(sin(s.bang * pi / 4))
    D.rect(81, 16, 7 * a, 9, 6)
    -- l'erba che spacca l'asfalto
    D.rect(0, 54, 128, 10, 3)
    for i = 0, 12 do local x = i * 10 + 4; D.line(x, 58, x - 1, 54, 6); D.line(x + 1, 58, x + 2, 55, 6) end
    D.line(0, 60, 40, 58, 1); D.line(40, 58, 70, 61, 1)
    -- il semaforo che cambia colore per nessuno
    D.rect(112, 22, 1, 32, 4); D.rect(109, 14, 7, 12, 2)
    local c = s.light < 5 and 1 or (s.light < 6 and 2 or 3)
    D.circle(112.5, 16.5, 1.2, c == 3 and 13 or 3); D.circle(112.5, 20, 1.2, c == 2 and 13 or 3); D.circle(112.5, 23.5, 1.2, c == 1 and 13 or 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LO STUDIO CINEMATOGRAFICO: i riflettori, la sedia col nome, la claquette
-------------------------------------------------------------------------------
S.studio_cine = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 3, dark = true, speed = 3, on_step = H.steps("legno", 0.3) })
    s.spot = 0
    s.motes = D.parts(30)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "walk", R(54, 70), 3 }, { "pose", "look_up", 5 }, { "pose", "arms_open", 4 } }, { { "walk", R(20, 40), 3 }, { "pose", "bend", 3 }, { "pose", "stand", 3 } } }) end)
    s.fig:update(dt)
    if s.spot <= 0 and random() < dt * 0.03 then s.spot = 8 end
    s.spot = max(0, s.spot - dt)
    D.motes_update(s.motes, dt, 3, { 50, 10, 30, 46 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 1)
    -- le travi, i riflettori appesi
    for x = 0, 127, 16 do D.line(x, 2, x + 8, 10, 3); D.line(x + 16, 2, x + 8, 10, 3) end
    D.line(0, 2, 127, 2, 4); D.line(0, 10, 127, 10, 3)
    for i = 0, 3 do local x = 14 + i * 32; D.line(x, 10, x, 14, 4); D.rect(x - 3, 14, 6, 5, 5) end
    -- il riflettore che si accende da solo, su nessuno
    local on = s.spot > 0
    local a = on and min(1, s.spot / 1, (8 - s.spot) / 1) or 0
    if a > 0 then
      D.poly({ 76, 19, 82, 19, 92, 58, 64, 58 }, 3 + a * 4 + lu * 2)
      D.motes_draw(s.motes, 6 + a * 8)
      D.rect(76, 14, 6, 5, 13)
    end
    -- i fondali appoggiati ai muri, la sedia di tela, la claquette
    D.rect(100, 22, 24, 36, 3); D.line(100, 22, 124, 58, 2); D.house(104, 50, 10, 8, 4, 3)
    D.rect(8, 44, 10, 2, 5); D.rect(8, 40, 10, 2, 6); D.line(9, 46, 15, 58, 5); D.line(15, 46, 9, 58, 5)
    txt(8, 38, "REGIA", 4)
    D.poly({ 30, 58, 40, 58, 40, 54, 30, 54 }, 9); D.poly({ 30, 54, 40, 52, 40, 50, 30, 52 }, 6)
    D.rect(0, 58, 128, 6, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL SET ABBANDONATO: le facciate del West, il saloon vuoto, il cespuglio
-------------------------------------------------------------------------------
S.set_film = {
  init = function(s)
    s.fig = D.figura(-6, 56, { s = 1.15, l = 2, dark = true, speed = 3, on_step = H.steps("sabbia", 0.3) })
    s.tw = -20
    s.door = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 58, 3 }, { "pose", "stand", 3 }, { "fn", function() s.door = 1 end }, { "walk", 66, 2 }, { "pose", "look_up", 4 },
      { "walk", 140, 3 }, { "fn", function(f) f.x = -6; s.door = 0 end }, { "wait", R(4, 8) } } end)
    s.fig:update(dt)
    s.tw = s.tw + dt * (8 + mac("vento") * 20)
    if s.tw > 150 then s.tw = -20 end
  end,
  draw = function(s, t)
    local w = mac("vento")
    D.gradient(0, 40, 9, 13)
    D.circle(104, 14, 6, 15)
    -- le facciate senza niente dietro: si vedono le travi di sostegno
    local fronts = { { 4, 20, 26 }, { 34, 14, 34 }, { 72, 22, 24 }, { 100, 18, 26 } }
    for i, f in ipairs(fronts) do
      local x, y, wd = f[1], f[2], f[3]
      D.rect(x, y, wd, 56 - y, 5)
      D.rect(x, y, wd, 3, 7)
      D.rect(x + 4, y + 8, 6, 8, 2); D.rect(x + wd - 10, y + 8, 6, 8, 2)
      D.line(x + wd, y + 4, x + wd + 6, 56, 3)
    end
    txt(40, 22, "SALOON", 10)
    -- le porte a battente del saloon: dietro, niente
    local sw = sin(t * 3) * (s.door > 0 and 2 or 0.4 + w)
    D.rect(46, 40, 10, 16, 13)
    D.rect(46, 42, 4 + sw, 8, 4); D.rect(52 - sw, 42, 4 + sw, 8, 4)
    D.rect(0, 56, 128, 8, 10)
    -- il cespuglio che rotola
    local x = s.tw
    local r = 3
    D.circle(x, 52, r, 6, true)
    D.line(x - 2 * cos(t * 6), 52 - 2 * sin(t * 6), x + 2 * cos(t * 6), 52 + 2 * sin(t * 6), 6)
    s.fig:draw()
  end,
}

end
