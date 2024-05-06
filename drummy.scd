// TODO:
// - positioning in a stereo field
(
SynthDef(\bufplay, {
    arg out=0, buf=0, rate=1, amp=1, pan=0;
    var signal = PlayBuf.ar(2, buf, BufRateScale.ir(buf)*rate, doneAction: 2);
    signal = signal * amp;

    Out.ar(out, signal)
}).add;
)

(
~quant = 32; // baseQuant
~bpm = 105; // BPM

~stretch =  15 / ~bpm * ~quant;
~dur = ~quant.reciprocal ! 15;

// dirs and samples

// TODO:
// - mix channels into one or load only one channel
~bufRead = { |x|
    var baseDir = PathName.new(
        "~/Music/material/Drum samples/513TubeDrumHits_Wav_SP/Samples/"
    );
    Buffer.read(s, (baseDir +/+ x).fullPath)
};
~hat = { |n| ~bufRead.("Hats\ &\ Shakers" +/+ n)};
~kck = { |n| ~bufRead.("Kicks" +/+ n)};
~snr = { |n| ~bufRead.("Snares" +/+ n)};
~clp = { |n| ~bufRead.("Claps" +/+ n)};
~cym = { |n| ~bufRead.("Rides & Cymbals" +/+ n)};
~tom = { |n| ~bufRead.("Toms" +/+ n)};
~per = { |n| ~bufRead.("Percussion" +/+ n)};

// Some defaults
// Hi Hat
~hihat = ~hat.("1_C#2_Hat_SP.wav");

// Open hat
~ohat = ~hat.("1_C3_Hat_SP.wav");

// Snare
~snare = ~snr.("1_B2_Snare_SP.wav");

// Kick
~kick = ~kck.("1_A#4_Kick_SP.wav");
)

// TODO:
// - positioning in a stereo field
(
p = Pdef(
    \rhythm,
    Ptpar([
		// 4x4
		0.0, Pbind(
			\instrument, \bufplay,
			\dur, Pseq(~dur, inf),
			\stretch, ~stretch,
			\buf, Pfunc({ ~ohat }),
			\amp, Pseq([1, \, Pwhite(0.85, 1.0, 1), \], inf) // first beat is an accent
		),
		0.0, Pbind(
			\instrument, \bufplay,
			\dur, Pseq(~dur, inf),
			\stretch, ~stretch,
			\buf, Pfunc({ ~kick }),
			\amp, Pseq([1, \, \, \, \, \, \, \], inf)
		),
		0.0, Pbind(
			\instrument, \bufplay,
			\dur, Pseq(~dur, inf),
			\stretch, ~stretch,
			\buf, Pfunc({ ~snare }),
			\amp, Pseq([\, \, \, \, 1, \, \, \], inf)
		)
    ], inf)
);

p.play();

CmdPeriod.doOnce({
    "-> Caught signal: <shut down>".postln;
    p.stop;

    "-> Freeing all buffers".postln;
    Buffer.freeAll;

    postf("OK\n\n");
});
)
