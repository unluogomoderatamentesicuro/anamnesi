-- ANAMNESI · scene dei ricordi (v5): paese, case, mente, abisso
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

D.POSE.cut = { lean = 10, nod = 20, ua1 = 80, ua2 = 60, fa1 = 110, fa2 = 90, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.guitar = { lean = 6, nod = 20, ua1 = 40, ua2 = 50, fa1 = 100, fa2 = 70, th1 = 6, th2 = -6, sh1 = 0, sh2 = -2, hy = 7.1, rot = 0 }
D.POSE.sew = { lean = 14, nod = 26, ua1 = 45, ua2 = 40, fa1 = 95, fa2 = 90, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.knock = { lean = 4, nod = 6, ua1 = 90, ua2 = 6, fa1 = 120, fa2 = 2, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(D.tr(s)) else screen.text(D.tr(s)) end
end

-- un tendone a strisce del mercato
local function tendone(x, y, w, l)
  for i = 0, floor(w / 4) - 1 do D.rect(x + i * 4, y, 4, 3, (i % 2 == 0) and l or l - 3) end
  for i = 0, floor(w / 4) - 1 do D.poly({ x + i * 4, y + 3, x + i * 4 + 4, y + 3, x + i * 4 + 2, y + 5 }, (i % 2 == 0) and l or l - 3) end
end

-------------------------------------------------------------------------------
-- IL MERCATO DEL SABATO: i banchi, le arance, la nonna per mano
-------------------------------------------------------------------------------
S.mercato = {
  init = function(s)
    s.nonna = D.figura(-10, 56, { s = 1.2, l = 2, dark = true, dress = true, bun = true, speed = 3, on_step = H.steps("pietra", 0.2) })
    s.fig = D.figura(-16, 56, { s = 0.9, l = 2, dark = true, child = true, speed = 3,
      prop = function(x, y) D.rect(x - 2, y, 4, 4, 6) end })
    s.vend = D.figura(64, 50, { s = 1.1, l = 3, dark = true, pose = "talk", face = 1 })
    s.people = {}
    for i = 1, 6 do s.people[i] = { x = R(0, 128), v = R(3, 7) * pick({ -1, 1 }), l = R(3, 5) } end
  end,
  update = function(s, dt, t)
    think(s.nonna, function() return { { "walk", 40, 3 }, { "pose", "stand", 4 }, { "walk", 96, 3 }, { "pose", "bend", 3 }, { "walk", 150, 3 }, { "fn", function(f) f.x = -10; s.fig.x = -16 end } } end)
    s.nonna:update(dt)
    s.fig.x = s.nonna.x - 7; s.fig.walking = s.nonna.walking; s.fig.ph = s.nonna.ph; s.fig.face = s.nonna.face
    s.fig:update(dt)
    think(s.vend, function() return pick({ { { "pose", "talk", R(2, 4) } }, { { "pose", "arms_open", 2 } }, { { "pose", "carry", 2 } } }) end)
    s.vend:update(dt)
    local n = 2 + floor(mac("folla") * 4)
    for i, p in ipairs(s.people) do if i <= n then p.x = p.x + p.v * dt; if p.x > 134 then p.x = -6 elseif p.x < -6 then p.x = 134 end end end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 20, 8 + lu * 2, 10 + lu)
    D.rect(0, 8, 128, 40, 5)
    for i = 0, 7 do D.rect(4 + i * 16, 12, 8, 10, 3) end
    -- i banchi con i tendoni a strisce e la merce
    for i, x in ipairs({ 4, 46, 88 }) do
      tendone(x, 28, 36, 11)
      D.rect(x + 2, 40, 32, 2, 7); D.rect(x + 3, 42, 2, 14, 5); D.rect(x + 31, 42, 2, 14, 5)
      for k = 0, 6 do
        if i == 1 then D.circle(x + 5 + k * 4, 39, 1.6, 12)
        elseif i == 2 then D.rect(x + 4 + k * 4, 36, 3, 4, 7 + (k % 3) * 2)
        else D.circle(x + 5 + k * 4, 39, 1.4, 6) end
      end
    end
    D.rect(0, 56, 128, 8, 6)
    local n = 2 + floor(mac("folla") * 4)
    for i, p in ipairs(s.people) do if i <= n then D.circle(p.x, 44, 1.6, p.l); D.rect(p.x - 1.5, 45, 3, 8, p.l); D.line(p.x, 53, p.x + sin(t * 6 + i), 56, p.l) end end
    s.vend:draw(); s.nonna:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- DAL BARBIERE: la poltrona, le forbici, il palo a strisce che gira
-------------------------------------------------------------------------------
S.barbiere = {
  init = function(s)
    s.barb = D.figura(70, 58, { s = KS, l = 4, dark = true, pose = "cut", face = -1 })
    s.fig = D.figura(56, 50, { s = KS * 0.72, l = 9, child = true, pose = "sit", face = 1 })
    s.snip = 0
  end,
  update = function(s, dt, t)
    think(s.barb, function() return pick({ { { "pose", "cut", R(3, 5) } }, { { "walk", R(62, 80), 3 }, { "face", -1 }, { "pose", "cut", 3 } }, { { "pose", "talk", 3 } } }) end)
    s.barb:update(dt); s.fig:update(dt)
    s.snip = s.snip - dt
    if s.snip < 0 and s.barb.cur.ua1 > 70 then s.snip = R(0.2, 0.5); S.env.sfx("step", 3000, 0.012, 0.02, -0.1, 0.9, 0) end
  end,
  draw = function(s, t)
    K.room({ wall = 6, fy = 58, floor = "scacchi", floor_l = 3, paper = "piastrelle", tile_y = 36, ceil = 4 }, t)
    -- lo specchio lungo, le boccette, la radio
    D.rect(8, 12, 40, 20, 9); D.rect(9, 13, 38, 18, 4)
    D.circle(30, 22, 3, 6); D.rect(27, 25, 6, 6, 6)
    D.rect(8, 32, 40, 2, 7); for i = 0, 6 do D.rect(10 + i * 5, 28, 2, 4, 8 + (i % 3) * 2) end
    K.radio(100, 30, 6, t)
    D.rect(96, 30, 18, 1, 6)
    -- la poltrona con l'asse di legno
    D.rect(48, 50, 16, 3, 3); D.rect(50, 38, 3, 12, 3); D.rect(55, 53, 4, 5, 6); D.rect(50, 57, 14, 1, 7)
    D.rect(50, 48, 14, 2, 8)
    -- il palo a strisce bianche e rosse che gira
    D.rect(116, 10, 6, 26, 12)
    for k = 0, 6 do local y = 10 + ((k * 6 + t * 8) % 30); if y < 35 then D.line(116, y, 121, y - 3, 3) end end
    D.rect(115, 8, 8, 2, 7); D.rect(115, 36, 8, 2, 7)
    s.fig:draw(); s.barb:draw()
    -- il borotalco, a volte, una nuvoletta
    if (t % 12) > 10 then for i = 0, 5 do D.px(s.fig.x + R(-3, 3), s.fig.y - 18 + R(-2, 2), 12) end end
  end,
}

-------------------------------------------------------------------------------
-- L'EDICOLA: i giornalini con le mollette, le figurine
-------------------------------------------------------------------------------
S.edicola = {
  init = function(s)
    s.fig = D.figura(30, 56, { s = 1.0, l = 2, dark = true, child = true, pose = "stand", speed = 4 })
    s.open = 0
    s.cards = D.parts(8)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(36, 50), 4 }, { "face", 1 }, { "pose", "reach_up", 1.5 }, { "pose", "hold", 2 },
      { "fn", function() for i = 1, 5 do D.spawn(s.cards, { x = s.fig.x + 4, y = s.fig.y - 12, vx = R(-6, 6), vy = -R(4, 10), life = 2.5 }) end end }, { "pose", "arms_open", 3 }, { "walk", R(10, 30), 4 } } end)
    s.fig:update(dt)
    D.parts_update(s.cards, dt, function(p, d) p.vy = p.vy + 10 * d end)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 24, 8 + lu * 2, 10 + lu)
    -- il chiosco verde con la tettoia
    D.rect(50, 14, 64, 42, 5)
    D.poly({ 46, 14, 118, 14, 114, 8, 50, 8 }, 7)
    -- i giornali appesi con le mollette
    D.line(52, 18, 112, 18, 3)
    for i = 0, 7 do
      local x = 53 + i * 7.5
      D.rect(x, 18, 6, 9, 10 + (i % 3)); D.rect(x + 1, 20, 4, 2, 3 + (i % 4)); D.px(x + 3, 18, 4)
    end
    D.rect(52, 30, 60, 26, 3)
    for r = 0, 2 do for c = 0, 6 do D.rect(54 + c * 8, 32 + r * 8, 6, 6, 6 + ((r + c) % 4) * 2) end end
    -- l'edicolante dietro il banco, il ventaglio delle bustine
    D.circle(104, 30, 2, 4); D.rect(102, 32, 5, 6, 4)
    D.rect(0, 56, 128, 8, 6)
    for _, p in ipairs(s.cards.list) do D.rect(p.x, p.y, 2, 3, 13) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL DISTRIBUTORE DI NOTTE: l'unica luce sulla statale
