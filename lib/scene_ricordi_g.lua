-- ANAMNESI · scene dei ricordi (v6): il cielo, le alture, l'infanzia
-- Il fondo è nero. Le cose si disegnano con poche linee basse,
-- le persone sono di luce. Il cinema lo fanno la macchina da presa
-- (carrellate, panoramiche verticali, mano a spalla), i tagli di
-- inquadratura, le bande del formato largo, e la luce che si accende.
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

-------------------------------------------------------------------------------
-- LA MACCHINA DA PRESA
-------------------------------------------------------------------------------
-- tutto quello che fn disegna si sposta di (ox, oy): carrellate e panoramiche
function H.cam(ox, oy, fn)
  ox, oy = floor(ox + 0.5), floor(oy + 0.5)
  if ox == 0 and oy == 0 then fn(); return end
  local sm, sl, sr, sc, sp, scu, sa = screen.move, screen.line, screen.rect, screen.circle, screen.pixel, screen.curve, screen.arc
  screen.move = function(x, y) sm(x + ox, y + oy) end
  screen.line = function(x, y) sl(x + ox, y + oy) end
  screen.rect = function(x, y, w, h) sr(x + ox, y + oy, w, h) end
  screen.circle = function(x, y, r) sc(x + ox, y + oy, r) end
  screen.pixel = function(x, y) sp(x + ox, y + oy) end
  if scu then screen.curve = function(a, b, c, d, e, f) scu(a + ox, b + oy, c + ox, d + oy, e + ox, f + oy) end end
  if sa then screen.arc = function(x, y, r, a1, a2) sa(x + ox, y + oy, r, a1, a2) end end
  local ok, err = pcall(fn)
  screen.move, screen.line, screen.rect, screen.circle, screen.pixel, screen.curve, screen.arc = sm, sl, sr, sc, sp, scu, sa
  if not ok then error(err, 0) end
end

-- macchina a mano: un respiro lento dell'inquadratura
function H.hand(t, a)
  a = a or 1
  return (D.noise(t * 0.23) - 0.5) * 3 * a, (D.noise(t * 0.19 + 40) - 0.5) * 2 * a
end

-- le bande nere del formato largo (k da 0 a 1)
function H.bars(k)
  if k <= 0.02 then return end
  local h = floor(k * 8 + 0.5)
  screen.level(0); screen.rect(0, 0, 128, h); screen.fill()
  screen.rect(0, 64 - h, 128, h); screen.fill()
end

-- il montaggio: durate delle inquadrature in ciclo; ritorna l'inquadratura e il tempo dentro
function H.shot(t, lens)
  local tot = 0
  for _, d in ipairs(lens) do tot = tot + d end
  local u = t % tot
  for i, d in ipairs(lens) do
    if u < d then return i, u, d end
    u = u - d
  end
  return 1, 0, lens[1]
end

-- l'orizzonte: una sola linea, con qualche segno d'erba o di sasso
function H.horizon(y, l, seed, t, wind)
  D.line(0, y, 127, y, l)
  local r = D.lcg(seed or 3)
  for i = 1, 26 do
    local x = r() * 128
    local h = 1 + r() * 2
    local sw = wind and sin(t * 2 + x * 0.2) * wind or 0
    D.line(x, y, x + sw, y - h, l - 1)
  end
end

-- raggi di luce: poche linee sottili invece di un velo
function H.rays(x, y, x1, x2, y2, l, n)
  n = n or 5
  for i = 0, n - 1 do
    local k = (i + 0.5) / n
    D.line(x, y, x1 + (x2 - x1) * k, y2, l * (0.6 + 0.4 * sin(k * pi)))
  end
end


-- il bordo di una nuvola: solo la linea di sopra, niente riempimento
function H.cloud_edge(x, y, w, l, seed)
  local r = D.lcg(seed or 5)
  local bumps = {}
  for i = 1, floor(w / 6) + 2 do bumps[i] = { cx = x + r() * w, rr = 2 + r() * w * 0.16 } end
  local px, py
  for xx = x - 2, x + w + 2, 2 do
    local top = y
    for _, b in ipairs(bumps) do
      local d = abs(xx - b.cx)
      if d < b.rr then local h = sqrt(b.rr * b.rr - d * d); if y - h < top then top = y - h end end
    end
    if px then D.line(px, py, xx, top, l) end
    px, py = xx, top
  end
end

local function easeio(k) k = D.clamp(k, 0, 1); return k * k * (3 - 2 * k) end
H.ease = easeio

-- testo piccolo
local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(s) else screen.text(s) end
end

