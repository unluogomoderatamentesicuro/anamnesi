-- ANAMNESI v7
-- un viaggio nei ricordi
-- veri e immaginati
--
-- E1 E2 E3: le macro
-- del luogo
-- K2 scegli il sentiero
-- K3 cammina
-- K1+K2 evoca
-- K1+K3 ora / allora
-- K1+E1 volume
--
-- un luogo
-- moderatamente sicuro

engine.name = "Anamnesi"

local D = include("lib/disegno")
local K = include("lib/kit")
local C = include("lib/compositore")
local L = include("lib/luoghi")
local S = include("lib/scene")
local E = include("lib/episodi")
local Pr = include("lib/prologo")

local floor, sin, cos, random, abs, min, max, pi =
  math.floor, math.sin, math.cos, math.random, math.abs, math.min, math.max, math.pi

local FPS = 15
local FADE_OUT, CARD, FADE_IN = 1.6, 3.4, 2.6

local st = {
  t = 0, tp = 0, mode = "lingua", lt = 0, lang = 1,
  place = nil, scene = nil, ss = nil,
  exits = {}, sel = nil, sel_t = -99,
  travel = nil, k1 = false,
  msg = nil, msg_t = -99,
  macro = nil, macro_t = -99,
  lb = 0, lb_t = 0,                 -- le bande nere del cinema
  pages = {}, page = nil, page_t = -99, next_text = 14, text_i = 0,
  visited = {}, revealed = {}, capitolo = 0,
  idle = 0, arrived = 0, fade = 1,
  stime = 0, evo_t = -99,           -- il tempo della scena (rallenta nel ricordo), l'ultima evocazione
}
local redraw_metro

-------------------------------------------------------------------------------
-- parole
-------------------------------------------------------------------------------
local UI = {
  evoca = { "evoca", "evoke" }, ora = { "ora: com'è adesso", "now: as it is" }, allora = { "allora: com'era", "back then: as it was" },
  apre = { "un sentiero si apre", "a path opens" },
  scegli = { "scegli la lingua", "choose your language" },
  conferma = { "E2 scegli, K3 conferma", "E2 choose, K3 confirm" },
  volume = { "volume", "volume" }, spazio = { "spazio", "space" },
  capitolo = { "capitolo", "chapter" },
}
local function tx(t) return t[st.lang] or t[1] end

local TR = {
  ["à"] = "a'", ["è"] = "e'", ["é"] = "e'", ["ì"] = "i'", ["ò"] = "o'", ["ù"] = "u'",
  ["À"] = "A'", ["È"] = "E'", ["É"] = "E'", ["Ì"] = "I'", ["Ò"] = "O'", ["Ù"] = "U'",
  ["’"] = "'", ["‘"] = "'", ["“"] = '"', ["”"] = '"', ["…"] = "...", ["—"] = "-", ["«"] = '"', ["»"] = '"',
}
local function pixel_font() return params:get("carattere") == 1 end
local function tr(s)
  if not pixel_font() then return s end
  return (s:gsub("[%z\1-\127\194-\244][\128-\191]*", function(c) return TR[c] or c end))
end
Pr.tr = tr
D.tr = tr

local function font()
  if pixel_font() then screen.font_face(1); screen.font_size(8)
  else screen.font_face(4); screen.font_size(8) end
end