-------------------------------------------------------------------------------
S.distributore = {
  init = function(s)
    s.stars = D.stars_gen(40, 23, 0, 24)
    s.car = nil
    s.vend = 0
    s.fig = D.figura(24, 56, { s = 1.15, l = 7, pose = "stand" })
  end,
  update = function(s, dt, t)
    if not s.car and random() < dt * (0.04 + mac("distanza") * 0.02) then s.car = { x = -30, stop = random() < 0.3 } end
    if s.car then
      s.car.x = s.car.x + dt * ((s.car.stop and abs(s.car.x - 60) < 20) and 6 or 40)
      if s.car.x > 160 then s.car = nil end
    end
    s.vend = s.vend + dt
    think(s.fig, function() return pick({ { { "pose", "stand", R(6, 10) } }, { { "pose", "look_up", 4 } }, { { "pose", "head_down", 4 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 0.5 + nt * 0.5)
    -- la pensilina col neon che ronza
    D.rect(36, 14, 70, 4, 4)
    local nf = (D.noise(t * 4) > 0.15) and 1 or 0.3
    D.rect(40, 18, 62, 1, 14 * nf)
    D.poly({ 40, 19, 102, 19, 112, 56, 30, 56 }, 2 * nf)
    D.rect(44, 18, 3, 38, 3); D.rect(96, 18, 3, 38, 3)
    -- le pompe
    for i, x in ipairs({ 56, 76 }) do D.rect(x, 38, 8, 18, 6); D.rect(x + 1, 40, 6, 4, 11 * nf); D.line(x + 8, 42, x + 10, 50, 4) end
    -- il distributore di bibite che respira
    local br = 6 + sin(s.vend * 1.2) * 4
    D.rect(108, 36, 10, 20, 3); D.rect(109, 38, 8, 10, br)
    D.rect(0, 56, 128, 8, 1)
    for x = 0, 127, 10 do D.rect(x, 60, 5, 1, 5) end
    -- la macchina che passa (o si ferma un momento)
    if s.car then
      local x = s.car.x
      D.rect(x, 50, 22, 6, 3); D.rect(x + 4, 46, 12, 4, 3); D.rect(x + 5, 47, 4, 2, 6); D.rect(x + 11, 47, 4, 2, 6)
      D.circle(x + 5, 56, 2, 1); D.circle(x + 17, 56, 2, 1); D.px(x + 22, 52, 15); D.px(x, 52, 9)
      D.poly({ x + 22, 51, x + 50, 46, x + 50, 58, x + 22, 54 }, 3)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA SAGRA: le lampadine tra gli alberi, il liscio, i vecchi che ballano
-------------------------------------------------------------------------------
S.sagra = {
  init = function(s)
    s.couples = {}
    for i = 1, 3 do
      s.couples[i] = { a = D.figura(30 + i * 22, 56, { s = 1.1, l = 8, pose = "hug", face = 1 }),
        b = D.figura(34 + i * 22, 56, { s = 1.1, l = 7, pose = "hug", face = -1, dress = true, bun = (i == 2) }), ph = R(0, 6) }
    end
    s.fig = D.figura(110, 56, { s = 0.9, l = 9, child = true, pose = "stand", face = -1 })
    s.fw = 0
  end,
  update = function(s, dt, t)
    for i, c in ipairs(s.couples) do
      local cx = 30 + i * 24 + sin(t * 0.6 + c.ph) * 8
      c.a.x = cx - 2; c.b.x = cx + 2
      local bob = abs(sin(t * 3.3 + c.ph))
      c.a.cur.hy = 7.2 - bob * 0.3; c.b.cur.hy = 7.2 - bob * 0.3
      c.a:update(dt); c.b:update(dt)
    end
    think(s.fig, function() return pick({ { { "pose", "stand", R(5, 8) } }, { { "pose", "dance", 3 }, { "pose", "stand", 2 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 0)
    -- gli alberi e i fili di lampadine
    D.tree(8, 56, 40, 2, 3, 0); D.tree(122, 56, 40, 2, 9, 0)
    for k = 0, 1 do
      local y0 = 10 + k * 8
      for i = 0, 24 do
        local x = 8 + i * 4.6
        local y = y0 + sin(i / 24 * pi) * 6
        D.px(x, y, ((floor(t * 2) + i) % 4 == 0) and 15 or (9 + lu * 3))
      end
    end
    -- il palco con l'orchestra
    D.rect(84, 34, 36, 3, 5)
    for i = 0, 2 do local x = 90 + i * 10; D.circle(x, 26, 1.5, 6); D.rect(x - 1.5, 28, 3, 6, 6) end
    D.rect(0, 56, 128, 8, 3)
    for _, c in ipairs(s.couples) do c.a:draw(); c.b:draw() end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA LAVANDERIA A GETTONI: gli oblò che girano come pianeti
-------------------------------------------------------------------------------
S.lavanderia = {
  init = function(s)
    s.fig = D.figura(100, 58, { s = KS, l = 9, pose = "sit", face = -1 })
    s.a = 0
  end,
  update = function(s, dt, t)
    s.a = s.a + dt * (2 + mac("tempo") * 3)
    think(s.fig, function() return pick({ { { "pose", "sit", R(8, 12) } }, { { "pose", "sit_think", 6 } }, { { "pose", "sit_read", 8 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 7, fy = 58, floor = "piastrelle", floor_l = 5, ceil = 4 }, t)
    D.rect(20, 5, 30, 2, 15); D.rect(70, 5, 30, 2, 15)
    -- le lavatrici in fila, gli oblò che girano
    for i = 0, 3 do
      local x = 4 + i * 22
      D.rect(x, 30, 20, 28, 11); D.rect(x, 30, 20, 4, 9)
      D.px(x + 16, 32, (floor(t * 2 + i) % 2 == 0) and 15 or 6)
      D.circle(x + 10, 45, 7, 6); D.circle(x + 10, 45, 5.5, 3)
      for k = 0, 4 do
        local a = s.a * (1 + i * 0.13) + k * 1.3
        D.circle(x + 10 + cos(a) * 3, 45 + sin(a) * 3, 1.2, 7 + (k % 3) * 2)
      end
    end
    -- la panca, le riviste, la macchinetta dei gettoni
    D.rect(92, 50, 34, 2, 6); D.rect(94, 52, 2, 6, 5); D.rect(122, 52, 2, 6, 5)
    D.rect(112, 22, 10, 14, 5); D.rect(114, 24, 6, 3, 12)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA SALA PROVE: i cartoni delle uova, i cavi, uno due tre quattro
-------------------------------------------------------------------------------
S.sala_prove = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 10, pose = "guitar", face = 1,
      prop = function(x, y, f) D.poly({ x - 4, y - 1, x + 2, y - 3, x + 3, y + 2, x - 3, y + 4 }, 6); D.line(x + 2, y - 2, x + 12, y - 7, 7) end })
    s.drum = D.figura(84, 58, { s = KS, l = 4, pose = "sit", face = -1 })
    s.hit = 0
    s.beat = 0
  end,
  update = function(s, dt, t)
    local o = s.beat
    s.beat = s.beat + dt * (1.4 + mac("battito"))
    if floor(o) ~= floor(s.beat) then s.hit = 1 end
    s.hit = max(0, s.hit - dt * 6)
    s.fig:update(dt); s.drum:update(dt)
    s.fig.cur.lean = 6 + abs(sin(s.beat * pi)) * 6
    s.drum.cur.ua1 = 60 + s.hit * 40; s.drum.cur.ua2 = 50 + (1 - s.hit) * 40
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "moquette", floor_l = 2, ceil = 4 }, t)
    -- i cartoni delle uova sulle pareti
    for y = 8, 50, 6 do for x = (y % 12 == 2) and 0 or 3, 127, 6 do D.circle(x, y, 1.6, 3) end end
    -- l'amplificatore con la lucina, i cavi aggrovigliati
    D.rect(10, 40, 16, 18, 1); D.rect(11, 41, 14, 10, 3); D.px(23, 54, 15)
    screen.level(D.lv(4)); screen.move(26, 56); screen.curve(34, 62, 30, 50, 40, 56); screen.stroke()
    -- la batteria
    D.circle(96, 50, 6, 5); D.circle(96, 50, 4, 3)
    D.rect(84, 42, 8, 4, 6 + s.hit * 6); D.line(102, 36, 110, 34, 9 + s.hit * 5); D.line(106, 34, 106, 50, 4)
    s.drum:draw(); s.fig:draw()
    if s.hit > 0.5 then D.rect(0, 0, 128, 2, 4 * s.hit) end
  end,
}

-------------------------------------------------------------------------------
-- IL NEGOZIO DI DISCHI: le copertine, le cuffie, il disco che cambia tutto
-------------------------------------------------------------------------------
S.dischi = {
  init = function(s)
    s.fig = D.figura(40, 58, { s = KS, l = 9, pose = "bend", speed = 3, on_step = H.steps("legno", 0.25) })
    s.flip = 0
    s.ang = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "walk", R(20, 60), 3 }, { "pose", "bend", R(4, 8) } }, { { "walk", 96, 3 }, { "face", 1 }, { "pose", "hold", 2 }, { "pose", "head_down", R(8, 12) } } }) end)
    s.fig:update(dt)
    if s.fig.cur.lean > 40 then s.flip = s.flip + dt * 5 end
    s.ang = s.ang + dt * 3.5
  end,
  draw = function(s, t)
    local ra = mac("radio")
    K.room({ wall = 4, fy = 58, floor = "assi", floor_l = 3, ceil = 4 }, t)
    -- i poster, le copertine appese
    for i = 0, 4 do K.frame(8 + i * 22, 8, 16, 16, 5, 3 + (i * 3) % 8); D.circle(16 + i * 22, 16, 3 + (i % 2), 9 - (i % 3) * 2) end
    -- i cassoni di dischi, le dita che scorrono
    D.rect(8, 44, 64, 14, 3)
    for i = 0, 15 do
      local lean = (floor(s.flip) % 16 == i) and 2 or 0
      D.line(10 + i * 4 - lean, 44, 10 + i * 4 + 1, 38, 7 + (i % 3) * 2)
    end
    -- il giradischi del commesso
    D.rect(88, 40, 30, 4, 6); D.rect(90, 44, 26, 14, 4)
    D.circle(103, 38, 7, 2); D.circle(103, 38, 1, 12)
    D.line(103, 38, 103 + cos(s.ang) * 6, 38 + sin(s.ang) * 1.6, 7)
    D.line(112, 32, 108, 37, 9)
    if ra > 0.1 then for i = 1, 3 do local k = (t * 0.6 + i * 0.33) % 1; D.px(103 + i * 4 * k, 30 - k * 12, 9 * (1 - k)) end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA PROCESSIONE: la statua a spalla, le candele, la nenia lenta
-------------------------------------------------------------------------------
S.processione = {
  init = function(s)
    s.walkers = {}
    for i = 1, 9 do s.walkers[i] = D.figura(-10 - i * 13, 58, { s = 1.05, l = 3, dark = true, speed = 1.8, dress = (i % 2 == 0),
      prop = function(x, y) D.candle(x, y + 1, s.t or 0, 7, 2, false) end }) end
    s.fig = s.walkers[6]
    s.fig.child = true
    s.statue = 0
    s.t = 0
  end,
  update = function(s, dt, t)
    s.t = t
    for i, w in ipairs(s.walkers) do
      think(w, function() return { { "walk", 150, 1.8 }, { "fn", function(f) f.x = -10 - 8 * 13 + 0 end } } end)
      w:update(dt)
      w.cur.ua1 = max(w.cur.ua1, 45); w.cur.fa1 = max(w.cur.fa1, 90)
    end
    s.statue = s.walkers[1].x + 14
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    D.gradient(0, 30, 1, 3)
    -- le case strette, le coperte buone appese alle finestre
    for i = 0, 7 do
      local x = i * 16
      D.rect(x, 4, 15, 50, 3 + (i % 2))
      D.rect(x + 4, 12, 6, 7, 1); D.rect(x + 3, 19, 9, 6, 6 + (i % 3) * 2)
      for k = 0, 2 do D.px(x + 4 + k * 3, 24, 4) end
    end
    D.rect(0, 54, 128, 10, 2)
    -- la statua portata a spalla
    local x = s.statue % 180 - 20
    D.rect(x - 8, 36, 16, 2, 6)
    D.circle(x, 24, 2, 11); D.poly({ x - 3, 26, x + 3, 26, x + 4, 36, x - 4, 36 }, 10)
    D.circle(x, 21, 4, 6, true)
    for _, w in ipairs(s.walkers) do w:draw() end
  end,
}

-------------------------------------------------------------------------------
-- LA CANTINA: le botti, la lampadina sul filo, il vino che parla
-------------------------------------------------------------------------------
S.cantina = {
  init = function(s)
    s.fig = D.figura(-6, 20, { s = 1.15, l = 9, child = true, speed = 4, on_step = H.steps("pietra", 0.25) })
    s.bub = {}
    for i = 1, 3 do s.bub[i] = R(0, 4) end
    s.sw = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 30, 3, 56 }, { "walk", 80, 3 }, { "pose", "bend", 2 }, { "pose", "carry", 1 }, { "face", -1 }, { "walk", 30, 7 }, { "walk", -10, 7, 20 }, { "wait", R(6, 12) } } end)
    s.fig:update(dt)
    for i = 1, 3 do s.bub[i] = s.bub[i] - dt; if s.bub[i] < 0 then s.bub[i] = R(2, 6); S.env.sfx("drop", 300 + i * 80, 0.012, 0.15, (i - 2) * 0.4, 0.3, 0.001) end end
    s.sw = s.sw + dt
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- la lampadina sul filo, che oscilla un poco
    local bx = 64 + sin(s.sw * 0.7) * 2
    D.line(64, 0, bx, 14, 3); D.circle(bx, 15, 1.4, 15)
    local function L(x, y) return max(0, 9 - sqrt((x - bx) ^ 2 + (y - 15) ^ 2) / 7) end
    -- le scale da cui si scende
    for i = 0, 6 do local x = i * 4; D.rect(x, 20 + i * 5, 4, 64, L(x, 20 + i * 5) * 0.5); D.line(x, 20 + i * 5, x + 3, 20 + i * 5, L(x, 20 + i * 5)) end
    -- le botti
    for i = 0, 2 do
      local x = 48 + i * 26
      local l = L(x + 10, 44)
      D.circle(x + 10, 46, 11, l * 0.5); D.circle(x + 10, 46, 9, l * 0.3)
      D.line(x + 1, 46, x + 19, 46, l); D.line(x + 10, 37, x + 10, 55, l * 0.6)
      if s.bub[i + 1] < 0.4 then D.px(x + 10, 36, 10) end
    end
    -- le ragnatele grandi come tende
    for k = 0, 4 do D.line(110, 0, 128, 4 + k * 4, 2); D.line(110 + k * 3, 0, 128, 18, 2) end
    D.rect(0, 58, 128, 6, 1)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA MACCHINA DA CUCIRE: il pedale, l'ago, gli spilli tra le labbra
-------------------------------------------------------------------------------
S.cucito = {
  init = function(s)
    s.nonna = D.figura(54, 58, { s = KS, l = 4, dark = true, dress = true, bun = true, pose = "sew", face = 1 })
    s.fig = D.figura(100, 58, { s = KS * 0.72, l = 10, child = true, pose = "stand", face = -1 })
    s.needle = 0
    s.cat = 40
    s.reel = 0
  end,
  update = function(s, dt, t)
    think(s.nonna, function() return pick({ { { "pose", "sew", R(6, 10) } }, { { "pose", "sit", 2 }, { "pose", "talk", 3 } } }) end)
    think(s.fig, function() return pick({ { { "pose", "stand", R(4, 8) } }, { { "pose", "arms_open", 2 }, { "pose", "stand", 3 } } }) end)
    s.nonna:update(dt); s.fig:update(dt)
    s.needle = s.needle + dt * (s.nonna.cur.lean > 12 and (8 + mac("tempo") * 8) or 0)
    s.reel = s.reel + dt
    s.cat = 40 + sin(s.reel * 0.5) * 10
  end,
  draw = function(s, t)
    local warm = mac("calore")
    K.room({ wall = 4 + warm * 2, fy = 58, floor = "assi", floor_l = 3, paper = "fiori", ceil = 4 }, t)
    K.window(96, 10, 22, 22, K.views.day, t, s, 7)
    -- la macchina da cucire col tavolino e il pedale
    D.rect(62, 44, 30, 2, 6); D.rect(64, 46, 2, 12, 4); D.rect(88, 46, 2, 12, 4)
    D.rect(70, 34, 4, 10, 2); D.rect(70, 34, 18, 4, 2); D.rect(84, 38, 4, 6, 2)
    local ny = 41 + abs(sin(s.needle)) * 3
    D.line(86, 38, 86, ny, 12)
    D.rect(73, 40, 3, 2, 14)
    D.rect(66, 56, 18, 2, 3 + abs(sin(s.needle * 0.5)) * 3)
    -- la stoffa che scorre, la luce piccola
    D.rect(76, 43, 18, 1, 9)
    -- il gatto e il rocchetto rotolato
    D.circle(s.cat, 56, 1.4, 11)
    D.poly({ s.cat - 10, 58, s.cat - 3, 58, s.cat - 4, 54, s.cat - 9, 54 }, 3); D.circle(s.cat - 3, 54, 1.8, 3)
    s.nonna:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL TELEFONO A DISCO: grigio, pesante, che squilla per nessuno
-------------------------------------------------------------------------------
S.telefono_disco = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 9, speed = 3, on_step = H.steps("piastrelle", 0.25) })
    s.ring = 0
    s.dial = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 54, 3 }, { "face", 1 }, { "pose", "bend", 1 }, { "fn", function() s.dial = 6 end }, { "pose", "knock", 6 },
      { "pose", "phone", R(6, 10) }, { "pose", "head_down", 3 }, { "walk", -10, 3 }, { "wait", R(4, 10) } } end)
    s.fig:update(dt)
    s.dial = max(0, s.dial - dt)
    if s.fig.x < 0 and random() < dt * 0.08 then s.ring = 6 end
    if s.ring > 0 then
      local o = s.ring
      s.ring = s.ring - dt
      if floor(o * 2) ~= floor(s.ring * 2) and (s.ring % 2) > 1 then S.env.sfx("bell", 1100, 0.01, 0.4, 0.2, 0.4, 0.001) end
    end
  end,
  draw = function(s, t)
    K.room({ wall = 4, fy = 58, floor = "piastrelle", floor_l = 3, paper = "righe", ceil = 4 }, t)
    K.door(100, 58, 0, 4)
    -- il tavolino del corridoio, il centrino, il telefono
    D.rect(60, 44, 22, 2, 6); D.rect(62, 46, 2, 12, 5); D.rect(78, 46, 2, 12, 5)
    D.circle(71, 43, 4, 11)
    local sh = (s.ring > 0 and (s.ring % 2) > 1) and sin(t * 60) * 0.6 or 0
    D.rect(65 + sh, 37, 12, 6, 5); D.rect(64 + sh, 35, 14, 2, 6)
    D.circle(71 + sh, 40, 2.4, 3)
    local a = s.dial > 0 and sin(s.dial * 2) * 1.5 or 0
    for k = 0, 7 do local an = k / 8 * pi * 2 + a; D.px(71 + sh + cos(an) * 2, 40 + sin(an) * 2, 9) end
    screen.level(D.lv(4)); screen.move(77, 40); screen.curve(84, 44, 80, 52, 86, 58); screen.stroke()
    -- l'elenco del telefono, la penna legata col filo
    D.rect(64, 41, 6, 2, 9)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA TV A NOTTE FONDA: il monoscopio, poi la neve
