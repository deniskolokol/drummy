// selected samples
(
SynthDef(\bufplay, {
    arg out=0, buf=0, rate=1, amp=1, pan=0;
    var signal = PlayBuf.ar(2, buf, BufRateScale.ir(buf)*rate, doneAction: 2);

    signal = Pan2.ar(signal, pan, amp);
    Out.ar(out, signal)
}).add;

SynthDef(\reverb, {
    arg in, out=0, predelay=0.1, revtime=1.8, lpf=4500, amp=1, mix=0.15;
    var dry, wet, temp, sig;
    dry = In.ar(in, 2);
    temp = In.ar(in, 2);
    wet = 0; // or `DC.ar(0)!2` or `Silent.ar(2)`
    temp = DelayN.ar(temp, 0, 2, predelay);
    16.do {
        temp = AllpassN(temp, 0.05, {Rand(0.001, 0.05)}!2, revtime);
        temp = LPF(temp, lpf);
        wet = wet + temp
    };
    sig = XFade2.ar(dry, wet, mix*2-1, amp);
    Out.ar(out, sig);
}).add;
)

~reverbBus = Bus.audio(s, 2);
~createReverb = {~reverbSynth = Synth(\reverb, [\in, ~reverbBus])}
ServerTree.add(~createReverb);
// ServerTree.removeAll;

// version 1
(
d = Dictionary.new;
d.add(\l -> PathName("~/Projects/music/viDrum/samples/low/").entries.collect({
    arg sf;
    Buffer.read(s, sf.fullPath)
}));
d.add(\h -> PathName("~/Projects/music/viDrum/samples/high/").entries.collect({
    arg sf;
    Buffer.read(s, sf.fullPath)
}));
d.add(\m -> PathName("~/Projects/music/viDrum/samples/mid/").entries.collect({
    arg sf;
    Buffer.read(s, sf.fullPath)
}));

Pdef(
    \rhythm,
    Pbind(
        \instrument, \bufplay,
        \dur, Pseq([1/16, 1/8, 1/8, 1/16], inf),
        \stretch, 1.875, // 60/128 * 4,
        \buf, Pseq(
            [
                Prand(d[\l], 1), Pshuf(d[\m], 2), Prand(d[\h], 1),
                Prand(d[\l], 1), Prand(d[\m], 1), Pshuf(d[\h], 2)
            ],
            inf),
        \rate, Pexprand(0.4, 4.1, inf),
        \amp, Pseq([0.8, Pexprand(0.1, 0.2, 4), 0.8, Pexprand(0.1, 0.2, 4)], inf),
        // \out, ~reverbBus // WARNING! Doesn't work!
    )
).play(quant: 1.875)
)

Synth(\bufplay, [\buf, d[\m][0], \out, ~reverbBus])


// version 2 - more samples
(
var baseDir = "~/Music/material/Drum samples/513TubeDrumHits_Wav_SP/Samples/";
var baseQuant = 4;
var stretch = 60/128 * baseQuant;
var drumset = Dictionary.new;
var patt;

drumset.add(\snare -> PathName(baseDir +/+ "Snares").entries.collect({ |sf|
    Buffer.read(s, sf.fullPath)
}));
drumset.add(\kick -> PathName(baseDir +/+ "Kicks").entries.collect({ |sf|
    Buffer.read(s, sf.fullPath)
}));
drumset.add(\hat -> PathName(baseDir +/+ "Hats\ &\ Shakers").entries.collect({ |sf|
    Buffer.read(s, sf.fullPath)
}));

patt = Pdef(
    \rhythm,
    Pbind(
        \instrument, \bufplay,
        \dur, Pwrand([
            Pseq([1/16, 1/16, 1/16, 1/16, 1/16, 1/16, 1/16, 1/16], 2),
            Pseq([1/16, 1/8, 1/8, 1/16], 4),
            Pseq([1/8, 1/4, 1/4, 1/8], 2)
        ],
        [0.3, 0.5, 0.2], inf),
        \stretch, stretch,
        \buf, Pseq(
            [
                Prand(drumset[\kick], 1), Pshuf(drumset[\snare], 2), Prand(drumset[\hat], 1),
                Prand(drumset[\kick], 1), Prand(drumset[\snare], 1), Pshuf(drumset[\hat], 2)
            ],
            inf),
        \rate, Pexprand(0.4, 4.1, inf),
        \amp, Pseq([0.8, Pexprand(0.1, 0.2, 4), 0.8, Pexprand(0.1, 0.2, 4)], inf)
    )
);
patt.play(quant: 1.875);

CmdPeriod.doOnce({
    "-> Caught signal: <shut down>".postln;
    patt.stop;

    "INFO: Freeing internal buffers".postln;
    drumset[\snare].do { |buff| buff.free };
    drumset[\kick].do { |buff| buff.free };
    drumset[\hihat].do { |buff| buff.free };

    postf("OK\n\n");
});
)