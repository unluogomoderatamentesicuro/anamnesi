-- ANAMNESI · scene dei ricordi (v5): cielo, alture, infanzia
return function(S, D, K, H)
local floor, sin, cos, random, abs, min, max, pi, sqrt =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi, math.sqrt
local R, pick, pan, think, mac = H.R, H.pick, H.pan, H.think, H.mac
local KS = K.S

D.POSE.fly = { lean = 70, nod = -30, ua1 = 100, ua2 = -100, fa1 = 100, fa2 = -100, th1 = -10, th2 = -16, sh1 = -12, sh2 = -20, hy = 7.0, rot = 0 }
D.POSE.shout = { lean = -8, nod = -16, ua1 = 160, ua2 = 150, fa1 = 120, fa2 = 110, th1 = 4, th2 = -4, sh1 = 0, sh2 = -2, hy = 7.2, rot = 0 }
D.POSE.release = { lean = -6, nod = -34, ua1 = 150, ua2 = 140, fa1 = 170, fa2 = 165, th1 = 3, th2 = -3, sh1 = 0, sh2 = -1, hy = 7.3, rot = 0 }
D.POSE.pedal = { lean = 20, nod = 10, ua1 = 70, ua2 = 66, fa1 = 92, fa2 = 88, th1 = 70, th2 = 50, sh1 = 10, sh2 = -10, hy = 4.4, rot = 0 }
D.POSE.blow = { lean = 22, nod = 18, ua1 = 30, ua2 = 26, fa1 = 70, fa2 = 66, th1 = 90, th2 = 87, sh1 = 4, sh2 = 0, hy = 4.6, rot = 0 }

local function txt(x, y, s, l, center)
  screen.font_face(1); screen.font_size(8)
  screen.level(D.lv(l)); screen.move(x, y)
  if center then screen.text_center(D.tr(s)) else screen.text(D.tr(s)) end
end

-------------------------------------------------------------------------------
-- IL VOLO: sopra i tetti, i campi, il fiume
-------------------------------------------------------------------------------
S.volo = {
  init = function(s)
    s.fig = D.figura(46, 26, { s = 1.3, l = 2, dark = true, pose = "fly" })
    s.off = 0
    s.h1 = D.ridge_gen(5, 42, 8, 0.7)
    s.sw = {}
    for i = 1, 5 do s.sw[i] = { x = R(0, 128), y = R(14, 40), v = R(4, 12), p = R(0, 6) } end
    s.fields = {}
    for i = 1, 14 do s.fields[i] = { x = i * 22, w = R(14, 22), l = pick({ 7, 8, 9, 6 }) } end
  end,
  update = function(s, dt, t)
    s.off = s.off + dt * (12 + mac("vento") * 14)
    s.fig:update(dt)
    s.fig.y = 26 + sin(t * 0.6) * 3
    s.fig.cur.ua1 = 100 + sin(t * 1.2) * 8; s.fig.cur.ua2 = -100 - sin(t * 1.2) * 8
    for _, b in ipairs(s.sw) do b.x = b.x - b.v * dt; if b.x < -6 then b.x = 134; b.y = R(14, 40) end end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 8 + lu * 3, 12 + lu * 2)
    D.ridge(s.h1, 7, 64, s.off * 0.1)
    -- i campi visti dall'alto, a strisce, e il fiume che luccica
    for _, f in ipairs(s.fields) do
      local x = (f.x - s.off * 0.6) % 308 - 20
      D.poly({ x, 46, x + f.w, 46, x + f.w + 10, 64, x + 6, 64 }, f.l)
    end
    for i = 0, 40 do
      local x = i * 4
      local y = 52 + sin((x + s.off * 0.6) * 0.05) * 5
      D.rect(x, y, 4, 2, 12 + ((i + floor(t * 4)) % 5 == 0 and 3 or 0))
    end
    -- i tetti del paese che passano
    for i = 0, 3 do
      local x = (i * 40 - s.off * 0.8) % 180 - 20
      D.house(x, 50, 8, 4, 4, 3); D.house(x + 10, 51, 6, 3, 4, 3)
    end
    for _, b in ipairs(s.sw) do local w = sin(t * 10 + b.p) * 1.5; D.line(b.x - 2, b.y - w, b.x, b.y, 3); D.line(b.x, b.y, b.x + 2, b.y - w, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'ECLISSI: a mezzogiorno si fa sera, il sole diventa un anello
-------------------------------------------------------------------------------
S.eclissi = {
  init = function(s)
    s.k = 0
    s.people = {}
    for i = 1, 5 do s.people[i] = D.figura(20 + i * 18, 56, { s = 1.05, l = 2, dark = true, pose = "look_up", child = (i == 2), dress = (i == 4) }) end
    s.fig = s.people[3]
    s.stars = D.stars_gen(30, 8, 0, 30)
  end,
  update = function(s, dt, t)
    s.k = (s.k + dt / 60) % 1
    for _, p in ipairs(s.people) do p:update(dt) end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    -- la luce cala e torna: una curva lenta di un minuto
    local d = sin(s.k * pi) ^ 2
    D.gradient(0, 46, 10 - d * 9 + lu, 12 - d * 9 + lu)
    if d > 0.6 then D.stars(s.stars, t, (d - 0.6) * 2.5) end
    local sx = 40 + s.k * 50
    local mx = sx + (1 - d) * 18 - 9
    if d > 0.85 then
      -- la corona
      for i = 0, 15 do local a = i / 16 * pi * 2 + t * 0.05; D.line(64 + cos(a) * 9, 18 + sin(a) * 9, 64 + cos(a) * (12 + (i % 3) * 2), 18 + sin(a) * (12 + (i % 3) * 2), 10) end
      D.circle(64, 18, 8, 15); D.circle(64, 18, 7, 0)
    else
      D.circle(sx, 18, 8, 15)
      D.circle(mx, 18, 8, 10 - d * 9 + lu)
    end
    D.rect(0, 46, 128, 18, 6 - d * 4)
    for x = 0, 127 do local h = 2 + sin(x * 0.08) * 2; D.rect(x, 46 - h, 1, h, 5 - d * 3) end
    for _, p in ipairs(s.people) do p:draw() end
  end,
}

-------------------------------------------------------------------------------
-- LA COMETA: ferma nel cielo, sopra il campanile
-------------------------------------------------------------------------------
S.cometa = {
  init = function(s)
    s.stars = D.stars_gen(90, 97, 0, 40)
    s.fig = D.figura(36, 56, { s = 1.15, l = 7, pose = "look_up" })
    s.nonno = D.figura(50, 56, { s = 1.2, l = 6, pose = "point" })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "look_up", R(8, 12) } }, { { "pose", "stand", 3 }, { "pose", "look_up", 5 } } }) end)
    think(s.nonno, function() return pick({ { { "pose", "point", R(4, 8) } }, { { "pose", "stand", R(4, 6) } }, { { "pose", "look_up", 5 } } }) end)
    s.fig:update(dt); s.nonno:update(dt)
  end,
  draw = function(s, t)
    local st = mac("stelle")
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 0.8 + st * 0.5)
    -- la cometa: il nucleo e due code, una dritta e una che si apre
    local cx, cy = 92, 14
    for k = 0, 24 do
      local f = k / 24
      local l = 13 * (1 - f) + 1
      D.px(cx - k * 1.3, cy + k * 0.55, l)
      D.px(cx - k * 1.2, cy + k * 0.9 + f * 2, l * 0.6)
      if k % 2 == 0 then D.px(cx - k * 1.25, cy + k * 0.72 + sin(t * 2 + k) * f, l * 0.5) end
    end
    D.circle(cx, cy, 1.4, 15)
    -- il paese e il campanile
    D.rect(0, 44, 128, 20, 1)
    for i = 0, 6 do D.house(i * 18 + 6, 46, 12, 5 + (i % 3) * 2, 1, 4); if i % 2 == 0 then D.rect(i * 18 + 10, 42, 2, 2, 9) end end
    D.rect(80, 22, 6, 24, 2); D.poly({ 79, 22, 87, 22, 83, 16 }, 2)
    D.rect(0, 56, 128, 8, 1)
    s.fig:draw(); s.nonno:draw()
  end,
}