-------------------------------------------------------------------------------
S.tv_notte = {
  init = function(s)
    s.fig = D.figura(26, 58, { s = KS, l = 6, pose = "sit_slump", face = 1 })
    s.k = 0
  end,
  update = function(s, dt, t)
    s.k = (s.k + dt / 40) % 1
    think(s.fig, function() return pick({ { { "pose", "sit_slump", R(10, 16) } }, { { "pose", "lie", 8 }, { "pose", "sit_slump", 4 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local fr = mac("fragilita")
    D.rect(0, 0, 128, 64, 0)
    local snow = s.k > 0.5
    local tx, ty = 82, 22
    -- la luce dello schermo sulla stanza
    local glow = snow and (3 + D.noise(t * 8) * 2) or 4
    D.poly({ tx, ty, tx + 26, ty, 128, 64, 10, 64 }, glow * 0.4)
    D.rect(tx - 2, ty - 2, 30, 24, 3); D.rect(tx + 6, ty + 22, 14, 2, 3); D.rect(tx + 4, ty + 24, 18, 12, 2)
    if not snow then
      -- il monoscopio: cerchio, croce, barre
      D.rect(tx, ty, 26, 20, 8)
      for i = 0, 6 do D.rect(tx + i * 3.7, ty + 2, 3.7, 4, 3 + i * 2) end
      screen.level(D.lv(14)); screen.circle(tx + 13, ty + 12, 6); screen.stroke()
      D.line(tx + 13, ty + 6, tx + 13, ty + 18, 14); D.line(tx + 7, ty + 12, tx + 19, ty + 12, 14)
    else
      for i = 1, 130 do D.px(tx + random(0, 25), ty + random(0, 19), random(3, 14)) end
    end
    -- il divano, lui addormentato
    K.sofa(8, 58, 2, 2.4)
    s.fig.l = 3 + glow
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL TRASLOCO: gli scatoloni, le stanze che rimbombano, il quadro che non c'è
-------------------------------------------------------------------------------
S.trasloco = {
  init = function(s)
    s.fig = D.figura(60, 58, { s = KS, l = 9, pose = "stand", speed = 3, on_step = H.steps("legno", 0.3),
      prop = function(x, y, f) if f.cur.ua1 > 40 and f.cur.fa1 > 70 and f.cur.lean < 20 then D.rect(x - 4, y - 5, 9, 7, 7) end end })
    s.boxes = { { 10, 50 }, { 22, 50 }, { 16, 42 }, { 96, 50 } }
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({
      { { "walk", R(80, 100), 3 }, { "pose", "bend", 2 }, { "pose", "carry", 1 }, { "walk", 30, 3 }, { "pose", "bend", 2 }, { "pose", "stand", 2 } },
      { { "walk", 64, 3 }, { "face", 1 }, { "pose", "trace", 4 }, { "pose", "head_down", 4 } },
      { { "pose", "sit_ground", R(6, 10) } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 5, fy = 58, floor = "assi", floor_l = 4, paper = "righe", ceil = 4 }, t)
    -- dove c'era il quadro: un rettangolo più chiaro, il chiodo
    D.rect(56, 14, 20, 16, 7); D.px(66, 13, 2)
    K.window(98, 12, 20, 20, K.views.day, t, s, 8)
    -- gli scatoloni chiusi col nastro
    for _, b in ipairs(s.boxes) do D.rect(b[1], b[2], 12, 8, 7); D.rect(b[1] + 5, b[2], 2, 8, 10); D.line(b[1] + 2, b[2] + 3, b[1] + 4, b[2] + 3, 3) end
    -- il materasso per terra
    D.rect(30, 54, 30, 4, 9); D.rect(31, 52, 6, 2, 11)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA LETTERA MAI SPEDITA: il cassetto, la busta, la cassetta rossa
-------------------------------------------------------------------------------
S.lettera = {
  init = function(s)
    s.fig = D.figura(46, 58, { s = KS, l = 9, pose = "sit_read", face = 1,
      prop = function(x, y, f) if f.cur.fa1 > 100 then D.rect(x - 4, y - 5, 8, 6, 13); D.line(x - 4, y - 5, x, y - 2, 6); D.line(x, y - 2, x + 4, y - 5, 6); D.rect(x + 2, y - 4, 2, 2, 4) end end })
    s.drawer = 0
    s.rain = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "sit", 2 }, { "fn", function() s.drawer = 1 end }, { "pose", "sit_read", R(8, 14) }, { "pose", "sit_think", 4 }, { "fn", function() s.drawer = 0 end }, { "pose", "sit", 4 } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "righe", ceil = 4 }, t)
    -- fuori, la cassetta delle lettere sotto la pioggia
    K.window(86, 12, 30, 24, mac("pioggia") > 0.2 and K.views.rain or K.views.night, t, s.rain, 4)
    D.rect(108, 26, 5, 6, 6); D.rect(109, 32, 3, 4, 4)
    -- la scrivania col cassetto aperto
    local ty = K.desk(54, 58, 4)
    D.rect(58, ty + 4, 12, 5, 3)
    if s.drawer > 0 then D.rect(56, ty + 6, 16, 4, 5); D.rect(58, ty + 6, 5, 2, 12) end
    K.lamp(78, ty, 4, 1, t)
    K.chair(46, 58, 1, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL COMPLEANNO: la torta piccola, una candela, il canto stonato
-------------------------------------------------------------------------------
S.compleanno = {
  init = function(s)
    s.fig = D.figura(60, 58, { s = KS, l = 9, pose = "sit", face = 1 })
    s.others = { D.figura(90, 58, { s = KS, l = 3, dark = true, pose = "talk", face = -1, dress = true }), D.figura(104, 58, { s = KS * 0.72, l = 3, dark = true, child = true, pose = "arms_open", face = -1 }) }
    s.lit = true
    s.smoke = D.parts(16)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "fn", function() s.lit = true end }, { "pose", "sit", R(8, 12) }, { "pose", "blow", 1 }, { "fn", function() s.lit = false end }, { "pose", "sit", 2 }, { "pose", "arms_open", 3 }, { "pose", "sit", 6 } } end)
    s.fig:update(dt)
    for _, o in ipairs(s.others) do think(o, function() return pick({ { { "pose", "talk", 3 } }, { { "pose", "arms_open", 2 } } }) end); o:update(dt) end
    if not s.lit then D.smoke_update(s.smoke, dt, 76, 40, 3, t, 0.3) else D.parts_update(s.smoke, dt) end
  end,
  draw = function(s, t)
    local warm = mac("calore")
    local dark = s.lit and 1 or 3 + warm * 2
    K.room({ wall = dark, fy = 58, floor = "assi", floor_l = dark - 1, ceil = 4 }, t)
    -- la luce della candela sulle facce, quando la stanza è al buio
    -- al buio, solo la fiammella illumina il tavolo: un taglio netto di luce
    if s.lit then D.poly({ 68, 34, 84, 34, 92, 58, 60, 58 }, 2 + warm) end
    local ty = K.table(64, 58, 1.6, 4, 9)
    D.rect(70, ty - 5, 12, 5, 12); D.rect(70, ty - 6, 12, 1, 14)
    D.rect(75.5, ty - 10, 1, 4, 10)
    if s.lit then D.candle(76, ty - 6, t, 12, 3, false) end
    D.smoke_draw(s.smoke, 8)
    s.fig:draw()
    for _, o in ipairs(s.others) do o.l = s.lit and 2 or 4; o:draw() end
  end,
}

-------------------------------------------------------------------------------
-- LA RADIO DI NOTTE: la manopola, le stazioni, chi è ancora sveglio
-------------------------------------------------------------------------------
S.radio_notte = {
  init = function(s)
    s.fig = D.figura(36, 46, { s = KS, l = 7, pose = "lie" })
    s.tune = 0.3
    s.target = 0.3
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "lie", R(10, 16) } }, { { "pose", "sit_edge", 2 }, { "fn", function() s.target = R(0.05, 0.95) end }, { "pose", "sit_edge", 3 }, { "pose", "lie", 4 } } }) end)
    s.fig:update(dt)
    s.tune = s.tune + (s.target - s.tune) * dt * 0.8
  end,
  draw = function(s, t)
    local ra = mac("radio")
    D.rect(0, 0, 128, 64, 0)
    K.window(10, 8, 20, 18, K.views.night, t, s, 2)
    K.bed(14, 58, 3.4, 2, 3)
    s.fig:draw()
    -- la radio sul comodino, la scala delle frequenze accesa
    D.rect(74, 44, 12, 14, 3)
    D.rect(78, 30, 34, 14, 4); D.rect(80, 32, 30, 6, 6 + ra * 4)
    for k = 0, 9 do D.line(81 + k * 3, 33, 81 + k * 3, 34 + (k % 2), 3) end
    D.rect(80 + s.tune * 29, 32, 1, 6, 14)
    D.circle(84, 41, 1.5, 9); D.circle(105, 41, 1.5, 9)
    -- le onde: pulite quando sei sulla stazione, rotte quando no
    local clean = abs((s.tune * 10) % 1 - 0.5) > 0.35
    for i = 1, 3 do
      local k = (t * 0.5 + i * 0.33) % 1
      if clean then screen.level(D.lv(7 * (1 - k) * (0.4 + ra))); screen.arc(95, 28, 4 + k * 14, pi * 1.2, pi * 1.8); screen.stroke()
      else for j = 0, 4 do D.px(95 + random(-10, 10) * k, 28 - k * 14 + random(-1, 1), 6 * (1 - k)) end end
    end
  end,
}

