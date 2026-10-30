-- ANAMNESI · scene dei ricordi nuovi (v3), dal paese all'abisso
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

D.POSE.wipe = { lean = 0, nod = -6, ua1 = 120, ua2 = 8, fa1 = 140, fa2 = 4, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.2, rot = 0 }
D.POSE.lean_glass = { lean = 14, nod = 30, ua1 = 30, ua2 = 22, fa1 = 120, fa2 = 110, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }
D.POSE.hold_hand = { lean = 20, nod = 26, ua1 = 70, ua2 = 30, fa1 = 80, fa2 = 90, th1 = 4, th2 = 0, sh1 = -88, sh2 = -86, hy = 3.6, rot = 0 }

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(D.tr(s)) else screen.text(D.tr(s)) end
end

-------------------------------------------------------------------------------
-- IL TRENO DI NOTTE: lo scompartimento, le stazioni che passano
-------------------------------------------------------------------------------
S.treno_notte = {
  init = function(s)
    s.fig = D.figura(84, 52, { s = KS, l = 7, pose = "sit", face = -1 })
    s.other = D.figura(38, 52, { s = KS, l = 4, pose = "lean_glass", face = -1, dark = false })
    s.lights = {}
    for i = 1, 6 do s.lights[i] = { x = R(0, 300), big = random() < 0.3 } end
    s.off = 0
  end,
  update = function(s, dt, t)
    s.off = s.off + dt * (60 + mac("treno") * 90)
    think(s.fig, function() return pick({ { { "pose", "sit", R(8, 14) } }, { { "pose", "sit_think", R(6, 10) } }, { { "face", 1 }, { "pose", "sit", 4 }, { "face", -1 } } }) end)
    s.fig:update(dt); s.other:update(dt)
  end,
  draw = function(s, t)
    local j = sin(t * 19) * 0.35
    local nt = mac("notte")
    D.rect(0, 0, 128, 64, 1)
    -- il finestrino: fuori il buio, le luci delle stazioni
    D.rect(30, 12 + j, 68, 24, 0)
    local lit = 0
    for _, L in ipairs(s.lights) do
      local x = (L.x - s.off) % 300 - 40
      if x > 20 and x < 108 then
        local cx = max(30, min(98, x))
        if L.big then D.rect(cx, 14 + j, min(10, 98 - cx), 20, 11 - nt * 3); lit = 1
        else D.px(cx, 26 + j, 14) ; D.px(cx + 3, 28 + j, 10) end
      end
    end
    for i = 0, 4 do local x = (i * 30 - s.off * 0.3) % 80 + 30; if x < 97 then D.line(x, 32 + j, x + 2, 32 + j, 2) end end
    D.rect(28, 10 + j, 72, 2, 4); D.rect(28, 36 + j, 72, 3, 4); D.rect(28, 10 + j, 2, 28, 4); D.rect(98, 10 + j, 2, 28, 4)
    -- la valigia sul portapacchi
    D.rect(20, 4, 88, 1, 4); D.rect(60, 0, 16, 4, 5); D.rect(66, -1, 4, 1, 6)
    -- i sedili
    D.rect(4, 26, 16, 32, 3); D.rect(108, 26, 16, 32, 3)
    D.rect(4, 44, 40, 4, 3); D.rect(84, 44, 40, 4, 3)
    D.rect(0, 58, 128, 6, 0)
    s.other.l = 3 + lit * 6
    s.fig.l = 6 + lit * 5
    s.other:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CITTÀ LONTANA: una strada sconosciuta, una cartina, i cipressi lontani
-------------------------------------------------------------------------------
S.citta_lontana = {
  init = function(s)
    s.fig = D.figura(54, 56, { s = 1.2, l = 11, pose = "hold", speed = 4, on_step = H.steps("pietra", 0.3),
      prop = function(x, y) D.rect(x - 4, y - 5, 8, 6, 13); D.line(x - 2, y - 3, x + 2, y - 2, 8) end })
    s.lei = D.figura(140, 56, { s = 1.15, l = 6, dress = true, speed = 4 })
    s.pass = {}
    for i = 1, 6 do s.pass[i] = { x = R(-20, 150), v = R(6, 12) * pick({ -1, 1 }), l = R(3, 6) } end
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "pose", "hold", R(5, 8) }, { "face", -1 }, { "pose", "hold", 3 }, { "face", 1 } } end
      if r < 0.7 then return { { "walk", R(40, 70), 4 }, { "pose", "look_up", 4 } } end
      return { { "fn", function() s.lei.x = 140; s.lei:act({ { "walk", s.fig.x + 10, 4 }, { "face", -1 }, { "pose", "talk", 3 }, { "pose", "stand", 2 }, { "walk", -20, 4 } }) end },
        { "pose", "hold", 3 }, { "face", 1 }, { "pose", "talk", 4 }, { "pose", "stand", 3 }, { "face", -1 }, { "pose", "head_down", 4 } }
    end)
    s.fig:update(dt); s.lei:update(dt)
    local n = 2 + floor(mac("folla") * 4)
    for i, p in ipairs(s.pass) do
      if i <= n then p.x = p.x + p.v * dt; if p.x > 150 then p.x = -20 elseif p.x < -20 then p.x = 150 end end
    end
  end,
  draw = function(s, t)
    D.gradient(0, 30, 7, 9)
    -- il colle lontano coi cipressi del cimitero, la strada che ci porta
    D.poly({ 30, 30, 50, 22, 80, 22, 100, 30 }, 6)
    D.rect(30, 30, 70, 26, 7)
    for i = 0, 5 do local x = 36 + i * 10; D.rect(x, 34 - (i % 3) * 2, 8, 22 + (i % 3) * 2, 6); D.rect(x + 2, 38, 2, 3, 4); D.rect(x + 5, 44, 2, 3, 4) end
    for i = 0, 5 do D.cypress(52 + i * 5, 23, 6, 4, 0) end
    D.rect(54, 22, 22, 1, 7)
    -- i palazzi, i portici
    D.rect(0, 10, 34, 46, 5); D.rect(98, 6, 30, 50, 5)
    for y = 14, 34, 7 do for x = 4, 28, 8 do D.rect(x, y, 4, 5, 3) end; for x = 102, 124, 8 do D.rect(x, y, 4, 5, 3) end end
    for i = 0, 3 do
      local x = i * 9 + 1
      D.rect(x, 42, 7, 14, 2)
      D.circle(x + 3.5, 42, 3.5, 2)
    end
    D.rect(0, 40, 34, 2, 6)
    D.rect(0, 56, 128, 8, 6)
    for x = 0, 127, 6 do D.line(x, 56, x - 3, 63, 5) end
    local n = 2 + floor(mac("folla") * 4)
    for i, p in ipairs(s.pass) do
      if i <= n then
        local x = p.x
        D.circle(x, 44, 1.6, p.l); D.rect(x - 1, 45, 3, 7, p.l); D.line(x, 52, x + sin(t * 6 + i) * 1.5, 56, p.l)
      end
    end
    s.lei:draw(); s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- DOPO LA FESTA: i coriandoli, i bicchieri, il disco che gira ancora
