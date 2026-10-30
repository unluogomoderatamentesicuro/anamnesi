-- ANAMNESI · scene dei ricordi (v4): le case, la mente, l'abisso
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

D.POSE.hands_face = { lean = 26, nod = 40, ua1 = 40, ua2 = 34, fa1 = 160, fa2 = 150, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.scream = { lean = -10, nod = -30, ua1 = 30, ua2 = 26, fa1 = 170, fa2 = 165, th1 = 6, th2 = -6, sh1 = 0, sh2 = -2, hy = 7.0, rot = 0 }
D.POSE.handle = { lean = 4, nod = 6, ua1 = 75, ua2 = 6, fa1 = 80, fa2 = 2, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.torch = { lean = 6, nod = 10, ua1 = 80, ua2 = 10, fa1 = 88, fa2 = 4, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(D.tr(s)) else screen.text(D.tr(s)) end
end

-- un letto di ferro visto di lato
local function branda(x, y, l, mat)
  D.rect(x, y, 22, 2, l)
  D.rect(x, y - 6, 1, 14, l); D.rect(x + 21, y - 4, 1, 12, l)
  D.line(x, y - 6, x + 3, y - 6, l); D.line(x + 1, y + 2, x + 1, y + 8, l); D.line(x + 20, y + 2, x + 20, y + 8, l)
  if mat then D.rect(x + 1, y - 2, 20, 2, mat); D.rect(x + 2, y - 4, 5, 2, mat + 2) end
end

-------------------------------------------------------------------------------
-- L'ORFANOTROFIO: le brande in fila, la finestra che sbatte, le tacche sul muro
-------------------------------------------------------------------------------
S.orfanotrofio = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, child = true, speed = 3, on_step = H.steps("piastrelle", 0.25) })
    s.bang = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 40, 3 }, { "pose", "look_up", 3 }, { "walk", 98, 3 }, { "face", 1 }, { "pose", "trace", 4 }, { "pose", "head_down", 4 },
      { "walk", -10, 3 }, { "wait", R(4, 8) } } end)
    s.fig:update(dt)
    s.bang = s.bang + dt * (0.5 + mac("vento") * 1.5)
    if s.bang > 3 then s.bang = 0; S.env.sfx("step", 400, 0.05, 0.06, -0.6, 0.6, 0) end
  end,
  draw = function(s, t)
    K.room({ wall = 4, fy = 58, floor = "piastrelle", floor_l = 3, paper = "piastrelle", tile_y = 40, ceil = 4 }, t)
    -- la finestra che sbatte da sola
    local a = abs(sin(s.bang * pi / 3))
    K.window(10, 10, 20, 22, K.views.day, t, s, 6)
    D.rect(30, 10, 8 * a, 22, 5)
    -- le brande in fila
    for i = 0, 3 do branda(14 + i * 26, 50, 6, 8) end
    -- le tacche a matita delle altezze, con i nomi
    for i = 0, 4 do
      local y = 22 + i * 3 + (i % 2)
      D.line(104, y, 110, y, 2)
    end
    D.line(107, 20, 107, 38, 6)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL DORMITORIO: trenta letti nel buio, le voci sottovoce
