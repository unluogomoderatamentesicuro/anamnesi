-- ANAMNESI · gli episodi
-- Tra un luogo e l'altro non c'è un caricamento: c'è un piccolo film.
-- Ogni viaggio è un episodio di due inquadrature, con lui dentro:
-- un campo largo e poi un primo piano, oppure il contrario.
-- Strade di notte, lampioni sotto la pioggia, un ponte al tramonto,
-- scale che salgono verso la luce e scale che scendono nel buio,
-- una bicicletta tra i pioppi, un autobus vuoto, una finestra accesa.

local D = include("lib/disegno")
local P = include("lib/passaggi")
local E = {}
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local function R(a, b) return a + random() * (b - a) end

-------------------------------------------------------------------------------
-- attrezzi
-------------------------------------------------------------------------------
-- disegna la figura spostata dalla macchina da presa
local function fdraw(f, cx, cy, l)
  local x, y, ol = f.x, f.y, f.l
  f.x = x - (cx or 0); f.y = y - (cy or 0)
  if l then f.l = l end
  f:draw()
  f.x, f.y, f.l = x, y, ol
end

-- una figura che cammina all'infinito; i passi diventano suoni
local function walker(c, x, y, o)
  o = o or {}
  local f = D.figura(x, y, o)
  f.on_step = function() c.steps = (c.steps or 0) + 1 end
  if o.walk ~= false then f:act({ { "walk", x + (o.face or 1) * 99999, o.speed } }) end
  return f
end

-- un ombrello aperto, tenuto dalla mano davanti
local function umbrella(hx, hy, f)
  local s = f.s
  local top = hy - 9 * s
  D.line(hx, hy, hx, top, 3)
  local w = 7 * s
  D.poly({ hx - w, top + 2 * s, hx + w, top + 2 * s, hx + w * 0.6, top - 1.5 * s, hx, top - 2.6 * s, hx - w * 0.6, top - 1.5 * s }, 2)
  D.line(hx - w, top + 2 * s, hx + w, top + 2 * s, 4)
end

-- una lanterna
local function lantern(hx, hy, f)
  D.line(hx, hy, hx, hy + 2, 6)
  D.rect(hx - 1, hy + 2, 3, 3, 14)
end

-- palo del telegrafo, coi fili
local function pole(x, ybase, h, l)
  D.rect(x, ybase - h, 1, h, l)
  D.rect(x - 3, ybase - h + 2, 7, 1, l)
end

-------------------------------------------------------------------------------
-- gli episodi: ognuno ha due inquadrature { d, init, update, draw }
-- c = contesto: dest, dir, k (avanzamento dell'inquadratura), steps
-------------------------------------------------------------------------------
local EP = {}

-- 1. la strada di notte, i pali del telegrafo, un'auto che passa ----------
EP.strada = {
  luce = "notte",
  peso = function(dir, dest) return (dir ~= "su" and dir ~= "giu" and dest.strato <= 1 and dest.strato >= -1) and 3 or 0 end,
  terreno = "ghiaia",
  shots = {
    { d = 5.2,
      init = function(s, c)
        s.f = walker(c, 40, 50, { s = 1.05, l = 10, speed = 8 })
        s.stars = D.stars_gen(40, random(999), 2, 30)
        s.hills = D.ridge_gen(random(999), 40, 7, 0.7)
        s.hx = R(60, 120)
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local cam = s.f.x - 40
        D.rect(0, 0, 128, 64, 0)
        D.gradient(14, 42, 0, 2)
        D.stars(s.stars, t, 0.8)
        D.moon(100, 16, 4, 13, 0)
        D.ridge(s.hills, 1, 64, cam * 0.08)
        -- una casa lontana con la finestra accesa
        local hx = (s.hx - cam * 0.25) % 200 - 30
        D.house(hx, 40, 10, 6, 2, 4); D.rect(hx + 3, 36, 2, 2, 11)
        D.rect(0, 44, 128, 20, 1)
        D.line(0, 50, 127, 50, 3)
        D.line(0, 53, 127, 53, 2)
        -- i pali e i fili
        local px = {}
        for i = -1, 4 do
          local x = i * 44 - (cam % 44)
          px[#px + 1] = x
          pole(x, 50, 26, 4)
        end
        for i = 1, #px - 1 do
          local a, b = px[i], px[i + 1]
          for w = 0, 1 do
            local y = 26 + w * 2
            local m = (a + b) / 2
            D.line(a, y, m, y + 3, 3); D.line(m, y + 3, b, y, 3)
          end
        end
        fdraw(s.f, cam, 0)
      end },
    { d = 4.6,
      init = function(s, c)
        s.f = walker(c, 54, 72, { s = 2.7, l = 9, speed = 3.2 })
        s.car = -1.5
      end,
      update = function(s, dt) s.f:update(dt); s.car = s.car + dt end,
      draw = function(s, t, c)
        local cam = s.f.x - 54
        D.rect(0, 0, 128, 64, 0)
        D.gradient(20, 50, 0, 2)
        -- i fari che arrivano da dietro
        local beam = 0
        if s.car > 0 and s.car < 2.6 then
          beam = min(1, s.car / 1.2) * min(1, (2.6 - s.car) / 0.5)
          local x0 = -20 + s.car * 20
          D.poly({ x0, 46, 128, 30, 128, 64, x0, 50 }, 2 + beam * 3)
          D.poly({ x0, 47, 128, 38, 128, 58, x0, 49 }, 3 + beam * 5)
        end
        -- un palo vicino, scuro, che passa
        local x = 120 - (cam * 2.2) % 180
        D.rect(x, 0, 4, 64, 1)
        fdraw(s.f, cam, 0, 7 + beam * 7)
        if s.car >= 2.6 and s.car < 4 then
          -- l'auto è passata: due luci rosse che si allontanano
          local k = (s.car - 2.6) / 1.4
          local cx = 70 + k * 40
          D.px(cx, 48, 9 * (1 - k)); D.px(cx + 4, 48, 9 * (1 - k))
        end
      end },
  },
}

-- 2. sotto la pioggia, da un lampione all'altro ----------------------------
EP.pioggia = {
  luce = "notte",
  peso = function(dir, dest) return (dir ~= "su" and dest.strato <= 0) and 3 or 0 end,
  terreno = "pietra",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = walker(c, 46, 52, { s = 1.1, l = 9, speed = 7, prop = umbrella })
        s.rain = D.parts(160)
        s.win = {}
        for i = 1, 12 do s.win[i] = random() < 0.35 end
      end,
      update = function(s, dt) s.f:update(dt); D.rain_update(s.rain, dt, 3.2, 60, -10) end,
      draw = function(s, t, c)
        local cam = s.f.x - 46
        D.rect(0, 0, 128, 64, 0)
        -- il muro con le finestre
        for i = -1, 6 do
          local x = i * 24 - (cam * 0.6) % 24
          local lit = s.win[(i + floor(cam * 0.6 / 24)) % 12 + 1]
          D.window(x + 6, 14, 9, 11, 2, lit and 8 or nil)
          D.window(x + 6, 30, 9, 11, 2, nil)
        end
        D.rect(0, 52, 128, 12, 1)
        D.line(0, 52, 127, 52, 3)
        -- i lampioni, ogni 64 passi, e la loro luce a terra
        for i = -1, 3 do
          local x = i * 64 - (cam % 64) + 20
          D.rect(x, 18, 1, 34, 4)
          D.rect(x - 2, 17, 5, 2, 6)
          D.px(x, 19, 15)
          D.poly({ x - 1, 20, x + 1, 20, x + 12, 52, x - 12, 52 }, 2)
          D.line(x - 12, 53, x + 12, 53, 7)
          D.reflection(x, 55, 63, 6, t, 8)
        end
        D.rain_draw(s.rain, 0.8)
        fdraw(s.f, cam, 0)
      end },
    { d = 4.8,
      init = function(s, c)
        s.f = D.figura(64, 70, { s = 2.6, l = 8, pose = "head_down" })
        s.f:act({ { "wait", 1.4 }, { "pose", "look_up", 99 } })
        s.rain = D.parts(220)
      end,
      update = function(s, dt) s.f:update(dt); D.rain_update(s.rain, dt, 5, 64, -6) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        -- il cono del lampione, sopra di lui
        D.poly({ 60, 0, 68, 0, 96, 64, 32, 64 }, 2)
        D.rect(58, 0, 12, 2, 12)
        for _, p in ipairs(s.rain.list) do
          local inside = abs(p.x - 64) < 4 + p.y * 0.5
          if not p.splash then D.line(p.x, p.y, p.x + p.vx * 0.02, p.y - p.len, inside and p.l + 4 or p.l * 0.25) end
        end
        s.f:draw()
      end },
  },
}

