(
SynthDef(\kick, {
    arg out=0, amp=0.5, att=0.01, rel=1.0, ffreq=1900, pan=0;

    var freq = #[58.0936, 47.3074, 10.2712, 57.8168, 75.0203];
    var gen = Mix.ar(
		BPeakEQ.ar(
			SinOsc.ar(freq), ffreq, 1, 12.0
	));
	var env = Env.perc(att, rel, amp*0.5, curve: -4.0).kr(doneAction: Done.freeSelf);
    var signal = gen * env;

    Out.ar(out, Pan2.ar(signal, pan))
}).add;

SynthDef(\snare, {
    arg out=0, amp=1, att=0.01, rel=1.0, ffreq=3000, pan=0;

	var freq = #[81.5224, 163, 244.3903, 326.7002, 407.7456 ];
	var mul = [0.05, 0.65, 0.1, 0.04, 0.01];
	var decay = #[0.5, 0.1];
	var gen = Mix.ar(
		LPF.ar(Pulse.ar(freq, 0.5, mul))
		+
		AllpassN.ar(
			BPF.ar(HPF.ar(WhiteNoise.ar(1), 500), ffreq), 0.05, [0.05.rand, 0.05.rand], 4
	));
	var env = Env.perc(att, rel, amp, curve: -4.0).kr(doneAction: Done.freeSelf);
    var signal = gen * env;

    Out.ar(out, Pan2.ar(signal, pan))
}).add;

SynthDef("hihat", {
	arg out=0, amp=0.5, att=0.01, rel=0.2, ffreq=6000, pan=0;
	var env = Env.perc(att, rel, amp).kr(doneAction: Done.freeSelf);
	var signal = HPF.ar(WhiteNoise.ar, freq: ffreq, mul: env);

	Out.ar(out, Pan2.ar(signal, pan));
}).add;

SynthDef("tom", {
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
var baseQuant = 16;
var stretch = 25/128 * baseQuant;
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
		// 5-4-3-2-1 pattern of Tomek Chołoniewski
		// 0.0, Pbind(
		// 	\instrument, \hihat,
		// 	\amp, Pseq([1, \, \, \, \, \, \, \, \, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \, 1, \, \, \, 1, \], inf),
		// 	\stretch, stretch,
		// ),
		0.0, makePattern.(\kick,  [1, \, \, \, \, \, \, \, \, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \, 1, \, \, \, 1, \], beats),
		0.0, makePattern.(\hihat, [1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \, \, \, 1, \], beats),
		0.0, makePattern.(\snare, [\, \, 1, 1, 1, 1, 1, 1, 1, \, \, \, 1, 1, 1, 1, 1, \, \, \, 1, 1, 1, \, \, \, 1, \, \, \], beats),
    ], inf)
);
patt.play;

CmdPeriod.doOnce({
    "-> Caught signal: <shut down>".postln;
    patt.stop;
    postf("OK\n\n");
});
)

s.queryAllNodes
s.meter


(
var a;
a = Pseq([1, Pseq([0], Pseries(9, -2, 5))], inf);
10.do { a.next.postln };
)