-------------------------------------------------------------------------------
S.dormitorio = {
  init = function(s)
    s.words = D.parts(4)
    s.next = 3
    s.moon = 0
  end,
  update = function(s, dt, t)
    s.next = s.next - dt
    if s.next < 0 then
      s.next = R(6, 12)
      local w = H.lang() == 1 and { "e tu, quanti figli?", "tre", "una casa al mare", "un cane", "si chiamerà Luca", "domani viene" }
        or { "and you, how many kids?", "three", "a house by the sea", "a dog", "he'll be called Luca", "tomorrow she'll come" }
      D.spawn(s.words, { x = R(10, 80), y = R(26, 40), vx = 0, vy = -0.6, life = 6, w = pick(w), l = 5 + mac("voci") * 5 })
    end
    D.float_words_update(s.words, dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- la luna dalla finestra alta fa un rettangolo sul pavimento
    D.rect(54, 4, 18, 14, 2); D.line(63, 4, 63, 17, 1)
    D.poly({ 54, 18, 72, 18, 90, 58, 64, 58 }, 2)
    -- i letti in prospettiva, in fila verso il fondo
    for i = 6, 0, -1 do
      local d = i / 6
      local sc = 1 - d * 0.6
      local y = 58 - d * 20
      for side = -1, 1, 2 do
        local x = 64 + side * (24 + (1 - d) * 30) - 10 * sc
        D.rect(x, y - 4 * sc, 20 * sc, 3 * sc, 3 + (1 - d) * 3)
        D.rect(x, y - 9 * sc, 1, 9 * sc, 2 + (1 - d) * 2)
        local br = sin(t * 0.8 + i * 1.7 + side) * 0.5
        D.rect(x + 4 * sc, y - (6 + br) * sc, 13 * sc, 2 * sc, 4 + (1 - d) * 3)
      end
    end
    D.float_words_draw(s.words)
  end,
}

-------------------------------------------------------------------------------
-- IL REFETTORIO: tavoli lunghi, scodelle di latta, il pane passato di nascosto
-------------------------------------------------------------------------------
S.refettorio = {
  init = function(s)
    s.kids = {}
    for i = 1, 6 do s.kids[i] = D.figura(18 + i * 16, 58, { s = KS * 0.7, l = 6 + (i % 2), child = true, pose = "sit_read", face = (i % 2 == 0) and -1 or 1 }) end
    s.fig = s.kids[3]
    s.fig.l = 10
    s.bread = nil
    s.spoon = 0
  end,
  update = function(s, dt, t)
    for i, k in ipairs(s.kids) do
      think(k, function() return pick({ { { "pose", "sit_read", R(3, 6) } }, { { "pose", "sit", R(2, 4) } }, { { "pose", "head_down", 3 } } }) end)
      k:update(dt)
    end
    if not s.bread and random() < dt * 0.04 then s.bread = 0 end
    if s.bread then s.bread = s.bread + dt * 0.5; if s.bread > 1 then s.bread = nil end end
    s.spoon = s.spoon + dt
    if s.spoon > 1.5 then s.spoon = 0; S.env.sfx("bell", 2400 + random() * 400, 0.006, 0.08, R(-0.5, 0.5), 0.8, 0.001) end
  end,
  draw = function(s, t)
    K.room({ wall = 4, fy = 58, floor = "piastrelle", floor_l = 3, paper = "piastrelle", tile_y = 36, ceil = 4 }, t)
    D.cross(64, 22, 10, 7)
    K.window(14, 10, 14, 16, K.views.day, t, s, 6); K.window(100, 10, 14, 16, K.views.day, t, s, 6)
    -- il tavolo lungo, le scodelle in fila, le panche
    D.rect(8, 44, 112, 2, 6); D.rect(10, 46, 2, 12, 5); D.rect(116, 46, 2, 12, 5)
    for i = 1, 6 do local x = 20 + i * 16; D.rect(x - 3, 42, 6, 2, 10); D.px(x, 41, 12) end
    for _, k in ipairs(s.kids) do k:draw() end
    D.rect(8, 50, 112, 2, 4)
    -- il pane che passa di mano sotto il tavolo
    if s.bread then local x = 50 + s.bread * 16; D.rect(x, 47, 3, 2, 12) end
  end,
}

-------------------------------------------------------------------------------
-- IL LAVATOIO: le vasche di pietra, l'acqua che gocciola, il sole sullo specchio
-------------------------------------------------------------------------------
S.lavatoio = {
  init = function(s)
    s.drops = {}
    for i = 1, 5 do s.drops[i] = { x = 18 + i * 20, y = R(28, 40), rip = 0, v = R(14, 24) } end
    s.fig = D.figura(-6, 58, { s = KS, l = 9, child = true, speed = 3, on_step = H.steps("pietra", 0.25) })
  end,
  update = function(s, dt, t)
    for _, d in ipairs(s.drops) do
      d.y = d.y + d.v * dt
      if d.y > 44 then d.y = 28; d.rip = 1; S.env.sfx("drop", 1300 + d.x * 4, 0.012, 0.15, pan(d.x), 0.5, 0.001) end
      d.rip = max(0, d.rip - dt)
    end
    think(s.fig, function() return { { "walk", R(40, 90), 3 }, { "pose", "bend", 4 }, { "pose", "stand", 2 }, { "pose", "trace", 3 }, { "walk", -10, 3 }, { "wait", R(4, 10) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 3, fy = 58, floor = "pietra", floor_l = 2, paper = "piastrelle", tile_y = 30, ceil = 4 }, t)
    -- lo specchio appannato col sole disegnato
    D.rect(52, 8, 24, 14, 6)
    screen.level(D.lv(10)); screen.circle(64, 15, 3); screen.stroke()
    for i = 0, 7 do local a = i / 8 * pi * 2; D.line(64 + cos(a) * 4, 15 + sin(a) * 4, 64 + cos(a) * 6, 15 + sin(a) * 6, 10) end
    -- le vasche, i rubinetti d'ottone, le gocce
    for i, d in ipairs(s.drops) do
      local x = d.x
      D.rect(x - 8, 44, 16, 8, 6); D.rect(x - 7, 44, 14, 2, 3)
      D.rect(x - 1, 24, 3, 2, 11); D.line(x, 26, x, 28, 11)
      D.px(x, d.y, 12)
      if d.rip > 0 then D.line(x - (1 - d.rip) * 5, 45, x + (1 - d.rip) * 5, 45, 10 * d.rip) end
    end
    D.rect(0, 52, 128, 6, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'INFERMERIA: le lenzuola bianche, la mano sulla fronte, il brodo
-------------------------------------------------------------------------------
S.infermeria = {
  init = function(s)
    s.fig = D.figura(26, 44, { s = KS, l = 9, child = true, pose = "lie" })
    s.suora = D.figura(100, 58, { s = KS, l = 3, dark = true, dress = true, speed = 2.5, on_step = H.steps("piastrelle", 0.2) })
    s.hand = 0
    s.steam = D.parts(20)
  end,
  update = function(s, dt, t)
    think(s.suora, function() return { { "wait", R(6, 12) }, { "walk", 52, 2.5 }, { "face", -1 }, { "pose", "reach_up", 0.5 }, { "fn", function() s.hand = 5 end }, { "pose", "bend", 5 },
      { "pose", "stand", 1 }, { "walk", 100, 2.5 } } end)
    s.suora:update(dt); s.fig:update(dt)
    s.hand = max(0, s.hand - dt)
    D.smoke_update(s.steam, dt, 66, 41, 1.5, t, 0.2)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    K.room({ wall = 6 + warm, fy = 58, floor = "piastrelle", floor_l = 5, paper = "piastrelle", tile_y = 34, ceil = 4 }, t)
    -- i due lettini bianchi
    D.rect(10, 46, 38, 3, 12); D.rect(12, 49, 2, 9, 7); D.rect(44, 49, 2, 9, 7); D.rect(10, 38, 2, 10, 8)
    D.rect(70, 46, 30, 3, 12); D.rect(72, 49, 2, 9, 7); D.rect(96, 49, 2, 9, 7)
    -- l'armadietto di vetro con le bottigliette scure
    D.rect(106, 16, 18, 30, 8); D.rect(107, 17, 16, 28, 4)
    for r = 0, 2 do for c = 0, 3 do D.rect(108 + c * 4, 19 + r * 9, 2, 5, 1 + (c % 2)) end; D.line(107, 25 + r * 9, 122, 25 + r * 9, 8) end
    -- la tazza di brodo sul comodino
    D.rect(60, 44, 12, 14, 5); D.rect(63, 41, 6, 3, 11)
    D.smoke_draw(s.steam, 10)
    s.fig:draw()
    D.poly({ 22, 46, 48, 45, 48, 49, 22, 49 }, 13)
    s.suora:draw()
    if s.hand > 0 then D.circle(28, 36, 2, 12) end
  end,
}

-------------------------------------------------------------------------------
-- IL PARLATORIO: le sedie lungo il muro, la porta, l'orologio
-------------------------------------------------------------------------------
S.parlatorio = {
  init = function(s)
    s.kids = {}
    for i = 1, 5 do s.kids[i] = D.figura(14 + i * 14, 58, { s = KS * 0.7, l = 6, child = true, pose = "sit", face = 1 }) end
    s.fig = s.kids[5]
    s.fig.l = 10
    s.door = 0
    s.visit = nil
    s.vis = D.figura(124, 58, { s = KS, l = 3, dark = true, speed = 3 })
  end,
  update = function(s, dt, t)
    if s.door == 0 and random() < dt * 0.025 then s.door = 0.01; s.pick = random(1, 4) end
    if s.door > 0 then
      s.door = s.door + dt * 0.3
      if s.door > 0.3 and s.door < 0.34 then
        for _, k in ipairs(s.kids) do k:clear(); k:act({ { "pose", "look_up", 3 }, { "pose", "sit", 1 } }) end
        s.vis.x = 124; s.vis:clear(); s.vis:act({ { "walk", s.kids[s.pick].x + 10, 3 }, { "face", -1 }, { "pose", "hug", 4 }, { "walk", 140, 3 } })
      end
      if s.door > 3 then s.door = 0 end
    end
    for i, k in ipairs(s.kids) do
      think(k, function() return pick({ { { "pose", "sit", R(4, 8) } }, { { "pose", "head_down", 4 } }, { { "pose", "sit_think", 4 } } }) end)
      k:update(dt)
    end
    s.vis:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 4, fy = 58, floor = "piastrelle", floor_l = 3, ceil = 4 }, t)
    K.clock(64, 12, t * (0.5 + mac("tempo")), 5, true)
    -- la grata
    D.rect(84, 14, 16, 18, 1)
    for x = 85, 99, 3 do D.line(x, 14, x, 31, 6) end
    for y = 16, 30, 4 do D.line(84, y, 99, y, 6) end
    -- la porta da cui entravano i parenti
    local open = (s.door > 0) and min(1, s.door * 2, (3 - s.door)) or 0
    K.door(108, 58, open, 5, 13)
    for i, k in ipairs(s.kids) do K.chair(k.x, 58, 1, 4) end
    for _, k in ipairs(s.kids) do k:draw() end
    if s.vis.x < 122 then s.vis:draw() end
  end,
}

-------------------------------------------------------------------------------
-- LE SCALE DELL'ORFANOTROFIO: una sola luce, i gradini contati
-------------------------------------------------------------------------------
S.scale_orfano = {
  init = function(s)
    s.fig = D.figura(10, 58, { s = 1.2, l = 9, child = true, speed = 3, on_step = function(f) S.env.step("legno", 0, 0.35); s.n = s.n + 1 end,
      prop = function(x, y) D.candle(x, y + 1, s.t or 0, 7, 2, false) end })
    s.n = 30
    s.words = D.parts(4)
    s.t = 0
  end,
  update = function(s, dt, t)
    s.t = t
    local f = s.fig
    think(f, function() return { { "walk", 100, 3, 14 }, { "pose", "stand", 3 }, { "fn", function(g) g.x = 10; g.y = 58 end } } end)
    local o = s.n
    f:update(dt)
    if s.n ~= o and s.n % 1 == 0 then
      local w = H.lang() == 1 and { "trentuno", "trentadue", "trentatré", "trentaquattro", "trentacinque", "trentasei", "trentasette", "trentotto" }
        or { "thirty-one", "thirty-two", "thirty-three", "thirty-four", "thirty-five", "thirty-six", "thirty-seven", "thirty-eight" }
      if s.n % 3 == 0 then D.spawn(s.words, { x = f.x + 8, y = f.y - 22, vx = 0, vy = -1, life = 3, w = w[(s.n % 8) + 1], l = 6 }) end
    end
    f.cur.ua1 = max(f.cur.ua1, 50); f.cur.fa1 = max(f.cur.fa1, 80)
    D.float_words_update(s.words, dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local fx, fy = s.fig.x, s.fig.y - 10
    -- solo quello che tocca la luce della candela si vede
    for i = 0, 15 do
      local x = 6 + i * 6
      local y = 58 - i * 2.9
      local d = abs(x - fx) + abs(y - fy) * 0.5
      local l = max(0, 7 - d / 6)
      D.rect(x, y, 6, 64 - y, 1 + l * 0.4); D.line(x, y, x + 5, y, 2 + l)
    end
    s.fig:draw()
    D.float_words_draw(s.words)
  end,
}

-------------------------------------------------------------------------------
-- IL GIORNO DEL FUNERALE: tutti vestiti di scuro, la mano stretta, i fiori
-------------------------------------------------------------------------------
S.funerale = {
  init = function(s)
    s.fig = D.figura(40, 56, { s = 1.25, l = 9, pose = "head_down" })
    s.people = {}
    for i = 1, 6 do s.people[i] = D.figura(54 + i * 11, 56, { s = 1.2, l = 2, dark = true, face = -1, pose = "stand", dress = (i % 3 == 0), bun = (i % 3 == 0), speed = 2.5 }) end
    s.who = 1
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "head_down", R(6, 10) } }, { { "pose", "stand", 3 }, { "pose", "head_down", 4 } } }) end)
    s.fig:update(dt)
    local n = 2 + floor(mac("folla") * 4)
    for i, p in ipairs(s.people) do
      if i <= n then
        think(p, function()
          if i == s.who then
            return { { "walk", 50, 2.5 }, { "face", -1 }, { "pose", "handle", 3 }, { "pose", "talk", 2 }, { "fn", function() s.who = random(1, n) end }, { "walk", 54 + i * 11, 2.5 }, { "face", -1 } }
          end
          return { { "pose", pick({ "stand", "head_down" }), R(4, 8) } }
        end)
      end
      p:update(dt)
    end
  end,
  draw = function(s, t)
    D.gradient(0, 40, 6, 8)
    -- la chiesa, la porta aperta, i fiori
    D.rect(0, 6, 46, 50, 5); D.poly({ 0, 6, 46, 6, 23, 0 }, 6)
    D.rect(16, 28, 14, 28, 1); screen.level(D.lv(1)); screen.circle(23, 28, 7); screen.fill()
    D.rect(30, 50, 6, 6, 6); for k = 0, 4 do D.circle(31 + k, 49 - (k % 2) * 2, 1.4, 11 + (k % 2) * 3) end
    D.rect(0, 56, 128, 8, 4)
    local n = 2 + floor(mac("folla") * 4)
    for i, p in ipairs(s.people) do if i <= n then p:draw() end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA SIGNORA SOTTO IL VELO: due candele, lo specchio coperto, il rosario