-- 3. il ponte al tramonto ----------------------------------------------------
EP.ponte = {
  luce = "giorno",
  peso = function(dir, dest) return (dir ~= "su" and dir ~= "giu" and dest.strato >= -1 and dest.strato <= 2) and 3 or 0 end,
  terreno = "legno",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = walker(c, 8, 30, { s = 0.85, l = 1, dark = true, speed = 8 })
        s.birds = {}
        for i = 1, 5 do s.birds[i] = { x = R(-40, 0), y = R(6, 18), v = R(9, 14), p = R(0, 6) } end
      end,
      update = function(s, dt)
        s.f:update(dt)
        for _, b in ipairs(s.birds) do b.x = b.x + b.v * dt end
      end,
      draw = function(s, t, c)
        D.gradient(0, 36, 4, 10)
        D.circle(92, 36, 9, 14)
        D.rect(0, 36, 128, 28, 3)
        D.waves(37, 64, t, 7, 4, 3)
        D.reflection(92, 37, 63, 14, t, 13)
        -- il ponte: le arcate e il parapetto
        D.rect(0, 30, 128, 3, 1)
        for i = 0, 3 do
          local x = i * 36 + 4
          D.poly({ x, 33, x + 4, 33, x + 4, 46, x, 46 }, 1)
          for a = 0, 8 do
            local ang = pi * a / 8
            D.px(x + 4 + 16 - cos(ang) * 16, 33 + 13 - sin(ang) * 11, 1)
          end
        end
        D.line(0, 26, 127, 26, 1)
        for x = 0, 127, 6 do D.line(x, 26, x, 30, 1) end
        for _, b in ipairs(s.birds) do
          local w = sin(t * 9 + b.p) * 1.5
          D.line(b.x - 2, b.y - w, b.x, b.y, 1); D.line(b.x, b.y, b.x + 2, b.y - w, 1)
        end
        s.f:draw()
      end },
    { d = 4.8,
      init = function(s, c)
        s.f = D.figura(50, 64, { s = 2.4, l = 2, dark = true, pose = "window" })
        s.sun = 0
      end,
      update = function(s, dt) s.f:update(dt); s.sun = s.sun + dt end,
      draw = function(s, t, c)
        local sy = 34 + s.sun * 1.6
        D.gradient(0, 40, 5, 11)
        D.circle(98, sy, 8, 15)
        D.rect(0, 40, 128, 24, 4)
        D.waves(41, 64, t, 9, 3, 7)
        D.reflection(98, 41, 63, 12, t, 14)
        -- il parapetto in primo piano, su cui si appoggia
        D.rect(0, 46, 128, 3, 1)
        for x = 2, 127, 9 do D.rect(x, 49, 2, 15, 1) end
        s.f:draw()
      end },
  },
}

-- 4. scale che salgono verso la luce (di lato, poi coi suoi occhi) ----------
EP.salita = {
  peso = function(dir, dest) return dir == "su" and 4 or 0 end,
  terreno = "pietra",
  shots = {
    { d = 5.6,
      init = function(s, c)
        s.f = D.figura(-6, 70, { s = 1.1, l = 9, speed = 6 })
        s.f.on_step = function() c.steps = (c.steps or 0) + 1 end
        s.f:act({ { "walk", 300, 6, 70 - 306 * 0.62 } })
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local camx = s.f.x - 50
        local camy = s.f.y - 46
        D.rect(0, 0, 128, 64, 0)
        -- in alto, la porta da cui arriva la luce
        local wx, wy = 104 - c.k * 6, 4 + c.k * 4
        D.rect(wx, wy, 14, 20, 13)
        D.poly({ wx, wy + 20, wx + 14, wy + 20, wx - 30, 64, wx - 70, 64 }, 2)
        -- i gradini
        for i = -6, 60 do
          local x = i * 6 - 6 - camx
          local y = 70 - (i * 6) * 0.62 - camy
          if x > -8 and x < 136 then
            D.rect(x, y, 6, 64, 3)
            D.rect(x, y, 6, 1, 9)
            D.rect(x, y, 1, 4, 5)
          end
        end
        -- il corrimano
        D.line(-camx - 50, 60 + 31 - camy, 400 - camx, 60 - 450 * 0.62 + 31 - 26 - camy, 5)
        fdraw(s.f, camx, camy)
      end },
    { d = 3.8,
      init = function(s, c) s.p = {}; P.scale_su.init(s.p) end,
      update = function(s, dt, c) if P.scale_su.update(s.p, dt) then c.steps = (c.steps or 0) + 1 end end,
      draw = function(s, t, c) P.scale_su.draw(s.p, t, 0.3 + c.k * 0.7) end },
  },
}

