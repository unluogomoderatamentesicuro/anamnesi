-- ANAMNESI · le scene
-- Ogni luogo è un quadro vivo: init prepara, update fa succedere le cose,
-- draw dipinge, note ascolta la musica e risponde con la luce.
-- Le scene sono divise per strato in cinque file.

local D = include("lib/disegno")
local K = include("lib/kit")

local S = {}
S.env = {}       -- riempito dallo script: sfx, step, play, chord_midi, mac, lang

local random = math.random
local H = {}
function H.R(a, b) return a + random() * (b - a) end
function H.pick(t) return t[random(#t)] end
function H.pan(x) return D.clamp((x - 64) / 64, -1, 1) end
function H.copy(t) local o = {} for k, v in pairs(t) do o[k] = v end return o end
function H.think(fig, fn) if fig.idle then fig:act(fn()) end end
function H.steps(terrain, w) return function(f) S.env.step(terrain, H.pan(f.x), w or 0.5) end end
-- valore di una macro del luogo (0 se il luogo non la usa)
function H.mac(id) return (S.env.mac and S.env.mac(id)) or 0 end
-- parole nella lingua scelta: { {italiano...}, {english...} }
function H.lang() return S.env.lang and S.env.lang() or 1 end
function H.w(t) return H.pick(t[H.lang()] or t[1]) end
S.H = H

for _, f in ipairs({ "lib/scene_cielo", "lib/scene_infanzia", "lib/scene_paese", "lib/scene_case", "lib/scene_abisso",
  "lib/scene_ricordi_a", "lib/scene_ricordi_b", "lib/scene_ricordi_c", "lib/scene_ricordi_d",
  "lib/scene_ricordi_e", "lib/scene_ricordi_f", "lib/scene_ricordi_g", "lib/scene_ricordi_h", "lib/scene_ricordi_i", "lib/scene_ricordi_j" }) do
  include(f)(S, D, K, H)
end

return S