-------------------------------------------------------------------------------
S.casa_velo = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, speed = 2, on_step = H.steps("legno", 0.15) })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 30, 2 }, { "pose", "head_down", 5 }, { "pose", "pray", R(6, 10) }, { "pose", "stand", 2 }, { "walk", -10, 2 }, { "wait", R(6, 10) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 2, paper = "fiori", ceil = 4 }, t)
    -- lo specchio coperto dal panno nero, l'orologio fermo
    D.rect(16, 12, 14, 18, 6); D.rect(15, 11, 16, 3, 0); D.poly({ 15, 13, 31, 13, 31, 26, 15, 30 }, 0)
    K.clock(98, 14, 0, 5)
    -- il letto, il velo bianco sopra il profilo
    D.rect(44, 46, 52, 4, 4); D.rect(44, 36, 3, 22, 5); D.rect(93, 40, 3, 18, 5)
    D.rect(46, 44, 8, 2, 9)
    screen.level(D.lv(12)); screen.move(50, 44); screen.curve(58, 40, 66, 41, 70, 42); screen.curve(78, 43, 86, 42, 92, 44); screen.line(92, 46); screen.line(48, 46); screen.close(); screen.fill()
    -- le due candele
    D.rect(42, 44, 3, 14, 3); D.candle(43.5, 44, t, 8, 3, 3 + fu * 5)
    D.rect(96, 44, 3, 14, 3); D.candle(97.5, 44, t + 1.3, 8, 3, 3 + fu * 5)
    -- le sedie in fila lungo il muro
    for i = 0, 2 do K.chair(106 + i * 8, 58, -1, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA VOCE CHE NON RICORDI: la segreteria, il nastro, la lucina rossa
-------------------------------------------------------------------------------
S.voce_persa = {
  init = function(s)
    s.fig = D.figura(46, 58, { s = KS, l = 9, pose = "sit_think", face = 1 })
    s.play = 0
    s.reel = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "sit_think", R(4, 8) }, { "pose", "reach_up", 0.6 }, { "fn", function() s.play = 9 end }, { "pose", "sit", 2 }, { "pose", "hands_face", 6 }, { "pose", "sit_think", 4 } } end)
    s.fig:update(dt)
    if s.play > 0 then s.play = s.play - dt; s.reel = s.reel + dt * 4 end
  end,
  draw = function(s, t)
    local ra = mac("radio")
    K.room({ wall = 3, fy = 58, floor = "moquette", floor_l = 2, paper = "righe", ceil = 4 }, t)
    K.window(96, 12, 20, 20, K.views.night, t, s, 4)
    -- il tavolino con la segreteria
    local ty = K.table(56, 58, 1.8, 4)
    D.rect(62, ty - 7, 18, 7, 6); D.rect(64, ty - 6, 14, 3, 2)
    for i = 0, 1 do
      local cx = 67 + i * 8
      D.circle(cx, ty - 4.5, 1.6, 8)
      D.line(cx, ty - 4.5, cx + cos(s.reel + i) * 1.4, ty - 4.5 + sin(s.reel + i) * 1.4, 2)
    end
    D.px(78, ty - 6, (s.play > 0 and floor(t * 3) % 2 == 0) and 15 or 7)
    -- la voce: un'onda che esce e si sfilaccia
    if s.play > 0 then
      local k = 1 - s.play / 9
      for x = 0, 40 do
        local amp = (sin(x * 0.5 - t * 6) * 2 + sin(x * 0.17 + t) * 1.5) * (1 - k) * (1 - x / 40)
        D.px(82 + x, 30 + amp, (10 + ra * 4) * (1 - x / 40))
      end
    end
    K.chair(46, 58, 1, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA MADRE CHE NON HAI VISTO: la lapide, la foto ovale, il fiore semplice
-------------------------------------------------------------------------------
S.madre = {
  init = function(s)
    s.fig = D.figura(-6, 56, { s = 1.25, l = 2, dark = true, speed = 2.5, on_step = H.steps("ghiaia", 0.3),
      prop = function(x, y, f) if s.flower == 0 then D.line(x, y, x + 1, y - 5, 6); D.circle(x + 1, y - 6, 1.2, 13) end end })
    s.flower = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "fn", function() s.flower = 0 end }, { "walk", 54, 2.5 }, { "pose", "stand", 3 }, { "pose", "kneel_one", 2 }, { "fn", function() s.flower = 1 end },
      { "pose", "kneel_one", R(8, 12) }, { "pose", "stand", 4 }, { "pose", "head_down", 6 }, { "walk", -10, 2.5 }, { "wait", R(6, 10) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local lu, w = mac("luce"), mac("vento")
    D.gradient(0, 40, 7 + lu * 3, 10 + lu * 2)
    for i = 0, 4 do D.cypress(10 + i * 26, 46, 22, 3, sin(t * 0.6 + i) * w) end
    D.rect(0, 46, 128, 18, 6)
    -- la lapide, la fotografia ovale
    D.rect(60, 26, 22, 30, 10); D.rect(58, 54, 26, 3, 9)
    D.poly({ 60, 26, 82, 26, 78, 22, 64, 22 }, 10)
    D.circle(71, 34, 5, 4); D.circle(71, 34, 4, 7 + lu * 4)
    D.circle(71, 32, 1.5, 3); D.rect(69, 34, 4, 3, 3)
    D.line(64, 44, 78, 44, 6); D.line(66, 47, 76, 47, 6)
    if s.flower == 1 then D.line(70, 54, 71, 49, 6); D.circle(71, 48, 1.4, 14) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- UNA FAMIGLIA SPEZZATA: il letto, la pioggia, un lumino acceso per lei
-------------------------------------------------------------------------------
S.famiglia_spezzata = {
  init = function(s)
    s.fig = D.figura(40, 46, { s = KS, l = 7, pose = "lie" })
    s.rain = {}
    s.lit = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "lie", R(8, 14) } }, { { "pose", "curl", R(6, 10) } }, { { "pose", "sit_edge", 2 }, { "pose", "hands_face", 6 }, { "pose", "lie", 4 } } }) end)
    s.fig:update(dt)
    s.lit = min(1, s.lit + dt * 0.1 * (0.3 + mac("fuoco")))
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    D.rect(0, 0, 128, 64, 0)
    K.window(86, 10, 26, 24, K.views.rain, t, s.rain, 3)
    for i = 0, 12 do local x = 87 + (i * 7) % 25; local y = 11 + (t * 6 + i * 5) % 22; D.line(x, y, x, y + 2, 7) end
    K.bed(14, 58, 3.6, 2, 3)
    s.fig:draw()
    D.poly({ 30, 46, 64, 45, 64, 49, 30, 49 }, 3)
    -- il lumino sul davanzale, per lei
    D.rect(96, 34, 4, 3, 6)
    D.candle(98, 34, t, 6, 1, 2 + s.lit * 4 + fu * 3)
  end,
}

