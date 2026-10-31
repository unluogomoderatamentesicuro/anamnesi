-- ANAMNESI · scene dei ricordi (v6): il paese, le case, la mente, l'abisso
-- Fondo nero, persone di luce. Nel dolore la macchina trema, taglia,
-- si avvicina troppo; la luce si spegne e si riaccende.
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S
local cam, hand, bars, shot, rays, ease = H.cam, H.hand, H.bars, H.shot, H.rays, H.ease

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(s) else screen.text(s) end
end

-- un rettangolo vuoto
local function box(x, y, w, h, l)
  D.line(x, y, x + w, y, l); D.line(x, y + h, x + w, y + h, l)
  D.line(x, y, x, y + h, l); D.line(x + w, y, x + w, y + h, l)
end

-- una stanza disegnata solo con gli spigoli: il fondo resta nero
local function stanza(l, fy, vx)
  fy = fy or 54; vx = vx or 64
  D.line(0, fy, 127, fy, l)
  D.line(10, 6, 10, fy, l * 0.6); D.line(118, 6, 118, fy, l * 0.6)
  D.line(0, fy + 10, 10, fy, l * 0.5); D.line(127, fy + 10, 118, fy, l * 0.5)
  D.line(10, 6, 118, 6, l * 0.4)
end

-- il dolore della macchina da presa: tremore che cresce con il tormento
local function tremor(t, k)
  if k <= 0 then return 0, 0 end
  return (D.noise(t * 9) - 0.5) * 5 * k, (D.noise(t * 8 + 30) - 0.5) * 4 * k
end

