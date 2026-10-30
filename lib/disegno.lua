-- ANAMNESI · disegno
-- Gli attrezzi per dipingere su 128 x 64 pixel e 16 grigi:
-- cieli, crinali, alberi, pioggia, neve, fuoco, acqua, finestre
-- e una figura snodata che respira, cammina, si siede, si inginocchia.

-- un solo pennello per tutti: lo script e le scene condividono questo modulo
if _G.__anamnesi_disegno then return _G.__anamnesi_disegno end
local D = {}
_G.__anamnesi_disegno = D

local floor, sin, cos, rad, random, abs, min, max, sqrt, pi =
  math.floor, math.sin, math.cos, math.rad, math.random, math.abs, math.min, math.max, math.sqrt, math.pi

D.gain = 1      -- luminosità globale (dissolvenze)
D.veil = 0      -- velo del ricordo (allora)

-------------------------------------------------------------------------------
-- base
-------------------------------------------------------------------------------
function D.lv(l)
  local v = D.veil
  if v > 0 then l = l * (1 - 0.25 * v) end
  l = l * D.gain
  if l <= 0 then return 0 end
  -- una curva leggera: i neri restano neri, la luce resta luce
  l = 15 * (l / 15) ^ 1.15
  l = floor(l + 0.5)
  if l > 15 then l = 15 end
  return l
end
local lv = D.lv

function D.level(l) screen.level(lv(l)) end

function D.clamp(x, a, b) return x < a and a or (x > b and b or x) end
function D.lerp(a, b, t) return a + (b - a) * t end

-- generatore pseudo casuale con seme (per paesaggi sempre uguali)
function D.lcg(seed)
  local st = floor(seed) % 2147483647
  if st <= 0 then st = st + 2147483646 end
  return function(a, b)
    st = (st * 16807) % 2147483647
    local r = (st - 1) / 2147483646
    if a == nil then return r end
    if b == nil then return floor(r * a) + 1 end
    return a + r * (b - a)
  end
end

local function hash(n) return (sin(n * 127.1 + 311.7) * 43758.5453) % 1 end
function D.noise(x)
  local i = floor(x)
  local f = x - i
  local u = f * f * (3 - 2 * f)
  return hash(i) * (1 - u) + hash(i + 1) * u
end
local noise = D.noise

function D.rect(x, y, w, h, l)
  if w <= 0 or h <= 0 then return end
  screen.level(lv(l)); screen.rect(floor(x), floor(y), floor(w), floor(h)); screen.fill()
end

function D.px(x, y, l)
  screen.level(lv(l)); screen.pixel(floor(x), floor(y)); screen.fill()
end

-- più pixel dello stesso grigio in un colpo solo
function D.pixels(pts, l)
  if #pts == 0 then return end
  screen.level(lv(l))
  for i = 1, #pts, 2 do screen.pixel(floor(pts[i]), floor(pts[i + 1])) end
  screen.fill()
end

function D.line(x1, y1, x2, y2, l)
  screen.level(lv(l))
  screen.move(floor(x1) + 0.5, floor(y1) + 0.5)
  screen.line(floor(x2) + 0.5, floor(y2) + 0.5)
  screen.stroke()
end

-- segmento con spessore (braccia, gambe, rami)
function D.thick(x1, y1, x2, y2, w, l)
  if w < 1.3 then D.line(x1, y1, x2, y2, l); return end
  local dx, dy = x2 - x1, y2 - y1
  local len = sqrt(dx * dx + dy * dy)
  if len < 0.05 then D.circle(x1, y1, w / 2, l); return end
  local nx, ny = -dy / len * w / 2, dx / len * w / 2
  D.poly({ x1 + nx, y1 + ny, x2 + nx, y2 + ny, x2 - nx, y2 - ny, x1 - nx, y1 - ny }, l)
  D.circle(x2, y2, w / 2, l)
end

function D.poly(pts, l)
  screen.level(lv(l))
  screen.move(pts[1], pts[2])
  for i = 3, #pts, 2 do screen.line(pts[i], pts[i + 1]) end
  screen.close()
  screen.fill()
end

-- alone di luce: un solo anello piccolo e netto attorno alla fonte, niente retino
function D.glow(x, y, r, l, dens)
  local rr = min(r * 0.32, 5)
  if rr < 1.2 then return end
  D.circle(x, y, rr, l * 0.45)
  D.circle(x, y, rr * 0.5, l * 0.8)
end

D.tr = function(s) return s end

function D.circle(x, y, r, l, stroke)
  screen.level(lv(l))
  screen.circle(x, y, r)
  if stroke then screen.stroke() else screen.fill() end
end

-- cielo a fasce, dall'alto verso il basso
function D.gradient(y0, y1, l0, l1)
  local h = y1 - y0
  if h <= 0 then return end
  local last, start = nil, y0
  for y = y0, y1 do
    local l = lv(l0 + (l1 - l0) * ((y - y0) / h))
    if l ~= last then
      if last then screen.level(last); screen.rect(0, start, 128, y - start); screen.fill() end
      last, start = l, y
    end
  end
  screen.level(last); screen.rect(0, start, 128, y1 - start + 1); screen.fill()
