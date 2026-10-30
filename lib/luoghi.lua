-- ANAMNESI · i luoghi
-- Sette strati, dall'alto in basso: in cima la pace, in fondo l'abisso.
-- Ogni luogo ha un terreno (i passi), le sue parole in due lingue,
-- tre macro sue e la sua musica.
--
-- ruoli: melodia, risposta, arpeggio, basso, accordo, scintille, coppa,
--        campane, pulsazione, sussurri, schegge, onde
-- strumenti: piano, rhodes, bell, musicbox, celesta, pluck, guitar, choir,
--            hum, bowed, strings, harmonium, organ, accordion, breath,
--            arcade, radio, coppa, campana, glitch, whisper, swell, sub, drop

local L = {}
local function T(it, en) return { it, en } end
local function l(ruolo, str, ott, amp, prob, x)
  local t = { ruolo = ruolo, str = str, ott = ott, amp = amp, prob = prob }
  for k, v in pairs(x or {}) do t[k] = v end
  return t
end

L.STRATI = {
  [3] = T("il cielo", "the sky"), [2] = T("le alture", "the heights"), [1] = T("l'infanzia", "childhood"),
  [0] = T("il paese", "the village"), [-1] = T("le case", "the houses"), [-2] = T("la mente", "the mind"),
  [-3] = T("l'abisso", "the abyss"),
}