-------------------------------------------------------------------------------
-- GLI OROLOGI: nessuno segna la stessa ora
-------------------------------------------------------------------------------
S.orologi = {
  init = function(s)
    s.c = {}
    for i = 1, 11 do s.c[i] = { x = R(10, 118), y = R(10, 44), r = R(3, 7), sp = R(0.3, 3) * pick({ 1, 1, -1 }), stop = (i == 4) } end
    s.fig = D.figura(64, 58, { s = KS, l = 9, pose = "stand", speed = 3 })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "face", -1 }, { "pose", "look_up", 2 }, { "face", 1 }, { "pose", "look_up", 2 } }, { { "pose", "hands_face", 4 } }, { { "walk", R(30, 100), 4 }, { "pose", "stand", 2 } } }) end)
    s.fig:update(dt)
    s.fig.shake = mac("nevrosi") * 0.4
  end,
  draw = function(s, t)
    local tm = 1 + mac("tempo") * 2
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "righe", ceil = 4 }, t)
    for _, c in ipairs(s.c) do
      D.circle(c.x, c.y, c.r + 1, 8); D.circle(c.x, c.y, c.r, 2)
      local a = c.stop and 1.2 or (t * c.sp * tm)
      D.line(c.x, c.y, c.x + sin(a) * (c.r - 1), c.y - cos(a) * (c.r - 1), 13)
      D.line(c.x, c.y, c.x + sin(a / 12) * (c.r - 2), c.y - cos(a / 12) * (c.r - 2), 10)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL LABIRINTO: le siepi alte, gli angoli tutti uguali, la risata di là
