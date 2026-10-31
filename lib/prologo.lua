-- ANAMNESI · il prologo (v7)
-- Prima della soglia: una fiammella e chi racconta. Poi il bosco di notte,
-- lui con la lanterna; i passi da vicino; una radura, e in mezzo una porta
-- sola, senza casa intorno. Si apre: dentro ci sono le stelle. Entra.
-- Ogni volta il tempo è diverso: neve, pioggia, lucciole, o niente.

local D = include("lib/disegno")
local Pr = {}
local floor, sin, cos, random, min, max, pi, abs = math.floor, math.sin, math.cos, math.random, math.min, math.max, math.pi, math.abs

Pr.DUR = 39.5

local CARTE = {
  { "un luogo moderatamente sicuro", "presenta" },
  { "un luogo moderatamente sicuro", "presents" },
}
local FRASI = {
  { "ricordi veri, e immaginati", "chiudi gli occhi. poi aprili qui.", "niente di questo è perduto", "dove eravamo rimasti?" },
  { "memories, real and imagined", "close your eyes. then open them here.", "none of this is lost", "where were we?" },
}

-- le inquadrature: inizio, fine
local SH = { { 0, 6.5 }, { 6.5, 16 }, { 16, 22.5 }, { 22.5, 31 }, { 31, 35 }, { 35, 39.5 } }

local function lantern(x, y, f)
  -- la lanterna: un puntino che brucia e tre raggi corti verso terra
  local fl = D.noise(Pr.t * 6) * 3
  D.px(x, y + 1, 15); D.px(x, y, 12)
  D.line(x - 1, y - 2, x + 1, y - 2, 9)
  for i = -1, 1 do D.line(x + i, y + 3, x + i * 6, y + 9 + fl, 3) end
end

