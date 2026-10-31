-- ANAMNESI · il kit di scena
-- Stanze, arredi, finestre, cieli e terreni, tutti nella stessa scala:
-- negli interni un metro è 14 pixel, una persona è alta circa 25.

if _G.__anamnesi_kit then return _G.__anamnesi_kit end
local D = include("lib/disegno")
local K = {}
_G.__anamnesi_kit = K

local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi

K.U = 14          -- pixel per metro negli interni
K.S = 1.45        -- scala della figura negli interni
local U = K.U
local function m(v) return v * U end

-------------------------------------------------------------------------------
-- STANZA
-- o.wall: grigio del muro · o.fy: dove comincia il pavimento · o.floor: tipo
-- o.paper: carta da parati · o.ceil: altezza della linea del soffitto
-------------------------------------------------------------------------------
function K.room(o, t)
  local fy = o.fy or 58
  local w = o.wall or 3
  D.rect(0, 0, 128, fy, w)
  local ceil = o.ceil or 6
  if ceil > 0 then
    D.rect(0, 0, 128, ceil, w - 1)
    D.line(0, ceil, 127, ceil, w + 1)
  end
  -- luci sul muro (lampade, finestre)
  for _, L in ipairs(o.lights or {}) do
    local fl = L.flicker and (D.noise(t * 5 + L.x) * L.flicker) or 0
    D.glow(L.x, L.y, L.r, w + 1 + (L.l or 2) + fl)
  end
  local p = o.paper
  -- la carta da parati è un'ombra appena, non una trama che accende il muro
  local pl = math.min(w + 1, 3)
  if p == "righe" then
    for x = 3, 127, 6 do D.line(x, ceil + 1, x, fy - 3, pl) end
  elseif p == "puntini" then
    for y = ceil + 3, fy - 4, 5 do for x = (y % 10 < 5) and 2 or 5, 127, 6 do D.px(x, y, pl) end end
  elseif p == "fiori" then
    for y = ceil + 4, fy - 5, 7 do
      for x = (y % 14 < 7) and 3 or 7, 127, 8 do D.px(x, y, pl); D.px(x - 1, y + 1, pl); D.px(x + 1, y + 1, pl); D.px(x, y + 2, pl) end
    end
  elseif p == "assi" then
    for y = ceil + 4, fy - 2, 5 do D.line(0, y, 127, y, math.min(w - 1, 2.5)) end
    for i = 0, 18 do D.px((i * 37) % 128, ceil + 2 + (i * 5) % (fy - ceil - 4), pl) end
  elseif p == "piastrelle" then
    local ty = o.tile_y or (fy - 22)
    D.rect(0, ty, 128, fy - ty, pl)
    for x = 0, 127, 6 do D.line(x, ty, x, fy - 1, pl - 0.5) end
    for y = ty, fy - 1, 5 do D.line(0, y, 127, y, pl - 0.5) end
  end
  -- battiscopa
  D.rect(0, fy - 2, 128, 2, w + 1)
  K.floor(fy, o.floor or "assi", o.floor_l or (w - 1), o.vx or 64)
end

function K.floor(fy, kind, l, vx)
  D.rect(0, fy, 128, 64 - fy, l)
  vx = vx or 64
  if kind == "assi" then
    for x = -60, 190, 9 do D.line(vx + (x - vx) * 0.55, fy, x, 63, l - 1) end
    for y = fy + 3, 63, 4 do D.line(0, y, 127, y, l - 1 + (y - fy) * 0.05) end
  elseif kind == "piastrelle" or kind == "scacchi" then
    local rows = { fy, fy + 2, fy + 5, fy + 9 }
    for i = 1, #rows - 1 do
      local y0, y1 = rows[i], min(64, rows[i + 1])
      local wv = 6 + i * 3
      for x = -wv, 128, wv do
        if kind == "scacchi" and ((x / wv + i) % 2 == 0) then D.rect(x, y0, wv, y1 - y0, l + 2) end
        D.line(x, y0, x, y1, l - 1)
      end
      D.line(0, y0, 127, y0, l - 1)
    end
  elseif kind == "moquette" then
    for i = 0, 60 do D.px((i * 23) % 128, fy + 1 + (i * 7) % max(1, 63 - fy), l + 1) end
  elseif kind == "pietra" then
    for y = fy + 2, 63, 3 do
      for x = (y % 6 == 0) and 0 or 4, 127, 8 do D.line(x, y, x + 5, y, l - 1) end
    end
  elseif kind == "marmo" then
    for x = -60, 190, 16 do D.line(vx + (x - vx) * 0.4, fy, x, 63, l + 1) end
    local y, g = fy + 1, 1.5
    while y < 64 do D.line(0, y, 127, y, l + 1); y = y + g; g = g * 1.5 end
  end