L.lista = {

-------------------------------------------------------------------------------
-- +3 · IL CIELO
-------------------------------------------------------------------------------
{ id = "mare_stelle", strato = 3, x = 0.1, terreno = "nuvola", nome = T("Il mare di stelle", "The sea of stars"),
  ora = T("Non c'è più sotto né sopra. Galleggi in mezzo a luci che sono morte da migliaia di anni.",
          "There is no up or down any more. You float among lights that died thousands of years ago."),
  allora = T("Il soffitto della cameretta aveva stelle di plastica che brillavano al buio, per dieci minuti.",
             "The bedroom ceiling had plastic stars that glowed in the dark, for ten minutes."),
  altro = { T("Ogni luce è un nome che qualcuno ha detto ad alta voce.", "Every light is a name someone once said out loud.") },
  macro = { "stelle", "respiro", "eco" },
  musica = { tonica = 50, modo = "lidio", bpm = 50, prog = { 1, 2, 1, 5 }, accordo = "add9", battute = 4, glide = 14, tema = 0.15,
    drone = { amp = 0.42, cut = 1400, shape = 0.1, sub = 0.2, air = 0.35, breath = 0.45, detune = 0.15 },
    linee = { l("scintille", "celesta", 2, 0.2, 0.8, { bright = 0.2, legato = 3 }), l("accordo", "strings", 0, 0.2, 0.6, { atk = 3 }),
      l("melodia", "breath", 1, 0.28, 0.4, { legato = 2.2, riposo = 10 }), l("onde", "swell", 1, 0.25, 0.5) },
    tex = { wind = 0.05 }, fx = { rev = 0.82, size = 0.95, shimmer = 0.5, tape = 0.05, hiss = 0.05 } } },

{ id = "nuvole", strato = 3, x = 0.3, terreno = "nuvola", nome = T("Sopra le nuvole", "Above the clouds"),
  ora = T("Cammini sopra un mare bianco. Il sole è vicino, e non scotta.", "You walk on a white sea. The sun is close, and it doesn't burn."),
  allora = T("Dal finestrino dell'aereo pensavi che lassù si potesse camminare. Avevi ragione.",
             "From the plane window you thought you could walk up there. You were right."),
  altro = { T("Ogni passo affonda appena, come nella neve fresca.", "Every step sinks a little, like in fresh snow.") },
  macro = { "vento", "luce", "coro" },
  musica = { tonica = 55, modo = "lidio", bpm = 54, prog = { 1, 2, 4, 1 }, accordo = "add9", battute = 4, glide = 12, tema = 0.15,
    drone = { amp = 0.38, cut = 1700, shape = 0.2, sub = 0.2, air = 0.4, breath = 0.4 },
    linee = { l("accordo", "strings", 0, 0.22, 0.8, { atk = 3 }), l("melodia", "celesta", 1, 0.26, 0.6, { legato = 2.5 }),
      l("risposta", "breath", 1, 0.2, 0.5, { legato = 1.8 }), l("scintille", "bell", 2, 0.12, 0.4, { bright = 0.1 }) },
    tex = { wind = 0.22 }, fx = { rev = 0.75, size = 0.93, shimmer = 0.55, tape = 0.04 } } },

{ id = "empireo", strato = 3, x = 0.5, terreno = "nuvola", nome = T("La rosa di luce", "The rose of light"),
  ora = T("Cerchi di luce dentro altri cerchi, e in mezzo qualcosa che non si può guardare a lungo.",
          "Circles of light inside other circles, and in the middle something you cannot look at for long."),
  allora = T("Ci credevi da bambino, a mani giunte, senza fare domande. Forse era più semplice.",
             "You believed in it as a child, hands joined, asking nothing. Maybe it was simpler."),
  altro = { T("Qui tutto canta, anche quello che da laggiù sembrava solo rumore.", "Everything sings here, even what sounded like noise from down there.") },
  macro = { "luce", "coro", "stelle" },
  musica = { tonica = 52, modo = "ionio", bpm = 56, prog = { 1, 4, 6, 4 }, accordo = "add9", battute = 4, glide = 12, tema = 0.25,
    drone = { amp = 0.45, cut = 1800, shape = 0.25, sub = 0.25, air = 0.4, breath = 0.35 },
    linee = { l("accordo", "choir", 0, 0.26, 0.9, { atk = 2.5 }), l("melodia", "breath", 1, 0.3, 0.6, { legato = 1.8, riposo = 6 }),
      l("arpeggio", "celesta", 1, 0.16, 0.35, { bright = 0.3, legato = 4 }), l("campane", "campana", 0, 0.45, 0.15) },
    tex = { wind = 0.04 }, fx = { rev = 0.85, size = 0.96, shimmer = 0.7, tape = 0.04, hiss = 0.03 } } },

{ id = "aurora", strato = 3, x = 0.7, terreno = "neve", nome = T("L'aurora boreale", "The northern lights"),
  ora = T("Il cielo si muove come una tenda davanti a una finestra aperta.", "The sky moves like a curtain in front of an open window."),
  allora = T("Promettevi a qualcuno che un giorno l'avreste vista insieme.", "You promised someone you would see it together one day."),
  altro = { T("Sdraiato nella neve, non senti più il freddo.", "Lying in the snow, you no longer feel the cold.") },
  macro = { "stelle", "calore", "eco" }, macro_def = { 0.4, 0.3, 0.3 },
  musica = { tonica = 54, modo = "lidio", bpm = 46, prog = { 1, 2, 7, 1 }, accordo = "quarte", battute = 4, glide = 16, tema = 0.15,
    drone = { amp = 0.4, cut = 1300, shape = 0.15, sub = 0.25, air = 0.4, breath = 0.5 },
    linee = { l("accordo", "strings", 0, 0.22, 0.8, { atk = 4 }), l("melodia", "celesta", 1, 0.26, 0.5, { legato = 3, riposo = 10 }),
      l("onde", "swell", 1, 0.22, 0.5) },
    tex = { wind = 0.12 }, fx = { rev = 0.85, size = 0.96, shimmer = 0.45, echo = 0.2 } } },

{ id = "pace", strato = 3, x = 0.9, terreno = "erba", nome = T("La pace", "Peace"),
  ora = T("Non succede niente, e va tutto bene. Il respiro trova da solo il suo ritmo.",
          "Nothing happens, and all is well. Your breath finds its own rhythm."),
  allora = T("L'hai cercata tanto. Era qui, sotto tutto il rumore.", "You looked for it so long. It was here, under all the noise."),
  altro = { T("L'acqua non ha fretta. Nemmeno tu, adesso.", "The water is in no hurry. Neither are you, now.") },
  macro = { "respiro", "luce", "vento" },
  musica = { tonica = 53, modo = "penta", bpm = 48, prog = { 1, 1, 4, 1 }, accordo = "aperto", battute = 4, glide = 16, pedale = true, tema = 0.12,
    drone = { amp = 0.4, cut = 1100, shape = 0.05, sub = 0.3, air = 0.2, breath = 0.55 },
    linee = { l("coppa", "coppa", 0, 0.4, 0.8, { bright = 0.6 }), l("melodia", "piano", 1, 0.28, 0.45, { legato = 3, bright = 0.3, riposo = 12 }),
      l("scintille", "bell", 2, 0.12, 0.3, { bright = 0.1 }), l("risposta", "hum", 0, 0.18, 0.4, { legato = 1.5 }) },
    tex = { stream = 0.3, birds = 0.12, wind = 0.06 }, fx = { rev = 0.7, size = 0.9, shimmer = 0.35, tape = 0.06 } } },

{ id = "ninna", strato = 3, x = 0.6, terreno = "nuvola", nome = T("La ninna nanna", "The lullaby"),
  ora = T("La luna fa da culla. Qualcuno, da qualche parte, canta piano.", "The moon is a cradle. Somewhere, someone sings softly."),
  allora = T("Non ricordi le parole. Ricordi la voce, e che dopo veniva il sonno.", "You don't remember the words. You remember the voice, and that sleep came after."),
  altro = { T("Le stelle appese ai fili girano da sole.", "The stars on their strings turn by themselves.") },
  macro = { "infanzia", "respiro", "stelle" }, macro_def = { 0.4, 0.4, 0.3 },
  musica = { tonica = 53, modo = "ionio", bpm = 60, metro = 3, prog = { 1, 4, 5, 1 }, accordo = "triade", battute = 2, glide = 10, tema = 0.35,
    drone = { amp = 0.3, cut = 1000, shape = 0.05, sub = 0.2, air = 0.15, breath = 0.5 },
    linee = { l("melodia", "musicbox", 1, 0.3, 0.8, { bright = 0.2, legato = 3, lens = { 1, 2, 2, 3 } }), l("risposta", "hum", 0, 0.22, 0.5, { legato = 1.4 }),
      l("basso", "harmonium", -1, 0.18, 0.4, { legato = 1 }) },
    tex = { crackle = 0.05 }, fx = { rev = 0.6, size = 0.85, shimmer = 0.2, tape = 0.2, age = 0.15 } } },

-------------------------------------------------------------------------------
-- +2 · LE ALTURE
-------------------------------------------------------------------------------
{ id = "sentiero", strato = 2, x = 0.08, terreno = "ghiaia", nome = T("Il sentiero di montagna", "The mountain path"),
  ora = T("Il sentiero sale tra i larici, poi tra i sassi. L'aria si fa fina e fredda.",
          "The path climbs through the larches, then the stones. The air grows thin and cold."),
  allora = T("In montagna si parla poco. Si cammina, si respira. Il resto lo fa la salita.",
             "In the mountains you speak little. You walk, you breathe. The climb does the rest."),
  altro = { T("Lontano, i campanacci di una mandria che non vedrai.", "Far away, the bells of a herd you will never see.") },
  macro = { "vento", "tempo", "distanza" },
  musica = { tonica = 55, modo = "misolidio", bpm = 72, prog = { 1, 7, 4, 1 }, accordo = "sus2", battute = 2, glide = 8,
    drone = { amp = 0.35, cut = 1200, shape = 0.3, sub = 0.25, air = 0.25 },
    linee = { l("arpeggio", "guitar", 0, 0.32, 0.6, { bright = 0.5, legato = 3 }), l("melodia", "breath", 1, 0.32, 0.55, { legato = 1.6, riposo = 6 }),
      l("basso", "sub", -1, 0.3, 0.6) },
    tex = { wind = 0.3, birds = 0.2, cowbells = 0.4 }, fx = { rev = 0.5, size = 0.85, shimmer = 0.15, tape = 0.08 } } },

{ id = "bosco", strato = 2, x = 0.22, terreno = "foglie", nome = T("Camminare nel bosco", "Walking in the woods"),
  ora = T("Il bosco ti accoglie senza chiederti niente. Qui i pensieri camminano al tuo passo.",
          "The woods take you in and ask nothing. Here your thoughts walk at your pace."),
  allora = T("Ci vieni da sempre. Quando le cose si complicano, ti basta un sentiero e qualche albero.",
             "You have always come here. When things get hard, a path and a few trees are enough."),
  altro = { T("Il sole arriva a pezzi, tra le foglie, e ogni pezzo è un regalo.", "The sun arrives in pieces, between the leaves, and every piece is a gift.") },
  macro = { "foglie", "luce", "respiro" },
  musica = { tonica = 50, modo = "dorico", bpm = 66, prog = { 1, 4, 7, 4 }, accordo = "sus2", battute = 2, glide = 9, tema = 0.15,
    drone = { amp = 0.32, cut = 1000, shape = 0.25, sub = 0.25, air = 0.2 },
    linee = { l("arpeggio", "guitar", 0, 0.3, 0.6, { bright = 0.4, legato = 3 }), l("melodia", "breath", 1, 0.28, 0.5, { legato = 1.8 }),
      l("risposta", "celesta", 1, 0.16, 0.4), l("basso", "guitar", -1, 0.24, 0.5, { legato = 1.2 }) },
    tex = { birds = 0.3, leaves = 0.25, wind = 0.1 }, fx = { rev = 0.55, size = 0.85, shimmer = 0.1, tape = 0.08 } } },

{ id = "lago", strato = 2, x = 0.38, terreno = "pietra", nome = T("Il lago di montagna", "The mountain lake"),
  ora = T("L'acqua è così ferma che le montagne ci si guardano dentro.", "The water is so still the mountains look into it."),
  allora = T("Lanciavate i sassi piatti e contavate i rimbalzi. Vinceva sempre lui.", "You skipped flat stones and counted the bounces. He always won."),
  altro = { T("La nebbia sale dall'acqua come un respiro.", "Mist rises off the water like a breath.") },
  macro = { "nebbia", "luce", "eco" },
  musica = { tonica = 52, modo = "lidio", bpm = 48, prog = { 1, 5, 2, 1 }, accordo = "add9", battute = 4, glide = 14,
    drone = { amp = 0.38, cut = 1100, shape = 0.15, sub = 0.25, air = 0.3, breath = 0.5 },
    linee = { l("melodia", "rhodes", 0, 0.28, 0.5, { legato = 3, bright = 0.3, riposo = 10 }), l("accordo", "strings", 0, 0.18, 0.6, { atk = 4 }),
      l("onde", "swell", 0, 0.2, 0.4) },
    tex = { stream = 0.1, wind = 0.1 }, fx = { rev = 0.8, size = 0.94, shimmer = 0.25, echo = 0.3, etime = 0.6 } } },

{ id = "vetta", strato = 2, x = 0.52, terreno = "pietra", nome = T("La vetta", "The summit"),
  ora = T("In cima non c'è niente: una croce di ferro, il vento, e sotto le nuvole tutto il mondo che hai attraversato.",
          "At the top there is nothing: an iron cross, the wind, and under the clouds the whole world you have crossed."),
  allora = T("Da quassù non si vede nessuna strada. Si vede solo che tutto è collegato.",
             "From up here you can't see any road. You only see that everything is connected."),
  altro = { T("Il vento porta via le parole prima che tu le dica.", "The wind takes the words away before you say them.") },
  macro = { "vento", "luce", "coro" },
  musica = { tonica = 45, modo = "lidio", bpm = 44, prog = { 1, 2, 5, 1 }, accordo = "quarte", battute = 4, glide = 14, tema = 0.2,
    drone = { amp = 0.48, cut = 1500, shape = 0.35, sub = 0.35, air = 0.4, breath = 0.4 },
    linee = { l("accordo", "strings", 0, 0.26, 0.7, { atk = 3 }), l("accordo", "choir", 1, 0.16, 0.5, { atk = 4, voci = 2 }),
      l("melodia", "breath", 2, 0.24, 0.35, { legato = 2, riposo = 14 }) },
    tex = { wind = 0.55 }, fx = { rev = 0.88, size = 0.97, shimmer = 0.5, tape = 0.05 } } },

{ id = "campanile", strato = 2, x = 0.64, terreno = "pietra", nome = T("In cima al campanile", "Atop the bell tower"),
  ora = T("Il paese, da quassù, sta tutto in una mano. La campana ti passa accanto come un animale grande.",
          "From up here the village fits in one hand. The bell swings past you like a great animal."),
  allora = T("Il sacrestano ti ci portò una volta sola. Non l'hai mai dimenticato.", "The sexton took you up here only once. You never forgot it."),
  altro = { T("I tetti, i panni stesi, un cane che abbaia: la vita degli altri.", "Rooftops, washing hung out, a barking dog: other people's lives.") },
  macro = { "campane", "vento", "distanza" }, macro_def = { 0.5, 0.3, 0.5 },
  musica = { tonica = 58, modo = "ionio", bpm = 70, prog = { 1, 5, 6, 4 }, accordo = "triade", battute = 2, glide = 8,
    drone = { amp = 0.3, cut = 1300, shape = 0.3, sub = 0.2, air = 0.3 },
    linee = { l("campane", "campana", 0, 0.6, 0.4), l("accordo", "strings", 0, 0.18, 0.5, { atk = 2 }), l("melodia", "celesta", 1, 0.22, 0.5) },
    tex = { wind = 0.35, birds = 0.15 }, fx = { rev = 0.6, size = 0.88, shimmer = 0.15 } } },

{ id = "mura", strato = 2, x = 0.76, terreno = "pietra", nome = T("Le mura di Amelia", "The walls of Amelia"),
  ora = T("Pietre enormi, incastrate senza calce da gente di cui non si sa più il nome. Le rondini ci girano intorno.",
          "Huge stones, fitted without mortar by people whose names are long forgotten. Swallows wheel around them."),
  allora = T("Le guardavi da bambino e pensavi che le avessero messe lì i giganti. Forse è così.",
             "As a child you thought giants had put them there. Maybe they did."),
  altro = { T("La sera, le mura restano calde del sole di tutto il giorno.", "In the evening the walls stay warm with the whole day's sun.") },
  macro = { "luce", "campane", "vento" },
  musica = { tonica = 57, modo = "dorico", bpm = 62, prog = { 1, 4, 3, 7 }, accordo = "add9", battute = 2, glide = 10, tema = 0.2,
    drone = { amp = 0.34, cut = 1100, shape = 0.3, sub = 0.25, air = 0.2 },
    linee = { l("accordo", "strings", 0, 0.22, 0.7, { atk = 2.5 }), l("melodia", "piano", 1, 0.3, 0.6, { legato = 2.4, bright = 0.35 }),
      l("campane", "campana", 0, 0.4, 0.12), l("scintille", "celesta", 2, 0.1, 0.3) },
    tex = { swallows = 0.45, wind = 0.1 }, fx = { rev = 0.62, size = 0.9, shimmer = 0.15, tape = 0.1 } } },

{ id = "rifugio", strato = 2, x = 0.88, terreno = "legno", nome = T("Il rifugio", "The mountain hut"),
  ora = T("Fuori è buio e nevica. Dentro qualcuno suona la fisarmonica e tutti cantano un po' stonati.",
          "Outside it's dark and snowing. Inside someone plays the accordion and everyone sings a little out of tune."),
  allora = T("Era la prima volta che stavi sveglio con i grandi. Ti sentivi uno di loro.",
             "It was the first time you stayed up with the grown-ups. You felt like one of them."),
  altro = { T("Il vino caldo, la legna, le risate che si spengono piano.", "Mulled wine, firewood, laughter slowly fading.") },
  macro = { "fuoco", "folla", "tempo" },
  musica = { tonica = 55, modo = "misolidio", bpm = 96, metro = 3, prog = { 1, 4, 5, 1 }, accordo = "triade", battute = 2, glide = 7,
    drone = { amp = 0.24, cut = 900, shape = 0.4, sub = 0.2 },
    linee = { l("melodia", "accordion", 1, 0.34, 0.8, { legato = 1.2, lens = { 1, 1, 2, 2, 3 } }), l("basso", "guitar", -1, 0.3, 0.7, { legato = 1 }),
      l("arpeggio", "guitar", 0, 0.18, 0.4), l("risposta", "hum", 0, 0.18, 0.4) },
    tex = { fire = 0.3, crowd = 0.15, wind = 0.15 }, fx = { rev = 0.4, size = 0.7, tape = 0.2, age = 0.2 } } },

{ id = "baita", strato = 2, x = 0.97, terreno = "legno", nome = T("La baita", "The cabin"),
  ora = T("Fuori nevica, il vento gira intorno alla casa. Dentro il fuoco, il tavolo, un uomo solo.",
          "Outside it snows, the wind circles the house. Inside: the fire, the table, a man alone."),
  allora = T("Posava le cose sul tavolo una alla volta, come se ogni oggetto fosse una nota.",
             "He set things on the table one by one, as if each object were a note."),
  altro = { T("La legna scoppietta. L'orologio va avanti lo stesso.", "The wood crackles. The clock goes on anyway."),
    T("Ogni tanto si alza, guarda fuori, torna a sedersi.", "Now and then he gets up, looks out, sits down again.") },
  macro = { "fuoco", "vento", "fragilita" },
  musica = { tonica = 57, modo = "dorico", bpm = 60, prog = { 1, 4, 1, 7 }, accordo = "settima", battute = 2, glide = 9, tema = 0.12,
    drone = { amp = 0.36, cut = 800, shape = 0.4, sub = 0.3, air = 0.08, breath = 0.3 },
    linee = { l("melodia", "piano", 0, 0.36, 0.7, { legato = 2.4, bright = 0.35 }), l("arpeggio", "pluck", -1, 0.22, 0.3, { bright = 0.3, legato = 3 }),
      l("basso", "piano", -1, 0.28, 0.6, { bright = 0.2, legato = 1 }), l("risposta", "bowed", 0, 0.16, 0.4, { atk = 0.8 }) },
    tex = { fire = 0.5, wind = 0.35, clock = 0.25 }, fx = { rev = 0.42, size = 0.7, shimmer = 0.05, tape = 0.22, age = 0.15 } } },

-------------------------------------------------------------------------------
-- +1 · L'INFANZIA
-------------------------------------------------------------------------------
{ id = "mare", strato = 1, x = 0.05, terreno = "sabbia", nome = T("In riva al mare", "By the sea"),
  ora = T("L'acqua torna sempre allo stesso punto, e ogni volta è diversa.", "The water always returns to the same place, and each time it is different."),
  allora = T("Il secchiello, il sale sulle labbra, qualcuno che ti chiamava per il pranzo.", "The bucket, salt on your lips, someone calling you in for lunch."),
  altro = { T("Il bambino scava. Tu lo guardi da qui, da adesso.", "The child digs. You watch him from here, from now.") },
  macro = { "mare", "infanzia", "luce" },
  musica = { tonica = 48, modo = "ionio", bpm = 64, prog = { 1, 3, 4, 1 }, accordo = "add9", battute = 2, glide = 10, tema = 0.15,
    drone = { amp = 0.35, cut = 1100, shape = 0.2, sub = 0.25, air = 0.2, breath = 0.5 },
    linee = { l("arpeggio", "piano", 0, 0.28, 0.5, { bright = 0.4, legato = 3 }), l("melodia", "musicbox", 1, 0.22, 0.5, { bright = 0.2, legato = 3 }),
      l("accordo", "strings", 0, 0.16, 0.4, { atk = 3 }) },
    tex = { sea = 0.65, birds = 0.1, wind = 0.12 }, fx = { rev = 0.55, size = 0.85, shimmer = 0.15, tape = 0.3, age = 0.18 } } },

{ id = "lorenzo", strato = 1, x = 0.15, terreno = "erba", nome = T("Notte di San Lorenzo", "The night of falling stars"),
  ora = T("Una scia, poi un'altra. Non fai in tempo a esprimere niente.", "A streak, then another. You don't have time to wish for anything."),
  allora = T("Agosto, il mare in fondo, una voce che contava le stelle cadenti ad alta voce.", "August, the sea beyond, a voice counting the falling stars out loud."),
  altro = { T("L'erba è fredda sotto la schiena. Il cielo non finisce da nessuna parte.", "The grass is cold under your back. The sky never ends.") },
  macro = { "stelle", "notte", "respiro" },
  musica = { tonica = 51, modo = "lidio", bpm = 52, prog = { 1, 2, 6, 5 }, accordo = "add9", battute = 4, glide = 12, tema = 0.15,
    drone = { amp = 0.36, cut = 1000, shape = 0.15, sub = 0.2, air = 0.3, breath = 0.4 },
    linee = { l("melodia", "celesta", 1, 0.26, 0.6, { bright = 0.25, legato = 3.5 }), l("scintille", "bell", 2, 0.16, 0.6, { bright = 0.5, legato = 2 }),
      l("accordo", "bowed", -1, 0.16, 0.4, { atk = 3, voci = 2 }) },
    tex = { crick = 0.5, sea = 0.12 }, fx = { rev = 0.72, size = 0.92, shimmer = 0.4, tape = 0.12 } } },

{ id = "campagna", strato = 1, x = 0.25, terreno = "ghiaia", nome = T("Strada di campagna", "Country road"),
  ora = T("La strada bianca va dritta tra i campi. I pioppi tremano anche senza vento.", "The white road runs straight between the fields. The poplars tremble even without wind."),
  allora = T("In bicicletta, le gambe corte, il sole sulla nuca. Ogni curva era una scoperta.", "On a bicycle, short legs, the sun on your neck. Every bend was a discovery."),
  altro = { T("Un trattore lontano. Poi di nuovo solo cicale.", "A tractor far off. Then only cicadas again.") },
  macro = { "calore", "vento", "tempo" },
  musica = { tonica = 50, modo = "misolidio", bpm = 80, prog = { 1, 7, 4, 1 }, accordo = "triade", battute = 2, glide = 8,
    drone = { amp = 0.28, cut = 1100, shape = 0.35, sub = 0.2, air = 0.15 },
    linee = { l("melodia", "guitar", 1, 0.32, 0.65, { bright = 0.5, legato = 2 }), l("arpeggio", "pluck", 0, 0.2, 0.45, { bright = 0.4 }),
      l("basso", "guitar", -1, 0.26, 0.5, { legato = 1 }) },
    tex = { cicada = 0.45, birds = 0.15 }, fx = { rev = 0.42, size = 0.75, tape = 0.3, age = 0.25 } } },

{ id = "estate", strato = 1, x = 0.35, terreno = "ghiaia", nome = T("Estate dai nonni", "Summer at the grandparents'"),
  ora = T("Le persiane accostate, il caldo che ronza. In cucina qualcuno taglia il pane.", "Shutters half closed, the humming heat. In the kitchen someone is slicing bread."),
  allora = T("Il pomeriggio non finiva mai. Adesso vorresti che non fosse mai finito.", "The afternoon never ended. Now you wish it never had."),
  altro = { T("Il lenzuolo steso si gonfia e si sgonfia, come un respiro.", "The sheet on the line swells and falls, like a breath.") },
  macro = { "calore", "infanzia", "tempo" },
  musica = { tonica = 53, modo = "misolidio", bpm = 76, prog = { 1, 4, 1, 5 }, accordo = "triade", battute = 2, glide = 8, tema = 0.15,
    drone = { amp = 0.3, cut = 1000, shape = 0.35, sub = 0.2, air = 0.15 },
    linee = { l("melodia", "pluck", 1, 0.34, 0.65, { bright = 0.55, legato = 2 }), l("arpeggio", "piano", 0, 0.22, 0.45, { bright = 0.35, legato = 2.5 }),
      l("basso", "pluck", -1, 0.3, 0.5, { bright = 0.3, legato = 1 }), l("risposta", "accordion", 0, 0.14, 0.3) },
    tex = { cicada = 0.5, clock = 0.15, birds = 0.1 }, fx = { rev = 0.4, size = 0.75, tape = 0.45, age = 0.35, hiss = 0.2 } } },

{ id = "lucciole", strato = 1, x = 0.45, terreno = "erba", nome = T("Le lucciole", "Fireflies"),
  ora = T("Il prato si accende e si spegne. Un bambino corre con un barattolo in mano.", "The meadow lights up and goes dark. A child runs with a jar in his hand."),
  allora = T("Le liberavi sempre prima di andare a dormire. Dicevi che dovevano tornare a casa anche loro.",
             "You always let them go before bed. You said they had to go home too."),
  altro = { T("Più guardi, più ce ne sono.", "The longer you look, the more there are.") },
  macro = { "notte", "stelle", "infanzia" }, macro_def = { 0.5, 0.3, 0.3 },
  musica = { tonica = 56, modo = "lidio", bpm = 58, prog = { 1, 2, 4, 1 }, accordo = "add9", battute = 2, glide = 10, tema = 0.2,
    drone = { amp = 0.32, cut = 1100, shape = 0.15, sub = 0.2, air = 0.25 },
    linee = { l("melodia", "celesta", 1, 0.28, 0.65, { legato = 2.5 }), l("accordo", "rhodes", 0, 0.2, 0.5, { bright = 0.3 }),
      l("scintille", "musicbox", 2, 0.12, 0.6) },
    tex = { crick = 0.4, frogs = 0.08 }, fx = { rev = 0.65, size = 0.88, shimmer = 0.3, tape = 0.12 } } },

{ id = "fienile", strato = 1, x = 0.55, terreno = "legno", nome = T("Il fienile", "The hayloft"),
  ora = T("Il sole entra tra le assi a strisce. La polvere gira dentro la luce come una cosa viva.",
          "The sun comes through the boards in stripes. Dust turns in the light like something alive."),
  allora = T("Saltavi dalla trave nel fieno e l'aria ti mancava per un secondo, bellissimo.", "You jumped from the beam into the hay and for a second you couldn't breathe, beautifully."),
  altro = { T("Le rondini entrano ed escono dal portone, sempre di fretta.", "Swallows dart in and out of the great door, always in a hurry.") },
  macro = { "luce", "infanzia", "respiro" },
  musica = { tonica = 48, modo = "ionio", bpm = 72, prog = { 1, 4, 6, 5 }, accordo = "triade", battute = 2, glide = 8,
    drone = { amp = 0.3, cut = 1100, shape = 0.3, sub = 0.2, air = 0.2 },
    linee = { l("melodia", "musicbox", 1, 0.26, 0.6, { legato = 2.5 }), l("arpeggio", "guitar", 0, 0.24, 0.5), l("basso", "guitar", -1, 0.22, 0.4, { legato = 1 }) },
    tex = { birds = 0.2, swallows = 0.15, wind = 0.05 }, fx = { rev = 0.5, size = 0.8, tape = 0.25, age = 0.2 } } },

{ id = "fiera", strato = 1, x = 0.65, terreno = "pietra", nome = T("La fiera di paese", "The village fair"),
  ora = T("Le luci della giostra continuano a girare anche quando chiudi gli occhi.", "The carousel lights keep turning even when you close your eyes."),
  allora = T("Un gettone, un cavallo bianco, la paura bellissima di cadere.", "One token, a white horse, the beautiful fear of falling."),
  altro = { T("Lo zucchero filato si scioglie prima di arrivare in bocca.", "The candy floss melts before it reaches your mouth.") },
  macro = { "folla", "infanzia", "tempo" },
  musica = { tonica = 53, modo = "ionio", bpm = 108, metro = 3, prog = { 1, 4, 5, 1 }, accordo = "triade", battute = 2, glide = 6,
    drone = { amp = 0.22, cut = 1100, shape = 0.4, sub = 0.15 },
    linee = { l("melodia", "accordion", 1, 0.32, 0.8, { legato = 1.2, lens = { 1, 1, 2, 2, 3 } }), l("arpeggio", "musicbox", 1, 0.18, 0.5),
      l("basso", "guitar", -1, 0.28, 0.7, { legato = 1 }) },
    tex = { crowd = 0.4, wind = 0.05 }, fx = { rev = 0.45, size = 0.75, tape = 0.35, age = 0.3, hiss = 0.15 } } },

{ id = "sala_giochi", strato = 1, x = 0.75, terreno = "moquette", nome = T("La sala giochi", "The arcade"),
  ora = T("Gli schermi accesi nel buio, le monete che cadono, due ragazzi spalla a spalla.", "Screens glowing in the dark, coins dropping, two boys shoulder to shoulder."),
  allora = T("Lì avete imparato che si può essere amici senza dire niente, solo giocando.", "That's where you learned you can be friends without saying a thing, just playing."),
  altro = { T("Game over. Un'altra moneta. Ancora una partita.", "Game over. Another coin. One more game.") },
  macro = { "tempo", "infanzia", "eco" },
  musica = { tonica = 52, modo = "dorico", bpm = 120, prog = { 1, 7, 6, 7 }, accordo = "triade", battute = 2, glide = 4, tema = 0.3,
    drone = { amp = 0.3, cut = 1100, shape = 0.5, sub = 0.15 },
    linee = { l("melodia", "arcade", 1, 0.48, 0.8, { legato = 0.9, lens = { 1, 1, 2, 2 } }), l("arpeggio", "arcade", 0, 0.26, 0.6, { legato = 0.6 }),
      l("basso", "arcade", -1, 0.36, 0.7, { legato = 0.8 }) },
    tex = { arcade = 0.55, crowd = 0.1, hum = 0.08 }, fx = { rev = 0.35, size = 0.6, tape = 0.15, age = 0.1 } } },

{ id = "primo", strato = 1, x = 0.85, terreno = "moquette", nome = T("Il primo ricordo", "The first memory"),
  ora = T("Tutto è sfocato e grande. Sopra di te qualcosa gira piano, e un volto si china.",
          "Everything is blurred and huge. Above you something turns slowly, and a face leans in."),
  allora = T("Non sai se lo ricordi davvero o se te l'hanno raccontato tante volte.", "You don't know if you really remember it or if you've been told it so many times."),
  altro = { T("Una luce, una voce, un odore di latte e di sapone.", "A light, a voice, a smell of milk and soap.") },
  macro = { "infanzia", "luce", "silenzio" }, macro_def = { 0.5, 0.6, 0.2 },
  musica = { tonica = 50, modo = "lidio", bpm = 50, metro = 3, prog = { 1, 2, 1, 5 }, accordo = "add9", battute = 2, glide = 12, tema = 0.3,
    drone = { amp = 0.3, cut = 1200, shape = 0.05, sub = 0.2, air = 0.2, breath = 0.6 },
    linee = { l("melodia", "musicbox", 1, 0.26, 0.7, { legato = 3 }), l("risposta", "hum", 0, 0.2, 0.5), l("scintille", "celesta", 2, 0.12, 0.4) },
    tex = { crackle = 0.08 }, fx = { rev = 0.75, size = 0.9, shimmer = 0.25, tape = 0.3, age = 0.25 } } },

{ id = "conca", strato = 1, x = 0.95, terreno = "foglie", nome = T("La conca nel bosco", "The hollow in the woods"),
  ora = T("Il terreno scende in una piccola conca. Gli alberi si stringono intorno, come persone che non dicono niente.",
          "The ground drops into a small hollow. The trees close in around you, like people who say nothing."),
  allora = T("Ci vieni a pensare. Il vento passa in alto, sulle cime; quaggiù arrivano solo i pensieri, uno alla volta.",
             "You come here to think. The wind passes high in the treetops; down here only thoughts arrive, one at a time."),
  altro = { T("Una foglia, poi un'altra. Nessuna ha fretta di toccare terra.", "A leaf, then another. None is in a hurry to touch the ground.") },
  macro = { "foglie", "respiro", "profondita" },
  musica = { tonica = 50, modo = "dorico", bpm = 58, prog = { 1, 4, 3, 4 }, accordo = "sus2", battute = 4, glide = 10, tema = 0.15,
    drone = { amp = 0.36, cut = 850, shape = 0.3, sub = 0.3, air = 0.15, breath = 0.4 },
    linee = { l("melodia", "bowed", -1, 0.3, 0.6, { atk = 0.6, legato = 1.6 }), l("risposta", "breath", 1, 0.22, 0.4, { legato = 2 }),
      l("arpeggio", "guitar", 0, 0.18, 0.3, { bright = 0.25, legato = 3 }) },
    tex = { wind = 0.2, birds = 0.15, leaves = 0.15 }, fx = { rev = 0.6, size = 0.88, shimmer = 0.1, tape = 0.1, age = 0.08 } } },

-------------------------------------------------------------------------------
-- 0 · IL PAESE
-------------------------------------------------------------------------------
{ id = "stazione", strato = 0, x = 0.03, terreno = "pietra", nome = T("La stazione deserta", "The empty station"),
  ora = T("Il tabellone gira le lettere per un treno che non passa più.", "The board flips its letters for a train that no longer comes."),
  allora = T("Lì hai detto arrivederci, intendevi addio, e lo sapevate tutti e due.", "There you said goodbye for now, you meant goodbye, and you both knew it."),
  altro = { T("In fondo ai binari, a volte, una luce. Poi niente.", "At the end of the tracks, sometimes, a light. Then nothing.") },
  macro = { "treno", "distanza", "lacrime" },
  musica = { tonica = 47, modo = "eolio", bpm = 62, prog = { 1, 6, 3, 7 }, accordo = "add9", battute = 2, glide = 10, tema = 0.15,
    drone = { amp = 0.36, cut = 700, shape = 0.35, sub = 0.3, air = 0.1 },
    linee = { l("melodia", "piano", 1, 0.34, 0.65, { legato = 2.4, bright = 0.3 }), l("accordo", "strings", 0, 0.16, 0.5, { atk = 2.5, voci = 2 }),
      l("basso", "sub", -1, 0.3, 0.6) },
    tex = { wind = 0.25, hum = 0.2, rumble = 0.1 }, fx = { rev = 0.68, size = 0.9, tape = 0.18, age = 0.12, dark = 0.1 } } },

{ id = "domenica", strato = 0, x = 0.12, terreno = "pietra", nome = T("Domenica al paese", "Sunday in the village"),
  ora = T("Le campane a festa. La piazza si riempie di vestiti buoni.", "The bells ring out. The square fills with Sunday clothes."),
  allora = T("Le paste incartate, la messa lunghissima, la libertà del dopo.", "Wrapped pastries, the endless mass, the freedom afterwards."),
  altro = { T("I piccioni si alzano tutti insieme, per niente.", "The pigeons rise all together, for nothing.") },
  macro = { "campane", "folla", "luce" }, macro_def = { 0.4, 0.4, 0.5 },
  musica = { tonica = 55, modo = "ionio", bpm = 70, prog = { 1, 5, 6, 4 }, accordo = "triade", battute = 2, glide = 8,
    drone = { amp = 0.3, cut = 1300, shape = 0.3, sub = 0.2, air = 0.2 },
    linee = { l("campane", "campana", 0, 0.65, 0.4), l("accordo", "choir", 0, 0.2, 0.6, { atk = 1.5 }),
      l("melodia", "pluck", 1, 0.3, 0.5, { bright = 0.5, legato = 2 }), l("basso", "pluck", -1, 0.28, 0.4, { legato = 1 }) },
    tex = { birds = 0.3, crowd = 0.15 }, fx = { rev = 0.52, size = 0.85, shimmer = 0.12, tape = 0.2, age = 0.25 } } },

{ id = "chiesa", strato = 0, x = 0.21, terreno = "pietra", nome = T("La chiesa di notte", "The church at night"),
  ora = T("Le candele accese da persone che non ci sono più. Il silenzio qui ha un'eco.", "Candles lit by people who are no longer here. Silence has an echo in here."),
  allora = T("Accendevi un lumino e non sapevi bene per chi. Adesso lo sai.", "You lit a candle without quite knowing who for. Now you know."),
  altro = { T("L'armonium respira da solo, piano.", "The harmonium breathes by itself, softly.") },
  macro = { "coro", "eco", "silenzio" },
  musica = { tonica = 50, modo = "eolio", bpm = 44, prog = { 1, 6, 4, 5 }, accordo = "triade", battute = 4, glide = 14, tema = 0.2,
    drone = { amp = 0.26, cut = 800, shape = 0.2, sub = 0.12, air = 0.1, breath = 0.4 },
    linee = { l("accordo", "organ", 0, 0.18, 0.8, { atk = 1 }), l("melodia", "harmonium", 1, 0.26, 0.5, { legato = 2 }),
      l("accordo", "choir", 0, 0.14, 0.4, { atk = 3, voci = 2 }) },
    tex = {}, fx = { rev = 0.9, size = 0.97, shimmer = 0.1, tape = 0.06 } } },

{ id = "piazza", strato = 0, x = 0.3, terreno = "pietra", nome = T("La piazza d'estate", "The summer square"),
  ora = T("Le sedie fuori dal bar, le carte sul tavolino, i bambini che non vogliono andare a letto.", "Chairs outside the bar, cards on the table, children who won't go to bed."),
  allora = T("Ti addormentavi in braccio a qualcuno, con le voci dei grandi che diventavano un mare.", "You fell asleep in someone's arms, the grown-ups' voices becoming a sea."),
  altro = { T("Le falene girano intorno al lampione come se fosse la luna.", "The moths circle the streetlamp as if it were the moon.") },
  macro = { "folla", "notte", "tempo" },
  musica = { tonica = 48, modo = "misolidio", bpm = 92, metro = 3, prog = { 1, 4, 5, 1 }, accordo = "triade", battute = 2, glide = 7,
    drone = { amp = 0.22, cut = 1000, shape = 0.4, sub = 0.15 },
    linee = { l("melodia", "accordion", 1, 0.3, 0.7, { legato = 1.3 }), l("basso", "guitar", -1, 0.28, 0.7, { legato = 1 }),
      l("arpeggio", "guitar", 0, 0.18, 0.4) },
    tex = { crowd = 0.35, crick = 0.2, radio = 0.06 }, fx = { rev = 0.45, size = 0.78, tape = 0.25, age = 0.25 } } },

{ id = "fornole", strato = 0, x = 0.4, terreno = "erba", nome = T("Fornole, al tramonto", "Fornole at sunset"),
  ora = T("Le case di pietra prendono il colore del miele. Laggiù Amelia, sul suo colle, dentro le sue mura.",
          "The stone houses turn the colour of honey. Over there Amelia, on her hill, inside her walls."),
  allora = T("È casa. Non perché ci sei nato, ma perché ci torni sempre, anche quando non ti muovi.",
             "It is home. Not because you were born here, but because you always come back, even when you don't move."),
  altro = { T("Gli ulivi diventano d'argento quando passa il vento.", "The olive trees turn silver when the wind passes.") },
  macro = { "luce", "campane", "vento" }, macro_def = { 0.55, 0.3, 0.2 },
  musica = { tonica = 55, modo = "dorico", bpm = 60, prog = { 1, 4, 7, 1 }, accordo = "add9", battute = 2, glide = 10, tema = 0.25,
    drone = { amp = 0.34, cut = 1000, shape = 0.3, sub = 0.25, air = 0.2 },
    linee = { l("accordo", "strings", 0, 0.22, 0.7, { atk = 2.5 }), l("melodia", "piano", 1, 0.32, 0.65, { legato = 2.4, bright = 0.35 }),
      l("campane", "campana", 0, 0.35, 0.12), l("risposta", "guitar", 0, 0.18, 0.4) },
    tex = { swallows = 0.3, birds = 0.1, wind = 0.06 }, fx = { rev = 0.6, size = 0.88, shimmer = 0.15, tape = 0.12 } } },

{ id = "soglia", strato = 0, x = 0.5, terreno = "pietra", nome = T("La soglia", "The threshold"),
  ora = T("Sei sulla soglia. Il fuoco è acceso alle tue spalle.", "You stand on the threshold. The fire burns behind you."),
  allora = T("Da qui si va dove si è già stati, e anche dove non si è mai stati.", "From here you go where you have been, and where you have never been."),
  altro = { T("In alto la quiete. In basso tutto il resto. Scegli tu.", "Above, the quiet. Below, everything else. You choose."),
    T("Puoi anche restare. Restare è un modo di andare.", "You may also stay. Staying is a way of going.") },
  macro = { "luce", "respiro", "fuoco" },
  musica = { tonica = 52, modo = "dorico", bpm = 60, prog = { 1, 4, 7, 1 }, accordo = "add9", battute = 4, glide = 10, tema = 0.3,
    drone = { amp = 0.45, cut = 950, shape = 0.3, sub = 0.35, air = 0.18, breath = 0.35 },
    linee = { l("melodia", "piano", 0, 0.32, 0.6, { legato = 2.6, bright = 0.3, riposo = 8 }), l("coppa", "coppa", 0, 0.28, 0.4),
      l("onde", "swell", 0, 0.22, 0.4), l("accordo", "strings", 0, 0.14, 0.4, { atk = 3 }) },
    tex = { fire = 0.3, wind = 0.15 }, fx = { rev = 0.62, size = 0.9, shimmer = 0.2, tape = 0.12, age = 0.06 } } },

{ id = "parco", strato = 0, x = 0.58, terreno = "ghiaia", nome = T("Il parco giochi", "The playground"),
  ora = T("Le giostre di ferro verniciato, scrostate. L'altalena cigola da sola.", "Painted iron rides, peeling. The swing creaks by itself."),
  allora = T("Sembra fermo al 1975: i colori di allora, sbiaditi da cinquant'anni di sole.", "It seems stuck in 1975: the colours of then, faded by fifty years of sun."),
  altro = { T("È bellissimo, come tutte le cose che nessuno ha avuto il cuore di buttare via.", "It is beautiful, like everything no one had the heart to throw away.") },
  macro = { "infanzia", "vento", "fragilita" },
  musica = { tonica = 58, modo = "ionio", bpm = 84, metro = 3, prog = { 1, 4, 5, 1 }, accordo = "triade", battute = 2, glide = 8,
    drone = { amp = 0.26, cut = 900, shape = 0.4, sub = 0.15, air = 0.1, wob = 0.3 },
    linee = { l("melodia", "musicbox", 1, 0.3, 0.75, { bright = 0.15, legato = 2.5, lens = { 1, 2, 2, 3 } }), l("arpeggio", "bell", 0, 0.16, 0.45, { bright = 0.05, legato = 2 }),
      l("basso", "pluck", -1, 0.26, 0.5, { legato = 1 }) },
    tex = { wind = 0.22, birds = 0.08, crackle = 0.15 }, fx = { rev = 0.5, size = 0.8, tape = 0.6, age = 0.5, hiss = 0.3 } } },

{ id = "cabina", strato = 0, x = 0.66, terreno = "pietra", nome = T("La cabina telefonica", "The phone booth"),
  ora = T("Piove sulla cabina. Dentro, una voce lontana dice qualcosa che non vuoi capire.", "Rain on the phone booth. Inside, a distant voice says something you don't want to understand."),
  allora = T("I gettoni contati, la fila fuori, e quella telefonata che è durata troppo poco.", "The counted tokens, the queue outside, and that call that lasted far too little."),
  altro = { T("Una macchina passa e illumina tutto, poi il buio torna più buio.", "A car goes by and lights everything up, then the dark comes back darker.") },
  macro = { "pioggia", "lacrime", "distanza" },
  musica = { tonica = 54, modo = "eolio", bpm = 58, prog = { 1, 6, 7, 1 }, accordo = "settima", battute = 2, glide = 10,
    drone = { amp = 0.34, cut = 750, shape = 0.3, sub = 0.3, air = 0.08 },
    linee = { l("melodia", "rhodes", 0, 0.3, 0.6, { legato = 2.4, bright = 0.3 }), l("accordo", "strings", 0, 0.16, 0.5, { atk = 2.5 }),
      l("basso", "sub", -1, 0.28, 0.5) },
    tex = { rain = 0.5, city = 0.2 }, fx = { rev = 0.6, size = 0.85, tape = 0.15, age = 0.1, echo = 0.15 } } },

{ id = "bottega", strato = 0, x = 0.74, terreno = "piastrelle", nome = T("La bottega", "The shop at night"),
  ora = T("La fotocopiatrice canta la sua canzone di luce, un foglio dopo l'altro. Fuori il paese dorme.",
          "The copier sings its song of light, one sheet after another. Outside the village sleeps."),
  allora = T("Una vita di carta, di toner, di macchine da aggiustare. E dentro, chissà come, la musica.",
             "A life of paper, toner, machines to fix. And somehow, inside it all, music."),
  altro = { T("Ogni copia è un po' diversa dall'originale. Come i ricordi.", "Every copy is a little different from the original. Like memories.") },
  macro = { "tempo", "luce", "fragilita" },
  musica = { tonica = 57, modo = "dorico", bpm = 84, prog = { 1, 4, 1, 7 }, accordo = "settima", battute = 2, glide = 8,
    drone = { amp = 0.26, cut = 900, shape = 0.4, sub = 0.2 },
    linee = { l("arpeggio", "rhodes", 0, 0.24, 0.6, { bright = 0.35 }), l("melodia", "pluck", 1, 0.28, 0.5, { bright = 0.5, legato = 1.5 }),
      l("basso", "sub", -1, 0.26, 0.5) },
    tex = { copier = 0.5, clock = 0.15, hum = 0.06 }, fx = { rev = 0.4, size = 0.7, tape = 0.15, age = 0.1, echo = 0.12 } } },

{ id = "cimitero", strato = 0, x = 0.82, terreno = "ghiaia", nome = T("Il cimitero di notte", "The cemetery at night"),
  ora = T("I lumini rossi tra le lapidi. Cerchi un nome che avevi dimenticato, e ne trovi cento.", "Red votive lights among the graves. You look for a name you'd forgotten, and find a hundred."),
  allora = T("La domenica si portavano i fiori. Tu correvi tra le tombe e non avevi paura di niente.", "On Sundays you brought flowers. You ran among the graves, afraid of nothing."),
  altro = { T("Ogni lumino è una persona che qualcuno non vuole lasciare al buio.", "Every little light is someone a person won't leave in the dark.") },
  macro = { "notte", "coro", "ricordo" },
  musica = { tonica = 49, modo = "eolio", bpm = 46, prog = { 1, 6, 4, 5 }, accordo = "add9", battute = 4, glide = 14, tema = 0.2,
    drone = { amp = 0.38, cut = 750, shape = 0.25, sub = 0.3, breath = 0.45 },
    linee = { l("accordo", "strings", 0, 0.2, 0.7, { atk = 3 }), l("accordo", "choir", 0, 0.14, 0.4, { atk = 4, voci = 2 }),
      l("melodia", "celesta", 1, 0.22, 0.4, { legato = 3, riposo = 10 }) },
    tex = { crick = 0.2, owl = 0.15, wind = 0.08 }, fx = { rev = 0.8, size = 0.94, shimmer = 0.15, tape = 0.1 } } },

{ id = "massimo", strato = 0, x = 0.9, terreno = "ghiaia", nome = T("Da Massimo", "Visiting Massimo"),
  ora = T("Ti siedi sul bordo di marmo, davanti alla sua foto. Togli una foglia secca, sistemi i fiori. Poi parli, piano.",
          "You sit on the marble edge, facing his photo. You brush away a dry leaf, straighten the flowers. Then you talk, softly."),
  allora = T("Vieni a raccontargli le cose. Anche le più piccole, anche i videogiochi che escono: soprattutto quelli.",
             "You come to tell him things. Even the smallest, even the video games coming out: those most of all."),
  altro = {
    T("A novembre esce GTA 6. Io credo che tu ci stia già giocando, da qualche parte.", "GTA 6 comes out in November. I think you're already playing it, somewhere."),
    T("Ho giocato a Mother, il gioco che avevi fatto tu tanti anni fa. C'eri dentro tutto.", "I played Mother, the game you made all those years ago. All of you was in it."),
    T("Mi manchi. Vorrei solo parlarti ancora un po'.", "I miss you. I'd just like to talk to you a little longer."),
    T("I lumini restano accesi anche quando me ne vado.", "The little lights stay on even after I leave.") },
  macro = { "ricordo", "lacrime", "pioggia" }, macro_def = { 0.4, 0.3, 0.1 },
  musica = { tonica = 48, modo = "eolio", bpm = 54, prog = { 1, 6, 4, 5 }, accordo = "add9", battute = 4, glide = 11, tema = 0.35,
    drone = { amp = 0.36, cut = 800, shape = 0.25, sub = 0.3, air = 0.12, breath = 0.4 },
    linee = { l("melodia", "piano", 1, 0.34, 0.7, { legato = 2.6, bright = 0.32, riposo = 7 }), l("accordo", "strings", 0, 0.16, 0.5, { atk = 3, voci = 2 }),
      l("melodia", "arcade", 1, 0.1, 0.25, { legato = 1.2, riposo = 16, bright = 0.2 }), l("onde", "swell", 0, 0.2, 0.35) },
    tex = { wind = 0.12, birds = 0.1 }, fx = { rev = 0.7, size = 0.9, shimmer = 0.18, tape = 0.12, age = 0.08 } } },

{ id = "studio", strato = 0, x = 0.97, terreno = "moquette", nome = T("Lo studio", "The studio"),
  ora = T("Le macchine accese nella notte, le lucine, i cavi. Qui il rumore diventa musica.", "Machines on in the night, little lights, cables. Here noise turns into music."),
  allora = T("Hai sempre avuto bisogno di un posto dove le cose che non sai dire potessero suonare.", "You always needed a place where the things you can't say could sound."),
  altro = { T("Sul piccolo schermo, un uomo cammina tra i suoi ricordi.", "On the small screen, a man walks among his memories.") },
  macro = { "eco", "tempo", "luce" },
  musica = { tonica = 52, modo = "dorico", bpm = 90, prog = { 1, 7, 4, 1 }, accordo = "settima", battute = 2, glide = 7, tema = 0.2,
    drone = { amp = 0.3, cut = 1200, shape = 0.6, sub = 0.25, wob = 0.2 },
    linee = { l("arpeggio", "rhodes", 0, 0.26, 0.7, { bright = 0.45 }), l("melodia", "bell", 1, 0.24, 0.5, { bright = 0.4 }),
      l("basso", "sub", -1, 0.3, 0.6), l("schegge", "glitch", 1, 0.08, 0.2) },
    tex = { hum = 0.05 }, fx = { rev = 0.5, size = 0.8, shimmer = 0.15, echo = 0.3, etime = 0.5 } } },

-------------------------------------------------------------------------------
-- -1 · LE CASE
-------------------------------------------------------------------------------
{ id = "pioggia", strato = -1, x = 0.05, terreno = "legno", nome = T("Pioggia sul tetto", "Rain on the roof"),
  ora = T("Piove forte, e la casa sembra più piccola e più tua.", "It's raining hard, and the house feels smaller and more yours."),
  allora = T("Un plaid, un libro che non leggevi, il pianoforte di là che sbagliava sempre la stessa nota.",
             "A blanket, a book you weren't reading, the piano in the next room always missing the same note."),
  altro = { T("La goccia nella pentola tiene il tempo meglio di tutti.", "The drip in the pot keeps better time than anyone.") },
  macro = { "pioggia", "fragilita", "calore" }, macro_def = { 0.5, 0.15, 0.6 },
  musica = { tonica = 57, modo = "dorico", bpm = 60, prog = { 1, 4, 6, 5 }, accordo = "settima", battute = 2, glide = 9,
    drone = { amp = 0.3, cut = 750, shape = 0.3, sub = 0.25, air = 0.06 },
    linee = { l("melodia", "piano", 0, 0.36, 0.75, { legato = 2.4, bright = 0.3 }), l("basso", "piano", -1, 0.24, 0.6, { legato = 1.2, bright = 0.2 }),
      l("arpeggio", "piano", 1, 0.14, 0.25, { legato = 2, bright = 0.25 }) },
    tex = { rain = 0.5, drip = 0.25, clock = 0.08 }, fx = { rev = 0.5, size = 0.75, tape = 0.18, age = 0.15 },
    speciale = { nota_sbagliata = true } } },

{ id = "nonni", strato = -1, x = 0.15, terreno = "piastrelle", nome = T("Giorno dopo giorno", "Day after day"),
  ora = T("La casa dei nonni in un giorno qualunque: l'orologio, la radio bassa, qualcuno che chiama il tuo nome dall'altra stanza.",
          "Your grandparents' house on an ordinary day: the clock, the radio low, someone calling your name from the next room."),
  allora = T("Non ti hanno tenuto solo d'estate. Ti hanno cresciuto loro, un giorno dopo l'altro, come se fosse la cosa più naturale del mondo.",
             "They didn't just have you for the summer. They raised you, day after day, as if it were the most natural thing in the world."),
  altro = { T("Il sugo sul fuoco dalla mattina. Nessuno ti chiede niente.", "Sauce on the stove since morning. Nobody asks anything of you."),
    T("Il nonno gira la pagina del giornale. La nonna assaggia.", "Grandpa turns the newspaper page. Grandma tastes the sauce.") },
  macro = { "radio", "infanzia", "tempo" }, macro_def = { 0.3, 0.3, 0.5 },
  musica = { tonica = 50, modo = "ionio", bpm = 66, prog = { 1, 6, 2, 5 }, accordo = "settima", battute = 2, glide = 8, tema = 0.25,
    drone = { amp = 0.28, cut = 900, shape = 0.3, sub = 0.2, air = 0.1 },
    linee = { l("melodia", "guitar", 1, 0.3, 0.6, { bright = 0.45, legato = 2 }), l("accordo", "piano", 0, 0.2, 0.6, { legato = 1.2, bright = 0.3 }),
      l("basso", "piano", -1, 0.24, 0.5, { legato = 1, bright = 0.2 }), l("risposta", "accordion", 0, 0.14, 0.3) },
    tex = { clock = 0.4, voices = 0.14, crackle = 0.08 }, fx = { rev = 0.38, size = 0.7, tape = 0.3, age = 0.38, hiss = 0.15 } } },

{ id = "lettura", strato = -1, x = 0.25, terreno = "moquette", nome = T("Lei che legge", "She reads"),
  ora = T("Lei legge sotto la lampada. Tu la guardi leggere, ed è già una storia.", "She reads under the lamp. You watch her read, and that is already a story."),
  allora = T("Le parole le piacciono da sempre: da dove vengono, cosa nascondono dentro.", "She has always loved words: where they come from, what they hide inside."),
  altro = { T("Gira la pagina. Il mondo aspetta.", "She turns the page. The world waits."),
    T("Un giorno le hai regalato un libro scritto apposta per lei.", "One day you gave her a book written just for her.") },
  macro = { "calore", "silenzio", "pioggia" }, macro_def = { 0.7, 0.2, 0.2 },
  musica = { tonica = 51, modo = "ionio", bpm = 56, prog = { 1, 4, 2, 5 }, accordo = "settima", battute = 4, glide = 12, tema = 0.2,
    drone = { amp = 0.28, cut = 900, shape = 0.2, sub = 0.2, breath = 0.4 },
    linee = { l("melodia", "piano", 0, 0.3, 0.6, { legato = 2.6, bright = 0.3 }), l("accordo", "strings", 0, 0.14, 0.5, { atk = 3 }),
      l("risposta", "celesta", 1, 0.14, 0.3) },
    tex = { clock = 0.1 }, fx = { rev = 0.5, size = 0.78, tape = 0.1, age = 0.08 } } },

{ id = "figlio", strato = -1, x = 0.35, terreno = "legno", nome = T("Tuo figlio", "Your son"),
  ora = T("Giugno. Il primo vagito, poi il silenzio stupito, poi il suo respiro contro il tuo petto.",
          "June. The first cry, then an astonished silence, then his breath against your chest."),
  allora = T("Ti ha rivoluzionato tutto. Le notti, le priorità, la paura, la gioia.", "He turned everything upside down. The nights, the priorities, the fear, the joy."),
  altro = { T("Una cosa così piccola, e il mondo intero si sposta.", "Something so small, and the whole world shifts.") },
  macro = { "luce", "respiro", "coro" }, macro_def = { 0.7, 0.4, 0.2 },
  musica = { tonica = 55, modo = "ionio", bpm = 60, prog = { 1, 4, 6, 5 }, accordo = "add9", battute = 4, glide = 10, tema = 0.4,
    drone = { amp = 0.32, cut = 1300, shape = 0.15, sub = 0.2, air = 0.3, breath = 0.5 },
    linee = { l("melodia", "celesta", 1, 0.28, 0.7, { legato = 2.5 }), l("accordo", "strings", 0, 0.2, 0.7, { atk = 3 }),
      l("risposta", "hum", 0, 0.2, 0.5) },
    tex = { birds = 0.2 }, fx = { rev = 0.6, size = 0.88, shimmer = 0.35, tape = 0.06 } } },

{ id = "soffitta", strato = -1, x = 0.45, terreno = "legno", nome = T("La soffitta", "The attic"),
  ora = T("Il baule si apre con un sospiro. Dentro, fotografie di gente che sorride a qualcuno che non c'è più.",
          "The trunk opens with a sigh. Inside, photographs of people smiling at someone who is no longer there."),
  allora = T("La nonna scriveva i nomi dietro le foto, perché qualcuno se li ricordasse.", "Grandma wrote the names on the backs of the photos, so someone would remember them."),
  altro = { T("La polvere nella luce del lucernario sembra neve che sale.", "The dust in the skylight beam looks like snow falling upwards.") },
  macro = { "ricordo", "fragilita", "luce" },
  musica = { tonica = 57, modo = "eolio", bpm = 52, metro = 3, prog = { 1, 6, 3, 7 }, accordo = "add9", battute = 2, glide = 10, tema = 0.25,
    drone = { amp = 0.3, cut = 850, shape = 0.25, sub = 0.25 },
    linee = { l("melodia", "musicbox", 1, 0.26, 0.6, { legato = 3 }), l("accordo", "piano", 0, 0.2, 0.5, { bright = 0.25 }),
      l("onde", "swell", 0, 0.18, 0.3) },
    tex = { radio = 0.12, crackle = 0.15, wind = 0.06 }, fx = { rev = 0.55, size = 0.8, tape = 0.35, age = 0.35, hiss = 0.2 } } },

{ id = "sottoscala", strato = -1, x = 0.5, terreno = "legno", nome = T("Il sottoscala", "Under the stairs"),
  ora = T("Il triangolo di buio sotto i gradini. Sopra la testa passano i piedi degli adulti. Qui dentro nessuno ti trova.",
          "The triangle of dark under the steps. Grown-ups' feet pass overhead. In here nobody can find you."),
  allora = T("Ti nascondevi qui, con le ginocchia al petto. Era il tuo posto sicuro. Lo è ancora: basta chiudere gli occhi.",
             "You hid here, knees to your chest. It was your safe place. It still is: you only have to close your eyes."),
  altro = { T("La polvere gira lenta nella striscia di luce.", "The dust turns slowly in the strip of light.") },
  macro = { "battito", "voci", "silenzio" }, macro_def = { 0.2, 0.3, 0.2 },
  musica = { tonica = 52, modo = "eolio", bpm = 56, prog = { 1, 6, 1, 7 }, accordo = "add9", battute = 2, glide = 10, tema = 0.2,
    drone = { amp = 0.3, cut = 500, shape = 0.25, sub = 0.35, air = 0.05, breath = 0.5 },
    linee = { l("melodia", "musicbox", 1, 0.2, 0.6, { bright = 0.08, legato = 2.5 }), l("accordo", "bowed", -1, 0.16, 0.4, { atk = 2 }),
      l("basso", "sub", -1, 0.24, 0.4) },
    tex = { voices = 0.2, heart = 0.1, rumble = 0.06 }, fx = { rev = 0.3, size = 0.55, tape = 0.15, age = 0.2, dark = 0.45 },
    speciale = { hrate = 1.15 } } },

{ id = "nonno", strato = -1, x = 0.55, terreno = "piastrelle", nome = T("Il nonno tra le stanze", "Grandfather between rooms"),
  ora = T("Il nonno, malato, si trascina da una stanza all'altra. Le pantofole strisciano, la mano cerca lo stipite.",
          "Grandfather, ill, drags himself from room to room. Slippers shuffling, his hand searching for the door frame."),
  allora = T("Era l'uomo più forte che conoscessi. Vederlo così ti ha insegnato una cosa che non sai ancora dire.",
             "He was the strongest man you knew. Seeing him like that taught you something you still can't put into words."),
  altro = { T("Una mano enorme, ruvida, calda, ti accarezzava la testa. Non serviva dire niente.", "A huge hand, rough and warm, stroked your head. Nothing needed saying.") },
  macro = { "lacrime", "respiro", "ricordo" },
  musica = { tonica = 53, modo = "eolio", bpm = 50, prog = { 1, 4, 6, 5 }, accordo = "add9", battute = 4, glide = 12, tema = 0.2,
    drone = { amp = 0.36, cut = 700, shape = 0.3, sub = 0.3, air = 0.08, breath = 0.45 },
    linee = { l("melodia", "bowed", -1, 0.32, 0.65, { atk = 0.8, legato = 1.5, riposo = 6 }), l("risposta", "piano", 1, 0.22, 0.4, { legato = 3, bright = 0.25 }),
      l("accordo", "strings", 0, 0.12, 0.35, { atk = 3, voci = 2 }) },
    tex = { clock = 0.3, breath = 0.1 }, fx = { rev = 0.55, size = 0.82, tape = 0.15, age = 0.18 } } },

{ id = "letto_nonni", strato = -1, x = 0.62, terreno = "legno", nome = T("Il vecchio letto", "The old bed"),
  ora = T("La coperta all'uncinetto, gli occhiali sul comodino, la corona del rosario. Tutto aspetta.",
          "The crocheted blanket, glasses on the nightstand, the rosary. Everything is waiting."),
  allora = T("Da piccolo ci dormivi in mezzo, quando avevi paura. Il loro respiro era la notte più sicura del mondo.",
             "As a child you slept between them when you were scared. Their breathing was the safest night in the world."),
  altro = { T("Il materasso conserva ancora la forma di due persone.", "The mattress still keeps the shape of two people.") },
  macro = { "ricordo", "silenzio", "calore" },
  musica = { tonica = 53, modo = "dorico", bpm = 50, prog = { 1, 4, 1, 7 }, accordo = "triade", battute = 4, glide = 12, tema = 0.25,
    drone = { amp = 0.3, cut = 800, shape = 0.2, sub = 0.25, breath = 0.5 },
    linee = { l("accordo", "harmonium", 0, 0.2, 0.7, { atk = 0.5 }), l("melodia", "piano", 1, 0.26, 0.55, { legato = 3, bright = 0.25 }) },
    tex = { clock = 0.2, breath = 0.08 }, fx = { rev = 0.55, size = 0.8, tape = 0.2, age = 0.25 } } },

{ id = "stanza_vuota", strato = -1, x = 0.7, terreno = "legno", nome = T("La stanza di chi non c'è più", "The room of the one who's gone"),
  ora = T("Il letto fatto, i vestiti piegati sulla sedia, le scarpe in fila. Nessuno ha avuto il coraggio di toccare niente.",
          "The bed made, clothes folded on the chair, shoes lined up. Nobody has had the courage to touch anything."),
  allora = T("Entravi senza bussare. Adesso ti fermi sempre sulla porta.", "You used to walk in without knocking. Now you always stop at the door."),
  altro = { T("La luce della finestra si sposta lenta sul pavimento, come ogni giorno.", "The window light moves slowly across the floor, as it does every day.") },
  macro = { "silenzio", "lacrime", "luce" },
  musica = { tonica = 50, modo = "eolio", bpm = 44, prog = { 1, 6, 4, 1 }, accordo = "aperto", battute = 4, glide = 16, tema = 0.2,
    drone = { amp = 0.3, cut = 700, shape = 0.1, sub = 0.25, breath = 0.6 },
    linee = { l("melodia", "piano", 0, 0.26, 0.4, { legato = 4, bright = 0.2, riposo = 14 }), l("accordo", "strings", 0, 0.14, 0.4, { atk = 4 }),
      l("onde", "swell", 0, 0.18, 0.35) },
    tex = {}, fx = { rev = 0.8, size = 0.93, tape = 0.1, hiss = 0.1 } } },

{ id = "scrivere", strato = -1, x = 0.78, terreno = "legno", nome = T("Il libro per lei", "The book for her"),
  ora = T("Di notte, una pagina dopo l'altra. Ripa dei Mori cresce sulla scrivania come una casa in costruzione.",
          "At night, one page after another. Ripa dei Mori grows on the desk like a house being built."),
  allora = T("Volevi regalarle una cosa che nessun negozio vende: una storia fatta solo per lei.", "You wanted to give her something no shop sells: a story made only for her."),
  altro = { T("Il tasto della e si inceppa sempre. Lo perdoni ogni volta.", "The e key always sticks. You forgive it every time.") },
  macro = { "tempo", "ricordo", "calore" },
  musica = { tonica = 48, modo = "dorico", bpm = 74, prog = { 1, 4, 7, 1 }, accordo = "settima", battute = 2, glide = 9, tema = 0.2,
    drone = { amp = 0.26, cut = 900, shape = 0.3, sub = 0.2 },
    linee = { l("melodia", "piano", 1, 0.3, 0.65, { legato = 2, bright = 0.35 }), l("arpeggio", "pluck", 0, 0.2, 0.45, { bright = 0.4 }),
      l("basso", "piano", -1, 0.22, 0.5, { legato = 1, bright = 0.2 }) },
    tex = { typewriter = 0.45, clock = 0.1, rain = 0.08 }, fx = { rev = 0.42, size = 0.72, tape = 0.15, age = 0.12 } } },

{ id = "ospedale", strato = -1, x = 0.9, terreno = "piastrelle", nome = T("L'ospedale di notte", "The hospital at night"),
  ora = T("Il corridoio verde, le sedie di plastica, il distributore che ronza. Da una porta si nasce, da un'altra si muore.",
          "The green corridor, plastic chairs, the humming vending machine. Through one door people are born, through another they die."),
  allora = T("Hai imparato qui che il tempo può fermarsi del tutto, alle quattro del mattino.", "Here you learned that time can stop completely, at four in the morning."),
  altro = { T("Il monitor conta per tutti, anche per te.", "The monitor counts for everyone, you included.") },
  macro = { "battito", "distanza", "silenzio" },
  musica = { tonica = 47, modo = "eolio", bpm = 58, prog = { 1, 7, 6, 7 }, accordo = "sus2", battute = 4, glide = 12,
    drone = { amp = 0.34, cut = 650, shape = 0.4, sub = 0.25, air = 0.05 },
    linee = { l("pulsazione", "bell", 2, 0.12, 0.14, { bright = 0, legato = 0.4 }), l("accordo", "strings", 0, 0.18, 0.6, { atk = 3 }),
      l("melodia", "piano", 0, 0.26, 0.4, { legato = 2.5, bright = 0.2, riposo = 10 }) },
    tex = { hum = 0.42 }, fx = { rev = 0.55, size = 0.8, tape = 0.08, age = 0.1, dark = 0.15 } } },

-------------------------------------------------------------------------------
-- -2 · LA MENTE
-------------------------------------------------------------------------------
{ id = "voci", strato = -2, x = 0.05, terreno = "vuoto", nome = T("Le voci nella testa", "Voices in the head"),
  ora = T("Parlano tutte insieme, vicinissime, e nessuna dice qualcosa che si possa capire fino in fondo.",
          "They all talk at once, very close, and none of them says anything you can fully understand."),
  allora = T("Di notte sentivi parlare dall'altra stanza e ti sembrava che parlassero di te.", "At night you heard talking in the next room and thought they were talking about you."),
  altro = { T("Se smetti di ascoltarle per un momento, ricominciano più forte.", "If you stop listening for a moment, they start again louder.") },
  macro = { "nevrosi", "voci", "distanza" }, macro_def = { 0.3, 0.4, 0.5 },
  musica = { tonica = 50, modo = "quarti", bpm = 92, prog = { 1, 2, 1, 4 }, accordo = "grappolo", battute = 1, glide = 4,
    drone = { amp = 0.32, cut = 1200, shape = 0.7, sub = 0.2, air = 0.2, detune = 0.6, wob = 0.4 },
    linee = { l("sussurri", "whisper", 1, 0.36, 0.9, { legato = 1 }), l("pulsazione", "pluck", 0, 0.22, 0.4, { bright = 0.7, legato = 0.6 }),
      l("schegge", "glitch", 1, 0.18, 0.5), l("melodia", "piano", 1, 0.22, 0.3, { legato = 1, bright = 0.6 }) },
    tex = { voices = 0.55, heart = 0.22 }, fx = { rev = 0.4, size = 0.6, shimmer = 0.1, tape = 0.4, crush = 0.1, hiss = 0.3 },
    speciale = { hrate = 1.5 } } },

{ id = "giudizio", strato = -2, x = 0.15, terreno = "pietra", nome = T("Il giudizio", "Judgement"),
  ora = T("Figure alte, senza faccia, in fila. Ognuna alza un dito e ti indica. Nessuna parla, e tu senti tutto.",
          "Tall faceless figures in a row. Each raises a finger and points at you. None speaks, and you hear everything."),
  allora = T("Era la tua voce, in realtà. È sempre stata la tua voce.", "It was your own voice, really. It has always been your own voice."),
  altro = { T("Se alzi lo sguardo, diventano più piccole.", "If you look up, they get smaller.") },
  macro = { "voci", "nevrosi", "profondita" },
  musica = { tonica = 49, modo = "locrio", bpm = 60, prog = { 1, 2, 5, 1 }, accordo = "grappolo", battute = 2, glide = 8,
    drone = { amp = 0.38, cut = 600, shape = 0.5, sub = 0.4, detune = 0.4 },
    linee = { l("accordo", "organ", -1, 0.22, 0.7, { atk = 0.6 }), l("accordo", "choir", -1, 0.14, 0.5, { atk = 2 }), l("sussurri", "whisper", 1, 0.26, 0.5) },
    tex = { voices = 0.35, rumble = 0.2 }, fx = { rev = 0.75, size = 0.9, tape = 0.2, dark = 0.25 } } },

{ id = "buio", strato = -2, x = 0.25, terreno = "legno", nome = T("La paura del buio", "Fear of the dark"),
  ora = T("Non sai dove sei finito. Qualcosa scricchiola alla tua sinistra. Il tuo respiro è il rumore più forte.",
          "You don't know where you are. Something creaks to your left. Your breathing is the loudest sound."),
  allora = T("Lasciavano la porta socchiusa e la luce del corridoio accesa. Bastava quella striscia.", "They left the door ajar and the hall light on. That strip of light was enough."),
  altro = { T("L'armadio ha una forma diversa, al buio.", "The wardrobe has a different shape in the dark.") },
  macro = { "battito", "profondita", "silenzio" },
  musica = { tonica = 49, modo = "frigio", bpm = 48, prog = { 1, 2, 1, 7 }, accordo = "grappolo", battute = 4, glide = 14,
    drone = { amp = 0.4, cut = 420, shape = 0.5, sub = 0.45, air = 0.04, breath = 0.6 },
    linee = { l("melodia", "bowed", -1, 0.26, 0.4, { atk = 1.5, legato = 1.4, riposo = 14 }), l("onde", "swell", -1, 0.24, 0.4),
      l("scintille", "drop", 2, 0.2, 0.3) },
    tex = { heart = 0.4, drip = 0.15, rumble = 0.25 }, fx = { rev = 0.5, size = 0.85, tape = 0.12, age = 0.1, dark = 0.5 },
    speciale = { hrate = 1.25 } } },

{ id = "specchio", strato = -2, x = 0.35, terreno = "piastrelle", nome = T("Lo specchio", "The mirror"),
  ora = T("Il riflesso arriva sempre un momento dopo. A volte fa un gesto che tu non hai fatto.", "The reflection always arrives a moment late. Sometimes it makes a gesture you didn't make."),
  allora = T("Ti guardavi a lungo, da ragazzo, per capire chi saresti diventato.", "As a boy you'd look for a long time, trying to see who you'd become."),
  altro = { T("Chi dei due è quello vero?", "Which of the two is the real one?") },
  macro = { "eco", "fragilita", "luce" }, macro_def = { 0.4, 0.2, 0.5 },
  musica = { tonica = 47, modo = "eolio", bpm = 56, prog = { 1, 6, 1, 7 }, accordo = "add9", battute = 2, glide = 10,
    drone = { amp = 0.3, cut = 900, shape = 0.3, sub = 0.25 },
    linee = { l("melodia", "rhodes", 0, 0.3, 0.6, { legato = 2.4 }), l("risposta", "celesta", 1, 0.2, 0.6), l("onde", "swell", 0, 0.2, 0.4) },
    tex = { drip = 0.1 }, fx = { rev = 0.55, size = 0.8, shimmer = 0.15, echo = 0.4, etime = 0.35 } } },

{ id = "incubo", strato = -2, x = 0.45, terreno = "legno", nome = T("L'incubo", "The nightmare"),
  ora = T("Ti svegli di colpo nel buio, con il cuore in gola. Eri sicuro di aver perso la persona che ami di più.",
          "You wake suddenly in the dark, heart in your throat. You were sure you'd lost the person you love most."),
  allora = T("Ti alzi a controllare che respiri. Respira. Torni a letto, ma non dormi più.", "You get up to check that he's breathing. He is. You go back to bed, but you don't sleep again."),
  altro = { T("Le nuvole corrono davanti alla luna come se scappassero.", "The clouds race across the moon as if fleeing.") },
  macro = { "nevrosi", "battito", "tempo" },
  musica = { tonica = 54, modo = "locrio", bpm = 104, prog = { 1, 2, 5, 1 }, accordo = "grappolo", battute = 1, glide = 3,
    drone = { amp = 0.34, cut = 900, shape = 0.75, sub = 0.4, air = 0.1, detune = 0.5, wob = 0.5 },
    linee = { l("pulsazione", "pluck", -1, 0.3, 0.45, { bright = 0.4, legato = 0.5 }), l("schegge", "glitch", 1, 0.2, 0.5),
      l("melodia", "bowed", 0, 0.22, 0.4, { atk = 0.3, legato = 1 }), l("basso", "sub", -1, 0.32, 0.8) },
    tex = { heart = 0.55, voices = 0.18, wind = 0.15 }, fx = { rev = 0.42, size = 0.7, tape = 0.35, crush = 0.12, age = 0.2 },
    speciale = { hrate = 1.9 } } },

{ id = "tre_notte", strato = -2, x = 0.55, terreno = "legno", nome = T("Le tre di notte", "Three in the morning"),
  ora = T("La sveglia segna le tre e diciassette. I fari delle macchine attraversano il soffitto, uno ogni tanto.",
          "The clock says three seventeen. Car headlights cross the ceiling, one every now and then."),
  allora = T("Da piccolo contavi i fari sul soffitto finché non dimenticavi il numero.", "As a child you counted the lights on the ceiling until you forgot the number."),
  altro = { T("Tutti i pensieri difficili aspettano quest'ora per bussare.", "All the hard thoughts wait for this hour to knock.") },
  macro = { "battito", "silenzio", "nevrosi" }, macro_def = { 0.3, 0.3, 0.1 },
  musica = { tonica = 52, modo = "frigio", bpm = 52, prog = { 1, 2, 1, 6 }, accordo = "add9", battute = 4, glide = 14,
    drone = { amp = 0.34, cut = 700, shape = 0.3, sub = 0.3, breath = 0.5 },
    linee = { l("melodia", "rhodes", 0, 0.28, 0.5, { legato = 2.5, riposo = 10 }), l("onde", "swell", 0, 0.2, 0.4) },
    tex = { clock = 0.25, city = 0.08, heart = 0.12 }, fx = { rev = 0.6, size = 0.85, tape = 0.15, dark = 0.2 } } },

{ id = "occasioni", strato = -2, x = 0.65, terreno = "pietra", nome = T("Le occasioni perdute", "The missed chances"),
  ora = T("Un corridoio pieno di porte socchiuse. Dietro ognuna una luce diversa. Una alla volta, si chiudono.",
          "A corridor full of half-open doors. Behind each, a different light. One by one, they close."),
  allora = T("Non le hai viste passare. Te ne sei accorto solo dal rumore della porta.", "You didn't see them go by. You only noticed from the sound of the door."),
  altro = { T("Ogni tanto una si riapre. Bisogna restare abbastanza per vederlo.", "Now and then one opens again. You have to stay long enough to see it.") },
  macro = { "ricordo", "lacrime", "distanza" },
  musica = { tonica = 52, modo = "eolio", bpm = 54, prog = { 1, 4, 6, 5 }, accordo = "add9", battute = 4, glide = 12, tema = 0.2,
    drone = { amp = 0.34, cut = 750, shape = 0.25, sub = 0.3 },
    linee = { l("melodia", "piano", 0, 0.3, 0.6, { legato = 2.6, bright = 0.25 }), l("accordo", "strings", 0, 0.16, 0.5, { atk = 3 }), l("onde", "swell", 0, 0.2, 0.4) },
    tex = { clock = 0.18 }, fx = { rev = 0.7, size = 0.9, tape = 0.15, age = 0.1 } } },

{ id = "fuga", strato = -2, x = 0.75, terreno = "piastrelle", nome = T("La fuga", "Running away"),
  ora = T("Corri in un corridoio che non finisce. Qualcosa ti segue, sempre alla stessa distanza.", "You run down a corridor that never ends. Something follows, always the same distance behind."),
  allora = T("Scappavi da cose che, a guardarle, erano piccolissime.", "You ran from things that, when you looked at them, were tiny."),
  altro = { T("Se ti fermi, si ferma anche lei.", "If you stop, so does it.") },
  macro = { "tempo", "battito", "nevrosi" },
  musica = { tonica = 55, modo = "frigio", bpm = 132, prog = { 1, 2, 1, 7 }, accordo = "grappolo", battute = 1, glide = 3,
    drone = { amp = 0.3, cut = 1000, shape = 0.7, sub = 0.35, detune = 0.4 },
    linee = { l("pulsazione", "pluck", 0, 0.28, 0.55, { bright = 0.5, legato = 0.5 }), l("accordo", "strings", 0, 0.16, 0.6, { atk = 0.4 }),
      l("basso", "sub", -1, 0.3, 0.8) },
    tex = { heart = 0.45, breath = 0.3 }, fx = { rev = 0.35, size = 0.6, tape = 0.2, age = 0.1 }, speciale = { hrate = 2.1 } } },

{ id = "rabbia", strato = -2, x = 0.85, terreno = "erba", nome = T("La rabbia", "Anger"),
  ora = T("Sei per terra sotto il temporale, e sei arrabbiato con la vita. Per quello che ti ha tolto, per come, per quando.",
          "You're on the ground in the storm, angry at life. For what it took from you, for how, for when."),
  allora = T("Hai urlato contro tutto. Il cielo ha risposto con un tuono, e ti è sembrato giusto.", "You screamed at everything. The sky answered with thunder, and it felt right."),
  altro = { T("La rabbia non riporta indietro nessuno. Ma per un momento scalda.", "Anger brings no one back. But for a moment it keeps you warm.") },
  macro = { "nevrosi", "vento", "pioggia" }, macro_def = { 0.3, 0.5, 0.5 },
  musica = { tonica = 50, modo = "frigio", bpm = 96, prog = { 1, 2, 7, 1 }, accordo = "grappolo", battute = 2, glide = 5,
    drone = { amp = 0.4, cut = 800, shape = 0.8, sub = 0.45, detune = 0.5 },
    linee = { l("pulsazione", "strings", 0, 0.22, 0.4, { atk = 0.05, legato = 0.6 }), l("basso", "sub", -1, 0.34, 0.8),
      l("schegge", "glitch", 1, 0.18, 0.4), l("melodia", "bowed", 0, 0.24, 0.4, { atk = 0.2 }) },
    tex = { storm = 0.55, wind = 0.4 }, fx = { rev = 0.5, size = 0.8, tape = 0.25, crush = 0.08 } } },

{ id = "pavimento", strato = -2, x = 0.95, terreno = "marmo", nome = T("Il pavimento gelido", "The cold floor"),
  ora = T("Ti sei steso per terra. Il pavimento è gelido contro la guancia. Non pensi più a niente. Va bene così.",
          "You've lain down on the floor. It's icy against your cheek. You think of nothing. That's all right."),
  allora = T("Anche allora ti eri steso così, dopo quella telefonata, e il freddo era l'unica cosa vera.",
             "You lay like this back then too, after that phone call, and the cold was the only real thing."),
  altro = { T("La luce della finestra si sposta sul pavimento. È l'unica cosa che si muove.", "The window light moves across the floor. It's the only thing that moves.") },
  macro = { "silenzio", "calore", "luce" }, macro_def = { 0.2, 0.25, 0.4 },
  musica = { tonica = 52, modo = "eolio", bpm = 40, prog = { 1, 1, 6, 1 }, accordo = "aperto", battute = 4, glide = 18, pedale = true,
    drone = { amp = 0.34, cut = 520, shape = 0.15, sub = 0.3, air = 0.05, breath = 0.6 },
    linee = { l("melodia", "piano", 0, 0.26, 0.3, { legato = 4, bright = 0.15, riposo = 16 }), l("onde", "swell", 0, 0.2, 0.3) },
    tex = { hum = 0.08, rumble = 0.15 }, fx = { rev = 0.82, size = 0.95, tape = 0.1, age = 0.12, dark = 0.4 } } },

-------------------------------------------------------------------------------
-- -3 · L'ABISSO
-------------------------------------------------------------------------------
{ id = "palude", strato = -3, x = 0.05, terreno = "acqua", nome = T("La palude", "The marsh"),
  ora = T("L'acqua arriva alle caviglie e non si vede il fondo. Piccole luci si accendono tra le canne.",
          "The water reaches your ankles and you can't see the bottom. Little lights flicker among the reeds."),
  allora = T("Ti dicevano di non seguirle mai, quelle luci. Non ti hanno mai detto perché.", "They told you never to follow those lights. They never told you why."),
  altro = { T("Le rane smettono di cantare quando passi.", "The frogs stop singing as you pass.") },
  macro = { "nebbia", "notte", "profondita" },
  musica = { tonica = 50, modo = "frigio", bpm = 40, prog = { 1, 2, 1, 7 }, accordo = "aperto", battute = 4, glide = 16,
    drone = { amp = 0.38, cut = 550, shape = 0.25, sub = 0.4, breath = 0.5 },
    linee = { l("melodia", "bowed", -1, 0.24, 0.4, { atk = 1.5, legato = 1.5 }), l("onde", "swell", 0, 0.2, 0.4), l("scintille", "drop", 2, 0.16, 0.3) },
    tex = { frogs = 0.45, stream = 0.08, crick = 0.1 }, fx = { rev = 0.75, size = 0.9, dark = 0.4, tape = 0.12 } } },

{ id = "lete", strato = -3, x = 0.2, terreno = "acqua", nome = T("Il fiume dell'oblio", "The river of forgetting"),
  ora = T("L'acqua è nera e lenta. Ti chini a bere, e qualcosa che sapevi non lo sai più.", "The water is black and slow. You bend to drink, and something you knew is gone."),
  allora = T("C'era una canzone. Ne ricordi solo il modo in cui finiva.", "There was a song. You only remember the way it ended."),
  altro = { T("Le parole galleggiano un poco, poi vanno giù.", "The words float for a moment, then sink.") },
  macro = { "nebbia", "profondita", "fragilita" },
  musica = { tonica = 45, modo = "eolio", bpm = 44, prog = { 1, 7, 6, 7 }, accordo = "aperto", battute = 4, glide = 16,
    drone = { amp = 0.4, cut = 520, shape = 0.2, sub = 0.4, air = 0.05, breath = 0.5 },
    linee = { l("onde", "swell", 0, 0.3, 0.7), l("melodia", "piano", 1, 0.24, 0.4, { legato = 3, bright = 0.15, riposo = 10 }),
      l("accordo", "bowed", -1, 0.18, 0.4, { atk = 4, voci = 2 }) },
    tex = { stream = 0.4, rumble = 0.15 }, fx = { rev = 0.85, size = 0.95, tape = 0.3, age = 0.2, dark = 0.45 },
    speciale = { oblio = 0.3 } } },

{ id = "metro", strato = -3, x = 0.35, terreno = "metallo", nome = T("La metropolitana chiusa", "The closed subway"),
  ora = T("La stazione è chiusa da anni. A volte passa ancora un treno, vuoto, con le luci accese.", "The station has been closed for years. Sometimes a train still passes, empty, lights on."),
  allora = T("Sei rimasto sul binario a guardarlo andare via, con la porta che si chiudeva davanti a te.", "You stayed on the platform watching it leave, the door closing in front of you."),
  altro = { T("Le piastrelle bianche ricordano tutti i passi.", "The white tiles remember every footstep.") },
  macro = { "treno", "eco", "nevrosi" },
  musica = { tonica = 53, modo = "locrio", bpm = 70, prog = { 1, 2, 1, 5 }, accordo = "add9", battute = 2, glide = 8,
    drone = { amp = 0.34, cut = 700, shape = 0.5, sub = 0.35, detune = 0.3 },
    linee = { l("melodia", "rhodes", 0, 0.26, 0.5, { legato = 2 }), l("pulsazione", "sub", -1, 0.24, 0.3, { legato = 0.6 }), l("schegge", "glitch", 1, 0.12, 0.3) },
    tex = { train = 0.15, hum = 0.3, drip = 0.12 }, fx = { rev = 0.7, size = 0.88, tape = 0.2, echo = 0.25, etime = 0.7 } } },

{ id = "sommerso", strato = -3, x = 0.5, terreno = "acqua", nome = T("Il mondo sommerso", "The drowned world"),
  ora = T("Sotto l'acqua c'è un paese intero: le case, la piazza, il campanile. Nessuno è andato via. Hanno solo smesso di parlare.",
          "Under the water there is a whole village: houses, square, bell tower. Nobody left. They just stopped talking."),
  allora = T("Dicevano che nelle notti calme si sentivano ancora le campane, da sotto il lago.", "They said that on calm nights you could still hear the bells, from under the lake."),
  altro = { T("La luce arriva tardi, quaggiù, e arriva già stanca.", "Light arrives late down here, and already tired.") },
  macro = { "profondita", "campane", "eco" },
  musica = { tonica = 48, modo = "esatonale", bpm = 40, prog = { 1, 2, 1, 4 }, accordo = "triade", battute = 4, glide = 16,
    drone = { amp = 0.38, cut = 600, shape = 0.1, sub = 0.4, air = 0.04, breath = 0.6, wob = 0.3 },
    linee = { l("campane", "campana", 0, 0.42, 0.25, { bright = 0.1 }), l("melodia", "bell", 0, 0.22, 0.4, { bright = 0.1, legato = 4, riposo = 10 }),
      l("accordo", "choir", -1, 0.2, 0.4, { atk = 5, voci = 2 }) },
    tex = { bubble = 0.5, rumble = 0.25 }, fx = { rev = 0.9, size = 0.97, tape = 0.25, age = 0.1, dark = 0.72 } } },

{ id = "pianto", strato = -3, x = 0.65, terreno = "acqua", nome = T("Piangere", "Crying"),
  ora = T("Piove, e non si capisce più cosa sia pioggia e cosa no. Ti siedi in mezzo alla strada e lasci fare.",
          "It's raining, and you can't tell any more what is rain and what isn't. You sit in the middle of the road and let it happen."),
  allora = T("Da grande non piangevi più. Poi un giorno hai ricominciato, e ti sei sentito di nuovo bambino.",
             "As a grown man you'd stopped crying. Then one day you started again, and felt like a child once more."),
  altro = { T("La pozzanghera si allarga, e ci si specchia il lampione.", "The puddle spreads, and the streetlamp looks at itself in it.") },
  macro = { "pioggia", "lacrime", "respiro" }, macro_def = { 0.5, 0.5, 0.4 },
  musica = { tonica = 57, modo = "eolio", bpm = 50, prog = { 1, 6, 3, 7 }, accordo = "add9", battute = 4, glide = 12, tema = 0.2,
    drone = { amp = 0.34, cut = 700, shape = 0.25, sub = 0.3, breath = 0.55 },
    linee = { l("accordo", "strings", 0, 0.22, 0.7, { atk = 3 }), l("melodia", "piano", 1, 0.28, 0.55, { legato = 3, bright = 0.25 }),
      l("risposta", "hum", 0, 0.18, 0.4) },
    tex = { rain = 0.45 }, fx = { rev = 0.75, size = 0.9, tape = 0.12 } } },

{ id = "vuoto", strato = -3, x = 0.8, terreno = "vuoto", nome = T("Il vuoto", "The void"),
  ora = T("Al posto di una persona, adesso, c'è una forma esatta di niente. Ci inciampi dieci volte al giorno.",
          "Where a person was, there is now an exact shape of nothing. You trip over it ten times a day."),
  allora = T("Ti dicono che col tempo passa. Non passa: impari a camminarci intorno.", "They tell you it passes with time. It doesn't: you learn to walk around it."),
  altro = { T("La sedia è rimasta dov'era.", "The chair is still where it was.") },
  macro = { "silenzio", "lacrime", "eco" },
  musica = { tonica = 50, modo = "eolio", bpm = 36, prog = { 1, 6, 1, 4 }, accordo = "aperto", battute = 4, glide = 20, pedale = true,
    drone = { amp = 0.32, cut = 600, shape = 0.0, sub = 0.25, air = 0.1, breath = 0.7 },
    linee = { l("onde", "swell", 0, 0.24, 0.5), l("melodia", "piano", 1, 0.2, 0.2, { legato = 4, bright = 0.1, riposo = 20 }) },
    tex = { wind = 0.04 }, fx = { rev = 0.95, size = 0.98, shimmer = 0.08, tape = 0.1, hiss = 0.2 } } },

{ id = "grembo", strato = -3, x = 0.95, terreno = "vuoto", uscite = { su = "alba", sx = "vuoto" }, nome = T("Prima di nascere", "Before being born"),
  ora = T("Caldo, buio, un cuore che batte vicinissimo. Non sai ancora niente, e va bene così.", "Warm, dark, a heart beating very close. You know nothing yet, and that's fine."),
  allora = T("In fondo all'abisso c'è l'inizio. Nessuno te l'aveva detto.", "At the bottom of the abyss lies the beginning. Nobody had told you."),
  altro = { T("Da qui si può solo salire.", "From here, the only way is up.") },
  macro = { "battito", "calore", "respiro" }, macro_def = { 0.5, 0.7, 0.4 },
  musica = { tonica = 48, modo = "penta", bpm = 40, prog = { 1, 1, 4, 1 }, accordo = "aperto", battute = 4, glide = 18, pedale = true, tema = 0.3,
    drone = { amp = 0.36, cut = 600, shape = 0.05, sub = 0.4, breath = 0.7 },
    linee = { l("melodia", "hum", 0, 0.26, 0.6, { legato = 2 }), l("onde", "swell", 0, 0.2, 0.4), l("pulsazione", "sub", -1, 0.16, 0.12, { legato = 0.8 }) },
    tex = { heart = 0.5, bubble = 0.08 }, fx = { rev = 0.7, size = 0.9, dark = 0.55, tape = 0.1 }, speciale = { hrate = 1.0 } } },

-------------------------------------------------------------------------------
-- I LUOGHI NASCOSTI (si aprono solo se resti abbastanza)
-------------------------------------------------------------------------------
{ id = "trono", strato = 3, x = 1.1, terreno = "nuvola", segreto = { da = { "empireo" }, dopo = 150 }, uscite = { giu = "empireo" },
  nome = T("Sopra ogni cosa", "Above everything"),
  ora = T("Ti siedi sul bordo del mondo. Laggiù, piccolissimo, tutto quello che hai attraversato.", "You sit on the edge of the world. Down there, tiny, everything you have crossed."),
  allora = T("Da quassù nessun dolore ha più la sua misura. Resta solo la luce.", "From up here no pain keeps its size. Only light remains."),
  altro = { T("Le città di notte sembrano costellazioni capovolte.", "Cities at night look like upside-down constellations.") },
  macro = { "luce", "coro", "silenzio" },
  musica = { tonica = 48, modo = "ionio", bpm = 40, prog = { 1, 4, 1, 5 }, accordo = "aperto", battute = 4, glide = 18, tema = 0.35,
    drone = { amp = 0.42, cut = 1600, shape = 0.2, sub = 0.3, air = 0.4, breath = 0.4 },
    linee = { l("accordo", "organ", 0, 0.2, 0.7, { atk = 2 }), l("accordo", "choir", 1, 0.18, 0.6, { atk = 4 }), l("melodia", "strings", 1, 0.2, 0.5, { atk = 1, legato = 1.5 }) },
    tex = { wind = 0.08 }, fx = { rev = 0.9, size = 0.98, shimmer = 0.6 } } },

{ id = "neve", strato = 2, x = 1.1, terreno = "neve", segreto = { da = { "baita" }, dopo = 150 }, uscite = { giu = "baita", su = "pace" },
  nome = T("La prima neve", "The first snow"),
  ora = T("Il mondo ha smesso di fare rumore. Si sente solo il fuoco, da dentro.", "The world has stopped making noise. Only the fire can be heard, from inside."),
  allora = T("Ti svegliavi e capivi che aveva nevicato dal silenzio, prima ancora di guardare.", "You'd wake and know it had snowed from the silence, before you even looked."),
  altro = { T("Le impronte si riempiono piano. Fra un'ora nessuno saprà che sei passato.", "The footprints slowly fill. In an hour nobody will know you passed.") },
  macro = { "vento", "luce", "silenzio" },
  musica = { tonica = 58, modo = "ionio", bpm = 46, prog = { 1, 4, 1, 5 }, accordo = "add9", battute = 4, glide = 14, tema = 0.2,
    drone = { amp = 0.32, cut = 1200, shape = 0.05, sub = 0.2, air = 0.3, breath = 0.5 },
    linee = { l("melodia", "celesta", 1, 0.24, 0.5, { bright = 0.12, legato = 4, riposo = 10 }), l("scintille", "bell", 2, 0.1, 0.35, { bright = 0.3 }),
      l("accordo", "strings", 0, 0.14, 0.4, { atk = 4 }) },
    tex = { fire = 0.1, wind = 0.06 }, fx = { rev = 0.78, size = 0.94, shimmer = 0.3, dark = 0.1 } } },

{ id = "faro", strato = 1, x = 1.1, terreno = "pietra", segreto = { da = { "mare" }, dopo = 120 }, uscite = { giu = "mare", su = "vetta" },
  nome = T("Il faro", "The lighthouse"),
  ora = T("Il fascio di luce gira e gira, e ogni volta tocca il mare nello stesso punto.", "The beam turns and turns, and each time touches the sea in the same place."),
  allora = T("Qualcuno ci lavorava, una volta. Accendeva la luce per gente che non avrebbe mai conosciuto.", "Someone used to work here. He lit the lamp for people he'd never meet."),
  altro = { T("Anche tu sei stato un faro per qualcuno, senza saperlo.", "You too have been a lighthouse for someone, without knowing it.") },
  macro = { "mare", "vento", "luce" },
  musica = { tonica = 52, modo = "lidio", bpm = 50, prog = { 1, 2, 5, 1 }, accordo = "add9", battute = 4, glide = 14,
    drone = { amp = 0.36, cut = 1000, shape = 0.2, sub = 0.3, breath = 0.5 },
    linee = { l("melodia", "rhodes", 0, 0.28, 0.5, { legato = 3 }), l("accordo", "strings", 0, 0.18, 0.6, { atk = 4 }) },
    tex = { sea = 0.55, wind = 0.2 }, fx = { rev = 0.75, size = 0.92, shimmer = 0.25 } } },

{ id = "alba", strato = -2, x = 1.1, terreno = "erba", segreto = { da = { "pavimento" }, dopo = 120 }, uscite = { giu = "pavimento", su = "pace" },
  nome = T("L'alba", "Dawn"),
  ora = T("Ti rialzi. Prima in ginocchio, poi in piedi. Fuori il cielo si schiarisce senza chiedere il permesso.",
          "You get up. First to your knees, then to your feet. Outside the sky brightens without asking permission."),
  allora = T("Anche questo è passato. O passerà. Da qui non si vede, ma succede.", "This too has passed. Or will. You can't see it from here, but it happens."),
  altro = { T("Il primo uccello canta da solo, come se fosse il primo di tutti.", "The first bird sings alone, as if it were the first of all.") },
  macro = { "luce", "coro", "respiro" }, macro_def = { 0.6, 0.3, 0.5 },
  musica = { tonica = 53, modo = "lidio", bpm = 56, prog = { 1, 2, 5, 1 }, accordo = "add9", battute = 4, glide = 12, tema = 0.35,
    drone = { amp = 0.4, cut = 1300, shape = 0.25, sub = 0.25, air = 0.3, breath = 0.35 },
    linee = { l("accordo", "strings", 0, 0.22, 0.8, { atk = 4 }), l("melodia", "celesta", 1, 0.22, 0.55, { bright = 0.3, legato = 3 }),
      l("onde", "swell", 1, 0.22, 0.6), l("risposta", "breath", 1, 0.2, 0.3, { legato = 2 }) },
    tex = { birds = 0.3, wind = 0.08 }, fx = { rev = 0.7, size = 0.9, shimmer = 0.45, tape = 0.06 } } },

{ id = "silenzio", strato = -3, x = 1.1, terreno = "vuoto", segreto = { da = { "vuoto" }, dopo = 180 }, uscite = { su = "mare_stelle", giu = "vuoto" },
  nome = T("Il mondo senza suono", "The world without sound"),
  ora = T("Qui non arriva più niente. Nemmeno il dolore. Solo una luce piccola, che non chiede niente.", "Nothing reaches here any more. Not even pain. Only a small light that asks for nothing."),
  allora = T("Era il silenzio di dopo. Lo hai attraversato, e non lo sapevi.", "It was the silence that comes after. You crossed it, and didn't know."),
  altro = { T("Senti il sangue nelle orecchie. Vuol dire che ci sei.", "You hear the blood in your ears. It means you're here.") },
  macro = { "silenzio", "luce", "eco" },
  musica = { tonica = 48, modo = "penta", bpm = 32, prog = { 1, 1, 1, 1 }, accordo = "aperto", battute = 8, glide = 24, pedale = true,
    drone = { amp = 0.22, cut = 500, shape = 0.0, sub = 0.25, air = 0.05, breath = 0.8 },
    linee = { l("coppa", "coppa", 0, 0.2, 0.4, { bright = 0.2 }), l("scintille", "bell", 2, 0.06, 0.15, { bright = 0 }) },
    tex = { heart = 0.08 }, fx = { rev = 0.95, size = 0.99, shimmer = 0.2, dark = 0.6 }, speciale = { hrate = 0.9 } } },

{ id = "altrove", strato = -1, x = 1.2, terreno = "legno", segreto = { da = { "conca", "soglia", "occasioni" }, dopo = 200 },
  uscite = { su = "altrove", giu = "altrove", sx = "altrove", dx = "altrove" },
  nome = T("Altrove", "Elsewhere"),
  ora = T("Non c'eri mai stato. Eppure qualcosa qui ti riconosce.", "You've never been here. And yet something here knows you."),
  allora = T("Forse è un ricordo di qualcun altro, finito per sbaglio tra i tuoi.", "Maybe it's someone else's memory, slipped in among yours by mistake."),
  altro = { T("Più vai avanti, più la strada del ritorno si confonde.", "The further you go, the more the way back blurs.") },
  macro = { "eco", "nebbia", "respiro" }, musica = {} },

{ id = "qualcuno", strato = 0, x = 1.2, terreno = "pietra", segreto = { da = { "altrove" }, dopo = 60 }, uscite = { su = "soglia", giu = "soglia" },
  nome = T("Qualcuno è venuto", "Someone came"),
  ora = T("Ti eri perso. Poi una luce, dei passi, una mano sulla spalla. Qualcuno è venuto a prenderti.", "You were lost. Then a light, footsteps, a hand on your shoulder. Someone came to fetch you."),
  allora = T("Non serve chiedere aiuto ad alta voce. Basta restare dove si è, e aspettare.", "You don't have to call for help out loud. You just stay where you are, and wait."),
  altro = { T("Si torna a casa insieme.", "You go home together.") },
  macro = { "luce", "calore", "coro" }, macro_def = { 0.7, 0.7, 0.3 },
  musica = { tonica = 50, modo = "ionio", bpm = 54, prog = { 1, 4, 6, 5 }, accordo = "add9", battute = 4, glide = 10, tema = 0.5,
    drone = { amp = 0.36, cut = 1300, shape = 0.2, sub = 0.25, air = 0.3, breath = 0.4 },
    linee = { l("accordo", "strings", 0, 0.22, 0.8, { atk = 3 }), l("melodia", "piano", 1, 0.3, 0.7, { legato = 2.5, bright = 0.35 }),
      l("risposta", "hum", 0, 0.18, 0.4) },
    tex = { wind = 0.05 }, fx = { rev = 0.65, size = 0.9, shimmer = 0.35 } } },
}