-------------------------------------------------------------------------------
-- DOPO IL TEMPORALE: l'arcobaleno, le gocce, la lumaca
-------------------------------------------------------------------------------
S.arcobaleno = {
  init = function(s)
    s.fig = D.figura(30, 56, { s = 1.0, l = 2, dark = true, child = true, speed = 9, on_step = H.steps("erba", 0.25) })
    s.drops = D.parts(30)
    s.snail = 60
    s.puddle = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "walk", R(70, 110), 9 }, { "pose", "look_up", 3 }, { "walk", R(10, 40), 8 } }, { { "pose", "point", 4 } }, { { "pose", "bend", 3 } } }) end)
    s.fig:update(dt)
    if random() < dt * 6 then D.spawn(s.drops, { x = R(96, 124), y = R(20, 30), vx = 0, vy = 10, life = 3 }) end
    D.parts_update(s.drops, dt, function(p, d) p.vy = p.vy + 30 * d; if p.y > 56 then p.dead = true end end)
    s.snail = s.snail + dt * 0.5
    if s.snail > 90 then s.snail = 40 end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 40, 6 + lu * 3, 10 + lu * 2)
    -- le nuvole del temporale che se ne vanno a destra
    D.cloud(90 + t * 0.4 % 40, 6, 40, 4, 3)
    -- l'arcobaleno: sette archi netti
    local a = 0.4 + lu * 0.6
    for k = 0, 6 do
      screen.level(D.lv((14 - k * 1.4) * a)); screen.arc(30, 56, 40 + k * 2, pi * 1.02, pi * 1.75); screen.stroke()
    end
    -- il campanile da dove parte
    D.rect(8, 30, 6, 16, 4); D.poly({ 7, 30, 15, 30, 11, 25 }, 4)
    D.rect(0, 46, 128, 18, 7)
    -- l'albero che sgocciola
    D.tree(110, 50, 26, 4, 7, 0)
    for _, p in ipairs(s.drops.list) do D.px(p.x, p.y, 13) end
    -- la pozzanghera col cielo dentro, la lumaca
    D.rect(56, 57, 24, 2, 11)
    D.circle(s.snail, 55, 1.5, 4, true); D.line(s.snail + 1, 56, s.snail + 4, 56, 4); D.px(s.snail + 4, 54, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA BALENA NEL CIELO
-------------------------------------------------------------------------------
S.balena_cielo = {
  init = function(s)
    s.fig = D.figura(28, 52, { s = 1.15, l = 2, dark = true, pose = "look_up" })
    s.x = 150
    s.cl = { { 0, 46, 30, 0.5 }, { 60, 50, 26, 0.4 }, { 110, 44, 34, 0.6 } }
    s.song = 0
  end,
  update = function(s, dt, t)
    s.x = s.x - dt * 3
    if s.x < -90 then s.x = 150 end
    think(s.fig, function() return pick({ { { "pose", "look_up", R(8, 12) } }, { { "pose", "arms_open", 5 } }, { { "pose", "reach_up", 4 } } }) end)
    s.fig:update(dt)
    s.song = s.song - dt
    if s.song < 0 then s.song = R(14, 26); S.env.sfx("swell", 110, 0.05, 5, -0.2, 0.2, 1.2) end
  end,
  draw = function(s, t)
    local pr = mac("profondita")
    D.gradient(0, 50, 3, 7)
    -- la balena: il corpo lungo, la coda, le pieghe della gola, l'occhio
    local x, y = s.x, 18 + sin(t * 0.3) * 2
    D.poly({ x, y, x + 20, y - 8, x + 60, y - 6, x + 80, y, x + 60, y + 6, x + 20, y + 8 }, 2 + pr * 2)
    D.poly({ x + 78, y, x + 92, y - 8 + sin(t * 0.6) * 2, x + 88, y, x + 92, y + 8 + sin(t * 0.6) * 2 }, 2 + pr * 2)
    for k = 0, 5 do D.line(x + 8 + k * 4, y + 3, x + 12 + k * 4, y + 7, 4) end
    D.px(x + 12, y - 2, 12)
    D.poly({ x + 30, y + 5, x + 40, y + 5, x + 34, y + 12 }, 3)
    K.clouds(s.cl, t * 0.4, 12)
    D.rect(0, 52, 128, 12, 10)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE LANTERNE: cento lanterne che salgono, una col nome
-------------------------------------------------------------------------------
S.lanterne = {
  init = function(s)
    s.l = {}
    for i = 1, 26 do s.l[i] = { x = R(0, 128), y = R(-10, 60), v = R(2, 5), ph = R(0, 6), s = R(0.6, 1.4) } end
    s.mine = nil
    s.fig = D.figura(56, 58, { s = 1.2, l = 7, pose = "stand" })
  end,
  update = function(s, dt, t)
    for _, a in ipairs(s.l) do a.y = a.y - a.v * dt * a.s; a.x = a.x + sin(t * 0.4 + a.ph) * dt * 2; if a.y < -6 then a.y = R(56, 66); a.x = R(0, 128) end end
    think(s.fig, function() return { { "pose", "carry", 4 }, { "fn", function() s.mine = { x = 60, y = 42 } end }, { "pose", "release", 3 }, { "pose", "look_up", R(10, 16) }, { "pose", "head_down", 3 } } end)
    s.fig:update(dt)
    if s.mine then s.mine.y = s.mine.y - dt * 3; s.mine.x = s.mine.x + sin(t * 0.5) * dt * 3; if s.mine.y < -8 then s.mine = nil end end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 64, 0, 2)
    for _, a in ipairs(s.l) do
      local sz = 1.6 + a.s * 1.4
      local fl = 10 + D.noise(t * 3 + a.ph) * 3 + lu * 2
      D.rect(a.x - sz / 2, a.y - sz, sz, sz * 1.4, fl * (0.55 + a.s * 0.35))
      D.px(a.x, a.y + sz * 0.4, 15)
    end
    -- il lago che le riflette
    D.rect(0, 52, 128, 12, 1)
    for _, a in ipairs(s.l) do if a.y < 52 then D.px(a.x, 52 + (52 - a.y) * 0.2, 4) end end
    if s.mine then D.rect(s.mine.x - 2, s.mine.y - 3, 4, 5, 15) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL LAGO DELL'ECO: gridi il nome, torna due volte
-------------------------------------------------------------------------------
S.piediluco = {
  init = function(s)
    s.fig = D.figura(30, 52, { s = 1.2, l = 2, dark = true, pose = "stand" })
    s.echo = {}
    s.boat = 130
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "stand", R(4, 8) }, { "pose", "shout", 1 }, { "fn", function()
      s.echo = { { x = 40, a = 1, k = 0 }, { x = 120, a = 0, k = -1.4 }, { x = 100, a = 0, k = -2.8 } } end }, { "pose", "stand", 6 }, { "pose", "look_up", 4 } } end)
    s.fig:update(dt)
    for _, e in ipairs(s.echo) do e.k = e.k + dt end
    s.boat = s.boat - dt * 3
    if s.boat < -20 then s.boat = 140 end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 7 + lu * 3, 10 + lu * 2)
    -- la montagna di fronte, il paesino sulla riva
    D.poly({ 60, 30, 90, 6, 110, 14, 128, 10, 128, 30 }, 4)
    D.poly({ 0, 30, 20, 20, 50, 30 }, 5)
    for i = 0, 4 do D.house(64 + i * 8, 30, 6, 4, 6, 3) end
    -- il lago, il riflesso della montagna
    D.rect(0, 30, 128, 22, 6)
    D.poly({ 60, 31, 90, 48, 110, 42, 128, 46, 128, 31 }, 5)
    D.waves(31, 52, t * 0.5, 9, 2, 3)
    -- la barca a remi
    local b = s.boat
    D.poly({ b - 6, 40, b + 6, 40, b + 4, 42, b - 4, 42 }, 2); D.line(b, 38, b + 6, 43, 2)
    -- il grido e l'eco: cerchi che tornano dalla montagna
    for i, e in ipairs(s.echo) do
      if e.k > 0 and e.k < 2.5 then
        local r = e.k * 14
        local l = (i == 1 and 9 or 6 / i) * (1 - e.k / 2.5)
        screen.level(D.lv(l)); screen.arc(i == 1 and 40 or 96, 22, r, pi * (i == 1 and 1.6 or 0.6), pi * (i == 1 and 2.4 or 1.4)); screen.stroke()
      end
    end
    D.rect(0, 52, 128, 12, 4)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL PONTE DELLE TORRI: gli archi alti sulla gola, il falco sotto
