-- ANAMNESI · scene dei ricordi (v7): il cielo, le alture, l'infanzia
-- Fondo nero, persone di luce. Qui le cose suonano: l'ascia, la slitta,
-- il tamburo di latta. Le scene ascoltano i colpi del ritmo (ritmo = true)
-- e si muovono a tempo con loro.
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S
local cam, hand, bars, shot, rays, ease, cloud_edge = H.cam, H.hand, H.bars, H.shot, H.rays, H.ease, H.cloud_edge

local function box(x, y, w, h, l)
  D.line(x, y, x + w, y, l); D.line(x, y + h, x + w, y + h, l)
  D.line(x, y, x, y + h, l); D.line(x + w, y, x + w, y + h, l)
end
local function tremor(t, k)
  if k <= 0 then return 0, 0 end
  return (D.noise(t * 9) - 0.5) * 5 * k, (D.noise(t * 8 + 30) - 0.5) * 4 * k
end
H.box, H.tremor = box, tremor

D.POSE.chop_up = { lean = -8, nod = -10, ua1 = 170, ua2 = 165, fa1 = 175, fa2 = 172, th1 = 8, th2 = -8, sh1 = 0, sh2 = -3, hy = 7.2, rot = 0 }
D.POSE.chop_down = { lean = 30, nod = 20, ua1 = 70, ua2 = 66, fa1 = 80, fa2 = 76, th1 = 14, th2 = -12, sh1 = -4, sh2 = -14, hy = 6.6, rot = 0 }
D.POSE.drum = { lean = 8, nod = 20, ua1 = 50, ua2 = 46, fa1 = 110, fa2 = 105, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.drum_hit = { lean = 14, nod = 26, ua1 = 40, ua2 = 60, fa1 = 70, fa2 = 120, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.pull = { lean = -4, nod = -16, ua1 = 160, ua2 = 155, fa1 = 170, fa2 = 168, th1 = 4, th2 = -4, sh1 = 0, sh2 = -2, hy = 7.0, rot = 0 }
D.POSE.dance_a = { lean = 2, nod = 6, ua1 = 80, ua2 = 50, fa1 = 120, fa2 = 90, th1 = 8, th2 = -6, sh1 = 0, sh2 = -2, hy = 7.2, rot = 0 }
D.POSE.skate = { lean = 18, nod = 4, ua1 = -30, ua2 = -40, fa1 = -20, fa2 = -30, th1 = 20, th2 = -30, sh1 = 10, sh2 = -40, hy = 6.8, rot = 0 }

-------------------------------------------------------------------------------
-- LA GIOSTRA DELLE STELLE
-------------------------------------------------------------------------------
S.giostra_stelle = {
  ritmo = true,
  init = function(s)
    s.a = 0; s.bump = 0
    s.kid = D.figura(0, 0, { s = 0.7, l = 15, child = true, pose = "sit" })
  end,
  update = function(s, dt, t)
    s.a = s.a + dt * (0.25 + mac("ritmo") * 0.3)
    s.bump = max(0, s.bump - dt * 3)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local cx, cy = 64, 30
    -- il tetto a punta, fatto di stelle
    for i = 0, 8 do
      local a = i / 8 * pi
      local x, y = cx + cos(a) * 40, cy - 6 - sin(a) * 4
      D.line(cx, 4, x, y + 6, 3)
      D.px(x, y + 6, 8 + 6 * sin(t * 2 + i))
    end
    D.px(cx, 3, 15)
    -- il palo centrale
    D.line(cx, 6, cx, 56, 5)
    -- i cavalli: costellazioni che girano in un'ellisse, su e giù
    for i = 0, 5 do
      local a = s.a + i * pi / 3
      local x = cx + cos(a) * 40
      local z = sin(a)
      local y = cy + 6 + z * 6 + sin(t * 2 + i) * 3 - s.bump * 2
      local l = 6 + (z + 1) * 4
      D.line(x, cy - 4 + z * 2, x, y - 3, 2 + z)
      -- il cavallo: cinque stelle unite
      local pts = { { -4, 0 }, { 0, -1 }, { 4, 0 }, { 5, -4 }, { -3, 3 }, { 3, 3 } }
      for j = 1, #pts - 1 do D.line(x + pts[j][1], y + pts[j][2], x + pts[j + 1][1], y + pts[j + 1][2], l * 0.5) end
      for _, p in ipairs(pts) do D.px(x + p[1], y + p[2], l + 2) end
      if i == 0 then s.kid.x, s.kid.y = x, y - 1; if z > -0.3 then s.kid:draw() end end
    end
    D.line(14, 56, 114, 56, 3)
    bars(0.3)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.bump = 1 end end,
}

-------------------------------------------------------------------------------
-- LE LETTERE NEL VENTO
-------------------------------------------------------------------------------
S.lettere_vento = {
  init = function(s)
    s.fig = D.figura(40, 56, { s = 1.1, l = 14, pose = "hold", face = 1 })
    s.let = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "hold", R(1.5, 3) }, { "pose", "reach_up", 0.6 },
      { "fn", function(f) s.let[#s.let + 1] = { x = f.x + 4, y = f.y - 20, vx = R(6, 14), vy = -R(4, 8), ph = R(0, 6), age = 0, back = random() < 0.12 } end },
      { "pose", "look_up", R(2, 4) } } end)
    s.fig:update(dt)
    local v = 0.6 + mac("vento")
    for i = #s.let, 1, -1 do
      local p = s.let[i]
      p.age = p.age + dt
      if p.back and p.age > 3 and p.age < 6 then
        p.vx = p.vx + (s.fig.hand[1] - p.x) * dt * 0.8; p.vy = p.vy + (s.fig.hand[2] - p.y) * dt * 0.8
        p.vx = p.vx * 0.96; p.vy = p.vy * 0.96
      end
      p.x = p.x + p.vx * dt * v; p.y = p.y + p.vy * dt
      if p.x > 140 or p.y < -10 then table.remove(s.let, i) end
    end
  end,
  draw = function(s, t)
    local ox, oy = hand(t, 0.8)
    cam(ox, oy, function()
      for i = 0, 3 do cloud_edge((i * 40 + t * 1.5) % 180 - 30, 60, 30, 4, i + 3) end
      D.line(20, 56, 70, 56, 4)
      -- la scatola aperta ai suoi piedi
      box(44, 52, 8, 4, 8); D.line(44, 52, 41, 48, 6)
      s.fig:draw()
      for _, p in ipairs(s.let) do
        local f = sin(t * 9 + p.ph) * 2
        D.line(p.x - 2, p.y - f, p.x, p.y, 13); D.line(p.x, p.y, p.x + 2, p.y - f, 13)
        D.px(p.x, p.y + 1, 9)
      end
    end)
  end,
}

-------------------------------------------------------------------------------
-- IL TRENO DELLE NUVOLE
-------------------------------------------------------------------------------
S.treno_nuvole = {
  ritmo = true,
  init = function(s)
    s.off = 0; s.jolt = 0
    s.faces = {}
    for i = 1, 14 do s.faces[i] = random() < 0.7 end
  end,
  update = function(s, dt, t)
    s.off = s.off + dt * (10 + mac("treno") * 10)
    s.jolt = max(0, s.jolt - dt * 5)
  end,
  draw = function(s, t)
    -- la macchina segue il treno: le nuvole scorrono sotto, veloci
    for i = 0, 6 do cloud_edge(((i * 34 - s.off * 1.4) % 220) - 40, 56 + (i % 2) * 4, 30, 5, i + 20) end
    for i = 0, 5 do cloud_edge(((i * 50 - s.off * 0.4) % 260) - 40, 14 + (i % 3) * 4, 24, 3, i + 40) end
    -- il treno: tre carrozze, i finestrini accesi con le facce dentro
    local y = 34 + s.jolt
    for c = 0, 2 do
      local x = 6 + c * 40
      box(x, y, 36, 12, 9)
      for w = 0, 3 do
        local k = c * 4 + w + 1
        D.rect(x + 3 + w * 8, y + 3, 6, 5, 4)
        D.line(x + 3 + w * 8, y + 3, x + 9 + w * 8, y + 3, 12)
        if s.faces[k] then D.circle(x + 6 + w * 8, y + 6, 1.2, 15) end
      end
      D.circle(x + 6, y + 13, 1.5, 7, true); D.circle(x + 30, y + 13, 1.5, 7, true)
      if c < 2 then D.line(x + 36, y + 8, x + 40, y + 8, 6) end
    end
    -- il fumo della locomotiva che diventa nuvola
    for i = 0, 4 do D.circle(124 - i * 6 + sin(t + i), y - 4 - i * 2, 1 + i * 0.6, 6 - i, true) end
    bars(0.45)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.jolt = 1 end end,
}

-------------------------------------------------------------------------------
-- IL BALLO DEI NONNI
-------------------------------------------------------------------------------
S.ballo_nonni = {
  init = function(s)
    s.lui = D.figura(60, 54, { s = 1.2, l = 14, pose = "dance_a", face = 1 })
    s.lei = D.figura(68, 54, { s = 1.1, l = 13, pose = "hug", face = -1, dress = true, bun = true })
    s.a = 0
  end,
  update = function(s, dt, t)
    s.a = s.a + dt * 0.5
    local cx = 64 + sin(s.a * 0.5) * 16
    s.lui.x = cx - 4 + cos(s.a) * 1.5; s.lei.x = cx + 4 - cos(s.a) * 1.5
    -- ogni tanto si girano: lui di qua, lei di là
    local fl = sin(s.a * 0.7) > 0
    s.lui.face = fl and 1 or -1; s.lei.face = fl and -1 or 1
    if fl then s.lui.x, s.lei.x = s.lui.x, s.lei.x else s.lui.x, s.lei.x = s.lei.x, s.lui.x end
    s.lui.y = 54 - abs(sin(s.a * 1.5)) * 0.8; s.lei.y = s.lui.y
    s.lui:update(dt); s.lei:update(dt)
  end,
  draw = function(s, t)
    -- la pista: un'ellisse di lumini
    for i = 0, 23 do local a = i / 24 * 2 * pi; D.px(64 + cos(a) * 46, 56 + sin(a) * 5, 4 + 3 * sin(t * 2 + i)) end
    for i = 0, 3 do cloud_edge((i * 44 + t) % 180 - 30, 62, 30, 4, i + 60) end
    -- la luna come un riflettore
    D.circle(104, 10, 3, 13); rays(104, 10, s.lui.x - 14, s.lui.x + 14, 56, 2, 4)
    s.lui:draw(); s.lei:draw()
    bars(0.35)
  end,
}

-------------------------------------------------------------------------------
-- LA MONGOLFIERA
-------------------------------------------------------------------------------
S.mongolfiera = {
  init = function(s)
    s.y = 0; s.burn = 0
    s.fig = D.figura(0, 0, { s = 0.6, l = 15, pose = "lean_rail", face = 1 })
    s.lights = {}
    for i = 1, 60 do s.lights[i] = { x = R(0, 128), y = R(0, 30), b = R(3, 10) } end
  end,
  update = function(s, dt, t)
    if s.burn <= 0 and random() < dt * 0.12 then s.burn = R(1.5, 3) end
    if s.burn > 0 then s.burn = s.burn - dt; s.y = s.y + dt * 3 else s.y = s.y + dt * 0.8 end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- la terra sotto: luci minuscole che scendono man mano che si sale
    local dy = (s.y * 0.6) % 40
    for _, l in ipairs(s.lights) do
      local y = 46 + (l.y + dy) % 40 * 0.5
      if y < 64 then D.px(l.x, y, l.b * 0.6) end
    end
    -- il pallone: l'arco, gli spicchi
    local cx, cy = 64, 22 + sin(t * 0.5) * 1.5
    for i = -3, 3 do
      local w = 16 * cos(i / 4 * pi / 2)
      screen.level(D.lv(5 + (i == 0 and 3 or 0)))
      screen.move(cx + i * 4.5, cy + 12)
      screen.curve(cx + i * 6, cy - 4, cx + i * 3, cy - 16, cx, cy - 17)
      screen.stroke()
    end
    screen.level(D.lv(8)); screen.circle(cx, cy - 2, 15); screen.stroke()
    -- il fuoco del bruciatore
    if s.burn > 0 then for i = 0, 3 do D.line(cx - 1 + i * 0.7, cy + 13, cx + (D.noise(t * 9 + i) - 0.5) * 3, cy + 6 - D.noise(t * 7 + i) * 4, 13) end end
    -- il cesto con lui dentro
    D.line(cx - 6, cy + 13, cx - 4, cy + 22, 5); D.line(cx + 6, cy + 13, cx + 4, cy + 22, 5)
    s.fig.x, s.fig.y = cx - 1, cy + 28
    s.fig:draw()
    box(cx - 5, cy + 22, 10, 6, 10)
    bars(0.3)
  end,
}

-------------------------------------------------------------------------------
-- LA BIBLIOTECA DEL CIELO
-------------------------------------------------------------------------------
S.biblio_cielo = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = 1.1, l = 14, pose = "look_up" })
    s.books = {}
    s.shelf = {}
    for i = 1, 40 do s.shelf[i] = { h = R(3, 6), l = R(3, 7) } end
  end,
  update = function(s, dt, t)
    if random() < dt * 0.5 then s.books[#s.books + 1] = { x = pick({ 12, 116 }), y = R(10, 50), vx = 0, vy = 0, age = 0 } end
    for i = #s.books, 1, -1 do
      local b = s.books[i]
      b.age = b.age + dt
      b.vx = b.vx + ((64 - b.x) * 0.02 + sin(b.age * 2) * 1) * dt * 8
      b.vy = b.vy - dt * 2
      b.x = b.x + b.vx * dt; b.y = b.y + b.vy * dt
      if b.y < -8 then table.remove(s.books, i) end
    end
    think(s.fig, function() return pick({ { { "pose", "look_up", R(4, 8) } }, { { "pose", "reach_up", 3 }, { "pose", "stand", 2 } }, { { "pose", "sit_read", 6 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- gli scaffali ai lati, che salgono e si perdono
    for side = 0, 1 do
      local x0 = side == 0 and 2 or 104
      for r = 0, 7 do
        local y = 58 - r * 7
        D.line(x0, y, x0 + 22, y, 4)
        local x = x0 + 1
        for k = 1, 6 do
          local b = s.shelf[(r * 6 + k + side * 7) % 40 + 1]
          D.line(x, y - 1, x, y - b.h, b.l * (1 - r / 10))
          x = x + 3.5
        end
      end
    end
    for _, b in ipairs(s.books) do
      local w = sin(t * 6 + b.age * 3) * 3
      D.line(b.x - 3, b.y - w, b.x, b.y, 12); D.line(b.x, b.y, b.x + 3, b.y - w, 12); D.line(b.x, b.y, b.x, b.y + 2, 8)
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA SLITTA
-------------------------------------------------------------------------------
S.slitta = {
  ritmo = true,
  init = function(s)
    s.u = 0; s.state = 0
    s.kid = D.figura(0, 0, { s = 0.85, l = 15, child = true, pose = "sit" })
    s.snow = D.parts(30)
    s.walker = D.figura(110, 0, { s = 0.85, l = 12, child = true, speed = 2.5 })
  end,
  update = function(s, dt, t)
    if s.state == 0 then
      s.u = s.u + dt * (0.18 + mac("fretta") * 0.15) * (0.4 + s.u * 1.6)
      if random() < dt * 30 then D.spawn(s.snow, { x = 0, y = 0, vx = R(-10, 10), vy = -R(5, 15), life = 0.6, rel = true, u = s.u }) end
      if s.u >= 1 then s.state = 1; s.walker.x = 120; s.walker:act({ { "walk", 6, 2 } }) end
    else
      s.walker:update(dt)
      s.walker.y = 20 + (120 - s.walker.x) * 0.3
      if s.walker.idle then s.state = 0; s.u = 0 end
    end
    D.parts_update(s.snow, dt, function(p, d) p.vy = p.vy + 40 * d end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    -- il pendio, da sinistra in alto a destra in basso
    local function slope(x) return 20 + x * 0.3 end
    D.line(0, slope(0), 127, slope(127), 7)
    for i = 0, 12 do D.pine(8 + i * 11, slope(8 + i * 11) - 4 - (i % 3) * 6, 6, 3, 0) end
    for i = 0, 20 do D.px((i * 23) % 128, slope((i * 23) % 128) + 3 + (i % 4), 4) end
    if s.state == 0 then
      local x = 4 + s.u * 118
      local y = slope(x)
      local ox, oy = tremor(t, s.u * 0.5)
      cam(ox, oy, function()
        D.line(x - 7, y - 1, x + 6, y + 2, 12); D.line(x + 6, y + 2, x + 8, y, 12)
        s.kid.x, s.kid.y = x - 1, y - 1
        s.kid:draw()
        for _, p in ipairs(s.snow.list) do D.px(x - 6 + p.x * 0.3 - (p.age or 0) * 20, y + 1 + p.y * (p.age or 0), 14) end
      end)
    else
      s.walker:draw()
      D.line(s.walker.x + 4, s.walker.y - 6, s.walker.x + 12, s.walker.y - 4, 7)
      D.line(s.walker.x + 12, s.walker.y - 3, s.walker.x + 20, s.walker.y - 1, 10)
    end
  end,
}

-------------------------------------------------------------------------------
-- LA CASCATA GELATA
-------------------------------------------------------------------------------
S.cascata_gelo = {
  ritmo = true,
  init = function(s)
    s.ice = {}
    for i = 1, 22 do s.ice[i] = { x = 40 + i * 2.2 + R(-0.5, 0.5), len = R(16, 40), ring = 0 } end
    s.drops = D.parts(20)
    s.fig = D.figura(18, 58, { s = 1.1, l = 14, pose = "look_up", face = 1 })
  end,
  update = function(s, dt, t)
    for _, c in ipairs(s.ice) do c.ring = max(0, c.ring - dt * 2) end
    D.parts_update(s.drops, dt, function(p, d) p.vy = p.vy + 60 * d; if p.y > 56 then p.life = 0 end end)
    think(s.fig, function() return pick({ { { "pose", "look_up", R(5, 9) } }, { { "walk", R(14, 30), 2 }, { "face", 1 }, { "pose", "reach_up", 3 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- la roccia sopra, e il bordo della pozza
    D.line(30, 8, 100, 6, 5); D.line(30, 8, 26, 0, 4); D.line(100, 6, 106, 0, 4)
    for _, c in ipairs(s.ice) do
      local l = 5 + c.ring * 10 + 2 * sin(t * 0.8 + c.x)
      D.line(c.x, 8, c.x + sin(c.x) * 0.5, 8 + c.len, l)
      D.px(c.x, 8 + c.len, l + 3)
    end
    -- dentro, l'acqua che ancora scorre: un filo che si muove dietro il ghiaccio
    for y = 10, 50, 3 do D.px(64 + sin(y * 0.3 + t * 4) * 3, y, 3) end
    D.line(30, 56, 100, 56, 6); D.line(34, 58, 96, 58, 3)
    for _, p in ipairs(s.drops.list) do D.px(p.x, p.y, 14) end
    s.fig:draw()
  end,
  note = function(s, ev)
    local c = s.ice[random(#s.ice)]
    c.ring = 1
    D.spawn(s.drops, { x = c.x, y = 8 + c.len, vx = 0, vy = 0, life = 2 })
  end,
}

-------------------------------------------------------------------------------
-- IL BOSCAIOLO: l'ascia cade a tempo col ritmo
-------------------------------------------------------------------------------
S.boscaiolo = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(56, 58, { s = 1.35, l = 14, pose = "chop_up", face = 1,
      prop = function(x, y, f)
        -- l'ascia: il manico e la lama
        local a = f.cur.ua1 / 180 * pi
        local hx, hy = x + sin(a) * 6, y - cos(a) * 6
        D.line(x, y, hx, hy, 9); D.poly({ hx, hy, hx + 3, hy - 1, hx + 3, hy + 3 }, 13)
      end })
    s.chips = D.parts(24)
    s.logs = 3
    s.down = 0
  end,
  update = function(s, dt, t)
    s.down = max(0, s.down - dt)
    if s.down <= 0 and s.fig.cur.ua1 < 120 then s.fig:set("chop_up") end
    s.fig:update(dt)
    D.parts_update(s.chips, dt, function(p, d) p.vy = p.vy + 50 * d; if p.y > 58 then p.vy = 0; p.vx = p.vx * 0.5 end end)
  end,
  draw = function(s, t)
    for i, x in ipairs({ 6, 18, 100, 112, 124 }) do D.line(x, 0, x, 58, 3 + (i % 2)); D.line(x + 2, 0, x + 2, 58, 2) end
    D.line(0, 58, 127, 58, 4)
    -- il ceppo e il pezzo da spaccare
    box(64, 50, 12, 8, 8); D.line(66, 54, 74, 54, 4)
    D.rect(67, 44, 6, 6, 9)
    -- la catasta
    for r = 0, 2 do for c = 0, 3 - r do D.circle(86 + c * 5 + r * 2.5, 56 - r * 4.5, 2.2, 7, true) end end
    s.fig:draw()
    for _, p in ipairs(s.chips.list) do D.px(p.x, p.y, 12) end
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" and (ev.o == 2 or ev.o == 1) then
      s.fig:set("chop_down"); s.down = 0.18
      for i = 1, 4 do D.spawn(s.chips, { x = 70, y = 46, vx = R(-20, 20), vy = -R(10, 25), life = 1.5 }) end
    end
  end,
}

-------------------------------------------------------------------------------
-- IL CAMPANARO
-------------------------------------------------------------------------------
S.campanaro = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(64, 60, { s = 1.2, l = 14, pose = "pull" })
    s.bells = { { x = 40, a = 0, v = 0 }, { x = 64, a = 0, v = 0 }, { x = 88, a = 0, v = 0 } }
    s.birds = D.parts(10)
  end,
  update = function(s, dt, t)
    for _, b in ipairs(s.bells) do b.v = b.v - b.a * 6 * dt; b.v = b.v * (1 - dt * 0.4); b.a = b.a + b.v * dt end
    s.fig.y = 60 + max(0, s.bells[2].a) * 4
    s.fig:update(dt)
    D.parts_update(s.birds, dt)
  end,
  draw = function(s, t)
    -- la cella: archi a bifora, solo il contorno
    for i = 0, 1 do
      local x = 22 + i * 52
      screen.level(D.lv(4)); screen.move(x, 30); screen.line(x, 14); screen.arc(x + 15, 14, 15, pi, 2 * pi); screen.line(x + 30, 30); screen.stroke()
    end
    D.line(14, 6, 114, 6, 5)
    for _, b in ipairs(s.bells) do
      local a = b.a * 0.6
      local cx, cy = b.x, 10
      local function P(dx, dy) return cx + dx * cos(a) - dy * sin(a), cy + dx * sin(a) + dy * cos(a) end
      local p = { { -3, 2 }, { 3, 2 }, { 6, 12 }, { -6, 12 } }
      for i = 1, 4 do local x1, y1 = P(p[i][1], p[i][2]); local x2, y2 = P(p[i % 4 + 1][1], p[i % 4 + 1][2]); D.line(x1, y1, x2, y2, 11) end
      local bx, by = P(sin(t * 3 + b.x) * 2, 13); D.circle(bx, by, 1, 14)
      -- la corda
      local rx, ry = P(0, 12)
      D.line(rx, ry, b.x == 64 and s.fig.hand[1] or b.x, b.x == 64 and s.fig.hand[2] or 58, 6)
    end
    D.line(0, 60, 127, 60, 3)
    s.fig:draw()
    for _, p in ipairs(s.birds.list) do local w = sin(t * 18) * 1.5; D.line(p.x - 2, p.y - w, p.x, p.y, 10); D.line(p.x, p.y, p.x + 2, p.y - w, 10) end
  end,
  note = function(s, ev)
    if ev.str == "campana" or (ev.ruolo == "ritmo" and ev.o == 1) then
      local b = s.bells[random(3)]; b.v = b.v + pick({ -1, 1 }) * 1.5
      if random() < 0.4 then D.spawn(s.birds, { x = R(30, 100), y = 22, vx = R(-30, 30), vy = -R(10, 20), life = 3 }) end
    end
  end,
}

-------------------------------------------------------------------------------
-- PERSO SUL MONTE: la torcia, la neve, il cuore
-------------------------------------------------------------------------------
S.perso_monte = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(64, 56, { s = 1.2, l = 14, speed = 3, pose = "torch", on_step = H.steps("neve", 0.4) })
    s.snow = D.parts(80)
    s.beat = 0; s.win = 0
  end,
  update = function(s, dt, t)
    D.snow_update(s.snow, dt, 1.2 + mac("vento") * 2, 64, -8 - mac("vento") * 20, t)
    s.beat = max(0, s.beat - dt * 4)
    s.win = s.win + dt
    if s.win > 40 then s.win = 0 end
    think(s.fig, function() return pick({ { { "walk", R(30, 98), 3 }, { "pose", "torch", R(2, 4) } }, { { "face", -s.fig.face }, { "pose", "torch", 2 } }, { { "pose", "look_up", 2 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, 0.15 + s.beat * 0.4 + mac("fretta") * 0.3)
    cam(ox, oy, function()
      D.line(0, 56, 127, 56, 3)
      -- la torcia: un cono di linee sottili davanti a lui, che trema
      local f = s.fig
      local dir = f.face
      local hx, hy = f.hand[1], f.hand[2]
      local w = (D.noise(t * 7) - 0.5) * 4
      for i = -3, 3 do D.line(hx, hy, hx + dir * 50, hy + i * 6 + w, 2 + (3 - abs(i)) * 0.8) end
      D.px(hx, hy, 15)
      -- là in fondo, a volte, una finestra
      if s.win > 28 then local k = min(1, (s.win - 28) / 3); D.rect(118, 44, 3, 3, 13 * k) end
      f:draw()
      D.snow_draw(s.snow, 9)
    end)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.beat = 1 end end,
}

-------------------------------------------------------------------------------
-- IL PONTE TIBETANO
-------------------------------------------------------------------------------
S.ponte_tibetano = {
  init = function(s)
    s.fig = D.figura(8, 0, { s = 1.0, l = 15, speed = 2, on_step = function(f) S.env.step("legno", H.pan(f.x), 0.35); s.sw = s.sw + 0.6 end })
    s.sw = 0; s.v = 0
  end,
  update = function(s, dt, t)
    s.v = s.v - s.sw * 3 * dt + (D.noise(t * 0.5) - 0.5) * mac("vento") * 3 * dt
    s.v = s.v * (1 - dt * 0.5)
    s.sw = s.sw + s.v * dt * 4
    think(s.fig, function() return { { "walk", 64, 2 }, { "pose", "head_down", 4 }, { "pose", "stand", 3 }, { "walk", 120, 2 }, { "fn", function(f) f.x = 8 end } } end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- le due pareti di roccia
    D.line(0, 30, 8, 30, 6); D.line(8, 30, 6, 64, 5); D.line(120, 30, 127, 30, 6); D.line(120, 30, 122, 64, 5)
    -- il torrente lontanissimo, in basso
    for i = 0, 8 do local x = 40 + i * 6 + sin(t + i) * 1; D.px(x, 62, 5) end
    -- il ponte: una catenaria che dondola
    local function y_at(x) local k = (x - 8) / 112; return 30 + sin(k * pi) * (8 + s.sw * 1.2) + sin(k * pi) * s.sw * 2 end
    local px, py
    for x = 8, 120, 4 do
      local y = y_at(x)
      local lat = sin((x - 8) / 112 * pi) * s.sw * 2
      if px then D.line(px, py, x + lat, y, 9); D.line(px, py - 8, x + lat, y - 8, 5) end
      D.line(x + lat, y, x + lat, y - 8, 3)
      px, py = x + lat, y
    end
    s.fig.y = y_at(s.fig.x)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- I PATTINI SUL LAGO
-------------------------------------------------------------------------------
S.pattini = {
  ritmo = true,
  init = function(s)
    s.fig = D.figura(64, 50, { s = 1.15, l = 15, pose = "skate", face = 1 })
    s.a = 0
    s.trail = {}
    s.crack = 0
  end,
  update = function(s, dt, t)
    s.a = s.a + dt * 0.4
    local x, y = 64 + cos(s.a) * 40, 50 + sin(s.a) * 6
    s.fig.face = (-sin(s.a) >= 0) and 1 or -1
    s.fig.x, s.fig.y = x, y
    s.trail[#s.trail + 1] = { x = x, y = y, age = 0 }
    for i = #s.trail, 1, -1 do s.trail[i].age = s.trail[i].age + dt; if s.trail[i].age > 8 then table.remove(s.trail, i) end end
    s.crack = max(0, s.crack - dt * 0.5)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    -- la riva e gli alberi neri dall'altra parte
    D.line(0, 40, 127, 40, 4)
    for i = 0, 12 do D.pine(4 + i * 10, 40, 8 + (i % 3) * 3, 3, 0) end
    -- le scie dei pattini sul ghiaccio
    for i = 2, #s.trail, 2 do local a, b = s.trail[i - 1], s.trail[i]; D.line(a.x, a.y + 0.5, b.x, b.y + 0.5, 6 * (1 - a.age / 8)) end
    if s.crack > 0 then local px, py = 30, 58; for i = 1, 8 do local nx, ny = px + 10, py - R(-2, 2); D.line(px, py, nx, ny, 10 * s.crack); px, py = nx, ny end end
    s.fig:draw()
    -- il riflesso: una figura capovolta appena accennata
    D.line(s.fig.x, s.fig.y + 1, s.fig.x, s.fig.y + 8, 3)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 and random() < 0.1 then s.crack = 1 end end,
}

-------------------------------------------------------------------------------
-- IL CARRETTO: giù per la discesa della chiesa
-------------------------------------------------------------------------------
S.carretto = {
  ritmo = true,
  init = function(s)
    s.off = 0; s.jolt = 0
    s.k1 = D.figura(0, 0, { s = 0.85, l = 15, child = true, pose = "sit", face = 1 })
    s.k2 = D.figura(0, 0, { s = 0.8, l = 13, child = true, pose = "arms_open", face = 1 })
  end,
  update = function(s, dt, t)
    s.off = s.off + dt * (40 + mac("fretta") * 50)
    s.jolt = max(0, s.jolt - dt * 6)
    s.k1:update(dt); s.k2:update(dt)
  end,
  draw = function(s, t)
    -- la strada in discesa che scorre via: case, lampioni, la chiesa che si allontana
    local o = s.off
    for i = 0, 8 do
      local x = ((i * 30 - o * 0.5) % 270) - 30
      D.line(x, 40 - (x * 0.1), x, 20 - (x * 0.1), 4); D.line(x, 20 - x * 0.1, x + 16, 16 - x * 0.1, 4)
      D.rect(x + 5, 26 - x * 0.1, 3, 3, 8)
    end
    for i = 0, 5 do local x = ((i * 50 - o) % 300) - 40; D.line(x, 54 - x * 0.12, x, 34 - x * 0.12, 6); D.px(x, 33 - x * 0.12, 13) end
    D.line(0, 56, 127, 44, 5)
    -- il carretto con due bambini, che sobbalza
    local x = 56
    local y = 56 - x * 0.094 - s.jolt * 2
    local ox, oy = tremor(t, 0.3 + mac("fretta") * 0.3)
    cam(ox, oy, function()
      D.line(x - 12, y - 3, x + 12, y - 5, 12)
      D.circle(x - 9, y - 1, 2, 9, true); D.circle(x + 9, y - 3, 2, 9, true)
      D.line(x + 12, y - 5, x + 15, y - 10, 7)
      s.k1.x, s.k1.y = x + 4, y - 4; s.k2.x, s.k2.y = x - 5, y - 3
      s.k2:draw(); s.k1:draw()
      for i = 1, 4 do D.line(x - 16 - i * 6, y - 4 - i, x - 22 - i * 6, y - 4 - i, 6 - i) end
    end)
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" then s.jolt = 1 end end,
}

-------------------------------------------------------------------------------
-- LE BIGLIE
-------------------------------------------------------------------------------
S.biglie = {
  ritmo = true,
  init = function(s)
    s.m = {}
    for i = 1, 4 do s.m[i] = { u = i * 0.07, v = 0, l = 10 + i } end
    s.kid = D.figura(18, 60, { s = 1.1, l = 14, child = true, pose = "kneel", face = 1 })
  end,
  update = function(s, dt, t)
    for _, m in ipairs(s.m) do m.v = max(0, m.v - dt * 0.03); m.u = (m.u + m.v * dt) % 1 end
    think(s.kid, function() return pick({ { { "pose", "kneel", R(3, 5) }, { "pose", "dig", 0.4 } }, { { "pose", "kneel_one", 4 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    -- la pista nella sabbia, a otto, vista dall'alto e un po' di sbieco
    local function P(u) local a = u * 2 * pi; return 70 + sin(a) * 44, 40 + sin(2 * a) * 12 end
    local px, py = P(0)
    for i = 1, 80 do local x, y = P(i / 80); D.line(px, py - 2, x, y - 2, 4); D.line(px, py + 2, x, y + 2, 4); px, py = x, y end
    -- il tunnel
    local tx, ty = P(0.25); box(tx - 4, ty - 4, 8, 6, 6)
    for _, m in ipairs(s.m) do
      local x, y = P(m.u)
      D.circle(x, y, 1.5, m.l); D.px(x - 0.5, y - 0.8, 15)
    end
    s.kid:draw()
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" and (ev.o == 1 or ev.o == 2) then local m = s.m[random(#s.m)]; m.v = m.v + 0.06 + random() * 0.05 end
  end,
}

-------------------------------------------------------------------------------
-- IL TAMBURO DI LATTA: le bacchette battono quello che senti
-------------------------------------------------------------------------------
S.tamburo = {
  ritmo = true,
  init = function(s)
    s.kid = D.figura(60, 54, { s = 1.3, l = 15, child = true, pose = "drum", face = 1 })
    s.hit = 0; s.ring = {}
    s.nonna = D.figura(112, 54, { s = 1.2, l = 11, dress = true, bun = true, pose = "stand", face = -1 })
  end,
  update = function(s, dt, t)
    s.hit = max(0, s.hit - dt)
    if s.hit <= 0 then s.kid:set("drum") end
    for i = #s.ring, 1, -1 do s.ring[i].r = s.ring[i].r + dt * 30; if s.ring[i].r > 20 then table.remove(s.ring, i) end end
    think(s.nonna, function() return pick({ { { "pose", "stand", R(3, 6) } }, { { "pose", "arms_open", 1 }, { "pose", "stand", 2 } } }) end)
    s.kid:update(dt); s.nonna:update(dt)
  end,
  draw = function(s, t)
    -- l'albero di Natale in un angolo, solo lucine
    for i = 0, 12 do local k = i / 12; D.px(18 + sin(i * 2.3) * k * 10, 14 + k * 36, 4 + 9 * (0.5 + 0.5 * sin(t * 2 + i))) end
    D.px(18, 12, 15)
    D.line(0, 58, 127, 58, 3)
    -- il tamburo: due ellissi e le righe a zig zag
    local cx, cy = 70, 52
    screen.level(D.lv(11)); screen.circle(cx, cy - 6, 6); screen.stroke()
    D.line(cx - 6, cy - 6, cx - 6, cy, 10); D.line(cx + 6, cy - 6, cx + 6, cy, 10); D.line(cx - 6, cy, cx + 6, cy, 10)
    for i = 0, 3 do D.line(cx - 6 + i * 4, cy - 1, cx - 4 + i * 4, cy - 5, 6) end
    for _, r in ipairs(s.ring) do screen.level(D.lv(8 * (1 - r.r / 20))); screen.circle(cx, cy - 6, r.r); screen.stroke() end
    s.kid:draw(); s.nonna:draw()
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" then
      s.kid:set(ev.o == 1 and "drum_hit" or (random() < 0.5 and "drum_hit" or "drum")); s.hit = 0.12
      if ev.o == 1 then s.ring[#s.ring + 1] = { r = 6 } end
    end
  end,
}

-------------------------------------------------------------------------------
-- LA RECITA: il riflettore, la battuta che non arriva
-------------------------------------------------------------------------------
S.recita = {
  init = function(s)
    s.kid = D.figura(64, 52, { s = 1.15, l = 15, child = true, pose = "stand", face = 1,
      prop = function(x, y, f) D.line(f.x - 3, f.y - 20, f.x + 3, f.y - 20, 10); D.line(f.x, f.y - 24, f.x - 3, f.y - 20, 9); D.line(f.x, f.y - 24, f.x + 3, f.y - 20, 9) end })
    s.heads = {}
    for i = 1, 14 do s.heads[i] = { x = 4 + i * 8.6, y = 60 + (i % 2) * 2, clap = 0 } end
    s.cyc = 0; s.curtain = 0
  end,
  update = function(s, dt, t)
    s.cyc = s.cyc + dt
    if s.cyc > 40 then s.cyc = 0 end
    s.curtain = D.lerp(s.curtain, s.cyc < 3 and 0 or 1, dt * 1.5)
    local panic = s.cyc > 10 and s.cyc < 24
    s.kid.shake = panic and 0.3 or 0
    if s.cyc > 24 and s.cyc < 30 then for _, h in ipairs(s.heads) do h.clap = (sin(t * 20 + h.x) > 0) and 1 or 0 end else for _, h in ipairs(s.heads) do h.clap = 0 end end
    think(s.kid, function()
      if panic then return { { "pose", pick({ "head_down", "hands_face", "stand" }), 2 } } end
      if s.cyc > 24 then return { { "pose", "arms_open", 2 } } end
      return { { "pose", "stand", 2 } }
    end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    -- il palco, il sipario che si apre ai lati
    D.line(0, 52, 127, 52, 6)
    local c = s.curtain * 50
    for i = 0, 6 do D.line(64 - c - i * 2, 4, 64 - c - i * 2 + sin(t + i) * 0.5, 52, 5); D.line(64 + c + i * 2, 4, 64 + c + i * 2, 52, 5) end
    D.line(0, 4, 127, 4, 6)
    -- il riflettore bianco, dall'alto
    if s.curtain > 0.5 then rays(64, 0, 50, 78, 52, 3, 6) end
    s.kid:draw()
    -- il pubblico: teste nel buio, e quando applaudono, le mani
    for _, h in ipairs(s.heads) do D.circle(h.x, h.y, 2.2, 6); if h.clap > 0 then D.px(h.x - 2, h.y - 3, 12); D.px(h.x + 2, h.y - 3, 12) end end
  end,
}

-------------------------------------------------------------------------------
-- L'AUTOSCONTRO
-------------------------------------------------------------------------------
S.autoscontro = {
  ritmo = true,
  init = function(s)
    s.cars = {}
    for i = 1, 5 do s.cars[i] = { x = R(16, 112), y = R(36, 56), vx = R(-20, 20), vy = R(-6, 6), l = i == 1 and 15 or R(8, 12) } end
    s.sparks = D.parts(30)
  end,
  update = function(s, dt, t)
    for i, c in ipairs(s.cars) do
      c.x = c.x + c.vx * dt; c.y = c.y + c.vy * dt
      if c.x < 12 or c.x > 116 then c.vx = -c.vx end
      if c.y < 34 or c.y > 58 then c.vy = -c.vy end
      for j = i + 1, #s.cars do
        local d = s.cars[j]
        if abs(c.x - d.x) < 9 and abs(c.y - d.y) < 4 then
          c.vx, d.vx = d.vx, c.vx; c.vy, d.vy = -c.vy, -d.vy
          S.env.sfx("step", 300, 0.05, 0.15, H.pan(c.x), 0.6, 0)
        end
      end
    end
    D.parts_update(s.sparks, dt, function(p, d) p.vy = p.vy + 40 * d end)
  end,
  draw = function(s, t)
    -- la rete del soffitto, con le scintille
    for x = 0, 127, 6 do D.line(x, 8, x + 3, 8, 3) end
    for _, c in ipairs(s.cars) do D.line(c.x, 8, c.x + 1, c.y - 8, 2) end
    for _, p in ipairs(s.sparks.list) do D.px(p.x, p.y, 15) end
    -- la pista
    D.line(6, 60, 122, 60, 5); D.line(6, 32, 122, 32, 3)
    -- le macchinine: un guscio, una testa
    table.sort(s.cars, function(a, b) return a.y < b.y end)
    for _, c in ipairs(s.cars) do
      local f = c.vx >= 0 and 1 or -1
      box(c.x - 6, c.y - 4, 12, 4, c.l)
      D.line(c.x - 6 * f, c.y - 4, c.x - 4 * f, c.y - 7, c.l - 2)
      D.circle(c.x, c.y - 7, 1.4, c.l)
    end
  end,
  note = function(s, ev)
    if ev.ruolo == "ritmo" and random() < 0.5 then
      local c = s.cars[random(#s.cars)]
      for i = 1, 3 do D.spawn(s.sparks, { x = c.x, y = 9, vx = R(-10, 10), vy = R(0, 8), life = 0.5 }) end
    end
  end,
}

-------------------------------------------------------------------------------
-- PERSO AL MERCATO: le gambe dei grandi, la voce che non risponde
-------------------------------------------------------------------------------
S.perso = {
  ritmo = true,
  init = function(s)
    s.kid = D.figura(64, 60, { s = 1.0, l = 15, child = true, speed = 4, pose = "look_up" })
    s.legs = {}
    for i = 1, 10 do s.legs[i] = { x = R(-10, 138), v = R(14, 30) * pick({ -1, 1 }), h = R(30, 50), ph = R(0, 6), l = R(4, 7) } end
    s.beat = 0; s.coat = nil
  end,
  update = function(s, dt, t)
    local f = 1 + mac("fretta") * 1.2
    for _, g in ipairs(s.legs) do
      g.x = g.x + g.v * dt * f; g.ph = g.ph + dt * 8 * f
      if g.x > 140 then g.x = -12 elseif g.x < -12 then g.x = 140 end
    end
    s.beat = max(0, s.beat - dt * 4)
    think(s.kid, function() return pick({ { { "walk", R(30, 98), 4 }, { "pose", "look_up", R(1, 2) } }, { { "face", -s.kid.face }, { "pose", "cry", 1.5 } }, { { "pose", "look_up", 1 }, { "walk", R(30, 98), 5 } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local ox, oy = tremor(t, 0.1 + s.beat * 0.5)
    cam(ox, oy, function()
      -- solo gambe: i grandi visti da sotto, che non si fermano
      for _, g in ipairs(s.legs) do
        local sw = sin(g.ph) * 4
        D.line(g.x - 2, 60 - g.h, g.x - 2 + sw, 62, g.l); D.line(g.x + 2, 60 - g.h, g.x + 2 - sw, 62, g.l)
        D.line(g.x - 4, 60 - g.h, g.x + 4, 60 - g.h, g.l + 1)
        -- una borsa che dondola
        if g.h > 40 then D.rect(g.x + 5 + sin(g.ph * 0.5) * 2, 60 - g.h + 10, 4, 5, g.l + 2) end
      end
      D.line(0, 62, 127, 62, 3)
      s.kid:draw()
    end)
    -- la sua voce: la parola che sale e si perde
    if (t % 6) < 1.5 then
      screen.font_face(1); screen.font_size(8)
      local k = (t % 6) / 1.5
      screen.level(D.lv(12 * (1 - k))); screen.move(s.kid.x - 12, 34 - k * 20); screen.text(H.lang() == 1 and "mamma?" or "mum?")
    end
  end,
  note = function(s, ev) if ev.ruolo == "ritmo" and ev.o == 1 then s.beat = 1 end end,
}

-------------------------------------------------------------------------------
-- LA FEBBRE: la stanza che si allunga e si accorcia
-------------------------------------------------------------------------------
S.febbre = {
  init = function(s)
    s.kid = D.figura(70, 46, { s = 1.1, l = 14, child = true, pose = "lie", face = 1 })
    s.hand = 0; s.ht = 0
  end,
  update = function(s, dt, t)
    s.ht = s.ht + dt
    if s.ht > 20 then s.ht = 0 end
    s.hand = D.lerp(s.hand, (s.ht > 12 and s.ht < 18) and 1 or 0, dt * 1.2)
    think(s.kid, function() return pick({ { { "pose", "lie", R(5, 9) } }, { { "pose", "curl", R(3, 5) } } }) end)
    s.kid:update(dt)
  end,
  draw = function(s, t)
    local nv = 0.5 + mac("nevrosi")
    local st = 1 + sin(t * 0.7) * 0.12 * nv
    -- il soffitto e le pareti che respirano
    local cx = 64
    D.line(cx - 60 * st, 4 + (1 - st) * 20, cx + 60 * st, 4 + (1 - st) * 20, 4)
    D.line(cx - 60 * st, 4 + (1 - st) * 20, cx - 60 * st, 56, 3); D.line(cx + 60 * st, 4 + (1 - st) * 20, cx + 60 * st, 56, 3)
    -- la tenda con i disegni che diventano facce
    for i = 0, 4 do
      local x, y = 20 + i * 5, 14 + (i % 2) * 6
      D.circle(x, y, 1.5, 5, true)
      if sin(t * 0.5 + i) > 0.6 * (1 - mac("nevrosi") * 0.5) then D.px(x - 0.5, y - 0.5, 9); D.px(x + 0.7, y - 0.5, 9) end
    end
    D.line(14, 8, 14, 40, 4); D.line(42, 8, 42, 40, 4)
    -- il letto, le coperte pesanti
    D.line(50, 46, 120, 46, 7); D.line(50, 46, 50, 56, 5); D.line(120, 40, 120, 56, 6)
    s.kid:draw()
    D.line(56, 44, 104, 44, 10)
    -- la mano fresca sulla fronte, che arriva da fuori campo
    if s.hand > 0.05 then
      local hx = 128 - s.hand * 44
      D.thick(128, 30, hx, 38, 2, 14); D.circle(hx, 38, 2, 15)
    end
  end,
}

end