end

-- retino (nebbia, polvere, luce che filtra)
function D.dither(x, y, w, h, l, dens, seed, t)
  screen.level(lv(l))
  local r = D.lcg(seed or 7)
  local n = floor(w * h * dens)
  local tt = t or 0
  for i = 1, n do
    local px = x + floor(r() * w + tt * (r() - 0.5) * 2) % w
    local py = y + floor(r() * h)
    screen.pixel(px, py)
  end
  screen.fill()
end

-------------------------------------------------------------------------------
-- terra e cielo
-------------------------------------------------------------------------------
function D.ridge_gen(seed, base, amp, rough)
  local r = D.lcg(seed)
  local ph = { r() * 9, r() * 9, r() * 9, r() * 9 }
  local h = {}
  rough = rough or 1
  for x = 0, 128 do
    local v = sin(x * 0.02 + ph[1]) * 0.55 + sin(x * 0.055 + ph[2]) * 0.3 * rough
      + sin(x * 0.13 + ph[3]) * 0.12 * rough + (noise(x * 0.4 + ph[4] * 10) - 0.5) * 0.12 * rough
    h[x] = base - amp * (v * 0.5 + 0.5)
  end
  return h
end

-- crinale pieno (può scorrere orizzontalmente: off)
function D.ridge(h, l, ybot, off)
  off = off or 0
  screen.level(lv(l))
  screen.move(0, ybot or 64)
  for x = 0, 128 do
    local xi = floor(x + off) % 129
    screen.line(x, h[xi])
  end
  screen.line(128, ybot or 64)
  screen.close()
  screen.fill()
end

function D.ridge_line(h, l, off)
  off = off or 0
  screen.level(lv(l))
  screen.move(0, h[floor(off) % 129])
  for x = 1, 128 do screen.line(x, h[floor(x + off) % 129]) end
  screen.stroke()
end

function D.stars_gen(n, seed, y0, y1)
  local r = D.lcg(seed)
  local s = {}
  for i = 1, n do
    s[i] = { x = r() * 128, y = y0 + r() * (y1 - y0), ph = r() * 6.28, sp = 0.5 + r() * 2.5, b = r() ^ 2.2, fl = 0 }
  end
  return s
end