end

-- pavimento luminoso sotto una finestra o una lampada
function K.pool(x, fy, w, l)
  D.poly({ x - w * 0.4, fy, x + w * 0.4, fy, x + w * 0.7, 63, x - w * 0.7, 63 }, l)
end

-------------------------------------------------------------------------------
-- FINESTRE con il mondo fuori
-------------------------------------------------------------------------------
K.views = {}

function K.views.night(x, y, w, h, t, st)
  D.rect(x, y, w, h, 1)
  st.stars = st.stars or D.stars_gen(floor(w * h / 18), floor(x * 7 + y), 0, h)
  for _, s in ipairs(st.stars) do
    local tw = 0.5 + 0.5 * sin(t * s.sp + s.ph)
    if s.x < w then D.px(x + s.x % w, y + s.y, 3 + s.b * 8 * tw) end
  end
  if st.moon then D.moon(x + w * 0.7, y + h * 0.3, 2, 13, 1, 0.5) end
  if st.hills ~= false then
    for i = 0, w - 1 do
      local hh = h * 0.18 + sin((x + i) * 0.15) * 1.5 + sin((x + i) * 0.05) * 2
      D.rect(x + i, y + h - hh, 1, hh, 2)
    end
  end
end

function K.views.day(x, y, w, h, t, st)
  for i = 0, h - 1 do D.rect(x, y + i, w, 1, 10 + i / h * 2) end
  local cx = x + ((t * 1.2 + (st.cloud or 0)) % (w + 16)) - 8
  if cx > x + 2 and cx < x + w - 6 then D.rect(cx, y + h * 0.25, 6, 2, 13); D.rect(cx + 1, y + h * 0.25 - 1, 3, 1, 13) end
  for i = 0, w - 1 do
    local hh = h * 0.22 + sin((x + i) * 0.12) * 1.5
    D.rect(x + i, y + h - hh, 1, hh, 7)
  end
end

function K.views.rain(x, y, w, h, t, st)
  D.rect(x, y, w, h, 4)
  st.drops = st.drops or {}
  for i = 1, floor(w * h / 25) do
    local px = x + (i * 37 + floor(t * 40) * (i % 3 + 1)) % w
    local py = y + (i * 53 + floor(t * 90 * (1 + i % 2))) % h
    D.px(px, py, 7)
    if py + 1 < y + h then D.px(px, py + 1, 6) end
  end
  for i = 0, w - 1 do D.rect(x + i, y + h - 3, 1, 3, 3) end
end

function K.views.snow(x, y, w, h, t, st)
  D.rect(x, y, w, h, 2)
  for i = 1, floor(w * h / 20) do
    local px = x + (i * 37 + sin(t + i) * 2 + t * 2) % w
    local py = y + (i * 53 + t * 8 * (1 + (i % 3) * 0.3)) % h
    D.px(px, py, 11)
  end
  for i = 0, w - 1 do D.rect(x + i, y + h - 3, 1, 3, 10) end
end

function K.window(x, y, w, h, view, t, st, frame)
  local f = frame or 6
  if view then view(x, y, w, h, t, st or {}) end
  screen.level(D.lv(f)); screen.rect(x - 0.5, y - 0.5, w + 1, h + 1); screen.stroke()
  D.line(x + floor(w / 2), y, x + floor(w / 2), y + h - 1, f)
  D.line(x, y + floor(h / 2), x + w - 1, y + floor(h / 2), f)
  D.rect(x - 2, y + h, w + 4, 2, f)