-------------------------------------------------------------------------------
S.labirinto = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = 1.2, l = 9, pose = "stand", speed = 3, on_step = H.steps("foglie", 0.25) })
    s.p = 0
    s.turn = 0
    s.laugh = 8
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "stand", R(2, 4) } }, { { "face", -1 }, { "pose", "stand", 2 }, { "face", 1 } }, { { "pose", "look_up", 3 } } }) end)
    s.fig:update(dt)
    s.p = s.p + dt * 0.6
    if s.p > 1 then s.p = 0; s.turn = pick({ -1, 1 }) end
    s.laugh = s.laugh - dt
    if s.laugh < 0 then s.laugh = R(14, 30); S.env.sfx("whisper", 600, 0.02, 0.6, pick({ -0.8, 0.8 }), 0.6, 0.02) end
  end,
  draw = function(s, t)
    local fog = mac("nebbia")
    D.gradient(0, 20, 7, 9 - fog * 2)
    -- il corridoio di siepi che avanza, e l'angolo che gira
    local p = s.p
    local vx = 64 + s.turn * p * 30
    D.poly({ 0, 0, 40 - p * 10, 18, 40 - p * 10, 50, 0, 64 }, 3)
    D.poly({ 128, 0, 88 + p * 10, 18, 88 + p * 10, 50, 128, 64 }, 3)
    D.rect(40 - p * 10, 18, 48 + p * 20, 32, 4 + fog * 2)
    D.rect(vx - 6, 22, 12, 28, 2)
    for i = 0, 20 do D.px((i * 37) % 40, 10 + (i * 13) % 44, 5); D.px(128 - (i * 29) % 40, 10 + (i * 11) % 44, 5) end
    D.poly({ 0, 64, 128, 64, 88 + p * 10, 50, 40 - p * 10, 50 }, 6)
    if fog > 0.1 then for k = 0, 2 do local y = 30 + k * 8; D.rect((t * 6 + k * 30) % 160 - 30, y, 50, 2, 6 + fog * 3) end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ASCENSORE: i numeri che salgono e scendono, le porte che non si aprono