-------------------------------------------------------------------------------
-- ESSERE IL DOLORE DI QUALCUNO: la porta, il pianto di là, la mano sulla maniglia
-------------------------------------------------------------------------------
S.colpa = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 9, pose = "stand", face = 1, speed = 2, on_step = H.steps("legno", 0.2) })
    s.sob = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({
      { { "walk", 58, 2 }, { "face", 1 }, { "pose", "handle", R(3, 5) }, { "pose", "head_down", 3 }, { "walk", 40, 2 }, { "face", 1 } },
      { { "pose", "head_down", R(6, 10) } },
      { { "walk", 20, 2 }, { "face", 1 }, { "pose", "hands_face", 1 }, { "pose", "stand", 5 } } }) end)
    s.fig:update(dt)
    s.sob = s.sob + dt
  end,
  draw = function(s, t)
    local ba = mac("battito")
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 2, paper = "righe", ceil = 4 }, t)
    -- la porta chiusa, la luce sotto, il pianto
    D.rect(66, 24, 22, 34, 4); D.rect(67, 25, 20, 33, 5)
    D.px(69, 42, 12)
    local sob = 0.5 + 0.5 * sin(s.sob * 3) * sin(s.sob * 0.7)
    D.line(67, 57, 86, 57, 8 + sob * 5)
    D.poly({ 67, 58, 86, 58, 92, 64, 61, 64 }, 3 + sob * 2)
    -- il corridoio buio, il quadro storto
    D.rect(98, 20, 12, 10, 4); D.rect(99, 21, 10, 8, 2)
    s.fig:draw()
    -- il battito che si vede appena, nella cornice dello schermo
    if ba > 0.2 then local k = (sin(t * 7) > 0.9) and 1 or 0; if k > 0 then screen.level(D.lv(3 * ba)); screen.rect(0.5, 0.5, 127, 63); screen.stroke() end end
  end,
}