-- 5. scale che scendono nel buio, una lampadina che oscilla ----------------
EP.discesa = {
  peso = function(dir, dest) return dir == "giu" and 4 or 0 end,
  terreno = "pietra",
  shots = {
    { d = 5.6,
      init = function(s, c)
        s.f = D.figura(-4, 4, { s = 1.1, l = 9, speed = 5.5, bent = 4 })
        s.f.on_step = function() c.steps = (c.steps or 0) + 1 end
        s.f:act({ { "walk", 300, 5.5, 4 + 304 * 0.62 } })
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local camx = s.f.x - 56
        local camy = s.f.y - 40
        D.rect(0, 0, 128, 64, 0)
        -- la lampadina in alto, sempre più lontana
        local bx, by = 30 - camx * 0.8, -6 - camy * 0.8
        local sw = sin(t * 1.3) * 3
        D.line(bx, by - 30, bx + sw, by, 3)
        D.circle(bx + sw, by + 1, 1.5, 15)
        for i = -4, 60 do
          local x = i * 6 - camx
          local y = 4 + (i * 6) * 0.62 - camy
          if x > -8 and x < 136 then
            local d = math.sqrt((x - bx) ^ 2 + (y - by) ^ 2)
            local l = max(0, 7 - d / 12)
            D.rect(x, y, 6, 70, l * 0.4)
            D.line(x, y, x + 5, y, l)
          end
        end
        local d = math.sqrt((56 - bx) ^ 2 + (40 - by) ^ 2)
        fdraw(s.f, camx, camy, max(2, 11 - d / 10))
      end },
    { d = 3.8,
      init = function(s, c) s.p = {}; P.scale_giu.init(s.p) end,
      update = function(s, dt, c) if P.scale_giu.update(s.p, dt) then c.steps = (c.steps or 0) + 1 end end,
      draw = function(s, t, c) P.scale_giu.draw(s.p, t, c.k) end },
  },
}

-- 6. il corridoio, le porte, una che si apre -------------------------------
EP.corridoio = {
  peso = function(dir, dest) return (dir ~= "su" and dest.strato <= 0) and 3 or 1 end,
  terreno = "legno",
  shots = {
    { d = 5.2,
      init = function(s, c)
        s.f = walker(c, 40, 54, { s = 1.3, l = 10, speed = 6 })
        s.lit = {}
        for i = 1, 8 do s.lit[i] = random() < 0.4 end
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local cam = s.f.x - 40
        D.rect(0, 0, 128, 64, 2)
        D.rect(0, 0, 128, 6, 1)
        D.rect(0, 40, 128, 2, 3)
        D.rect(0, 54, 128, 10, 1)
        for x = -(cam % 8), 127, 8 do D.line(x, 54, x - 6, 63, 2) end
        for i = -1, 4 do
          local n = i + floor(cam / 40)
          local x = i * 40 - (cam % 40) + 8
          local lit = s.lit[n % 8 + 1]
          D.rect(x, 22, 13, 32, 1)
          D.rect(x + 1, 23, 11, 31, 3)
          D.px(x + 10, 39, 9)
          if lit then D.line(x + 1, 54, x + 11, 54, 12); D.poly({ x + 1, 55, x + 11, 55, x + 16, 63, x - 4, 63 }, 4) end
          -- le lampade del soffitto
          local lx = i * 40 - (cam % 40) + 28
          D.rect(lx - 3, 6, 7, 1, 9)
        end
        fdraw(s.f, cam, 0)
      end },
    { d = 4.6,
      init = function(s, c) s.o = 0 end,
      update = function(s, dt, c) s.o = min(1, s.o + dt * (c.k > 0.35 and 0.42 or 0)) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 1)
        -- la porta, vicina; si apre e dentro c'è luce
        local w = 46
        local open = s.o * w
        D.rect(40, 4, w, 60, 15)
        D.poly({ 40 + open, 4, 40 + w, 4, 40 + w, 64, 40 + open, 64 }, 3)
        D.rect(40 + w - 6, 34, 3, 2, 10)
        D.rect(36, 2, 4, 62, 2); D.rect(86, 2, 4, 62, 2)
        -- la sua mano sulla maniglia
        local hx = 80 - s.o * 8
        D.poly({ 128, 44, 128, 64, hx + 10, 42, hx + 6, 34 }, 2)
        D.circle(hx + 3, 36, 3, 8)
        D.rect(hx, 34, 4, 2, 9)
        if s.o > 0.6 then D.flash((s.o - 0.6) * 30) end
      end },
  },
}

-- 7. nel bosco, con i raggi del sole ---------------------------------------
EP.bosco = {
  luce = "giorno",
  peso = function(dir, dest) return (dir ~= "giu" and dest.strato >= 0) and 3 or 0 end,
  terreno = "foglie",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = walker(c, 44, 54, { s = 1.05, l = 2, dark = true, speed = 7 })
        s.leaves = D.parts(30)
      end,
      update = function(s, dt, c)
        s.f:update(dt)
        if random() < dt * 4 then D.spawn(s.leaves, { x = R(0, 128), y = 4, vx = R(-3, 3), vy = R(5, 9), life = 8, ph = R(0, 6) }) end
        D.parts_update(s.leaves, dt)
      end,
      draw = function(s, t, c)
        local cam = s.f.x - 44
        D.gradient(0, 54, 9, 6)
        -- tre file di alberi che scorrono a velocità diverse
        for i = -1, 12 do local x = i * 12 - (cam * 0.25) % 12; D.rect(x, 0, 2, 54, 7) end
        for i = -1, 6 do local x = i * 26 - (cam * 0.55) % 26 + 5; D.rect(x, 0, 3, 54, 4) end
        -- i raggi, netti
        for i = 0, 3 do
          local x = i * 34 + 10 - (cam * 0.4) % 34
          D.poly({ x, 0, x + 4, 0, x + 26, 54, x + 20, 54 }, 11)
        end
        D.rect(0, 54, 128, 10, 3)
        fdraw(s.f, cam, 0)
        for i = -1, 3 do local x = i * 56 - (cam * 1.6) % 56; D.rect(x, 0, 7, 64, 1) end
        for _, p in ipairs(s.leaves.list) do D.px(p.x + sin(t * 2 + p.ph) * 2, p.y, 12) end
      end },
    { d = 4.6,
      init = function(s, c)
        s.f = D.figura(56, 74, { s = 2.6, l = 2, dark = true, pose = "stand" })
        s.f:act({ { "wait", 0.8 }, { "pose", "look_up", 99 } })
        s.leaves = D.parts(30); s.b = -20
      end,
      update = function(s, dt)
        s.f:update(dt); s.b = s.b + dt * 34
        if random() < dt * 5 then D.spawn(s.leaves, { x = R(0, 128), y = 0, vx = R(-2, 2), vy = R(4, 8), life = 10, ph = R(0, 6) }) end
        D.parts_update(s.leaves, dt)
      end,
      draw = function(s, t, c)
        D.gradient(0, 64, 11, 7)
        D.poly({ 70, 0, 80, 0, 120, 64, 104, 64 }, 14)
        D.poly({ 20, 0, 26, 0, 50, 64, 40, 64 }, 13)
        -- i rami in alto, controluce
        D.thick(0, 6, 60, 2, 2, 2); D.thick(128, 10, 80, 0, 2, 2); D.thick(30, 4, 40, 12, 1, 2)
        s.f:draw()
        local by = 14 + sin(s.b * 0.2) * 3
        D.line(s.b - 2, by - 1, s.b, by, 2); D.line(s.b, by, s.b + 2, by - 1, 2)
        for _, p in ipairs(s.leaves.list) do D.px(p.x + sin(t * 2 + p.ph) * 3, p.y, 3) end
      end },
  },
}

