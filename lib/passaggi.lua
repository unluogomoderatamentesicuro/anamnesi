-- ANAMNESI · i passaggi
-- Il cammino da un luogo all'altro. Ogni volta un modo diverso:
-- scale che salgono o scendono viste coi tuoi occhi, corridoi, boschi,
-- nuvole, cadute, acqua, fotografie, porte di luce, finestrini di treno.

local D = include("lib/disegno")
local P = {}
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local function R(a, b) return a + random() * (b - a) end

-- ogni passaggio: init(s), update(s, dt) che ritorna true quando cade un passo, draw(s, t)

-------------------------------------------------------------------------------
-- scale che salgono, in prima persona
-------------------------------------------------------------------------------
P.scale_su = {
  init = function(s) s.p = 0 end,
  update = function(s, dt) local o = s.p; s.p = s.p + dt * 1.6; return floor(o) ~= floor(s.p) end,
  draw = function(s, t, k)
    local bob = sin(s.p * pi) * 1.5
    D.gradient(0, 64, 1 + k * 3, 0)
    D.circle(64, 6, 10 + k * 14, 2 + k * 3); D.circle(64, 6, 5 + k * 6, 4 + k * 6)
    local fr = s.p % 1
    for j = 9, 0, -1 do
      local d = j - fr + 0.2
      local sc = 1 / (1 + d * 0.5)
      local sc2 = 1 / (1 + (d + 1) * 0.5)
      local y1 = 64 - 58 * (1 - sc) + bob
      local y2 = 64 - 58 * (1 - sc2) + bob
      local w1, w2 = 70 * sc, 70 * sc2
      local mid = y1 - (y1 - y2) * 0.45
      local lv = 2 + (1 - d / 10) * 4
      D.poly({ 64 - w1, y1, 64 + w1, y1, 64 + w1 * 0.98, mid, 64 - w1 * 0.98, mid }, lv - 1)
      D.poly({ 64 - w1 * 0.98, mid, 64 + w1 * 0.98, mid, 64 + w2, y2, 64 - w2, y2 }, lv + 1)
      D.line(64 - w1 * 0.98, mid, 64 + w1 * 0.98, mid, lv + 3)
    end
    -- il corrimano
    D.line(0, 30 + bob, 50, 4 + bob, 5); D.line(127, 30 + bob, 78, 4 + bob, 5)
  end,
}

-------------------------------------------------------------------------------
-- scale che scendono, in prima persona
-------------------------------------------------------------------------------
P.scale_giu = {
  init = function(s) s.p = 0 end,
  update = function(s, dt) local o = s.p; s.p = s.p + dt * 1.5; return floor(o) ~= floor(s.p) end,
  draw = function(s, t, k)
    local bob = sin(s.p * pi) * 1.5
    D.rect(0, 0, 128, 64, 0)
    -- i muri ai lati, che si stringono verso il basso
    D.poly({ 0, 0, 40, 0, 56, 64, 0, 64 }, 1); D.poly({ 128, 0, 88, 0, 72, 64, 128, 64 }, 1)
    local fr = s.p % 1
    for j = 8, 0, -1 do
      local d = j - fr + 0.3
      local sc = 1 / (1 + d * 0.45)
      local sc2 = 1 / (1 + (d + 1) * 0.45)
      local y1 = 4 + 60 * (1 - sc) + bob
      local y2 = 4 + 60 * (1 - sc2) + bob
      local w1, w2 = 46 * sc + 8, 46 * sc2 + 8
      local mid = y1 + (y2 - y1) * 0.6
      local lv = max(1, (8 - d) * 0.9 - k * 2)
      D.poly({ 64 - w1, y1, 64 + w1, y1, 64 + w1 * 0.97, mid, 64 - w1 * 0.97, mid }, lv)
      D.poly({ 64 - w1 * 0.97, mid, 64 + w1 * 0.97, mid, 64 + w2, y2, 64 - w2, y2 }, lv * 0.45)
      D.line(64 - w1, y1, 64 + w1, y1, lv + 3)
    end
    -- il corrimano
    D.line(2, 12 + bob, 50, 62 + bob, 5); D.line(125, 12 + bob, 78, 62 + bob, 5)
    D.glow(64, 64, 14, 2)
  end,
}