-------------------------------------------------------------------------------
-- LA CAPPELLA SCONSACRATA: niente altare, il raggio che fa una croce
-------------------------------------------------------------------------------
S.cappella = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, speed = 2.5, on_step = H.steps("marmo", 0.3) })
    s.motes = D.parts(24)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 54, 2.5 }, { "pose", "look_up", 5 }, { "pose", "kneel", R(8, 12) }, { "pose", "stand", 3 }, { "walk", -10, 2.5 }, { "wait", R(6, 10) } } end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 2 + mac("luce") * 2, { 80, 8, 30, 50 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 1)
    -- le volte
    for i = 0, 3 do
      local x = i * 34 - 2
      D.rect(x, 20, 3, 38, 3)
      screen.level(D.lv(3)); screen.move(x + 3, 24); screen.curve(x + 10, 6, x + 24, 6, x + 31, 24); screen.stroke()
    end
    -- dove c'era l'altare: un rettangolo più chiaro sul muro
    D.rect(92, 30, 26, 20, 2); D.rect(100, 16, 10, 14, 2)
    -- il vetro rotto, il raggio, la croce di luce sul pavimento
    D.rect(108, 8, 8, 12, 5 + lu * 6); D.line(110, 8, 113, 14, 1)
    D.poly({ 108, 20, 116, 20, 70, 58, 58, 58 }, 3 + lu * 3)
    D.motes_draw(s.motes, 9 + lu * 4)
    D.rect(56, 57, 18, 2, 8 + lu * 6); D.rect(63, 54, 3, 8, 8 + lu * 6)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- RINNEGARE: le candele che si spengono, l'ultima che resiste
-------------------------------------------------------------------------------
S.rinnegare = {
  init = function(s)
    s.c = {}
    for i = 1, 9 do s.c[i] = { x = 30 + i * 8, on = true, t = 0 } end
    s.fig = D.figura(20, 58, { s = KS, l = 8, speed = 2.5, on_step = H.steps("marmo", 0.3) })
    s.next = 1
  end,
  update = function(s, dt, t)
    local f = s.fig
    think(f, function()
      if s.next > 8 then
        return { { "pose", "stand", 8 }, { "pose", "head_down", 6 }, { "fn", function() for _, c in ipairs(s.c) do c.on = true end; s.next = 1 end }, { "walk", 20, 3 }, { "face", 1 } }
      end
      local c = s.c[s.next]
      return { { "walk", c.x - 6, 2.5 }, { "face", 1 }, { "pose", "bend", 1.5 }, { "fn", function() c.on = false; c.t = 2; s.next = s.next + 1 end }, { "pose", "stand", R(1, 3) } }
    end)
    f:update(dt)
    for _, c in ipairs(s.c) do c.t = max(0, c.t - dt) end
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    D.rect(0, 0, 128, 64, 0)
    -- l'organo con le canne storte
    for i = 0, 10 do local h = 18 + abs(5 - i) * -2 + 10; D.rect(40 + i * 5, 30 - h, 3, h, 3 + (i % 2)); D.px(41 + i * 5, 30 - h, 6) end
    D.rect(36, 30, 60, 4, 3)
    -- la campana incrinata
    D.poly({ 108, 8, 116, 8, 119, 20, 105, 20 }, 4); D.line(112, 10, 110, 18, 0)
    -- l'altare con le candele
    D.rect(30, 46, 80, 12, 3); D.rect(28, 45, 84, 2, 5)
    for _, c in ipairs(s.c) do
      D.rect(c.x - 1, 40, 2, 5, 9)
      if c.on then D.candle(c.x, 45, t + c.x, 9, 5, 2 + fu * 3)
      elseif c.t > 0 then local k = 2 - c.t; D.px(c.x + sin(k * 3), 38 - k * 6, 6 * c.t / 2) end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL MANICOMIO: il corridoio verde, gli spioncini, il neon che ronza
-------------------------------------------------------------------------------
S.manicomio = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, speed = 3, on_step = H.steps("piastrelle", 0.3) })
    s.pacer = D.figura(100, 58, { s = KS, l = 4, speed = 2.5, on_step = H.steps("piastrelle", 0.15) })
    s.neon = 1
    s.eyes = {}
    for i = 1, 4 do s.eyes[i] = R(0, 10) end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(30, 60), 3 }, { "pose", "stand", 3 }, { "walk", 140, 3 }, { "fn", function(f) f.x = -6 end }, { "wait", R(4, 8) } } end)
    think(s.pacer, function() return { { "walk", 112, 2.5 }, { "walk", 92, 2.5 } } end)
    s.fig:update(dt); s.pacer:update(dt)
    s.neon = (random() < dt * (2 + mac("nevrosi") * 8)) and 0.3 or min(1, s.neon + dt * 4)
    for i = 1, 4 do s.eyes[i] = s.eyes[i] - dt; if s.eyes[i] < -2 then s.eyes[i] = R(2, 12) end end
  end,
  draw = function(s, t)
    K.room({ wall = 6 * s.neon, fy = 58, floor = "piastrelle", floor_l = 3 * s.neon + 1, paper = "piastrelle", tile_y = 34, ceil = 4 }, t)
    D.rect(0, 34, 128, 1, 3)
    -- il neon
    D.rect(30, 5, 30, 2, 15 * s.neon); D.rect(76, 5, 30, 2, 13 * s.neon)
    -- le porte con lo spioncino, e a volte un occhio
    for i = 1, 4 do
      local x = 4 + (i - 1) * 32
      D.rect(x, 22, 16, 36, 3); D.rect(x + 1, 23, 14, 34, 4)
      D.rect(x + 6, 30, 4, 2, 1)
      if s.eyes[i] < 0 then D.px(x + 7, 30, 12); D.px(x + 8, 30, 12) end
      D.px(x + 13, 42, 9)
    end
    s.pacer:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- CHIUDERSI A URLARE: la porta a chiave, l'urlo, poi il respiro