-- 8. lungo il mare, di notte, le impronte ----------------------------------
EP.spiaggia = {
  luce = "notte",
  peso = function(dir, dest)
    if dir == "su" or dir == "giu" then return 0 end
    return (dest.terreno == "sabbia" or dest.terreno == "acqua") and 6 or ((dest.strato >= 0 and dest.strato <= 2) and 1 or 0)
  end,
  terreno = "sabbia",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = walker(c, 44, 54, { s = 1.05, l = 9, speed = 6 })
        s.prints = {}
        s.f.on_step = function(f) c.steps = (c.steps or 0) + 1; s.prints[#s.prints + 1] = f.x end
        s.stars = D.stars_gen(50, random(999), 2, 26)
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local cam = s.f.x - 44
        D.rect(0, 0, 128, 64, 0)
        D.stars(s.stars, t, 0.9)
        D.moon(26, 12, 3, 14, 0)
        D.rect(0, 30, 128, 18, 1)
        D.waves(30, 47, t, 7, 3, 11)
        D.reflection(26, 31, 46, 5, t, 10)
        local sh = 48 + sin(t * 0.9) * 1.5
        D.rect(0, sh, 128, 64 - sh, 3)
        D.line(0, sh, 127, sh, 10)
        for _, x in ipairs(s.prints) do local sx = x - cam; if sx > -2 and sx < 130 then D.px(sx - 1, 56, 1) end end
        fdraw(s.f, cam, 0)
      end },
    { d = 4.8,
      init = function(s, c) s.f = D.figura(64, 52, { s = 1.1, l = 9, pose = "sit_ground" }) end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        D.gradient(0, 30, 0, 2)
        D.moon(96, 10, 5, 15, 2)
        D.rect(0, 30, 128, 20, 1)
        D.waves(30, 49, t * 0.7, 7, 2, 13)
        D.reflection(96, 31, 48, 8, t, 12)
        local sh = 49 + sin(t * 0.7) * 1.2
        D.rect(0, sh, 128, 64 - sh, 3)
        D.line(0, sh, 127, sh, 9)
        s.f:draw()
      end },
  },
}

-- 9. in bicicletta tra i pioppi, da bambino ---------------------------------
EP.bicicletta = {
  luce = "giorno",
  peso = function(dir, dest) return (dir ~= "giu" and dest.strato >= 1 and dest.strato <= 2) and 4 or 0 end,
  terreno = "erba",
  shots = {
    { d = 5.2,
      init = function(s, c) s.f = D.figura(50, 47, { s = 1.2, l = 2, dark = true, child = true, pose = "sit" }); s.x = 0; s.cr = 0 end,
      update = function(s, dt, c)
        s.f:update(dt)
        local o = s.cr
        s.x = s.x + dt * 22; s.cr = s.cr + dt * 5
        if floor(o / pi) ~= floor(s.cr / pi) then c.steps = (c.steps or 0) + 0 end
      end,
      draw = function(s, t, c)
        D.gradient(0, 40, 6, 12)
        D.circle(90, 40, 10, 15)
        D.rect(0, 40, 128, 24, 4)
        for y = 42, 63, 3 do D.line(0, y, 127, y, 5 + (y - 42) / 7) end
        -- i pioppi
        for i = -1, 8 do
          local x = i * 18 - (s.x * 0.5) % 18
          D.poly({ x, 40, x + 2, 40, x + 1, 22 }, 2)
          D.rect(x, 26, 3, 14, 2)
        end
        D.rect(0, 50, 128, 3, 6)
        -- la bicicletta
        local bx, by = 50, 50
        for _, wx in ipairs({ bx - 6, bx + 6 }) do
          D.circle(wx, by - 3.5, 3.5, 1, true)
          D.line(wx, by - 3.5, wx + cos(s.cr * 2) * 3, by - 3.5 + sin(s.cr * 2) * 3, 1)
        end
        D.line(bx - 6, by - 3.5, bx, by - 3.5, 1); D.line(bx, by - 3.5, bx - 2, by - 8, 1)
        D.line(bx - 2, by - 8, bx + 4, by - 8, 1); D.line(bx + 4, by - 8, bx + 6, by - 3.5, 1)
        D.line(bx + 4, by - 8, bx + 4, by - 10, 1); D.line(bx + 3, by - 10, bx + 6, by - 10, 1)
        -- le gambe che pedalano
        local f = s.f
        f.x, f.y = bx - 2.5, by - 3.5
        f.cur.lean = 18; f.cur.ua1 = 70; f.cur.ua2 = 66; f.cur.fa1 = 90; f.cur.fa2 = 86
        f.cur.th1 = 60 + sin(s.cr) * 25; f.cur.th2 = 60 - sin(s.cr) * 25
        f.cur.sh1 = f.cur.th1 - 60 - cos(s.cr) * 20; f.cur.sh2 = f.cur.th2 - 60 + cos(s.cr) * 20
        f:draw()
      end },
    { d = 4.6,
      init = function(s, c) s.x = -10 end,
      update = function(s, dt) s.x = s.x + dt * 14 end,
      draw = function(s, t, c)
        D.gradient(0, 44, 7, 13)
        D.circle(70, 44, 22, 15)
        D.rect(0, 44, 128, 20, 3)
        for i = 0, 5 do local x = 10 + i * 22; D.poly({ x, 44, x + 3, 44, x + 1.5, 24 }, 2) end
        -- la piccola sagoma che passa sul sole
        local x = s.x
        D.circle(x - 3, 42, 1.5, 1, true); D.circle(x + 3, 42, 1.5, 1, true)
        D.line(x - 3, 42, x + 3, 42, 1); D.line(x, 42, x, 38, 1)
        D.circle(x, 36, 1.2, 1)
      end },
  },
}