-------------------------------------------------------------------------------
S.ponte_torri = {
  init = function(s)
    s.fig = D.figura(-6, 22, { s = 0.9, l = 2, dark = true, speed = 3, on_step = H.steps("pietra", 0.2) })
    s.hawk = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", 60, 3 }, { "pose", "lean_rail", R(6, 10) }, { "walk", 140, 3 }, { "fn", function(f) f.x = -6 end }, { "wait", R(3, 8) } } end)
    s.fig:update(dt)
    s.hawk = s.hawk + dt
  end,
  draw = function(s, t)
    local w = mac("vento")
    D.gradient(0, 30, 8, 11)
    -- la gola: i fianchi boscosi
    D.poly({ 0, 20, 30, 30, 44, 64, 0, 64 }, 4); D.poly({ 128, 18, 98, 30, 84, 64, 128, 64 }, 4)
    for i = 0, 10 do D.tree(4 + i * 3, 30 + i * 3, 8, 3, i + 1, sin(t + i) * w); D.tree(124 - i * 3, 30 + i * 3, 8, 3, i + 7, sin(t + i + 1) * w) end
    D.rect(44, 56, 40, 8, 3)
    -- il ponte: il piano alto e gli archi lunghi
    D.rect(0, 22, 128, 3, 6)
    for i = 0, 5 do
      local x = i * 22 + 4
      D.rect(x, 25, 4, 39, 6)
      screen.level(D.lv(6)); screen.move(x + 4, 34); screen.curve(x + 8, 27, x + 18, 27, x + 22, 34); screen.stroke()
    end
    for x = 0, 127, 5 do D.line(x, 18, x, 22, 6) end
    D.line(0, 18, 127, 18, 7)
    -- il falco che gira sotto
    local hx, hy = 64 + cos(s.hawk * 0.4) * 22, 42 + sin(s.hawk * 0.4) * 5
    local wf = sin(s.hawk * 3) * 1
    D.line(hx - 4, hy - wf, hx, hy, 2); D.line(hx, hy, hx + 4, hy - wf, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA FAGGETA: le colonne grigie, le foglie rosse alle caviglie
-------------------------------------------------------------------------------
S.faggeta = {
  init = function(s)
    s.fig = D.figura(-6, 56, { s = 1.15, l = 2, dark = true, speed = 2.5, on_step = H.steps("foglie", 0.35) })
    s.leaves = D.parts(40)
    s.trunks = {}
    for i = 1, 9 do s.trunks[i] = { x = i * 15 + R(-4, 4), w = R(3, 6), l = R(5, 8) } end
    s.peck = 6
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "walk", R(30, 60), 2.5 }, { "pose", "look_up", 5 }, { "pose", "stand", 3 }, { "walk", 140, 2.5 }, { "fn", function(f) f.x = -6 end }, { "wait", R(2, 5) } } end)
    s.fig:update(dt)
    if random() < dt * (1 + mac("foglie") * 4) then D.spawn(s.leaves, { x = R(0, 128), y = 0, vx = R(-2, 3), vy = R(4, 8), life = 12, ph = R(0, 6) }) end
    D.parts_update(s.leaves, dt, function(p) if p.y > 58 then p.dead = true end end)
    s.peck = s.peck - dt
    if s.peck < 0 then s.peck = R(12, 25); for i = 1, 6 do clock.run(function() clock.sleep(i * 0.07); S.env.sfx("step", 1600, 0.02, 0.03, -0.7, 0.8, 0) end) end end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 56, 9 + lu * 2, 6)
    -- i raggi bassi d'autunno
    for k = 0, 2 do local x = 20 + k * 40; D.poly({ x, 0, x + 6, 0, x + 30, 56, x + 22, 56 }, 10 + lu * 2) end
    for _, tr in ipairs(s.trunks) do
      D.rect(tr.x, 0, tr.w, 58, tr.l)
      D.rect(tr.x, 0, 1, 58, tr.l + 2)
      D.px(tr.x + 1, 20 + (tr.x % 13), tr.l - 2); D.px(tr.x + 2, 34 + (tr.x % 7), tr.l - 2)
    end
    -- il tappeto di foglie rosse
    D.rect(0, 54, 128, 10, 5)
    for i = 0, 80 do D.px((i * 23) % 128, 54 + (i * 7) % 9, 7 + (i % 4)) end
    for _, p in ipairs(s.leaves.list) do D.px(p.x + sin(t * 2 + p.ph) * 3, p.y, 11) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL TEMPORALE DALLA COLLINA: il muro grigio che cammina sui campi