-------------------------------------------------------------------------------
S.urlare = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = KS, l = 10, pose = "hands_face" })
    s.wave = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "sit_slump", R(6, 10) }, { "pose", "stand", 1.5 }, { "pose", "scream", 0.4 }, { "fn", function() s.wave = 1 end }, { "pose", "scream", 3 },
      { "pose", "cry", 4 }, { "pose", "sit_ground", R(6, 10) }, { "pose", "sit_think", 5 } } end)
    s.fig:update(dt)
    if s.wave > 0 then s.wave = s.wave + dt * 0.6; if s.wave > 3 then s.wave = 0 end end
    s.fig.shake = (s.wave > 0 and s.wave < 2) and (0.5 + mac("nevrosi") * 0.5) or 0
  end,
  draw = function(s, t)
    local si = mac("silenzio")
    K.room({ wall = 2, fy = 58, floor = "assi", floor_l = 2, ceil = 4 }, t)
    -- la porta con la chiave girata
    K.door(10, 58, 0, 3); D.rect(24, 36, 2, 3, 12)
    -- l'urlo: anelli netti che si allargano e sbattono contro i muri
    if s.wave > 0 then
      for k = 0, 3 do
        local r = (s.wave - k * 0.25) * 40
        if r > 0 and r < 90 then
          local l = max(0, 10 - r / 9) * (1 - si * 0.7)
          screen.level(D.lv(l)); screen.circle(64, 32, r); screen.stroke()
        end
      end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- DIMENTICARSI: le parole che perdono le lettere