-------------------------------------------------------------------------------
-- un corridoio con le porte che passano
-------------------------------------------------------------------------------
P.corridoio = {
  init = function(s) s.p = 0 end,
  update = function(s, dt) local o = s.p; s.p = s.p + dt * 1.4; return floor(o * 2) ~= floor(s.p * 2) end,
  draw = function(s, t, k)
    local vx, vy = 64, 30 + sin(s.p * 2 * pi) * 1.2
    D.rect(0, 0, 128, 64, 0)
    D.poly({ 0, 64, 128, 64, vx + 6, vy + 4, vx - 6, vy + 4 }, 3)
    D.poly({ 0, 0, 128, 0, vx + 6, vy - 4, vx - 6, vy - 4 }, 1)
    D.rect(vx - 6, vy - 4, 12, 8, 5 + k * 6)
    local fr = s.p % 1
    for j = 6, 0, -1 do
      local d = j - fr + 0.1
      local sc = 1 / (1 + d * 0.7)
      for side = -1, 1, 2 do
        local x = vx + side * 70 * sc
        local h = 46 * sc
        local w = 12 * sc
        D.rect(side > 0 and x - w or x, vy - h * 0.55, w, h, 1 + sc * 2)
        D.rect(side > 0 and x - w + w * 0.2 or x + w * 0.6, vy - h * 0.1, max(1, w * 0.15), max(1, h * 0.05), 6)
      end
      D.rect(vx - 20 * sc, vy - 32 * sc - 2, 40 * sc, max(1, 2 * sc), 8 * sc + 2)
    end
  end,
}

-------------------------------------------------------------------------------
-- un sentiero nel bosco, in prima persona
-------------------------------------------------------------------------------
P.bosco = {
  init = function(s)
    s.p = 0
    s.trees = {}
    for i = 1, 14 do s.trees[i] = { z = i * 0.6, side = (i % 2 == 0) and 1 or -1, off = R(10, 40) } end
  end,
  update = function(s, dt)
    local o = s.p
    s.p = s.p + dt * 1.3
    for _, tr in ipairs(s.trees) do
      tr.z = tr.z - dt * 1.3
      if tr.z < 0.2 then tr.z = tr.z + 8.4; tr.off = R(10, 40) end
    end
    return floor(o * 2) ~= floor(s.p * 2)
  end,
  draw = function(s, t, k)
    local bob = sin(s.p * 2 * pi) * 1
    D.gradient(0, 30, 4 + k * 2, 6)
    D.rect(0, 30 + bob, 128, 34, 2)
    D.poly({ 60, 30 + bob, 68, 30 + bob, 110, 64, 18, 64 }, 4)
    table.sort(s.trees, function(a, b) return a.z > b.z end)
    for _, tr in ipairs(s.trees) do
      local sc = 1 / tr.z
      local x = 64 + tr.side * tr.off * sc * 2
      local w = max(1, 3 * sc)
      local top = 30 + bob - 60 * sc
      D.rect(x - w / 2, top, w, 30 + bob - top + 10 * sc, min(1 + sc * 1.2, 3))
      D.circle(x, top, 8 * sc, 1)
    end
  end,
}