-------------------------------------------------------------------------------
S.temporale = {
  init = function(s)
    s.fig = D.figura(24, 52, { s = 1.2, l = 2, dark = true, pose = "stand" })
    s.flash = 0
    s.front = 128
    s.count = nil
    s.words = D.parts(4)
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "stand", R(5, 8) } }, { { "pose", "point", 4 } }, { { "pose", "look_up", 4 } } }) end)
    s.fig:update(dt)
    s.front = s.front - dt * (0.8 + mac("vento") * 1.5)
    if s.front < 40 then s.front = 128 end
    if random() < dt * 0.18 then
      s.flash = 1; s.fx = R(s.front + 5, 124); s.count = 0
    end
    s.flash = max(0, s.flash - dt * 3)
    if s.count then
      local o = s.count
      s.count = s.count + dt
      local d = (s.fx - 24) / 25
      if floor(o) ~= floor(s.count) and s.count < d then
        local w = H.lang() == 1 and { "uno", "due", "tre", "quattro", "cinque" } or { "one", "two", "three", "four", "five" }
        D.spawn(s.words, { x = 10, y = 30, vx = 0, vy = -1, life = 1.5, w = w[min(5, floor(s.count))], l = 6 })
      end
      if s.count >= d then s.count = nil; S.env.sfx("drop", 50, 0.06, 2, pan(s.fx), 0.1, 0.05) end
    end
    D.float_words_update(s.words, dt)
  end,
  draw = function(s, t)
    D.gradient(0, 36, 5, 8)
    -- il muro grigio della pioggia che cammina
    D.rect(s.front, 0, 128 - s.front, 46, 3)
    for x = floor(s.front), 127, 3 do D.line(x, 8, x - 4, 46, 4) end
    D.cloud(s.front - 10, 6, 60, 2, 9)
    if s.flash > 0 then
      local x = s.fx
      D.line(x, 4, x - 4, 16, 15 * s.flash); D.line(x - 4, 16, x + 2, 26, 15 * s.flash); D.line(x + 2, 26, x - 2, 40, 15 * s.flash)
      D.flash(s.flash * 6, s.front, 0, 128 - s.front, 46)
    end
    -- la valle, i campi
    D.rect(0, 36, 128, 28, 6)
    for i = 0, 6 do D.line(0, 40 + i * 3, 128, 38 + i * 4, 7) end
    D.poly({ 0, 64, 0, 50, 40, 52, 70, 64 }, 4)
    s.fig:draw()
    D.float_words_draw(s.words)
  end,
}

-------------------------------------------------------------------------------
-- IL GREGGE: la nuvola che bela, il cane che fa tutto
-------------------------------------------------------------------------------
S.gregge = {
  init = function(s)
    s.sheep = {}
    for i = 1, 22 do s.sheep[i] = { x = R(-60, 30), y = R(30, 42), ph = R(0, 6), lamb = random() < 0.15 } end
    s.dog = { x = 0 }
    s.past = D.figura(-30, 40, { s = 1.0, l = 2, dark = true, speed = 2.5 })
    s.fig = D.figura(100, 56, { s = 1.15, l = 2, dark = true, pose = "stand", face = -1 })
  end,
  update = function(s, dt, t)
    for _, sh in ipairs(s.sheep) do sh.x = sh.x + dt * (3 + sin(t + sh.ph) * 1.5); if sh.x > 150 then sh.x = R(-60, -10) end end
    s.dog.x = 40 + sin(t * 0.7) * 50
    think(s.past, function() return { { "walk", 150, 2.5 }, { "fn", function(f) f.x = -30 end } } end)
    s.past:update(dt); s.fig:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 9 + lu * 2, 12 + lu)
    D.rect(0, 30, 128, 34, 8)
    D.line(0, 30, 127, 26, 9)
    for _, sh in ipairs(s.sheep) do
      local x, y = sh.x, sh.y + abs(sin(t * 4 + sh.ph)) * 0.6
      local r = sh.lamb and 1.6 or 2.4
      D.circle(x, y, r, 13); D.circle(x + r, y - 0.5, r * 0.7, 13)
      D.px(x + r * 1.7, y - 1, 3)
      D.line(x - 1, y + r, x - 1, y + r + 1.5, 3); D.line(x + 1, y + r, x + 1, y + r + 1.5, 3)
    end
    -- il cane che corre intorno
    local dx = s.dog.x
    D.rect(dx, 42, 4, 2, 2); D.px(dx + 4, 41, 2); D.line(dx, 44, dx - 1, 46, 2); D.line(dx + 3, 44, dx + 4, 46, 2)
    s.past:draw()
    D.rect(0, 52, 128, 12, 7)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- L'EREMO: la celletta nella roccia, la croce, la valle intera
-------------------------------------------------------------------------------
S.eremo = {
  init = function(s)
    s.fig = D.figura(40, 50, { s = 1.2, l = 2, dark = true, pose = "sit_ground", face = 1 })
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "sit_ground", R(10, 16) } }, { { "pose", "pray", R(8, 12) } }, { { "pose", "stand", 3 }, { "pose", "look_up", 5 } } }) end)
    s.fig:update(dt)
  end,
  draw = function(s, t)
    local w = mac("vento")
    -- la valle in fondo, luminosa
    D.gradient(0, 40, 8, 11)
    s.rg = s.rg or { D.ridge_gen(30, 30, 6, 0.6), D.ridge_gen(31, 34, 6, 0.6), D.ridge_gen(32, 38, 6, 0.6), D.ridge_gen(33, 42, 6, 0.6) }
    for k = 0, 3 do D.ridge(s.rg[k + 1], 9 - k * 1.5, 64, 0) end
    -- la roccia, l'apertura della cella
    D.poly({ 0, 0, 30, 0, 26, 20, 34, 40, 30, 64, 0, 64 }, 2)
    D.poly({ 128, 0, 72, 0, 78, 16, 70, 34, 80, 64, 128, 64 }, 2)
    D.rect(0, 50, 128, 14, 2)
    -- dentro: il giaciglio di paglia, la croce, la candela consumata
    D.rect(84, 48, 26, 3, 6)
    for x = 84, 108, 2 do D.line(x, 48, x + 1, 46, 7) end
    D.cross(100, 34, 10, 5)
    D.rect(90, 46, 2, 2, 8); D.px(91, 44, 10 + D.noise(t * 6) * 4)
    -- un filo d'erba sul bordo, mosso
    for i = 0, 4 do D.line(30 + i * 2, 50, 30 + i * 2 + sin(t + i) * (1 + w * 2), 45, 5) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL FALÒ: le scintille alle stelle, le facce arancioni