-------------------------------------------------------------------------------
local PAROLE = { { "casa", "nonna", "mare", "pane", "tuo nome", "domenica", "Massimo", "giugno" }, { "home", "grandma", "sea", "bread", "your name", "Sunday", "Massimo", "June" } }
S.dimenticarsi = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = 1.3, l = 9, pose = "stand" })
    s.w = {}
    s.next = 1
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "stand", R(6, 10) } }, { { "pose", "head_down", 6 } }, { { "pose", "look_up", 4 } } }) end)
    s.fig:update(dt)
    s.next = s.next - dt
    if s.next < 0 then
      s.next = R(3, 6)
      local p = PAROLE[H.lang()] or PAROLE[1]
      s.w[#s.w + 1] = { s = pick(p), x = R(10, 100), y = R(14, 40), age = 0 }
      if #s.w > 4 then table.remove(s.w, 1) end
    end
    local fr = 0.15 + mac("fragilita") * 0.4
    for _, w in ipairs(s.w) do w.age = w.age + dt * fr end
    -- lui stesso sbiadisce, e torna
    s.fig.l = 4 + 5 * (0.5 + 0.5 * sin(t * 0.2))
  end,
  draw = function(s, t)
    local ne = mac("nebbia")
    D.gradient(0, 64, 4, 6 + ne * 3)
    for _, w in ipairs(s.w) do
      -- ogni lettera se ne va per conto suo
      local out = {}
      for i = 1, #w.s do
        local ch = w.s:sub(i, i)
        local gone = ((i * 7 + #w.s) % 10) / 10 < w.age
        out[#out + 1] = gone and " " or ch
      end
      txt(w.x, w.y, table.concat(out), max(0, 11 - w.age * 4))
    end
    D.rect(0, 58, 128, 6, 5)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- NESSUNO CHE PARLA: l'aria della stanza, la polvere nella luce
-------------------------------------------------------------------------------
S.nessuno_parla = {
  init = function(s)
    s.fig = D.figura(48, 58, { s = KS, l = 9, pose = "sit", face = 1 })
    s.motes = D.parts(30)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit", R(14, 22) } }, { { "pose", "sit_think", R(10, 14) } }, { { "pose", "look_up", 6 } } }) end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 2 + mac("luce") * 2, { 70, 10, 40, 46 }, t)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    K.room({ wall = 4, fy = 58, floor = "moquette", floor_l = 3, ceil = 4 }, t)
    K.window(94, 10, 22, 26, K.views.day, t, s, 8)
    for k = 0, 4 do D.line(96 + k * 4, 36, 66 + k * 6, 58, 7 + lu * 3) end
    K.pool(62, 58, 30, 7 + lu * 3)
    D.motes_draw(s.motes, 10 + lu * 3)
    K.armchair(48, 58, 1, 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL MANICOMIO ABBANDONATO: i letti senza materasso, i nomi sul muro, la pioggia
-------------------------------------------------------------------------------
S.manicomio_abb = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, speed = 2.5, on_step = H.steps("piastrelle", 0.3) })
    s.rain = D.parts(60)
    s.names = {}
    local nn = { "ANNA", "ANNA", "G.", "ANNA", "LUIGI", "ANNA", "ANNA" }
    for i = 1, 14 do s.names[i] = { x = R(4, 110), y = R(10, 32), s = nn[(i % #nn) + 1], l = R(3, 7) } end
  end,
  update = function(s, dt, t)
    D.rain_update(s.rain, dt, 0.4 + mac("pioggia") * 1.5, 58, 0)
    for _, p in ipairs(s.rain.list) do if p.x < 50 or p.x > 74 then p.dead = true end end
    think(s.fig, function() return { { "walk", 40, 2.5 }, { "pose", "trace", 4 }, { "pose", "look_up", 3 }, { "walk", 140, 2.5 }, { "fn", function(f) f.x = -6 end }, { "wait", R(4, 9) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 3, fy = 58, floor = "piastrelle", floor_l = 2, ceil = 0 }, t)
    -- il tetto rotto: la pioggia entra solo in mezzo
    D.rect(50, 0, 24, 3, 0)
    for _, n in ipairs(s.names) do txt(n.x, n.y, n.s, n.l) end
    for i = 0, 3 do branda(6 + i * 32, 50, 5) end
    D.rain_draw(s.rain, 0.8)
    D.rect(52, 57, 20, 1, 6)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'OSPEDALE ABBANDONATO: la torcia, la sedia a rotelle, la porta aperta
-------------------------------------------------------------------------------
S.ospedale_abb = {
  init = function(s)
    s.fig = D.figura(20, 58, { s = KS, l = 8, pose = "torch", speed = 2, on_step = H.steps("piastrelle", 0.3) })
    s.ang = 0
    s.chair = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(20, 70), 2 }, { "face", pick({ -1, 1 }) }, { "pose", "torch", R(4, 7) }, { "face", 1 } } end)
    s.fig:update(dt)
    s.fig.cur.ua1 = 80; s.fig.cur.fa1 = 88
    s.ang = sin(t * 0.4) * 0.35
    if random() < dt * 0.02 then s.chair = 1 end
    s.chair = max(0, s.chair - dt * 0.2)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local f = s.fig
    local hx, hy = f.hand[1] or f.x, f.hand[2] or 40
    local dir = f.face
    -- il cono della torcia: si vede solo quello che tocca
    local a1, a2 = s.ang - 0.25, s.ang + 0.25
    local L = 90
    local x1, y1 = hx + dir * cos(a1) * L, hy + sin(a1) * L
    local x2, y2 = hx + dir * cos(a2) * L, hy + sin(a2) * L
    D.poly({ hx, hy, x1, y1, x2, y2 }, 2)
    local function lit(x, y) local dx, dy = (x - hx) * dir, y - hy; if dx <= 0 then return 0 end; local a = math.atan(dy / dx); return (a > a1 and a < a2) and max(0, 1 - dx / 100) or 0 end
    -- gli oggetti, visibili solo nel fascio
    local k = lit(84, 48)
    if k > 0 then
      local turn = s.chair * 2
      D.circle(84, 52, 5, 6 * k, true); D.rect(80, 42, 8, 2, 7 * k); D.line(87, 42 - turn, 89, 34, 7 * k); D.circle(91, 56, 1.5, 6 * k, true)
    end
    k = lit(108, 40)
    if k > 0 then D.rect(100, 26, 14, 30, 2 + 4 * k); D.rect(101, 27, 6, 29, 9 * k) end
    k = lit(52, 46)
    if k > 0 then D.rect(44, 44, 16, 2, 6 * k); D.rect(46, 40, 10, 4, 10 * k); D.line(47, 41, 54, 41, 3); D.line(47, 43, 52, 43, 3) end
    D.line(0, 58, 127, 58, 1)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL REPARTO FERMO: le macchine ferme a metà gesto, l'armadietto col nome
-------------------------------------------------------------------------------
S.reparto = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 3, dark = true, speed = 2.5, on_step = H.steps("metallo", 0.3) })
    s.motes = D.parts(20)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 92, 2.5 }, { "face", 1 }, { "pose", "handle", 3 }, { "pose", "head_down", 6 }, { "walk", 140, 2.5 }, { "fn", function(f) f.x = -6 end }, { "wait", R(4, 9) } } end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 2, { 10, 6, 70, 40 }, t)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 1)
    -- i lucernari del capannone
    for i = 0, 4 do D.poly({ i * 28, 10, i * 28 + 14, 2, i * 28 + 28, 10 }, 3); D.rect(i * 28 + 8, 5, 10, 3, 5) end
    D.motes_draw(s.motes, 6)
    -- la pressa, ferma a metà
    D.rect(14, 18, 24, 6, 4); D.rect(18, 24, 4, 20, 3); D.rect(30, 24, 4, 20, 3)
    D.rect(20, 34, 12, 4, 5); D.rect(14, 44, 24, 14, 4)
    D.rect(44, 40, 30, 3, 4); for x = 46, 72, 6 do D.circle(x, 41.5, 1.5, 3) end
    -- il calendario della ditta, un giorno cerchiato
    D.rect(60, 14, 12, 14, 8); for y = 19, 26, 2 do for x = 61, 70, 2 do D.px(x, y, 4) end end
    screen.level(D.lv(11)); screen.circle(66, 22, 1.8); screen.stroke()
    -- gli armadietti, uno col nome, la tuta appesa
    for i = 0, 2 do
      local x = 96 + i * 10
      D.rect(x, 24, 9, 34, 4)
      for y = 26, 30, 2 do D.line(x + 2, y, x + 6, y, 2) end
    end
    D.rect(98, 34, 5, 2, 12)
    D.rect(97, 38, 7, 14, 6)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL PAESE SOMMERSO: il campanile sotto il lago, i pesci nelle porte