function Pr.init(lang, step)
  Pr.lang = lang
  Pr.step = step
  Pr.t = 0
  Pr.kind = random(4)
  Pr.ps = D.parts(60)
  Pr.frase = FRASI[lang][random(#FRASI[lang])]
  Pr.trees = {}
  for i = 1, 26 do Pr.trees[i] = { x = random() * 200, z = 0.3 + random() * 1.2, l = 2 + random() * 4 } end
  table.sort(Pr.trees, function(a, b) return a.z < b.z end)
  Pr.leaves = D.parts(20)
  local function st(f) if Pr.step then Pr.step(f) end end
  -- nel bosco: cammina sul posto, è il bosco che passa
  Pr.fig = D.figura(46, 54, { s = 1.05, l = 14, speed = 4, on_step = st,
    prop = function(x, y) lantern(x + 1, y + 2) end })
  Pr.fig.walking = true
  -- da vicino
  Pr.figc = D.figura(60, 78, { s = 2.7, l = 14, speed = 3, on_step = st,
    prop = function(x, y) lantern(x + 2, y + 3) end })
  Pr.figc.walking = true
  -- nella radura
  Pr.fig2 = D.figura(-8, 54, { s = 1.0, l = 14, speed = 4, on_step = st,
    prop = function(x, y) lantern(x + 1, y + 2) end })
  Pr.fig2:act({ { "walk", 54, 4 }, { "pose", "stand", 2.5 }, { "pose", "look_up", 2 }, { "pose", "reach_up", 99 } })
  -- dentro la porta
  Pr.fig3 = D.figura(64, 62, { s = 2.2, l = 14, pose = "stand" })
  Pr.door = 0
  Pr.walk = 0
end

local function weather(dt, t)
  if Pr.kind == 1 then D.snow_update(Pr.ps, dt, 1.4, 64, -2, t)
  elseif Pr.kind == 2 then D.rain_update(Pr.ps, dt, 1.0, 64, -6)
  elseif Pr.kind == 3 then D.motes_update(Pr.ps, dt, 1.2, { 0, 20, 128, 40 }, t) end
end

local function weather_draw()
  if Pr.kind == 1 then D.snow_draw(Pr.ps, 10)
  elseif Pr.kind == 2 then D.rain_draw(Pr.ps, 0.6)
  elseif Pr.kind == 3 then D.motes_draw(Pr.ps, 12) end
end

function Pr.update(dt)
  Pr.t = Pr.t + dt
  local t = Pr.t
  weather(dt, t)
  if t > SH[2][1] and t < SH[3][2] then
    Pr.walk = Pr.walk + dt * 9
    local f = (t < SH[3][1]) and Pr.fig or Pr.figc
    -- il passo, senza andare da nessuna parte
    local old = f.ph
    f.walking = true
    f.ph = f.ph + dt * 4.2
    if f.on_step and floor(old / pi) ~= floor(f.ph / pi) then f.on_step(f) end
    f.t = f.t + dt
    local k = math.min(1, dt * 14)
    local p = {}
    local s1, c1 = sin(f.ph), cos(f.ph)
    p.th1 = 24 * s1; p.th2 = -24 * s1
    p.sh1 = p.th1 - 24 * max(0, -c1); p.sh2 = p.th2 - 24 * max(0, c1)
    p.ua1 = 30; p.ua2 = 16 * s1 + 4; p.fa1 = 70; p.fa2 = p.ua2 + 14
    p.lean = 5; p.nod = 6; p.hy = 7.0 - 0.35 * abs(c1); p.rot = 0
    for key, v in pairs(p) do f.cur[key] = f.cur[key] + (v - f.cur[key]) * k end
    if random() < dt * 3 then D.spawn(Pr.leaves, { x = 130, y = random() * 50, vx = -20 - random() * 20, vy = 4 + random() * 4, life = 6, ph = random() * 6 }) end
    D.parts_update(Pr.leaves, dt, function(p2, d) p2.x = p2.x - Pr.walk * 0 ; p2.y = p2.y + sin(p2.age * 3 + p2.ph) * d * 4 end)
  end
  if t > SH[4][1] and t < SH[4][2] then Pr.fig2:update(dt) end
  if t > SH[4][1] + 6 then Pr.door = min(1, Pr.door + dt * 0.45) end
  if t > SH[5][1] then Pr.fig3:update(dt) end
  return t >= Pr.DUR
end

local function fade(t, a, b, inn, out)
  return max(0, min(1, (t - a) / inn, (b - t) / out))
end

local function title(txt, y, l, size)
  screen.font_face(1); screen.font_size(size or 8)
  screen.level(D.lv(l)); screen.move(64, y); screen.text_center(Pr.tr and Pr.tr(txt) or txt)
end

local function bars(h)
  h = h or 7
  screen.level(0); screen.rect(0, 0, 128, h); screen.rect(0, 64 - h, 128, h); screen.fill()
end

-- la porta sola nella radura: il telaio, la luce sotto, e quando si apre le stelle
local function porta(cx, base, w, h, open, t, l)
  local x0, x1, y0 = cx - w / 2, cx + w / 2, base - h
  D.line(x0, base, x0, y0, l); D.line(x1, base, x1, y0, l); D.line(x0, y0, x1, y0, l)
  if open < 0.02 then
    D.line(x0 + 1, base - 1, x1 - 1, base - 1, 8 + 3 * D.noise(t * 3))
    -- l'anta chiusa: due righe di legno appena accennate
    D.line(x0 + 2, y0 + h * 0.3, x1 - 2, y0 + h * 0.3, 2); D.line(x0 + 2, y0 + h * 0.7, x1 - 2, y0 + h * 0.7, 2)
    D.px(x1 - 3, base - h * 0.45, 8)
  else
    -- l'anta ruota verso di noi: un trapezio di sole linee
    local ow = w * (1 - open * 0.85)
    D.line(x0, y0, x0 - (w - ow) * 0.35, y0 - 2 * open, l - 1)
    D.line(x0 - (w - ow) * 0.35, y0 - 2 * open, x0 - (w - ow) * 0.35, base + 2 * open, l - 1)
    -- dentro: stelle che si accendono
    local r = D.lcg(17)
    for i = 1, floor(12 + open * 18) do
      local sx, sy = x0 + 1 + r() * (w - 2), y0 + 1 + r() * (h - 2)
      D.px(sx, sy, (4 + r() * 11) * open * (0.6 + 0.4 * sin(t * (1 + r() * 2) + i)))
    end
    -- la luce che esce, a raggi sottili sul prato
    for i = 0, 6 do
      local k = i / 6
      D.line(x0 + k * w, base, cx + (k - 0.5) * w * 4.5, 64, 2 + open * 4 * sin(k * pi))
    end
  end
end

function Pr.draw()
  local t = Pr.t
  screen.level(0); screen.rect(0, 0, 128, 64); screen.fill()
  local lg = Pr.lang
  if t < SH[1][2] then
    -- una fiammella nel buio, e il nome di chi racconta
    local a = fade(t, 0.5, SH[1][2], 1.5, 1.2)
    D.gain = a
    local fl = D.noise(t * 5)
    D.rect(63, 24, 3, 6, 9)
    D.poly({ 63, 24, 66, 24, 64.5 + (fl - 0.5) * 1.5, 18 - fl * 2 }, 13)
    D.px(64, 22, 15)
    title("un luogo", 38, 10)
    title("moderatamente sicuro", 47, 10)
    title(CARTE[lg][2], 57, 5)
    D.gain = 1
  elseif t < SH[2][2] then
    -- il bosco di notte: i tronchi passano, lui cammina con la lanterna
    local a = fade(t, SH[2][1], SH[2][2], 2.0, 0.6)
    D.gain = a
    for _, tr in ipairs(Pr.trees) do
      local x = (tr.x - Pr.walk * tr.z) % 200 - 30
      local near = 1 - math.min(1, abs(x - 46) / 50)
      local l = tr.l * (0.5 + tr.z * 0.4) + near * 4
      D.line(x, 0, x, 56, l)
      if tr.z > 1.1 then D.line(x + 1, 0, x + 1, 56, l * 0.6) end
      if tr.z > 0.8 then D.line(x, 12 + tr.l * 3, x + 6 * tr.z, 6 + tr.l * 3, l * 0.7) end
    end
    D.line(0, 56, 127, 56, 3)
    for i = 0, 20 do local x = (i * 13 - Pr.walk * 1.2) % 140 - 6; D.px(x, 58 + (i % 3), 3) end
    weather_draw()
    Pr.fig:draw()
    for _, p in ipairs(Pr.leaves.list) do D.line(p.x, p.y, p.x + 1, p.y - 1, 6) end
    bars()
    D.gain = 1
  elseif t < SH[3][2] then
    -- da vicino: la lanterna che dondola a ogni passo, il sentiero sotto
    local a = fade(t, SH[3][1], SH[3][2], 0.5, 0.6)
    D.gain = a
    for i = 0, 6 do
      local x = (i * 37 - Pr.walk * 2.6) % 190 - 30
      D.line(x, 0, x + 4, 64, 2 + (i % 3))
    end
    weather_draw()
    local sw = sin(Pr.figc.ph) * 0.35
    local px, py = 64, 4
    local lx, ly = px + sin(sw) * 26, py + cos(sw) * 26
    -- il manico e la gabbia
    D.line(px, 0, lx, ly, 7)
    local function P(dx, dy) return lx + dx * cos(sw) + dy * sin(sw), ly - dx * sin(sw) + dy * cos(sw) end
    local c = { { -6, 2 }, { 6, 2 }, { 7, 20 }, { -7, 20 } }
    for i = 1, 4 do local a1, b1 = P(c[i][1], c[i][2]); local a2, b2 = P(c[i % 4 + 1][1], c[i % 4 + 1][2]); D.line(a1, b1, a2, b2, 10) end
    local t1, t2 = P(-4, 0); local t3, t4 = P(4, 0); local t5, t6 = P(0, -3)
    D.line(t1, t2, t5, t6, 9); D.line(t5, t6, t3, t4, 9)
    for i = -1, 1, 2 do local a1, b1 = P(i * 3, 3); local a2, b2 = P(i * 3.5, 19); D.line(a1, b1, a2, b2, 4) end
    -- la fiamma
    local fl = D.noise(t * 7)
    local f1, f2 = P(0, 15); local f3, f4 = P((fl - 0.5) * 2, 8 - fl * 2)
    D.line(f1, f2, f3, f4, 15); D.px(f1, f2, 15); D.px(f1 + 1, f2, 12)
    -- la luce che cade sul sentiero e si sposta col dondolo
    local gx = lx
    for i = -3, 3 do D.line(gx + i * 2, 50, gx + i * 9, 62, 3 + (3 - abs(i))) end
    D.line(0, 56, 127, 56, 3)
    for i = 0, 14 do local x = (i * 17 - Pr.walk * 3) % 140 - 6; D.line(x, 58 + (i % 3), x + 3, 58 + (i % 3), 4) end
    bars()
    D.gain = 1
  elseif t < SH[4][2] then
    -- la radura: una porta sola, senza casa intorno
    local a = fade(t, SH[4][1], SH[4][2], 1.2, 0.4)
    D.gain = a
    local r = D.lcg(5)
    for i = 1, 40 do D.px(r() * 128, r() * 30, 2 + r() * 6) end
    for i = 0, 12 do local x = i * 11 + 3; D.line(x, 40 - (i % 3) * 3, x, 54, 2) end
    D.line(0, 54, 127, 54, 3)
    porta(84, 54, 16, 28, Pr.door, t, 10)
    weather_draw()
    Pr.fig2:draw()
    bars()
    D.gain = 1
  elseif t < SH[5][2] then
    -- da dentro la luce: la porta enorme, le stelle, lui che entra e rimpicciolisce
    local a = fade(t, SH[5][1], SH[5][2], 0.4, 0.8)
    D.gain = a
    local k = (t - SH[5][1]) / (SH[5][2] - SH[5][1])
    local r = D.lcg(23)
    for i = 1, 70 do
      local sx, sy = 20 + r() * 88, 4 + r() * 56
      D.px(sx, sy, (3 + r() * 12) * (0.6 + 0.4 * sin(t * (1 + r() * 2) + i)))
    end
    D.line(18, 64, 18, 2, 9); D.line(110, 64, 110, 2, 9); D.line(18, 2, 110, 2, 9)
    local f = Pr.fig3
    f.s = 2.2 * (1 - k * 0.8)
    f.y = 62 - k * 22
    f:draw()
    D.gain = 1
  else
    -- il titolo, una lettera alla volta, e una frase
    local tt = t - SH[6][1]
    local a = fade(t, SH[6][1], SH[6][2], 0.3, 0.9)
    D.gain = a
    local name = "ANAMNESI"
    screen.font_face(1); screen.font_size(8)
    for i = 1, #name do
      local li = max(0, min(1, (tt - i * 0.18) / 0.4))
      if li > 0 then
        screen.level(D.lv(14 * li)); screen.move(29 + (i - 1) * 10, 30); screen.text(name:sub(i, i))
      end
    end
    local fa = max(0, min(1, (tt - 2) / 0.8))
    if fa > 0 then title(Pr.frase, 46, 6 * fa) end
    D.gain = 1
  end
end

return Pr