-- i luoghi nuovi della v3
for _, p in ipairs(include("lib/luoghi_nuovi")(T, l)) do table.insert(L.lista, p) end
for _, p in ipairs(include("lib/luoghi_nuovi2")(T, l)) do table.insert(L.lista, p) end
for _, p in ipairs(include("lib/luoghi_nuovi3")(T, l)) do table.insert(L.lista, p) end

-------------------------------------------------------------------------------
-- ALTROVE: ogni volta un luogo nuovo, con un nome e una musica nuovi
-------------------------------------------------------------------------------
local A = {
  luoghi = { { "Una serra", "A greenhouse" }, { "Una scala", "A staircase" }, { "Una stanza", "A room" }, { "Un corridoio", "A corridor" },
    { "Una cucina", "A kitchen" }, { "Un giardino", "A garden" }, { "Una soffitta", "An attic" }, { "Un cortile", "A courtyard" },
    { "Una sala d'attesa", "A waiting room" }, { "Un treno fermo", "A stopped train" }, { "Una spiaggia", "A beach" }, { "Una cappella", "A chapel" } },
  con = { { "piena di fotografie senza volti", "full of faceless photographs" }, { "con una sola candela", "with a single candle" },
    { "dove piove dal soffitto", "where it rains from the ceiling" }, { "con gli orologi fermi", "with the clocks stopped" },
    { "dove qualcuno ha appena riso", "where someone has just laughed" }, { "che ricorda il tuo nome", "that remembers your name" },
    { "con una porta in più", "with one door too many" }, { "piena di lettere mai spedite", "full of letters never sent" },
    { "dove è sempre domenica", "where it is always Sunday" }, { "con la radio accesa", "with the radio on" },
    { "che profuma di pane", "that smells of bread" }, { "dove nessuno ti aspetta", "where nobody is waiting for you" } },
  modi = { "dorico", "eolio", "lidio", "frigio", "misolidio", "ionio", "esatonale", "penta_m" },
  strumenti = { "piano", "rhodes", "celesta", "musicbox", "harmonium", "guitar", "bell", "breath" },
  pad = { "strings", "choir", "organ", "bowed" },
  tex = { "wind", "rain", "clock", "drip", "radio", "crick", "stream", "breath", "voices", "hum" },
  macro = { "eco", "nebbia", "respiro", "luce", "fragilita", "ricordo", "distanza", "silenzio" },
}

