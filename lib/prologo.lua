-- ANAMNESI · il prologo
-- Prima di arrivare sulla soglia: una luce nel buio, una strada di notte,
-- una casa su un colle con una finestra accesa, una porta che si apre.
-- Ogni volta il tempo è diverso: neve, pioggia, lucciole, stelle.

local D = include("lib/disegno")
local Pr = {}
local floor, sin, cos, random, min, max, pi = math.floor, math.sin, math.cos, math.random, math.min, math.max, math.pi

Pr.DUR = 43

local CARTE = {
  { "un luogo moderatamente sicuro", "presenta" },
  { "un luogo moderatamente sicuro", "presents" },
}
local FRASI = {
  { "ricordi veri, e immaginati", "chiudi gli occhi. poi aprili qui.", "niente di questo è perduto", "dove eravamo rimasti?" },
  { "memories, real and imagined", "close your eyes. then open them here.", "none of this is lost", "where were we?" },
}

-- le inquadrature: inizio, fine
local SH = { { 0, 6.5 }, { 6.5, 17 }, { 17, 24 }, { 24, 32 }, { 32, 40 }, { 40, 43 } }

function Pr.init(lang, step)
  Pr.lang = lang
  Pr.step = step
  Pr.t = 0
  Pr.kind = random(4)
  Pr.ps = D.parts(60)
  Pr.frase = FRASI[lang][random(#FRASI[lang])]
  Pr.stars = D.stars_gen(60, random(999), 0, 36)
  Pr.hills = D.ridge_gen(random(999), 44, 8, 0.7)
  Pr.hill2 = D.ridge_gen(random(999), 52, 8, 0.5)
  local function st(f) if Pr.step then Pr.step(f) end end
  -- la strada, di lato
  Pr.fig = D.figura(-6, 54, { s = 1.0, l = 10, speed = 7, on_step = st })
  Pr.fig:act({ { "walk", 200, 7 } })
  -- il primo piano
  Pr.figc = D.figura(56, 76, { s = 2.7, l = 9, speed = 3, on_step = st })
  Pr.figc:act({ { "walk", 9999, 3 } })
  -- il sentiero sul colle
  Pr.fig2 = D.figura(18, 60, { s = 0.75, l = 9, speed = 5, on_step = st })
  Pr.fig2:act({ { "walk", 52, 5, 50 }, { "walk", 70, 4, 44 }, { "pose", "stand", 9 } })
  -- davanti alla porta
  Pr.fig3 = D.figura(64, 70, { s = 2.6, l = 1, dark = true, pose = "stand" })
  Pr.fig3:act({ { "wait", 3.2 }, { "pose", "look_up", 2 }, { "pose", "arms_open", 9 } })
  Pr.door = 0
end

local function weather(dt, t)
  if Pr.kind == 1 then D.snow_update(Pr.ps, dt, 1.6, 64, -2, t)
  elseif Pr.kind == 2 then D.rain_update(Pr.ps, dt, 1.2, 64, -6)
  elseif Pr.kind == 3 then D.motes_update(Pr.ps, dt, 1.5, { 0, 30, 128, 30 }, t) end
end

local function weather_draw()
  if Pr.kind == 1 then D.snow_draw(Pr.ps, 12)
  elseif Pr.kind == 2 then D.rain_draw(Pr.ps, 0.7)
  elseif Pr.kind == 3 then D.motes_draw(Pr.ps, 12) end
end

function Pr.update(dt)
  Pr.t = Pr.t + dt
  local t = Pr.t
  weather(dt, t)
  if t > SH[2][1] and t < SH[2][2] then Pr.fig:update(dt) end
  if t > SH[3][1] and t < SH[3][2] then Pr.figc:update(dt) end
  if t > SH[4][1] and t < SH[4][2] then Pr.fig2:update(dt) end
  if t > SH[5][1] then Pr.fig3:update(dt) end
  if t > SH[5][1] + 2.5 then Pr.door = min(1, Pr.door + dt * 0.28) end
  return t >= Pr.DUR
end

local function fade(t, a, b, inn, out)
  return max(0, min(1, (t - a) / inn, (b - t) / out))
end

local function title(txt, y, l, size)
  screen.font_face(1); screen.font_size(size or 8)
  screen.level(D.lv(l)); screen.move(64, y); screen.text_center(Pr.tr and Pr.tr(txt) or txt)
end

local function bars()
  screen.level(0); screen.rect(0, 0, 128, 7); screen.rect(0, 57, 128, 7); screen.fill()
end

local function poles(cam, base, h, l)
  local px = {}
  for i = -1, 4 do
    local x = i * 44 - (cam % 44)
    px[#px + 1] = x
    D.rect(x, base - h, 1, h, l); D.rect(x - 3, base - h + 2, 7, 1, l)
  end
  for i = 1, #px - 1 do
    local a, b = px[i], px[i + 1]
    local y = base - h + 2
    local m = (a + b) / 2
    D.line(a, y, m, y + 3, l - 1); D.line(m, y + 3, b, y, l - 1)
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
    -- la strada di notte, di lato, lui che cammina
    local a = fade(t, SH[2][1], SH[2][2], 1.8, 0.8)
    D.gain = a
    local cam = Pr.fig.x - 46
    D.gradient(8, 46, 0, 3)
    D.stars(Pr.stars, t, 1)
    D.moon(114, 30, 4, 14, 0)
    D.ridge(Pr.hills, 1, 64, cam * 0.08)
    D.rect(0, 50, 128, 14, 1)
    D.line(0, 50, 127, 50, 4)
    poles(cam, 50, 26, 5)
    local x = Pr.fig.x
    Pr.fig.x = 46
    Pr.fig:draw()
    Pr.fig.x = x
    weather_draw()
    bars()
    D.gain = a * fade(t, SH[2][1] + 2.5, SH[2][2] - 0.6, 2, 1.2)
    title("A N A M N E S I", 18, 15)
    D.gain = 1
  elseif t < SH[3][2] then
    -- il primo piano: il cappotto, il passo, una frase
    local a = fade(t, SH[3][1], SH[3][2], 0.6, 0.8)
    D.gain = a
    local cam = Pr.figc.x - 56
    D.gradient(0, 50, 0, 2)
    D.stars(Pr.stars, t, 0.6, -cam * 0.1)
    local px = 128 - (cam * 2.4) % 180
    D.rect(px, 0, 4, 64, 2)
    local x = Pr.figc.x
    Pr.figc.x = 56
    Pr.figc:draw()
    Pr.figc.x = x
    weather_draw()
    bars()
    D.gain = a * fade(t, SH[3][1] + 1.2, SH[3][2] - 0.4, 1.2, 1)
    title(Pr.frase, 63, 9)
    D.gain = 1
  elseif t < SH[4][2] then
    -- la casa sul colle, una finestra accesa, il sentiero che sale
    local a = fade(t, SH[4][1], SH[4][2], 1.2, 0.8)
    local z = 1 + (t - SH[4][1]) * 0.035
    D.gain = a
    local function Z(x, y) return 64 + (x - 64) * z, 44 + (y - 44) * z end
    D.gradient(0, 50, 0, 3)
    D.stars(Pr.stars, t, 0.9)
    D.moon(24, 14, 3, 13, 0)
    -- il colle
    screen.level(D.lv(2))
    local x0, y0 = Z(-20, 64); screen.move(x0, y0)
    for i = 0, 20 do local hx, hy = Z(-20 + i * 9, 64 - 22 * math.sin(i / 20 * pi) ^ 0.6); screen.line(hx, hy) end
    local xe, ye = Z(160, 64); screen.line(xe, ye); screen.close(); screen.fill()
    -- il sentiero
    for k = 0, 30 do
      local f = k / 30
      local px, py = Z(18 + f * 52, 60 - f * 16)
      D.px(px, py, 6)
    end
    -- la casa
    local x1, y1 = Z(62, 34); local x2, y2 = Z(84, 46)
    D.rect(x1, y1, x2 - x1, y2 - y1, 5)
    local r1x, r1y = Z(60, 34); local r2x, r2y = Z(86, 34); local r3x, r3y = Z(73, 25)
    D.poly({ r1x, r1y, r2x, r2y, r3x, r3y }, 6)
    local cx1, cy1 = Z(78, 27); local cx2, cy2 = Z(81, 31)
    D.rect(cx1, cy1, cx2 - cx1, cy2 - cy1, 6)
    local wx1, wy1 = Z(75, 37); local wx2, wy2 = Z(81, 42)
    D.rect(wx1, wy1, wx2 - wx1, wy2 - wy1, 13 + sin(t * 2) * 1.5)
    local dx1, dy1 = Z(66, 39); local dx2, dy2 = Z(71, 46)
    D.rect(dx1, dy1, dx2 - dx1, dy2 - dy1, 2)
    -- un albero accanto
    local tx, ty = Z(94, 46)
    D.bare_tree(tx, ty, 16 * z, 2, 7, sin(t) * 0.5)
    -- lui, piccolo, che sale
    local fx, fy = Pr.fig2.x, Pr.fig2.y
    Pr.fig2.x, Pr.fig2.y = Z(fx, fy)
    local s0 = Pr.fig2.s; Pr.fig2.s = s0 * z
    Pr.fig2:draw()
    Pr.fig2.x, Pr.fig2.y, Pr.fig2.s = fx, fy, s0
    weather_draw()
    bars()
    D.gain = 1
  elseif t < SH[5][2] then
    -- la porta: lui, di spalle; si apre, ed è tutta luce
    local a = fade(t, SH[5][1], SH[5][2] + 9, 0.8, 1)
    D.gain = a
    D.rect(0, 0, 128, 64, 3)
    for y = 7, 56, 4 do D.line(0, y, 127, y, 2) end
    local open = Pr.door
    D.rect(40, 6, 48, 58, 1)
    D.rect(44, 10, 40, 54, 15)
    D.rect(44 + 40 * open, 10, 40 * (1 - open), 54, 4)
    if open < 0.95 then D.rect(44 + 40 * open + 33 * (1 - open), 36, 2, 2, 10) end
    D.poly({ 44, 63, 84, 63, 84 + 30 * open, 64, 44 - 30 * open, 64 }, 10 * open)
    Pr.fig3:draw()
    if t > SH[5][2] - 2.5 then D.rect(0, 0, 128, 64, (t - (SH[5][2] - 2.5)) / 2.5 * 15) end
    bars()
    D.gain = 1
  else
    -- il bianco che si spegne piano: e sei sulla soglia
    local k = (t - SH[6][1]) / (SH[6][2] - SH[6][1])
    D.rect(0, 0, 128, 64, 15 * (1 - k) ^ 1.5)
  end
end

return Pr