end

-------------------------------------------------------------------------------
-- ARREDI (x = sinistra, fy = pavimento)
-------------------------------------------------------------------------------
function K.piano(x, fy, l, keys)
  local w, h = m(1.45), m(1.25)
  local top = fy - h
  D.rect(x, top, w, h - 2, l)
  D.rect(x, top, w, 2, l + 2)
  D.rect(x + 2, top + 4, w - 4, 6, l + 1)
  local kb = fy - m(0.72)
  D.rect(x - 1, kb - 1, w + 2, 3, l + 1)
  D.rect(x + 1, kb - 1, w - 2, 2, 11)
  local n = floor((w - 2) / 2)
  for k = 0, n - 1 do
    local kx = x + 1 + k * 2
    if keys and keys[k] then D.rect(kx, kb - 1, 2, 2, 15) end
    D.px(kx, kb - 1, 6)
    if k % 7 ~= 2 and k % 7 ~= 6 then D.px(kx + 1, kb - 1, 1) end
  end
  D.rect(x + 2, kb + 2, 2, fy - kb - 2, l - 1); D.rect(x + w - 4, kb + 2, 2, fy - kb - 2, l - 1)
  D.rect(x + 3, top - 3, 4, 3, l + 3)   -- una foto sopra
  return x + w / 2, kb, n
end

function K.table(x, fy, wm, l, cloth)
  local w = m(wm or 1.4)
  local ty = fy - m(0.76)
  D.rect(x, ty, w, 2, l + 1)
  if cloth then D.rect(x - 1, ty + 2, w + 2, 3, cloth); for i = x, x + w, 3 do D.px(i, ty + 4, cloth - 2) end end
  D.rect(x + 1, ty + 2, 2, fy - ty - 2, l - 1); D.rect(x + w - 3, ty + 2, 2, fy - ty - 2, l - 1)
  return ty
end

function K.chair(x, fy, face, l)
  local sy = fy - m(0.45)
  D.rect(x - 4, sy, 9, 2, l)
  D.line(x - 3, sy + 2, x - 3, fy - 1, l - 1); D.line(x + 3, sy + 2, x + 3, fy - 1, l - 1)
  local bx = face > 0 and x - 4 or x + 4
  D.rect(bx, fy - m(0.95), 1, m(0.5), l)
  D.rect(bx - 1, fy - m(0.95), 3, 1, l + 1)
  return sy
end

function K.armchair(x, fy, face, l)
  local sy = fy - m(0.42)
  D.rect(x - 7, sy, 15, fy - sy, l)
  local bx = face > 0 and x - 9 or x + 5
  D.rect(bx, fy - m(0.95), 5, m(0.95), l + 1)
  D.rect(x - 9, sy - 3, 4, fy - sy + 3, l + 1); D.rect(x + 6, sy - 3, 4, fy - sy + 3, l + 1)
  D.line(x - 7, sy, x + 6, sy, l + 2)
  return sy
end

function K.bed(x, fy, wm, l, blanket, head_right)
  local w = m(wm or 2)
  local by = fy - m(0.5)
  D.rect(x, by, w, fy - by, l)
  if blanket then D.rect(x + 3, by - 2, w - 6, 4, blanket) ; D.line(x + 3, by - 2, x + w - 4, by - 2, blanket + 2) end
  local hx = head_right and x + w - 2 or x
  D.rect(hx, fy - m(1.05), 3, m(1.05), l + 1)
  local px = head_right and x + w - 12 or x + 4
  D.rect(px, by - 3, 8, 3, l + 4)
  return by
end

function K.door(x, fy, open, l, inner)
  local w, h = m(0.9), m(2.1)
  D.rect(x - 1, fy - h - 1, w + 2, h + 1, l + 1)
  D.rect(x, fy - h, w, h, inner or 1)
  if open and open > 0 then
    local ow = floor(w * (1 - open))
    D.rect(x, fy - h, ow, h, l)
    D.px(x + ow - 2, fy - h * 0.5, l + 4)
  else
    D.rect(x, fy - h, w, h, l)
    D.rect(x + 2, fy - h + 3, w - 4, h * 0.4, l - 1); D.rect(x + 2, fy - h * 0.5, w - 4, h * 0.4, l - 1)
    D.px(x + w - 3, fy - h * 0.5, l + 4)
  end