-------------------------------------------------------------------------------
S.falo = {
  init = function(s)
    s.sparks = D.parts(60)
    s.stars = D.stars_gen(50, 17, 0, 26)
    s.people = {}
    for i, x in ipairs({ 22, 34, 90, 104, 116 }) do s.people[i] = D.figura(x, 56, { s = 1.1, l = 2, dark = true, face = (x < 64) and 1 or -1, pose = "stand", dress = (i % 2 == 0) }) end
    s.fig = s.people[2]
    s.sing = 0
  end,
  update = function(s, dt, t)
    local fu = mac("fuoco")
    for _ = 1, floor(dt * (14 + fu * 30) + random()) do D.spawn(s.sparks, { x = R(56, 72), y = 40, vx = R(-6, 6), vy = -R(14, 34), life = R(1, 3) }) end
    D.parts_update(s.sparks, dt)
    for i, p in ipairs(s.people) do
      think(p, function() return pick({ { { "pose", "stand", R(4, 8) } }, { { "pose", "look_up", 4 } }, { { "pose", "talk", 3 } } }) end)
      p:update(dt)
    end
  end,
  draw = function(s, t)
    local fu = mac("fuoco")
    D.rect(0, 0, 128, 64, 0)
    D.stars(s.stars, t, 0.7 + mac("stelle") * 0.5)
    D.rect(0, 50, 128, 14, 1)
    -- il falò: le fascine, le fiamme alte
    D.poly({ 50, 56, 78, 56, 64, 44 }, 2)
    D.fire(64, 54, 10 + fu * 6, 18 + fu * 14, t, 15)
    for _, p in ipairs(s.sparks.list) do D.px(p.x, p.y, 15 * (1 - p.age / p.life)) end
    -- le facce illuminate di arancio
    for _, p in ipairs(s.people) do
      p.l = 2 + (1 - min(1, abs(p.x - 64) / 60)) * 5 + D.noise(t * 4 + p.x) * 2
      p:draw()
    end
  end,
}

-------------------------------------------------------------------------------
-- I GIRASOLI: tutti girati da una parte, tu dall'altra
-------------------------------------------------------------------------------
S.girasoli = {
  init = function(s)
    s.fig = D.figura(60, 58, { s = 1.15, l = 2, dark = true, child = true, pose = "stand", face = -1 })
    s.f = {}
    for r = 0, 3 do for i = 0, 15 do s.f[#s.f + 1] = { x = i * 9 + (r % 2) * 4 + R(-1, 1), y = 30 + r * 8, s = 0.6 + r * 0.2, ph = R(0, 6) } end end
    s.bee = { x = 40, y = 30 }
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "stand", R(6, 10) } }, { { "pose", "look_up", 5 } }, { { "face", 1 }, { "pose", "stand", 3 }, { "face", -1 } } }) end)
    s.fig:update(dt)
    s.bee.x = 40 + sin(t * 0.9) * 30; s.bee.y = 30 + sin(t * 2.1) * 6
  end,
  draw = function(s, t)
    local lu, w = mac("luce"), mac("vento")
    D.gradient(0, 30, 9 + lu * 2, 12 + lu * 2)
    D.circle(110, 10, 6, 15)
    D.rect(0, 30, 128, 34, 6)
    for _, f in ipairs(s.f) do
      local sw = sin(t * 1.1 + f.ph) * (0.4 + w * 1.5)
      local x, y = f.x + sw, f.y
      local r = 2.2 * f.s
      D.line(f.x, y + 10 * f.s, x, y, 5)
      D.circle(x + 0.6, y, r + 1, 13); D.circle(x + 0.8, y, r * 0.6, 3)
      D.px(f.x - 2, y + 5 * f.s, 7); D.px(f.x + 2, y + 6 * f.s, 7)
    end
    D.px(s.bee.x, s.bee.y, 2); D.px(s.bee.x + 1, s.bee.y - 1, 9)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL COMMODORE 64: lo schermo blu, il cursore, il registratore
-------------------------------------------------------------------------------
S.c64 = {
  init = function(s)
    s.fig = D.figura(44, 58, { s = KS * 0.75, l = 9, child = true, pose = "type", face = 1 })
    s.load = 0
    s.lines = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return pick({ { { "pose", "type", R(6, 10) } }, { { "pose", "sit", 4 } }, { { "pose", "sit_think", 4 } } }) end)
    s.fig:update(dt)
    s.load = (s.load + dt * (0.04 + mac("tempo") * 0.1)) % 1.2
    s.lines = s.lines + dt
  end,
  draw = function(s, t)
    K.room({ wall = 2, fy = 58, floor = "moquette", floor_l = 2, paper = "righe", ceil = 4 }, t)
    -- la scrivania, la tv usata come monitor, il C64 e il registratore
    local ty = K.desk(54, 58, 4)
    D.rect(60, ty - 22, 26, 20, 4)
    local scr = s.load < 1
    D.rect(62, ty - 20, 22, 15, 3)
    D.rect(63, ty - 19, 20, 13, scr and 6 or 5)
    if scr then
      -- le righe del bordo che lampeggiano mentre carica
      for y = ty - 20, ty - 6, 2 do D.line(60, y, 61, y, (floor(t * 20 + y) % 3) * 4 + 2); D.line(84, y, 85, y, (floor(t * 20 + y) % 3) * 4 + 2) end
      D.rect(64, ty - 18, 8, 1, 11); D.rect(64, ty - 16, 12, 1, 11)
      if floor(t * 2) % 2 == 0 then D.rect(64, ty - 14, 2, 2, 13) end
    else
      for k = 0, 4 do D.rect(64 + (k * 3) % 14, ty - 17 + k * 2, 3, 1, 12) end
    end
    D.rect(58, ty - 2, 22, 3, 7); for k = 0, 9 do D.px(59 + k * 2, ty - 1, 4) end
    D.rect(82, ty - 3, 9, 4, 3); D.circle(84.5, ty - 1, 1, 9); D.circle(88.5, ty - 1, 1, 9)
    K.chair(44, 58, 1, 4)
    -- i poster, le cassette impilate
    K.frame(20, 12, 14, 18, 3, 6); D.rect(100, 14, 14, 1, 5); for i = 0, 4 do D.rect(101 + i * 2.6, 9, 2, 5, 6 + (i % 2) * 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE CASSETTE DALLA RADIO: il dito sul REC
-------------------------------------------------------------------------------
S.cassette = {
  init = function(s)
    s.fig = D.figura(50, 58, { s = KS * 0.75, l = 9, child = true, pose = "sit_ground", face = 1 })
    s.rec = 0
    s.reel = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "sit_ground", R(5, 9) }, { "pose", "reach_up", 0.5 }, { "fn", function() s.rec = 12 end }, { "pose", "sit_think", 10 }, { "pose", "sit_ground", 3 } } end)
    s.fig:update(dt)
    if s.rec > 0 then s.rec = s.rec - dt; s.reel = s.reel + dt * 3 end
  end,
  draw = function(s, t)
    local ra = mac("radio")
    K.room({ wall = 3, fy = 58, floor = "moquette", floor_l = 2, paper = "puntini", ceil = 4 }, t)
    K.window(10, 12, 20, 18, K.views.day, t, s, 6)
    -- lo stereo con le due piastre
    D.rect(64, 36, 44, 22, 4); D.rect(64, 35, 44, 2, 6)
    for i = 0, 1 do
      local x = 68 + i * 20
      D.rect(x, 40, 16, 10, 2); D.rect(x + 1, 41, 14, 8, 6)
      for k = 0, 1 do
        local cx = x + 4 + k * 8
        D.circle(cx, 45, 2, 3)
        D.line(cx, 45, cx + cos(s.reel + k) * 2, 45 + sin(s.reel + k) * 2, 9)
      end
    end
    D.px(105, 52, (s.rec > 0) and ((floor(t * 3) % 2 == 0) and 15 or 9) or 3)
    -- l'ago della radio, le onde che escono
    D.rect(66, 53, 20, 2, 2); D.rect(70 + (t * 2) % 14, 53, 1, 2, 12)
    if ra > 0.1 then for i = 1, 3 do local k = (t * 0.8 + i * 0.33) % 1; screen.level(D.lv(6 * ra * (1 - k))); screen.arc(110, 40, 4 + k * 12, -0.6, 0.6); screen.stroke() end end
    -- le cassette con le copertine scritte a penna
    for i = 0, 4 do D.rect(28 + i * 5, 54, 4, 4, 9 - (i % 3)); D.line(29 + i * 5, 55, 31 + i * 5, 55, 3) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- IL CIRCO: il tendone, il trapezio, il clown triste