-------------------------------------------------------------------------------
S.ascensore = {
  init = function(s)
    s.fig = D.figura(46, 58, { s = KS, l = 9, pose = "stand", face = 1 })
    s.floor = 3
    s.dir = 1
    s.open = 0
    s.press = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "knock", 1 }, { "fn", function() s.press = 1 end }, { "pose", "stand", R(6, 10) } }, { { "pose", "head_down", 5 } }, { { "pose", "look_up", 4 } } }) end)
    s.fig:update(dt)
    s.press = max(0, s.press - dt * 0.2)
    if random() < dt * 0.5 then
      s.floor = s.floor + s.dir
      if s.floor > 8 or s.floor < 0 or random() < 0.2 then s.dir = -s.dir end
      s.floor = max(0, min(8, s.floor))
    end
    if s.open <= 0 and random() < dt * 0.01 then s.open = 5; S.env.sfx("bell", 1320, 0.03, 1.2, 0.3, 0.4, 0.001) end
    s.open = max(0, s.open - dt)
  end,
  draw = function(s, t)
    K.room({ wall = 5, fy = 58, floor = "marmo", floor_l = 4, ceil = 4 }, t)
    -- le porte d'acciaio, il display, la freccia
    local o = s.open > 0 and min(1, s.open, (5 - s.open)) or 0
    D.rect(58, 14, 36, 44, 6)
    D.rect(60, 16, 32, 42, 0)
    if o > 0 then
      -- dentro: un piano che non esiste, tutto bianco
      D.rect(60, 16, 32, 42, 14 * o)
    end
    local w = 16 * (1 - o)
    D.rect(60, 16, w, 42, 8); D.rect(92 - w, 16, w, 42, 8)
    D.line(76, 16, 76, 57, o > 0 and 0 or 5)
    D.rect(66, 6, 20, 7, 1)
    local labels = { "T", "1", "2", "3", "4", "5", "6", "7", "8" }
    txt(73, 12, labels[s.floor + 1], 12)
    D.poly(s.dir > 0 and { 82, 11, 85, 11, 83.5, 8 } or { 82, 8, 85, 8, 83.5, 11 }, 10)
    D.rect(98, 32, 4, 8, 6); D.circle(100, 34, 1, s.press > 0 and 15 or 5); D.circle(100, 38, 1, 5)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE MASCHERE: tutti sorridono con la stessa bocca
-------------------------------------------------------------------------------
local function maschera(x, y, r, l, smile)
  D.circle(x, y, r, l)
  D.px(x - r * 0.4, y - r * 0.2, 1); D.px(x + r * 0.4, y - r * 0.2, 1)
  if smile then D.line(x - r * 0.5, y + r * 0.3, x, y + r * 0.55, 1); D.line(x, y + r * 0.55, x + r * 0.5, y + r * 0.3, 1)
  else D.line(x - r * 0.4, y + r * 0.45, x + r * 0.4, y + r * 0.45, 1) end
