(
// Kick drums and snare are inspired by:
// https://www.youtube.com/watch?v=xYc7_PbbtuE&list=WL&index=59&t=2s

// Synthetic kick drum.
SynthDef(\kick_synth, {
    arg out=0, att=0.001, rel=0.8, curve=(-8), amp=0.5, pan=0,
    bpfreq=10120, bprq=0.5;

    // Base frequency with a slight downhill (XLine) - to make kick sounding less "tonal".
    var sndfreq = 55 * (1 + (4 * Env.perc(0, 0.13, curve: curve).ar)) * XLine.ar(1, 0.5, 1);
    var snd = SinOsc.ar(sndfreq);

    // Add a second sine wave with a fast chirp.
    snd = snd + (SinOsc.ar(XLine.ar(4000, 50, 0.01)) * Env.perc(0.0001, 0.01).ar * -5.dbamp);

    // Add some filtered (deterministic!) noise.
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpfreq, bprq) * Env.perc(0.001, 0.03).ar * -8.dbamp);

    // Glue it all together by a light distortion.
    snd = snd * (1 + (2 * Env.perc(0.001, 2.2).ar));
    snd = (snd * 0.dbamp).tanh;

    // Sculpt by percussion env.
    snd = snd * Env.perc(att, rel, curve: curve).ar(Done.freeSelf);
    snd = snd * amp;
    snd = Pan2.ar(snd, pan);
    Out.ar(out, snd);
}).add;


// "Acoutsic" kick drum
SynthDef(\kick_acoustic, {
    arg out=0, att=0.001, rel=1.3, curve=(-6), amp=0.56, pan=0,
    bpfreq1=7120, bprq1=0.5, bpfreq2=3120, bprq2=0.3;

    var snd, sndfreq;

    // For acoustic effect layering many sine waves with different frequencies...
    sndfreq = 60 * (1 + (8 * Env.perc(0, 0.06, curve: -4).ar)) * XLine.ar(1, 0.9, 1);
    sndfreq = sndfreq * [1, 1.3, 2.4, 2.6, 2.8, 3.3, 3.4];
    snd = SinOsc.ar(sndfreq);

    // ...as well as amplitudes, attacks and release times.
    snd = snd * [0, -10, -5, -19, -15, -20, -15].dbamp;
    snd = snd * Env.perc(
        attackTime: [0.01, 0.01, 0.015, 0.01, 0.03, 0.01, 0.02] * 0.5,
        releaseTime:[1,    0.3,  0.1,   0.03, 0.05, 0.03, 0.06] * 3
    ).ar;

    // Mix it together.
    snd = snd.sum;

    // Add some filtered noise.
    snd = snd + (BPF.ar(WhiteNoise.ar, bpfreq1, bprq1) * Env.perc(0.001, 0.01).ar * -8.dbamp);
    snd = snd + (BPF.ar(WhiteNoise.ar, bpfreq2, bprq2) * Env.perc(0.001, 0.08).ar * -8.dbamp);

    // Glue it all together by a light distortion.
    snd = (snd * 4.dbamp).tanh;

    // Smooth it out by a little reverb.
    snd = snd + (GVerb.ar(snd, 6, 1) * -30.dbamp);

    // Sculpt by percussion env.
    snd = snd * Env.perc(att, rel, curve: curve).ar(Done.freeSelf);
    snd = snd * amp;
    snd = Pan2.ar(snd, pan);
    Out.ar(out, snd);
}).add;

