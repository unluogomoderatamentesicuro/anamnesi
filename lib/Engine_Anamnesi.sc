// ANAMNESI
// un luogo moderatamente sicuro
//
// Motore audio.
// IL RESPIRO   un drone a quattro voci che scivola da un accordo all'altro
// IL MONDO     trenta paesaggi sonori, ognuno acceso solo quando serve
// LE VOCI      ventiquattro strumenti che suonano una nota e se ne vanno
// L'ARIA       nastro, eta', polvere, buio, eco, riverbero e scintille
//
// Tutto cio' che resta acceso scorre con Lag: niente stacchi.
// Le texture spente non consumano CPU: il norns respira.

Engine_Anamnesi : CroneEngine {
	var <fxBus, <srcGroup, <texGroup, <drone, <air;
	var <texSyn, texLag = 6, hrate = 1.1, crate = 1;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		var s = context.server;
		var tex;

		fxBus = Bus.audio(s, 2);
		texSyn = IdentityDictionary.new;

		// ------------------------------------------------------------
		// IL RESPIRO
		// ------------------------------------------------------------
		SynthDef(\an_drone, {
			arg out = 0, amp = 0, f1 = 55, f2 = 82.5, f3 = 110, f4 = 165,
			glide = 8, lag = 4, cut = 900, res = 0.2, detune = 0.1, shape = 0.3,
			air = 0.1, sub = 0.4, wob = 0.1, breath = 0.3;
			var fr, a, c, dt, sh, ai, sb, wb, br, rs, lfo, sig, subs, airs, br_env;
			fr = Lag.kr([f1, f2, f3, f4], glide);
			a = Lag.kr(amp, lag); c = Lag.kr(cut, lag); dt = Lag.kr(detune, lag);
			sh = Lag.kr(shape, lag); ai = Lag.kr(air, lag); sb = Lag.kr(sub, lag);
			wb = Lag.kr(wob, lag); br = Lag.kr(breath, lag); rs = Lag.kr(res, lag);
			lfo = LFNoise2.kr(wb.linexp(0, 1, 0.08, 2.5)) * wb * 0.01;
			sig = Mix.fill(4, { |i|
				var f = fr[i] * (1 + lfo);
				var spread = dt * 0.005 * (i + 1);
				var fs = f * [1 - spread, 1 + spread];
				var w = VarSaw.ar(fs, Rand(0, 1), LFNoise2.kr(0.05).range(0.15, 0.85));
				var o = SinOsc.ar(fs, Rand(0, 2pi)) + SinOsc.ar(fs * 2, 0, 0.22);
				var mv = LFNoise2.kr(0.03 + (i * 0.011)).range(0.35, 1);
				XFade2.ar(o, w, sh * 2 - 1) * mv * [1, 0.8, 0.62, 0.48][i]
			});
			br_env = 1 - (br * SinOsc.kr(0.07 + (br * 0.03)).range(0, 0.55));
			sig = sig * br_env;
			sig = MoogFF.ar(sig, (c * LFNoise2.kr(0.04).range(0.8, 1.25)).clip(60, 14000), rs.linlin(0, 1, 0, 3.2));
			subs = SinOsc.ar(fr[0] * 0.5 * [1, 1.002]) * sb * 0.22;
			airs = BPF.ar(PinkNoise.ar(1 ! 2), (c * 3).clip(500, 12000), 0.6)
				* ai * 0.35 * LFNoise2.kr(0.1 ! 2).range(0.3, 1);
			Out.ar(out, LeakDC.ar((sig * 0.32) + subs + airs) * a);
		}).add;

		// ------------------------------------------------------------
		// IL MONDO: ogni paesaggio e' un synth a parte
		// ------------------------------------------------------------
		tex = (
			rain: { (BPF.ar(Dust2.ar([700, 820]), 2600, 1.2) * 0.9)
				+ LPF.ar(PinkNoise.ar(0.22 ! 2), 1700)
				+ (Ringz.ar(Dust.ar([2.5, 3]), [2900, 3600], 0.02) * 0.08) },
			wind: { BPF.ar(PinkNoise.ar(1 ! 2), LFNoise2.kr([0.11, 0.13]).exprange(220, 1300),
				LFNoise2.kr(0.07 ! 2).range(0.25, 0.8)) * LFNoise2.kr(0.17 ! 2).range(0.25, 1.2) * 1.4 },
			sea: {
				var swell = (SinOsc.kr([1/8.7, 1/9.3], [0, 1.4]).range(0, 1) * LFNoise2.kr(0.05 ! 2).range(0.6, 1)).squared;
				LPF.ar(PinkNoise.ar(1 ! 2), swell.linexp(0, 1, 250, 3500)) * ((swell * 0.9) + 0.08) },
			fire: { (HPF.ar(Decay2.ar(Dust.ar([6, 8]), 0.0005, 0.003) * WhiteNoise.ar(1 ! 2), 900) * 0.6)
				+ (LPF.ar(BrownNoise.ar(1 ! 2), 220) * 0.35 * LFNoise2.kr(0.8 ! 2).range(0.5, 1)) },
			crick: { (SinOsc.ar([4300, 4520]) * LFPulse.kr([17, 15.5], 0, 0.45).lag(0.004)
				* LFPulse.kr([0.55, 0.43], [0, 0.4], 0.55).lag(0.03) * 0.05)
				+ (SinOsc.ar([3900, 3700]) * LFPulse.kr([21, 19], 0, 0.4).lag(0.004)
				* LFPulse.kr([0.31, 0.37], [0.2, 0.6], 0.5).lag(0.03) * 0.03) },
			cicada: { BPF.ar(WhiteNoise.ar(1 ! 2), [5200, 5600], 0.15)
				* ((LFPulse.kr([90, 87], 0, 0.5).lag(0.001) * 0.6) + 0.4)
				* LFNoise2.kr(0.2 ! 2).range(0.2, 1) * 0.5 },
			birds: {
				var bt = Dust.kr([0.35, 0.28]);
				var bf = TExpRand.kr(1800, 4200, bt);
				var ch = Decay2.kr(bt + TDelay.kr(bt, 0.12) + TDelay.kr(bt, 0.21), 0.005, 0.09);
				SinOsc.ar(bf * (1 + (ch * LFNoise1.kr(20 ! 2).range(-0.1, 0.25)))) * ch * 0.08 },
			hum: { ((SinOsc.ar(50) * 0.6) + SinOsc.ar(100, 0, 0.3) + LPF.ar(LFSaw.ar(50, 0, 0.12), 900)
				+ (BPF.ar(WhiteNoise.ar, 3000, 0.3) * LFNoise0.kr(8).range(0, 0.04)))
				* LFNoise2.kr(0.3).range(0.7, 1) * 0.22 ! 2 },
			clock: { |hr, cr|
				var tk = Impulse.ar(cr, 0), tc = Impulse.ar(cr, 0.5);
				((Ringz.ar(tk, 2600, 0.03) + (Ringz.ar(tc, 2100, 0.03) * 0.8)) * 0.12) ! 2 },
			heart: { |hr, cr|
				var hb = Impulse.ar(hr);
				(SinOsc.ar(48 * (1 + Decay2.ar(hb, 0.001, 0.05)))
					* (Decay2.ar(hb, 0.004, 0.14) + (Decay2.ar(DelayN.ar(hb, 0.5, 0.28), 0.004, 0.11) * 0.7))) * 0.42 ! 2 },
			drip: {
				var d = Dust.ar([0.45, 0.38]);
				Ringz.ar(d, TExpRand.ar(700, 2400, d) * (1 + (Decay.ar(d, 0.03) * 0.5)), 0.12) * 0.25 },
			voices: {
				var syl = LFNoise1.kr([4.3, 3.7]).max(0) * LFNoise2.kr(0.2 ! 2).range(0, 1).squared;
				LPF.ar(Formant.ar(LFNoise2.kr([1.3, 1.1]).exprange(95, 230),
					LFNoise1.kr([5, 4.4]).exprange(350, 1600),
					LFNoise1.kr(3 ! 2).exprange(200, 900)), 1400) * syl * 0.18 },
			crowd: {
				var v = Mix.fill(3, { |i|
					var syl = LFNoise1.kr(3.5 + i).max(0) * LFNoise2.kr(0.3).range(0.2, 1);
					Pan2.ar(Formant.ar(LFNoise2.kr(1.2).exprange(110, 260), LFNoise1.kr(4).exprange(400, 1900),
						LFNoise1.kr(3).exprange(200, 1000)) * syl, [-0.6, 0.1, 0.7][i])
				});
				var cl = Ringz.ar(Dust.ar([0.6, 0.5]), [3200, 4100], 0.05) * 0.04;
				(LPF.ar(v, 2200) * 0.1) + cl },
			rumble: { LPF.ar(BrownNoise.ar(1 ! 2), 70) * 0.45 },
			crackle: { ((Dust2.ar([9, 11]) * 0.4)
				+ (Decay2.ar(Dust.ar([0.7, 0.9]), 0.001, 0.01) * WhiteNoise.ar(0.8 ! 2))) * 0.5 },
			stream: { (RLPF.ar(Dust2.ar([90, 110]), LFNoise1.kr([9, 7]).exprange(900, 3200), 0.08) * 0.35)
				+ LPF.ar(PinkNoise.ar(0.08 ! 2), 900) },
			bubble: {
				var b = Dust.ar([1.5, 1.2]);
				(Ringz.ar(b, TExpRand.ar(250, 900, b), 0.06) * 0.3) + LPF.ar(BrownNoise.ar(0.1 ! 2), 180) },
			train: {
				var t = Impulse.ar(1.55);
				var k = Decay2.ar(t + DelayN.ar(t, 0.2, 0.13), 0.002, 0.06);
				(BPF.ar(WhiteNoise.ar(1 ! 2), [900, 1100], 0.8) * k * 0.6)
				+ (LPF.ar(BrownNoise.ar(1 ! 2), 140) * 0.35)
				+ (SinOsc.ar([61, 62.3]) * 0.03) },
			city: { (LPF.ar(PinkNoise.ar(1 ! 2), LFNoise2.kr(0.1).range(250, 600)) * LFNoise2.kr(0.13 ! 2).range(0.3, 0.8) * 0.5)
				+ (SinOsc.ar([392, 494]) * Decay2.kr(Dust.kr(0.02), 0.05, 0.6) * 0.03) },
			copier: {
				var scan = LFPulse.kr(0.22, 0, 0.62).lag(0.25);
				var whir = LPF.ar(Mix(Saw.ar([98, 147.3, 196.1])), 700) * 0.05 * scan;
				var swish = BPF.ar(PinkNoise.ar, 3200, 0.5) * Decay2.kr(Impulse.kr(0.22, 0.6), 0.05, 0.35) * 0.4;
				var fan = SinOsc.ar(50, 0, 0.04) + LPF.ar(PinkNoise.ar(0.05), 500);
				(whir + swish + fan) ! 2 },
			leaves: { (HPF.ar(Dust2.ar(LFNoise1.kr(0.3 ! 2).range(40, 420)), 1800) * 0.5)
				+ (BPF.ar(PinkNoise.ar(1 ! 2), 4200, 0.8) * LFNoise2.kr(0.25 ! 2).range(0, 0.25)) },
			frogs: {
				var t = Dust.kr([0.7, 0.55]);
				var e = Decay2.kr(t, 0.02, 0.45) * LFPulse.kr(TRand.kr(14, 24, t), 0, 0.4).lag(0.003);
				RLPF.ar(Pulse.ar(TRand.kr(90, 140, t), 0.3), TRand.kr(450, 800, t), 0.2) * e * 0.12 },
			owl: {
				var t = Dust.kr(0.07);
				var e = Decay2.kr(t, 0.06, 0.4) + Decay2.kr(TDelay.kr(t, 0.6), 0.06, 0.6);
				Pan2.ar(SinOsc.ar(370 * (1 - (Decay.kr(t, 0.8) * 0.06))) * e * 0.1, TRand.kr(-0.8, 0.8, t)) },
			storm: {
				var th = Dust.kr(0.04);
				(LPF.ar(PinkNoise.ar(0.5 ! 2), 2200) + (BPF.ar(Dust2.ar([1600, 1800]), 3000, 1) * 0.7))
				+ (LPF.ar(BrownNoise.ar(1 ! 2), 260) * Decay2.kr(th, 0.4, 5) * 2.2) },
			swallows: {
				var t = Dust.kr(LFNoise1.kr(0.2 ! 2).range(0.3, 7));
				SinOsc.ar(TExpRand.kr(4600, 7800, t) * (1 + (Decay.kr(t, 0.05) * 0.4))) * Decay2.kr(t, 0.002, 0.05) * 0.05 },
			cowbells: {
				var t = Dust.ar([0.25, 0.2]);
				var f = TExpRand.ar(480, 720, t);
				Mix([1, 2.43, 3.91].collect { |r, i| Ringz.ar(t, f * r, [0.8, 0.4, 0.25][i]) * [1, 0.5, 0.3][i] }) * 0.03 },
			typewriter: {
				var burst = LFPulse.kr(0.18, 0, 0.55);
				var t = Dust.ar(burst * 9 + 0.05);
				var bell = Ringz.ar(T2A.ar(Dust.kr(0.03)), 2400, 0.6) * 0.03;
				((Ringz.ar(t, 2300, 0.012) * 0.2) + (HPF.ar(t * WhiteNoise.ar, 2500) * 0.2) + bell) ! 2 },
			breath: {
				var b = SinOsc.kr(0.21).range(0, 1);
				BPF.ar(PinkNoise.ar(1 ! 2), b.linexp(0, 1, 500, 1300), 0.7) * b.squared * 0.35 },
			radio: {
				var note = Select.kr(LFNoise0.kr(0.8).range(0, 6.99), [262, 294, 330, 392, 440, 523, 587]);
				var ghost = (SinOsc.ar(note * [1, 1.5]) * [0.6, 0.3]).sum.tanh * LFNoise2.kr(0.4).range(0.2, 1);
				var stat = BPF.ar(WhiteNoise.ar, 1800, 1.5) * LFNoise2.kr(0.3).range(0.02, 0.12);
				(BPF.ar(ghost * 0.12 + stat, 1100, 1.2) + (Dust2.ar(6) * 0.1)) ! 2 },
			// LA SOFFERENZA: rumori che fanno male, ma senza saturare
			noise: {
				var swell = LFNoise2.kr(0.13 ! 2).range(0.35, 1);
				var band = LFNoise2.kr([0.07, 0.09]).exprange(300, 3800);
				var n = BPF.ar(WhiteNoise.ar(1 ! 2), band, LFNoise2.kr(0.1).range(0.3, 1.2)) * 1.4;
				var grit = (LPF.ar(BrownNoise.ar(1 ! 2), 500) * 0.6 + n).softclip;
				LeakDC.ar(grit * swell * 0.28) },
			tinnitus: {
				var f = [6900, 7020] * LFNoise2.kr(0.05).range(0.98, 1.02);
				(SinOsc.ar(f) * LFNoise2.kr(0.2 ! 2).range(0.3, 1) * 0.018)
				+ (SinOsc.ar([3480, 3510]) * 0.006) },
			static: {
				var bursts = LFNoise0.kr([5, 6.5]).range(0, 1).squared;
				var crack = Dust2.ar([40, 55]) * Decay.kr(Dust.kr([0.7, 0.9]), 1.5);
				(HPF.ar(WhiteNoise.ar(1 ! 2), 1500) * bursts * 0.08) + (crack * 0.35) },
			machine: {
				var t = Dust.kr([0.6, 0.45]);
				var clank = Ringz.ar(T2A.ar(t), TExpRand.kr(180, 900, t) * [1, 1.37], 0.35).sum * 0.06;
				var hum = (Saw.ar([49, 50.2]) * 0.05 + SinOsc.ar([98, 99.5]) * 0.04);
				LPF.ar(hum, 700) + (clank ! 2) + (LPF.ar(BrownNoise.ar(1 ! 2), 120) * 0.25) },
			shriek: {
				var f = LFNoise2.kr(0.3 ! 2).exprange(1200, 2600);
				var fb = SinOsc.ar(f + (SinOsc.ar(f * 0.501) * f * LFNoise2.kr(0.2).range(0.2, 1.4)));
				BPF.ar(fb, f, 0.4) * LFNoise2.kr(0.25 ! 2).range(0, 1).squared * 0.07 },
			arcade: {
				var t = Dust.kr(2.5);
				var b = Pulse.ar(TExpRand.kr(200, 1600, t).round(55), 0.5) * Decay2.kr(t, 0.001, 0.09);
				(LPF.ar(b, 3000) * 0.05 + (SinOsc.ar(60, 0, 0.02))) ! 2 },
		);

		tex.keysValuesDo { |k, f|
			SynthDef(("an_t_" ++ k).asSymbol, {
				arg out = 0, lvl = 0, lag = 6, gate = 1, hrate = 1.1, crate = 1;
				var env = EnvGen.kr(Env.asr(lag, 1, lag, \sin), gate, doneAction: 2);
				var sig = f.value(Lag.kr(hrate, 4), Lag.kr(crate, 2));
				Out.ar(out, sig * Lag.kr(lvl, lag) * env);
			}).add;
		};

		// ------------------------------------------------------------
		// LE VOCI
		// argomenti comuni: freq amp dur pan bright atk det
		// ------------------------------------------------------------

		// pianoforte di feltro, due corde per nota
		SynthDef(\an_piano, {
			arg out = 0, freq = 220, amp = 0.3, dur = 3, pan = 0, bright = 0.5, atk = 0.004, det = 0;
			var env, sig, h;
			env = EnvGen.ar(Env.new([0, 1, 0.5, 0], [atk, dur * 0.25, dur * 0.75], [-2, -3, -5]), doneAction: 2);
			sig = Mix.fill(6, { |k|
				var n = k + 1;
				var f = freq * n * (1 + (n * n * 0.0003));
				var e = EnvGen.ar(Env.perc(0.002, dur * (1.4 / n)));
				(SinOsc.ar(f * (1 + (det * Rand(-0.006, 0.006))), Rand(0, 2pi))
					+ SinOsc.ar(f * 1.0012, Rand(0, 2pi), 0.7)) / (n ** 1.3) * e
			}) * 0.6;
			h = BPF.ar(WhiteNoise.ar, freq * 3, 1) * EnvGen.ar(Env.perc(0.0005, 0.03)) * 0.15;
			// il feltro del martelletto: un tonfo morbido, quasi un respiro del legno
			h = h + (LPF.ar(BrownNoise.ar, 260) * EnvGen.ar(Env.perc(0.001, 0.09)) * 0.35);
			sig = LPF.ar(sig + h, bright.linexp(0, 1, 700, 7000));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.85, pan));
		}).add;

		// pianoforte elettrico
		SynthDef(\an_rhodes, {
			arg out = 0, freq = 220, amp = 0.3, dur = 3, pan = 0, bright = 0.5, atk = 0.003, det = 0;
			var env, ix, mod, sig, tine;
			env = EnvGen.ar(Env.new([0, 1, 0.45, 0], [atk, dur * 0.3, dur * 0.7], [-2, -2, -4]), doneAction: 2);
			ix = EnvGen.ar(Env.perc(0.001, dur * 0.4)) * (0.6 + (bright * 2.2)) + 0.25;
			mod = SinOsc.ar(freq * (1 + (det * 0.002))) * freq * ix;
			sig = SinOsc.ar(freq + mod);
			tine = SinOsc.ar(freq * 14.1) * EnvGen.ar(Env.perc(0.001, 0.06)) * 0.08 * bright;
			sig = (sig + tine) * env * amp * 0.32;
			Out.ar(out, Pan2.ar(sig, pan + SinOsc.kr(4.2, 0, 0.25)));
		}).add;

		// carillon, vetro, campanella
		SynthDef(\an_bell, {
			arg out = 0, freq = 880, amp = 0.2, dur = 4, pan = 0, bright = 0.5, atk = 0.001, det = 0;
			var env, mod, sig;
			env = EnvGen.ar(Env.perc(atk, dur, 1, -5), doneAction: 2);
			mod = SinOsc.ar(freq * 3.502) * freq * bright * 1.6 * EnvGen.ar(Env.perc(0.001, dur * 0.18));
			sig = SinOsc.ar((freq * (1 + (det * 0.01))) + mod)
				+ (SinOsc.ar(freq * 4.07) * 0.12 * EnvGen.ar(Env.perc(0.001, dur * 0.1)));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.38, pan));
		}).add;

		// carillon con la molla
		SynthDef(\an_musicbox, {
			arg out = 0, freq = 880, amp = 0.2, dur = 3, pan = 0, bright = 0.5, atk = 0.001, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.perc(atk, dur, 1, -6), doneAction: 2);
			sig = SinOsc.ar(freq * (1 + (det * 0.006))) + (SinOsc.ar(freq * 3.01) * 0.25 * EnvGen.ar(Env.perc(0.001, dur * 0.2)))
				+ (SinOsc.ar(freq * 5.92) * 0.12 * bright * EnvGen.ar(Env.perc(0.001, dur * 0.08)));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.34, pan));
		}).add;

		// celesta
		SynthDef(\an_celesta, {
			arg out = 0, freq = 880, amp = 0.2, dur = 2.5, pan = 0, bright = 0.5, atk = 0.001, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.perc(atk, dur, 1, -4), doneAction: 2);
			sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 4) * 0.3 * EnvGen.ar(Env.perc(0.001, 0.15)) * (0.4 + bright));
			sig = sig + (BPF.ar(WhiteNoise.ar, freq * 6, 0.5) * EnvGen.ar(Env.perc(0.0005, 0.01)) * 0.2);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.36, pan));
		}).add;

		// corda pizzicata
		SynthDef(\an_pluck, {
			arg out = 0, freq = 220, amp = 0.3, dur = 3, pan = 0, bright = 0.5, atk = 0, det = 0;
			var sig, ex;
			ex = LPF.ar(WhiteNoise.ar, bright.linexp(0, 1, 1200, 9000)) * EnvGen.ar(Env.perc(0.001, 0.01));
			sig = CombL.ar(ex, 0.05, (freq.max(30) * (1 + (det * 0.006))).reciprocal, dur);
			sig = LPF.ar(sig, bright.linexp(0, 1, 900, 6000)) * EnvGen.kr(Env.linen(0, dur, 0.2), doneAction: 2);
			Out.ar(out, Pan2.ar(LeakDC.ar(sig) * amp * 0.75, pan));
		}).add;

		// chitarra: corda con cassa di legno
		SynthDef(\an_guitar, {
			arg out = 0, freq = 220, amp = 0.3, dur = 3, pan = 0, bright = 0.5, atk = 0, det = 0;
			var sig, ex, body;
			ex = LPF.ar(PinkNoise.ar, bright.linexp(0, 1, 900, 5000)) * EnvGen.ar(Env.perc(0.001, 0.015));
			sig = CombL.ar(ex, 0.05, (freq.max(30) * (1 + (det * 0.004))).reciprocal, dur * 1.2);
			body = Mix(BPF.ar(sig, [110, 220, 440], 0.5)) * 0.8;
			sig = LPF.ar(sig + body, bright.linexp(0, 1, 1200, 4500)) * EnvGen.kr(Env.linen(0, dur, 0.3), doneAction: 2);
			Out.ar(out, Pan2.ar(LeakDC.ar(sig) * amp * 0.7, pan));
		}).add;

		// coro: tre gole, vocali che cambiano
		SynthDef(\an_choir, {
			arg out = 0, freq = 220, amp = 0.2, dur = 6, pan = 0, bright = 0.5, atk = 2, det = 0;
			var env, src, vib, vw, f1, f2, sig;
			env = EnvGen.ar(Env.new([0, 1, 1, 0], [atk, dur, atk * 1.6], [2, 0, -3]), doneAction: 2);
			vib = SinOsc.kr(Rand(4.6, 5.6), 0, 0.006) * EnvGen.kr(Env.new([0, 0, 1], [atk * 0.5, atk]));
			src = Mix.fill(3, { |i| Saw.ar(freq * (1 + vib + ([-1, 0, 1][i] * 0.004 * (1 + det)))) });
			vw = Rand(0, 1);
			f1 = vw.linlin(0, 1, 750, 320) * LFNoise2.kr(0.2).range(0.92, 1.08);
			f2 = vw.linlin(0, 1, 1150, 800);
			sig = BPF.ar(src, f1, 0.1) + (BPF.ar(src, f2, 0.08) * 0.6) + (BPF.ar(src, 2500, 0.07) * 0.25 * bright);
			Out.ar(out, Pan2.ar(sig * env * amp * 1.2, pan));
		}).add;

		// una voce sola che canticchia a bocca chiusa
		SynthDef(\an_hum, {
			arg out = 0, freq = 220, amp = 0.2, dur = 3, pan = 0, bright = 0.5, atk = 0.4, det = 0;
			var env, vib, src, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.8, 0], [atk, dur, 0.8], [2, -1, -3]), doneAction: 2);
			vib = SinOsc.kr(5.1, 0, 0.005) * Line.kr(0, 1, atk + 0.5);
			src = Saw.ar(freq * (1 + vib + (det * 0.003)));
			sig = (BPF.ar(src, 280, 0.25) * 1.2) + (BPF.ar(src, 900, 0.15) * 0.25 * (bright + 0.3));
			sig = LPF.ar(sig, 1600);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.9, pan));
		}).add;

		// archi: violoncello, viola, un arco che trema
		SynthDef(\an_bowed, {
			arg out = 0, freq = 110, amp = 0.25, dur = 6, pan = 0, bright = 0.5, atk = 1.2, det = 0;
			var env, vib, sig, body;
			env = EnvGen.ar(Env.new([0, 1, 0.8, 0], [atk, dur, atk * 1.8], [2, -1, -3]), doneAction: 2);
			vib = SinOsc.kr(Rand(4.8, 5.8), 0, 0.005) * Line.kr(0, 1, atk * 1.5);
			sig = Mix(Saw.ar(freq * (1 + vib + (det * 0.004 * [-1, 1])))) * 0.5;
			sig = LPF.ar(sig, bright.linexp(0, 1, 700, 4500));
			body = Mix(BPF.ar(sig, [280, 460, 1100, 2400], 0.3)) * 1.2;
			sig = (sig * 0.4) + body + (BPF.ar(PinkNoise.ar, freq * 4, 0.5) * 0.02);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.65, pan));
		}).add;

		// orchestra d'archi, morbida e larga
		SynthDef(\an_strings, {
			arg out = 0, freq = 220, amp = 0.2, dur = 6, pan = 0, bright = 0.5, atk = 2.5, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.85, 0], [atk, dur, atk * 1.4], [2, -1, -3]), doneAction: 2);
			sig = [
				Mix(Saw.ar(freq * [1, 1.005] * (1 + SinOsc.kr([4.9, 5.3], 0, 0.004)))),
				Mix(Saw.ar(freq * [0.997, 1.003] * (1 + SinOsc.kr([5.1, 4.7], 0, 0.004))))
			] * 0.3;
			sig = LPF.ar(sig, bright.linexp(0, 1, 900, 5000) * EnvGen.kr(Env.new([0.5, 1], [atk])));
			sig = HPF.ar(sig, 120);
			Out.ar(out, Balance2.ar(sig[0], sig[1], pan) * env * amp * 0.7);
		}).add;

		// armonium a pedale, nella chiesa piccola
		SynthDef(\an_harmonium, {
			arg out = 0, freq = 220, amp = 0.2, dur = 3, pan = 0, bright = 0.5, atk = 0.15, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.9, 0], [atk, dur, 0.5], [1, 0, -3]), doneAction: 2);
			sig = Mix(Pulse.ar(freq * [1, 1.004, 2.003], [0.3, 0.32, 0.4], [1, 0.7, 0.3]));
			sig = LPF.ar(sig, bright.linexp(0, 1, 700, 2600)) * (1 + SinOsc.kr(5.5, 0, 0.06));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.22, pan));
		}).add;

		// organo di chiesa
		SynthDef(\an_organ, {
			arg out = 0, freq = 220, amp = 0.2, dur = 4, pan = 0, bright = 0.5, atk = 0.08, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 1, 0], [atk, dur, 0.6], [1, 0, -2]), doneAction: 2);
			sig = Mix([0.5, 1, 2, 3, 4, 8].collect { |r, i|
				SinOsc.ar(freq * r * (1 + (i * 0.0007)), 0, [0.25, 1, 0.6, 0.25, 0.3 * bright, 0.12 * bright][i]) });
			Out.ar(out, Pan2.ar(sig * env * amp * 0.12, pan));
		}).add;

		// fisarmonica della festa
		SynthDef(\an_accordion, {
			arg out = 0, freq = 220, amp = 0.2, dur = 2, pan = 0, bright = 0.5, atk = 0.05, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.85, 0], [atk, dur, 0.25], [1, -1, -3]), doneAction: 2);
			sig = Mix(Pulse.ar(freq * [1, 1.009, 0.5], [0.35, 0.4, 0.45], [1, 0.8, 0.4]));
			sig = BPF.ar(sig, bright.linexp(0, 1, 900, 2200), 1.6) * (1 + SinOsc.kr(6.2, 0, 0.12));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.55, pan));
		}).add;

		// soffio: flauto, ocarina, fischio nel vento
		SynthDef(\an_breath, {
			arg out = 0, freq = 660, amp = 0.2, dur = 2, pan = 0, bright = 0.5, atk = 0.15, det = 0;
			var env, vib, sig, noise;
			env = EnvGen.ar(Env.new([0, 1, 0.75, 0], [atk, dur * 0.6, (dur * 0.4) + 0.3], [1, -1, -3]), doneAction: 2);
			vib = SinOsc.kr(5.2, 0, 0.007) * Line.kr(0, 1, 0.6);
			sig = SinOsc.ar(freq * (1 + vib + (det * 0.003))) + SinOsc.ar(freq * 2 * (1 + vib), 0, 0.12 * bright);
			noise = BPF.ar(PinkNoise.ar, freq * 1.5, 0.4) * 0.18 * (bright + 0.3);
			Out.ar(out, Pan2.ar((sig + noise) * env * amp * 0.45, pan));
		}).add;

		// la sala giochi: onda quadra a otto bit
		SynthDef(\an_arcade, {
			arg out = 0, freq = 440, amp = 0.2, dur = 0.5, pan = 0, bright = 0.5, atk = 0.002, det = 0;
			var env, vib, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.6, 0], [atk, dur * 0.3, dur * 0.7], [0, -2, -3]), doneAction: 2);
			vib = SinOsc.kr(6, 0, 0.006) * Line.kr(0, 1, 0.3);
			sig = Pulse.ar(freq * (1 + vib), 0.5) + (Pulse.ar(freq * 0.5, 0.25) * 0.3);
			sig = LPF.ar(sig, bright.linexp(0, 1, 1200, 5000));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.32, pan));
		}).add;

		// una canzone dentro una radio vecchia
		SynthDef(\an_radio, {
			arg out = 0, freq = 440, amp = 0.2, dur = 2, pan = 0, bright = 0.5, atk = 0.02, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.7, 0], [atk, dur * 0.4, dur * 0.6], [1, -2, -3]), doneAction: 2);
			sig = (Saw.ar(freq) * 0.4) + SinOsc.ar(freq * 2, 0, 0.3);
			sig = BPF.ar(sig, 1100, 1.3) * LFNoise2.kr(3).range(0.6, 1);
			sig = (sig * 2).tanh * 0.5 + (BPF.ar(WhiteNoise.ar, 2000, 1) * 0.02);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.4, pan));
		}).add;

		// coppa tibetana
		SynthDef(\an_coppa, {
			arg out = 0, freq = 220, amp = 0.2, dur = 12, pan = 0, bright = 0.5, atk = 0.01, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.perc(atk, dur, 1, -3), doneAction: 2);
			sig = (SinOsc.ar(freq * [1, 1.0035]) * 0.5)
				+ (SinOsc.ar(freq * 2.71 * [1, 1.002]) * 0.25 * bright)
				+ (SinOsc.ar(freq * 5.15) * 0.08 * bright * EnvGen.ar(Env.perc(0.01, dur * 0.3)));
			Out.ar(out, Balance2.ar(sig[0], sig[1], pan) * env * amp * 0.3);
		}).add;

		// campana di chiesa
		SynthDef(\an_campana, {
			arg out = 0, freq = 220, amp = 0.3, dur = 8, pan = 0, bright = 0.5, atk = 0, det = 0;
			var ex, sig;
			ex = Impulse.ar(0) + (Decay2.ar(Impulse.ar(0), 0.001, 0.02) * PinkNoise.ar * 0.5);
			sig = Klank.ar(`[
				[0.5, 1, 1.19, 1.56, 2, 2.51, 2.66, 3.01, 4.1],
				[0.6, 1, 0.5, 0.4, 0.45, 0.25, 0.2, 0.18, 0.1],
				[1, 0.8, 0.5, 0.45, 0.4, 0.3, 0.25, 0.2, 0.12]
			], ex, freq, 0, dur);
			sig = LPF.ar(sig, bright.linexp(0, 1, 1500, 9000)) * EnvGen.kr(Env.linen(0, dur, 0.1), doneAction: 2);
			Out.ar(out, Pan2.ar(sig * amp * 0.1, pan));
		}).add;

		// nevrosi: schegge digitali
		SynthDef(\an_glitch, {
			arg out = 0, freq = 440, amp = 0.2, dur = 0.2, pan = 0, bright = 0.5, atk = 0, det = 0;
			var env, sig, sr;
			env = EnvGen.ar(Env.perc(0.001, dur, 1, -2), doneAction: 2);
			sr = LFNoise0.kr(30).exprange(800, 12000);
			sig = Latch.ar(SinOsc.ar(freq * LFNoise0.kr(25).exprange(0.5, 2)) + (PinkNoise.ar * bright * 0.6), Impulse.ar(sr));
			sig = sig * LFPulse.kr(LFNoise0.kr(6).exprange(8, 40), 0, 0.5);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.25, pan));
		}).add;

		// FM a due operatori: campane di vetro, metalli lontani
		SynthDef(\an_fm, {
			arg out = 0, freq = 440, amp = 0.2, dur = 3, pan = 0, bright = 0.5, atk = 0.005, det = 0;
			var env, ix, mod, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.3, 0], [atk, dur * 0.3, dur * 0.7], [-2, -3, -4]), doneAction: 2);
			ix = EnvGen.ar(Env.perc(0.002, dur * 0.6)) * (1 + (bright * 5));
			mod = SinOsc.ar(freq * 3.501 * (1 + (det * 0.003))) * freq * ix;
			sig = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 0.5) * 0.25);
			Out.ar(out, Pan2.ar(LPF.ar(sig, 9000) * env * amp * 0.35, pan));
		}).add;

		// nuvola di grani: una nota che si sbriciola in polvere luminosa
		SynthDef(\an_grain, {
			arg out = 0, freq = 440, amp = 0.2, dur = 4, pan = 0, bright = 0.5, atk = 0.5, det = 0;
			var env, trig, sig;
			env = EnvGen.ar(Env.new([0, 1, 0], [atk, dur], [2, -3]), doneAction: 2);
			trig = Dust.kr(18 + (bright * 30));
			sig = GrainSin.ar(2, trig, TRand.kr(0.04, 0.16, trig), freq * TChoose.kr(trig, [1, 1, 2, 0.5, 1.5]) * (1 + TRand.kr(-0.004, 0.004, trig)),
				TRand.kr(-0.8, 0.8, trig) + pan);
			Out.ar(out, sig * env * amp * 0.3);
		}).add;

		// metallo graffiato: un arco su una lamiera, la cosa che stride
		SynthDef(\an_scrape, {
			arg out = 0, freq = 220, amp = 0.2, dur = 3, pan = 0, bright = 0.5, atk = 0.3, det = 0;
			var env, exc, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.7, 0], [atk, dur * 0.5, dur * 0.5], [1, 0, -3]), doneAction: 2);
			exc = BPF.ar(PinkNoise.ar, freq * 4, 0.5) * LFNoise1.kr(18).range(0.2, 1);
			sig = DynKlank.ar(`[[1, 2.31, 3.89, 5.17, 6.72] * freq, [1, 0.6, 0.45, 0.3, 0.2], [0.6, 0.5, 0.4, 0.3, 0.2]], exc);
			sig = (sig * (2 + (bright * 3))).tanh * 0.5;
			Out.ar(out, Pan2.ar(LeakDC.ar(sig) * env * amp * 0.3, pan));
		}).add;

		// pad di seghe stonate, come un vecchio sintetizzatore polifonico
		SynthDef(\an_saw, {
			arg out = 0, freq = 220, amp = 0.2, dur = 4, pan = 0, bright = 0.5, atk = 1, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.8, 0], [atk, dur, atk * 1.5], [1, 0, -2]), doneAction: 2);
			sig = Mix(Saw.ar(freq * [1, 1.004 + (det * 0.003), 0.996, 0.5005])) * 0.25;
			sig = RLPF.ar(sig, (freq * (2 + (bright * 6))).clip(80, 9000) * LFNoise2.kr(0.3).range(0.8, 1.2), 0.5);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.5, pan + (SinOsc.kr(0.13) * 0.2)));
		}).add;

		// grappolo dissonante: sette note strette che battono tra loro
		SynthDef(\an_cluster, {
			arg out = 0, freq = 220, amp = 0.2, dur = 4, pan = 0, bright = 0.5, atk = 0.8, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.9, 0], [atk, dur, 2], [2, 0, -3]), doneAction: 2);
			sig = Mix(SinOsc.ar(freq * [1, 1.059, 1.122, 0.944, 1.189, 0.891, 2.12], 0, [1, 0.8, 0.6, 0.6, 0.4, 0.4, 0.2]));
			sig = sig + (LPF.ar(Saw.ar(freq * [0.5, 0.53]).sum, freq * 2) * 0.3 * bright);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.12, pan));
		}).add;

		// sussurro
		SynthDef(\an_whisper, {
			arg out = 0, freq = 400, amp = 0.2, dur = 1.5, pan = 0, bright = 0.5, atk = 0.1, det = 0;
			var env, syl, sig;
			env = EnvGen.ar(Env.new([0, 1, 1, 0], [atk, dur, 0.3]), doneAction: 2);
			syl = LFNoise1.kr(Rand(5, 9)).max(0).sqrt;
			sig = (BPF.ar(WhiteNoise.ar, LFNoise1.kr(6).exprange(freq, freq * 4), 0.12) * 2)
				+ (BPF.ar(WhiteNoise.ar, LFNoise1.kr(4).exprange(1800, 4200), 0.2) * 0.5 * bright);
			Out.ar(out, Pan2.ar(sig * syl * env * amp * 0.5, pan));
		}).add;

		// nastro al contrario: un suono che arriva invece di andarsene
		SynthDef(\an_swell, {
			arg out = 0, freq = 220, amp = 0.2, dur = 4, pan = 0, bright = 0.5, atk = 0, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0], [dur, 0.08], [5, -4]), doneAction: 2);
			sig = Mix.fill(4, { |k| SinOsc.ar(freq * (k + 1) * (1 + (det * Rand(-0.004, 0.004))), 0, 1 / ((k + 1) ** 1.6)) });
			sig = LPF.ar(sig + VarSaw.ar(freq, 0, 0.3, 0.15 * bright), bright.linexp(0, 1, 800, 5000));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.35, pan));
		}).add;

		// basso profondo
		SynthDef(\an_sub, {
			arg out = 0, freq = 55, amp = 0.3, dur = 4, pan = 0, bright = 0.5, atk = 0.3, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.new([0, 1, 0.7, 0], [atk, dur * 0.4, dur * 0.6], [1, -1, -3]), doneAction: 2);
			sig = SinOsc.ar(freq) + (LPF.ar(LFTri.ar(freq * 2), 300) * 0.2 * bright);
			Out.ar(out, (sig * env * amp * 0.45) ! 2);
		}).add;

		// passi (freq = peso, bright = terreno, dur = trascinamento)
		SynthDef(\an_step, {
			arg out = 0, freq = 1, amp = 0.2, dur = 0.15, pan = 0, bright = 0.5, atk = 0, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.perc(0.002, dur, 1, -6), doneAction: 2);
			sig = (LPF.ar(WhiteNoise.ar, bright.linexp(0, 1, 250, 6000)) * 0.6)
				+ (SinOsc.ar(70 * freq) * EnvGen.ar(Env.perc(0.001, 0.05)) * 0.5)
				+ (Dust2.ar(600 * bright) * 0.3);
			Out.ar(out, Pan2.ar(sig * env * amp * 0.6, pan));
		}).add;

		// goccia
		SynthDef(\an_drop, {
			arg out = 0, freq = 1200, amp = 0.2, dur = 0.3, pan = 0, bright = 0.5, atk = 0, det = 0;
			var env, sig;
			env = EnvGen.ar(Env.perc(0.001, dur), doneAction: 2);
			sig = SinOsc.ar(freq * EnvGen.ar(Env.new([0.7, 1.3], [dur * 0.5], \exp)));
			Out.ar(out, Pan2.ar(sig * env * amp * 0.25, pan));
		}).add;

		// ------------------------------------------------------------
		// L'ARIA
		// ------------------------------------------------------------
		SynthDef(\an_air, {
			arg in = 0, out = 0, amp = 0.8, lag = 3, rev = 0.5, size = 0.85, damp = 0.4,
			shimmer = 0.2, tape = 0.1, age = 0.1, crush = 0, hiss = 0.02, dark = 0, speed = 1,
			echo = 0, etime = 0.45, efb = 3;
			var sig, rv, sz, dp, sh, tp, ag, cr, hs, dk, ec, et, ef, wow, srate, bits, crushed;
			var fb, shim, v, verb, bad, ech;
			sig = In.ar(in, 2);
			// se qualcosa si rompe (un numero impossibile) l'aria resta pulita
			bad = CheckBadValues.ar(sig[0] + sig[1], 0, 0);
			sig = [Select.ar(bad > 0, [sig[0], DC.ar(0)]), Select.ar(bad > 0, [sig[1], DC.ar(0)])];

			rv = Lag.kr(rev, lag); sz = Lag.kr(size, lag); dp = Lag.kr(damp, lag);
			sh = Lag.kr(shimmer, lag); tp = Lag.kr(tape, lag); ag = Lag.kr(age, lag);
			cr = Lag.kr(crush, lag); hs = Lag.kr(hiss, lag); dk = Lag.kr(dark, lag);
			ec = Lag.kr(echo, lag); et = Lag.kr(etime, 4); ef = Lag.kr(efb, lag);

			// nastro che si stira
			wow = (SinOsc.kr(0.33 * speed, [0, 0.5]) * 0.0035) + (LFNoise2.kr(5.5 ! 2) * 0.0007) + (LFNoise2.kr(0.2 ! 2) * 0.002);
			sig = DelayC.ar(sig, 0.05, 0.012 + (wow * tp));

			// eta': la carta ingiallisce
			sig = LPF.ar(sig, ag.linexp(0, 1, 19000, 2400));
			sig = HPF.ar(sig, ag.linexp(0, 1, 20, 160));
			sig = (sig * (1 + (ag * 1.5))).tanh / (1 + (ag * 0.5));

			// frantumi
			srate = cr.linexp(0, 1, 30000, 1800);
			bits = cr.linlin(0, 1, 16, 4);
			crushed = (Latch.ar(sig, Impulse.ar(srate)) * (2 ** bits)).round(1) / (2 ** bits);
			sig = XFade2.ar(sig, crushed, ((cr * 4) - 1).clip(-1, 1));

			// buio
			sig = LPF.ar(sig, dk.linexp(0, 1, 20000, 380));

			// eco a nastro, che si allontana
			ech = CombC.ar(LPF.ar(sig, 3500), 1.6, [et, et * 1.5].clip(0.05, 1.55), ef) * ec * 0.6;
			sig = sig + ech;

			// un coro lieve tra i due canali: il suono ti gira intorno
			sig = sig + (DelayC.ar([sig[1], sig[0]], 0.03, LFNoise2.kr([0.21, 0.27]).range(0.007, 0.019)) * 0.26);

			// spazio, e luce che sale
			fb = LocalIn.ar(2);
			shim = PitchShift.ar(fb, 0.2, 2, 0.004, 0.03) * sh * 0.5;
			v = sig + shim;
			v = AllpassN.ar(v, 0.05, [0.0123, 0.0147], 0.6);
			v = AllpassN.ar(v, 0.05, [0.0211, 0.0187], 0.8);
			v = AllpassN.ar(v, 0.05, [0.0293, 0.0331], 1.0);
			verb = FreeVerb2.ar(v[0], v[1], 1, sz, dp);
			verb = verb + (CombL.ar(verb, 1.6, [1.21, 1.47] * LFNoise2.kr(0.05 ! 2).range(0.98, 1.02),
				sz.linexp(0, 1, 1, 10)) * 0.16 * sz);
			// il ritorno non puo' mai crescere senza fine
			LocalOut.ar(Limiter.ar(LPF.ar(verb, 6000), 0.5, 0.02));
			sig = (sig * (1 - (rv * 0.55))) + (verb * rv * 1.3);

			sig = sig + (HPF.ar(PinkNoise.ar(1 ! 2), 3000) * hs * 0.04);
			sig = LeakDC.ar(sig);
			sig = Limiter.ar(sig * Lag.kr(amp, 1) * 1.7, 0.95, 0.01);
			Out.ar(out, sig);
		}).add;

		s.sync;

		srcGroup = Group.head(context.xg);
		texGroup = Group.after(srcGroup);
		drone = Synth.head(srcGroup, \an_drone, [\out, fxBus]);
		air = Synth.tail(context.xg, \an_air, [\in, fxBus, \out, context.out_b]);

		this.addCommand(\drone, "sf", { arg msg; drone.set(msg[1].asSymbol, msg[2]); });
		this.addCommand(\fx, "sf", { arg msg; air.set(msg[1].asSymbol, msg[2]); });

		this.addCommand(\tex, "sf", { arg msg;
			var k = msg[1].asSymbol, v = msg[2], syn;
			case
			{ k == \lag } { texLag = v.max(0.05) }
			{ k == \hrate } { hrate = v; texSyn[\heart] !? { |x| x.set(\hrate, v) } }
			{ k == \crate } { crate = v; texSyn[\clock] !? { |x| x.set(\crate, v) } }
			{ true } {
				syn = texSyn[k];
				if (v > 0.003) {
					if (syn.isNil) {
						texSyn[k] = Synth.head(texGroup, ("an_t_" ++ k).asSymbol,
							[\out, fxBus, \lvl, v, \lag, texLag, \hrate, hrate, \crate, crate]);
					} {
						syn.set(\lvl, v, \lag, texLag);
					};
				} {
					if (syn.notNil) { syn.set(\gate, 0); texSyn[k] = nil };
				};
			};
		});

		this.addCommand(\note, "sfffffff", { arg msg;
			Synth.head(srcGroup, ("an_" ++ msg[1].asString).asSymbol, [
				\out, fxBus, \freq, msg[2], \amp, msg[3], \dur, msg[4],
				\pan, msg[5], \bright, msg[6], \atk, msg[7], \det, msg[8]
			]);
		});
	}

	free {
		texSyn.do { |x| x.free };
		drone.free; air.free; srcGroup.free; texGroup.free; fxBus.free;
	}
}