end

function K.lamp(x, fy, l, on, t)
  local top = fy - m(1.55)
  if on then D.glow(x, top + 3, 13 + D.noise(t * 2 + x) * 2, 6 + on * 2) end
  D.line(x, fy - 1, x, top + 4, l)
  D.rect(x - 3, fy - 1, 7, 1, l)
  D.poly({ x - 4, top + 4, x + 4, top + 4, x + 3, top - 1, x - 3, top - 1 }, on and 10 or l + 2)
end

function K.clock(x, y, t, l, big)
  local r = big and 4 or 3
  D.circle(x, y, r + 1, l + 2); D.circle(x, y, r, 2)
  local a = t / 60 * 2 * pi
  D.line(x, y, x + sin(a) * (r - 1), y - cos(a) * (r - 1), 12)
  D.line(x, y, x + sin(a / 12) * (r - 2), y - cos(a / 12) * (r - 2), 10)
  if big then
    local sw = sin(t * pi) * 0.3
    D.rect(x - 3, y + r + 1, 7, 13, l)
    D.rect(x - 2, y + r + 2, 5, 11, 1)
    D.line(x, y + r + 2, x + sin(sw) * 8, y + r + 2 + cos(sw) * 8, 8)
    D.circle(x + sin(sw) * 8, y + r + 2 + cos(sw) * 8, 1.2, 11)
  end
end

function K.frame(x, y, w, h, l, inner)
  D.rect(x, y, w, h, l + 2)
  D.rect(x + 1, y + 1, w - 2, h - 2, inner or l - 1)
end

function K.shelf(x, y, w, l, seed)
  D.rect(x, y, w, 1, l + 1)
  local r = D.lcg(seed or 3)
  local cx = x + 1
  while cx < x + w - 2 do
    local bw = 1 + floor(r() * 2)
    local bh = 4 + floor(r() * 3)
    D.rect(cx, y - bh, bw, bh, l + floor(r() * 4) - 1)
    cx = cx + bw + (r() < 0.2 and 1 or 0)
  end
end

function K.bookcase(x, fy, l, seed)
  local w, h = m(1.0), m(1.9)
  D.rect(x, fy - h, w, h, l - 1)
  for k = 1, 4 do K.shelf(x + 1, fy - h + k * (h / 4.4) + 4, w - 2, l + 1, (seed or 1) + k) end
end

function K.radio(x, y, l, t)
  D.rect(x, y - 6, 11, 6, l)
  D.rect(x + 1, y - 5, 6, 3, 9 + D.noise(t * 2) * 3)
  D.line(x + 2, y - 4, x + 2 + (t * 0.3) % 4, y - 4, 2)
  D.circle(x + 9, y - 3, 1.1, l + 3)
end

function K.tv(x, fy, t, on, l)
  local y = fy - m(0.5)
  D.rect(x, y, 18, fy - y, l)
  D.rect(x + 1, y - 13, 16, 13, l + 1)
  D.rect(x + 2, y - 12, 12, 10, on and (5 + D.noise(t * 9) * 4) or 1)
  if on then for i = 1, 8 do D.px(x + 2 + random(0, 11), y - 12 + random(0, 9), random(8, 14)) end end
  D.circle(x + 15.5, y - 9, 0.8, l + 4)
  return x + 8, y - 7
end

function K.stove(x, fy, l, t)
  local h = m(0.85)
  D.rect(x, fy - h, 26, h, l)
  D.rect(x, fy - h, 26, 2, l + 2)
  D.rect(x + 3, fy - h + 5, 9, 7, 0)
  D.rect(x + 4, fy - h + 6, 7, 5, 6 + D.noise(t * 5) * 5)
  D.rect(x + 15, fy - h + 4, 8, 8, l + 1)
  return fy - h
end