-------------------------------------------------------------------------------
S.circo = {
  init = function(s)
    s.fig = D.figura(64, 64, { s = 1.15, l = 3, dark = true, child = true, pose = "sit", face = 1 })
    s.acro = D.figura(50, 24, { s = 0.9, l = 13, pose = "swing" })
    s.clown = D.figura(90, 52, { s = 1.1, l = 11, pose = "stand", face = -1 })
    s.roll = 0
  end,
  update = function(s, dt, t)
    think(s.clown, function() return pick({ { { "pose", "cry", 3 }, { "pose", "stand", 2 } }, { { "walk", R(70, 110), 3 }, { "face", -1 }, { "pose", "arms_open", 3 } }, { { "pose", "head_down", 4 } } }) end)
    s.clown:update(dt); s.acro:update(dt); s.fig:update(dt)
    s.roll = s.roll + dt
  end,
  draw = function(s, t)
    local fo = mac("folla")
    D.rect(0, 0, 128, 64, 1)
    -- il tendone a strisce
    for i = 0, 9 do D.poly({ 64, -2, 64 + (i - 5) * 14, 30, 64 + (i - 4) * 14, 30 }, (i % 2 == 0) and 3 or 2) end
    -- i riflettori e il trapezio che oscilla
    D.poly({ 20, 0, 26, 0, 70, 56, 50, 56 }, 3)
    local a = sin(t * 1.3) * 0.5
    local ax, ay = 56 + sin(a) * 18, 8 + cos(a) * 18
    D.line(50, 8, ax - 3, ay, 7); D.line(62, 8, ax + 3, ay, 7); D.line(ax - 4, ay, ax + 4, ay, 9)
    s.acro.x, s.acro.y = ax, ay + 14
    s.acro:draw()
    -- la pista di segatura, il clown
    D.rect(20, 50, 88, 8, 6)
    screen.level(D.lv(8)); screen.move(20, 50); screen.curve(40, 46, 88, 46, 108, 50); screen.stroke()
    s.clown:draw()
    D.circle(s.clown.x + s.clown.face * 1.5, s.clown.y - 12.5, 0.9, 15)
    -- il pubblico, teste nel buio
    local n = 8 + floor(fo * 10)
    for i = 0, n do D.circle((i * 13) % 128 + 4, 60 + (i % 2) * 2, 2.4, 2) end
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA GIOSTRA A CATENE: i seggiolini, le luci che diventano strisce
-------------------------------------------------------------------------------
S.giostra = {
  init = function(s)
    s.a = 0
    s.sp = 0
  end,
  update = function(s, dt, t)
    local target = 1.2 + mac("tempo") * 1.5
    local cyc = t % 50
    if cyc > 40 then target = 0 end
    s.sp = s.sp + (target - s.sp) * dt * 0.4
    s.a = s.a + s.sp * dt
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 64, 0, 3)
    -- il palo centrale, il tetto con le luci
    D.rect(62, 10, 4, 54, 5)
    D.poly({ 40, 14, 88, 14, 64, 4 }, 4)
    for i = 0, 11 do D.px(42 + i * 4, 14, (floor(t * 4 + i) % 3 == 0) and 15 or (7 + lu * 4)) end
    -- i seggiolini: più gira, più volano in fuori
    local out = min(1, s.sp / 2)
    local pts = {}
    for i = 0, 9 do
      local a = s.a + i / 10 * pi * 2
      local r = 20 + out * 26
      local x = 64 + cos(a) * r
      local y = 14 + 18 + out * 6 + sin(a) * 4
      local front = sin(a) > 0
      pts[#pts + 1] = { x = x, y = y, f = front, a = a }
    end
    table.sort(pts, function(p, q) return (p.f and 1 or 0) < (q.f and 1 or 0) end)
    for _, p in ipairs(pts) do
      local l = p.f and 12 or 6
      D.line(64 + cos(p.a) * 18, 14, p.x, p.y, p.f and 7 or 3)
      D.rect(p.x - 2, p.y, 4, 2, l)
      D.circle(p.x, p.y - 2, 1.3, l); D.line(p.x - 1, p.y + 2, p.x - 1 + out * 2, p.y + 5, l)
      -- le luci che diventano strisce
      if s.sp > 1 and p.f then D.line(p.x, p.y - 4, p.x - cos(p.a + pi / 2) * 6, p.y - 4, 4) end
    end
    D.rect(0, 58, 128, 6, 2)
  end,
}

-------------------------------------------------------------------------------
-- LA TOMBOLA DI NATALE: i fagioli, il cestino, la nonna che chiama
-------------------------------------------------------------------------------
S.tombola = {
  init = function(s)
    s.nonna = D.figura(36, 58, { s = KS, l = 4, dark = true, dress = true, bun = true, pose = "talk", face = 1 })
    s.fig = D.figura(82, 58, { s = KS * 0.72, l = 10, child = true, pose = "sit_read", face = -1 })
    s.zio = D.figura(106, 58, { s = KS, l = 4, dark = true, pose = "sit", face = -1 })
    s.num = nil
    s.next = 3
    s.beans = {}
    s.snow = D.parts(30)
  end,
  update = function(s, dt, t)
    s.next = s.next - dt
    if s.next < 0 then
      s.next = R(4, 7)
      s.num = { n = random(1, 90), t = 2.5 }
      s.nonna:act({ { "pose", "reach_up", 0.6 }, { "pose", "talk", 2 } })
      if random() < 0.5 then s.beans[#s.beans + 1] = { x = R(70, 96), y = R(43, 45) } end
      if #s.beans > 9 then s.beans = {} end
    end
    if s.num then s.num.t = s.num.t - dt; if s.num.t < 0 then s.num = nil end end
    s.nonna:update(dt); s.fig:update(dt); s.zio:update(dt)
    D.snow_update(s.snow, dt, 1, 30, 0, t)
  end,
  draw = function(s, t)
    local warm, fu = mac("calore"), mac("fuoco")
    K.room({ wall = 4 + warm * 2, fy = 58, floor = "assi", floor_l = 3, paper = "fiori", ceil = 4 }, t)
    K.window(8, 10, 18, 18, K.views.night, t, s, 5)
    for _, p in ipairs(s.snow.list) do if p.x > 8 and p.x < 26 and p.y > 10 then D.px(p.x, p.y, 13) end end
    K.clock(100, 14, t, 5, true)
    -- la stufa a legna nell'angolo, con la brace che si vede dallo sportello
    D.rect(116, 38, 12, 20, 3); D.rect(118, 44, 7, 6, 0); D.fire(121.5, 49, 2.5, 4 + fu * 3, t, 13)
    -- il tavolo con le cartelle e i fagioli, i mandarini
    local ty = K.table(44, 58, 4.6, 4, 10)
    for i = 0, 3 do D.rect(52 + i * 12, ty - 2, 10, 2, 13); for k = 0, 4 do D.px(53 + i * 12 + k * 2, ty - 1, 6) end end
    for _, b in ipairs(s.beans) do D.px(b.x, ty - 2, 3) end
    D.circle(98, ty - 2, 1.6, 11); D.circle(102, ty - 2, 1.6, 11)
    D.rect(46, ty - 6, 5, 4, 7)
    s.nonna:draw(); s.fig:draw(); s.zio:draw()
    if s.num then txt(s.nonna.x + 6, 22, tostring(s.num.n), 13 * min(1, s.num.t)) end
  end,
}

-------------------------------------------------------------------------------
-- IL PRESEPE: il muschio, la carta stagnola, i re magi un passo alla volta
-------------------------------------------------------------------------------
S.presepe = {
  init = function(s)
    s.fig = D.figura(110, 58, { s = KS * 0.72, l = 9, child = true, pose = "stand", face = -1 })
    s.kings = 0
  end,
  update = function(s, dt, t)
    think(s.fig, function() return { { "pose", "stand", R(6, 10) }, { "pose", "reach_up", 1.5 }, { "fn", function() s.kings = min(1, s.kings + 0.08) end }, { "pose", "head_down", 4 } } end)
    s.fig:update(dt)
    if s.kings >= 1 and random() < dt * 0.02 then s.kings = 0 end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.rect(0, 0, 128, 64, 0)
    -- il cielo di carta blu con la stella attaccata
    D.rect(4, 4, 96, 30, 1)
    for i = 0, 14 do D.px(8 + (i * 29) % 90, 6 + (i * 11) % 24, 5 + (i % 3) * 2) end
    D.px(54, 8, 15); D.line(52, 8, 56, 8, 10); D.line(54, 6, 54, 10, 10); D.line(55, 9, 60, 14, 6)
    -- le montagne di sughero, il muschio
    D.poly({ 4, 40, 20, 26, 36, 34, 52, 22, 70, 32, 88, 24, 100, 38, 100, 44, 4, 44 }, 3)
    D.rect(4, 44, 96, 14, 4)
    for i = 0, 60 do D.px(4 + (i * 17) % 96, 44 + (i * 5) % 13, 5 + (i % 3)) end
    -- il fiume di stagnola che luccica
    for x = 4, 99 do local y = 50 + sin(x * 0.12) * 2; D.px(x, y, (floor(t * 6 + x) % 7 == 0) and 15 or 10) end
    -- la capanna, la luce dentro
    D.poly({ 44, 44, 62, 44, 62, 34, 53, 30, 44, 34 }, 2)
    D.rect(48, 38, 10, 6, 6 + lu * 4)
    D.circle(52, 41, 1, 13); D.circle(55, 41, 1, 13)
    -- le lucine che lampeggiano
    for i = 0, 9 do D.px(8 + i * 10, 4, ((floor(t * 1.5) + i) % 3 == 0) and 15 or 4) end
    -- il pastore con l'agnello, i re magi che avanzano
    D.circle(30, 44, 1.2, 9); D.rect(29, 45, 2, 4, 8); D.circle(33, 48, 1.2, 13)
    local kx = 92 - s.kings * 26
    for k = 0, 2 do D.circle(kx + k * 3, 40, 1, 12 - k); D.rect(kx + k * 3 - 1, 41, 2, 4, 11 - k); D.px(kx + k * 3, 39, 15) end
    D.rect(0, 58, 128, 6, 2)
    s.fig:draw()
  end,
}

-------------------------------------------------------------------------------
-- LA PARTITA IN PIAZZA: le porte con gli zaini, il pallone sotto la macchina
-------------------------------------------------------------------------------
S.partita = {
  init = function(s)
    s.kids = {}
    for i = 1, 5 do s.kids[i] = D.figura(R(20, 108), 56, { s = 0.95, l = 2, dark = true, child = true, speed = R(8, 12), on_step = H.steps("pietra", 0.12) }) end
    s.fig = s.kids[1]
    s.ball = { x = 64, y = 54, vx = 0, vy = 0 }
    s.call = 0
  end,
  update = function(s, dt, t)
    local b = s.ball
    for i, k in ipairs(s.kids) do
      think(k, function() return { { "walk", b.x + R(-8, 8), k.speed }, { "pose", "stand", R(0.3, 1) } } end)
      k:update(dt)
      if abs(k.x - b.x) < 3 and random() < dt * 4 then b.vx = R(-40, 40); b.vy = -R(10, 30) end
    end
    b.vy = b.vy + 60 * dt
    b.x = b.x + b.vx * dt; b.y = b.y + b.vy * dt
    if b.y > 54 then b.y = 54; b.vy = -b.vy * 0.4; b.vx = b.vx * 0.85 end
    if b.x < 6 or b.x > 122 then b.vx = -b.vx; b.x = max(6, min(122, b.x)) end
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 30, 8 + lu * 2, 11 + lu)
    -- la piazza: la fontana, i palazzi, la macchina del farmacista
    D.rect(0, 10, 30, 40, 5); D.rect(98, 6, 30, 44, 5)
    for y = 14, 40, 8 do D.rect(6, y, 4, 5, 3); D.rect(18, y, 4, 5, 3); D.rect(104, y, 4, 5, 3); D.rect(116, y, 4, 5, 3) end
    D.rect(40, 30, 48, 20, 6); D.poly({ 38, 30, 90, 30, 64, 20 }, 7)
    D.rect(0, 50, 128, 14, 7)
    D.rect(90, 44, 22, 6, 3); D.rect(94, 40, 12, 4, 4); D.circle(94, 50, 2, 1); D.circle(108, 50, 2, 1)
    -- le porte fatte con gli zaini
    D.rect(8, 52, 4, 3, 3); D.rect(22, 52, 4, 3, 3); D.rect(102, 52, 4, 3, 2); D.rect(116, 52, 4, 3, 2)
    D.circle(s.ball.x, s.ball.y, 1.5, 14)
    for _, k in ipairs(s.kids) do k:draw() end
  end,
}

-------------------------------------------------------------------------------
-- SENZA ROTELLE: la mano dietro la sella, poi lontana
-------------------------------------------------------------------------------
S.prima_bici = {
  init = function(s)
    s.k = 0
    s.cr = 0
    s.nonno = D.figura(20, 56, { s = 1.2, l = 2, dark = true, pose = "bend", speed = 4 })
    s.fig = D.figura(28, 52, { s = 1.0, l = 2, dark = true, child = true, pose = "pedal" })
  end,
  update = function(s, dt, t)
    s.k = (s.k + dt / 26) % 1
    s.cr = s.cr + dt * 5
    s.nonno:update(dt)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 34, 9 + lu * 2, 12 + lu)
    for i = 0, 7 do D.tree(i * 18 + 6, 36, 14, 5, i + 3, sin(t + i) * mac("vento")) end
    D.rect(0, 36, 128, 28, 8)
    D.poly({ 0, 64, 0, 52, 128, 48, 128, 64 }, 9)
    -- la bici si stacca dalla mano: prima insieme, poi lui resta indietro
    local k = s.k
    local bx = 28 + max(0, k - 0.25) * 120
    if bx > 140 then bx = 140 end
    local hold = k < 0.3
    s.nonno.x = hold and (bx - 8) or (bx - 8 - (k - 0.3) * 30)
    if s.nonno.x > 30 and not hold then s.nonno.x = max(20, 30 - (k - 0.3) * 20) end
    s.nonno:set(hold and "bend" or "arms_open")
    local by = 54
    for _, wx in ipairs({ bx - 6, bx + 6 }) do
      D.circle(wx, by - 3.5, 3.5, 2, true)
      D.line(wx, by - 3.5, wx + cos(s.cr * 2) * 3, by - 3.5 + sin(s.cr * 2) * 3, 2)
    end
    D.line(bx - 6, by - 3.5, bx, by - 3.5, 2); D.line(bx, by - 3.5, bx - 2, by - 8, 2)
    D.line(bx - 2, by - 8, bx + 4, by - 8, 2); D.line(bx + 4, by - 8, bx + 6, by - 3.5, 2)
    D.line(bx + 4, by - 8, bx + 4, by - 10, 2)
    local f = s.fig
    f.x, f.y = bx - 2.5, by - 3.5
    f.cur.lean = 18; f.cur.ua1 = 70; f.cur.ua2 = 66; f.cur.fa1 = 90; f.cur.fa2 = 86; f.cur.hy = 4.4
    f.cur.th1 = 60 + sin(s.cr) * 25; f.cur.th2 = 60 - sin(s.cr) * 25
    f.cur.sh1 = f.cur.th1 - 60 - cos(s.cr) * 20; f.cur.sh2 = f.cur.th2 - 60 + cos(s.cr) * 20
    f:draw()
    s.nonno:draw()
  end,
}

