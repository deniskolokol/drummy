(
SynthDef(\bufplay, {
    arg out=0, buf=0, rate=1, amp=1, pan=0;
    var signal = PlayBuf.ar(2, buf, BufRateScale.ir(buf)*rate, doneAction: 2);
    signal = signal * amp;

    Out.ar(out, signal)
}).add;
)

(
a = ( );

q = 32; // baseQuant
b = 105; // BPM

a[\stretch] =  15 / b * q;
a[\dur] = q.reciprocal ! 15;

// dirs and samples
d = "/Users/deko/Music/material/Drum\ samples/513TubeDrumHits_Wav_SP/Samples/";
a[\buff] = (
	snare: Buffer.read(s, d +/+ "Snares/1_B2_Snare_SP.wav"),
	kick: Buffer.read(s, d +/+ "Kicks/1_A#4_Kick_SP.wav"),
	hihat: Buffer.read(s, d +/+ "Hats\ &\ Shakers/1_C#2_Hat_SP.wav"),
	openHat: Buffer.read(s, d +/+ "Hats\ &\ Shakers/1_C3_Hat_SP.wav")
);
p = Pdef(
    \rhythm,
    Ptpar([
		// 4x4
		0.0, Pbind(
			\instrument, \bufplay,
			\dur, Pseq(a.dur, inf),
			\stretch, a.stretch,
			\buf, a.buff.openHat,
			\amp, Pseq([1, \, Pwhite(0.85, 1.0, 1), \], inf) // first beat is an accent
		),
		0.0, Pbind(
			\instrument, \bufplay,
			\dur, Pseq(a.dur, inf),
			\stretch, a.stretch,
			\buf, a.buff.kick,
			\amp, Pseq([1, \, \, \, \, \, \, \], inf)
		),
		0.0, Pbind(
			\instrument, \bufplay,
			\dur, Pseq(a.dur, inf),
			\stretch, a.stretch,
			\buf, a.buff.snare,
			\amp, Pseq([\, \, \, \, 1, \, \, \], inf)
		)
    ], inf)
);

p.play();

CmdPeriod.doOnce({
    "-> Caught signal: <shut down>".postln;
    p.stop;

    "INFO: Freeing internal buffers".postln;
	a.buff.do { |buff| buff.free };

    postf("OK\n\n");
});
)



// 5-4-3-2-1 pattern of Tomek Chołoniewski
// openHat [1, \, \, \, \, \, \, \, \, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \, 1, \, \, \, 1, \]
// kick    [1, \, \, \, \, \, \, \, \, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \, 1, \, \, \, 1, \]
// snare   [\, \, 1, 1, 1, 1, 1, 1, 1, \, \, \, 1, 1, 1, 1, 1, \, \, \, 1, 1, 1, \, \, \, 1, \, \, \]