-- 10. nella neve, il fiato che si vede -------------------------------------
EP.neve = {
  luce = "giorno",
  peso = function(dir, dest) return (dir ~= "giu" and dest.strato >= 2) and 4 or 0 end,
  terreno = "neve",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = walker(c, 46, 52, { s = 1.05, l = 2, dark = true, speed = 5, bent = 8 })
        s.f.flap = 0.6
        s.snow = D.parts(160); s.prints = {}
        s.f.on_step = function(f) c.steps = (c.steps or 0) + 1; s.prints[#s.prints + 1] = f.x end
        s.h = D.ridge_gen(random(999), 30, 10, 0.8)
      end,
      update = function(s, dt, c) s.f:update(dt); D.snow_update(s.snow, dt, 4, 64, -14, c.t) end,
      draw = function(s, t, c)
        local cam = s.f.x - 46
        D.gradient(0, 40, 6, 9)
        D.ridge(s.h, 11, 64, cam * 0.15)
        for i = -1, 6 do local x = i * 30 - (cam * 0.5) % 30; D.pine(x, 46, 14, 3, sin(t + i) * 0.6) end
        D.rect(0, 50, 128, 14, 13)
        for _, x in ipairs(s.prints) do local sx = x - cam; if sx > -2 and sx < 130 then D.px(sx, 53, 8) end end
        fdraw(s.f, cam, 0)
        D.snow_draw(s.snow, 15)
      end },
    { d = 4.6,
      init = function(s, c)
        s.f = D.figura(60, 74, { s = 2.6, l = 2, dark = true, pose = "head_down" })
        s.snow = D.parts(200); s.br = D.parts(20)
      end,
      update = function(s, dt, c)
        s.f:update(dt); D.snow_update(s.snow, dt, 6, 64, -18, c.t)
        if (c.t % 2.2) < dt * 1.5 then
          for i = 1, 5 do D.spawn(s.br, { x = 68 + R(0, 2), y = 31 + R(0, 2), vx = R(4, 9), vy = R(-3, 0), life = 1.6 }) end
        end
        D.parts_update(s.br, dt)
      end,
      draw = function(s, t, c)
        D.gradient(0, 64, 7, 11)
        s.f:draw()
        for _, p in ipairs(s.br.list) do D.circle(p.x, p.y, 0.6 + p.age, 13 * (1 - p.age / 1.6)) end
        D.snow_draw(s.snow, 15)
      end },
  },
}

-- 11. l'autobus della notte ---------------------------------------------------
EP.autobus = {
  luce = "notte",
  peso = function(dir, dest) return (dir ~= "su" and dest.strato <= 0) and 3 or 0 end,
  terreno = "metallo",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = D.figura(70, 50, { s = 1.6, l = 8, pose = "sit" })
        s.f:act({ { "wait", 1.2 }, { "pose", "sit_slump", 99 } })
        s.lights = {}
        for i = 1, 5 do s.lights[i] = R(0, 260) end
        s.off = 0
      end,
      update = function(s, dt) s.f:update(dt); s.off = s.off + dt * 70 end,
      draw = function(s, t, c)
        local j = sin(t * 23) * 0.3
        D.rect(0, 0, 128, 64, 1)
        -- i finestrini: fuori passa la città
        local lit = 0
        for _, L in ipairs(s.lights) do
          local x = (L - s.off) % 260 - 40
          if x > -10 and x < 128 then
            D.rect(x, 14, 3, 20, 12)
            if abs(x - 70) < 20 then lit = max(lit, 1 - abs(x - 70) / 20) end
          end
        end
        for i = 0, 3 do
          local x = i * 34 - 4
          D.rect(x, 12 + j, 4, 26, 3)
        end
        D.rect(0, 10 + j, 128, 2, 3); D.rect(0, 36 + j, 128, 4, 3)
        -- i sedili
        for i = 0, 3 do D.rect(i * 34 + 14, 40 + j, 10, 14, 2); D.rect(i * 34 + 22, 30 + j, 3, 12, 2) end
        D.rect(0, 54, 128, 10, 0)
        fdraw(s.f, 0, -j, 5 + lit * 8)
      end },
    { d = 4.6,
      init = function(s, c) s.x = -90 end,
      update = function(s, dt) s.x = s.x + dt * 34 end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        D.rect(0, 46, 128, 18, 1)
        for i = 0, 2 do D.rect(i * 50 + 10, 14, 1, 32, 2); D.rect(i * 50 + 8, 13, 5, 2, 7) end
        -- l'autobus che passa, i finestrini accesi, una sola sagoma
        local x = s.x
        D.rect(x, 26, 80, 18, 3)
        for i = 0, 6 do D.rect(x + 4 + i * 11, 29, 8, 7, 10) end
        D.circle(x + 41, 32, 1.4, 1); D.rect(x + 39, 34, 4, 2, 1)
        D.circle(x + 14, 45, 3, 1); D.circle(x + 66, 45, 3, 1)
        D.rect(x + 78, 38, 2, 2, 15)
        -- il riflesso sull'asfalto bagnato
        for i = 0, 6 do D.line(x + 4 + i * 11, 50 + (i % 2), x + 11 + i * 11, 50 + (i % 2), 4) end
      end },
  },
}

-- 12. il treno: dentro e fuori ------------------------------------------------
EP.treno = {
  luce = "notte",
  peso = function(dir, dest) return (dir ~= "su" and dir ~= "giu") and 2 or 0 end,
  terreno = "metallo",
  shots = {
    { d = 5.0,
      init = function(s, c) s.p = {}; P.finestrino.init(s.p, c.dest, c.dir) end,
      update = function(s, dt, c) P.finestrino.update(s.p, dt) end,
      draw = function(s, t, c) P.finestrino.draw(s.p, t, c.k) end },
    { d = 5.0,
      init = function(s, c) s.x = -150; s.stars = D.stars_gen(40, random(99), 2, 28) end,
      update = function(s, dt) s.x = s.x + dt * 48 end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        D.stars(s.stars, t, 0.8)
        D.moon(20, 12, 4, 13, 0)
        -- il viadotto
        D.rect(0, 40, 128, 3, 2)
        for i = 0, 5 do
          local x = i * 24
          D.rect(x, 43, 4, 21, 2)
          for a = 0, 10 do local ang = pi * a / 10; D.px(x + 4 + 10 - cos(ang) * 10, 43 + 10 - sin(ang) * 8, 2) end
        end
        for v = 0, 3 do
          local x = s.x + v * 38
          D.rect(x, 32, 36, 8, 3)
          for i = 0, 4 do D.rect(x + 2 + i * 7, 34, 5, 3, 11) end
        end
        D.rect(s.x + 150, 34, 2, 2, 15)
      end },
  },
}