SynthDef(\snare, {
    arg out=0, att=0.001, rel=0.6, curve=(-4), amp=0.56, pan=0,
    bpfreq1=2120, bprq1=0.3, bpfreq2=4120, bprq2=0.6;

    var snd, sndfreq;
    sndfreq = 200 * (1 + (2 * Env.perc(0.001, 0.03).ar)) * [1, 2.3, 3.5, 5.8];
    snd = SinOsc.ar(sndfreq);
    snd = snd * Env.perc(0, [2, 0.4, 0.2, 0.1]).ar;
    snd = snd * [0, -20, -12, -24].dbamp;
    snd = snd.sum;

    // Give it some punch (add click).
    snd = snd + (SinOsc.ar(XLine.ar(3000, 100, 0.03)) * Env.perc(0.01, 0.03).ar);

    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpfreq1, bprq1) * Env.perc(0.05, 0.1).ar * -3.dbamp);

    // Second layer of noise to make it less dull.
    snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), bpfreq2, bprq2) * Env.perc(0.003, 0.15).ar * -8.dbamp);

    // Parallel distortion which has the benefit of filtering:
    // distortion adds sum/diff tones that multiplies the number of partials
    // in clanky snares. Additionally if the original partials have different
    // decay times, the sum/diff tones will also have different decay times,
    // which leads to timbral variation, and therefore more realistic (less
    // synthetic) output.
    snd = snd + ((snd * 13.dbamp).tanh * -10.dbamp);

    // Add PitchShift for a real clanky snare.
    snd = snd + LPF.ar(PitchShift.ar(snd, 0.005, 1.8) * -4.dbamp, 3000);

    snd = snd * Env.perc(att, rel, curve: curve).ar;

    // Distortion can sound a little warmer if you cut the highs, then distort,
    // them bring them back on.
    // WARNING: always put distortion after the Env!
    snd = BHiShelf.ar((LPF.ar(snd, 8000) * 2.dbamp).tanh, 8000, 10);

    // Add some reverb and the second env so it can ring out.
    // Important: GVerb is mono-to-stereo, avoiding Pan2!
    snd = snd + (GVerb.ar(snd, 16, 2) * -30.dbamp);
    snd = snd * Env.perc(0.001, 1, curve: curve).ar(Done.freeSelf);

    snd = snd * amp;

    Out.ar(out, snd);
}).add;

SynthDef(\hihat, {
    arg out=0, amp=0.5, att=0.01, rel=0.2, ffreq=6000, pan=0;
    var env = EnvGen.kr(Env.perc(att, rel, amp), doneAction: Done.freeSelf);
    var signal = HPF.ar(
        LPF.ar(WhiteNoise.ar, freq: ffreq),
        Rand(1000, 8000)
    );
    signal = signal * env;
    Out.ar(out, Pan2.ar(signal, pan));
}).add;


SynthDef(\tom, {
	arg out=0, amp=1, att=0.05, rel=0.7, ffreq=1500, pan=0;

	var freq = #[ 147.5224, 229, 310.3903, 392.7002, 473.7456 ];
	var mul = [0.05, 0.65, 0.1, 0.04, 0.01];
	var decay = #[0.5, 0.1];
	var gen = Mix.ar([
		LPF.ar(Pulse.ar(freq, 0.5, mul)),
		AllpassN.ar(
			BPF.ar(HPF.ar(WhiteNoise.ar(0.35), 500), ffreq), 0.05, [0.05.rand, 0.05.rand], 4
    )]);
	var env = Env.perc(att, rel, amp, curve: -4.0).kr(doneAction: Done.freeSelf);
    var signal = gen * env;

    Out.ar(out, Pan2.ar(signal, pan))
}).add;
)