function K.crib(x, fy, l)
  local y = fy - m(0.9)
  D.rect(x, y, 20, 1, l + 2); D.rect(x, fy - m(0.45), 20, 2, l + 1)
  for i = x, x + 20, 3 do D.line(i, y, i, fy - m(0.45), l) end
  D.line(x, y, x, fy, l + 1); D.line(x + 20, y, x + 20, fy, l + 1)
  return fy - m(0.45)
end

function K.wardrobe(x, fy, l)
  local h = m(2.0)
  D.rect(x, fy - h, 18, h, l)
  D.line(x + 9, fy - h + 1, x + 9, fy - 2, l - 1)
  D.px(x + 7, fy - h * 0.5, l + 4); D.px(x + 11, fy - h * 0.5, l + 4)
  D.rect(x - 1, fy - h - 1, 20, 2, l + 1)
end

function K.fireplace(x, fy, t, l, k)
  k = k or 1
  local w, h = m(1.5), m(1.25)
  D.rect(x, fy - h, w, h, l)
  D.rect(x - 2, fy - h - 2, w + 4, 3, l + 1)
  for y = fy - h + 3, fy - 2, 4 do D.line(x, y, x + w - 1, y, l - 1) end
  D.rect(x + 4, fy - h + 6, w - 8, h - 6, 0)
  D.fire(x + w / 2, fy - 1, (w - 10) * (0.7 + k * 0.3), (h - 10) * (0.6 + k * 0.5), t, 15)
end

function K.sofa(x, fy, l, wm)
  local w = m(wm or 1.9)
  local sy = fy - m(0.42)
  D.rect(x, sy, w, fy - sy, l)
  D.rect(x + 2, fy - m(0.85), w - 4, m(0.43), l + 1)
  D.rect(x, sy - 4, 4, fy - sy + 4, l + 1); D.rect(x + w - 4, sy - 4, 4, fy - sy + 4, l + 1)
  return sy
end

function K.desk(x, fy, l)
  local ty = fy - m(0.75)
  D.rect(x, ty, 26, 2, l + 1)
  D.rect(x + 16, ty + 2, 10, fy - ty - 2, l - 1)
  D.line(x + 1, ty + 2, x + 1, fy - 1, l - 1)
  return ty
end

function K.typewriter(x, y, l)
  D.poly({ x, y, x + 12, y, x + 10, y - 4, x + 2, y - 4 }, l)
  D.rect(x + 1, y - 6, 10, 2, l + 2)
  D.rect(x + 3, y - 11, 6, 5, 13)
end

function K.rug(x1, x2, fy, l)
  D.poly({ x1 + 4, fy + 1, x2 - 4, fy + 1, x2, fy + 5, x1, fy + 5 }, l)
  D.line(x1 + 2, fy + 3, x2 - 2, fy + 3, l + 1)
end

-------------------------------------------------------------------------------
-- ESTERNI
-------------------------------------------------------------------------------
-- tipi di cielo: notte, alba, giorno, tramonto, grigio
function K.sky(kind, y1, t, st, gain)
  if kind == "notte" then D.gradient(0, y1, 0, 2)
  elseif kind == "alba" then D.gradient(0, y1, 2, 8)
  elseif kind == "giorno" then D.gradient(0, y1, 8, 11)
  elseif kind == "tramonto" then D.gradient(0, y1, 3, 10)
  elseif kind == "grigio" then D.gradient(0, y1, 5, 7)
  else D.gradient(0, y1, 1, 3) end
  if (kind == "notte" or kind == "crepuscolo") and st then
    st.stars = st.stars or D.stars_gen(80, 77, 0, y1 - 4)
    D.stars(st.stars, t, (gain or 1))
  end
end

function K.clouds(list, t, l)
  for _, c in ipairs(list) do D.cloud((c[1] + t * (c[4] or 1)) % 180 - 30, c[2], c[3], l, c[3]) end
end

-------------------------------------------------------------------------------
-- cervelli: il personaggio sceglie da solo cosa fare
-------------------------------------------------------------------------------
function K.think(fig, fn) if fig.idle then fig:act(fn()) end end

return K