-------------------------------------------------------------------------------
S.festa_finita = {
  init = function(s)
    s.fig = D.figura(70, 58, { s = KS, l = 9, pose = "sit_slump", face = -1, speed = 4, on_step = H.steps("pietra", 0.25) })
    s.conf = {}
    for i = 1, 60 do s.conf[i] = { x = R(0, 128), y = R(57, 63), l = pick({ 6, 9, 12, 14 }) } end
    s.balloon = { y = 10, x = 100 }
    s.ang = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "pose", "sit_slump", R(8, 14) } } end
      if r < 0.8 then return { { "pose", "stand", 1 }, { "walk", 42, 3 }, { "pose", "carry", 4 }, { "walk", 70, 3 }, { "face", -1 }, { "pose", "sit", R(6, 9) } } end
      return { { "pose", "sit_think", R(6, 10) } }
    end)
    s.fig:update(dt)
    s.balloon.y = s.balloon.y + dt * 0.8
    s.balloon.x = s.balloon.x + sin(t * 0.4) * dt * 2
    if s.balloon.y > 50 then s.balloon.y = 50 end
    s.ang = s.ang + dt * (1 + mac("radio") * 2)
  end,
  draw = function(s, t)
    local ra = mac("radio")
    K.room({ wall = 3, fy = 58, floor = "piastrelle", floor_l = 2, ceil = 4 }, t)
    -- le stelle filanti che pendono
    for i = 0, 8 do
      local x = i * 15 + 4
      screen.level(D.lv(5 + (i % 3) * 2)); screen.move(x, 4); screen.curve(x + 4, 12, x + 8, 6 + sin(t * 0.5 + i) * 2, x + 12, 4); screen.stroke()
      D.line(x + 6, 7, x + 6 + sin(t + i), 14 + (i % 3) * 3, 6)
    end
    K.window(96, 14, 18, 16, K.views.night, t, s, 5)
    -- il tavolo coi bicchieri a metà
    local ty = K.table(20, 58, 1.6, 4, 7)
    for i = 0, 4 do local x = 24 + i * 4; D.rect(x, ty - 4, 2, 4, 9); D.rect(x, ty - 2, 2, 2, 5 + (i % 3) * 2) end
    D.rect(40, ty - 3, 6, 3, 8)
    -- il giradischi
    D.rect(100, 44, 18, 14, 3)
    D.circle(109, 42, 6, 2); D.circle(109, 42, 1, 9)
    D.line(109, 42, 109 + cos(s.ang * 3) * 5, 42 + sin(s.ang * 3) * 1.5, 7)
    D.line(116, 38, 112, 41, 8)
    if ra > 0.1 then D.px(102, 46, 8 + ra * 7) end
    for _, c in ipairs(s.conf) do D.px(c.x, c.y, c.l) end
    K.chair(70, 58, -1, 4)
    -- il palloncino che scende senza fiato
    local b = s.balloon
    D.circle(b.x, b.y, 3, 7); D.px(b.x - 1, b.y - 1, 11)
    D.line(b.x, b.y + 3, b.x + sin(t) * 2, b.y + 9, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CITTÀ VECCHIA: i portici, la pioggia, una cabina, un gettone
-------------------------------------------------------------------------------
S.citta_vecchia = {
  init = function(s)
    s.rain = D.parts(160)
    s.fig = D.figura(102, 56, { s = 1.2, l = 9, pose = "phone" })
    s.umb = D.figura(-10, 56, { s = 1.05, l = 3, dark = true, speed = 5, prop = function(x, y, f) D.line(x, y, x, y - 9, 3); D.poly({ x - 7, y - 7, x + 7, y - 7, x, y - 12 }, 2) end })
    s.ring = 0
  end,
  update = function(s, dt, t)
    D.rain_update(s.rain, dt, 1 + mac("pioggia") * 4, 60, -5)
    think(s.fig, function() return { { "pose", "phone", R(10, 16) }, { "pose", "head_down", 4 }, { "pose", "phone", 6 } } end)
    think(s.umb, function() return { { "wait", R(4, 12) }, { "fn", function(f) f.x = -10 end }, { "walk", 140, 5 } } end)
    s.fig:update(dt); s.umb:update(dt)
    s.ring = s.ring + dt
    if s.ring > 4 then s.ring = 0; if s.fig.cur.ua1 > 100 then S.env.sfx("bell", 880, 0.012, 0.8, 0.6, 0.2, 0.001) end end
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- le case, le finestre gialle
    D.rect(0, 4, 128, 40, 2)
    for i = 0, 7 do
      local x = 6 + i * 16
      D.rect(x, 10, 6, 8, (i % 3 == 0) and 11 or 1)
      D.rect(x, 24, 6, 8, (i % 4 == 1) and 10 or 1)
    end
    -- i portici
    for i = 0, 4 do
      local x = i * 22 - 4
      D.rect(x, 34, 4, 22, 3)
      screen.level(D.lv(3)); screen.move(x + 4, 38); screen.curve(x + 8, 32, x + 14, 32, x + 18, 38); screen.stroke()
    end
    D.rect(0, 30, 128, 3, 3)
    -- il lastricato lucido coi riflessi
    D.rect(0, 56, 128, 8, 1)
    for i = 0, 7 do D.reflection(9 + i * 16, 57, 63, 4, t + i, 6) end
    -- la grondaia che trabocca
    for y = 4, 56, 3 do D.px(124, y + (t * 30) % 3, 8) end
    -- la cabina
    D.rect(94, 30, 18, 26, 4); D.rect(96, 32, 14, 22, 1); D.rect(94, 28, 18, 3, 6)
    D.rect(104, 36, 4, 5, 6)
    s.fig:draw()
    D.rain_draw(s.rain, 0.8)
    s.umb:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE STRADE NELLA NEBBIA: guidando, le righe bianche una alla volta
-------------------------------------------------------------------------------
S.strade_nebbia = {
  init = function(s)
    s.p = 0
    s.car = nil
    s.bark = 0
  end,
  update = function(s, dt, t)
    s.p = s.p + dt * 1.2
    if not s.car and random() < dt * 0.04 then s.car = { z = 0 } end
    if s.car then s.car.z = s.car.z + dt * 0.25; if s.car.z > 1.2 then s.car = nil end end
    s.bark = s.bark - dt
    if s.bark < 0 then s.bark = R(15, 40); S.env.sfx("drop", 300, 0.02, 0.15, -0.6, 0.3, 0.001) end
  end,
  draw = function(s, t)
    local fog = mac("nebbia")
    D.rect(0, 0, 128, 64, 0)
    -- la strada in prospettiva, i fari che la illuminano
    D.poly({ 60, 30, 68, 30, 120, 64, 8, 64 }, 2)
    D.poly({ 62, 30, 66, 30, 100, 64, 28, 64 }, 3)
    local fr = s.p % 1
    for j = 0, 6 do
      local d = j + 1 - fr
      local sc = 1 / (d * 0.5 + 0.3)
      local y = 30 + 34 * min(1, sc * 0.3)
      local h = max(1, sc * 1.2)
      local l = 12 - d * 1.4
      if y < 64 then D.rect(63.5 - sc * 0.4, y, max(1, sc * 0.8), h, l) end
    end
    -- la nebbia: bande nette che scorrono
    local nb = 3 + floor(fog * 4)
    for i = 0, nb - 1 do
      local y = 24 + i * 5 + sin(t * 0.3 + i) * 1.5
      local x0 = (t * (3 + i) + i * 40) % 160 - 40
      D.rect(x0, y, 60 + i * 10, 2, 3 + fog * 2)
      D.rect(x0 + 90, y + 2, 40, 1, 2 + fog * 2)
    end
    -- la cascina lontana che non vedi bene
    D.rect(20, 26, 1, 1, 6 - fog * 4)
    -- l'auto che arriva: due luci che crescono, passano, spariscono
    if s.car then
      local z = s.car.z
      local sc = z * z
      local x = 70 + sc * 30
      local y = 31 + sc * 20
      local r = 0.6 + sc * 5
      if z < 1 then D.circle(x, y, r, 13); D.circle(x + 2 + sc * 10, y, r, 13) end
      if z > 0.85 then D.rect(0, 0, 128, 64, (1 - abs(z - 1) * 6) * 6) end
    end
    -- il volante, le mani
    screen.level(D.lv(2)); screen.arc(64, 74, 26, pi * 1.15, pi * 1.85); screen.stroke()
    D.circle(44, 58, 3, 3); D.circle(84, 58, 3, 3)
    D.rect(0, 56, 128, 8, 0)
    D.rect(4, 58, 18, 4, 1); D.px(10, 59, 9); D.px(14, 59, 6)
  end,
}

-------------------------------------------------------------------------------
-- LE FINESTRE ACCESE: cento vite di fronte
-------------------------------------------------------------------------------
S.finestre = {
  init = function(s)
    s.w = {}
    for r = 0, 3 do for c = 0, 5 do
      s.w[#s.w + 1] = { x = 42 + c * 14, y = 6 + r * 13, on = random() < 0.5, kind = random(5), t = R(5, 40), ph = R(0, 6) }
    end end
    s.fig = D.figura(18, 58, { s = KS, l = 2, dark = true, pose = "window", face = 1 })
  end,
  update = function(s, dt, t)
    local act = 1 + mac("voci") * 3
    for _, w in ipairs(s.w) do
      w.t = w.t - dt * act
      if w.t < 0 then w.on = not w.on; w.t = R(10, 50); w.kind = random(5) end
    end
    think(s.fig, function() return pick({ { { "pose", "window", R(10, 16) } }, { { "pose", "stand", 4 }, { "pose", "window", 6 } }, { { "pose", "head_down", 5 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local nt = mac("notte")
    D.rect(0, 0, 128, 64, 0)
    -- il palazzo di fronte
    D.rect(38, 2, 90, 58, 2 - nt)
    for _, w in ipairs(s.w) do
      local x, y = w.x, w.y
      if w.on then
        D.rect(x, y, 10, 9, 9)
        local p = t + w.ph
        if w.kind == 1 then
          -- qualcuno cucina
          D.circle(x + 3, y + 3, 1, 2); D.rect(x + 2, y + 4, 2, 5, 2); D.rect(x + 6, y + 6, 3, 1, 3)
          D.px(x + 7, y + 4 - (p * 2) % 2, 12)
        elseif w.kind == 2 then
          -- qualcuno piange, seduto
          D.circle(x + 5, y + 5, 1, 2); D.rect(x + 4, y + 6, 3, 3, 2)
        elseif w.kind == 3 then
          -- due che ballano
          local d = sin(p * 3) * 1
          D.circle(x + 3 + d, y + 2, 1, 2); D.rect(x + 2 + d, y + 3, 2, 6, 2)
          D.circle(x + 7 - d, y + 2, 1, 2); D.rect(x + 6 - d, y + 3, 2, 6, 2)
        elseif w.kind == 4 then
          -- la televisione accesa
          D.rect(x + 2, y + 4, 5, 4, 4 + D.noise(p * 5) * 6)
        else
          D.rect(x + 1, y + 1, 3, 8, 7)
        end
      else
        D.rect(x, y, 10, 9, 1)
      end
      D.rect(x, y + 9, 10, 1, 3)
    end
    -- la tua finestra: la cornice, tu di spalle
    D.rect(0, 0, 36, 64, 3)
    D.rect(4, 6, 28, 46, 1)
    D.rect(32, 0, 6, 64, 4)
    D.rect(4, 50, 30, 2, 5)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL CROCEVIA: quattro strade, i cartelli girati dal vento
-------------------------------------------------------------------------------
S.crocevia = {
  init = function(s)
    s.fig = D.figura(70, 52, { s = 1.15, l = 2, dark = true, pose = "stand", speed = 4, on_step = H.steps("ghiaia", 0.3) })
    s.sign = { 0, 1.2, 2.5, 3.9 }
    s.leaves = D.parts(20)
  end,
  update = function(s, dt, t)
    local w = mac("vento")
    for i = 1, 4 do s.sign[i] = s.sign[i] + dt * (0.05 + w * 0.4) * (i % 2 == 0 and 1 or -1) * (0.5 + D.noise(t * 0.3 + i)) end
    think(s.fig, function()
      local r = random()
      if r < 0.3 then return { { "face", -1 }, { "pose", "stand", R(2, 4) }, { "face", 1 }, { "pose", "stand", R(2, 4) } } end
      if r < 0.6 then return { { "walk", R(46, 60), 3 }, { "pose", "stand", 2 }, { "walk", 70, 3 }, { "face", 1 } } end
      if r < 0.8 then return { { "walk", R(80, 96), 3 }, { "pose", "stand", 2 }, { "walk", 70, 3 }, { "face", -1 } } end
      return { { "pose", "head_down", 5 }, { "pose", "look_up", 3 } }
    end)
    s.fig:update(dt)
    if random() < dt * (0.5 + w * 3) then D.spawn(s.leaves, { x = -4, y = R(36, 60), vx = R(14, 30) * (0.5 + w), vy = R(-2, 2), life = 8, ph = R(0, 6) }) end
    D.parts_update(s.leaves, dt)
  end,
  draw = function(s, t)
    local di = mac("distanza")
    D.gradient(0, 30, 3, 9 - di * 3)
    D.circle(30, 30, 7, 12)
    D.rect(0, 30, 128, 34, 4)
    -- le quattro strade: due diagonali, una dritta, una che torna
    D.poly({ 62, 30, 66, 30, 128, 50, 128, 58 }, 6)
    D.poly({ 62, 30, 66, 30, 0, 58, 0, 50 }, 6)
    D.poly({ 63, 30, 65, 30, 84, 64, 44, 64 }, 7)
    D.line(64, 30, 64, 64, 8)
    -- il palo con i cartelli
    D.rect(66, 30, 1, 22, 2)
    for i = 1, 4 do
      local a = s.sign[i]
      local y = 32 + i * 3
      local dx = cos(a) * 8
      D.thick(66, y, 66 + dx, y + sin(a) * 0.8, 1.6, 9 - i)
      D.px(66 + dx, y, 12)
    end
    for _, p in ipairs(s.leaves.list) do D.px(p.x, p.y + sin(t * 4 + p.ph) * 2, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA BIBLIOTECA DEI NOMI: scaffali fino al buio, i nomi che salgono
-------------------------------------------------------------------------------
local NOMI = { "Ada", "Pietro", "Lina", "Gino", "Rosa", "Ettore", "Nella", "Bruno", "Elvira", "Tonino", "Maria", "Aldo", "Iole", "Dante", "Wanda", "Massimo" }
S.biblioteca = {
  init = function(s)
    s.fig = D.figura(70, 58, { s = KS, l = 9, pose = "stand", speed = 4, on_step = H.steps("legno", 0.3),
      prop = function(x, y, f) if f.cur.fa1 > 80 and f.cur.ua1 < 60 then D.rect(x - 3, y - 4, 6, 5, 12); D.line(x, y - 4, x, y, 7) end end })
    s.words = D.parts(8)
    s.next = 4
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "walk", R(30, 100), 3 }, { "pose", "reach_up", 2 }, { "pose", "hold", R(6, 10) } } end
      if r < 0.7 then return { { "pose", "hold", R(8, 12) }, { "pose", "head_down", 3 } } end
      return { { "pose", "look_up", 5 } }
    end)
    s.fig:update(dt)
    s.next = s.next - dt * (0.5 + mac("ricordo"))
    if s.next < 0 then
      s.next = R(3, 7)
      D.spawn(s.words, { x = R(10, 100), y = R(30, 50), vx = R(-1, 1), vy = -R(2, 4), life = 7, w = pick(NOMI), l = 6 + mac("ricordo") * 5 })
    end
    D.float_words_update(s.words, dt)
  end,
  draw = function(s, t)
    local si = mac("silenzio")
    D.rect(0, 0, 128, 64, 0)
    -- gli scaffali in prospettiva, che salgono nel buio
    for side = -1, 1, 2 do
      for k = 0, 5 do
        local x = side < 0 and (k * 9) or (128 - k * 9 - 9)
        local l = 4 - k * 0.6
        D.rect(x, 0, 8, 58, l * 0.5)
        for y = 4, 54, 6 do
          D.rect(x, y, 8, 1, l)
          for b = 0, 3 do D.rect(x + b * 2, y - 4 + (b % 2), 1, 4 - (b % 2), l + (b % 3)) end
        end
      end
    end
    -- la scala a pioli, le candele
    D.line(84, 58, 92, 10, 5); D.line(90, 58, 98, 10, 5)
    for y = 14, 56, 6 do local k = (58 - y) / 48; D.line(84 + k * 8, y, 90 + k * 8, y, 5) end
    local cl = 9 - si * 4
    D.candle(30, 58, t, 6, 4, cl * 0.6)
    D.candle(106, 50, t + 2, 6, 3, cl * 0.5)
    D.rect(0, 58, 128, 6, 2)
    s.fig:draw()
    D.float_words_draw(s.words)
  end,
}

-------------------------------------------------------------------------------
-- LA SALA DI PROIEZIONE: il fascio, la polvere, quelli che salutano
-------------------------------------------------------------------------------
S.sala_proiezione = {
  init = function(s)
    s.motes = D.parts(30)
    s.jam = 0
    s.burn = 0
    s.fig = D.figura(80, 62, { s = KS, l = 3, dark = true, pose = "sit", face = -1 })
    s.people = {}
    for i = 1, 4 do s.people[i] = { x = 10 + i * 8, ph = R(0, 6), kind = random(3) } end
  end,
  update = function(s, dt, t)
    D.motes_update(s.motes, dt, 4, { 30, 8, 90, 30 }, t)
    if s.jam <= 0 and random() < dt * 0.01 then s.jam = 6; s.burn = 0 end
    if s.jam > 0 then s.jam = s.jam - dt; s.burn = s.burn + dt end
    think(s.fig, function() return pick({ { { "pose", "sit", R(10, 16) } }, { { "pose", "sit_think", R(6, 10) } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ri = mac("ricordo")
    D.rect(0, 0, 128, 64, 0)
    -- lo schermo
    local fl = s.jam > 0 and 12 or (9 + D.noise(t * 12) * 3)
    D.rect(4, 8, 46, 30, fl)
    if s.jam <= 0 then
      for i, p in ipairs(s.people) do
        local tt = t * 2 + p.ph
        local x = p.x + sin(t * 0.3 + i) * 3
        D.circle(x, 20, 2, 3); D.rect(x - 1.5, 22, 3, 8, 3)
        if p.kind == 1 then D.line(x + 1, 23, x + 4, 18 + sin(tt * 3) * 2, 3)
        elseif p.kind == 2 then D.line(x - 1, 30, x - 2 + sin(tt * 4), 34, 3); D.line(x + 1, 30, x + 2 - sin(tt * 4), 34, 3)
        else D.line(x - 1, 23, x - 3, 27 + sin(tt * 2), 3) end
      end
      for i = 1, 3 do local x = 4 + (floor(t * 7 * i) * 13) % 46; D.line(x, 8, x, 37, fl - 3) end
    else
      for i, p in ipairs(s.people) do D.circle(p.x, 20, 2, 3); D.rect(p.x - 1.5, 22, 3, 8, 3); D.line(p.x + 1, 23, p.x + 4, 18, 3) end
      local r = s.burn * 4
      D.circle(27, 23, r + 2, 6); D.circle(27, 23, r, 15)
    end
    -- il fascio dal proiettore
    D.poly({ 118, 10, 120, 12, 50, 38, 50, 8 }, 2)
    D.motes_draw(s.motes, 8 + ri * 4)
    D.rect(116, 6, 10, 8, 3); D.px(117, 11, 15)
    -- le poltrone vuote
    for r = 0, 1 do for i = 0, 9 do local x = 8 + i * 12 + r * 6; D.rect(x, 48 + r * 8, 9, 10, 1 + r); D.rect(x, 47 + r * 8, 9, 1, 2 + r) end end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA CASA ABBANDONATA: il calendario fermo a marzo, la tavola per sei
-------------------------------------------------------------------------------
S.casa_abbandonata = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = KS, l = 8, speed = 3, on_step = H.steps("legno", 0.3) })
    s.drip = { y = 8 }
    s.rip = 0
    s.curt = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      return { { "walk", 40, 3 }, { "pose", "look_up", 3 }, { "walk", 74, 3 }, { "pose", "trace", 3 }, { "pose", "head_down", 5 },
        { "walk", R(90, 110), 3 }, { "pose", "stand", 4 }, { "walk", -10, 4 }, { "wait", R(4, 10) } }
    end)
    s.fig:update(dt)
    s.drip.y = s.drip.y + dt * 30
    if s.drip.y > 56 then s.drip.y = 8; s.rip = 1; S.env.sfx("drop", 1400, 0.015, 0.2, 0.5, 0.5, 0.001) end
    s.rip = max(0, s.rip - dt * 1.5)
    s.curt = s.curt + dt * (0.5 + mac("vento") * 3)
  end,
  draw = function(s, t)
    local w = mac("vento")
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "fiori", ceil = 4 }, t)
    -- la carta che si stacca a lembi
    for i = 0, 5 do
      local x = 6 + i * 21
      D.poly({ x, 4, x + 5, 4, x + 4 + sin(t * 0.6 + i) * w * 2, 12 + (i % 3) * 5, x + 1, 10 + (i % 3) * 5 }, 5)
      D.rect(x, 4, 5, 6 + (i % 3) * 5, 1)
    end
    -- la finestra rotta, la tenda nel vento
    K.window(96, 12, 18, 18, K.views.night, t, s, 4)
    D.line(100, 14, 106, 22, 6); D.line(106, 22, 104, 28, 6)
    local c = sin(s.curt) * (2 + w * 5)
    D.poly({ 94, 10, 99, 10, 99 + c, 34, 93 + c * 0.6, 34 }, 7)
    -- il calendario fermo a marzo
    D.rect(18, 16, 12, 14, 10); D.rect(18, 16, 12, 3, 6)
    for y = 21, 28, 2 do for x = 19, 28, 2 do D.px(x, y, 4) end end
    txt(17, 37, S.H.lang() == 1 and "marzo" or "march", 5)
    -- la tavola per sei, le sedie cadute, una sola in piedi
    local ty = K.table(48, 58, 2.6, 3, 5)
    for i = 0, 5 do D.rect(52 + i * 5.5, ty - 1, 4, 1, 9) end
    K.chair(66, 58, 1, 4)
    D.poly({ 42, 57, 46, 55, 50, 58, 44, 58 }, 3); D.line(44, 56, 40, 50, 3)
    D.poly({ 88, 57, 96, 57, 96, 55, 88, 55 }, 3); D.line(96, 56, 100, 52, 3)
    -- la goccia dal soffitto e la pozza
    D.px(30, s.drip.y, 10)
    D.rect(24, 58, 12, 1, 4)
    if s.rip > 0 then D.ripple(30, 59, (1 - s.rip) * 6, 8 * s.rip) end
    local ra = mac("radio")
    K.radio(108, 44, 3, t)
    if ra > 0.1 then D.px(110, 40, 5 + ra * 8 * D.noise(t * 9)) end
    D.rect(104, 44, 16, 2, 4); D.rect(106, 46, 2, 12, 3)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ATTESA: le nove e venti, il telefono che non suona
-------------------------------------------------------------------------------
S.attesa = {
  init = function(s)
    s.fig = D.figura(38, 58, { s = KS, l = 9, pose = "window", face = 1, speed = 4, on_step = H.steps("pietra", 0.3) })
    s.rain = {}
    s.pass = nil
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.4 then return { { "walk", 38, 3 }, { "face", 1 }, { "pose", "window", R(8, 14) } } end
      if r < 0.75 then return { { "walk", 78, 3 }, { "face", 1 }, { "pose", "sit", 1 }, { "pose", "sit_think", R(6, 10) }, { "pose", "head_down", 4 } } end
      return { { "walk", 60, 3 }, { "pose", "stand", 3 }, { "pose", "head_down", 3 } }
    end)
    s.fig:update(dt)
    if not s.pass and random() < dt * 0.06 then s.pass = { x = 0, v = R(4, 7) } end
    if s.pass then
      local o = s.pass.x
      s.pass.x = s.pass.x + s.pass.v * dt
      if floor(o / 2) ~= floor(s.pass.x / 2) then S.env.step("pietra", -0.3, 0.15) end
      if s.pass.x > 30 then s.pass = nil end
    end
  end,
  draw = function(s, t)
    local tm = mac("tempo")
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "righe", ceil = 4 }, t)
    -- la finestra sulla strada: il lampione, chi passa e non è lei
    local v = mac("pioggia") > 0.2 and K.views.rain or K.views.night
    K.window(46, 12, 30, 24, v, t, s.rain, 5)
    D.rect(70, 14, 1, 20, 6); D.px(70, 14, 14)
    if s.pass then local x = 48 + s.pass.x; D.circle(x, 28, 1, 2); D.rect(x - 1, 29, 2, 5, 2) end
    -- l'orologio: le nove e venti, e poi di più
    local m = 20 + t / 60 * (1 + tm * 20)
    local cx, cy = 100, 16
    D.circle(cx, cy, 6, 6); D.circle(cx, cy, 5, 2)
    local am = m / 60 * 2 * pi
    local ah = (9 + m / 60) / 12 * 2 * pi
    D.line(cx, cy, cx + sin(am) * 4, cy - cos(am) * 4, 12)
    D.line(cx, cy, cx + sin(ah) * 3, cy - cos(ah) * 3, 10)
    -- il tavolo: due tazze, il telefono
    local ty = K.table(82, 58, 1.4, 4, 6)
    D.rect(88, ty - 3, 3, 3, 10); D.rect(94, ty - 3, 3, 3, 10)
    D.rect(100, ty - 3, 6, 3, 2); D.rect(100, ty - 4, 6, 1, 3)
    K.chair(80, 58, 1, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE FOTOGRAFIE: la scatola, i sorrisi, "felici"
-------------------------------------------------------------------------------
S.fotografie = {
  init = function(s)
    s.fig = D.figura(46, 58, { s = KS, l = 9, pose = "sit_read", face = 1,
      prop = function(x, y, f) if f.cur.fa1 > 100 then D.rect(x - 4, y - 6, 8, 7, 12); D.rect(x - 3, y - 5, 6, 4, 5); D.circle(x, y - 3, 1, 11) end end })
    s.ph = {}
    for i = 1, 9 do s.ph[i] = { x = R(60, 104), y = R(36, 42), a = R(-0.5, 0.5), k = random(4) } end
    s.motes = D.parts(16)
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.6 then return { { "pose", "sit_read", R(8, 14) }, { "fn", function() local p = s.ph[random(#s.ph)]; p.x = R(60, 104); p.a = R(-0.5, 0.5); p.k = random(4) end } } end
      if r < 0.85 then return { { "pose", "sit_think", R(6, 10) } } end
      return { { "pose", "sit", 3 }, { "pose", "head_down", 5 } }
    end)
    s.fig:update(dt)
    D.motes_update(s.motes, dt, 1.5, { 20, 6, 60, 30 }, t)
  end,
  draw = function(s, t)
    local ri = mac("ricordo")
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "puntini", ceil = 4 }, t)
    K.lamp(30, 58, 4, 1 + ri, t)
    -- il tavolo con la scatola e le fotografie sparse
    local ty = K.table(56, 58, 3.6, 4)
    D.rect(98, ty - 6, 16, 6, 6); D.rect(98, ty - 7, 16, 1, 8)
    for _, p in ipairs(s.ph) do
      local c, sn = cos(p.a), sin(p.a)
      local function pt(dx, dy) return p.x + dx * c - dy * sn, ty - 1 + dx * sn * 0.3 + dy * 0.3 end
      local ax, ay = pt(-4, -3); local bx, by = pt(4, -3); local cx, cy = pt(4, 3); local dx, dy = pt(-4, 3)
      D.poly({ ax, ay - 2, bx, by - 2, cx, cy - 2, dx, dy - 2 }, 11)
      D.px(p.x, ty - 3, 4 + p.k)
    end
    K.chair(46, 58, 1, 4)
    D.motes_draw(s.motes, 9)
    s.fig:draw()
    if ri > 0.5 then txt(64, 30, S.H.lang() == 1 and "felici" or "happy", (ri - 0.5) * 14, true) end
  end,
}

-------------------------------------------------------------------------------
-- IL RIPOSTIGLIO: le scatole, la bicicletta senza ruote, NON BUTTARE
-------------------------------------------------------------------------------
S.ripostiglio = {
  init = function(s)
    s.fig = D.figura(36, 58, { s = KS, l = 9, pose = "stand", speed = 3, on_step = H.steps("legno", 0.25),
      prop = function(x, y, f) if s.holding then D.circle(x, y - 1, 1.5, 14) end end })
    s.holding = false
    s.sw = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      return { { "walk", R(50, 70), 3 }, { "pose", "bend", 3 }, { "fn", function() s.holding = true end }, { "pose", "hold", R(6, 10) },
        { "pose", "head_down", 3 }, { "pose", "bend", 2 }, { "fn", function() s.holding = false end }, { "pose", "stand", 2 }, { "walk", R(20, 40), 3 }, { "pose", "look_up", 4 } }
    end)
    s.fig:update(dt)
    s.sw = s.sw + dt
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 1)
    -- la lampadina nuda che oscilla
    local sx = sin(s.sw * 0.9) * 4
    D.line(64, 0, 64 + sx, 12, 3)
    D.circle(64 + sx, 13, 1.5, 15)
    D.poly({ 64 + sx - 2, 14, 64 + sx + 2, 14, 64 + sx * 2 + 30, 58, 64 + sx * 2 - 30, 58 }, 2)
    -- le scatole ammassate
    local boxes = { { 4, 40, 18, 18 }, { 6, 26, 16, 14 }, { 8, 16, 12, 10 }, { 90, 42, 20, 16 }, { 112, 34, 16, 24 }, { 94, 30, 14, 12 }, { 60, 46, 48, 12 } }
    for i, b in ipairs(boxes) do
      D.rect(b[1], b[2], b[3], b[4], 4 + (i % 3))
      D.rect(b[1] + b[3] / 2 - 1, b[2], 2, b[4], 6 + (i % 2))
    end
    txt(84, 55, S.H.lang() == 1 and "NON BUTTARE" or "KEEP", 11, true)
    -- la bicicletta senza ruote appesa, il ventilatore, il sacco
    D.line(30, 6, 46, 6, 4); D.line(30, 6, 34, 14, 4); D.line(46, 6, 44, 14, 4); D.line(34, 14, 44, 14, 4); D.line(38, 4, 38, 0, 3)
    D.circle(118, 22, 4, 4, true); D.line(118, 18, 118, 26, 3); D.line(114, 22, 122, 22, 3); D.line(118, 26, 118, 34, 4)
    D.poly({ 30, 58, 44, 58, 42, 46, 32, 46 }, 3); D.line(36, 46, 38, 44, 4)
    D.rect(0, 58, 128, 6, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- PRIMA DI DORMIRE: il soffitto, i fari che passano, i numeri
-------------------------------------------------------------------------------
S.prima_dormire = {
  init = function(s)
    s.fig = D.figura(46, 46, { s = KS, l = 6, pose = "lie" })
    s.car = nil
    s.n = 0
    s.words = D.parts(4)
    s.br = 0
  end,
  update = function(s, dt, t)
    s.br = s.br + dt * (0.6 + (1 - mac("respiro")) * 0.6)
    if not s.car and random() < dt * (0.05 + mac("notte") * 0.05) then s.car = { k = 0, dir = pick({ -1, 1 }) } end
    if s.car then
      s.car.k = s.car.k + dt * 0.35
      if s.car.k > 1 then
        s.car = nil; s.n = s.n + 1
        if s.n > 9 then s.n = 1 end
        local nums = S.H.lang() == 1 and { "uno", "due", "tre", "quattro", "cinque", "sei", "sette", "otto", "nove" } or { "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" }
        D.spawn(s.words, { x = R(30, 80), y = 18, vx = 0, vy = -1, life = 5, w = nums[s.n], l = 6 })
      end
    end
    D.float_words_update(s.words, dt)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    D.rect(0, 0, 128, 12, 1)
    -- i fari che attraversano il soffitto
    if s.car then
      local k = s.car.k
      local x = s.car.dir > 0 and (-30 + k * 190) or (160 - k * 190)
      D.poly({ x, 0, x + 18, 0, x + 26, 12, x + 8, 12 }, 8 * sin(k * pi))
      D.poly({ x + 8, 12, x + 26, 12, x + 34, 40, x + 20, 40 }, 3 * sin(k * pi))
    end
    -- la finestra con la tenda
    D.rect(96, 14, 18, 20, 1); D.rect(94, 12, 22, 2, 2)
    D.poly({ 96, 14, 104, 14, 102 + sin(t * 0.3), 34, 96, 34 }, 2)
    -- il letto, lui sotto la coperta che respira
    K.bed(18, 58, 3.6, 2, 3)
    s.fig:draw()
    local b = sin(s.br) * 0.8
    D.poly({ 34, 50 - b, 64, 49 - b, 64, 52, 34, 52 }, 3)
    D.float_words_draw(s.words)
  end,
}

-------------------------------------------------------------------------------
-- LA CASA VUOTA: i tubi che bussano, le chiavi sul tavolo, le voci
-------------------------------------------------------------------------------
S.casa_vuota = {
  init = function(s)
    s.fig = D.figura(100, 58, { s = KS, l = 9, pose = "stand", face = -1, speed = 3, on_step = H.steps("legno", 0.25) })
    s.knock = 0
    s.quiet = 0
    s.ghosts = {}
    s.ghosts[1] = D.figura(42, 58, { s = KS, l = 4, pose = "sit", face = 1 })
    s.ghosts[2] = D.figura(70, 58, { s = KS, l = 4, pose = "talk", face = -1, bun = true, dress = true })
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      return { { "walk", R(80, 112), 3 }, { "pose", "stand", R(4, 8) }, { "face", -1 }, { "pose", "head_down", 4 }, { "pose", "look_up", 3 } }
    end)
    s.fig:update(dt)
    for _, g in ipairs(s.ghosts) do g:update(dt) end
    s.knock = s.knock - dt
    if s.knock < 0 then s.knock = R(6, 18); s.kt = 0.6; S.env.sfx("step", 900, 0.05, 0.05, -0.6, 0.6, 0) end
    s.kt = max(0, (s.kt or 0) - dt)
    if s.quiet <= 0 and random() < dt * (0.02 + mac("silenzio") * 0.05) then s.quiet = 6 end
    s.quiet = max(0, s.quiet - dt)
  end,
  draw = function(s, t)
    local vo = mac("voci")
    K.room({ wall = 3, fy = 58, floor = "assi", floor_l = 2, paper = "righe", ceil = 4 }, t)
    -- i tubi sul muro, che bussano
    local sh = (s.kt > 0) and sin(t * 60) * 0.6 or 0
    D.rect(4 + sh, 4, 2, 54, 5); D.rect(4 + sh, 20, 18, 2, 5); D.rect(20 + sh, 20, 2, 38, 5)
    -- il frigorifero che ronza
    D.rect(108, 26, 14, 32, 6); D.line(108, 38, 121, 38, 4); D.rect(110, 30, 1, 5, 9)
    D.px(118, 28, s.quiet > 0 and 2 or 12)
    -- l'attaccapanni coi cappotti
    D.line(30, 12, 30, 58, 4); D.rect(26, 12, 9, 1, 5)
    D.poly({ 27, 13, 31, 13, 32, 30, 26, 30 }, 3)
    -- il tavolo con le chiavi
    local ty = K.table(46, 58, 2.2, 4)
    D.circle(64, ty - 1, 1.2, 12, true); D.line(65, ty - 1, 68, ty - 1, 12)
    K.chair(42, 58, 1, 4); K.chair(80, 58, -1, 4)
    -- quando tutto tace, tornano loro, appena
    local ga = (s.quiet > 0 and min(1, s.quiet / 2, (6 - s.quiet) / 1) or 0) + vo * 0.3
    if ga > 0.05 then
      for _, g in ipairs(s.ghosts) do g.l = 2 + ga * 6; g:draw() end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA VEGLIA: il respiro, il monitor, la sedia scomoda
-------------------------------------------------------------------------------
S.veglia = {
  init = function(s)
    s.pat = D.figura(54, 44, { s = KS, l = 6, pose = "lie" })
    s.fig = D.figura(96, 58, { s = KS, l = 8, pose = "sit_think", face = -1 })
    s.trace = {}
    for i = 1, 30 do s.trace[i] = 0 end
    s.ph = 0
    s.rain = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_think", R(8, 14) } }, { { "pose", "sit_slump", R(6, 10) } }, { { "pose", "sit", 4 }, { "pose", "head_down", 4 } } }) end)
    s.fig:update(dt); s.pat:update(dt)
    local rate = 1.1 + mac("battito") * 0.8
    local o = s.ph
    s.ph = s.ph + dt * rate
    s.acc = (s.acc or 0) + dt * 12
    while s.acc > 1 do
      s.acc = s.acc - 1
      table.remove(s.trace, 1)
      local f = s.ph % 1
      s.trace[#s.trace + 1] = (f < 0.08) and -5 or ((f < 0.14) and 3 or 0)
    end
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "piastrelle", floor_l = 2, ceil = 4 }, t)
    local v = mac("pioggia") > 0.2 and K.views.rain or K.views.night
    K.window(12, 12, 22, 20, v, t, s.rain, 4)
    -- il letto d'ospedale, la flebo
    D.rect(30, 46, 50, 4, 5); D.rect(32, 50, 2, 8, 4); D.rect(76, 50, 2, 8, 4)
    D.rect(28, 36, 2, 14, 5)
    D.line(84, 10, 84, 58, 5); D.rect(82, 10, 5, 7, 9); D.line(84, 17, 70, 42, 4)
    s.pat:draw()
    D.poly({ 36, 46, 78, 46, 78, 43, 40, 42 }, 7)
    -- il monitor
    D.rect(92, 16, 26, 16, 1); D.rect(91, 15, 28, 1, 4)
    for i = 2, #s.trace do D.line(92 + (i - 2) * 0.86, 25 + s.trace[i - 1], 92 + (i - 1) * 0.86, 25 + s.trace[i], 11) end
    K.chair(96, 58, -1, 4)
    s.fig:draw()
    -- la lampada piccola
    D.rect(112, 44, 6, 1, 10); D.line(115, 44, 115, 58, 3)
  end,
}

-------------------------------------------------------------------------------
-- L'ULTIMO RESPIRO: la mano, il respiro che si allunga
-------------------------------------------------------------------------------
S.ultimo_respiro = {
  init = function(s)
    s.pat = D.figura(56, 44, { s = KS, l = 6, pose = "lie" })
    s.fig = D.figura(88, 58, { s = KS, l = 8, pose = "hold_hand", face = -1 })
    s.br = 0
    s.len = 4
  end,
  update = function(s, dt, t)
    s.len = 4 + (1 - mac("respiro")) * 6
    s.br = s.br + dt * 2 * pi / s.len
    think(s.fig, function() return pick({ { { "pose", "hold_hand", R(10, 16) } }, { { "pose", "pray", 6 }, { "pose", "hold_hand", 6 } } }) end)
    s.fig:update(dt); s.pat:update(dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- la porta socchiusa sul corridoio
    D.rect(4, 10, 16, 48, 1); D.rect(4, 10, 5, 48, 9)
    D.poly({ 9, 58, 4, 58, 20, 64, 34, 64 }, 4)
    D.rect(0, 58, 128, 6, 1)
    -- il letto
    D.rect(30, 46, 56, 4, 3); D.rect(32, 50, 2, 8, 2); D.rect(82, 50, 2, 8, 2)
    D.rect(28, 36, 2, 14, 3)
    s.pat:draw()
    local b = (sin(s.br) * 0.5 + 0.5) ^ 2 * 1.4
    D.poly({ 38, 46, 84, 46, 84, 43 - b * 0.5, 44, 42 - b }, 5)
    s.fig:draw()
    -- le due mani, insieme, sul lenzuolo
    D.circle(79, 44, 1.4, 12)
  end,
}

-------------------------------------------------------------------------------
-- VENTICINQUE ANNI DOPO: il muro dei loculi, le foto ovali
-------------------------------------------------------------------------------
S.venticinque = {
  init = function(s)
    s.fig = D.figura(70, 58, { s = 1.25, l = 2, dark = true, pose = "stand", speed = 3, on_step = H.steps("ghiaia", 0.3) })
    s.lamps = {}
    for i = 1, 12 do s.lamps[i] = R(0, 6) end
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.45 then return { { "walk", R(54, 80), 3 }, { "face", -1 }, { "pose", "wipe", 2 }, { "pose", "wipe", 2 }, { "pose", "head_down", 5 } } end
      if r < 0.8 then return { { "pose", "stand", R(6, 10) }, { "pose", "look_up", 3 } } end
      return { { "walk", R(20, 110), 3 }, { "pose", "stand", 4 } }
    end)
    s.fig:update(dt)
    if s.fig.cur.ua1 > 110 then s.fig.cur.fa1 = 140 + sin(t * 8) * 25 end
  end,
  draw = function(s, t)
    local w, ri = mac("vento"), mac("ricordo")
    D.gradient(0, 10, 6, 8)
    -- il muro dei loculi
    D.rect(0, 6, 128, 50, 8)
    local i = 0
    for r = 0, 3 do for c = 0, 7 do
      i = i + 1
      local x, y = 2 + c * 16, 8 + r * 12
      D.rect(x, y, 14, 11, 10); D.rect(x, y, 14, 1, 11)
      -- la foto ovale
      D.circle(x + 4, y + 5, 2.2, 4 + ri * 3)
      D.px(x + 4, y + 4, 9 + ri * 4)
      -- il lumino e i fiori di plastica sbiaditi
      D.px(x + 10, y + 8, (D.noise(t * 3 + i) > 0.4) and 13 or 7)
      D.px(x + 12 + sin(t + i) * w, y + 6, 6); D.px(x + 11, y + 5 + sin(t * 1.3 + i) * w * 0.5, 5)
    end end
    D.rect(0, 56, 128, 8, 5)
    for k = 0, 30 do D.px((k * 41) % 128, 57 + (k * 3) % 6, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- AMORE NON CORRISPOSTO: di là ridono, tu scrivi e cancelli
-------------------------------------------------------------------------------
S.amore = {
  init = function(s)
    s.fig = D.figura(30, 58, { s = KS, l = 7, pose = "sit_ground", face = 1,
      prop = function(x, y) D.rect(x - 1, y - 3, 3, 4, 13) end })
    s.dancers = {}
    for i = 1, 5 do s.dancers[i] = { x = R(78, 116), ph = R(0, 6), sp = R(2, 4) } end
    s.msg = 0; s.count = 11; s.del = false
    s.rain = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(8, 12) } }, { { "pose", "sit_think", R(6, 10) } }, { { "pose", "cry", 4 }, { "pose", "sit_ground", 4 } } }) end)
    s.fig:update(dt)
    s.fig.cur.fa1 = max(s.fig.cur.fa1, 100); s.fig.cur.ua1 = max(s.fig.cur.ua1, 50)
    s.msg = s.msg + dt * (s.del and -1.5 or 0.9)
    if s.msg > 1 then s.del = true end
    if s.msg < 0 then s.msg = 0; s.del = false; s.count = s.count + 1; if s.count > 30 then s.count = 11 end end
  end,
  draw = function(s, t)
    local fo = mac("folla")
    D.rect(0, 0, 128, 64, 0)
    K.window(8, 12, 18, 18, mac("pioggia") > 0.2 and K.views.rain or K.views.night, t, s.rain, 3)
    -- la porta socchiusa sulla festa
    D.rect(70, 8, 52, 50, 10)
    local n = 2 + floor(fo * 3)
    for i = 1, n do
      local d = s.dancers[i]
      local x = d.x + sin(t * 0.4 + d.ph) * 4
      local bob = abs(sin(t * d.sp + d.ph)) * 2
      D.circle(x, 28 - bob, 2, 4); D.rect(x - 1.5, 30 - bob, 3, 10, 4)
      D.line(x - 1, 40 - bob, x - 2 + sin(t * d.sp) * 2, 50, 4); D.line(x + 1, 40 - bob, x + 2 - sin(t * d.sp) * 2, 50, 4)
      D.line(x + 1, 31 - bob, x + 4, 26 - bob + sin(t * d.sp * 2) * 2, 4)
    end
    D.rect(66, 6, 4, 52, 3); D.rect(122, 6, 6, 52, 3)
    D.poly({ 70, 58, 122, 58, 110, 64, 40, 64 }, 4)
    D.rect(0, 58, 128, 6, 1)
    D.poly({ 70, 58, 122, 58, 100, 64, 50, 64 }, 4)
    s.fig:draw()
    -- il messaggio che si scrive e si cancella
    local w = floor(s.msg * 22)
    D.rect(36, 30, 26, 9, 3)
    if w > 0 then D.rect(38, 33, w, 1, 11); if w > 10 then D.rect(38, 35, w - 10, 1, 11) end end
    if floor(t * 2) % 2 == 0 then D.rect(38 + w, 33, 1, 3, 13) end
    txt(64, 38, tostring(s.count), 4)
  end,
}

-------------------------------------------------------------------------------
-- IL DUBBIO: le strade che si dividono, le ombre che provano
-------------------------------------------------------------------------------
S.dubbio = {
  init = function(s)
    s.fig = D.figura(64, 56, { s = 1.2, l = 11, pose = "stand" })
    s.ghosts = {}
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      return { { "face", -1 }, { "pose", "stand", R(1.5, 3) }, { "face", 1 }, { "pose", "stand", R(1.5, 3) }, { "pose", "head_down", 3 } }
    end)
    s.fig:update(dt)
    local ne = mac("nevrosi")
    if random() < dt * (0.2 + ne * 0.8) then
      local side = pick({ -1, 1 })
      local g = D.figura(64, 56, { s = 1.2, l = 5, speed = 5 + ne * 6 })
      local path = { { -1, 30 }, { 1, 30 }, { -1, 50 }, { 1, 50 } }
      local p = path[random(4)]
      g:act({ { "walk", 64 + p[1] * 34, 5 + ne * 6, 56 - p[2] * 0.6 }, { "pose", "stand", 1 } })
      g.life = 4
      s.ghosts[#s.ghosts + 1] = g
    end
    for i = #s.ghosts, 1, -1 do
      local g = s.ghosts[i]
      g:update(dt); g.life = g.life - dt
      if g.life <= 0 then table.remove(s.ghosts, i) end
    end
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    -- l'albero delle strade: si dividono, e si dividono ancora
    local function branch(x, y, len, a, d)
      if d > 4 then return end
      for _, sg in ipairs({ -1, 1 }) do
        local na = a + sg * (0.5 - d * 0.06)
        local x2, y2 = x + sin(na) * len, y - cos(na) * len
        D.line(x, y, x2, y2, 7 - d * 1.3)
        branch(x2, y2, len * 0.66, na, d + 1)
      end
    end
    D.line(64, 64, 64, 56, 8)
    branch(64, 56, 20, 0, 0)
    for _, g in ipairs(s.ghosts) do g.l = 1 + max(0, g.life) * 1.4; g:draw() end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- I VOLTI CHE NON RICORDI: le cornici, i volti che vanno e vengono
-------------------------------------------------------------------------------
S.volti = {
  init = function(s)
    s.fig = D.figura(64, 58, { s = KS, l = 9, pose = "stand", speed = 3, on_step = H.steps("pietra", 0.3),
      prop = function(x, y, f) if f.cur.fa1 > 80 then D.rect(x - 3, y - 5, 6, 6, 12); D.circle(x, y - 2, 1.5, 6) end end })
    s.ph = {}
    for i = 1, 5 do s.ph[i] = R(0, 6) end
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local r = random()
      if r < 0.5 then return { { "walk", 10 + random(0, 4) * 24 + 10, 3 }, { "pose", "look_up", R(4, 7) } } end
      if r < 0.8 then return { { "pose", "hold", R(6, 10) }, { "pose", "head_down", 3 } } end
      return { { "pose", "stand", 5 } }
    end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local ne, ri = mac("nebbia"), mac("ricordo")
    K.room({ wall = 4, fy = 58, floor = "pietra", floor_l = 3, ceil = 4 }, t)
    for i = 0, 4 do
      local x = 8 + i * 24
      D.rect(x, 12, 18, 22, 7); D.rect(x + 1, 13, 16, 20, 2)
      -- il volto: la testa resta, i tratti vanno e vengono
      D.circle(x + 9, 21, 5, 5)
      D.rect(x + 3, 27, 12, 6, 5)
      local k = (0.5 + 0.5 * sin(t * 0.15 + s.ph[i + 1])) * (1 - ne) + ri * 0.4
      if k > 0.45 then
        local l = (k - 0.45) * 14
        D.px(x + 7, 20, l); D.px(x + 11, 20, l); D.line(x + 8, 24, x + 10, 24, l)
      end
      -- la sciarpa, la risata: le cose che restano
      if i == 2 then D.rect(x + 4, 26, 10, 2, 10); D.rect(x + 11, 28, 2, 4, 10) end
    end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA VITA CHE NON HAI AVUTO: di là dal muro, una famiglia a tavola
-------------------------------------------------------------------------------
S.vita_mai = {
  init = function(s)
    s.fig = D.figura(22, 58, { s = KS, l = 6, pose = "sit_slump", face = 1 })
    s.mom = D.figura(72, 58, { s = KS, l = 3, dark = true, pose = "sit", face = 1, dress = true, bun = true })
    s.dad = D.figura(112, 58, { s = KS, l = 3, dark = true, pose = "sit", face = -1 })
    s.kid = D.figura(92, 58, { s = KS * 0.7, l = 3, dark = true, pose = "sit", face = -1, child = true })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_slump", R(8, 14) } }, { { "pose", "sit_think", R(6, 10) } }, { { "pose", "sit_ground", 3 }, { "pose", "look_up", 4 }, { "pose", "sit_slump", 4 } } }) end)
    for _, f in ipairs({ s.mom, s.dad, s.kid }) do
      think(f, function() return pick({ { { "pose", "sit", R(3, 6) } }, { { "pose", "talk", R(2, 4) }, { "pose", "sit", 2 } } }) end)
      f:update(dt)
    end
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local warm, di = mac("calore"), mac("distanza")
    -- di qua, il buio
    D.rect(0, 0, 128, 64, 0)
    D.rect(0, 58, 50, 6, 1)
    -- di là, la cucina calda
    local l = 8 + warm * 4 - di * 4
    D.rect(56, 8, 72, 50, l)
    D.rect(56, 50, 72, 8, l - 2)
    D.rect(92, 8, 1, 6, l - 4); D.rect(89, 14, 7, 3, 15)
    local ty = 46
    D.rect(66, ty, 56, 2, l - 5); D.rect(70, ty + 2, 2, 10, l - 5); D.rect(116, ty + 2, 2, 10, l - 5)
    s.mom:draw(); s.dad:draw(); s.kid:draw()
    -- il muro, spesso quanto la distanza
    local w = 4 + di * 8
    D.rect(50, 0, w, 64, 2)
    D.rect(50 + w - 1, 0, 1, 64, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE CRIPTE: volte basse, ossa in ordine, una candela accesa
-------------------------------------------------------------------------------
S.cripta = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = 1.25, l = 8, speed = 2.5, on_step = H.steps("pietra", 0.35),
      prop = function(x, y) D.candle(x, y, s.t or 0, 7, 2, 4) end })
    s.t = 0
  end,
  update = function(s, dt, t)
    s.t = t
    think(s.fig, function() return { { "walk", R(40, 70), 2.5 }, { "pose", "carry", R(4, 7) }, { "walk", 140, 2.5 }, { "fn", function(f) f.x = -6 end }, { "wait", R(3, 8) } } end)
    s.fig:update(dt)
    s.fig.cur.ua1 = max(s.fig.cur.ua1, 40); s.fig.cur.fa1 = max(s.fig.cur.fa1, 90)
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    D.rect(0, 0, 128, 64, 0)
    -- le volte basse
    for i = 0, 4 do
      local x = i * 32 - 4
      D.rect(x, 14, 4, 44, 3)
      screen.level(D.lv(3)); screen.move(x + 4, 20); screen.curve(x + 10, 6, x + 22, 6, x + 28, 20); screen.stroke()
      -- le ossa in ordine nelle nicchie
      for r = 0, 2 do for c = 0, 3 do
        local bx, by = x + 8 + c * 5, 24 + r * 9
        D.circle(bx, by, 1.6, 5); D.px(bx - 0.5, by, 1); D.px(bx + 1, by, 1)
        D.line(bx - 2, by + 4, bx + 2, by + 4, 4)
      end end
    end
    D.rect(0, 58, 128, 6, 2)
    -- l'altare con la candela che nessuno ha acceso
    D.rect(108, 48, 16, 10, 4)
    D.candle(116, 48, t, 9, 4, 4 + fu * 6)
    local hx = s.fig.hand[1]
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA FABBRICA CHIUSA: il cancello, i fiori secchi, la fotografia
-------------------------------------------------------------------------------
S.fabbrica = {
  init = function(s)
    s.fig = D.figura(-6, 58, { s = 1.2, l = 2, dark = true, speed = 3, on_step = H.steps("ghiaia", 0.3) })
    s.drip = 10
    s.mem = 0
    s.stars = D.stars_gen(20, 4, 0, 14)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 66, 3 }, { "pose", "stand", 3 }, { "pose", "kneel_one", 6 }, { "pose", "stand", 3 }, { "pose", "look_up", 4 }, { "walk", -10, 3 }, { "wait", R(4, 9) } } end)
    s.fig:update(dt)
    s.drip = s.drip - dt
    if s.drip < 0 then s.drip = R(3, 6); S.env.sfx("drop", 2200, 0.012, 0.15, 0.4, 0.6, 0.001) end
    if s.mem <= 0 and random() < dt * mac("profondita") * 0.05 then s.mem = 5 end
    s.mem = max(0, s.mem - dt)
  end,
  draw = function(s, t)
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 0.6)
    -- i capannoni enormi e muti
    for i = 0, 2 do
      local x = 20 + i * 36
      D.poly({ x, 44, x, 20, x + 16, 12, x + 34, 20, x + 34, 44 }, 2)
      for k = 0, 2 do
        local lit = s.mem > 0 and (D.noise(t * 4 + i * 3 + k) > 0.4)
        D.rect(x + 4 + k * 10, 26, 6, 6, lit and 10 or 1)
        if not lit and k == 1 then D.line(x + 15, 26, x + 18, 31, 3) end
      end
    end
    D.rect(108, 4, 5, 40, 2); D.rect(107, 4, 7, 2, 3)
    -- la recinzione e il cancello
    D.rect(0, 44, 128, 14, 1)
    for x = 0, 127, 4 do D.line(x, 34, x, 58, 3) end
    D.line(0, 34, 127, 34, 4); D.line(0, 46, 127, 46, 3)
    D.rect(60, 32, 2, 26, 5); D.rect(84, 32, 2, 26, 5)
    -- i fiori secchi e la fotografia sotto la plastica
    D.rect(70, 42, 5, 6, 9); D.rect(71, 43, 3, 3, 5)
    for k = 0, 3 do D.line(76 + k, 48, 75 + k * 2, 40, 5); D.px(75 + k * 2, 39, 7) end
    D.rect(0, 58, 128, 6, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL POZZO: sporgersi, e là in fondo un cerchio di cielo
-------------------------------------------------------------------------------
S.pozzo = {
  init = function(s)
    s.fig = D.figura(46, 56, { s = 1.3, l = 2, dark = true, pose = "stand" })
    s.stars = D.stars_gen(40, 8, 0, 34)
    s.view = 0
    s.vt = 0
    s.stone = nil
    s.rip = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "stand", 3 }, { "pose", "bend", R(10, 14) }, { "pose", "stand", 4 } } end)
    s.fig:update(dt)
    s.vt = s.vt + dt
    if s.vt > 22 then s.vt = 0; s.view = 1 - s.view end
    if not s.stone and random() < dt * 0.05 then s.stone = { y = 0 } end
    if s.stone then
      s.stone.y = s.stone.y + dt * 0.4
      if s.stone.y > 1 then s.stone = nil; s.rip = 1; S.env.sfx("drop", 500, 0.03, 0.4, 0, 0.3, 0.001) end
    end
    s.rip = max(0, s.rip - dt * 0.4)
  end,
  draw = function(s, t)
    local f = min(1, s.vt / 1.2, (22 - s.vt) / 1.2)
    local g = D.gain
    D.gain = g * max(0, f)
    if s.view == 0 then
      -- di fuori: il pozzo nel campo, di notte
      D.rect(0, 0, 128, 64, 0)
      D.stars(s.stars, t, 0.9)
      D.moon(100, 12, 3, 13, 0)
      D.rect(0, 50, 128, 14, 1)
      D.rect(56, 38, 30, 14, 4)
      for y = 40, 50, 4 do for x = 56, 84, 6 do D.rect(x + (y % 8 == 0 and 3 or 0), y, 5, 3, 5) end end
      D.rect(56, 37, 30, 2, 6)
      D.rect(60, 18, 2, 20, 3); D.rect(80, 18, 2, 20, 3); D.rect(58, 17, 26, 2, 4)
      D.line(71, 19, 71, 34, 3); D.rect(68, 34, 6, 4, 4)
      s.fig:draw()
    else
      -- da dentro: guardi giù, il cerchio di cielo che trema
      D.rect(0, 0, 128, 64, 0)
      for k = 8, 1, -1 do D.circle(64, 32, 6 + k * 4.5, 1 + (k % 2), true) end
      local wob = sin(t * 2) * 0.6 + s.rip * sin(t * 12) * 2
      D.circle(64, 32, 6 + wob, 2)
      for i = 1, 6 do local a = i + t * 0.05; D.px(64 + cos(a) * 3, 32 + sin(a) * 3, 6 + mac("stelle") * 8) end
      if s.rip > 0 then D.circle(64, 32, (1 - s.rip) * 7 + 1, 6 * s.rip, true) end
      if s.stone then local r = 30 * (1 - s.stone.y); D.px(64 + r * 0.2, 32 + r * 0.6, 9) end
    end
    D.gain = g
  end,
}

-------------------------------------------------------------------------------
-- IL MARE APERTO: nessuna riva, la zattera, la balena laggiù
-------------------------------------------------------------------------------
S.mare_aperto = {
  init = function(s)
    s.fig = D.figura(64, 36, { s = 1.1, l = 3, dark = true, pose = "sit_ground" })
    s.stars = D.stars_gen(50, 12, 0, 24)
    s.whale = -60
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(8, 14) } }, { { "pose", "look_up", 5 } }, { { "pose", "sit_think", 8 } } }) end)
    local m = mac("mare")
    s.fig.y = 36 + sin(t * 0.7) * (1 + m * 2.5)
    s.fig:update(dt)
    s.whale = s.whale + dt * 4
    if s.whale > 200 then s.whale = -80 end
  end,
  draw = function(s, t)
    local m, pr = mac("mare"), mac("profondita")
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 0.9 + mac("stelle") * 0.4)
    D.moon(26, 10, 3, 13, 0)
    -- le onde, alte quanto il mare
    local amp = 1 + m * 3
    for k = 0, 3 do
      local y = 30 + k * 4
      screen.level(D.lv(2 + k))
      screen.move(0, y + sin(t * 0.7 + k) * amp)
      for x = 4, 128, 4 do screen.line(x, y + sin(t * 0.7 + x * 0.06 + k) * amp) end
      screen.line(128, 64); screen.line(0, 64); screen.close(); screen.fill()
    end
    D.reflection(26, 31, 44, 4, t, 7)
    -- la zattera
    local ry = s.fig.y + 1
    D.rect(54, ry, 22, 2, 4)
    s.fig:draw()
    -- giù, sotto la luce: la balena che passa
    local wy = 54 + pr * 4
    D.poly({ s.whale, wy, s.whale + 30, wy - 3, s.whale + 44, wy, s.whale + 30, wy + 3 }, 2 + pr * 2)
    D.poly({ s.whale - 8, wy - 3, s.whale, wy, s.whale - 8, wy + 3 }, 2 + pr * 2)
  end,
}

end