end
S.maschere = {
  init = function(s)
    s.crowd = {}
    for i = 1, 7 do s.crowd[i] = { x = 8 + i * 16, ph = R(0, 6) } end
    s.fig = D.figura(64, 58, { s = KS, l = 9, pose = "stand",
      prop = function(x, y, f) if s.hold then maschera(x + 1, y - 2, 3, 13, true) end end })
    s.hold = false
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "stand", R(4, 6) }, { "fn", function() s.hold = true end }, { "pose", "hold", 4 }, { "pose", "reach_up", 3 }, { "fn", function() s.hold = false end }, { "pose", "head_down", 5 } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 1)
    -- la sala da ballo, i lampadari
    for i = 0, 2 do local x = 24 + i * 40; D.line(x, 0, x, 6, 4); for k = -2, 2 do D.px(x + k * 2, 8 + abs(k), 12) end end
    D.rect(0, 58, 128, 6, 3)
    for i = 0, 15 do D.rect(i * 8, 58, 4, 6, 5) end
    -- la folla mascherata che ondeggia
    local n = 4 + floor(mac("folla") * 3)
    for i = 1, n do
      local c = s.crowd[i]
      if abs(c.x - 64) > 10 then
        local bob = sin(t * 2 + c.ph) * 1.5
        D.rect(c.x - 3, 36 + bob, 6, 22, 3)
        maschera(c.x, 30 + bob, 3.4, 12, true)
      end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'OMBRA CHE NON TI SEGUE
-------------------------------------------------------------------------------
S.ombra = {
  init = function(s)
    s.fig = D.figura(40, 52, { s = 1.25, l = 11, pose = "stand", speed = 3, on_step = H.steps("pietra", 0.3) })
    s.sh = { x = 40, face = 1, tx = 40, wave = 0 }
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(20, 60), 3 }, { "pose", "look_up", 3 }, { "face", 1 }, { "pose", "stand", 4 } } end)
    s.fig:update(dt)
    local sh = s.sh
    if random() < dt * 0.1 then sh.tx = R(70, 120) end
    sh.x = sh.x + (sh.tx - sh.x) * dt * 0.25
    sh.wave = sh.wave + dt
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 52, 6 + lu * 4, 9 + lu * 3)
    D.circle(16, 10, 5, 15)
    D.rect(0, 52, 128, 12, 9 + lu * 2)
    -- l'ombra, sdraiata per terra, che se ne va per conto suo
    local x = s.sh.x
    D.poly({ x - 2, 54, x + 2, 54, x + 22, 60, x + 16, 61 }, 3)
    D.circle(x + 21, 60, 2, 3)
    local wv = sin(s.sh.wave * 3) * 2
    D.line(x + 12, 58, x + 18 + wv, 63, 3)
    s.fig:draw()
    -- sotto di lui, nessuna ombra
  end,
}

-------------------------------------------------------------------------------
-- L'ACQUARIO: i pesci in tondo, il vetro dalla tua parte
-------------------------------------------------------------------------------
S.acquario = {
  init = function(s)
    s.fish = {}
    for i = 1, 7 do s.fish[i] = { a = R(0, 6), r = R(14, 40), sp = R(0.3, 0.7), y = R(14, 46) } end
    s.bub = D.parts(30)
    s.fig = D.figura(64, 50, { s = 1.3, l = 4, pose = "window", face = 1 })
  end,
  update = function(s, dt, t)
    for _, f in ipairs(s.fish) do f.a = f.a + dt * f.sp end
    if random() < dt * 5 then D.spawn(s.bub, { x = R(10, 118), y = 62, vx = 0, vy = -R(6, 12), life = 8 }) end
    D.parts_update(s.bub, dt)
    think(s.fig, function() return pick({ { { "pose", "window", R(8, 12) } }, { { "pose", "stand", 4 } }, { { "pose", "knock", 2 }, { "pose", "window", 4 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local pr = mac("profondita")
    D.gradient(0, 64, 4, 1)
    for i = 0, 4 do local x = 10 + i * 26 + sin(t * 0.4 + i) * 3; D.line(x, 0, x + 6, 50, 3) end
    -- le alghe
    for i = 0, 8 do local x = 6 + i * 14; for k = 0, 5 do D.px(x + sin(t + k + i) * 1.5, 62 - k * 3, 4) end end
    -- i pesci che girano in tondo
    for _, f in ipairs(s.fish) do
      local x = 64 + cos(f.a) * f.r
      local dir = -sin(f.a) > 0 and 1 or -1
      local l = sin(f.a) > 0 and 9 or 5
      D.poly({ x - 3, f.y, x + 3, f.y - 1.5, x + 3, f.y + 1.5 }, l)
      D.poly({ x - 3 * dir, f.y, x - 5 * dir, f.y - 2, x - 5 * dir, f.y + 2 }, l)
    end
    for _, b in ipairs(s.bub.list) do D.px(b.x, b.y, 6) end
    s.fig:draw()
    -- il vetro, davanti a lui: la cornice del suo acquario
    screen.level(D.lv(7)); screen.rect(2.5, 2.5, 123, 59); screen.stroke()
    D.line(6, 6, 20, 20, 5 + pr * 3); D.line(8, 4, 24, 20, 3)
  end,
}

-------------------------------------------------------------------------------
-- LA MINIERA: le rotaie nella montagna, la lampada sul casco
-------------------------------------------------------------------------------
S.miniera = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = 1.25, l = 8, speed = 2.2, on_step = H.steps("pietra", 0.3) })
    s.drip = 3
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 50, 2.2 }, { "face", 1 }, { "pose", "trace", 4 }, { "pose", "head_down", 4 }, { "walk", 140, 2.2 }, { "fn", function(f) f.x = -6 end }, { "wait", R(4, 8) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    local f = s.fig
    local hx, hy = f.x + f.face * 2, f.y - 24 * f.s / 1.25
    -- la lampada sul casco: solo quello che guardi
    local function L(x, y)
      local dx = (x - hx) * f.face
      if dx < -4 then return 0 end
      return max(0, 9 - sqrt((x - hx) ^ 2 + ((y - hy) * 1.6) ^ 2) / 6)
    end
    -- le travi di sostegno, le rotaie, il carrello, la data incisa
    for i = 0, 6 do
      local x = i * 22 + 6
      local l = L(x, 30)
      if l > 0.3 then D.rect(x, 18, 3, 40, l * 0.6); D.rect(x - 3, 16, 24, 3, l * 0.6) end
    end
    for x = 0, 127, 4 do local l = L(x, 58); if l > 0.3 then D.line(x, 58, x + 2, 58, l); D.rect(x, 59, 3, 1, l * 0.5) end end
    local l = L(90, 52)
    if l > 0.3 then D.poly({ 82, 48, 100, 48, 98, 56, 84, 56 }, l * 0.8); D.circle(86, 57, 1.5, l); D.circle(96, 57, 1.5, l) end
    l = L(52, 34)
    if l > 0.3 then txt(42, 36, "1957", l) end
    D.poly({ hx, hy, hx + f.face * 70, hy - 18, hx + f.face * 70, hy + 22 }, 1)
    f:draw()
    D.px(hx, hy, 15)
  end,
}

-------------------------------------------------------------------------------
-- IL FARO SPENTO: il mare sugli scogli, la lampada intera lassù
-------------------------------------------------------------------------------
S.faro_spento = {
  init = function(s)
    s.fig = D.figura(36, 50, { s = 1.15, l = 2, dark = true, pose = "look_up" })
    s.spray = D.parts(40)
    s.flick = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "look_up", R(6, 10) } }, { { "pose", "stand", 4 } }, { { "pose", "reach_up", 4 } } }) end)
    s.fig:update(dt)
    if random() < dt * (2 + mac("mare") * 6) then for i = 1, 6 do D.spawn(s.spray, { x = R(60, 120), y = 52, vx = R(-6, 6), vy = -R(10, 30), life = 1.2 }) end end
    D.parts_update(s.spray, dt, function(p, d) p.vy = p.vy + 40 * d end)
    -- a volte, con tanta luce, prova ad accendersi
    if random() < dt * mac("luce") * 0.2 then s.flick = 1 end
    s.flick = max(0, s.flick - dt * 2)
  end,
  draw = function(s, t)
    D.gradient(0, 40, 1, 3)
    D.cloud(20 + t * 0.6 % 60, 8, 50, 2, 4)
    -- il faro sullo scoglio
    D.poly({ 82, 50, 102, 50, 98, 14, 86, 14 }, 4)
    for y = 20, 48, 8 do D.rect(84 + (50 - y) * 0.1, y, 16 - (50 - y) * 0.2, 3, 2) end
    D.rect(84, 8, 16, 6, 2); D.rect(87, 9, 10, 4, 1 + s.flick * 14); D.poly({ 83, 8, 101, 8, 92, 3 }, 3)
    if s.flick > 0.2 then D.poly({ 97, 10, 128, 0, 128, 22 }, s.flick * 6) end
    -- gli scogli, il mare che si rompe
    D.poly({ 60, 64, 70, 50, 90, 48, 110, 52, 128, 50, 128, 64 }, 2)
    D.rect(0, 48, 70, 16, 3)
    D.waves(48, 64, t, 8, 6, 5)
    for _, p in ipairs(s.spray.list) do D.px(p.x, p.y, 12 * (1 - p.age / 1.2)) end
    D.poly({ 20, 64, 30, 52, 52, 52, 60, 64 }, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- SOTTO LE RADICI: le radici che si parlano, lui raggomitolato in mezzo
-------------------------------------------------------------------------------
S.radici = {
  init = function(s)
    s.fig = D.figura(64, 48, { s = 1.3, l = 7, pose = "curl" })
    s.pulse = 0
    s.r = {}
    local rr = D.lcg(77)
    for i = 1, 9 do
      local pts = {}
      local x, y = 10 + i * 12, 0
      for k = 1, 9 do x = x + (rr() - 0.5) * 14; y = y + 6; pts[#pts + 1] = { x, y } end
      s.r[i] = pts
    end
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "curl", R(10, 16) } }, { { "pose", "lie", 8 } } }) end)
    s.fig:update(dt)
    s.pulse = s.pulse + dt * (0.5 + mac("respiro") * 0.5)
  end,
  draw = function(s, t)
    local warm = mac("calore")
    D.rect(0, 0, 128, 64, 1)
    D.rect(0, 0, 128, 6, 3)
    -- le radici, e la linfa che le attraversa come una luce lenta
    for i, pts in ipairs(s.r) do
      local px, py = pts[1][1], 6
      for k, p in ipairs(pts) do
        local glow = max(0, 1 - abs(((s.pulse + i * 0.1) % 1.5) - k / 9) * 6)
        D.thick(px, py, p[1], p[2], max(0.6, 3 - k * 0.3), 3 + glow * (6 + warm * 4))
        px, py = p[1], p[2]
      end
    end
    -- i sassi, i semi
    for i = 0, 20 do D.circle((i * 37) % 128, 20 + (i * 13) % 40, 1 + (i % 3) * 0.6, 2 + (i % 2)) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- SOTTO IL GHIACCIO: la luce bianca a un palmo, la crepa che si ferma
