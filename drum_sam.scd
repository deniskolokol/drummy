(
SynthDef(\bufplay, {
    arg out=0, buf=0, rate=1, amp=1, pan=0;
    var signal = PlayBuf.ar(1, buf, BufRateScale.ir(buf)*rate, doneAction: 2);
    signal = signal * amp;
    signal = Pan2.ar(signal, pan);
    Out.ar(out, signal)
}).add
)

(
// Load samples.
~bufRead = { |x|
    var baseDir = PathName.new(
        "~/Music/material/Drum samples/513TubeDrumHits_Wav_SP/Samples/"
    );
    Buffer.readChannel(s, (baseDir +/+ x).fullPath, channels:[0])
};
~hat = { |n| ~bufRead.("Hats\ &\ Shakers" +/+ n)};
~kck = { |n| ~bufRead.("Kicks" +/+ n)};
~snr = { |n| ~bufRead.("Snares" +/+ n)};
~clp = { |n| ~bufRead.("Claps" +/+ n)};
~cym = { |n| ~bufRead.("Rides & Cymbals" +/+ n)};
~tom = { |n| ~bufRead.("Toms" +/+ n)};
~per = { |n| ~bufRead.("Percussion" +/+ n)};

// Some defaults:
// Hi Hat.
~hihat = ~hat.("1_C#2_Hat_SP.wav");

// Open hat.
~ohat = ~hat.("1_C3_Hat_SP.wav");

// Snare.
~snare = ~snr.("1_B2_Snare_SP.wav");

// Kick.
~kick = ~kck.("1_A#4_Kick_SP.wav");

// Tempo.
~tempo = TempoClock.new(105/60).schedAbs(0, { ~tempo.beatsPerBar_(4) });
~dur = 1/4;

// Main pattern.
~pt = Pdef(
    \rhythm,
    Ptpar([
        // 4x4
        0.0, Pbind(
            \instrument, \bufplay,
            \dur, Pseq(~dur ! 8, inf),
            \buf, Pfunc({ ~ohat }),
            \amp, Pseq([1, \, Pwhite(0.85, 1.0, 1), \], inf), // first beat is an accent
            \pan, 0.3
        ),
        0.0, Pbind(
            \instrument, \bufplay,
            \dur, Pseq(~dur ! 8, inf),
            \buf, Pfunc({ ~kick }),
            \amp, Pseq([1, \, \, \, \, \, \, \], inf),
        ),
        0.0, Pbind(
            \instrument, \bufplay,
            \dur, Pseq(~dur ! 8, inf),
            \buf, Pfunc({ ~snare }),
            \amp, Pseq([\, \, \, \, 1, \, \, \], inf),
            \pan, -0.3
        )
    ], inf)
);
p = ~pt.play(~tempo, quant: Quant(4));

CmdPeriod.doOnce({
    "-> Caught signal: <shut down>".postln;
    p.stop;

    "-> Freeing all buffers".postln;
    Buffer.freeAll;

    postf("OK\n\n");
});
)


// Change tempo.
~tempo.schedAbs(~tempo.nextBar, { ~tempo.tempo_(120/60) })