-------------------------------------------------------------------------------
S.paese_sommerso = {
  init = function(s)
    s.fish = {}
    for i = 1, 8 do s.fish[i] = { x = R(0, 128), y = R(10, 54), v = R(3, 8) * pick({ -1, 1 }) } end
    s.bub = D.parts(30)
    s.bell = 0
    s.fig = D.figura(30, 50, { s = 1.15, l = 5, pose = "float" })
  end,
  update = function(s, dt, t)
    for _, f in ipairs(s.fish) do f.x = f.x + f.v * dt; if f.x > 134 then f.x = -6 elseif f.x < -6 then f.x = 134 end end
    if random() < dt * 4 then D.spawn(s.bub, { x = R(0, 128), y = 64, vx = 0, vy = -R(4, 10), life = 8 }) end
    D.parts_update(s.bub, dt)
    if random() < dt * (0.02 + mac("campane") * 0.08) then s.bell = 1; S.env.sfx("campana", 180, 0.05, 6, 0.2, 0.1, 0.01) end
    s.bell = max(0, s.bell - dt * 0.3)
    think(s.fig, function() return { { "glide", R(20, 50), R(30, 48), 10 }, { "pose", "float", 4 } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.gradient(0, 64, 4, 1)
    -- i raggi dall'alto, ondulati
    for i = 0, 4 do local x = 20 + i * 24 + sin(t * 0.3 + i) * 4; D.line(x, 0, x + 10, 40, 4) end
    -- le case con le finestre aperte, la fontana
    for i = 0, 3 do
      local x = 4 + i * 30
      D.rect(x, 36, 20, 22, 2); D.poly({ x - 1, 36, x + 21, 36, x + 10, 30 }, 2)
      D.rect(x + 4, 42, 4, 5, 0); D.rect(x + 12, 46, 5, 12, 0)
    end
    D.rect(56, 52, 12, 6, 3); D.rect(61, 46, 2, 6, 3)
    -- il campanile, la campana che si muove
    D.rect(100, 8, 12, 50, 3); D.poly({ 98, 8, 114, 8, 106, 0 }, 3)
    local sw = sin(t * 2) * s.bell * 3
    D.poly({ 103 + sw, 14, 109 + sw, 14, 110 + sw, 20, 102 + sw, 20 }, 5 + s.bell * 6)
    for _, f in ipairs(s.fish) do D.line(f.x, f.y, f.x + (f.v > 0 and -3 or 3), f.y, 5); D.px(f.x + (f.v > 0 and -4 or 4), f.y - 1, 4); D.px(f.x + (f.v > 0 and -4 or 4), f.y + 1, 4) end
    for _, b in ipairs(s.bub.list) do D.px(b.x + sin(t * 2 + b.y) * 0.8, b.y, 6) end
    D.rect(0, 58, 128, 6, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- QUELLI LAGGIÙ: le navi sul fondo, le forme pallide, il lumino che scende
-------------------------------------------------------------------------------
S.affondati = {
  init = function(s)
    s.forms = {}
    for i = 1, 6 do s.forms[i] = { x = R(10, 118), y = R(30, 50), ph = R(0, 6) } end
    s.light = { y = -4, x = 64 }
    s.bub = D.parts(20)
  end,
  update = function(s, dt, t)
    s.light.y = s.light.y + dt * 3
    s.light.x = 64 + sin(t * 0.3) * 6
    if s.light.y > 54 then s.light.y = -4 end
    if random() < dt * 2 then D.spawn(s.bub, { x = R(20, 108), y = 60, vx = 0, vy = -R(3, 6), life = 10 }) end
    D.parts_update(s.bub, dt)
  end,
  draw = function(s, t)
    local co = mac("coro")
    D.rect(0, 0, 128, 64, 0)
    -- le navi coricate, coperte di sabbia
    D.poly({ 4, 58, 44, 58, 50, 50, 10, 46 }, 2); D.line(26, 48, 34, 30, 2); D.line(34, 30, 36, 34, 2)
    D.poly({ 76, 58, 124, 58, 118, 48, 82, 52 }, 2); D.line(100, 50, 96, 34, 2)
    D.rect(0, 58, 128, 6, 3)
    for i = 0, 30 do D.px((i * 41) % 128, 58 + (i * 3) % 5, 4) end
    -- le forme pallide che dormono nell'acqua
    for _, f in ipairs(s.forms) do
      local y = f.y + sin(t * 0.3 + f.ph) * 1.5
      local l = 2 + co * 4
      D.circle(f.x, y - 4, 1.4, l); D.poly({ f.x - 1.5, y - 3, f.x + 1.5, y - 3, f.x + 1, y + 4, f.x - 1, y + 4 }, l)
    end
    -- il lumino che scende verso di loro
    local L = s.light
    D.circle(L.x, L.y, 2.5, 4); D.px(L.x, L.y, 15)
    for _, b in ipairs(s.bub.list) do D.px(b.x, b.y, 4) end
  end,
}

-------------------------------------------------------------------------------
-- IL BOSCO PROFONDO: i tronchi tutti uguali, i passi che si fermano con i tuoi
-------------------------------------------------------------------------------
S.bosco_profondo = {
  init = function(s)
    s.fig = D.figura(50, 58, { s = 1.2, l = 8, speed = 3, on_step = function(f) S.env.step("foglie", pan(f.x), 0.35); s.echo = 0.35 end })
    s.cam = 0
    s.echo = 0
    s.shadow = 0
  end,
  update = function(s, dt, t)
    local f = s.fig
    think(f, function() return { { "walk", f.x + R(20, 40), 3 }, { "pose", "stand", R(2, 4) }, { "face", -1 }, { "pose", "stand", 2 }, { "face", 1 } } end)
    f:update(dt)
    s.cam = f.x - 50
    if s.echo > 0 then s.echo = s.echo - dt; if s.echo <= 0 then S.env.step("foglie", -0.7, 0.15 + mac("battito") * 0.2) end end
    s.shadow = s.shadow + dt
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.rect(0, 0, 128, 64, 0)
    -- tre file di tronchi tutti uguali
    for layer = 3, 1, -1 do
      local sp = 0.3 * layer
      local l = 4 - layer + (1 - nt) * 1.5
      for i = -1, 10 do
        local x = i * (10 + layer * 6) - (s.cam * sp) % (10 + layer * 6)
        D.rect(x, 0, 2 + layer, 58, l)
      end
    end
    D.rect(0, 58, 128, 6, 2)
    for i = 0, 20 do D.px((i * 37 - s.cam) % 128, 59 + (i % 4), 4) end
    s.fig:draw()
    -- qualcosa, sempre un passo indietro, quando ti volti non c'è
    if s.fig.face > 0 then
      local x = s.fig.x - s.cam - 18 + sin(s.shadow) * 1
      D.circle(x, 36, 2, 1); D.rect(x - 2, 38, 4, 18, 1)
    end
  end,
}

-------------------------------------------------------------------------------
-- IL DOLORE: solo il fuoco, e tu dentro. Poi il respiro.
-------------------------------------------------------------------------------
S.dolore = {
  init = function(s)
    s.fig = D.figura(64, 56, { s = 1.4, l = 1, dark = true, pose = "curl" })
    s.br = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "curl", R(10, 16) }, { "pose", "kneel", 5 }, { "pose", "cry", 6 }, { "pose", "kneel", 4 }, { "pose", "sit_ground", 6 } } end)
    s.fig:update(dt)
    s.br = s.br + dt * (0.6 + (1 - mac("respiro")) * 0.6)
  end,
  draw = function(s, t)
    local fu, ar = mac("fuoco"), mac("archi")
    D.rect(0, 0, 128, 64, 0)
    -- le fiamme intorno: lingue nette che salgono
    local n = 10 + floor(fu * 12)
    for i = 0, n - 1 do
      local x = (i / n) * 140 - 6
      local h = 14 + D.noise(t * 2 + i * 0.7) * 22 * (0.5 + fu)
      local sw = sin(t * 3 + i) * 3
      D.poly({ x - 4, 64, x + 4, 64, x + sw, 64 - h }, 5 + (i % 3) * 2)
      D.poly({ x - 2, 64, x + 2, 64, x + sw * 0.6, 64 - h * 0.6 }, 10 + (i % 2) * 3)
    end
    -- il respiro: un cerchio che si allarga e si stringe, sopra di lui
    local r = 10 + sin(s.br) * 4 + ar * 4
    screen.level(D.lv(6 + ar * 6)); screen.circle(64, 36, r); screen.stroke()
    s.fig:draw()
  end,
}

end