-------------------------------------------------------------------------------
S.ghiaccio = {
  init = function(s)
    s.fig = D.figura(54, 30, { s = 1.2, l = 2, dark = true, pose = "kneel" })
    s.crack = 0
    s.knock = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "kneel", R(5, 8) }, { "pose", "dig", 0.4 }, { "fn", function() s.knock = 1; S.env.sfx("step", 500, 0.03, 0.05, 0, 0.3, 0) end }, { "pose", "kneel", 1 },
      { "pose", "dig", 0.4 }, { "fn", function() s.knock = 1; S.env.sfx("step", 500, 0.03, 0.05, 0, 0.3, 0) end }, { "pose", "kneel_one", 6 } } end)
    s.fig:update(dt)
    s.knock = max(0, s.knock - dt * 2)
    if s.crack <= 0 and random() < dt * 0.02 then s.crack = 0.01 end
    if s.crack > 0 then s.crack = s.crack + dt * 0.5; if s.crack > 3 then s.crack = 0 end end
  end,
  draw = function(s, t)
    local fog = mac("nebbia")
    D.gradient(0, 30, 4, 7)
    for i = 0, 5 do D.pine(i * 24 + 6, 30, 10, 3, 0) end
    -- la lastra di ghiaccio, e sotto la luce muta
    D.rect(0, 30, 128, 34, 8)
    -- la luce sotto la lastra: tre lame orizzontali, nette
    for k = 0, 2 do local w = 30 - k * 9; D.rect(60 - w / 2, 42 + k * 3, w, 2, 11 + k * 2 + s.knock * 2) end
    for i = 0, 10 do D.line(i * 13, 31, i * 13 + 20, 34 + (i % 3), 10) end
    -- la crepa che corre e si ferma
    if s.crack > 0 then
      local n = min(10, floor(s.crack * 6))
      local x, y = 60, 34
      for k = 1, n do local nx, ny = x + 6 + (k % 2) * 2, y + ((k % 3) - 1) * 2; D.line(x, y, nx, ny, 15); x, y = nx, ny end
    end
    if fog > 0.1 then for k = 0, 2 do D.rect((t * 4 + k * 50) % 170 - 40, 26 + k * 3, 60, 1, 9 + fog * 3) end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ULTIMA ECO: la parola che torna sempre più piano, poi non torna
-------------------------------------------------------------------------------
S.ultima_eco = {
  init = function(s)
    s.fig = D.figura(24, 52, { s = 1.25, l = 9, pose = "stand" })
    s.w = {}
    s.next = 2
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "stand", R(6, 10) }, { "pose", "shout", 1.5 }, { "fn", function()
      local word = H.lang() == 1 and "ciao" or "hello"
      for k = 0, 4 do s.w[#s.w + 1] = { k = -k * 1.4, x = 40 + k * 18, y = 24 + (k % 2) * 8, l = 12 - k * 2.8, word = word } end end },
      { "pose", "stand", 8 }, { "pose", "head_down", 5 } } end)
    s.fig:update(dt)
    for i = #s.w, 1, -1 do local e = s.w[i]; e.k = e.k + dt; if e.k > 3 then table.remove(s.w, i) end end
  end,
  draw = function(s, t)
    local ec = mac("eco")
    D.rect(0, 0, 128, 64, 0)
    D.rect(0, 52, 128, 12, 1)
    for _, e in ipairs(s.w) do
      if e.k > 0 then
        local a = min(1, e.k * 2, (3 - e.k))
        txt(e.x, e.y, e.word, max(0, e.l * a * (0.6 + ec * 0.4)))
      end
    end
    s.fig:draw()
  end,
}

end