-- 13. salire oltre le nuvole --------------------------------------------------
EP.nuvole = {
  luce = "giorno",
  peso = function(dir, dest) return (dir == "su" and dest.strato >= 2) and 4 or 0 end,
  terreno = "nuvola",
  shots = {
    { d = 4.4,
      init = function(s, c) s.p = {}; P.nuvole.init(s.p) end,
      update = function(s, dt) P.nuvole.update(s.p, dt) end,
      draw = function(s, t, c) P.nuvole.draw(s.p, t, c.k) end },
    { d = 5.0,
      init = function(s, c)
        s.f = walker(c, 20, 44, { s = 1.0, l = 2, dark = true, speed = 6 })
        s.cl = {}
        for i = 1, 14 do s.cl[i] = { x = i * 11 - 10, r = R(5, 9) } end
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        D.gradient(0, 46, 9, 14)
        D.circle(100, 30, 8, 15)
        for _, cl in ipairs(s.cl) do D.circle(cl.x, 50, cl.r, 13) end
        D.rect(0, 50, 128, 14, 13)
        for _, cl in ipairs(s.cl) do D.circle(cl.x + 4, 58, cl.r, 15) end
        if s.f.x > 120 then s.f.x = 120 end
        s.f:draw()
      end },
  },
}

-- 14. cadere ------------------------------------------------------------------
EP.caduta = {
  peso = function(dir, dest) return (dir == "giu" and dest.strato <= -2) and 4 or 0 end,
  terreno = "vuoto",
  shots = {
    { d = 5.0,
      init = function(s, c) s.p = {}; P.caduta.init(s.p) end,
      update = function(s, dt) P.caduta.update(s.p, dt) end,
      draw = function(s, t, c) P.caduta.draw(s.p, t, c.k) end },
    { d = 4.6,
      init = function(s, c) s.f = D.figura(64, 52, { s = 1.6, l = 7, pose = "curl" }) end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        local a = min(1, c.k * 2)
        D.poly({ 60, 0, 68, 0, 78, 54, 50, 54 }, 2 * a)
        D.rect(44, 53, 40, 1, 4 * a)
        s.f:draw()
      end },
  },
}

-- 15. affondare ---------------------------------------------------------------
EP.acqua = {
  peso = function(dir, dest) return (dir == "giu" and dest.terreno == "acqua") and 6 or 0 end,
  terreno = "acqua",
  shots = {
    { d = 4.4,
      init = function(s, c) s.f = walker(c, 36, 46, { s = 1.0, l = 2, dark = true, speed = 7 }) end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        D.gradient(0, 40, 3, 8)
        D.rect(0, 40, 128, 24, 4)
        D.waves(40, 64, t, 9, 3, 5)
        -- entra nell'acqua: la superficie gli sale addosso
        local sink = max(0, (s.f.x - 50) * 0.7)
        s.f.y = 46 + sink
        s.f:draw()
        D.rect(0, 46, 128, 18, 4)
        D.waves(46, 64, t, 9, 3, 6)
        D.line(0, 46, 127, 46, 10)
      end },
    { d = 5.0,
      init = function(s, c) s.p = {}; P.acqua.init(s.p) end,
      update = function(s, dt) P.acqua.update(s.p, dt) end,
      draw = function(s, t, c) P.acqua.draw(s.p, t, c.k) end },
  },
}

-- 16. con la lanterna, nel buio ----------------------------------------------
EP.lanterna = {
  luce = "notte",
  peso = function(dir, dest) return (dir ~= "su" and dest.strato <= -1) and 4 or 0 end,
  terreno = "foglie",
  shots = {
    { d = 5.4,
      init = function(s, c)
        s.f = walker(c, 50, 52, { s = 1.15, l = 9, speed = 5, prop = lantern, bent = 3 })
        s.f.cur.ua1 = 30
        s.trees = {}
        for i = 1, 12 do s.trees[i] = { x = i * 26 + R(-6, 6), h = R(14, 30), seed = random(999) } end
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local cam = s.f.x - 50
        D.rect(0, 0, 128, 64, 0)
        local lx, ly = s.f.hand[1] or 54, (s.f.hand[2] or 44) + 3
        local fl = 1 + D.noise(t * 6) * 0.15
        -- la luce: tre anelli netti, poi niente
        D.circle(lx, ly, 20 * fl, 1); D.circle(lx, ly, 12 * fl, 2)
        D.rect(0, 52, 128, 12, 0)
        D.line(max(0, lx - 26), 52, min(127, lx + 26), 52, 3)
        for _, tr in ipairs(s.trees) do
          local x = (tr.x - cam) % 312 - 30
          local d = abs(x - lx)
          if d < 40 then D.bare_tree(x, 52, tr.h, max(1, 5 - d / 9), tr.seed, 0) end
        end
        fdraw(s.f, cam, 0)
      end },
    { d = 4.6,
      init = function(s, c) s.f = D.figura(60, 74, { s = 2.6, l = 7, pose = "head_down", prop = lantern }); s.f.cur.ua1 = 40 end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        local dim = 1 - max(0, c.k - 0.6) * 2
        local lx, ly = s.f.hand[1] or 66, (s.f.hand[2] or 50) + 6
        D.circle(lx, ly, 26 * dim, 1); D.circle(lx, ly, 14 * dim, 2)
        s.f.l = max(1, 9 * dim)
        s.f:draw()
      end },
  },
}