function L.altrove(p)
  local r = math.random
  local function pk(t) return t[r(#t)] end
  local a, c = pk(A.luoghi), pk(A.con)
  p.nome = T(a[1] .. " " .. c[1], a[2] .. " " .. c[2])
  p.gen = { seed = r(99999), kind = (r() < 0.35) and "fuori" or "stanza" }
  local pool = {}
  for i, m in ipairs(A.macro) do pool[i] = m end
  p.macro = {}
  for i = 1, 3 do p.macro[i] = table.remove(pool, r(#pool)) end
  local tx = {}
  tx[pk(A.tex)] = 0.15 + r() * 0.3
  if r() < 0.5 then tx[pk(A.tex)] = 0.1 + r() * 0.2 end
  p.musica = { tonica = 45 + r(0, 12), modo = pk(A.modi), bpm = 44 + r(0, 36), prog = { 1, pk({ 4, 6, 2, 7 }), pk({ 5, 4, 3 }), 1 },
    accordo = pk({ "add9", "triade", "settima", "sus2", "aperto" }), battute = pk({ 2, 4 }), glide = 10, tema = 0.15,
    drone = { amp = 0.34, cut = 600 + r(0, 800), shape = r() * 0.5, sub = 0.25, air = r() * 0.3, breath = 0.4 },
    linee = { l("melodia", pk(A.strumenti), pk({ 0, 1 }), 0.28, 0.6, { legato = 2.5 }), l("accordo", pk(A.pad), 0, 0.18, 0.6, { atk = 3 }),
      l(pk({ "onde", "scintille", "risposta", "arpeggio" }), pk(A.strumenti), 1, 0.18, 0.5) },
    tex = tx, fx = { rev = 0.6 + r() * 0.3, size = 0.9, shimmer = r() * 0.3, tape = 0.1 + r() * 0.2, echo = r() * 0.3 } }
end

-------------------------------------------------------------------------------
-- la mappa: vicini nello stesso strato, sopra e sotto
-------------------------------------------------------------------------------
L.by_id = {}
for _, p in ipairs(L.lista) do L.by_id[p.id] = p end

local function strato(n)
  local t = {}
  for _, p in ipairs(L.lista) do if p.strato == n and not p.segreto then t[#t + 1] = p end end
  table.sort(t, function(a, b) return a.x < b.x end)
  return t
end

local function nearest(list, x)
  local best, bd = nil, 9
  for _, p in ipairs(list) do
    local d = math.abs(p.x - x)
    if d < bd then best, bd = p, d end
  end
  return best
end

for _, p in ipairs(L.lista) do
  if not p.uscite then
    local u = {}
    local row = strato(p.strato)
    for i, q in ipairs(row) do
      if q == p then
        if row[i - 1] then u.sx = row[i - 1].id end
        if row[i + 1] then u.dx = row[i + 1].id end
      end
    end
    local up, dn = strato(p.strato + 1), strato(p.strato - 1)
    if #up > 0 then u.su = nearest(up, p.x).id end
    if #dn > 0 then u.giu = nearest(dn, p.x).id end
    p.uscite = u
  end
end
for _, p in ipairs(L.lista) do
  if p.segreto then
    for _, da in ipairs(p.segreto.da) do
      local from = L.by_id[da]
      from.nascosti = from.nascosti or {}
      table.insert(from.nascosti, { id = p.id, dopo = p.segreto.dopo })
    end
  end
end

L.DIREZIONI = { "su", "dx", "giu", "sx" }

function L.uscite(p, tempo)
  local t = {}
  for _, d in ipairs(L.DIREZIONI) do
    if p.uscite[d] then t[#t + 1] = { dir = d, id = p.uscite[d] } end
  end
  for _, n in ipairs(p.nascosti or {}) do
    if tempo >= n.dopo then t[#t + 1] = { dir = "segreto", id = n.id } end
  end
  return t
end

function L.conta()
  local n, s = 0, 0
  for _, p in ipairs(L.lista) do if p.segreto then s = s + 1 else n = n + 1 end end
  return n, s
end

return L