-------------------------------------------------------------------------------
-- LE POZZANGHERE: gli stivali rossi, il cielo dentro ogni pozza
-------------------------------------------------------------------------------
S.pozzanghere = {
  init = function(s)
    s.fig = D.figura(20, 56, { s = 1.05, l = 2, dark = true, child = true, speed = 6, on_step = H.steps("acqua", 0.25) })
    s.pools = { { x = 34, w = 16, r = 0 }, { x = 70, w = 20, r = 0 }, { x = 104, w = 14, r = 0 } }
    s.splash = D.parts(40)
    s.rain = D.parts(60)
  end,
  update = function(s, dt, t)
    think(s.fig, function()
      local p = s.pools[random(#s.pools)]
      return { { "walk", p.x - 6, 6 }, { "pose", "bend", 0.4 }, { "glide", p.x + p.w / 2, 50, 0.3 }, { "glide", p.x + p.w / 2, 56, 0.25 },
        { "fn", function() p.r = 1; for i = 1, 12 do D.spawn(s.splash, { x = p.x + p.w / 2 + R(-4, 4), y = 56, vx = R(-20, 20), vy = -R(10, 30), life = 0.8 }) end
          S.env.sfx("drop", 700, 0.04, 0.2, pan(p.x), 0.4, 0.001) end }, { "pose", "arms_open", 1.5 }, { "pose", "stand", R(1, 3) } }
    end)
    s.fig:update(dt)
    for _, p in ipairs(s.pools) do p.r = max(0, p.r - dt * 0.7) end
    D.parts_update(s.splash, dt, function(p, d) p.vy = p.vy + 60 * d end)
    D.rain_update(s.rain, dt, 0.3 + mac("pioggia") * 2, 58, -3)
  end,
  draw = function(s, t)
    local lu = mac("luce")
    D.gradient(0, 40, 6 + lu * 3, 9 + lu * 2)
    D.cloud(20 + (t * 0.5) % 40, 8, 40, 9, 2)
    for i = 0, 6 do D.house(i * 20, 44, 14, 10 + (i % 3) * 3, 5, 4) end
    D.rect(0, 44, 128, 20, 4)
    -- le pozzanghere col cielo dentro, e lui riflesso
    for _, p in ipairs(s.pools) do
      D.rect(p.x, 56, p.w, 3, 9 + lu * 2)
      D.line(p.x + 3, 57, p.x + p.w - 4, 57, 12)
      if p.r > 0 then for k = 1, 2 do D.ripple(p.x + p.w / 2, 57, (1 - p.r) * p.w * 0.5 * k, 13 * p.r) end end
    end
    D.rain_draw(s.rain, 0.7)
    s.fig:draw()
    -- gli stivali
    for _, p in ipairs(s.splash.list) do D.px(p.x, p.y, 13) end
  end,
}

end