-- 17. la finestra accesa: fuori, a guardare dentro --------------------------
EP.finestra = {
  luce = "notte",
  peso = function(dir, dest) return (dest.strato <= 1 and dest.strato >= -1) and 3 or 0 end,
  terreno = "erba",
  shots = {
    { d = 5.2,
      init = function(s, c)
        s.f = D.figura(-6, 52, { s = 1.0, l = 1, dark = true, speed = 6 })
        s.f.on_step = function() c.steps = (c.steps or 0) + 1 end
        s.f:act({ { "walk", 70 }, { "pose", "stand", 9 } })
        s.stars = D.stars_gen(40, random(99), 2, 30)
      end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        D.stars(s.stars, t, 0.8)
        D.rect(0, 52, 128, 12, 1)
        -- la casa, una sola finestra accesa
        D.rect(78, 24, 40, 28, 2)
        D.poly({ 74, 24, 122, 24, 98, 10 }, 2)
        D.rect(108, 12, 4, 8, 2)
        D.rect(88, 32, 12, 10, 12)
        D.line(94, 32, 94, 41, 2); D.line(88, 36, 99, 36, 2)
        D.poly({ 88, 52, 100, 52, 104, 60, 82, 60 }, 3)
        s.f:draw()
      end },
    { d = 5.0,
      init = function(s, c)
        s.a = D.figura(48, 50, { s = 1.6, l = 4, pose = "sit", face = 1 })
        s.b = D.figura(80, 50, { s = 1.55, l = 4, pose = "sit", face = -1, bun = true })
        s.a:act({ { "wait", 2 }, { "pose", "talk", 2 }, { "pose", "sit", 9 } })
        s.f = D.figura(118, 78, { s = 3.4, l = 0, dark = true, sil = true, pose = "window", face = -1 })
      end,
      update = function(s, dt) s.a:update(dt); s.b:update(dt); s.f:update(dt) end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        -- dentro: la cucina dei nonni, la luce calda
        D.rect(14, 6, 100, 52, 10)
        D.rect(14, 40, 100, 18, 9)
        D.rect(60, 8, 1, 6, 4); D.rect(57, 14, 7, 3, 15)
        D.rect(42, 40, 44, 3, 5); D.rect(46, 43, 2, 12, 5); D.rect(80, 43, 2, 12, 5)
        D.circle(64, 38, 1.5, 13)
        s.a:draw(); s.b:draw()
        -- la cornice della finestra, il vetro
        D.rect(0, 0, 128, 6, 1); D.rect(0, 58, 128, 6, 1)
        D.rect(0, 0, 14, 64, 1); D.rect(114, 0, 14, 64, 1)
        D.rect(63, 6, 2, 52, 1); D.rect(14, 30, 100, 2, 1)
        -- lui, fuori, di spalle, una sagoma nera
        s.f:draw()
      end },
  },
}

-- 18. le fotografie e la porta: per i sentieri segreti -----------------------
EP.segreto = {
  peso = function(dir, dest) return dir == "segreto" and 10 or 0 end,
  terreno = "legno",
  shots = {
    { d = 4.6,
      init = function(s, c)
        s.p = {}; P.foto.init(s.p)
        for i, ph in ipairs(s.p.ph) do ph.x = i * 30 - 20 end
      end,
      update = function(s, dt) P.foto.update(s.p, dt) end,
      draw = function(s, t, c) P.foto.draw(s.p, t, c.k) end },
    { d = 5.0,
      init = function(s, c) s.p = {}; P.porta.init(s.p) end,
      update = function(s, dt, c) if P.porta.update(s.p, dt) then c.steps = (c.steps or 0) + 1 end end,
      draw = function(s, t, c) P.porta.draw(s.p, t, c.k) end },
  },
}

-- 19. l'aquilone sul prato, da bambino --------------------------------------
EP.aquilone = {
  luce = "giorno",
  peso = function(dir, dest) return (dir ~= "giu" and dest.strato >= 1) and 3 or 0 end,
  terreno = "erba",
  shots = {
    { d = 5.2,
      init = function(s, c)
        s.f = walker(c, 40, 54, { s = 1.0, l = 2, dark = true, child = true, speed = 10 })
        s.k = { x = 70, y = 14 }
      end,
      update = function(s, dt, c)
        s.f:update(dt)
        s.k.x = 70 + sin(c.t * 0.7) * 10; s.k.y = 14 + sin(c.t * 1.1) * 4
      end,
      draw = function(s, t, c)
        local cam = s.f.x - 40
        D.gradient(0, 46, 9, 13)
        D.circle(108, 12, 5, 15)
        for i = 0, 3 do D.cloud((i * 50 - cam * 0.1) % 180 - 30, 10 + i * 4, 18, 14, i + 3) end
        D.rect(0, 44, 128, 20, 8)
        for x = 0, 127, 2 do local xx = (x + cam) % 128; D.line(x, 64, x + sin(t * 2 + xx) * 0.8, 58 + (xx % 5), 6) end
        local hx, hy = s.f.hand[1], s.f.hand[2]
        screen.level(D.lv(4)); screen.move(hx, hy); screen.curve(hx + 10, hy - 16, s.k.x - 8, s.k.y + 14, s.k.x, s.k.y + 4); screen.stroke()
        D.poly({ s.k.x, s.k.y - 4, s.k.x + 3, s.k.y, s.k.x, s.k.y + 4, s.k.x - 3, s.k.y }, 2)
        for i = 1, 4 do D.px(s.k.x - i + sin(t * 4 + i) * 1.5, s.k.y + 4 + i * 2, 3) end
        fdraw(s.f, cam, 0)
      end },
    { d = 4.4,
      init = function(s, c) s.a = 0 end,
      update = function(s, dt) s.a = s.a + dt end,
      draw = function(s, t, c)
        D.gradient(0, 64, 13, 9)
        local x, y = 64 + sin(t * 0.8) * 14, 26 + sin(t * 1.3) * 6
        D.poly({ x, y - 12, x + 9, y, x, y + 12, x - 9, y }, 2)
        D.line(x, y - 12, x, y + 12, 6); D.line(x - 9, y, x + 9, y, 6)
        for i = 1, 8 do D.circle(x - i * 2 + sin(t * 3 + i * 0.7) * 3, y + 12 + i * 4, 1, 3) end
        D.line(x, y + 12, 40, 64, 4)
      end },
  },
}

-- 20. la barca sul lago, di notte ---------------------------------------------
EP.barca = {
  luce = "notte",
  peso = function(dir, dest)
    if dest.terreno == "acqua" then return 5 end
    return (dir ~= "su" and dest.strato <= 1 and dest.strato >= -3) and 1 or 0
  end,
  terreno = "acqua",
  shots = {
    { d = 5.4,
      init = function(s, c) s.x = -20; s.stars = D.stars_gen(50, random(99), 0, 30) end,
      update = function(s, dt, c)
        local o = s.x
        s.x = s.x + dt * 9
        if floor(o / 9) ~= floor(s.x / 9) then c.steps = (c.steps or 0) + 1 end
      end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        D.stars(s.stars, t, 0.9)
        D.moon(96, 12, 4, 14, 0)
        for x = 0, 127 do local h = 3 + sin(x * 0.05) * 2; D.rect(x, 34 - h, 1, h, 1) end
        D.rect(0, 34, 128, 30, 1)
        D.reflection(96, 35, 63, 8, t, 10)
        D.waves(35, 64, t * 0.6, 5, 2, 9)
        -- la barca, lui che rema
        local x = s.x
        local ro = sin(t * 2.2)
        D.poly({ x - 10, 44, x + 10, 44, x + 7, 47, x - 7, 47 }, 6)
        D.line(x - 10, 44, x + 10, 44, 9)
        D.circle(x, 36, 1.6, 8); D.rect(x - 1.5, 38, 3, 6, 8)
        D.line(x, 40, x + 8 + ro * 3, 48, 7); D.line(x, 40, x - 8 - ro * 3, 48, 7)
        if ro > 0.8 then D.ripple(x + 11, 48, 3, 6) end
      end },
    { d = 4.4,
      init = function(s, c) s.k = 0 end,
      update = function(s, dt) s.k = s.k + dt end,
      draw = function(s, t, c)
        D.rect(0, 0, 128, 64, 0)
        -- il remo che entra nell'acqua, da vicino
        D.rect(0, 30, 128, 34, 1)
        D.reflection(64, 31, 63, 20, t, 8)
        local a = sin(t * 1.6)
        local x1, y1 = 30, 4
        local x2, y2 = 70 + a * 14, 40 + a * 4
        D.thick(x1, y1, x2, y2, 3, 5)
        D.poly({ x2 - 3, y2 - 2, x2 + 8, y2 + 6, x2 + 4, y2 + 9, x2 - 6, y2 + 2 }, 6)
        if a < -0.5 then for r = 1, 3 do D.ripple(x2 + 2, 42, r * 4 + (t * 10 % 4), 8 - r * 2) end end
      end },
  },
}