-------------------------------------------------------------------------------
-- di lato, tra i campi
-------------------------------------------------------------------------------
P.campi = {
  init = function(s, dest, dir)
    s.fig = D.figura(64, 52, { s = 0.9, l = 11 })
    s.fig.face = dir == "sx" and -1 or 1
    s.off = 0
    s.h1 = D.ridge_gen(random(999), 36, 10, 0.8)
    s.h2 = D.ridge_gen(random(999), 46, 6, 0.6)
    s.stars = D.stars_gen(40, random(999), 0, 30)
  end,
  update = function(s, dt)
    local f = s.fig
    local o = f.ph
    f.ph = f.ph + dt * 4.2
    f.q = {}; f:update(dt); f.walking = true
    s.off = s.off + dt * 9 * f.face
    return floor(o / pi) ~= floor(f.ph / pi)
  end,
  draw = function(s, t, k)
    D.gradient(0, 40, 0, 4)
    D.stars(s.stars, t, 0.8)
    D.moon(96, 10, 3, 12, 1, 0.4)
    D.ridge(s.h1, 2, 64, s.off * 0.3)
    D.ridge(s.h2, 3, 64, s.off * 0.7)
    D.rect(0, 52, 128, 12, 2)
    D.line(0, 52, 127, 52, 4)
    for i = 0, 10 do local x = (i * 14 - s.off) % 140 - 6; D.line(x, 52, x, 45, 5); D.line(x, 47, x + 14, 47, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- salire attraverso le nuvole
-------------------------------------------------------------------------------
P.nuvole = {
  init = function(s)
    s.c = {}
    for i = 1, 16 do s.c[i] = { x = R(0, 128), y = R(-10, 70), r = R(5, 14), v = R(14, 30) } end
  end,
  update = function(s, dt)
    for _, c in ipairs(s.c) do c.y = c.y + c.v * dt; if c.y > 80 then c.y = -14; c.x = R(0, 128) end end
    return false
  end,
  draw = function(s, t, k)
    D.gradient(0, 64, 4 + k * 6, 8 + k * 5)
    for _, c in ipairs(s.c) do D.circle(c.x, c.y, c.r, 10 + (c.v / 30) * 3) end
  end,
}

-------------------------------------------------------------------------------
-- cadere nel buio
-------------------------------------------------------------------------------
P.caduta = {
  init = function(s)
    s.ps = {}
    for i = 1, 40 do s.ps[i] = { x = R(0, 128), y = R(0, 64), v = R(30, 80) } end
    s.fig = D.figura(64, 40, { s = 1.0, l = 8, pose = "float" })
    s.ft = {}
    for k, v in pairs(D.POSE.float) do s.ft[k] = v end
    s.fig.tgt = s.ft
  end,
  update = function(s, dt)
    for _, p in ipairs(s.ps) do p.y = p.y - p.v * dt; if p.y < 0 then p.y = 64; p.x = R(0, 128) end end
    s.ft.rot = (s.ft.rot or 0) + dt * 20
    s.fig:update(dt)
    return false
  end,
  draw = function(s, t, k)
    D.rect(0, 0, 128, 64, 0)
    for _, p in ipairs(s.ps) do D.line(p.x, p.y, p.x, p.y + p.v * 0.06, 2 + p.v / 30) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- affondare nell'acqua
-------------------------------------------------------------------------------
P.acqua = {
  init = function(s)
    s.b = {}
    for i = 1, 24 do s.b[i] = { x = R(0, 128), y = R(0, 64), v = R(8, 20), r = R(0.4, 1.6) } end
    s.fig = D.figura(64, 36, { s = 1.0, l = 7, pose = "float" })
  end,
  update = function(s, dt)
    for _, b in ipairs(s.b) do b.y = b.y - b.v * dt; if b.y < -2 then b.y = 66; b.x = R(0, 128) end end
    s.fig:update(dt)
    return false
  end,
  draw = function(s, t, k)
    D.gradient(0, 64, 5 - k * 3, 0)
    for i = 0, 4 do
      local x0 = (i * 30 + t * 2) % 150 - 10
      for d = 0, 40, 3 do D.px(x0 + d * 0.4, d, 4 - d / 12) end
    end
    s.fig:draw()
    for _, b in ipairs(s.b) do if b.r < 0.9 then D.px(b.x, b.y, 7) else D.circle(b.x, b.y, b.r, 7, true) end end
  end,
}

-------------------------------------------------------------------------------
-- le fotografie che scorrono
-------------------------------------------------------------------------------
P.foto = {
  init = function(s)
    s.ph = {}
    for i = 1, 7 do s.ph[i] = { x = 130 + i * 30, y = R(8, 34), a = R(-0.3, 0.3), k = random(4), v = R(18, 28), z = R(0.7, 1.2) } end
  end,
  update = function(s, dt)
    for _, p in ipairs(s.ph) do p.x = p.x - p.v * dt; if p.x < -40 then p.x = 150; p.y = R(8, 34); p.k = random(4) end end
    return false
  end,
  draw = function(s, t, k)
    D.rect(0, 0, 128, 64, 0)
    for _, p in ipairs(s.ph) do
      local w, h = 22 * p.z, 26 * p.z
      local c, sn = cos(p.a), sin(p.a)
      local function pt(dx, dy) return p.x + dx * c - dy * sn, p.y + dx * sn + dy * c end
      local ax, ay = pt(0, 0); local bx, by = pt(w, 0); local cx, cy = pt(w, h); local dx, dy = pt(0, h)
      D.poly({ ax, ay, bx, by, cx, cy, dx, dy }, 11)
      local ix, iy = pt(2, 2); local jx, jy = pt(w - 2, 2); local kx, ky = pt(w - 2, h - 7); local lx, ly = pt(2, h - 7)
      D.poly({ ix, iy, jx, jy, kx, ky, lx, ly }, 4)
      -- dentro, un ricordo minuscolo
      local mx, my = pt(w * 0.5, h * 0.45)
      if p.k == 1 then D.circle(mx, my - 2, 3, 9); D.line(mx - 8, my + 3, mx + 8, my + 3, 7)
      elseif p.k == 2 then D.rect(mx - 4, my - 2, 8, 6, 2); D.poly({ mx - 5, my - 2, mx + 5, my - 2, mx, my - 6 }, 2)
      elseif p.k == 3 then D.circle(mx - 2, my - 3, 1.6, 9); D.line(mx - 2, my - 1, mx - 2, my + 4, 9); D.circle(mx + 3, my - 1, 1.2, 9); D.line(mx + 3, my, mx + 3, my + 4, 9)
      else D.line(mx - 8, my + 2, mx + 8, my + 2, 9); D.circle(mx + 3, my - 3, 2, 12) end
    end
  end,
}

-------------------------------------------------------------------------------
-- una porta di luce
-------------------------------------------------------------------------------
P.porta = {
  init = function(s)
    s.fig = D.figura(20, 56, { s = 1.0, l = 1, dark = true, speed = 9 })
    s.fig:act({ { "walk", 60 }, { "pose", "arms_open", 4 } })
  end,
  update = function(s, dt)
    local o = s.fig.ph
    s.fig:update(dt)
    return s.fig.walking and floor(o / pi) ~= floor(s.fig.ph / pi)
  end,
  draw = function(s, t, k)
    D.rect(0, 0, 128, 64, 0)
    local w = 12 + k * 30
    local h = 40 + k * 20
    D.rect(66 - w / 2 - 6, 56 - h - 6, w + 12, h + 6, 3)
    D.rect(66 - w / 2, 56 - h, w, h, 13 + k * 2)
    D.poly({ 66 - w / 2, 56, 66 + w / 2, 56, 66 + w, 64, 66 - w, 64 }, 8)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- dal finestrino di un treno di notte
-------------------------------------------------------------------------------
P.finestrino = {
  init = function(s, dest, dir)
    s.off = 0
    s.dir = dir == "sx" and -1 or 1
    s.lights = {}
    for i = 1, 12 do s.lights[i] = { x = R(0, 160), y = R(30, 44), z = R(0.3, 1) } end
    s.h = D.ridge_gen(random(999), 36, 8, 0.8)
  end,
  update = function(s, dt)
    local o = s.off
    s.off = s.off + dt * 30 * s.dir
    return floor(o / 40) ~= floor(s.off / 40)
  end,
  draw = function(s, t, k)
    D.rect(0, 0, 128, 64, 0)
    D.ridge(s.h, 1, 50, s.off * 0.2)
    for _, L in ipairs(s.lights) do D.px((L.x - s.off * L.z) % 160 - 16, L.y, 6 + L.z * 7) end
    for i = 0, 6 do local x = (i * 30 - s.off * 1.5) % 210 - 30; D.line(x, 10, x, 50, 1) end
    -- la cornice del finestrino e il tuo riflesso
    D.rect(0, 0, 128, 8, 2); D.rect(0, 54, 128, 10, 2)
    D.rect(0, 0, 8, 64, 2); D.rect(120, 0, 8, 64, 2)
    D.circle(80, 30, 5, 1); D.poly({ 72, 54, 88, 54, 86, 38, 74, 38 }, 1)
  end,
}

-------------------------------------------------------------------------------
-- la scelta, sempre diversa dall'ultima
-------------------------------------------------------------------------------
local last = nil
function P.scegli(dir, from, dest)
  local pool
  local acqua = dest.terreno == "acqua"
  if dir == "segreto" then pool = { "porta", "foto" }
  elseif dir == "su" then
    pool = { "scale_su", "scale_su", "bosco", "foto" }
    if dest.strato >= 2 then pool[#pool + 1] = "nuvole"; pool[#pool + 1] = "nuvole" end
  elseif dir == "giu" then
    pool = { "scale_giu", "scale_giu", "corridoio", "foto" }
    if dest.strato <= -2 then pool[#pool + 1] = "caduta" end
    if acqua then pool[#pool + 1] = "acqua"; pool[#pool + 1] = "acqua" end
  else
    pool = { "campi", "corridoio", "foto" }
    if dest.strato >= 1 then pool[#pool + 1] = "bosco"; pool[#pool + 1] = "campi" end
    if dest.strato <= 0 then pool[#pool + 1] = "finestrino"; pool[#pool + 1] = "corridoio" end
    if acqua then pool[#pool + 1] = "acqua" end
  end
  local name
  for _ = 1, 6 do name = pool[random(#pool)]; if name ~= last then break end end
  last = name
  return name, P[name]
end

return P