function D.stars(s, t, base, dx, dy)
  base = base or 1
  local buckets = {}
  for _, st in ipairs(s) do
    local tw = 0.5 + 0.5 * sin(t * st.sp + st.ph)
    local l = floor((1 + st.b * 9 * (0.55 + 0.45 * tw) + st.fl * 10) * base)
    if st.fl > 0 then st.fl = max(0, st.fl - 0.04) end
    if l > 0 then
      l = min(15, l)
      local x = (st.x + (dx or 0)) % 128
      local y = st.y + (dy or 0)
      buckets[l] = buckets[l] or {}
      local b = buckets[l]
      b[#b + 1] = x; b[#b + 1] = y
      if st.b > 0.75 or st.fl > 0.3 then
        b[#b + 1] = x + 1; b[#b + 1] = y
        b[#b + 1] = x - 1; b[#b + 1] = y
        b[#b + 1] = x; b[#b + 1] = y + 1
        b[#b + 1] = x; b[#b + 1] = y - 1
      end
    end
  end
  for l, pts in pairs(buckets) do D.pixels(pts, l) end
end

function D.flare_star(s)
  local st = s[random(#s)]
  st.fl = 1
  return st
end

function D.moon(x, y, r, l, skyl, phase)
  D.circle(x, y, r + 3, max(0, (skyl or 0) + 1))
  D.circle(x, y, r, l)
  if phase and phase ~= 0 then D.circle(x + phase * r, y - r * 0.2, r, skyl or 0) end
  -- mari lunari
  D.px(x - r * 0.3, y - r * 0.2, l - 3); D.px(x + r * 0.2, y + r * 0.3, l - 3); D.px(x - 0.1 * r, y + 0.1 * r, l - 2)
end

function D.cloud(x, y, w, l, seed)
  local r = D.lcg(seed or floor(w * 7))
  screen.level(lv(l))
  for i = 1, floor(w / 4) + 2 do
    local cx = x + r() * w
    local cy = y + (r() - 0.6) * w * 0.12
    screen.circle(cx, cy, 1.5 + r() * w * 0.12)
    screen.fill()
  end
end

-------------------------------------------------------------------------------
-- alberi ed erba
-------------------------------------------------------------------------------
function D.pine(x, y, h, l, sway)
  sway = sway or 0
  local tiers = max(2, floor(h / 4))
  D.line(x, y, x, y - h * 0.25, l - 2)
  for i = 0, tiers - 1 do
    local f = i / tiers
    local w = h * 0.36 * (1 - f * 0.75)
    local ty = y - h * 0.18 - f * h * 0.8
    local sx = sway * f
    D.poly({ x - w + sx * 0.5, ty, x + w + sx * 0.5, ty, x + sx, ty - h * 0.32 }, l)
  end
end

local tree_cache = {}
function D.bare_tree(x, y, h, l, seed, sway)
  local key = seed .. ":" .. floor(h)
  local segs = tree_cache[key]
  if not segs then
    segs = {}
    local r = D.lcg(seed)
    local function br(x0, y0, ang, len, depth)
      local x1 = x0 + sin(ang) * len
      local y1 = y0 - cos(ang) * len
      segs[#segs + 1] = { x0, y0, x1, y1, depth }
      if depth < 4 and len > 1.5 then
        local n = (depth == 1 and r() < 0.4) and 3 or 2
        for i = 1, n do
          br(x1, y1, ang + (r() - 0.5) * 1.3, len * (0.62 + r() * 0.18), depth + 1)
        end
      end
    end
    br(0, 0, (r() - 0.5) * 0.15, h * 0.34, 0)
    tree_cache[key] = segs
  end
  sway = sway or 0
  for _, s in ipairs(segs) do
    local k = s[5] / 4
    D.line(x + s[1] + sway * (k ^ 2) * (s[1] ~= 0 and 1 or 0), y + s[2], x + s[3] + sway * ((s[5] + 1) / 4) ^ 2, y + s[4], l - s[5] * 0.6)
  end
end

function D.tree(x, y, h, l, seed, sway)
  local r = D.lcg(seed or 3)
  sway = sway or 0
  D.line(x, y, x + sway * 0.3, y - h * 0.5, l - 2)
  D.line(x + 1, y, x + 1 + sway * 0.3, y - h * 0.4, l - 4)
  for i = 1, 9 do
    local a = r() * pi * 2
    local d = r() * h * 0.25
    D.circle(x + cos(a) * d * 1.2 + sway, y - h * 0.62 + sin(a) * d * 0.7, h * (0.14 + r() * 0.12), l - r() * 2)
  end
end

function D.cypress(x, y, h, l, sway)
  sway = sway or 0
  D.poly({ x - h * 0.12, y, x + h * 0.12, y, x + h * 0.09 + sway * 0.5, y - h * 0.6, x + sway, y - h, x - h * 0.09 + sway * 0.5, y - h * 0.6 }, l)
end

function D.grass_gen(seed, n, x0, x1, hmin, hmax)
  local r = D.lcg(seed)
  local g = {}
  for i = 1, n do g[i] = { x = x0 + r() * (x1 - x0), h = hmin + r() * (hmax - hmin), ph = r() * 6.28, l = r() } end
  return g
end

function D.grass(g, y, t, l, wind)
  wind = wind or 1
  for _, b in ipairs(g) do
    local sw = (sin(t * 1.3 + b.ph + b.x * 0.05) * 0.8 + noise(t * 0.4 + b.x * 0.02) * 1.2) * wind
    D.line(b.x, y, b.x + sw * (b.h / 4), y - b.h, l - b.l * 3)
  end
end

-------------------------------------------------------------------------------
-- particelle
-------------------------------------------------------------------------------
function D.parts(n) return { list = {}, max = n } end

function D.spawn(ps, p)
  if #ps.list < ps.max then ps.list[#ps.list + 1] = p end
end

function D.parts_update(ps, dt, fn)
  local j = 1
  for i = 1, #ps.list do
    local p = ps.list[i]
    p.x = p.x + (p.vx or 0) * dt
    p.y = p.y + (p.vy or 0) * dt
    p.age = (p.age or 0) + dt
    if fn then fn(p, dt) end
    if not p.dead and p.age < (p.life or 99) then
      ps.list[j] = p; j = j + 1
    end
  end
  for i = j, #ps.list do ps.list[i] = nil end
end

-- pioggia: gocce oblique e schizzi
function D.rain_update(ps, dt, dens, ground, wind)
  for i = 1, floor(dens * 60 * dt + random()) do
    D.spawn(ps, { x = random() * 140 - 6, y = -random() * 8, vx = (wind or -8), vy = 90 + random() * 40, len = 2 + random() * 3, l = 4 + random() * 6 })
  end
  D.parts_update(ps, dt, function(p)
    if p.y > (ground or 64) - random() * 6 then
      p.dead = true
      if random() < 0.3 then D.spawn(ps, { x = p.x, y = p.y, vx = 0, vy = 0, life = 0.08, splash = true, l = p.l }) end
    end
  end)
end

function D.rain_draw(ps, lmul)
  lmul = lmul or 1
  for _, p in ipairs(ps.list) do
    if p.splash then
      D.px(p.x - 1, p.y, p.l * lmul); D.px(p.x + 1, p.y, p.l * lmul)
    else
      D.line(p.x, p.y, p.x + p.vx * 0.02, p.y - p.len, p.l * lmul)
    end
  end
end

function D.snow_update(ps, dt, dens, ground, wind, t)
  for i = 1, floor(dens * 25 * dt + random()) do
    D.spawn(ps, { x = random() * 140 - 6, y = -2, vx = (wind or 0), vy = 6 + random() * 8, ph = random() * 6, s = random() })
  end
  D.parts_update(ps, dt, function(p, d)
    p.x = p.x + sin(t * 1.5 + p.ph) * 4 * d
    if p.y > (ground or 64) then p.dead = true end
  end)
end

function D.snow_draw(ps, l)
  local a, b = {}, {}
  for _, p in ipairs(ps.list) do
    if p.s > 0.7 then
      b[#b + 1] = p.x; b[#b + 1] = p.y; b[#b + 1] = p.x + 1; b[#b + 1] = p.y
      b[#b + 1] = p.x; b[#b + 1] = p.y + 1; b[#b + 1] = p.x + 1; b[#b + 1] = p.y + 1
    else
      a[#a + 1] = p.x; a[#a + 1] = p.y
    end
  end
  D.pixels(a, (l or 13) - 4)
  D.pixels(b, l or 13)
end

-- lucciole, polvere nella luce, scintille
function D.motes_update(ps, dt, dens, box, t)
  for i = 1, floor(dens * dt * 10 + random()) do
    D.spawn(ps, { x = box[1] + random() * box[3], y = box[2] + random() * box[4], vx = (random() - 0.5) * 3, vy = (random() - 0.5) * 2, life = 3 + random() * 5, ph = random() * 6 })
  end
  D.parts_update(ps, dt, function(p, d)
    p.vx = p.vx + (noise(t * 0.5 + p.ph * 7) - 0.5) * 6 * d
    p.vy = p.vy + (noise(t * 0.5 + p.ph * 3 + 50) - 0.5) * 6 * d
  end)
end

function D.motes_draw(ps, l)
  for _, p in ipairs(ps.list) do
    local life = p.life or 4
    local f = min(1, p.age / 0.8, (life - p.age) / 0.8)
    if f > 0 then D.px(p.x, p.y, l * f) end
  end
end

-------------------------------------------------------------------------------
-- fuoco, candele, fumo
-------------------------------------------------------------------------------
function D.fire(x, y, w, h, t, l)
  l = l or 15
  -- bagliore
  D.circle(x, y - h * 0.3, w * 1.4 + sin(t * 9) * 0.5, 2)
  D.circle(x, y - h * 0.3, w * 0.9, 3)
  local n = max(3, floor(w))
  for i = 0, n - 1 do
    local fx = x - w / 2 + (i + 0.5) * (w / n)
    local fh = h * (0.45 + 0.55 * noise(t * 6 + i * 3.1)) * (1 - abs(i - (n - 1) / 2) / n)
    local sw = (noise(t * 4 + i * 7) - 0.5) * 2.5
    D.poly({ fx - w / n * 0.7, y, fx + w / n * 0.7, y, fx + sw, y - fh }, l - 5 + noise(t * 8 + i) * 3)
    D.poly({ fx - w / n * 0.35, y, fx + w / n * 0.35, y, fx + sw * 0.6, y - fh * 0.6 }, l)
  end
  -- braci
  D.rect(x - w / 2, y, w, 1, 6)
  for i = 1, 3 do
    if random() < 0.5 then D.px(x - w / 2 + random() * w, y, 9 + random() * 6) end
  end
end

function D.candle(x, y, t, l, h, halo)
  h = h or 3
  D.rect(x - 1, y - h, 2, h, l or 7)
  local f = noise(t * 7 + x)
  if halo ~= false then D.glow(x, y - h - 2, 4 + f, halo or 4) end
  D.px(x, y - h - 1, 15)
  D.px(x + (f > 0.6 and 1 or 0), y - h - 2, 10 + f * 5)
  if f > 0.3 then D.px(x, y - h - 3, 6 + f * 4) end
end

function D.smoke_update(ps, dt, x, y, rate, t, wind)
  if random() < rate * dt then
    D.spawn(ps, { x = x, y = y, vx = 0, vy = -4 - random() * 3, life = 6 + random() * 4, ph = random() * 6 })
  end
  D.parts_update(ps, dt, function(p, d)
    p.vx = (wind or 1.5) + (noise(t * 0.7 + p.ph * 5) - 0.5) * 3
  end)
end

-- fumo e vapore: piccole nubi di punti che si allargano e svaniscono
function D.smoke_draw(ps, l)
  for _, p in ipairs(ps.list) do
    local f = 1 - p.age / p.life
    local r = 0.5 + p.age * 0.45
    if r < 1.2 then
      D.px(p.x, p.y, l * f)
    else
      local a = p.ph + p.age * 0.7
      local pts = {}
      for k = 0, 3 do
        local ang = a + k * 1.7
        pts[#pts + 1] = p.x + cos(ang) * r * (0.5 + 0.5 * ((k * 0.37) % 1))
        pts[#pts + 1] = p.y + sin(ang) * r * 0.7
      end
      D.pixels(pts, l * f * 0.8)
    end
  end
end

-------------------------------------------------------------------------------
-- acqua
-------------------------------------------------------------------------------
function D.waves(y0, y1, t, l, speed, seed)
  local r = D.lcg(seed or 5)
  local rows = {}
  local y = y0
  local gap = 1.5
  while y < y1 do rows[#rows + 1] = y; y = y + gap; gap = gap * 1.25 end
  for i, wy in ipairs(rows) do
    local d = i / #rows
    local segs = 3 + floor(d * 6)
    for k = 1, segs do
      local ph = r() * 200
      local x = ((ph + t * (speed or 6) * (0.3 + d)) % 150) - 10
      local w = 3 + d * 10 * r()
      D.line(x, wy + sin(t + ph) * d, x + w, wy + sin(t + ph) * d, l * (0.35 + d * 0.65))
    end
  end
end

-- riflesso tremolante di una luce sull'acqua
function D.reflection(x, y0, y1, w, t, l)
  for y = y0, y1, 2 do
    local d = (y - y0) / max(1, y1 - y0)
    local ww = w * (0.4 + d) * (0.6 + 0.4 * noise(t * 2 + y))
    local ox = (noise(t * 1.3 + y * 0.3) - 0.5) * 4 * d
    D.line(x - ww / 2 + ox, y, x + ww / 2 + ox, y, l * (1 - d * 0.6))
  end
end

function D.ripple(x, y, r, l)
  if r <= 0 then return end
  screen.level(lv(l))
  screen.move(x - r, y)
  for i = 1, 16 do
    local a = i / 16 * pi * 2
    screen.line(x - cos(a) * r, y + sin(a) * r * 0.3)
  end
  screen.stroke()
end

-------------------------------------------------------------------------------
-- architettura
-------------------------------------------------------------------------------
function D.window(x, y, w, h, frame, lit, cross)
  if lit then D.rect(x, y, w, h, lit) end
  screen.level(lv(frame))
  screen.rect(x + 0.5, y + 0.5, w - 1, h - 1)
  screen.stroke()
  if cross ~= false then
    D.line(x + floor(w / 2), y, x + floor(w / 2), y + h - 1, frame)
    D.line(x, y + floor(h / 2), x + w - 1, y + floor(h / 2), frame)
  end
end

function D.house(x, y, w, h, l, roof)
  D.rect(x, y - h, w, h, l)
  roof = roof or 4
  D.poly({ x - 1, y - h, x + w + 1, y - h, x + w / 2, y - h - roof }, l + 1)
end

function D.cross(x, y, h, l)
  D.rect(x, y - h, 1, h, l)
  D.rect(x - floor(h / 4), y - h + floor(h / 4), floor(h / 2) + 1, 1, l)
end

-- pavimento in prospettiva
function D.floor_persp(y0, y1, vx, l, step)
  step = step or 12
  for x = -128, 256, step do D.line(vx + (x - vx) * 0.25, y0, x, y1, l) end
  local y, g = y0, 1
  while y < y1 do D.line(0, y, 127, y, l); y = y + g; g = g * 1.5 end
end

-------------------------------------------------------------------------------
-- testo che sale e svanisce (parole)
-------------------------------------------------------------------------------
function D.float_words_update(ps, dt)
  D.parts_update(ps, dt)
end

function D.float_words_draw(ps)
  screen.font_face(1); screen.font_size(8)
  for _, p in ipairs(ps.list) do
    local f = min(1, p.age / 1, (p.life - p.age) / 1.5)
    if f > 0 then
      screen.level(lv((p.l or 10) * f))
      screen.level(0); screen.move(floor(p.x) + 1, floor(p.y) + 1); screen.text(D.tr(p.w))
      screen.level(lv((p.l or 10) * f))
      screen.move(floor(p.x), floor(p.y))
      screen.text(D.tr(p.w))
    end
  end
end

-------------------------------------------------------------------------------
-- LA FIGURA
-- uno scheletro di 13 punti, con cappotto, che respira.
-- angoli in gradi: 0 = giù, 90 = avanti (gambe e braccia);
-- lean: 0 = busto dritto, + = in avanti; rot: tutto il corpo ruotato.
-------------------------------------------------------------------------------
local POSE = {
  stand     = { lean = 0,   nod = 0,   ua1 = 6,   ua2 = -4,  fa1 = 3,   fa2 = -5,  th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.2, rot = 0 },
  look_up   = { lean = -8,  nod = -38, ua1 = 4,   ua2 = -3,  fa1 = 2,   fa2 = -4,  th1 = 4,   th2 = -3,  sh1 = 1,   sh2 = -2,  hy = 7.2, rot = 0 },
  head_down = { lean = 8,   nod = 32,  ua1 = 6,   ua2 = 2,   fa1 = 10,  fa2 = 6,   th1 = 2,   th2 = -2,  sh1 = 0,   sh2 = -1,  hy = 7.1, rot = 0 },
  sit_ground= { lean = 22,  nod = 14,  ua1 = 55,  ua2 = 50,  fa1 = 100, fa2 = 96,  th1 = 118, th2 = 112, sh1 = 0,   sh2 = -6,  hy = 1.7, rot = 0 },
  sit_think = { lean = 12,  nod = 22,  ua1 = 40,  ua2 = 60,  fa1 = 150, fa2 = 95,  th1 = 105, th2 = 98,  sh1 = 10,  sh2 = 4,   hy = 1.7, rot = 0 },
  sit       = { lean = 4,   nod = 8,   ua1 = 22,  ua2 = 16,  fa1 = 72,  fa2 = 66,  th1 = 90,  th2 = 87,  sh1 = 4,   sh2 = 0,   hy = 4.6, rot = 0 },
  sit_read  = { lean = 10,  nod = 30,  ua1 = 30,  ua2 = 26,  fa1 = 115, fa2 = 110, th1 = 90,  th2 = 87,  sh1 = 4,   sh2 = 0,   hy = 4.6, rot = 0 },
  sit_slump = { lean = 30,  nod = 40,  ua1 = 35,  ua2 = 30,  fa1 = 150, fa2 = 140, th1 = 88,  th2 = 84,  sh1 = 0,   sh2 = -4,  hy = 4.6, rot = 0 },
  kneel     = { lean = 6,   nod = 18,  ua1 = 14,  ua2 = 10,  fa1 = 40,  fa2 = 30,  th1 = 4,   th2 = 0,   sh1 = -88, sh2 = -86, hy = 3.6, rot = 0 },
  kneel_one = { lean = 18,  nod = 26,  ua1 = 60,  ua2 = 12,  fa1 = 85,  fa2 = 8,   th1 = 86,  th2 = 2,   sh1 = 0,   sh2 = -88, hy = 3.7, rot = 0 },
  pray      = { lean = 10,  nod = 28,  ua1 = 25,  ua2 = 22,  fa1 = 125, fa2 = 122, th1 = 4,   th2 = 0,   sh1 = -88, sh2 = -86, hy = 3.6, rot = 0 },
  lie       = { lean = 0,   nod = -8,  ua1 = 8,   ua2 = 4,   fa1 = 6,   fa2 = 2,   th1 = 2,   th2 = -2,  sh1 = 2,   sh2 = -2,  hy = 1.0, rot = 90 },
  lie_face  = { lean = 0,   nod = 10,  ua1 = 160, ua2 = 10,  fa1 = 175, fa2 = 4,   th1 = 0,   th2 = -6,  sh1 = -8,  sh2 = -12, hy = 1.0, rot = -90 },
  curl      = { lean = 35,  nod = 30,  ua1 = 70,  ua2 = 64,  fa1 = 130, fa2 = 120, th1 = 75,  th2 = 66,  sh1 = -25, sh2 = -32, hy = 1.4, rot = 90 },
  cry       = { lean = 32,  nod = 42,  ua1 = 32,  ua2 = 26,  fa1 = 152, fa2 = 140, th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.0, rot = 0 },
  reach_up  = { lean = -6,  nod = -28, ua1 = 150, ua2 = 8,   fa1 = 166, fa2 = 2,   th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.3, rot = 0 },
  arms_open = { lean = -10, nod = -30, ua1 = 115, ua2 = -95, fa1 = 125, fa2 = -110,th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.3, rot = 0 },
  carry     = { lean = 3,   nod = 10,  ua1 = 22,  ua2 = 18,  fa1 = 82,  fa2 = 78,  th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.2, rot = 0 },
  bend      = { lean = 55,  nod = 20,  ua1 = 60,  ua2 = 40,  fa1 = 50,  fa2 = 35,  th1 = 8,   th2 = -6,  sh1 = 0,   sh2 = -2,  hy = 6.9, rot = 0 },
  window    = { lean = 2,   nod = -6,  ua1 = 60,  ua2 = -4,  fa1 = 120, fa2 = -5,  th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.2, rot = 0 },
  float     = { lean = -4,  nod = -15, ua1 = 60,  ua2 = -50, fa1 = 80,  fa2 = -60, th1 = 18,  th2 = -10, sh1 = -6,  sh2 = -24, hy = 7.0, rot = 0 },
  hug       = { lean = 6,   nod = 20,  ua1 = 70,  ua2 = 64,  fa1 = 150, fa2 = 145, th1 = 3,   th2 = -3,  sh1 = 0,   sh2 = -1,  hy = 7.1, rot = 0 },
  swing     = { lean = -6,  nod = -10, ua1 = 150, ua2 = 148, fa1 = 175, fa2 = 172, th1 = 80,  th2 = 76,  sh1 = 20,  sh2 = 10,  hy = 4.6, rot = 0 },
  dig       = { lean = 40,  nod = 30,  ua1 = 70,  ua2 = 55,  fa1 = 40,  fa2 = 30,  th1 = 4,   th2 = 0,   sh1 = -88, sh2 = -86, hy = 3.6, rot = 0 },
  talk      = { lean = 2,   nod = 4,   ua1 = 35,  ua2 = 18,  fa1 = 95,  fa2 = 66,  th1 = 90,  th2 = 87,  sh1 = 4,   sh2 = 0,   hy = 4.6, rot = 0 },
}
D.POSE = POSE
local KEYS = { "lean", "nod", "ua1", "ua2", "fa1", "fa2", "th1", "th2", "sh1", "sh2", "hy", "rot" }

local Fig = {}
Fig.__index = Fig

function D.figura(x, y, o)
  o = o or {}
  local f = setmetatable({
    x = x, y = y, s = o.s or 0.8, l = o.l or 12, face = o.face or 1,
    q = {}, cur = {}, tgt = POSE[o.pose or "stand"], walking = false, ph = 0, t = random() * 10,
    coat = o.coat ~= false, dress = o.dress, child = o.child, bun = o.bun,
    bent = o.bent or 0, shake = 0, speed = o.speed or 7, flap = 0, idle = true,
    hand = { x, y }, prop = o.prop, on_step = o.on_step, dark = o.dark,
  }, Fig)
  for _, k in ipairs(KEYS) do f.cur[k] = f.tgt[k] end
  return f
end

function Fig:act(list)
  for _, a in ipairs(list) do self.q[#self.q + 1] = a end
  self.idle = false
end

function Fig:clear() self.q = {}; self.walking = false end

function Fig:set(pose) self.tgt = POSE[pose] or POSE.stand end

local function walkpose(ph, bent)
  local s1, c1 = sin(ph), cos(ph)
  local p = {}
  p.th1 = 24 * s1; p.th2 = -24 * s1
  p.sh1 = p.th1 - 24 * max(0, -c1)
  p.sh2 = p.th2 - 24 * max(0, c1)
  p.ua1 = -16 * s1 + 4 + bent * 0.5; p.ua2 = 16 * s1 + 4 + bent * 0.5
  p.fa1 = p.ua1 + 14 + bent * 0.6; p.fa2 = p.ua2 + 14 + bent * 0.6
  p.lean = 4 + bent; p.nod = 2 + bent * 0.4
  p.hy = 7.0 - 0.35 * abs(c1) - bent * 0.02
  p.rot = 0
  return p
end

function Fig:update(dt)
  self.t = self.t + dt
  local a = self.q[1]
  if a then
    local kind = a[1]
    if kind == "walk" then
      local tx = a[2]
      local dx = tx - self.x
      if abs(dx) < 0.5 then
        self.x = tx; self.walking = false; table.remove(self.q, 1)
      else
        self.face = dx > 0 and 1 or -1
        self.walking = true
        local sp = (a[3] or self.speed) * self.s
        local mv = min(abs(dx), sp * dt)
        self.x = self.x + mv * self.face
        if a[4] then self.y = self.y + (a[4] - self.y) * min(1, mv / max(0.5, abs(dx))) end
        local old = self.ph
        self.ph = self.ph + dt * (sp / self.s) * 0.75
        if self.on_step and floor(old / pi) ~= floor(self.ph / pi) then self.on_step(self) end
      end
    elseif kind == "pose" then
      if not a.started then
        a.started = true; a.left = a[3] or 1
        self.tgt = POSE[a[2]] or POSE.stand
        self.walking = false
      end
      a.left = a.left - dt
      if a.left <= 0 then table.remove(self.q, 1) end
    elseif kind == "wait" then
      a.left = (a.left or a[2]) - dt
      if a.left <= 0 then table.remove(self.q, 1) end
    elseif kind == "fn" then
      table.remove(self.q, 1)
      a[2](self)
    elseif kind == "face" then
      self.face = a[2]; table.remove(self.q, 1)
    elseif kind == "glide" then
      -- spostamento senza passi (galleggiare, scivolare)
      if not a.started then a.started = true; a.x0 = self.x; a.y0 = self.y; a.k = 0 end
      a.k = min(1, a.k + dt / a[4])
      local e = a.k * a.k * (3 - 2 * a.k)
      self.x = a.x0 + (a[2] - a.x0) * e
      self.y = a.y0 + (a[3] - a.y0) * e
      if a.k >= 1 then table.remove(self.q, 1) end
    else
      table.remove(self.q, 1)
    end
  end
  self.idle = #self.q == 0
  local tgt, rate = self.tgt, 2.6
  if self.walking then tgt = walkpose(self.ph, self.bent); rate = 14 end
  local k = min(1, dt * rate)
  for _, key in ipairs(KEYS) do
    self.cur[key] = self.cur[key] + (tgt[key] - self.cur[key]) * k
  end
end

function Fig:draw()
  local c, s, fc = self.cur, self.s, self.face
  local l = self.l
  local br = sin(self.t * 1.4) * 1.3
  local sh = self.shake > 0 and sin(self.t * 23) * self.shake * 3 or 0
  local hx, hy = self.x, self.y - c.hy * s
  local rr = rad(c.rot) * fc
  local cr, sr = cos(rr), sin(rr)
  local function P(dx, dy)
    return hx + dx * cr - dy * sr, hy + dx * sr + dy * cr
  end
  local function dir(ang, len) local a = rad(ang); return sin(a) * len * s * fc, cos(a) * len * s end
  local lean = c.lean + br * 0.6 + sh
  local la = rad(lean)
  local ux, uy = sin(la) * fc, -cos(la)          -- direzione del busto (su)
  local px_, py_ = -uy, ux                        -- perpendicolare
  if fc < 0 then px_, py_ = uy, -ux end
  local tl = (self.child and 3.6 or 5) * s
  local sx, sy = ux * tl, uy * tl                 -- spalla
  local headr = (self.child and 1.55 or 1.65) * s
  local na = rad(lean + c.nod * 0.7)
  local nx, ny = sx + ux * 0.9 * s, sy + uy * 0.9 * s
  local hcx, hcy = nx + sin(na) * fc * headr, ny - cos(na) * headr

  local lw, aw = 1.15 * s, 0.95 * s          -- spessore di gambe e braccia
  local function seg(x1, y1, x2, y2, lvl, w)
    local a1, b1 = P(x1, y1)
    local a2, b2 = P(x2, y2)
    D.thick(a1, b1, a2, b2, w or 1, lvl)
  end
  local function leg(i, lvl)
    local kx, ky = dir(c["th" .. i], 3.6)
    local fx, fy = dir(c["sh" .. i], 3.6)
    seg(0, 0, kx, ky, lvl, lw * 1.1)
    seg(kx, ky, kx + fx, ky + fy, lvl, lw)
    seg(kx + fx, ky + fy, kx + fx + fc * s * 1.3, ky + fy, lvl - 1, lw * 0.9)
  end
  local function arm(i, lvl)
    local swing = (i == 1 and 1 or -1) * sh * 2
    local ex, ey = dir(c["ua" .. i] + swing + br * 0.5, 3.0)
    local wx, wy = dir(c["fa" .. i] + swing, 2.8)
    seg(sx, sy, sx + ex, sy + ey, lvl, aw * 1.1)
    seg(sx + ex, sy + ey, sx + ex + wx, sy + ey + wy, lvl, aw)
    local hx2, hy2 = P(sx + ex + wx, sy + ey + wy)
    if s >= 1.2 then D.circle(hx2, hy2, 0.55 * s, lvl + (self.dark and -1 or 1)) end
    if i == 1 then self.hand = { hx2, hy2 } end
  end

  local far = l - (self.dark and -2 or 4)
  leg(2, far)
  arm(2, far)
  -- busto / cappotto
  local hw, sw = 1.35 * s, 1.2 * s
  local hem = self.coat and (self.dress and 3.6 or 2.3) * s or 0.3 * s
  local hwf = self.coat and (self.dress and 2.6 or 1.9) * s or hw
  local flap = self.flap * sin(self.t * 7) * s
  local p1x, p1y = P(sx + px_ * sw, sy + py_ * sw)
  local p2x, p2y = P(sx - px_ * sw, sy - py_ * sw)
  local p3x, p3y = P(-ux * hem - px_ * hwf - flap, -uy * hem - py_ * hwf)
  local p4x, p4y = P(-ux * hem + px_ * hwf - flap * 1.5, -uy * hem + py_ * hwf)
  D.poly({ p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y }, l - 1)
  -- spalle tonde
  if s >= 1.1 then local qx, qy = P(sx, sy); D.circle(qx, qy, sw * 0.95, l - 1) end
  leg(1, l)
  arm(1, l)
  -- collo e testa
  local nwx, nwy = P(nx, ny)
  local hxw, hyw = P(hcx, hcy)
  if s >= 1.1 then D.thick(nwx, nwy, hxw, hyw, 0.9 * s, l) end
  D.circle(hxw, hyw, headr, l)
  if self.bun then
    D.circle(hxw - fc * headr * 0.9, hyw - headr * 0.3, headr * 0.55, l - 2)
  elseif not self.child and self.hair ~= false and s >= 0.9 then
    -- i capelli: una calotta più scura sulla nuca
    local hl = self.dark and l + 1 or l - 3
    D.circle(hxw - fc * headr * 0.3, hyw - headr * 0.35, headr * 0.78, hl)
    D.circle(hxw + fc * headr * 0.25, hyw + headr * 0.15, headr * 0.72, l)
  end
  if self.prop then self.prop(self.hand[1], self.hand[2], self) end
end

return D