-- 21. i fiori al cimitero ---------------------------------------------------------
EP.fiori = {
  peso = function(dir, dest) return (dest.strato <= 0 and dest.strato >= -1) and 2 or 0 end,
  terreno = "ghiaia",
  shots = {
    { d = 5.0,
      init = function(s, c) s.f = walker(c, 30, 54, { s = 1.1, l = 2, dark = true, speed = 4, prop = function(x, y) D.line(x, y, x + 1, y - 5, 6); D.circle(x + 1, y - 6, 1.5, 12) end }) end,
      update = function(s, dt) s.f:update(dt) end,
      draw = function(s, t, c)
        local cam = s.f.x - 30
        D.gradient(0, 40, 6, 9)
        for i = -1, 7 do local x = i * 22 - (cam * 0.6) % 22; D.cypress(x, 46, 24, 3, sin(t * 0.6 + i) * 0.4) end
        D.rect(0, 46, 128, 18, 6)
        for i = -1, 6 do local x = i * 24 - cam % 24 + 10; D.rect(x, 40, 8, 10, 9); D.poly({ x, 40, x + 8, 40, x + 4, 37 }, 9); D.cross(x + 4, 37, 4, 7) end
        fdraw(s.f, cam, 0)
      end },
    { d = 4.6,
      init = function(s, c) s.k = 0 end,
      update = function(s, dt) s.k = min(1, s.k + dt * 0.35) end,
      draw = function(s, t, c)
        D.gradient(0, 64, 8, 5)
        -- la mano che posa i fiori sotto la fotografia ovale
        D.rect(40, 0, 48, 64, 10)
        D.circle(64, 18, 8, 5); D.circle(64, 18, 6, 8)
        D.line(50, 36, 78, 36, 6); D.line(54, 40, 74, 40, 6)
        local y = 64 - s.k * 14
        D.thick(120, 64, 76, y, 6, 3)
        for i = 0, 2 do D.line(70 + i * 3, y, 66 + i * 4, y - 10, 6); D.circle(66 + i * 4, y - 11, 2, 12 + i) end
        D.circle(74, y, 3, 5)
      end },
  },
}

E.EP = EP

-------------------------------------------------------------------------------
-- la scelta: pesata per direzione e strato, mai uno degli ultimi tre
-------------------------------------------------------------------------------
-- è notte o giorno, là dove si va?
local NOTTE = { crick = 1, owl = 1, frogs = 1 }
local GIORNO = { birds = 1, cicada = 1, cowbells = 1, swallows = 1 }
function E.luce(dest)
  if dest.notte ~= nil then return dest.notte and "notte" or "giorno" end
  local tex = dest.musica and dest.musica.tex or {}
  local n, g = 0, 0
  for k, v in pairs(tex) do
    if NOTTE[k] then n = n + v end
    if GIORNO[k] then g = g + v end
  end
  if n > g and n > 0.05 then return "notte" end
  if g > n and g > 0.05 then return "giorno" end
  if dest.strato <= -1 then return "notte" end
  return nil
end

local recent = {}
function E.scegli(dir, from, dest)
  local pool, tot = {}, 0
  local luce = E.luce(dest)
  for name, ep in pairs(EP) do
    local w = ep.peso(dir, dest, from) or 0
    if luce and ep.luce and ep.luce ~= luce then w = w * 0.1 end
    for _, r in ipairs(recent) do if r == name then w = w * 0.05 end end
    if w > 0 then pool[#pool + 1] = { name, w }; tot = tot + w end
  end
  table.sort(pool, function(a, b) return a[1] < b[1] end)
  local name = "corridoio"
  if tot > 0 then
    local r = random() * tot
    for _, p in ipairs(pool) do r = r - p[2]; if r <= 0 then name = p[1]; break end end
  end
  table.insert(recent, 1, name)
  if #recent > 3 then recent[4] = nil end
  return name
end

-------------------------------------------------------------------------------
-- il proiettore
-------------------------------------------------------------------------------
function E.nuovo(name, dir, from, dest)
  local ep = EP[name]
  local c = { dest = dest, dir = dir, from = from, steps = 0, t = 0, k = 0 }
  local run = { name = name, ep = ep, c = c, i = 1, lt = 0, s = {}, dur = 0, terreno = ep.terreno }
  for _, sh in ipairs(ep.shots) do run.dur = run.dur + sh.d end
  ep.shots[1].init(run.s, c)
  return run
end

-- ritorna il numero di passi caduti in questo fotogramma
function E.update(run, dt)
  local c = run.c
  local sh = run.ep.shots[run.i]
  if not sh then return 0 end
  run.lt = run.lt + dt
  c.t = c.t + dt
  if run.lt >= sh.d and run.ep.shots[run.i + 1] then
    run.i = run.i + 1; run.lt = 0; run.s = {}
    sh = run.ep.shots[run.i]
    sh.init(run.s, c)
  end
  c.k = min(1, run.lt / sh.d)
  local before = c.steps
  sh.update(run.s, dt, c)
  return c.steps - before
end

-- a: dissolvenza esterna; gli stacchi tra le inquadrature sono brevi neri
function E.draw(run, t, a)
  local sh = run.ep.shots[run.i]
  if not sh then return end
  local g = D.gain
  local cut = 1
  if run.i > 1 then cut = min(1, run.lt / 0.35) end
  if run.ep.shots[run.i + 1] then cut = min(cut, (sh.d - run.lt) / 0.3) end
  D.gain = g * max(0, min(a or 1, cut))
  sh.draw(run.s, t, run.c)
  D.gain = g
end

return E