-------------------------------------------------------------------------------
-- LA PASTICCERIA: le paste in fila, il nastro arricciato
-------------------------------------------------------------------------------
S.pasticceria = {
  init = function(s)
    s.clerk = D.figura(96, 50, { s = 1.15, l = 12, dress = true, pose = "hold", face = -1 })
    s.kid = D.figura(-10, 58, { s = 0.85, l = 15, child = true, speed = 3 })
    s.bell = 0
  end,
  update = function(s, dt, t)
    s.bell = max(0, s.bell - dt * 1.5)
    think(s.kid, function() return { { "fn", function() s.bell = 1; S.env.sfx("bell", 2400, 0.03, 1.2, -0.6, 0.9, 0) end }, { "walk", 40, 3 }, { "face", 1 },
      { "pose", "point", 3 }, { "walk", 60, 2 }, { "pose", "point", 2 }, { "walk", 46, 2 }, { "face", 1 }, { "pose", "point", 3 }, { "pose", "hold", 8 }, { "walk", -14, 3 }, { "wait", 4 } } end)
    s.kid:update(dt)
    think(s.clerk, function() return pick({ { { "pose", "hold", R(3, 5) } }, { { "pose", "carry", 2 }, { "pose", "talk", 2 } }, { { "walk", R(84, 104), 2 }, { "face", -1 }, { "pose", "bend", 2 } } }) end)
    s.clerk:update(dt)
  end,
  draw = function(s, t)
    -- la porta a vetri con la campanella
    box(2, 18, 14, 40, 4); D.px(9, 16, 6 + s.bell * 9); D.line(9, 14, 9, 16, 4)
    -- il bancone di vetro: un contorno e tre ripiani di paste
    box(30, 34, 74, 22, 6)
    for r = 0, 1 do
      D.line(32, 42 + r * 8, 102, 42 + r * 8, 4)
      for c = 0, 10 do
        local x, y = 35 + c * 6.3, 40 + r * 8
        if (c + r) % 3 == 0 then D.circle(x, y, 1.7, 10, true); D.px(x, y - 1, 14)
        elseif (c + r) % 3 == 1 then D.rect(x - 2, y - 1, 4, 2, 11); D.px(x, y - 2, 15)
        else D.circle(x, y, 1.3, 12) end
      end
    end
    D.line(30, 34, 104, 34, 9)
    -- il vassoio col nastro, sul banco
    D.line(70, 33, 82, 33, 10); D.line(76, 33, 76, 29, 13); D.line(76, 29, 73, 27, 13); D.line(76, 29, 79, 27, 13)
    D.line(0, 58, 127, 58, 4)
    s.clerk:draw(); s.kid:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA FERMATA DELL'AUTOBUS: due fari nella nebbia; non è il tuo
-------------------------------------------------------------------------------
S.fermata = {
  init = function(s)
    s.fig = D.figura(54, 58, { s = 1.15, l = 13, pose = "stand", face = 1 })
    s.rain = D.parts(60)
    s.bus = -1
  end,
  update = function(s, dt, t)
    local p = mac("pioggia")
    for i = 1, 3 do if random() < dt * 30 * (0.2 + p) then D.spawn(s.rain, { x = R(0, 140), y = -2, vx = -8, vy = R(40, 50), life = 1.5 }) end end
    D.parts_update(s.rain, dt, function(q) if q.y > 58 then q.life = 0 end end)
    if s.bus < 0 and random() < dt * 0.04 then s.bus = 0 end
    if s.bus >= 0 then s.bus = s.bus + dt; if s.bus > 12 then s.bus = -1 end end
    think(s.fig, function() return pick({ { { "pose", "stand", R(5, 9) } }, { { "face", 1 }, { "pose", "lean_rail", 4 } }, { { "pose", "head_down", 4 } }, { { "walk", R(44, 60), 1.5 }, { "face", 1 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = hand(t, 0.7)
    cam(ox, oy, function()
      -- la pensilina: il tetto, i montanti, il pannello graffiato
      D.line(30, 22, 80, 20, 7); D.line(32, 22, 32, 58, 5); D.line(78, 21, 78, 58, 5)
      box(34, 30, 10, 14, 4); for i = 0, 3 do D.line(35, 33 + i * 3, 42, 33 + i * 3, 3) end
      D.line(0, 58, 127, 58, 4); D.line(0, 61, 127, 61, 2)
      -- l'autobus: prima due fari lontani, poi passa e va
      if s.bus >= 0 then
        local u = s.bus
        if u < 6 then
          local k = u / 6
          local x, sz = 120 - k * 10, 0.5 + k * 2
          D.circle(x, 46, sz, 10 + k * 5); D.circle(x + 4 + k * 8, 46, sz, 10 + k * 5)
          D.line(x - 4, 47, x - 30 * k, 52 + k * 4, 3 + k * 4)
        else
          local bx = 110 - (u - 6) * 40
          box(bx, 26, 60, 26, 9)
          for i = 0, 5 do D.rect(bx + 3 + i * 9, 30, 6, 6, 6) end
          D.circle(bx + 10, 53, 3, 6, true); D.circle(bx + 48, 53, 3, 6, true)
        end
      end
      s.fig:draw()
      for _, q in ipairs(s.rain.list) do D.line(q.x, q.y, q.x - 1, q.y + 3, 5) end
    end)
  end,
}

-------------------------------------------------------------------------------
-- IL CINEMA ALL'APERTO: il fascio di luce, il pipistrello, il sonno
-------------------------------------------------------------------------------
S.cinema_aperto = {
  init = function(s)
    s.heads = {}
    for i = 1, 11 do s.heads[i] = { x = 6 + i * 10 + R(-2, 2), y = 50 + (i % 2) * 6, nod = R(0, 6) } end
    s.kid = D.figura(66, 62, { s = 0.9, l = 14, child = true, pose = "sit", face = 1 })
    s.bat = nil
    s.st = D.stars_gen(30, 71, 0, 10)
  end,
  update = function(s, dt, t)
    if not s.bat and random() < dt * 0.05 then s.bat = { x = -6, y = R(14, 24), v = R(30, 50) } end
    if s.bat then s.bat.x = s.bat.x + s.bat.v * dt; if s.bat.x > 134 then s.bat = nil end end
    think(s.kid, function() return pick({ { { "pose", "sit", R(6, 10) } }, { { "pose", "sit_slump", R(8, 12) } }, { { "pose", "look_up", 3 }, { "pose", "sit", 4 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    D.stars(s.st, t, 0.6)
    -- lo schermo e il film: forme lente che passano, il contorno luminoso
    box(30, 6, 68, 32, 10)
    local fl = 0.8 + 0.2 * D.noise(t * 12)
    D.line(34, 30, 94, 30, 4 * fl)
    local fx = 40 + (t * 4) % 50
    D.circle(fx, 24, 3, 9 * fl, true); D.line(fx, 27, fx, 30, 8 * fl)
    D.line(60 + sin(t * 0.3) * 20, 12, 70 + sin(t * 0.3) * 20, 12, 7 * fl)
    -- i pini ai lati
    D.pine(14, 46, 30, 3, sin(t * 0.3) * 0.2); D.pine(114, 46, 30, 3, sin(t * 0.3 + 1) * 0.2)
    -- il fascio del proiettore dalle spalle
    rays(64, 62, 32, 96, 8, 2.5, 6)
    D.px(64, 62, 15)
    if s.bat then
      local b, w = s.bat, sin(t * 20) * 2
      D.line(b.x - 3, b.y - w, b.x, b.y, 14); D.line(b.x, b.y, b.x + 3, b.y - w, 14)
    end
    -- le teste del pubblico, controluce ma accese dal fascio sul bordo
    for i, h in ipairs(s.heads) do
      local y = h.y + (sin(t * 0.5 + h.nod) > 0.97 and 1 or 0)
      D.circle(h.x, y, 2.2, 5); D.px(h.x, y - 2, 9)
    end
    s.kid:draw()
    bars(0.6)
  end,
}

-------------------------------------------------------------------------------
-- IL CAMPO SPORTIVO DI NOTTE: i riflettori, la palla, uno alla volta si spengono
-------------------------------------------------------------------------------
S.campo_notte = {
  init = function(s)
    s.fig = D.figura(40, 56, { s = 1.0, l = 14, speed = 6, on_step = H.steps("erba", 0.3) })
    s.ball = { x = 50, y = 56, vx = 0, vy = 0 }
    s.on = { 1, 1, 1, 1 }; s.clock = 0
    s.bugs = {}
    for i = 1, 16 do s.bugs[i] = { a = R(0, 6), r = R(2, 6), k = random(4), sp = R(2, 5) } end
  end,
  update = function(s, dt, t)
    s.clock = s.clock + dt
    if s.clock > 60 then for i = 1, 4 do s.on[i] = max(0, s.on[i] - dt * 0.5) end end
    if s.clock > 70 then s.clock = 0; s.on = { 1, 1, 1, 1 } end
    local b = s.ball
    b.vy = b.vy + 60 * dt; b.x = b.x + b.vx * dt; b.y = b.y + b.vy * dt
    if b.y > 56 then b.y = 56; b.vy = -b.vy * 0.4; b.vx = b.vx * 0.7 end
    if b.x < 4 or b.x > 124 then b.vx = -b.vx end
    think(s.fig, function() return { { "walk", b.x - 3 * (b.vx >= 0 and 1 or -1), 6 }, { "pose", "throw", 0.4 }, { "fn", function(f)
      if abs(f.x - b.x) < 8 then b.vx = R(20, 40) * (f.x < 64 and 1 or -1); b.vy = -R(20, 40); S.env.sfx("step", 120, 0.06, 0.12, H.pan(f.x), 0.4, 0) end end }, { "pose", "stand", R(1, 3) } } end)
    s.fig:update(dt)
    for _, g in ipairs(s.bugs) do g.a = g.a + dt * g.sp end
  end,
  draw = function(s, t)
    local xs = { 6, 40, 88, 122 }
    for i, x in ipairs(xs) do
      D.line(x, 54, x, 8, 4)
      local l = s.on[i]
      if l > 0.05 then
        for k = 0, 2 do D.rect(x - 3 + k * 2, 5, 2, 2, 15 * l) end
        rays(x, 7, x - 16, x + 16, 56, 2 * l, 3)
        for _, g in ipairs(s.bugs) do if g.k == i then D.px(x + cos(g.a) * g.r, 9 + sin(g.a) * g.r * 0.6, 10 * l) end end
      end
    end
    -- le righe del campo in prospettiva, la porta senza rete
    D.line(0, 56, 127, 56, 5); D.line(64, 46, 64, 63, 4); D.line(14, 46, 114, 46, 3)
    D.line(108, 56, 108, 42, 9); D.line(120, 56, 120, 42, 9); D.line(108, 42, 120, 42, 9)
    s.fig:draw()
    D.circle(s.ball.x, s.ball.y - 1.5, 1.5, 15)
  end,
}

-------------------------------------------------------------------------------
-- LA FONTANA DELLA PIAZZA: le monetine sul fondo, il desiderio di spalle
-------------------------------------------------------------------------------
S.fontana = {
  init = function(s)
    s.fig = D.figura(-10, 58, { s = 1.1, l = 13, speed = 3, on_step = H.steps("pietra", 0.2) })
    s.coins = {}
    for i = 1, 12 do s.coins[i] = { x = R(44, 84), ph = R(0, 6) } end
    s.drops = D.parts(40); s.coin = nil
    s.pig = { x = 90, hop = 0 }
  end,
  update = function(s, dt, t)
    for i = 1, 2 do if random() < dt * 20 then D.spawn(s.drops, { x = 64, y = 28, vx = R(-10, 10), vy = -R(6, 12), life = 2 }) end end
    D.parts_update(s.drops, dt, function(p, d) p.vy = p.vy + 40 * d; if p.y > 46 then p.life = 0 end end)
    think(s.fig, function() return { { "walk", 96, 3 }, { "face", 1 }, { "pose", "head_down", 2 }, { "pose", "throw", 0.5 },
      { "fn", function(f) s.coin = { x = f.x - 2, y = f.y - 22, vx = -14, vy = -14 } end }, { "pose", "stand", 4 }, { "walk", 140, 3 }, { "fn", function(f) f.x = -10 end }, { "wait", 3 } } end)
    s.fig:update(dt)
    if s.coin then
      local c = s.coin
      c.vy = c.vy + 40 * dt; c.x = c.x + c.vx * dt; c.y = c.y + c.vy * dt
      if c.y > 44 then s.coins[#s.coins + 1] = { x = c.x, ph = 0 }; s.coin = nil; S.env.sfx("bell", 3200, 0.03, 0.4, 0.2, 1, 0) end
    end
    s.pig.hop = max(0, s.pig.hop - dt)
    if random() < dt * 0.2 then s.pig.hop = 0.3; s.pig.x = D.clamp(s.pig.x + R(-6, 6), 20, 108) end
  end,
  draw = function(s, t)
    -- la vasca e il leone di pietra, solo contorni
    D.line(36, 46, 92, 46, 8); D.line(36, 46, 38, 56, 6); D.line(92, 46, 90, 56, 6); D.line(38, 56, 90, 56, 5)
    D.line(58, 46, 58, 26, 5); D.line(70, 46, 70, 26, 5); D.circle(64, 24, 5, 6, true); D.px(62, 23, 8); D.px(66, 23, 8); D.px(64, 28, 10)
    for _, p in ipairs(s.drops.list) do D.px(p.x, p.y, 12) end
    -- il luccichio delle monete sul fondo
    for _, c in ipairs(s.coins) do local g = 0.5 + 0.5 * sin(t * 2 + c.ph); D.px(c.x, 50 + (c.ph % 2), 5 + g * 9) end
    if s.coin then D.px(s.coin.x, s.coin.y, 15) end
    D.line(0, 58, 127, 58, 4)
    -- il piccione
    local py = 57 - s.pig.hop * 6
    D.circle(s.pig.x, py - 1.5, 1.8, 9); D.px(s.pig.x + 2, py - 3, 11)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL MERCATINO DELLE PULCI: sui teli, le vite degli altri
-------------------------------------------------------------------------------
S.pulci = {
  init = function(s)
    s.people = {}
    for i = 1, 3 do s.people[i] = D.figura(R(0, 128), 58, { s = 1.0, l = 10 + i, speed = 2, dress = i == 2 }) end
    s.seller = D.figura(104, 58, { s = 1.05, l = 11, pose = "sit", face = -1 })
    s.lr = D.lcg(8)
  end,
  update = function(s, dt, t)
    for _, p in ipairs(s.people) do
      think(p, function() return pick({ { { "walk", R(8, 120), 2 }, { "pose", "bend", R(2, 4) }, { "pose", "hold", 2 } }, { { "walk", R(8, 120), 2 }, { "pose", "stand", 3 } } }) end)
      p:update(dt)
    end
    think(s.seller, function() return pick({ { { "pose", "sit", R(4, 8) } }, { { "pose", "talk", 3 } } }) end)
    s.seller:update(dt)
  end,
  draw = function(s, t)
    -- i portici dietro: archi
    for i = 0, 4 do screen.level(D.lv(3)); screen.move(i * 28, 40); screen.line(i * 28, 20); screen.arc(i * 28 + 14, 20, 14, pi, 2 * pi); screen.line(i * 28 + 28, 40); screen.stroke() end
    D.line(0, 58, 127, 58, 4)
    -- i teli in prospettiva e la roba sopra
    for k, x in ipairs({ 6, 46, 84 }) do
      D.line(x, 54, x + 30, 54, 5); D.line(x - 3, 62, x + 33, 62, 5); D.line(x, 54, x - 3, 62, 5); D.line(x + 30, 54, x + 33, 62, 5)
      if k == 1 then D.circle(x + 6, 57, 1.5, 11, true); D.circle(x + 12, 57, 1.5, 11, true); D.line(x + 18, 58, x + 24, 58, 9) end
      if k == 2 then D.circle(x + 8, 57, 2, 10); D.px(x + 7, 56, 3); for i = 0, 3 do D.rect(x + 16 + i, 58 - i, 6, 1, 8 + i) end end
      if k == 3 then D.line(x + 5, 60, x + 5, 55, 10); D.rect(x + 3, 54, 4, 2, 12); D.rect(x + 14, 56, 8, 5, 6); D.line(x + 14, 56, x + 22, 56, 11) end
    end
    for _, p in ipairs(s.people) do p:draw() end
    s.seller:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA TIPOGRAFIA: la macchina batte il tempo, i fogli escono caldi
-------------------------------------------------------------------------------
S.tipografia = {
  init = function(s)
    s.man = D.figura(30, 58, { s = KS, l = 13, pose = "stand", face = 1 })
    s.ph = 0; s.sheets = {}
  end,
  update = function(s, dt, t)
    local old = s.ph
    s.ph = s.ph + dt * (0.8 + mac("macchine") * 1.2)
    if floor(old) ~= floor(s.ph) then
      s.sheets[#s.sheets + 1] = { x = 90, y = 40, v = 12 }
      S.env.sfx("step", 180, 0.05, 0.08, 0.3, 0.6, 0)
    end
    for i = #s.sheets, 1, -1 do local p = s.sheets[i]; p.x = p.x + p.v * dt; p.y = min(48, p.y + dt * 4); if p.x > 120 then table.remove(s.sheets, i) end end
    think(s.man, function() return pick({ { { "pose", "handle", R(3, 6) } }, { { "walk", R(24, 44), 2 }, { "face", 1 }, { "pose", "bend", 3 } }, { { "pose", "hold", 3 } } }) end)
    s.man:update(dt)
  end,
  draw = function(s, t)
    local k = s.ph % 1
    local press = k < 0.15 and k / 0.15 or (k < 0.4 and 1 - (k - 0.15) / 0.25 or 0)
    -- il montaggio: piano largo, poi il dettaglio della pressa che batte
    local sh = shot(t, { 14, 6 })
    if sh == 1 then
      stanza(4, 58)
      -- la pressa: il telaio, il volano che gira, il piano che scende
      box(56, 20, 34, 34, 6)
      local a = s.ph * 2 * pi
      D.circle(48, 30, 9, 6, true); D.line(48, 30, 48 + cos(a) * 9, 30 + sin(a) * 9, 10); D.line(48, 30, 48 - cos(a) * 9, 30 - sin(a) * 9, 10)
      D.line(48 + cos(a) * 9, 30 + sin(a) * 9, 60, 26 + press * 8, 7)
      D.rect(60, 26 + press * 8, 26, 2, 11)
      D.line(60, 40, 86, 40, 8)
      D.line(86, 40, 120, 48, 5)
      for _, p in ipairs(s.sheets) do D.line(p.x, p.y, p.x + 8, p.y, 13) end
      -- le cassettiere dei caratteri
      for r = 0, 3 do D.line(98, 14 + r * 6, 116, 14 + r * 6, 4) end
      s.man:draw()
    else
      -- da vicino: le righe di piombo e il foglio che riceve l'inchiostro
      local y = 16 + press * 12
      for i = 0, 6 do D.line(20 + (i % 2) * 6, y + i * 2, 108 - (i % 3) * 8, y + i * 2, 12) end
      D.line(10, 46, 118, 46, 6)
      if press > 0.9 then for i = 0, 5 do D.line(22, 48 + i * 2, 100 - i * 6, 48 + i * 2, 15) end end
      D.line(10, 8, 10, 60, 3); D.line(118, 8, 118, 60, 3)
    end
    bars(0.3)
  end,
}

-------------------------------------------------------------------------------
-- LA PISCINA D'INVERNO: le corsie, il cloro, e sotto il mondo diventa blu
-------------------------------------------------------------------------------
-- il nuotatore: steso, le braccia che girano, i piedi che battono
local function swimmer(x, y, t, l)
  D.thick(x - 9, y, x, y - 0.5, 1.6, l)
  D.circle(x + 2.2, y - 1, 1.7, l)
  local a = t * 4
  D.line(x - 1, y - 0.5, x - 1 + cos(a) * 5, y + sin(a) * 3, l)
  D.line(x - 1, y - 0.5, x - 1 + cos(a + pi) * 5, y + sin(a + pi) * 3, l - 3)
  local k = sin(t * 12) * 1.5
  D.line(x - 9, y, x - 13, y + k, l - 1); D.line(x - 9, y, x - 13, y - k, l - 3)
end

S.piscina = {
  init = function(s)
    s.x = -10
    s.bub = D.parts(30)
  end,
  update = function(s, dt, t)
    s.x = s.x + dt * 10
    if s.x > 140 then s.x = -14 end
    if random() < dt * 8 then D.spawn(s.bub, { x = s.x + R(-2, 6), y = 40, vx = R(-1, 1), vy = -R(6, 12), life = 4 }) end
    D.parts_update(s.bub, dt)
  end,
  draw = function(s, t)
    local sh = shot(t, { 16, 10 })
    if sh == 1 then
      -- sopra: le corsie in prospettiva, i riflessi che tremano
      D.line(0, 18, 127, 18, 4)
      for i = -3, 3 do D.line(64 + i * 10, 18, 64 + i * 40, 64, 3) end
      for r = 0, 5 do local y = 22 + r * 7; for x = (t * 6 + r * 5) % 10, 128, 10 do D.line(x, y, x + 3, y + sin(t * 2 + x) * 0.5, 4 + r) end end
      -- le vetrate del tetto
      for i = 0, 7 do D.line(i * 18, 0, i * 18 + 10, 14, 3) end
      swimmer(s.x, 31, t, 14)
      D.line(s.x - 12, 32, s.x + 8, 32, 6)
    else
      -- sotto: il fondo con le righe, le bolle, il nuotatore che vola
      D.line(0, 58, 127, 58, 5)
      for i = 0, 7 do D.line(i * 18 + 4, 58, i * 18 + 10, 58, 9) end
      for r = 0, 3 do local y = 6 + r * 2; D.line(0, y + sin(t + r) , 127, y + sin(t * 1.3 + r), 3 + r) end
      for i = 0, 6 do local x = (i * 21 + t * 3) % 140 - 6; D.line(x, 14, x + 10, 56, 2) end
      swimmer(s.x, 40 + sin(t * 0.8) * 2, t, 14)
      for _, p in ipairs(s.bub.list) do D.px(p.x, p.y, 9) end
    end
  end,
}

-------------------------------------------------------------------------------
-- LA SEDIA VUOTA: la tavola di Natale, il suo bicchiere
-------------------------------------------------------------------------------
S.sedia_vuota = {
  init = function(s)
    s.f = {}
    local xs = { 20, 36, 92, 108 }
    for i, x in ipairs(xs) do s.f[i] = D.figura(x, 54, { s = KS * 0.8, l = 10 + (i % 2) * 2, pose = "sit", face = x < 64 and 1 or -1, dress = i % 2 == 1 }) end
    s.laugh = 0
  end,
  update = function(s, dt, t)
    s.laugh = max(0, s.laugh - dt)
    if random() < dt * 0.03 then s.laugh = 6; local f = s.f[random(4)]; f:act({ { "pose", "arms_open", 1.2 }, { "pose", "head_down", 4 } }); f.shake = 0.5 end
    for _, f in ipairs(s.f) do
      f.shake = max(0, f.shake - dt * 0.3)
      think(f, function() return pick({ { { "pose", "sit", R(5, 9) } }, { { "pose", "talk", R(2, 4) } }, { { "pose", "head_down", 3 } } }) end)
      f:update(dt)
    end
  end,
  draw = function(s, t)
    -- la carrellata lentissima verso la sedia vuota, e indietro
    local k = ease(0.5 - 0.5 * cos(t * 2 * pi / 50))
    local ox = 0
    cam(ox, k * 3, function()
      stanza(3, 56)
      -- la finestra con la neve
      box(52, 10, 24, 18, 4); D.line(64, 10, 64, 28, 3)
      for i = 0, 8 do D.px(54 + (i * 7) % 20, 12 + ((t * 4 + i * 5) % 15), 8) end
      -- la tavola
      D.line(10, 40, 118, 40, 9); D.line(14, 41, 14, 56, 4); D.line(114, 41, 114, 56, 4)
      for i = 0, 8 do D.line(12 + i * 12, 41, 14 + i * 12, 44, 3) end
      -- i piatti, i bicchieri, il suo bicchiere davanti alla sedia vuota
      for _, x in ipairs({ 22, 38, 64, 90, 106 }) do D.line(x - 3, 39, x + 3, 39, 8); D.line(x + 5, 39, x + 5, 35, 6) end
      D.line(69, 39, 69, 34, 13); D.line(68, 34, 70, 34, 13)
      -- la sedia vuota, la candela che la illumina
      D.line(58, 56, 58, 32, 7 + k * 4); D.line(58, 44, 70, 44, 7 + k * 4); D.line(70, 44, 70, 56, 7 + k * 4); D.line(58, 32, 62, 32, 7)
      D.candle(80, 39, t, 7, 3, 4)
      for _, f in ipairs(s.f) do f:draw() end
    end)
    bars(0.3 + k * 0.4)
  end,
}

-------------------------------------------------------------------------------
-- IL CAPPOTTO APPESO: lo indossi, solo per un momento
-------------------------------------------------------------------------------
S.cappotto = {
  init = function(s)
    s.fig = D.figura(-12, 58, { s = KS, l = 13, speed = 2.5, coat = false, on_step = H.steps("legno", 0.3) })
    s.coat = 1      -- 1 appeso, 0 addosso
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 70, 2.5 }, { "face", 1 }, { "pose", "reach_up", 3 }, { "pose", "hug", 3 },
      { "fn", function(f) s.coat = 0; f.coat = true end }, { "pose", "hug", 6 }, { "pose", "head_down", 5 },
      { "pose", "reach_up", 2 }, { "fn", function(f) s.coat = 1; f.coat = false end }, { "pose", "stand", 3 }, { "walk", -14, 2.5 }, { "wait", 6 } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    stanza(3, 58)
    -- l'attaccapanni a muro, il cappotto (una sagoma lunga), la sciarpa
    D.line(70, 14, 96, 14, 7)
    for i = 0, 3 do D.line(72 + i * 7, 14, 72 + i * 7, 17, 9) end
    if s.coat == 1 then
      local sw = sin(t * 0.6) * 0.5
      screen.level(D.lv(9)); screen.move(79, 17); screen.line(84, 18); screen.line(87 + sw, 44); screen.line(76 + sw, 44); screen.line(77, 18); screen.close(); screen.stroke()
      D.line(80, 20, 82, 40, 5); D.px(82, 30, 12)
    end
    -- l'orologio e la porta
    K.clock(30, 18, t, 7)
    box(104, 16, 14, 42, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE SCALE AL BUIO: l'interruttore è in cima
-------------------------------------------------------------------------------
S.scale_buio = {
  init = function(s)
    s.fig = D.figura(8, 60, { s = 1.1, l = 13, speed = 4, on_step = function(f) S.env.step("legno", H.pan(f.x), 0.4) end })
    s.light = 0; s.heart = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "wait", 3 }, { "walk", 104, 4.5, 20 }, { "pose", "reach_up", 0.6 },
      { "fn", function() s.light = 1; S.env.sfx("step", 1400, 0.03, 0.05, 0.6, 0.9, 0) end }, { "pose", "arms_open", 3 }, { "pose", "stand", 6 },
      { "fn", function() s.light = 0 end }, { "wait", 2 }, { "fn", function(f) f.x = 8; f.y = 60 end } } end)
    s.fig:update(dt)
    s.heart = s.heart + dt * (s.light > 0 and 1 or 2.6)
  end,
  draw = function(s, t)
    local L = s.light
    local base = 2 + L * 7
    -- i gradini: senza luce se ne vede solo il bordo
    for i = 0, 11 do
      local x, y = 8 + i * 8, 60 - i * 3.4
      D.line(x, y, x + 8, y, base + 2); D.line(x + 8, y, x + 8, y - 3.4, base)
    end
    D.line(0, 64, 100, 20, base * 0.7); D.line(104, 20, 127, 20, base)
    -- il corrimano
    D.line(8, 48, 104, 8, base * 0.8)
    -- l'interruttore: un puntino che si vede anche al buio
    D.px(110, 6, 6 + L * 9)
    if L > 0 then D.circle(116, 2, 2, 15); rays(116, 2, 60, 127, 30, 4, 6) end
    s.fig:draw()
    if L == 0 then local hb = (sin(s.heart * 2 * pi) > 0.8) and 14 or 0; if hb > 0 then D.px(s.fig.x, s.fig.y - 12 * 1.1, hb) end end
  end,
}

-------------------------------------------------------------------------------
-- IL FRIGORIFERO DI NOTTE: la sua luce è l'unica della casa
-------------------------------------------------------------------------------
S.frigo_notte = {
  init = function(s)
    s.fig = D.figura(-12, 58, { s = KS, l = 6, speed = 2.5 })
    s.door = 0; s.want = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 74, 2.5 }, { "face", -1 }, { "pose", "torch", 1 }, { "fn", function() s.want = 1 end },
      { "pose", "stand", R(8, 14) }, { "pose", "head_down", 5 }, { "fn", function() s.want = 0 end }, { "wait", 2 }, { "walk", -14, 2.5 }, { "wait", 8 } } end)
    s.door = D.lerp(s.door, s.want, dt * 2)
    -- la figura è di luce solo dove la luce la tocca
    s.fig.l = 5 + s.door * 9
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local d = s.door
    -- il frigorifero: un contorno, la porta che ruota verso di noi
    box(46, 14, 20, 44, 4 + d * 4)
    if d > 0.05 then
      -- l'interno acceso: i ripiani e il piatto coperto
      for i = 0, 3 do D.line(48, 22 + i * 9, 64, 22 + i * 9, 6 + d * 8) end
      D.line(50, 30, 58, 30, 13); D.line(51, 29, 57, 29, 10)
      local w = 20 * (1 - d * 0.8)
      D.line(46, 14, 46 - w * 0.4, 12, 9); D.line(46 - w * 0.4, 12, 46 - w * 0.4, 60, 9); D.line(46 - w * 0.4, 60, 46, 58, 9)
      -- la luce per terra: poche linee sottili
      rays(56, 50, 70, 120, 64, 3 * d, 6)
    end
    D.line(0, 58, 127, 58, 2 + d * 3)
    -- il resto della cucina: solo un accenno che la luce raggiunge
    D.line(80, 30, 126, 30, 1 + d * 4); D.line(80, 34, 126, 34, 1 + d * 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL BAGNO ALLE TRE: il neon, lo specchio, la faccia che non sembra la tua
-------------------------------------------------------------------------------
S.bagno_notte = {
  init = function(s)
    s.me = D.figura(54, 62, { s = 1.8, l = 13, pose = "stand", face = 1 })
    s.ref = D.figura(86, 54, { s = 1.6, l = 8, pose = "stand", face = -1 })
    s.neon = 1; s.lag = {}
    s.drip = 0
  end,
  update = function(s, dt, t)
    local tor = mac("tormento") + (S.env.torment and S.env.torment() or 0)
    -- il neon che sfarfalla
    if random() < dt * (0.3 + tor * 3) then s.neon = 0.2 else s.neon = D.lerp(s.neon, 1, dt * 6) end
    think(s.me, function() return pick({ { { "pose", "stand", R(4, 8) } }, { { "pose", "lean_rail", R(4, 6) } }, { { "pose", "hands_face", 3 }, { "pose", "stand", 3 } }, { { "pose", "head_down", 4 } } }) end)
    s.me:update(dt)
    -- il riflesso segue con un ritardo che cresce col tormento
    table.insert(s.lag, 1, s.me.tgt)
    local n = 1 + floor(tor * 40)
    while #s.lag > n do table.remove(s.lag) end
    s.ref.tgt = s.lag[#s.lag]
    s.ref.shake = tor * 0.4
    s.ref:update(dt)
    s.drip = s.drip + dt
    if s.drip > 2.2 then s.drip = 0; S.env.sfx("drop", 1400 + random() * 400, 0.025, 0.3, 0.3, 0.7, 0) end
  end,
  draw = function(s, t)
    local n = s.neon
    -- il neon sopra lo specchio
    D.line(70, 4, 104, 4, 6 + n * 9)
    -- lo specchio: il contorno, dentro il riflesso
    box(68, 8, 38, 44, 5 + n * 4)
    s.ref.l = 5 + n * 5
    s.ref:draw()
    -- il lavandino e il rubinetto che gocciola
    D.line(62, 54, 112, 54, 8 * n + 2); D.line(66, 54, 70, 60, 5); D.line(108, 54, 104, 60, 5)
    D.line(88, 50, 88, 46, 9); D.line(88, 46, 92, 46, 9)
    local dy = (s.drip / 2.2) ^ 3 * 6
    D.px(92, 47 + dy, 13)
    -- le piastrelle: punti agli incroci, quasi niente
    for y = 10, 50, 8 do for x = 4, 60, 8 do D.px(x, y, 2 + n) end end
    s.me:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA FINESTRA DEL VICINO: alle otto si accende, ogni sera; poi una sera no
-------------------------------------------------------------------------------
S.vicino = {
  init = function(s)
    s.me = D.figura(16, 64, { s = 2.0, l = 12, pose = "window", face = 1 })
    s.old = D.figura(88, 34, { s = 0.6, l = 13, pose = "sit", face = -1, bent = 10 })
    s.cyc = 0; s.lit = 0; s.night = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 34 then s.cyc = 0; s.night = s.night + 1 end
    local should = s.cyc > 6 and s.cyc < 28 and (s.night % 4 ~= 3)
    s.lit = D.lerp(s.lit, should and 1 or 0, dt * 3)
    think(s.old, function() return pick({ { { "pose", "sit", R(4, 8) } }, { { "pose", "sit_read", R(3, 5) } }, { { "pose", "head_down", 3 } } }) end)
    s.old:update(dt)
    think(s.me, function() return pick({ { { "pose", "window", R(6, 10) } }, { { "pose", "head_down", 4 } } }) end)
    s.me:update(dt)
  end,
  draw = function(s, t)
    local ox = sin(t * 0.03) * 3
    cam(ox, 0, function()
      -- il palazzo di fronte: il bordo e le finestre spente
      box(60, 6, 60, 58, 3)
      for r = 0, 3 do for c = 0, 3 do
        local x, y = 64 + c * 14, 10 + r * 13
        if not (r == 1 and c == 2) then box(x, y, 9, 9, 3) end
      end end
      -- la sua finestra
      local L = s.lit
      box(92, 23, 9, 9, 3 + L * 8)
      if L > 0.1 then
        D.line(93, 31, 100, 31, 8 * L); D.px(94, 26, 10 * L)
        s.old.l = 13 * L
        s.old.x, s.old.y = 98, 31
        s.old:draw()
      end
      -- la luna
      D.circle(30, 10, 3, 9)
    end)
    -- la nostra finestra: il telaio in primo piano e la nostra figura di spalle
    D.line(0, 4, 50, 4, 5); D.line(50, 4, 50, 64, 5); D.line(0, 40, 50, 40, 4)
    s.me:draw()
    bars(0.35)
  end,
}

-------------------------------------------------------------------------------
-- L'ARMADIO DEI SUOI VESTITI: il cappello con la veletta
-------------------------------------------------------------------------------
S.armadio = {
  init = function(s)
    s.fig = D.figura(-12, 58, { s = KS, l = 13, speed = 2.5,
      prop = function(x, y, f) if s.hat then local hx, hy = f.x + f.face * 1.5, f.y - 25 * f.s / KS - 2; D.line(hx - 4, hy, hx + 4, hy, 14); D.rect(hx - 2, hy - 3, 4, 3, 13); D.line(hx + 4, hy, hx + 5, hy + 3, 7) end end })
    s.open = 0; s.want = 0; s.hat = false
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 50, 2.5 }, { "face", 1 }, { "fn", function() s.want = 1 end }, { "pose", "stand", 3 }, { "pose", "reach_up", 2 },
      { "fn", function() s.hat = true end }, { "pose", "arms_open", 2 }, { "pose", "stand", 5 }, { "pose", "head_down", 4 }, { "pose", "reach_up", 2 },
      { "fn", function() s.hat = false end }, { "fn", function() s.want = 0 end }, { "pose", "stand", 3 }, { "walk", -14, 2.5 }, { "wait", 6 } } end)
    s.open = D.lerp(s.open, s.want, dt * 0.8)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    stanza(3, 58)
    local o = s.open
    -- l'armadio: le due ante che si aprono verso di noi
    box(66, 8, 40, 50, 6)
    local w = 20 * (1 - o)
    D.line(66, 8, 66 - 10 * o, 6, 6); D.line(66 - 10 * o, 6, 66 - 10 * o, 60, 6); D.line(86 - 20 * o + w * 0, 8, 86, 8, 5)
    D.line(106, 8, 106 + 10 * o, 6, 6); D.line(106 + 10 * o, 6, 106 + 10 * o, 60, 6)
    if o > 0.1 then
      -- dentro: l'asta, i vestiti appesi, le scarpe appaiate, la cappelliera
      D.line(68, 16, 104, 16, 8 * o)
      for i = 0, 5 do
        local x = 71 + i * 6
        local sw = sin(t * 0.5 + i) * 0.4
        screen.level(D.lv(5 + o * 6)); screen.move(x, 16); screen.line(x - 2 + sw, 18); screen.line(x - 3 + sw, 40 + (i % 2) * 6); screen.line(x + 3 + sw, 40 + (i % 2) * 6); screen.line(x + 2 + sw, 18); screen.close(); screen.stroke()
      end
      for i = 0, 3 do D.line(70 + i * 9, 56, 74 + i * 9, 56, 9 * o) end
      D.line(70, 12, 84, 12, 8 * o)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ATTACCO DI PANICO: il corridoio si inclina, il cuore, il respiro
-------------------------------------------------------------------------------
S.panico = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = 1.3, l = 14, pose = "stand", face = 1 })
    s.beat = 0; s.hb = 0; s.cut = 0; s.breath = 0
  end,
  update = function(s, dt, t)
    local tor = mac("tormento")
    local rate = 1.3 + tor * 1.6 + mac("battito") * 0.8
    local old = s.beat
    s.beat = s.beat + dt * rate
    if floor(old) ~= floor(s.beat) then s.hb = 1; if random() < tor * 0.35 then s.cut = 0.08 end end
    s.hb = max(0, s.hb - dt * 4)
    s.cut = max(0, s.cut - dt)
    s.breath = s.breath + dt * (0.12 + mac("respiro") * 0.1)
    think(s.fig, function() return pick({ { { "pose", "hands_face", R(3, 5) } }, { { "pose", "bend", R(2, 4) } }, { { "pose", "kneel", 3 }, { "pose", "stand", 2 } }, { { "pose", "head_down", 3 } } }) end)
    s.fig.shake = 0.3 + tor * 0.6
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local tor = mac("tormento")
    if s.cut > 0 then return end        -- il taglio a nero, sul battito
    local ox, oy = tremor(t, 0.3 + tor)
    local tilt = sin(t * 0.4) * (4 + tor * 8)
    cam(ox, oy, function()
      -- gli scaffali del supermercato che convergono, inclinati
      local vx, vy = 64, 30
      for i = 0, 5 do
        local y = 6 + i * 9
        D.line(0, y + tilt * (1 - i / 5), vx - 14, vy + (y - vy) * 0.3, 4 + s.hb * 4)
        D.line(127, y - tilt * (1 - i / 5), vx + 14, vy + (y - vy) * 0.3, 4 + s.hb * 4)
      end
      D.line(0, 64, vx - 10, 40, 5); D.line(127, 64, vx + 10, 40, 5)
      -- il carrello abbandonato
      D.line(96, 54, 112, 54, 8); D.line(96, 54, 98, 46, 8); D.line(98, 46, 114, 46, 8); D.line(112, 54, 114, 46, 8)
      D.circle(98, 57, 1.2, 8, true); D.circle(110, 57, 1.2, 8, true)
      s.fig:draw()
      -- il respiro: un cerchio che si allarga e torna, da seguire
      local b = 0.5 - 0.5 * cos(s.breath * 2 * pi)
      D.circle(s.fig.x, s.fig.y - 14, 6 + b * 14, 3 + mac("respiro") * 6, true)
    end)
    -- il bordo che pulsa col cuore: si stringe
    if s.hb > 0 then
      local k = floor(s.hb * 3 * (0.5 + tor))
      for i = 0, k do screen.level(D.lv(6 - i)); screen.rect(i + 0.5, i + 0.5, 127 - i * 2, 63 - i * 2); screen.stroke() end
    end
  end,
}

-------------------------------------------------------------------------------
-- L'EMICRANIA: lo zigzag di luce, la stanza al buio a mezzogiorno
-------------------------------------------------------------------------------
S.emicrania = {
  init = function(s)
    s.fig = D.figura(76, 52, { s = KS, l = 12, pose = "lie", face = -1 })
    s.pulse = 0; s.a = 0
  end,
  update = function(s, dt, t)
    local tor = mac("tormento")
    s.pulse = max(0, s.pulse - dt * 1.5)
    s.a = s.a + dt * 0.2
    think(s.fig, function() return pick({ { { "pose", "lie", R(6, 10) } }, { { "pose", "curl", R(5, 8) } }, { { "pose", "sit_edge", 2 }, { "pose", "hands_face", 3 }, { "pose", "lie", 4 } } }) end)
    s.fig.shake = tor * 0.3
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local tor = mac("tormento")
    local lu = mac("luce")
    -- le tapparelle: righe sottili, con la luce che filtra fra le stecche
    box(14, 8, 30, 30, 4)
    for y = 10, 36, 2 do D.line(15, y, 43, y, 1 + lu * 3 + (y % 6 == 0 and 2 or 0)) end
    D.line(0, 54, 127, 54, 3)
    -- il letto e la pezza bagnata
    D.line(58, 52, 118, 52, 6); D.line(58, 52, 58, 58, 5); D.line(118, 46, 118, 58, 6)
    s.fig:draw()
    D.line(s.fig.x - 6, s.fig.y - 4, s.fig.x - 2, s.fig.y - 4, 12)
    -- l'aura: un arco a zigzag che luccica e si allarga, sul bordo della vista
    local r = 14 + (s.a % 1) * 30
    local px, py
    for k = 0, 16 do
      local a = -2.4 + k * 0.12
      local rr = r + ((k % 2 == 0) and 2 or -2)
      local x, y = 40 + cos(a) * rr, 30 + sin(a) * rr
      if px then D.line(px, py, x, y, 6 + tor * 9 * (0.5 + 0.5 * sin(t * 18 + k))) end
      px, py = x, y
    end
    -- la luce che batte dietro l'occhio
    if s.pulse > 0 then D.circle(s.fig.x - 4, s.fig.y - 6, 2 + s.pulse * 4, s.pulse * 10, true) end
  end,
  note = function(s, ev) if ev.str == "cluster" or ev.str == "fm" then s.pulse = 1 end end,
}

-------------------------------------------------------------------------------
-- IL RONZIO: il fischio sottile che viene da dentro
-------------------------------------------------------------------------------
S.ronzio = {
  init = function(s)
    s.fig = D.figura(46, 54, { s = KS, l = 13, pose = "sit_edge", face = 1 })
    s.radio = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_edge", R(6, 10) } }, { { "pose", "hands_face", R(3, 5) } }, { { "pose", "sit_think", 4 } } }) end)
    s.fig:update(dt)
    s.radio = D.lerp(s.radio, mac("radio"), dt)
  end,
  draw = function(s, t)
    local tor = mac("tormento")
    -- la stanza quasi non c'è: il bordo del letto e il comodino
    D.line(20, 54, 80, 54, 4); D.line(20, 54, 20, 60, 3); D.line(80, 48, 80, 60, 4)
    box(90, 44, 14, 14, 3)
    -- la radio sul comodino: la lancetta e il led
    D.line(92, 40, 102, 40, 6); D.line(92, 36, 102, 36, 5); D.line(94 + s.radio * 6, 36, 94 + s.radio * 6, 40, 12)
    D.px(100, 38, 4 + s.radio * 11)
    s.fig:draw()
    -- il fischio: una linea sottilissima, altissima, che trema e non si ferma
    local px, py
    local amp = 0.5 + tor * 2.5
    for x = 0, 128, 2 do
      local y = 10 + sin(x * 0.9 + t * 40) * amp * (0.5 + 0.5 * sin(x * 0.05 + t))
      if px then D.line(px, py, x, y, 7 + tor * 8 - s.radio * 4) end
      px, py = x, y
    end
  end,
}

-------------------------------------------------------------------------------
-- IL PRONTO SOCCORSO: il numero che non chiamano mai
-------------------------------------------------------------------------------
S.pronto_soccorso = {
  init = function(s)
    s.me = D.figura(40, 56, { s = KS * 0.9, l = 13, pose = "sit", face = 1 })
    s.n = 41; s.door = 0; s.str = nil; s.tick = 0
  end,
  update = function(s, dt, t)
    s.tick = s.tick + dt
    if s.tick > 25 then s.tick = 0; s.n = s.n + 1; S.env.sfx("bell", 880, 0.03, 0.6, 0.4, 0.4, 0) end
    if not s.str and random() < dt * 0.04 then s.str = { x = 140 } end
    if s.str then
      s.str.x = s.str.x - dt * 22
      if s.str.x < -40 then s.str = nil end
    end
    local want = (s.str and s.str.x > 70 and s.str.x < 130) and 1 or 0
    s.door = D.lerp(s.door, want, dt * 3)
    think(s.me, function() return pick({ { { "pose", "hands_face", R(4, 8) } }, { { "pose", "sit", R(4, 8) } }, { { "pose", "sit_think", 4 } } }) end)
    s.me:update(dt)
  end,
  draw = function(s, t)
    local fl = (D.noise(t * 3) > 0.92) and 0.5 or 1
    -- il neon lungo, le sedie avvitate in fila
    D.line(20, 3, 90, 3, 10 * fl)
    D.line(0, 56, 127, 56, 3)
    for i = 0, 5 do local x = 8 + i * 12; D.line(x, 48, x + 8, 48, 6); D.line(x + 8, 48, x + 8, 40, 5); D.line(x + 2, 48, x + 2, 56, 3) end
    -- il tabellone con il numero
    box(52, 12, 24, 10, 5); txt(64, 20, tostring(s.n), 12, true)
    -- il distributore
    box(4, 18, 14, 30, 4); for i = 0, 3 do D.line(6, 22 + i * 5, 16, 22 + i * 5, 6) end; D.px(14, 44, 12)
    -- le porte automatiche
    local d = s.door * 10
    D.line(100 - d, 14, 100 - d, 56, 7); D.line(110 + d, 14, 110 + d, 56, 7); D.line(98, 14, 112, 14, 5)
    if s.str then
      local x = s.str.x
      D.line(x, 46, x + 26, 46, 10); D.line(x + 2, 46, x + 2, 54, 6); D.line(x + 24, 46, x + 24, 54, 6)
      D.circle(x + 4, 44, 1.6, 12); D.line(x + 6, 44, x + 22, 44, 11)
    end
    s.me:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'INSONNIA: 2:14, 3:02, 4:40; il primo uccello
-------------------------------------------------------------------------------
S.insonnia = {
  init = function(s)
    s.fig = D.figura(60, 46, { s = KS, l = 12, pose = "lie", face = 1 })
    s.min = 120 + random(0, 30)
    s.flip = 0
  end,
  update = function(s, dt, t)
    s.min = s.min + dt * 1.8
    if s.min > 330 then s.min = 120 end
    s.flip = s.flip - dt
    if s.flip < 0 then
      s.flip = R(6, 12)
      s.fig.face = -s.fig.face
      s.fig:act({ { "pose", pick({ "lie", "curl", "lie_face" }), 3 } })
      S.env.sfx("breath", 300, 0.02, 1.4, 0, 0.3, 0.2)
    end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local dawn = D.clamp((s.min - 280) / 50, 0, 1)
    -- la sveglia: le cifre sono l'unica luce
    local h, m = floor(s.min / 60), floor(s.min % 60)
    txt(112, 40, string.format("%d:%02d", h, m), 12, true)
    D.line(100, 44, 124, 44, 4)
    -- il letto e il cuscino girato
    D.line(30, 48, 96, 48, 6); D.line(30, 48, 30, 58, 5); D.line(96, 44, 96, 58, 5)
    D.line(38, 44, 50, 44, 8)
    s.fig:draw()
    -- la finestra che schiarisce e l'uccello all'alba
    box(14, 6, 20, 20, 3 + dawn * 7)
    if dawn > 0.5 then D.line(24, 18, 26, 17, 12); D.line(26, 17, 28, 18, 12) end
    -- il soffitto, e il pensiero che gira: un cerchio che si chiude
    local px, py
    for k = 0, 20 do
      local a = t * 0.8 + k * 0.3
      local x, y = 64 + cos(a) * (8 + k * 0.4), 18 + sin(a) * (4 + k * 0.2)
      if px then D.line(px, py, x, y, 2 + k * 0.2) end
      px, py = x, y
    end
  end,
}

-------------------------------------------------------------------------------
-- LA TELEFONATA DI NOTTE: prima ancora di rispondere, lo sai
-------------------------------------------------------------------------------
S.telefonata = {
  init = function(s)
    s.fig = D.figura(110, 58, { s = KS, l = 13, speed = 2.5, on_step = H.steps("legno", 0.3) })
    s.ring = 0; s.st = 0; s.rt = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      return { { "fn", function() s.st = 1 end }, { "wait", 4 }, { "walk", 48, 2.5 }, { "face", -1 }, { "pose", "phone", 0.1 }, { "fn", function() s.st = 2 end },
        { "pose", "phone", 10 }, { "fn", function() s.st = 3 end }, { "pose", "head_down", 3 }, { "pose", "sit_ground", 10 }, { "pose", "hands_face", 8 },
        { "pose", "stand", 2 }, { "walk", 110, 2 }, { "fn", function() s.st = 0 end }, { "wait", 6 } }
    end)
    s.fig:update(dt)
    local old = s.rt
    s.rt = s.rt + dt
    if s.st == 1 then
      if floor(old / 2) ~= floor(s.rt / 2) then S.env.sfx("bell", 1300, 0.035, 0.8, -0.2, 0.9, 0) end
      if s.rt % 2 < 1 then s.ring = 1 end
    end
    s.ring = max(0, s.ring - dt * 1.5)
  end,
  draw = function(s, t)
    -- il corridoio: la porta della camera aperta, la luce che non c'è
    D.line(0, 58, 127, 58, 3)
    box(100, 18, 18, 40, 3)
    -- il tavolino e il telefono che vibra
    D.line(30, 44, 54, 44, 6); D.line(32, 44, 32, 58, 4); D.line(52, 44, 52, 58, 4)
    local jx = s.ring > 0.5 and sin(t * 60) * 1 or 0
    if s.st ~= 2 then D.rect(38 + jx, 40, 8, 4, 10); D.line(38 + jx, 39, 46 + jx, 39, 13) else D.rect(38, 42, 8, 2, 8) end
    if s.ring > 0 then for k = 1, 3 do D.circle(42, 41, k * 5 * (1.2 - s.ring * 0.4), s.ring * (8 - k * 2), true) end end
    -- il filo, quando lo tieni
    if s.st == 2 then D.line(42, 42, s.fig.hand[1], s.fig.hand[2], 6) end
    s.fig:draw()
    -- dopo: il silenzio, le bande che si chiudono
    bars(s.st == 3 and 0.9 or 0.3)
  end,
}

-------------------------------------------------------------------------------
-- LA STANZA CHE SI STRINGE: le pareti si avvicinano quando non guardi
-------------------------------------------------------------------------------
S.stanza_stretta = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = KS, l = 14, speed = 3 })
    s.w = 0
  end,
  update = function(s, dt, t)
    local tor = mac("tormento")
    s.w = s.w + dt * (0.006 + tor * 0.02)
    if s.w > 1 then s.w = 0 end
    think(s.fig, function() return pick({
      { { "walk", 40 - s.w * 20, 3 }, { "face", -1 }, { "pose", "push", R(3, 5) } },
      { { "walk", 88 + s.w * 20, 3 }, { "face", 1 }, { "pose", "push", R(3, 5) } },
      { { "pose", "kneel", 3 }, { "pose", "hands_face", 4 } }, { { "pose", "look_up", 3 } } }) end)
    s.fig.shake = tor * 0.3
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local k = ease(s.w)
    local L, Rr = 4 + k * 30, 124 - k * 30
    local top = 4 + k * 22
    local ox, oy = tremor(t, mac("tormento") * 0.4)
    cam(ox, oy, function()
      -- le pareti, il soffitto, la porta sempre più piccola
      D.line(L, top, L, 58, 9); D.line(Rr, top, Rr, 58, 9); D.line(L, top, Rr, top, 8); D.line(L, 58, Rr, 58, 7)
      D.line(0, 64, L, 58, 4); D.line(127, 64, Rr, 58, 4); D.line(0, 0, L, top, 3); D.line(127, 0, Rr, top, 3)
      local dw = 10 * (1 - k * 0.6)
      box(Rr - dw - 4, 58 - dw * 2.4, dw, dw * 2.4, 5)
      -- la parete respira
      for i = 0, 4 do local y = top + (58 - top) * (i + 0.5) / 5; D.px(L + 1 + sin(t * 2 + i) * 0.5, y, 6); D.px(Rr - 1 - sin(t * 2 + i) * 0.5, y, 6) end
      s.fig.x = D.clamp(s.fig.x, L + 6, Rr - 6)
      s.fig:draw()
    end)
  end,
}

-------------------------------------------------------------------------------
-- LA CREPA NEL SOFFITTO: ogni notte un po' più lunga
-------------------------------------------------------------------------------
S.crepa = {
  init = function(s)
    s.fig = D.figura(66, 50, { s = KS, l = 12, pose = "lie", face = 1 })
    s.pts = { { 20, 8 } }
    s.grain = D.parts(6)
  end,
  update = function(s, dt, t)
    local tor = mac("tormento")
    if random() < dt * (0.15 + tor * 0.6) and #s.pts < 60 then
      local p = s.pts[#s.pts]
      s.pts[#s.pts + 1] = { p[1] + R(1, 3), D.clamp(p[2] + R(-1.5, 1.5), 3, 14) }
      if #s.pts >= 60 then s.pts = { { 20, 8 } } end
      if random() < 0.3 then D.spawn(s.grain, { x = p[1], y = p[2], vx = 0, vy = 2, life = 8 }) end
    end
    D.parts_update(s.grain, dt, function(q, d) q.vy = q.vy + 10 * d; if q.y > 44 then q.vy = 0 end end)
    think(s.fig, function() return pick({ { { "pose", "lie", R(8, 14) } }, { { "pose", "curl", R(6, 10) } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.line(0, 2, 127, 2, 3)
    -- la crepa: la punta più chiara, il resto quasi spento
    for i = 2, #s.pts do
      local a, b = s.pts[i - 1], s.pts[i]
      local age = (#s.pts - i)
      D.line(a[1], a[2], b[1], b[2], max(3, 13 - age * 0.4))
      if i % 7 == 0 then D.line(b[1], b[2], b[1] + 2, b[2] + 3, 4) end
    end
    -- il letto, il cuscino, la figura che guarda in su
    D.line(36, 46, 110, 46, 6); D.line(36, 46, 36, 56, 5); D.line(110, 40, 110, 56, 5); D.line(98, 42, 108, 42, 8)
    s.fig:draw()
    for _, q in ipairs(s.grain.list) do D.px(q.x, q.y, 10) end
  end,
}

-------------------------------------------------------------------------------
-- L'INCENDIO: la casa brucia; tu sei fuori a guardare
-------------------------------------------------------------------------------
S.incendio = {
  init = function(s)
    s.me = D.figura(18, 62, { s = 1.6, l = 13, pose = "stand", face = 1 })
    s.emb = D.parts(40); s.smoke = D.parts(16)
    s.roof = 0
  end,
  update = function(s, dt, t)
    local f = 0.5 + mac("fuoco") * 0.5
    for i = 1, 2 do if random() < dt * 14 * f then D.spawn(s.emb, { x = R(56, 112), y = R(20, 40), vx = R(-4, 8) + mac("vento") * 10, vy = -R(10, 24), life = R(1.5, 3) }) end end
    D.parts_update(s.emb, dt)
    D.smoke_update(s.smoke, dt, 84, 10, 2, t, 4 + mac("vento") * 6)
    s.roof = s.roof + dt * 0.02
    if s.roof > 1.2 then s.roof = 0 end
    think(s.me, function() return pick({ { { "pose", "stand", R(5, 8) } }, { { "pose", "hands_face", 4 } }, { { "pose", "scream", 2 }, { "pose", "head_down", 4 } }, { { "pose", "kneel", 5 } } }) end)
    s.me:update(dt)
  end,
  draw = function(s, t)
    local tor = mac("tormento")
    local ox, oy = tremor(t, 0.2 + tor * 0.6)
    cam(ox, oy, function()
      D.smoke_draw(s.smoke, 3)
      -- la casa: muri e tetto, il tetto che cede
      local cave = min(1, s.roof) * 10
      D.line(56, 56, 56, 26, 6); D.line(112, 56, 112, 26, 6)
      D.line(56, 26, 84, 10 + cave, 6); D.line(84, 10 + cave, 112, 26, 6)
      -- le finestre piene di fuoco
      for _, w in ipairs({ { 62, 32 }, { 96, 32 }, { 80, 44 } }) do
        box(w[1], w[2], 10, 10, 8)
        D.fire(w[1] + 5, w[2] + 10, 8, 9 + sin(t * 3 + w[1]) * 2, t, 15)
      end
      if s.roof > 0.6 then D.fire(84, 18 + cave, 18, 12, t, 15) end
      for _, p in ipairs(s.emb.list) do D.px(p.x, p.y, 8 + (1 - p.age / p.life) * 7) end
      D.line(0, 56, 127, 56, 5)
      -- il riflesso del fuoco per terra
      for i = 0, 6 do D.line(60 + i * 7, 58 + (i % 2), 64 + i * 7, 58 + (i % 2), 5 + D.noise(t * 6 + i) * 6) end
      s.me:draw()
    end)
    bars(0.4)
  end,
}

-------------------------------------------------------------------------------
-- IL NAUFRAGIO: la nave si inclina, il salvagente lontano
-------------------------------------------------------------------------------
S.naufragio = {
  init = function(s)
    s.flash = 0
    s.f = D.figura(0, 0, { s = 0.8, l = 13, pose = "lean_rail", face = 1 })
  end,
  update = function(s, dt, t)
    if random() < dt * (0.06 + mac("tormento") * 0.15) then s.flash = 1; S.env.sfx("sub", 36, 0.1, 2.5, 0, 0.2, 0.05) end
    s.flash = max(0, s.flash - dt * 3)
    think(s.f, function() return pick({ { { "pose", "lean_rail", R(3, 5) } }, { { "pose", "reach_up", 2 } }, { { "pose", "kneel", 3 } } }) end)
    s.f:update(dt)
  end,
  draw = function(s, t)
    local fl = s.flash
    local m = mac("mare")
    local ox, oy = tremor(t, 0.3 + mac("tormento") * 0.5)
    cam(ox, oy + sin(t * 0.7) * 3, function()
      if fl > 0.4 then D.line(90, 0, 84, 12, 15); D.line(84, 12, 88, 14, 15); D.line(88, 14, 80, 28, 15) end
      -- la nave che si inclina: lo scafo ruotato attorno al centro
      local a = 0.25 + sin(t * 0.5) * 0.15 * (0.5 + m)
      local cx, cy = 50, 36
      local function P(x, y) return cx + x * cos(a) - y * sin(a), cy + x * sin(a) + y * cos(a) end
      local hull = { { -26, 0 }, { 26, 0 }, { 20, 8 }, { -22, 8 } }
      for i = 1, 4 do local p, q = hull[i], hull[i % 4 + 1]; local x1, y1 = P(p[1], p[2]); local x2, y2 = P(q[1], q[2]); D.line(x1, y1, x2, y2, 9 + fl * 6) end
      local mx1, my1 = P(-4, 0); local mx2, my2 = P(-4, -26); D.line(mx1, my1, mx2, my2, 8 + fl * 5)
      local cx1, cy1 = P(4, 0); local cx2, cy2 = P(4, -8); D.line(cx1, cy1, cx2, cy2, 6)
      local fx, fy = P(10, 0)
      s.f.x, s.f.y = fx, fy
      s.f:draw()
      -- le onde: creste che salgono e coprono
      for r = 0, 5 do
        local y0 = 34 + r * 5
        local px, py
        for x = 0, 128, 4 do
          local y = y0 + sin(x * 0.07 + t * (1.2 + r * 0.2) + r) * (2 + m * 4) - (r == 0 and 0 or 0)
          if px then D.line(px, py, x, y, 4 + r + fl * 6) end
          px, py = x, y
        end
      end
      -- il salvagente, lontano
      local bx, by = 108, 44 + sin(t * 1.1) * 4
      D.circle(bx, by, 2.5, 13, true); D.px(bx, by, 0)
    end)
    if fl > 0.7 then D.flash(fl * 3) end
  end,
}

-------------------------------------------------------------------------------
-- IL BUCO NERO: ogni cosa gira intorno e ci cade dentro
-------------------------------------------------------------------------------
local NOMI_BN = { { "luce", "giorni", "nomi", "voglia", "sabato", "ridere", "fame", "estate" }, { "light", "days", "names", "wanting", "saturday", "laughing", "hunger", "summer" } }
S.buco_nero = {
  init = function(s)
    s.p = {}
    for i = 1, 60 do s.p[i] = { a = R(0, 6.28), r = R(14, 70), v = R(0.2, 0.6) } end
    s.words = {}
    s.fig = D.figura(100, 50, { s = 0.9, l = 13, pose = "float", face = -1 })
    s.fr = 60
  end,
  update = function(s, dt, t)
    local pr = 0.4 + mac("profondita") * 0.8
    for _, q in ipairs(s.p) do
      q.a = q.a + dt * q.v * (40 / q.r)
      q.r = q.r - dt * q.v * 3 * pr
      if q.r < 7 then q.r = R(50, 70); q.a = R(0, 6.28) end
    end
    if random() < dt * 0.1 and #s.words < 4 then s.words[#s.words + 1] = { w = H.w(NOMI_BN), a = R(0, 6.28), r = 60 } end
    for i = #s.words, 1, -1 do local w = s.words[i]; w.a = w.a + dt * 0.8 * (40 / w.r); w.r = w.r - dt * 4 * pr; if w.r < 16 then table.remove(s.words, i) end end
    s.fr = s.fr - dt * 0.6 * pr
    if s.fr < 12 then s.fr = 60 end
    s.fig.x = 64 + cos(t * 0.05) * s.fr; s.fig.y = 34 + sin(t * 0.05) * s.fr * 0.35 + 8
    s.fig.l = 6 + 8 * D.clamp((s.fr - 12) / 30, 0, 1)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local cx, cy = 64, 32
    -- il disco: punti che girano più veloci vicino al centro
    for _, q in ipairs(s.p) do
      local x, y = cx + cos(q.a) * q.r, cy + sin(q.a) * q.r * 0.35
      D.px(x, y, 3 + min(12, 120 / q.r))
    end
    -- l'anello di luce e il nero al centro
    D.circle(cx, cy, 8, 13, true)
    D.circle(cx, cy, 7, 0)
    for _, w in ipairs(s.words) do
      local x, y = cx + cos(w.a) * w.r, cy + sin(w.a) * w.r * 0.35
      txt(floor(x), floor(y), w.w, min(10, w.r / 5))
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL FONDO: più giù non si va; in alto, un quadrato di luce
-------------------------------------------------------------------------------
S.fondo = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = 1.2, l = 13, pose = "lie", face = 1 })
    s.drip = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "lie", R(12, 18) }, { "pose", "curl", 6 }, { "pose", "sit_ground", 5 }, { "pose", "kneel", 4 }, { "pose", "stand", 3 }, { "pose", "look_up", 10 }, { "pose", "reach_up", 6 }, { "pose", "sit_ground", 4 } } end)
    s.fig:update(dt)
    s.drip = s.drip + dt
    if s.drip > 3.5 then s.drip = 0; S.env.sfx("drop", 900 + random() * 300, 0.03, 0.6, 0, 0.6, 0) end
  end,
  draw = function(s, t)
    -- la panoramica: quando ti alzi, la macchina guarda in su con te
    local up = (s.fig.tgt == D.POSE.look_up or s.fig.tgt == D.POSE.reach_up) and 1 or 0
    s.oy = D.lerp(s.oy or 0, up * 30, 0.02)
    cam(0, s.oy, function()
      -- le pareti del pozzo che salgono e si stringono
      D.line(10, 64, 44, -60, 4); D.line(118, 64, 84, -60, 4)
      for i = 0, 8 do local y = 60 - i * 14; D.px(10 + (64 - y) * 0.27 + 2, y, 5); D.px(118 - (64 - y) * 0.27 - 2, y, 5) end
      -- il quadrato di luce, lassù
      box(58, -56, 12, 8, 15)
      rays(64, -48, 52, 76, 58, 1.5 + up * 2, 4)
      -- la pietra, la goccia
      D.line(14, 60, 114, 60, 5)
      local dy = (s.drip / 3.5) ^ 2 * 100
      if dy < 100 then D.px(70, -40 + dy, 12) end
      s.fig:draw()
    end)
  end,
}

-------------------------------------------------------------------------------
-- IL DESERTO DI CENERE: le impronte si richiudono, un uccello vivo
-------------------------------------------------------------------------------
S.cenere = {
  init = function(s)
    s.fig = D.figura(-10, 56, { s = 1.0, l = 13, speed = 2, bent = 8, on_step = function(f) s.prints[#s.prints + 1] = { x = f.x, age = 0 } end })
    s.prints = {}
    s.ash = D.parts(70)
  end,
  update = function(s, dt, t)
    local v = mac("vento")
    for i = 1, 3 do if random() < dt * 20 then D.spawn(s.ash, { x = R(-10, 138), y = -2, vx = R(-2, 2) + v * 8, vy = R(3, 6), life = 14 }) end end
    D.parts_update(s.ash, dt, function(q) if q.y > 58 then q.life = 0 end end)
    for i = #s.prints, 1, -1 do local p = s.prints[i]; p.age = p.age + dt; if p.age > 4 then table.remove(s.prints, i) end end
    think(s.fig, function() return { { "walk", 140, 2 }, { "fn", function(f) f.x = -10 end }, { "wait", 3 } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox = sin(t * 0.02) * 4
    cam(ox, 0, function()
      D.line(0, 40, 127, 40, 4)
      D.line(0, 56, 127, 56, 3)
      -- l'albero bruciato e l'uccello sopra, l'unica cosa chiara
      D.thick(104, 56, 103, 26, 1.5, 6); D.line(103, 34, 94, 26, 5); D.line(103, 30, 112, 22, 5); D.line(112, 22, 116, 23, 4)
      D.circle(112, 20.5, 1.2, 14); D.px(113, 19, 15)
      for _, p in ipairs(s.prints) do D.line(p.x - 1, 57, p.x + 1, 57, 8 * (1 - p.age / 4)) end
      s.fig:draw()
      for _, q in ipairs(s.ash.list) do D.px(q.x, q.y, 5) end
    end)
    bars(0.5)
  end,
}

-------------------------------------------------------------------------------
-- LE CATENE: sbattono tra loro; una si spezza e cade
-------------------------------------------------------------------------------
S.catene = {
  init = function(s)
    s.ch = {}
    for i = 1, 7 do s.ch[i] = { x = 10 + i * 15, len = R(24, 46), a = 0, v = R(-0.3, 0.3), fall = nil, hit = 0 } end
    s.fig = D.figura(64, 60, { s = 1.2, l = 14, pose = "kneel", face = 1 })
  end,
  update = function(s, dt, t)
    local tor = mac("tormento")
    for i, c in ipairs(s.ch) do
      c.hit = max(0, c.hit - dt * 3)
      if c.fall then
        c.fall = c.fall + dt * 40
        if c.fall > 90 then c.fall = nil; c.len = R(24, 46) end
      else
        c.v = c.v + (-c.a * 2 + (D.noise(t * 0.6 + i * 3) - 0.5) * (0.6 + tor * 2)) * dt
        c.v = c.v * (1 - dt * 0.4)
        c.a = c.a + c.v * dt
        local n = s.ch[i + 1]
        if n and not n.fall then
          local x1 = c.x + sin(c.a) * c.len
          local x2 = n.x + sin(n.a) * n.len
          if x2 - x1 < 3 and abs(c.v - n.v) > 0.05 then
            c.v, n.v = n.v * 0.8, c.v * 0.8; c.hit = 1; n.hit = 1
            S.env.sfx("bell", 600 + random() * 500, 0.03 * (0.4 + tor), 0.5, H.pan(c.x), 1, 0)
          end
        end
        if random() < dt * 0.006 then c.fall = 0; S.env.sfx("drop", 220, 0.05, 1.6, H.pan(c.x), 0.3, 0) end
      end
    end
    think(s.fig, function() return pick({ { { "pose", "kneel", R(6, 10) } }, { { "pose", "pray", R(4, 6) } }, { { "pose", "hands_face", 4 } }, { { "pose", "look_up", 3 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, mac("tormento") * 0.3)
    cam(ox, oy, function()
      for _, c in ipairs(s.ch) do
        local y0 = c.fall or 0
        local n = floor(c.len / 3)
        for k = 0, n do
          local r = k * 3
          local x, y = c.x + sin(c.a) * r, y0 + cos(c.a) * r
          if k % 2 == 0 then D.circle(x, y, 1.2, 6 + c.hit * 9, true) else D.line(x, y - 1, x, y + 1, 6 + c.hit * 9) end
        end
      end
      D.line(0, 60, 127, 60, 3)
      s.fig:draw()
    end)
  end,
}

-------------------------------------------------------------------------------
-- LA FRANA: la montagna si muove; quando la polvere si posa, un filo d'erba
-------------------------------------------------------------------------------
S.frana = {
  init = function(s)
    s.rocks = {}
    s.dust = D.parts(50)
    s.fig = D.figura(16, 62, { s = 1.4, l = 13, pose = "stand", face = 1 })
    s.cyc = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 50 then s.cyc = 0 end
    local active = s.cyc < 28
    if active and random() < dt * (2 + mac("tormento") * 4) then
      s.rocks[#s.rocks + 1] = { x = R(70, 120), y = R(8, 16), vx = -R(8, 20), vy = 0, r = R(1, 3.5), sp = R(0, 6) }
      if random() < 0.3 then S.env.sfx("sub", 44 + random() * 10, 0.05, 1.2, 0.3, 0.3, 0) end
    end
    for i = #s.rocks, 1, -1 do
      local r = s.rocks[i]
      r.vy = r.vy + 40 * dt; r.x = r.x + r.vx * dt; r.y = r.y + r.vy * dt; r.sp = r.sp + dt * 6
      local gy = 14 + (120 - r.x) * 0.5
      if r.y > gy then r.y = gy; r.vy = -r.vy * 0.4; for k = 1, 2 do D.spawn(s.dust, { x = r.x, y = r.y, vx = R(-6, 6), vy = -R(2, 6), life = 3 }) end end
      if r.x < 20 or r.y > 64 then table.remove(s.rocks, i) end
    end
    D.parts_update(s.dust, dt, function(q, d) q.vx = q.vx * (1 - d) end)
    think(s.fig, function()
      if active then return pick({ { { "pose", "hands_face", 3 } }, { { "pose", "arms_open", 1 }, { "pose", "stand", 2 } }, { { "pose", "kneel", 3 } } }) end
      return { { "pose", "bend", 4 }, { "pose", "kneel", 6 } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local active = s.cyc < 28
    local ox, oy = tremor(t, active and (0.4 + mac("tormento") * 0.6) or 0)
    cam(ox, oy, function()
      -- il pendio e la cresta
      D.line(20, 64, 120, 14, 6); D.line(120, 14, 127, 18, 6)
      D.line(60, 6, 90, 0, 3); D.line(30, 20, 60, 6, 3)
      for _, r in ipairs(s.rocks) do D.circle(r.x, r.y - r.r, r.r, 10, true); D.px(r.x + cos(r.sp) * r.r * 0.6, r.y - r.r + sin(r.sp) * r.r * 0.6, 13) end
      for _, q in ipairs(s.dust.list) do D.px(q.x, q.y, 4 + (1 - q.age / q.life) * 3) end
      -- dopo: il filo d'erba
      if not active then
        local g = D.clamp((s.cyc - 32) / 8, 0, 1)
        D.line(36, 62, 36 + sin(t) * 0.5, 62 - g * 5, 14)
        if g > 0.8 then D.px(37, 57, 15) end
      end
      s.fig:draw()
    end)
  end,
}

end