D.POSE.wave = { lean = -2, nod = -10, ua1 = 150, ua2 = 6, fa1 = 130 , fa2 = -4, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.push = { lean = 24, nod = 8, ua1 = 85, ua2 = 80, fa1 = 95, fa2 = 92, th1 = 20, th2 = -22, sh1 = 6, sh2 = -26, hy = 6.9, rot = 0 }
D.POSE.crouch = { lean = 30, nod = 12, ua1 = 40, ua2 = 30, fa1 = 80, fa2 = 70, th1 = 110, th2 = 104, sh1 = -20, sh2 = -26, hy = 3.4, rot = 0 }
D.POSE.conduct = { lean = -2, nod = -8, ua1 = 120, ua2 = 100, fa1 = 150, fa2 = 120, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }

-------------------------------------------------------------------------------
-- L'ARPA DEL VENTO: i fili tesi sul crinale, che il vento fa cantare
-------------------------------------------------------------------------------
S.arpa_vento = {
  init = function(s)
    s.fig = D.figura(36, 52, { s = 1.0, l = 13, pose = "sit_ground", face = 1 })
    s.str = {}
    for i = 1, 6 do s.str[i] = { a = 0, ph = R(0, 6) } end
    s.gust = D.parts(16)
    s.ridge = D.ridge_gen(41, 50, 6, 0.6)
  end,
  update = function(s, dt, t)
    local v = mac("vento")
    for _, st in ipairs(s.str) do st.a = max(0, st.a - dt * 1.2) end
    if random() < dt * (1 + v * 6) then D.spawn(s.gust, { x = -4, y = R(6, 46), vx = R(30, 60) * (0.5 + v), vy = R(-2, 2), life = 4 }) end
    D.parts_update(s.gust, dt)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(6, 10) } }, { { "pose", "look_up", 0.1 }, { "pose", "sit_think", R(5, 8) } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox = sin(t * 0.04) * 6
    H.cam(ox, 0, function()
      D.ridge_line(s.ridge, 4, 0)
      H.horizon(52, 4, 9, t, 0.6 + mac("vento"))
      -- i due pali e i fili
      D.thick(70, 52, 70, 18, 1.4, 6); D.thick(112, 52, 112, 14, 1.4, 6)
      for i, st in ipairs(s.str) do
        local y1, y2 = 20 + i * 3.2, 16 + i * 3.4
        local amp = (0.3 + mac("vento") * 0.8) * (0.4 + st.a * 2.2)
        local px, py = 70, y1
        for k = 1, 10 do
          local x = 70 + k * 4.2
          local y = y1 + (y2 - y1) * k / 10 + sin(k / 10 * pi) * sin(t * (14 + i * 3) + st.ph) * amp
          D.line(px, py, x, y, 7 + st.a * 8)
          px, py = x, y
        end
      end
      for _, p in ipairs(s.gust.list) do D.line(p.x, p.y, p.x - 5, p.y, 3) end
      s.fig:draw()
    end)
  end,
  note = function(s, ev) local st = s.str[random(#s.str)]; st.a = 1 end,
}

-------------------------------------------------------------------------------
-- LA NEVE CHE SALE: i fiocchi lasciano la terra; la macchina sale con loro
-------------------------------------------------------------------------------
S.neve_luce = {
  init = function(s)
    s.fig = D.figura(60, 56, { s = 1.05, l = 13, pose = "stand" })
    s.fl = {}
    for i = 1, 70 do s.fl[i] = { x = R(0, 128), y = R(-70, 60), v = R(2, 6), ph = R(0, 6) } end
    s.st = D.stars_gen(50, 19, -64, -10)
  end,
  update = function(s, dt, t)
    for _, f in ipairs(s.fl) do
      f.y = f.y - f.v * dt * (0.6 + mac("vetro") * 0.5)
      f.x = f.x + sin(t * 0.7 + f.ph) * dt * 2
      if f.y < -70 then f.y = 58; f.x = R(0, 128) end
    end
    think(s.fig, function() return pick({ { { "pose", "reach_up", R(4, 6) }, { "pose", "stand", 3 } }, { { "pose", "look_up", R(5, 8) } }, { { "walk", R(40, 80), 2 }, { "pose", "look_up", 4 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- la panoramica: dal prato al cielo e ritorno, in quaranta secondi
    local k = easeio(0.5 - 0.5 * cos(t * 2 * pi / 40))
    local oy = k * 52
    H.cam(0, oy, function()
      D.stars(s.st, t, 0.8)
      H.horizon(56, 5, 4, t, 0.2)
      for i = 0, 5 do D.pine(8 + i * 22, 56, 9 + (i % 3) * 3, 4, sin(t + i) * 0.3) end
      s.fig:draw()
      for _, f in ipairs(s.fl) do
        local b = 6 + 6 * (0.5 + 0.5 * sin(t * 2 + f.ph))
        D.px(f.x, f.y, b)
      end
    end)
    H.bars(0.3 + k * 0.5)
  end,
}

-------------------------------------------------------------------------------
-- L'ORCHESTRA DELLE NUVOLE: arrivano uno alla volta, poi il direttore
-------------------------------------------------------------------------------
S.orchestra = {
  init = function(s)
    s.mus = {}
    for i = 1, 6 do
      local x = 14 + (i - 1) * 16
      s.mus[i] = { fig = D.figura(-10 - i * 14, 52, { s = 0.9, l = 11, pose = "stand", speed = 5 }), x = x, sat = false }
    end
    s.dir = D.figura(112, 54, { s = 1.05, l = 14, pose = "stand", face = -1 })
    s.cyc = 0; s.hit = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    for i, m in ipairs(s.mus) do
      if s.cyc > i * 4 and not m.sat then
        m.sat = true
        m.fig:act({ { "walk", m.x, 5 }, { "face", 1 }, { "pose", "play", 999 } })
      end
      m.fig:update(dt)
    end
    if s.cyc > 30 then
      think(s.dir, function() return pick({ { { "pose", "conduct", R(1, 2) }, { "pose", "arms_open", 1 } }, { { "pose", "conduct", 2 } }, { { "pose", "stand", 1 } } }) end)
    end
    s.dir:update(dt)
    s.hit = max(0, s.hit - dt * 2)
    if s.cyc > 90 then
      s.cyc = 0
      for i, m in ipairs(s.mus) do m.sat = false; m.fig:clear(); m.fig.x = -10 - i * 14; m.fig:set("stand"); m.fig.idle = true end
    end
  end,
  draw = function(s, t)
    -- le nuvole: solo il bordo, che scorre piano
    for i = 0, 4 do H.cloud_edge((i * 34 + t * 1.2) % 170 - 30, 60 + (i % 2), 26, 4, i + 2) end
    D.line(0, 54, 127, 54, 4)
    -- leggii e sedie
    for _, m in ipairs(s.mus) do
      D.line(m.x + 5, 54, m.x + 5, 44, 5); D.line(m.x + 3, 44, m.x + 8, 42, 7)
      D.line(m.x - 2, 54, m.x - 2, 49, 4); D.line(m.x - 3, 49, m.x + 1, 49, 4)
    end
    -- la luce dall'alto sul direttore, quando c'è
    if s.cyc > 28 then H.rays(112, 0, 102, 122, 54, 2 + s.hit * 3, 4) end
    for _, m in ipairs(s.mus) do m.fig:draw() end
    s.dir:draw()
    if s.cyc > 30 and s.dir.cur.ua1 > 100 then D.line(s.dir.hand[1], s.dir.hand[2], s.dir.hand[1] - 4, s.dir.hand[2] - 3, 14) end
    H.bars(0.5)
  end,
  note = function(s, ev) s.hit = 1 end,
}

-------------------------------------------------------------------------------
-- IL RITORNO: la tavola lunga sulle nuvole, un posto anche per te
-------------------------------------------------------------------------------
S.ritorno = {
  init = function(s)
    s.ospiti = {}
    local xs = { 18, 32, 46, 74, 88, 102 }
    for i, x in ipairs(xs) do
      s.ospiti[i] = D.figura(x, 52, { s = 1.0, l = 9 + (i % 3), pose = "sit", face = (x < 60) and 1 or -1, dress = i % 2 == 0, bun = i == 2 })
    end
    s.me = D.figura(-12, 52, { s = 1.0, l = 15, speed = 4 })
    s.state = 0; s.k = 0
  end,
  update = function(s, dt, t)
    for _, o in ipairs(s.ospiti) do
      think(o, function() return pick({ { { "pose", "sit", R(4, 8) } }, { { "pose", "talk", R(2, 4) } }, { { "pose", "sit_read", R(2, 3) } } }) end)
      o:update(dt)
    end
    think(s.me, function()
      if s.state == 0 then s.state = 1; return { { "wait", 4 }, { "walk", 60, 4 }, { "face", 1 }, { "pose", "sit", 22 }, { "fn", function() s.state = 2 end } } end
      s.state = 0
      return { { "pose", "stand", 1 }, { "walk", 140, 4 }, { "fn", function(f) f.x = -12 end } }
    end)
    s.me:update(dt)
    s.k = D.lerp(s.k, s.me.x > 40 and s.me.x < 80 and 1 or 0, dt * 0.4)
  end,
  draw = function(s, t)
    -- la carrellata si avvicina piano alla sedia vuota mentre arrivi
    local ox = -s.k * 4
    H.cam(ox, 0, function()
      for i = 0, 3 do H.cloud_edge((i * 44 + t * 0.8) % 180 - 30, 62, 34, 4, i + 9) end
      -- la tavola: il bordo della tovaglia, le gambe, i piatti
      D.line(8, 45, 120, 45, 8); D.line(8, 46, 120, 46, 4)
      D.line(12, 46, 12, 56, 4); D.line(116, 46, 116, 56, 4)
      for i = 0, 13 do D.line(12 + i * 8, 46, 12 + i * 8 + 2, 48, 3) end
      -- la sedia vuota, finché non ti siedi
      if s.me.cur.hy > 6 or abs(s.me.x - 60) > 2 then D.line(56, 52, 56, 40, 6); D.line(56, 46, 63, 46, 6); D.line(63, 46, 63, 52, 6) end
      for i = 0, 6 do
        local x = 18 + i * 14
        D.line(x - 2, 44, x + 2, 44, 9)
        if i % 2 == 0 then D.candle(x + 6, 44, t, 6, 3, 3) end
      end
      for _, o in ipairs(s.ospiti) do o:draw() end
      s.me:draw()
    end)
    H.bars(0.35)
  end,
}

-------------------------------------------------------------------------------
-- LA SCALA NEL CIELO: chi sale, chi scende; uno si ferma e saluta
-------------------------------------------------------------------------------
S.scala_cielo = {
  init = function(s)
    s.ups = {}
    for i = 1, 3 do s.ups[i] = { y = R(-50, 50), v = R(3, 5) * pick({ -1, 1 }), stop = 0, f = D.figura(66, 0, { s = 0.7, l = 12, pose = "reach_up" }) } end
    s.me = D.figura(30, 58, { s = 1.1, l = 14, pose = "look_up", face = 1 })
    s.st = D.stars_gen(40, 33, -60, 20)
  end,
  update = function(s, dt, t)
    for _, u in ipairs(s.ups) do
      if u.stop > 0 then
        u.stop = u.stop - dt
        if u.stop <= 0 then u.f:set("reach_up") end
      else
        u.y = u.y + u.v * dt
        if random() < dt * 0.03 then u.stop = 5; u.f:set("wave"); u.f.face = -1 end
      end
      if u.y < -60 then u.y = 58 elseif u.y > 58 then u.y = -60 end
      u.f.y = u.y; u.f:update(dt)
    end
    think(s.me, function() return pick({ { { "pose", "look_up", R(6, 10) } }, { { "pose", "wave", 3 }, { "pose", "look_up", 4 } } }) end)
    s.me:update(dt)
  end,
  draw = function(s, t)
    local oy = 18 + sin(t * 2 * pi / 50) * 20
    H.cam(0, oy * 0.6, function()
      D.stars(s.st, t, 0.7)
      H.horizon(58, 4, 12, t, 0.3)
      -- la scala: due montanti e i pioli, più luminosi verso l'alto
      for y = -60, 56, 4 do
        local b = 6 + 7 * (1 - (y + 60) / 120)
        D.line(60, y, 72, y, b * (0.7 + 0.3 * sin(t * 1.5 + y * 0.2)))
      end
      D.line(60, -60, 60, 58, 8); D.line(72, -60, 72, 58, 8)
      for _, u in ipairs(s.ups) do u.f:draw() end
      s.me:draw()
    end)
    H.bars(0.4)
  end,
}

-------------------------------------------------------------------------------
-- IL CAMPO DI VETRO: ogni passo fa suonare un filo d'erba
-------------------------------------------------------------------------------
S.campo_vetro = {
  init = function(s)
    s.bl = {}
    for i = 1, 90 do s.bl[i] = { x = R(0, 128), y = R(40, 62), h = R(3, 8), ring = 0 } end
    table.sort(s.bl, function(a, b) return a.y < b.y end)
    s.fig = D.figura(10, 56, { s = 1.05, l = 13, speed = 2.5, on_step = function(f)
      for _, b in ipairs(s.bl) do if abs(b.x - f.x) < 6 and abs(b.y - f.y) < 6 then b.ring = 1 end end
      S.env.sfx("bell", 1800 + random() * 1600, 0.025 * (0.4 + mac("vetro")), 1.2, H.pan(f.x), 0.8, 0)
    end })
  end,
  update = function(s, dt, t)
    for _, b in ipairs(s.bl) do b.ring = max(0, b.ring - dt * 0.7) end
    think(s.fig, function() return { { "walk", R(10, 118), 2.5 }, { "pose", pick({ "stand", "look_up", "head_down" }), R(3, 6) } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local v = mac("vento")
    local ox, oy = H.hand(t, 1)
    H.cam(ox, oy, function()
      D.line(0, 40, 127, 40, 3)
      local drawn = false
      for _, b in ipairs(s.bl) do
        if not drawn and b.y > s.fig.y then s.fig:draw(); drawn = true end
        local sw = sin(t * 1.5 + b.x * 0.1) * v * 1.5 + sin(t * 30) * b.ring * 0.6
        local l = 4 + (b.y - 40) * 0.15 + b.ring * 10
        D.line(b.x, b.y, b.x + sw, b.y - b.h, l)
        if b.ring > 0.5 then D.px(b.x + sw, b.y - b.h - 1, 15) end
      end
      if not drawn then s.fig:draw() end
    end)
  end,
  note = function(s, ev) local b = s.bl[random(#s.bl)]; b.ring = 0.8 end,
}

-------------------------------------------------------------------------------
-- IL MULINO A VENTO: le pale e la loro ombra che passa sul grano
-------------------------------------------------------------------------------
S.mulino = {
  init = function(s)
    s.kid = D.figura(26, 58, { s = 0.85, l = 13, child = true, pose = "lie", face = 1 })
    s.a = 0
    s.ridge = D.ridge_gen(5, 46, 5, 0.5)
  end,
  update = function(s, dt, t)
    local v = 0.2 + mac("vento") * 0.8
    local old = s.a
    s.a = s.a + dt * v * 0.8
    if floor(old / (pi / 2)) ~= floor(s.a / (pi / 2)) then S.env.sfx("step", 300, 0.02, 0.2, 0.3, 0.3, 0) end
    think(s.kid, function() return pick({ { { "pose", "lie", R(8, 14) } }, { { "pose", "sit_ground", R(4, 6) }, { "pose", "lie", 4 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    D.ridge_line(s.ridge, 4, 0)
    -- il mulino: la torre a tronco di cono, solo contorno
    D.line(84, 46, 88, 18, 6); D.line(100, 46, 96, 18, 6); D.line(88, 18, 96, 18, 6)
    D.line(86, 18, 92, 13, 6); D.line(98, 18, 92, 13, 6)
    D.rect(90, 38, 4, 8, 2); D.rect(91, 28, 2, 3, 9)
    -- le pale
    local cx, cy = 92, 20
    for i = 0, 3 do
      local a = s.a + i * pi / 2
      local ex, ey = cx + cos(a) * 20, cy + sin(a) * 20
      D.line(cx, cy, ex, ey, 9)
      local nx, ny = -sin(a) * 3, cos(a) * 3
      D.line(cx + cos(a) * 6 + nx, cy + sin(a) * 6 + ny, ex + nx, ey + ny, 5)
      -- l'ombra di ogni pala sul campo
      local sx = cx - 30 + cos(a) * 40
      D.line(sx - 6, 56 + sin(a), sx + 6, 57 + sin(a), 2)
    end
    D.circle(cx, cy, 1.5, 12)
    -- il grano
    for i = 0, 42 do
      local x = i * 3 + 1
      local sw = sin(t * 1.4 + i * 0.4) * (0.5 + mac("vento"))
      D.line(x, 58, x + sw, 54 - (i % 3), 4); D.px(x + sw, 53 - (i % 3), 7)
    end
    s.kid:draw()
    H.bars(0.3)
  end,
}

-------------------------------------------------------------------------------
-- IL MARE DI NEBBIA: le cime che spuntano, la campana attutita
-------------------------------------------------------------------------------
S.mare_nebbia = {
  init = function(s)
    s.fig = D.figura(18, 30, { s = 0.9, l = 13, pose = "sit_ground", face = 1 })
    s.bell = 0
  end,
  update = function(s, dt, t)
    s.bell = max(0, s.bell - dt * 0.6)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(8, 12) } }, { { "pose", "sit_think", R(5, 8) } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    -- il sole basso: un disco netto e un anello
    D.circle(104, 14, 3.5, 10 + lu * 4); D.circle(104, 14, 6, 3, true)
    -- la collina in primo piano
    D.line(0, 30, 30, 32, 6); D.line(30, 32, 44, 40, 6); D.line(44, 40, 52, 64, 6)
    -- le cime che bucano la nebbia
    D.line(70, 40, 70, 30, 7); D.line(68, 30, 72, 30, 7); D.poly({ 68, 30, 72, 30, 70, 25 }, 7); D.px(70, 33, 12 + s.bell * 3)
    for i, x in ipairs({ 86, 92, 112, 120 }) do D.pine(x, 42, 6 + (i % 2) * 3, 5, 0) end
    -- il mare bianco: righe tratteggiate che scorrono a velocità diverse
    local nb = 0.5 + mac("nebbia") * 0.5
    for r = 0, 6 do
      local y = 40 + r * 3.5
      local off = (t * (2 + r * 0.7)) % 8
      for x = -8 + off, 128, 8 do D.line(x, y, x + 4 + r * 0.3, y, (3 + r * 0.5) * nb) end
    end
    if s.bell > 0 then D.circle(70, 32, 4 + (1 - s.bell) * 10, s.bell * 6, true) end
    s.fig:draw()
  end,
  note = function(s, ev) if ev.str == "campana" then s.bell = 1 end end,
}

-------------------------------------------------------------------------------
-- LE CASTAGNE: il nonno sbuccia, il bambino si punge e ride
-------------------------------------------------------------------------------
S.castagne = {
  init = function(s)
    s.nonno = D.figura(70, 58, { s = 1.15, l = 12, pose = "bend", face = -1, bent = 6 })
    s.kid = D.figura(46, 58, { s = 0.8, l = 14, child = true, pose = "stand", face = 1, speed = 3 })
    s.leaves = D.parts(18)
    s.ricci = {}
    for i = 1, 9 do s.ricci[i] = { x = R(6, 122), y = R(56, 62) } end
  end,
  update = function(s, dt, t)
    if random() < dt * (0.5 + mac("foglie") * 2) then D.spawn(s.leaves, { x = R(0, 128), y = -2, vx = R(-3, 3), vy = R(4, 8), life = 12, ph = R(0, 6) }) end
    D.parts_update(s.leaves, dt, function(p, d) p.x = p.x + sin(p.age * 2 + p.ph) * d * 6; if p.y > 60 then p.vy = 0; p.vx = 0 end end)
    think(s.nonno, function() return pick({ { { "pose", "bend", R(3, 5) }, { "pose", "hold", R(2, 4) } }, { { "pose", "stand", 2 }, { "walk", R(60, 90), 2 }, { "face", -1 }, { "pose", "bend", 3 } } }) end)
    s.nonno:update(dt)
    think(s.kid, function() return pick({ { { "pose", "kneel", R(3, 5) }, { "pose", "stand", 1 }, { "pose", "arms_open", 1.5 } }, { { "walk", R(30, 56), 3 }, { "face", 1 }, { "pose", "hold", 3 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    -- i tronchi, solo il bordo, e i rami alti
    for i, x in ipairs({ 8, 34, 98, 120 }) do D.line(x, 0, x - 1, 58, 4); D.line(x + 4, 0, x + 3, 58, 3); D.bare_tree(x + 2, 20, 18, 3, i, sin(t * 0.3) * 0.2) end
    D.line(0, 58, 127, 58, 4)
    for _, r in ipairs(s.ricci) do
      D.circle(r.x, r.y, 1.6, 5, true)
      for k = 0, 5 do local a = k * pi / 3 + 0.3; D.px(r.x + cos(a) * 2.6, r.y + sin(a) * 2.6, 6) end
      D.px(r.x, r.y, 9)
    end
    for _, p in ipairs(s.leaves.list) do D.line(p.x - 1, p.y, p.x + 1, p.y - 1, 6) end
    s.kid:draw(); s.nonno:draw()
    if s.nonno.cur.ua1 < 50 then D.circle(s.nonno.hand[1], s.nonno.hand[2], 1, 13) end
  end,
}

-------------------------------------------------------------------------------
-- LA SORGENTE: l'acqua dalla roccia, le mani a coppa
-------------------------------------------------------------------------------
S.sorgente = {
  init = function(s)
    s.fig = D.figura(60, 58, { s = 1.15, l = 13, pose = "stand", face = 1, speed = 3 })
    s.drops = D.parts(40)
    s.rip = {}
  end,
  update = function(s, dt, t)
    for i = 1, 3 do if random() < dt * 25 then D.spawn(s.drops, { x = 86 + R(-0.5, 0.5), y = 30, vx = -R(4, 6), vy = R(0, 2), life = 2 }) end end
    D.parts_update(s.drops, dt, function(p, d) p.vy = p.vy + 60 * d; if p.y > 56 then p.life = 0; if random() < 0.1 then s.rip[#s.rip + 1] = { x = p.x, r = 0 } end end end)
    for i = #s.rip, 1, -1 do local r = s.rip[i]; r.r = r.r + dt * 5; if r.r > 8 then table.remove(s.rip, i) end end
    think(s.fig, function() return { { "walk", 72, 3 }, { "face", 1 }, { "pose", "kneel", 2 }, { "pose", "dig", R(3, 5) }, { "pose", "kneel", 2 }, { "pose", "stand", 2 }, { "walk", R(30, 50), 3 }, { "pose", "look_up", 5 } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- la roccia: contorno spezzato
    D.line(84, 0, 90, 18, 5); D.line(90, 18, 86, 30, 5); D.line(86, 30, 94, 44, 5); D.line(94, 44, 128, 50, 5)
    D.line(98, 10, 104, 22, 3); D.line(110, 30, 118, 36, 3)
    -- il cannello e l'acqua
    D.line(86, 30, 89, 30, 9)
    for _, p in ipairs(s.drops.list) do D.px(p.x, p.y, 12) end
    -- la vasca
    D.line(60, 56, 96, 56, 7); D.line(60, 56, 62, 60, 5); D.line(96, 56, 94, 60, 5)
    for _, r in ipairs(s.rip) do D.line(r.x - r.r, 57, r.x + r.r, 57, 9 * (1 - r.r / 8)) end
    D.line(0, 60, 127, 60, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL PIANOFORTE NEL BOSCO: ancora suona, stonato e bellissimo
-------------------------------------------------------------------------------
S.piano_bosco = {
  init = function(s)
    s.fig = D.figura(-10, 56, { s = 1.15, l = 13, speed = 3, on_step = H.steps("foglie", 0.3) })
    s.keys = {}
    for i = 1, 14 do s.keys[i] = 0 end
    s.bird = nil
    s.seated = false
  end,
  update = function(s, dt, t)
    for i = 1, 14 do s.keys[i] = max(0, s.keys[i] - dt * 2) end
    think(s.fig, function()
      if not s.seated then s.seated = true; return { { "walk", 54, 3 }, { "face", 1 }, { "pose", "play", 40 } } end
      s.seated = false
      return { { "pose", "stand", 2 }, { "walk", 140, 3 }, { "fn", function(f) f.x = -10 end }, { "wait", 4 } }
    end)
    s.fig:update(dt)
    if s.bird then
      local b = s.bird
      b.x = b.x + b.vx * dt; b.y = b.y + b.vy * dt; b.vy = b.vy - 4 * dt
      if b.y < -10 then s.bird = nil end
    end
  end,
  draw = function(s, t)
    for i, x in ipairs({ 10, 26, 100, 118 }) do D.line(x, 0, x, 56, 3); D.line(x + 3, 0, x + 2, 56, 2) end
    for i = 0, 6 do D.tree(4 + i * 20, 20, 14, 2, i + 30, sin(t * 0.4 + i) * 0.3) end
    D.line(0, 56, 127, 56, 3)
    -- il pianoforte verticale: contorno, il muschio, i tasti
    D.line(62, 30, 92, 30, 7); D.line(62, 30, 62, 56, 6); D.line(92, 30, 92, 56, 6)
    D.line(60, 41, 94, 41, 7); D.line(60, 44, 94, 44, 4)
    for i = 1, 14 do D.line(61 + i * 2.3, 41, 61 + i * 2.3, 43, 5 + s.keys[i] * 10) end
    for i = 0, 7 do D.px(64 + i * 3.6, 30 - (i % 2), 5) end
    D.circle(84, 34, 2, 4, true)
    s.fig:draw()
    if s.bird then
      local b = s.bird
      local w = sin(t * 18) * 2
      D.line(b.x - 2, b.y - w, b.x, b.y, 12); D.line(b.x, b.y, b.x + 2, b.y - w, 12)
    end
  end,
  note = function(s, ev)
    s.keys[1 + ((ev.midi or random(60)) % 14)] = 1
    if not s.bird and random() < 0.04 then s.bird = { x = 84, y = 34, vx = R(10, 20), vy = -8 } end
  end,
}

-------------------------------------------------------------------------------
-- LA FUNIVIA: la cabina segue il filo, i pini passano sotto
-------------------------------------------------------------------------------
S.funivia = {
  init = function(s)
    s.off = 0; s.sw = 0; s.swv = 0
    s.fig = D.figura(0, 0, { s = 0.7, l = 13, pose = "hold", face = 1 })
    s.kid = D.figura(0, 0, { s = 0.55, l = 15, child = true, pose = "look_up", face = 1 })
  end,
  update = function(s, dt, t)
    local old = s.off
    s.off = s.off + dt * 9
    -- passare il pilone: un sobbalzo
    if floor(old / 90) ~= floor(s.off / 90) then s.swv = s.swv + 0.6; S.env.sfx("sub", 50, 0.05, 0.6, 0, 0.3, 0) end
    local wv = mac("vento")
    s.swv = s.swv + (-s.sw * 3 + (D.noise(t * 0.4) - 0.5) * wv * 2) * dt
    s.swv = s.swv * (1 - dt * 0.6)
    s.sw = s.sw + s.swv * dt
    s.fig:update(dt); s.kid:update(dt)
  end,
  draw = function(s, t)
    -- la macchina segue la cabina: il paesaggio scorre via
    local o = s.off
    -- i crinali lontani, quasi fermi
    for i = 0, 8 do local x = ((i * 30 - o * 0.1) % 270) - 30; D.line(x, 50, x + 15, 36, 3); D.line(x + 15, 36, x + 30, 50, 3) end
    -- i pini sotto, più veloci
    for i = 0, 10 do local x = ((i * 17 - o * 0.6) % 190) - 20; D.pine(x, 64, 8 + (i % 3) * 3, 5, 0) end
    -- il filo e il pilone
    D.line(0, 18, 127, 10, 7); D.line(0, 20, 127, 12, 4)
    local px = (60 - (o % 90) * 2.2)
    if px > -10 and px < 140 then D.line(px, 13, px - 4, 64, 6); D.line(px + 4, 13, px + 8, 64, 6); for y = 20, 60, 8 do D.line(px - 2, y, px + 6, y + 8, 3) end end
    -- la cabina appesa che dondola
    local cx, cy = 64, 14
    local a = s.sw * 0.25
    local bx, by = cx + sin(a) * 14, cy + cos(a) * 14
    D.line(cx, cy, bx, by, 8)
    D.line(bx - 12, by, bx + 12, by, 9); D.line(bx - 12, by, bx - 12, by + 14, 8); D.line(bx + 12, by, bx + 12, by + 14, 8); D.line(bx - 12, by + 14, bx + 12, by + 14, 9)
    D.line(bx - 12, by + 5, bx + 12, by + 5, 4)
    s.fig.x = bx - 4; s.fig.y = by + 14; s.kid.x = bx + 5; s.kid.y = by + 14
    s.fig:draw(); s.kid:draw()
    H.bars(0.4)
  end,
}

-------------------------------------------------------------------------------
-- NASCONDINO: dietro la legnaia, i passi si avvicinano e passano oltre
-------------------------------------------------------------------------------
S.nascondino = {
  init = function(s)
    s.kid = D.figura(84, 58, { s = 0.85, l = 14, child = true, pose = "crouch", face = -1 })
    s.seek = D.figura(-12, 58, { s = 0.9, l = 11, child = true, speed = 4, on_step = H.steps("erba", 0.25) })
    s.heart = 0
  end,
  update = function(s, dt, t)
    think(s.seek, function() return { { "wait", R(2, 4) }, { "walk", R(40, 70), 3 }, { "pose", "look_up", 1.5 }, { "face", 1 }, { "wait", 2 }, { "walk", 140, 4 }, { "fn", function(f) f.x = -12 end } } end)
    s.seek:update(dt)
    local d = abs(s.seek.x - s.kid.x)
    s.heart = s.heart + dt * (1.2 + max(0, 50 - d) * 0.06)
    think(s.kid, function() return pick({ { { "pose", "crouch", R(6, 10) } }, { { "pose", "kneel", 2 }, { "pose", "crouch", 4 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.line(0, 58, 127, 58, 4)
    -- la casa lontana con una finestra
    D.line(4, 58, 4, 34, 3); D.line(4, 34, 18, 26, 3); D.line(18, 26, 32, 34, 3); D.line(32, 34, 32, 58, 3)
    D.rect(14, 40, 5, 5, 4 + lu * 6)
    -- la legnaia: tronchetti tondi impilati
    for r = 0, 3 do for c = 0, 4 - (r > 2 and 1 or 0) do D.circle(92 + c * 6 + (r % 2) * 3, 55 - r * 5, 2.4, 5, true); D.px(92 + c * 6 + (r % 2) * 3, 55 - r * 5, 6) end end
    s.seek:draw(); s.kid:draw()
    -- il cuore del bambino: un punto che batte
    local hb = (sin(s.heart * pi * 2) > 0.85) and 15 or 6
    D.px(s.kid.x - 1, s.kid.y - 8, hb)
  end,
}

-------------------------------------------------------------------------------
-- LE BOLLE DI SAPONE: una sale più in alto di tutte
-------------------------------------------------------------------------------
S.bolle = {
  init = function(s)
    s.kid = D.figura(30, 58, { s = 0.9, l = 14, child = true, pose = "stand", face = 1 })
    s.b = {}
    s.pops = D.parts(30)
  end,
  update = function(s, dt, t)
    think(s.kid, function() return { { "pose", "torch", 1 }, { "fn", function(f)
      for i = 1, random(2, 4) do s.b[#s.b + 1] = { x = f.x + 6, y = f.y - 16, vx = R(4, 12), vy = -R(2, 6), r = R(1.5, 4), age = 0, life = R(3, 9), ph = R(0, 6) } end
    end }, { "pose", "stand", R(2, 3) }, { "pose", "look_up", R(1, 2) } } end)
    s.kid:update(dt)
    for i = #s.b, 1, -1 do
      local b = s.b[i]
      b.age = b.age + dt
      b.x = b.x + b.vx * dt + sin(t * 2 + b.ph) * dt * 3 * (1 + mac("vento"))
      b.y = b.y + b.vy * dt
      b.vx = b.vx * (1 - dt * 0.3)
      if b.age > b.life or b.x > 132 then
        for k = 1, 5 do D.spawn(s.pops, { x = b.x, y = b.y, vx = R(-8, 8), vy = R(-8, 8), life = 0.4 }) end
        table.remove(s.b, i)
      end
    end
    D.parts_update(s.pops, dt)
  end,
  draw = function(s, t)
    D.line(0, 58, 127, 58, 4)
    D.line(108, 58, 108, 22, 3); D.line(100, 58, 100, 30, 3); D.line(100, 30, 108, 22, 3)
    s.kid:draw()
    for _, b in ipairs(s.b) do
      D.circle(b.x, b.y, b.r, 9, true)
      D.px(b.x - b.r * 0.4, b.y - b.r * 0.4, 15)
    end
    for _, p in ipairs(s.pops.list) do D.px(p.x, p.y, 10) end
  end,
}

-------------------------------------------------------------------------------
-- LA CASA SULL'ALBERO: quattro assi storte e una scala di corda
-------------------------------------------------------------------------------
S.casa_albero = {
  init = function(s)
    s.a = D.figura(70, 30, { s = 0.8, l = 14, child = true, pose = "sit_edge", face = -1 })
    s.b = D.figura(40, 60, { s = 0.8, l = 12, child = true, speed = 3 })
    s.up = false
  end,
  update = function(s, dt, t)
    think(s.a, function() return pick({ { { "pose", "sit_edge", R(5, 9) } }, { { "pose", "point", 2 }, { "pose", "sit_edge", 3 } } }) end)
    s.a:update(dt)
    think(s.b, function()
      if not s.up then s.up = true; return { { "walk", 56, 3 }, { "face", 1 }, { "pose", "reach_up", 1 }, { "glide", 56, 31, 4 }, { "pose", "stand", 1 }, { "walk", 62, 2 }, { "pose", "sit_ground", 12 } } end
      s.up = false
      return { { "pose", "stand", 1 }, { "walk", 56, 2 }, { "glide", 56, 60, 3 }, { "walk", R(14, 40), 3 }, { "pose", "look_up", 4 } }
    end)
    s.b:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = H.hand(t, 0.8)
    H.cam(ox, oy, function()
      -- il tronco e i rami
      D.line(88, 64, 88, 2, 5); D.line(96, 64, 95, 2, 5)
      D.line(90, 20, 118, 8, 4); D.line(90, 26, 120, 30, 4); D.line(92, 12, 74, 2, 4)
      for i = 0, 5 do H.cloud_edge(70 + i * 9, 6 + (i % 2) * 6, 12, 4, i + 40) end
      -- la piattaforma storta, il tetto di lamiera
      D.line(48, 31, 92, 33, 9); D.line(48, 33, 92, 35, 5)
      D.line(52, 31, 52, 18, 6); D.line(86, 32, 86, 18, 6); D.line(48, 18, 90, 16, 7)
      -- il cartello
      D.rect(58, 21, 14, 5, 3); D.line(58, 21, 72, 21, 8); D.line(60, 23, 70, 23, 10)
      -- la scala di corda
      local sw = sin(t * 1.2) * 1
      D.line(54, 33, 54 + sw, 60, 6); D.line(58, 33, 58 + sw, 60, 6)
      for y = 37, 59, 4 do D.line(54 + sw * (y - 33) / 27, y, 58 + sw * (y - 33) / 27, y, 7) end
      D.line(0, 60, 127, 60, 4)
      s.a:draw(); s.b:draw()
    end)
  end,
}

-------------------------------------------------------------------------------
-- IL TRENINO ELETTRICO: l'otto sul tappeto, il passaggio a livello
-------------------------------------------------------------------------------
S.trenino = {
  init = function(s)
    s.kid = D.figura(18, 62, { s = 1.0, l = 14, child = true, pose = "lie_face", face = 1 })
    s.p = 0; s.der = 0
  end,
  update = function(s, dt, t)
    if s.der > 0 then
      s.der = s.der - dt
    else
      s.p = s.p + dt * 0.35 * (0.6 + mac("treno") * 0.8)
      if random() < dt * 0.01 then s.der = 5; S.env.sfx("step", 900, 0.05, 0.1, 0.2, 0.7, 0) end
    end
    think(s.kid, function() return pick({ { { "pose", "lie_face", R(8, 12) } }, { { "pose", "sit_ground", 5 }, { "pose", "lie_face", 4 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    -- il tappeto in prospettiva: un trapezio di sole linee
    D.line(20, 36, 108, 36, 3); D.line(4, 62, 124, 62, 3); D.line(20, 36, 4, 62, 3); D.line(108, 36, 124, 62, 3)
    local function eight(u) local a = u * 2 * pi; return 64 + sin(a) * 44, 48 + sin(2 * a) * 8 end
    local px, py = eight(0)
    for i = 1, 60 do local x, y = eight(i / 60); D.line(px, py, x, y, 5); px, py = x, y end
    -- il passaggio a livello
    local nx = eight(0.25)
    local near = ((s.p % 1) > 0.15 and (s.p % 1) < 0.35)
    D.line(100, 50, 100, 40, 6)
    if near then D.line(100, 40, 112, 40, 12) else D.line(100, 40, 104, 30, 9) end
    if near and (t % 0.6) < 0.3 then D.px(100, 39, 15) end
    -- la locomotiva e due carrozze
    for c = 0, 2 do
      local u = s.p - c * 0.025
      local x, y = eight(u)
      if s.der > 0 and c == 0 then x = x + 4; y = y + 3 end
      D.rect(x - 2, y - 3, 4, 3, c == 0 and 14 or 10)
      if c == 0 then
        D.px(x, y - 4, 12)
        if s.der <= 0 and (t * 2) % 1 < 0.5 then D.px(x + R(-1, 1), y - 6 - R(0, 2), 6) end
      end
    end
    s.kid:draw()
    H.bars(0.3)
  end,
}

-------------------------------------------------------------------------------
-- IL PRIMO GIORNO DI SCUOLA: la mano che ti lascia, tre volte ti giri
-------------------------------------------------------------------------------
S.primo_giorno = {
  init = function(s)
    s.mom = D.figura(-10, 58, { s = 1.2, l = 12, dress = true, bun = true, speed = 3, on_step = H.steps("pietra", 0.2) })
    s.kid = D.figura(-18, 58, { s = 0.8, l = 15, child = true, speed = 3,
      prop = function(x, y, f) D.rect(f.x - f.face * 4 - 2, f.y - 14, 4, 5, 9) end })
    s.st = 0
  end,
  update = function(s, dt, t)
    think(s.mom, function() return { { "walk", 52, 3 }, { "face", 1 }, { "wait", 26 }, { "pose", "wave", 4 }, { "pose", "stand", 6 }, { "walk", -14, 3 }, { "wait", 6 } } end)
    s.mom:update(dt)
    think(s.kid, function()
      return { { "wait", 0.1 }, { "fn", function() s.st = 1 end }, { "wait", 8 }, { "fn", function() s.st = 2 end },
        { "walk", 76, 2.5 }, { "face", -1 }, { "pose", "stand", 1.5 }, { "face", 1 }, { "walk", 88, 2.5 }, { "face", -1 }, { "pose", "stand", 1.5 },
        { "face", 1 }, { "walk", 98, 2.5 }, { "face", -1 }, { "pose", "wave", 2 }, { "face", 1 }, { "walk", 140, 2.5 }, { "wait", 18 },
        { "fn", function(f) f.x = -18; s.st = 0 end } }
    end)
    if s.st <= 1 then s.kid.x = s.mom.x - 7; s.kid.walking = s.mom.walking; s.kid.ph = s.mom.ph; s.kid.face = s.mom.face end
    s.kid:update(dt)
  end,
  draw = function(s, t)
    -- il cancello: sbarre verticali, la scuola dietro con le finestre
    D.line(70, 20, 127, 20, 3); D.line(70, 20, 70, 58, 3)
    for r = 0, 1 do for c = 0, 4 do D.rect(76 + c * 10, 26 + r * 12, 5, 6, 3) end end
    for x = 60, 127, 4 do D.line(x, 40, x, 58, 6) end
    D.line(60, 40, 127, 40, 7); D.line(60, 50, 127, 50, 4)
    D.line(0, 58, 127, 58, 4)
    s.mom:draw(); s.kid:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL GHIACCIOLO: cola sul polso più veloce di quanto riesci a mangiarlo
-------------------------------------------------------------------------------
S.ghiacciolo = {
  init = function(s)
    s.kid = D.figura(56, 56, { s = 1.2, l = 14, child = true, pose = "sit_ground", face = 1,
      prop = function(x, y, f) D.line(x, y, x + 1, y - 2, 9); D.rect(x, y - 7, 3, 5, 12) end })
    s.drip = D.parts(20)
    s.left = 1
  end,
  update = function(s, dt, t)
    local cal = mac("calore")
    s.left = s.left - dt * 0.01 * (0.5 + cal)
    if s.left < 0 then s.left = 1 end
    if random() < dt * (1 + cal * 3) then D.spawn(s.drip, { x = s.kid.hand[1] + 1, y = s.kid.hand[2], vx = 0, vy = 4, life = 2 }) end
    D.parts_update(s.drip, dt, function(p, d) p.vy = p.vy + 40 * d end)
    think(s.kid, function() return pick({ { { "pose", "hold", R(3, 5) } }, { { "pose", "blow", 2 }, { "pose", "hold", 3 } }, { { "pose", "sit_ground", 3 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    -- il sole che vibra di caldo
    for k = 0, 7 do local a = k * pi / 4 + t * 0.1; D.line(100 + cos(a) * 7, 14 + sin(a) * 7, 100 + cos(a) * (10 + sin(t * 3 + k)), 14 + sin(a) * (10 + sin(t * 3 + k)), 6 + lu * 5) end
    D.circle(100, 14, 4, 12 + lu * 3)
    -- il mare: due righe che respirano, la sabbia
    D.line(0, 40, 127, 40, 5)
    for i = 0, 5 do local x = (i * 24 + t * 3) % 140 - 10; D.line(x, 43, x + 8, 43, 3) end
    D.line(0, 56, 127, 56, 4)
    for i = 0, 30 do D.px((i * 37) % 128, 58 + (i % 5), 3) end
    -- l'ombrellone
    D.line(30, 56, 30, 26, 6); D.poly({ 14, 30, 46, 30, 30, 22 }, 4); D.line(14, 30, 46, 30, 8)
    s.kid:draw()
    for _, p in ipairs(s.drip.list) do D.px(p.x, p.y, 12) end
  end,
}

-------------------------------------------------------------------------------
-- LA PAURA DEL TEMPORALE: il lampo mostra la stanza, poi il buio di nuovo
-------------------------------------------------------------------------------
S.paura_temporale = {
  init = function(s)
    s.kid = D.figura(70, 50, { s = 0.85, l = 12, child = true, pose = "curl", face = -1 })
    s.flash = 0; s.boom = 0
    s.rain = D.parts(40)
  end,
  update = function(s, dt, t)
    local p = mac("pioggia")
    if random() < dt * (0.05 + p * 0.12) then s.flash = 1; s.boom = R(1, 3) end
    s.flash = max(0, s.flash - dt * 3)
    if s.boom > 0 then
      s.boom = s.boom - dt
      if s.boom <= 0 then S.env.sfx("sub", 38, 0.12, 2.5, 0, 0.2, 0.02); s.kid.shake = 1 end
    end
    s.kid.shake = max(0, s.kid.shake - dt * 0.5)
    for i = 1, 2 do if random() < dt * 20 * (0.3 + p) then D.spawn(s.rain, { x = R(14, 44), y = 12, vx = -2, vy = R(30, 40), life = 0.6 }) end end
    D.parts_update(s.rain, dt)
    think(s.kid, function() return pick({ { { "pose", "curl", R(6, 12) } }, { { "pose", "sit", 3 }, { "pose", "curl", 5 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local f = s.flash
    -- di solito si vedono solo la finestra e la torcia; il lampo accende il resto
    local base = 2 + f * 9
    D.line(14, 12, 44, 12, 4 + f * 10); D.line(14, 12, 14, 40, 4 + f * 10); D.line(44, 12, 44, 40, 4 + f * 10); D.line(14, 40, 44, 40, 4 + f * 10)
    D.line(29, 12, 29, 40, 3 + f * 8); D.line(14, 26, 44, 26, 3 + f * 8)
    for _, p in ipairs(s.rain.list) do D.line(p.x, p.y, p.x - 1, p.y + 2, 4 + f * 8) end
    if f > 0.5 then D.line(36, 12, 31, 20, 15); D.line(31, 20, 34, 22, 15); D.line(34, 22, 28, 34, 15) end
    -- il letto, l'armadio, la porta: esistono solo nel lampo
    D.line(56, 50, 110, 50, base); D.line(56, 50, 56, 58, base); D.line(110, 44, 110, 58, base); D.line(56, 46, 62, 46, base)
    D.line(116, 6, 116, 58, base * 0.7); D.line(126, 6, 126, 58, base * 0.7)
    D.line(0, 58, 127, 58, base * 0.6)
    -- l'ombra della finestra per terra, nel lampo
    if f > 0.2 then D.line(40, 60, 70, 62, f * 8); D.line(30, 62, 60, 64, f * 6) end
    s.kid:draw()
    -- la coperta sopra il bambino e la torcia sotto
    D.line(60, 47, 104, 47, 7); D.line(60, 47, 58, 50, 5)
    local tx = 80 + sin(t * 0.7) * 6
    H.rays(tx, 48, tx + 6, tx + 20, 44, 6, 3)
    D.px(tx, 48, 15)
  end,
}

-------------------------------------------------------------------------------
-- LA CASA DEGLI SPECCHI: lungo, largo, piccolo, vecchio
-------------------------------------------------------------------------------
S.specchi = {
  init = function(s)
    s.me = D.figura(-10, 58, { s = 1.0, l = 14, speed = 3, on_step = H.steps("legno", 0.2) })
    s.ref = {
      { x = 22, f = D.figura(22, 54, { s = 1.6, l = 9 }) },
      { x = 52, f = D.figura(52, 54, { s = 0.9, l = 9, dress = true }) },
      { x = 82, f = D.figura(82, 54, { s = 0.55, l = 9, child = true }) },
      { x = 110, f = D.figura(110, 54, { s = 1.0, l = 9, bent = 22 }) },
    }
    s.away = 0
  end,
  update = function(s, dt, t)
    think(s.me, function()
      local q = {}
      for _, r in ipairs(s.ref) do q[#q + 1] = { "walk", r.x, 3 }; q[#q + 1] = { "face", -1 }; q[#q + 1] = { "pose", pick({ "stand", "arms_open", "point" }), R(2, 4) } end
      q[#q + 1] = { "walk", 140, 3 }; q[#q + 1] = { "fn", function(f) f.x = -10 end }
      return q
    end)
    s.me:update(dt)
    s.away = max(0, s.away - dt)
    if random() < dt * 0.04 * (0.4 + mac("nevrosi") * 2) then s.away = 3 end
    for i, r in ipairs(s.ref) do
      local near = abs(s.me.x - r.x) < 10
      r.f.x = r.x + (s.me.x - r.x) * 0.3
      r.f.face = -s.me.face
      if s.away > 0 and i == 4 then r.f.face = s.me.face end
      r.f.tgt = near and s.me.tgt or D.POSE.stand
      r.f.walking = s.me.walking; r.f.ph = s.me.ph
      r.f:update(dt)
    end
  end,
  draw = function(s, t)
    for _, r in ipairs(s.ref) do
      local near = abs(s.me.x - r.x) < 10
      local fl = near and 8 or 4
      -- la cornice ovale degli specchi deformanti
      screen.level(D.lv(fl)); screen.move(r.x - 9, 12); screen.line(r.x + 9, 12); screen.line(r.x + 11, 32); screen.line(r.x + 9, 54); screen.line(r.x - 9, 54); screen.line(r.x - 11, 32); screen.close(); screen.stroke()
      if near then r.f:draw() end
    end
    D.line(0, 58, 127, 58, 4)
    for i = 0, 8 do D.px(6 + i * 15, 6, 6 + (floor(t * 3 + i) % 2) * 6) end
    s.me:draw()
  end,
}

end