local function wrap(s, maxw)
  font()
  local lines, cur = {}, ""
  for w in s:gmatch("%S+") do
    local try = cur == "" and w or (cur .. " " .. w)
    if screen.text_extents(try) > maxw and cur ~= "" then lines[#lines + 1] = cur; cur = w else cur = try end
  end
  if cur ~= "" then lines[#lines + 1] = cur end
  return lines
end

-- testo con un bordo scuro: si legge sopra qualsiasi scena
local function text_out(x, y, s, l, align)
  font()
  local w = screen.text_extents(s)
  local x0 = x
  if align == "center" then x0 = x - w / 2 elseif align == "right" then x0 = x - w end
  x0 = floor(x0)
  screen.level(0)
  for _, o in ipairs({ { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }) do screen.move(x0 + o[1], y + o[2]); screen.text(s) end
  screen.level(D.clamp(floor(l + 0.5), 0, 15)); screen.move(x0, y); screen.text(s)
end

local function arrow(x, y, dir, l)
  screen.level(l)
  if dir == "su" then screen.move(x - 3, y + 2); screen.line(x, y - 1); screen.line(x + 3, y + 2)
  elseif dir == "giu" then screen.move(x - 3, y - 2); screen.line(x, y + 1); screen.line(x + 3, y - 2)
  elseif dir == "sx" then screen.move(x + 2, y - 3); screen.line(x - 1, y); screen.line(x + 2, y + 3)
  elseif dir == "dx" then screen.move(x - 2, y - 3); screen.line(x + 1, y); screen.line(x - 2, y + 3)
  else screen.move(x, y - 3); screen.line(x, y + 3); screen.stroke(); screen.move(x - 3, y); screen.line(x + 3, y) end
  screen.stroke()
end

-------------------------------------------------------------------------------
-- ganci tra le scene e la musica
-------------------------------------------------------------------------------
S.env.sfx = function(...) C.sfx(...) end
S.env.step = function(...) C.step(...) end
S.env.play = function(inst, midi, amp, dur, pan, bright, atk) C.play(inst, midi, amp, dur, pan, bright, atk) end
S.env.chord_midi = function(oct)
  local sc = C.scala()
  return C.prof.tonica + 12 * (oct or 0) + C.deg2semi(C.chord[random(#C.chord)], sc)
end
S.env.sel = function()
  local e = st.sel and st.exits and st.exits[st.sel]
  if e and st.t - st.sel_t < 8 then return e.dir end
end
S.env.mac = function(id)
  local v = C.mac[id]
  if v == nil then return 0 end
  return v
end
S.env.lang = function() return st.lang end
C.hooks.note = function(ev)
  if st.mode == "luogo" and st.scene and st.scene.note then
    -- i colpi del ritmo arrivano solo alle scene che li sanno guardare
    if ev.ruolo == "ritmo" and not st.scene.ritmo then return end
    st.scene.note(st.ss, ev)
  end
end

-------------------------------------------------------------------------------
-- luoghi
-------------------------------------------------------------------------------
local function nome(p) return tr(tx(p.nome)) end

local function build_pages(p)
  local allora = C.at > 0.5
  local choice
  if st.text_i == 0 then
    choice = allora and p.allora or p.ora
  else
    local pool = { p.ora, p.allora }
    for _, a in ipairs(p.altro or {}) do pool[#pool + 1] = a; pool[#pool + 1] = a end
    choice = (allora and random() < 0.6) and p.allora or pool[random(#pool)]
  end
  st.text_i = st.text_i + 1
  return wrap(tr(tx(choice)), 122)
end

local function arrive(id, quick)
  local p = L.by_id[id]
  if id == "altrove" then L.altrove(p) end
  st.place = p
  st.scene = S[id]
  st.ss = {}
  if st.scene and st.scene.init then st.scene.init(st.ss, p) end
  st.tp = 0
  st.sel, st.sel_t = nil, -99
  st.pages, st.page = {}, nil
  st.text_i = 0
  st.next_text = 16
  st.arrived = st.t
  st.visited[id] = true
  st.exits = L.uscite(p, 0)
  C.go(p, quick)
end

local function refresh_exits()
  local before = #st.exits
  st.exits = L.uscite(st.place, st.tp)
  if #st.exits > before then
    st.msg = tx(UI.apre); st.msg_t = st.t
    C.sfx("celesta", 1760, 0.05, 4, 0.3, 0.2, 0.001)
    C.sfx("celesta", 2637, 0.035, 5, -0.3, 0.2, 0.001)
  end
end

local function roman(n)
  local v = { { 50, "L" }, { 40, "XL" }, { 10, "X" }, { 9, "IX" }, { 5, "V" }, { 4, "IV" }, { 1, "I" } }
  local out = ""
  if n >= 100 then return tostring(n) end
  for _, p in ipairs(v) do while n >= p[1] do out = out .. p[2]; n = n - p[1] end end
  return out
end

local function start_travel(exit)
  local dest = L.by_id[exit.id]
  local name = E.scegli(exit.dir, st.place, dest)
  local run = E.nuovo(name, exit.dir, st.place, dest)
  st.capitolo = st.capitolo + 1
  local ep0 = FADE_OUT + CARD
  st.travel = {
    to = exit.id, dir = exit.dir, t = 0, switched = false, dest = dest, from_strato = st.place.strato,
    run = run, ep0 = ep0, ep1 = ep0 + run.dur, cap = st.capitolo,
  }
  st.travel.total = st.travel.ep1 + FADE_IN
  st.mode = "viaggio"
  st.sel = nil
  st.page = nil; st.pages = {}
  C.travel(true, dest)
end

local function select_next(d)
  if #st.exits == 0 then return end
  if st.sel == nil or st.t - st.sel_t > 8 then st.sel = 1
  else st.sel = ((st.sel - 1 + (d or 1)) % #st.exits) + 1 end
  st.sel_t = st.t
end

-------------------------------------------------------------------------------
-- aggiornamento
-------------------------------------------------------------------------------
local function update(dt)
  st.t = st.t + dt
  st.idle = st.idle + dt
  C.update(dt)
  D.veil = 0
  -- nel ricordo il tempo rallenta
  local sdt = dt * (1 - 0.45 * C.ac)
  st.stime = st.stime + sdt
  local base_gain = C.vis.gain or 1

  if st.mode == "lingua" then
    st.lt = st.lt + dt
    if st.lt > 10 then st.choose_lang() end
    return
  end

  if st.mode == "prologo" then
    D.gain = 1
    if Pr.update(dt) then
      st.mode = "luogo"; st.arrived = st.t; st.fade = 0
      C.go(st.place, false)
      C.arrivo()
    end
    return
  end

  -- le bande nere scendono quando c'è qualcosa da leggere
  local want = 0
  local since = st.t - st.arrived
  if st.mode == "luogo" and (since < 7 or st.page) then want = 1 end
  -- anche quando scegli un sentiero, giri una manopola o arriva un messaggio:
  -- le scritte stanno sempre nelle bande nere, mai sopra il disegno
  if st.mode == "luogo" and ((st.sel and st.t - st.sel_t < 8) or (st.macro and st.t - st.macro_t < 2.5) or (st.msg and st.t - st.msg_t < 3)) then want = 1 end
  if st.mode == "viaggio" then want = 1 end
  st.lb = st.lb + (want - st.lb) * min(1, dt * 2.2)

  local f = st.ss and st.ss.fig
  if f and f.s and not f.dress and not f.bun then
    if f.base_s == nil then f.base_s = f.s; f.base_child = f.child or false end
    if not f.base_child then
      local k = C.ac
      f.s = f.base_s * (1 - 0.24 * k)
      f.child = k > 0.5
    end
  end

  if st.mode == "luogo" then
    st.tp = st.tp + dt
    st.fade = min(1, st.fade + dt / 2.5)
    D.gain = base_gain * st.fade
    if st.scene and st.scene.update then st.scene.update(st.ss, sdt, st.stime) end
    if st.place.nascosti then refresh_exits() end
    local pmode = params:get("parole")
    if pmode < 3 then
      if st.page then
        if st.t - st.page_t > 4.2 then
          st.page = nil
          if #st.pages > 0 then st.page = table.remove(st.pages, 1); st.page_t = st.t end
        end
      elseif st.tp > st.next_text then
        st.pages = build_pages(st.place)
        st.page = table.remove(st.pages, 1)
        st.page_t = st.t + 0.8
        st.next_text = st.tp + (pmode == 1 and random(45, 75) or random(110, 200))
      end
    end
    local v = params:get("vagare")
    if v > 1 then
      local mins = ({ 0, 5, 10, 20, 40 })[v]
      if st.tp > mins * 60 and st.idle > mins * 60 and #st.exits > 0 then
        local e = st.exits[random(#st.exits)]
        for _ = 1, 3 do local c = st.exits[random(#st.exits)]; if not st.visited[c.id] then e = c end end
        start_travel(e)
      end
    end
    return
  end

  if st.mode == "viaggio" then
    local tv = st.travel
    tv.t = tv.t + dt
    if tv.t < FADE_OUT then
      -- il luogo che si lascia si spegne piano
      D.gain = base_gain * (1 - tv.t / FADE_OUT)
      if st.scene and st.scene.update then st.scene.update(st.ss, sdt, st.stime) end
    elseif not tv.switched then
      tv.switched = true
      arrive(tv.to, false)
      C.ponte()
    elseif tv.t < tv.ep0 then
      -- il cartello del capitolo
    elseif tv.t < tv.ep1 then
      -- l'episodio
      local n = E.update(tv.run, dt)
      if n > 0 then C.step(tv.run.terreno, 0, 0.55) end
    elseif tv.t < tv.total then
      if not tv.landed then tv.landed = true; C.travel(false); C.arrivo(); st.arrived = st.t end
      D.gain = base_gain * ((tv.t - tv.ep1) / FADE_IN)
      if st.scene and st.scene.update then st.scene.update(st.ss, sdt, st.stime) end
    else
      st.mode = "luogo"
      st.fade = 1
      st.travel = nil
      C.travel(false)
    end
  end
end

-- K3 durante il viaggio: si salta alla fine dell'episodio
local function skip_travel()
  local tv = st.travel
  if not tv or tv.t >= tv.ep1 then return end
  if not tv.switched then tv.switched = true; arrive(tv.to, false) end
  tv.t = max(tv.t, tv.ep1 - 0.01)
end

-------------------------------------------------------------------------------
-- disegno
-------------------------------------------------------------------------------
local function bars()
  local h = floor(st.lb * 8 + 0.5)
  if h <= 0 then return 0 end
  screen.level(0)
  screen.rect(0, 0, 128, h); screen.rect(0, 64 - h, 128, h); screen.fill()
  return h
end

local function draw_interstitial()
  local tv = st.travel
  if tv.t < tv.ep0 then
    -- il cartello: nero, il numero del capitolo, il nome del luogo
    local tc = tv.t - FADE_OUT
    local a = max(0, min(1, tc / 0.9, (CARD - tc) / 0.7))
    font()
    local cap = tr(tx(UI.capitolo)) .. " " .. roman(tv.cap)
    screen.level(floor(4 * a + 0.5)); screen.move(64, 21); screen.text_center(cap)
    local nm = nome(tv.dest)
    local rows = wrap(nm, 120)
    local w = 0
    for i, r in ipairs(rows) do
      screen.level(floor(13 * a + 0.5)); screen.move(64, 35 - (#rows - 1) * 9 + (i - 1) * 9); screen.text_center(r)
      w = math.max(w, screen.text_extents(r))
    end
    local lw = floor(min(1, tc / 1.8) * (w + 8))
    if lw > 0 then screen.level(floor(4 * a + 0.5)); screen.move(64 - lw / 2, 39.5); screen.line(64 + lw / 2, 39.5); screen.stroke() end
    if tv.dest.strato ~= tv.from_strato then
      screen.level(floor(4 * a + 0.5)); screen.move(64, 52); screen.text_center(tr(tx(L.STRATI[tv.dest.strato])))
    end
    return
  end
  -- l'episodio, dentro le bande del cinema
  local te = tv.t - tv.ep0
  local a = max(0, min(1, te / 0.7, (tv.ep1 - tv.t) / 0.6))
  E.draw(tv.run, st.t, a)
  D.gain = 1
  bars()
  if st.msg and st.t - st.msg_t < 3 then
    local age = st.t - st.msg_t
    font(); screen.level(floor(12 * min(1, age * 3, (3 - age) / 0.8))); screen.move(64, 63); screen.text_center(tr(st.msg))
  end
end

-- un nome troppo lungo per lo schermo perde l'articolo, poi si accorcia
local function fit(s, maxw)
  font()
  if screen.text_extents(s) <= maxw then return s end
  local t = s:gsub("^[A-Za-z]+'", ""):gsub("^%a%a?%a? ", "", 1)
  if screen.text_extents(t) <= maxw then return t end
  while #t > 3 and screen.text_extents(t .. "..") > maxw do t = t:sub(1, -2) end
  return t .. ".."
end

-- l'anno di un ricordo, sempre lo stesso per ogni luogo
local function anno(p)
  local h = 0
  for i = 1, #p.id do h = (h * 31 + p.id:byte(i)) % 997 end
  return 1977 + h % 19
end

-- allora: la scena diventa una vecchia fotografia, angoli tondi, la data stampata
local function draw_memory()
  local a = C.ac
  if a > 0.02 then
    local r = floor(4 + 10 * a)
    screen.level(0)
    for y = 0, r do
      local w = r - math.sqrt(math.max(0, r * r - (r - y) * (r - y)))
      w = floor(w + 0.5)
      if w > 0 then
        screen.rect(0, y, w, 1); screen.rect(128 - w, y, w, 1)
        screen.rect(0, 63 - y, w, 1); screen.rect(128 - w, 63 - y, w, 1)
      end
    end
    screen.fill()
    screen.level(floor(4 * a)); screen.rect(1.5, 1.5, 125, 61); screen.stroke()
    if a > 0.3 then
      font()
      screen.level(floor(10 * (a - 0.3) / 0.7))
      screen.move(122, 59); screen.text_right("'" .. string.format("%02d", anno(st.place) % 100))
    end
  end
  -- evoca: la luce che sale da lui
  local e = st.t - st.evo_t
  if e < 7 then
    local f = st.ss and st.ss.fig
    local fx, fy = 64, 40
    if f and f.x then fx, fy = f.x, f.y - 10 end
    for i = 1, 22 do
      local ph = (i * 0.618) % 1
      local k = (e / 6 + ph) % 1
      local x = fx + math.sin(i * 2.4 + e * 0.8) * (4 + k * 18)
      local y = fy - k * 42
      local l = (1 - k) * 13 * math.min(1, e * 2, (7 - e) / 1.5)
      if l > 0.5 and y > 0 then screen.level(floor(l)); screen.pixel(floor(x), floor(y)); screen.fill() end
    end
  end
end

local function evoke()
  C.evoca()
  st.evo_t = st.t
  st.msg = tx(UI.evoca); st.msg_t = st.t
  local p = st.place
  local pool = {}
  for _, t in ipairs(p.altro or {}) do pool[#pool + 1] = t end
  if #pool == 0 then pool = { p.ora, p.allora } end
  st.pages = wrap(tr(tx(pool[random(#pool)])), 122)
  st.page = table.remove(st.pages, 1); st.page_t = st.t + 1.2
  st.tp = math.max(st.tp, 1)
end

local function hint_active()
  local e = st.sel and st.exits[st.sel]
  return e and (st.t - st.sel_t) <= 8
end

-- il sentiero scelto: il nome scritto nella banda nera di sotto, con la sua freccia
local function draw_hint()
  local e = st.sel and st.exits[st.sel]
  if not e then return end
  local age = st.t - st.sel_t
  if age > 8 then return end
  local h = floor(st.lb * 8 + 0.5)
  if h < 6 then return end
  local a = min(1, age * 4, (8 - age) / 1.5)
  local l = floor(12 * a + 0.5)
  local nm = fit(nome(L.by_id[e.id]), 108)
  font()
  local w = screen.text_extents(nm)
  local x0 = floor(64 - w / 2)
  screen.level(l); screen.move(x0, 63); screen.text(nm)
  -- la freccia, accanto al nome, nella banda
  local d = e.dir
  if d == "su" then arrow(x0 - 6, 59, "su", l)
  elseif d == "giu" then arrow(x0 - 6, 59, "giu", l)
  elseif d == "sx" then arrow(x0 - 6, 59, "sx", l)
  elseif d == "dx" then arrow(x0 + w + 4, 59, "dx", l)
  else arrow(x0 - 6, 59, "segreto", l) end
  -- quanti sentieri ci sono, puntini nella banda di sopra
  for i = 1, #st.exits do
    screen.level(i == st.sel and l or floor(l / 3))
    screen.rect(64 - #st.exits * 2 + (i - 1) * 4, 3, 2, 1); screen.fill()
  end
end

local function draw_strata(a)
  if a <= 0 then return end
  for s = -3, 3 do
    local y = 32 - s * 5
    local cur = st.place and st.place.strato == s
    screen.level(floor((cur and 10 or 2) * a))
    if cur then screen.rect(124, y - 1, 2, 3) else screen.rect(125, y, 1, 1) end
    screen.fill()
  end
end

local function macro_label(i)
  local id = st.place.macro and st.place.macro[i]
  local M = id and C.MACRO[id]
  if not M then return "", 0, false end
  local v = C.mt[i]
  if M.bip then
    local name = (v < 0.5 and M[2]) and M[2] or M[1]
    return tr(tx(name)), v * 2 - 1, true
  end
  return tr(tx(M[1])), v, false
end

local function draw_overlays()
  local h = bars()
  local since = st.t - st.arrived
  local hint = hint_active()
  local mac_on = st.macro and st.t - st.macro_t < 2.5
  -- il nome del luogo, nella banda in alto
  if since < 7 and h >= 6 and not mac_on and not hint then
    local a = min(1, since / 1.2, (7 - since) / 1.2)
    if a > 0 then
      font()
      screen.level(floor(12 * a)); screen.move(64, 6); screen.text_center(fit(nome(st.place), 124))
      if not st.page then screen.level(floor(4 * a)); screen.move(64, 63); screen.text_center(tr(tx(L.STRATI[st.place.strato]))) end
    end
    draw_strata(a)
  end
  -- le parole del luogo, nella banda in basso: una riga alla volta
  if st.page and st.t >= st.page_t and h >= 6 and not hint then
    local age = st.t - st.page_t
    local a = min(1, age / 0.7, (4.2 - age) / 0.7)
    if a > 0 then
      font()
      screen.level(floor(11 * a + 0.5)); screen.move(64, 63); screen.text_center(st.page)
    end
  end
  draw_hint()
  -- la macro che stai muovendo: il nome a destra nella banda in alto, la barra a sinistra
  if mac_on and h >= 6 then
    local age = st.t - st.macro_t
    local a = min(1, (2.5 - age) / 0.6)
    local name, v, bip = st.macro[1], st.macro[2], st.macro[3]
    local l = floor(12 * a)
    font()
    screen.level(l); screen.move(125, 6); screen.text_right(name)
    local bx, bw, by = 3, 46, 3
    screen.level(floor(3 * a)); screen.rect(bx, by, bw, 1); screen.fill()
    screen.level(l)
    if bip then
      local c = bx + floor(bw / 2)
      local w = floor(v * bw / 2)
      if w >= 0 then screen.rect(c, by - 1, w + 1, 3) else screen.rect(c + w, by - 1, -w + 1, 3) end
      screen.fill()
      screen.level(floor(6 * a)); screen.rect(c, by - 2, 1, 5); screen.fill()
    else
      screen.rect(bx, by - 1, max(1, floor(v * bw)), 3); screen.fill()
    end
  end
  if st.msg and st.t - st.msg_t < 3 and h >= 6 and not hint then
    local age = st.t - st.msg_t
    local a = min(1, age * 3, (3 - age) / 0.8)
    font()
    screen.level(floor(12 * a)); screen.move(64, 63); screen.text_center(tr(st.msg))
  end
end

local function draw_lingua()
  screen.level(0); screen.rect(0, 0, 128, 64); screen.fill()
  local a = min(1, st.lt / 1)
  screen.font_face(1); screen.font_size(8)
  screen.level(floor(5 * a)); screen.move(64, 12); screen.text_center(st.lang == 1 and "scegli la lingua" or "choose your language")
  local opts = { "ITALIANO", "ENGLISH" }
  for i = 1, 2 do
    local y = 28 + (i - 1) * 12
    local sel = st.lang == i
    screen.level(floor((sel and 14 or 4) * a)); screen.move(64, y); screen.text_center(opts[i])
    if sel then screen.level(floor(10 * a)); screen.move(34, y); screen.text("-"); screen.move(91, y); screen.text("-") end
  end
  screen.level(floor(3 * a)); screen.move(64, 58); screen.text_center(st.lang == 1 and "E2 scegli, K3 conferma" or "E2 choose, K3 confirm")
end

function redraw()
  screen.clear()
  screen.aa(0)
  screen.line_width(1)
  if st.mode == "lingua" then draw_lingua()
  elseif st.mode == "prologo" then Pr.draw()
  elseif st.mode == "viaggio" and st.travel.t >= FADE_OUT and st.travel.t < st.travel.ep1 then draw_interstitial()
  else
    if st.scene and st.scene.draw then
      -- la macchina da presa: all'arrivo scende o scorre sul luogo, alla partenza se ne va
      local ox, oy = 0, 0
      local since = st.t - (st.arrived or 0)
      if since < 5 and st.mode ~= "prologo" then
        local k = 1 - since / 5
        k = k * k * (3 - 2 * k)
        local mv = st.place and (#st.place.id % 3) or 0
        if mv == 0 then oy = k * 16 elseif mv == 1 then ox = -k * 20 else ox = k * 20 end
      end
      if st.mode == "viaggio" and st.travel and st.travel.t < FADE_OUT then
        local k = st.travel.t / FADE_OUT
        oy = -k * k * 10
      end
      if S.H.cam then S.H.cam(ox, oy, function() st.scene.draw(st.ss, st.stime) end)
      else st.scene.draw(st.ss, st.stime) end
    end
    D.gain = 1
    if st.mode == "luogo" or st.mode == "viaggio" then draw_memory(); draw_overlays() end
  end
  screen.update()
end

-------------------------------------------------------------------------------
-- controlli
-------------------------------------------------------------------------------
local function lang_file() return norns.state.data .. "lingua.txt" end

function st.choose_lang()
  params:set("lingua", st.lang)
  if util and util.make_dir then util.make_dir(norns.state.data) end
  local f = io.open(lang_file(), "w")
  if f then f:write(tostring(st.lang)); f:close() end
  local pv = params:get("prologo")
  local first = not st.seen_prologue
  if pv == 1 or (pv == 2 and first) then
    st.mode = "prologo"
    Pr.init(st.lang, function(f2) C.step("ghiaia", (f2.x - 64) / 64, 0.4) end)
    clock.run(function() clock.sleep(7); if st.mode == "prologo" then C.ponte() end end)
  else
    st.mode = "luogo"; st.arrived = st.t; st.fade = 0
    C.go(st.place, false)
    C.arrivo()
  end
end

local function wake()
  st.idle = 0
  if st.mode == "prologo" then
    st.mode = "luogo"; st.arrived = st.t; st.fade = 0
    C.go(st.place, false)
    C.arrivo()
    return true
  end
  return false
end

local function show_macro(i)
  local name, v, bip = macro_label(i)
  st.macro = { name, v, bip }
  st.macro_t = st.t
end

function enc(n, d)
  if st.mode == "lingua" then
    st.lang = D.clamp(st.lang + (d > 0 and 1 or -1), 1, 2); st.lt = math.max(st.lt, 1); return
  end
  if wake() then return end
  if st.k1 then
    if n == 1 then params:delta("vol", d); st.macro = { tx(UI.volume), params:get("vol"), false }; st.macro_t = st.t
    elseif n == 2 then if st.mode == "luogo" then select_next(d > 0 and 1 or -1) end
    else params:delta("spazio", d); st.macro = { tx(UI.spazio), params:get("spazio") / 0.4, true }; st.macro_t = st.t end
    return
  end
  -- ogni scatto muove la macro di un trentesimo: in un giro si va da un capo all'altro
  params:set("m" .. n, D.clamp(params:get("m" .. n) + d * 0.033, 0, 1))
  show_macro(n)
end

function key(n, z)
  if n == 1 then st.k1 = (z == 1); return end
  if z == 0 then return end
  if st.mode == "lingua" then
    if n == 3 then st.choose_lang() elseif n == 2 then st.lang = st.lang == 1 and 2 or 1 end
    return
  end
  if wake() then return end
  if st.mode == "viaggio" and st.travel and st.travel.t >= st.travel.ep1 then
    -- sta già arrivando: il viaggio finisce qui e il tasto vale nel luogo
    if not st.travel.landed then C.travel(false); C.arrivo() end
    st.mode = "luogo"; st.fade = 1; st.travel = nil; C.travel(false)
  end
  if st.mode == "viaggio" and n == 3 and not st.k1 then skip_travel(); return end
  -- anche in viaggio: evocare e ricordare valgono già per il luogo dove stai andando
  if st.mode == "viaggio" and st.k1 and st.travel and st.travel.switched then
    if n == 2 then evoke()
    else
      params:set("allora", params:get("allora") == 1 and 2 or 1)
      st.msg = params:get("allora") == 2 and tx(UI.allora) or tx(UI.ora); st.msg_t = st.t
    end
    return
  end
  if st.mode ~= "luogo" then return end
  if n == 2 then
    if st.k1 then evoke()
    else select_next(1) end
  elseif n == 3 then
    if st.k1 then
      params:set("allora", params:get("allora") == 1 and 2 or 1)
      local al = params:get("allora") == 2
      st.msg = al and tx(UI.allora) or tx(UI.ora); st.msg_t = st.t
      -- e il luogo lo dice subito, nel suo tempo
      st.pages = wrap(tr(tx(al and st.place.allora or st.place.ora)), 122)
      st.page = table.remove(st.pages, 1); st.page_t = st.t + 0.6
      st.tp = math.max(st.tp, 1)
    else
      local e = st.sel and st.exits[st.sel]
      if e and st.t - st.sel_t <= 8 then start_travel(e) else select_next(0) end
    end
  end
end

-------------------------------------------------------------------------------
-- parametri
-------------------------------------------------------------------------------
local function add_params()
  params:add_separator("ANAMNESI")
  params:add_option("lingua", "lingua / language", { "italiano", "english" }, 1)
  params:set_action("lingua", function(v) st.lang = v end)
  params:add_control("vol", "volume", controlspec.new(0, 1, "lin", 0, 0.8, "", 0.01))
  params:set_action("vol", function(v) C.vol = v end)
  for i = 1, 3 do
    params:add_control("m" .. i, "macro " .. i, controlspec.new(0, 1, "lin", 0, 0.5, "", 0.01))
    params:set_action("m" .. i, function(v) C.mt[i] = v end)
  end
  params:add_option("allora", "ora / allora", { "ora", "allora" }, 1)
  params:set_action("allora", function(v) C.at = (v == 2) and 1 or 0 end)
  params:add_control("spazio", "spazio / space", controlspec.new(-0.4, 0.4, "lin", 0, 0, "", 0.0125))
  params:set_action("spazio", function(v) C.spazio = v end)
  params:add_option("parole", "parole / words", { "spesso", "a volte", "mai" }, 2)
  params:add_option("carattere", "carattere / font", { "pixel", "morbido" }, 1)
  params:add_option("vagare", "vagare / wander", { "mai", "5 min", "10 min", "20 min", "40 min" }, 1)
  params:add_option("inizio", "inizio / start", { "la soglia", "ultimo luogo" }, 1)
  params:add_option("prologo", "prologo", { "sempre", "la prima volta", "mai" }, 1)
  params:add_trigger("evoca", "evoca")
  params:set_action("evoca", function() if C.prof then C.evoca() end end)
end

local function last_file() return norns.state.data .. "ultimo.txt" end
local function load_last()
  local f = io.open(last_file(), "r")
  if not f then return nil end
  local id = f:read("*l"); f:close()
  if id and L.by_id[id] and id ~= "altrove" then return id end
  return nil
end
local function save_last()
  if not st.place then return end
  if util and util.make_dir then util.make_dir(norns.state.data) end
  local f = io.open(last_file(), "w")
  if f then f:write(st.place.id .. "\n"); f:close() end
end

-- quando arriva in un luogo, le tre manopole prendono i valori di quel luogo
local go_orig = C.go
C.go = function(place, quick)
  go_orig(place, quick)
  for i = 1, 3 do params:set("m" .. i, C.mt[i], true) end
end

-------------------------------------------------------------------------------
function init()
  math.randomseed(os.time())
  add_params()
  params:read()
  params:bang()
  local f = io.open(lang_file(), "r")
  if f then local v = tonumber(f:read("*l")); f:close(); if v == 1 or v == 2 then st.lang = v; st.seen_prologue = true end end
  local start = "soglia"
  if params:get("inizio") == 2 then start = load_last() or "soglia" end
  C.start()
  arrive(start, true)
  st.mode = "lingua"
  st.lt = 0
  redraw_metro = metro.init(function()
    update(1 / FPS)
    redraw()
  end, 1 / FPS, -1)
  redraw_metro:start()
end

function cleanup()
  save_last()
  params:write()
  if redraw_metro then redraw_metro:stop() end
  C.stop()
  _G.__anamnesi_disegno = nil
  _G.__anamnesi_kit = nil
end