(
var introN = 10;
var outroN = 24;
var fullN = 4; // full cycles of main line + syncope
var baseQuant = 16;
var stretch = 25/128 * baseQuant;
var freq = 2;
var measure = 1/baseQuant ! 10 * freq;
// intro (hat only) =
//       into bars -1 (off-beat)
//       times measure
//       times time scale 2 for all except hi-hat)
var introDelay = (introN-1) * measure.sum * 2;
// Tom is specific - it appears only ater the first break.
var introTom = introN + (fullN * 4 + 3) * measure.sum * 2;
var makePattern = { arg inst, amp, seq;
    Pbind(
        \instrument, inst,
        \amp, Pseq(amp, inf),
        \dur, Pseq(seq, inf),
        \stretch, stretch,
    )
};
var beats = baseQuant.reciprocal ! 30;
var patt = Pdef(
    \rhythm,
    Ptpar([
        // HI-HAT
        0.0, Pbind(
            \instrument, \hihat,
            \dur, Pseq(measure, inf),
            \amp, Pwhite(0.5, 1, 2278),
            \rel, Pwrand([0.02, 0.1, 0.5], [0.7, 0.15, 0.15], inf),
            \pan, Pgauss(0, 0.7, inf),
        ),

        // KICK
        introDelay, Pbind(
            \instrument, \kick_acoustic,
            \dur, Pseq(measure, inf) * 2,
            \amp, Pseq([
                // // intro silent (hat only)
                // Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], introN-1),
                Pseq([
                    // off-beat
                    Pseq([0, 0, 0, 0.2, 0.8, 1, 0, 1, 0, 0], 1),
                    Pseq([
                        // fig 1 - main line
                        Pseq([Pwrand([0, 1], [0.2, 0.8], 1), 0, 1, 0, 0, 0, 1, 1, 0, 0], 3),
                        Pxrand([
                            // fig 2 - syncope 1
                            Pseq([0, 0, 1, 0, 0, 1, 1, 1, 0, 0], 1),
                            // fig 3 - syncope 2
                            Pseq([0, 1, 0, 0, 1, 0, 0, 1, 0, 0], 1),
                            // fig 4 - syncope 3
                            Pseq([0, 1, 0, 0, 1, 1, 0, 0, 1, 1], 1),
                        ], 1),
                    ], 4),
                    // intermission
                    Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 3),
                ], fullN),
                // outro silent (hat only)
                Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], outroN),
                // outro hit
                Pseq([0, 0, 0, 0, 1, 1, 0, 1, 1, 1], 1)
            ], 1)
        ),

        // SNARE
        introDelay, Pbind(
            \instrument, \snare,
            \dur, Pseq(measure, inf) * 2,
            \amp, Pseq([
                Pseq([
                    // off-beat
                    Pseq([0, 0, 0, 0, 0, 0, 1, 0, 1, 0.8], 1),
                    Pseq([
                        // fig 1 - main line
                        Pseq([0, 0, 0, 1, 0, 0, 0, 0, 1, 0], 3),
                        Pxrand([
                            // fig 2 - syncope 1
                            Pseq([1, 1, 0, 0, 0, 1, 0, 0, 1, Prand([0, 1], 1)], 1),
                            // fig 3 - syncope 2
                            Pseq([1, 0, 0, 1, 0, 0, 1, 0, 1, Prand([0, 1], 1)], 1),
                            // fig 4 - syncope 3
                            Pseq([0, 0, 1, 0, 0, 0, 1, 0, 1, 1], 1),
                        ], 1),
                    ], 4),
                    // intermission
                    Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 3),
                ], fullN),
                // outro silent (hat only)
                Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], outroN),
                // outro hit
                Pseq([0, 0, 0, 0, 0, 1, 0, 1, 1, 0], 1)
            ], 1)
        ),

        // TOM
        introTom, Pbind(
            \instrument, \tom,
            \dur, Pseq(measure, inf) * 2,
            \amp, Pseq([
                // // intro silent (hat only)
                // Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], introN + (fullN*4 + 3)),
                Pseq([
                    // off-beat (tom is silent)
                    Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 1),
                    Pseq([
                        // fig 1 - main line
                        Pseq([0, 0, 0, 0, 0, 1, Pwrand([1, 0], [0.7, 0.3], 1), 0, 0, 1], 3),
                        Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 1),
                    ], 4),
                    // intermission
                    Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 3),
                ], fullN-1),
                // outro silent (hat only)
                Pseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], outroN),
                // outro hit
                Pseq([0, 0, 0, 0, 0, 0, 0, 1, 1, 0], 1)
            ])
        )
    ])
);
// var patt = Pdef(
//     \rhythm,
//     Ptpar([
//         // 5-4-3-2-1 pattern of Tomek Chołoniewski
//         // 0.0, Pbind(
//         // 	\instrument, \hihat,
//         // 	\amp, Pseq([1, \, \, \, \, \, \, \, \, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \, 1, \, \, \, 1, \], inf),
//         // 	\stretch, stretch,
//         // ),
//         0.0, makePattern.(\kick,  [1, \, \, \, \, \, \, \, \, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \, 1, \, \, \, 1, \], beats),
//         0.0, makePattern.(\hihat, [1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \], beats),
//         0.0, makePattern.(\snare, [\, \, 1, 1, 1, 1, 1, 1, 1, \, \, \, 1, 1, 1, 1, 1, \, \, \, 1, 1, 1, \, \, \, 1, \, \, \], beats),
//     ], inf)
// );
patt.play;

CmdPeriod.doOnce({
    "-> Caught signal: <shut down>".postln;
    patt.stop;
    postf("OK\n\n");
});
)