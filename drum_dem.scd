(
SynthDef(\drumline_full, {
    arg route=0, freq=1, amp=1, gate=1, att=1, rel=1, ca=6, cr= -3;

    var introN=10;
    var outroN=24;
    var fullN=4; // full cycles of main line + syncope
    var measure = 1/16 ! 10 * freq;
    var rhythmTrig = {
        TDuty.ar(Dseq(measure, inf), 0, Dwhite(0.5, 1, 2278)) //inf))
    } ! 2;

    var kickTrig = {
        TDuty.ar(Dseq(measure, inf) * 2, 0,
            Dseq([
                // intro silent (hat only)
                Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], introN-1),
                Dseq([
                    // off-beat
                    Dseq([0, 0, 0, 0.2, 0.8, 1, 0, 1, 0, 0], 1),
                    Dseq([
                        // fig 1 - main line
                        Dseq([Dwrand([0, 1], [0.2, 0.8], 1), 0, 1, 0, 0, 0, 1, 1, 0, 0], 3),
                        Dxrand([
                            // fig 2 - syncope 1
                            Dseq([0, 0, 1, 0, 0, 1, 1, 1, 0, 0], 1),
                            // fig 3 - syncope 2
                            Dseq([0, 1, 0, 0, 1, 0, 0, 1, 0, 0], 1),
                            // fig 4 - syncope 3
                            Dseq([0, 1, 0, 0, 1, 1, 0, 0, 1, 1], 1),
                        ], 1),
                    ], 4),
                    // intermission
                    Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 3),
                ], fullN),
                // outro silent (hat only)
                Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], outroN),
                // outro hit
                Dseq([0, 0, 0, 0, 1, 1, 0, 1, 1, 1], 1)
            ], 1)
        )
    } ! 2;

    var snareTrig = {
        TDuty.ar(Dseq(measure, inf) * 2, 0,
            Dseq([
                // intro silent (hat only)
                Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], introN-1),
                Dseq([
                    // off-beat
                    Dseq([0, 0, 0, 0, 0, 0, 1, 0, 1, 0.8], 1),
                    Dseq([
                        // fig 1 - main line
                        Dseq([0, 0, 0, 1, 0, 0, 0, 0, 1, 0], 3),
                        Dxrand([
                            // fig 2 - syncope 1
                            Dseq([1, 1, 0, 0, 0, 1, 0, 0, 1, Drand([0, 1], 1)], 1),
                            // fig 3 - syncope 2
                            Dseq([1, 0, 0, 1, 0, 0, 1, 0, 1, Drand([0, 1], 1)], 1),
                            // fig 4 - syncope 3
                            Dseq([0, 0, 1, 0, 0, 0, 1, 0, 1, 1], 1),
                        ], 1),
                    ], 4),
                    // intermission
                    Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 3),
                ], fullN),
                // outro silent (hat only)
                Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], outroN),
                // outro hit
                Dseq([0, 0, 0, 0, 0, 1, 0, 1, 1, 0], 1)
            ], 1)
        )
    } ! 2;

    var tomTrig = {
        TDuty.ar(Dseq(measure, inf) * 2, 0,
            Dseq([
                // intro silent (hat only)
                Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], introN + (fullN*4 + 3)),
                Dseq([
                    // off-beat (tom is silent)
                    Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 1),
                    Dseq([
                        // fig 1 - main line
                        Dseq([0, 0, 0, 0, 0, 1, Dwrand([1, 0], [0.7, 0.3], 1), 0, 0, 1], 3),
                        Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 1),
                    ], 4),
                    // intermission
                    Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 3),
                ], fullN-1),
                // outro silent (hat only)
                Dseq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0], outroN),
                // outro hit
                Dseq([0, 0, 0, 0, 0, 0, 0, 1, 1, 0], 1)
            ], 1)
        )
    } ! 2;

    var kickFreq = #[58.0936, 47.3074, 10.2712, 57.8168, 75.0203];
    var kick =
	// (
	// 	BPeakEQ.ar(
	// 		SinOsc.ar(kickFreq, 0, 1/kickFreq.size), 1900, 1, 12.0
	// 	)
	// 	+ SinOsc.ar(
	// 		0,
	// 		(Sweep.ar(kickTrig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi),
	// 		[2, 0.05]
	// 	).mean.tanh
	// );
	SinOsc.ar(
		0,
		(Sweep.ar(kickTrig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi),
		[2, 0.05]
	).mean.tanh
	* EnvGen.ar(Env([0, 0.5, 0.4, 0], [0, 0.2, 0.01], -5), kickTrig.abs)!2
	+
	LPF.ar(WhiteNoise.ar(Decay2.ar(kickTrig * LFNoise1.ar(8, 0.5, 0.5), TRand.ar(0.02, 0.3, kickTrig), 0.1)), 1500);
    var snareFreq = #[ 81.5224, 163, 244.3903, 326.7002, 407.7456 ];
    var snareMul = [0.05, 0.65, 0.1, 0.04, 0.01];
    var snare = (
        LPF.ar(
            Pulse.ar(snareFreq, 0.5, snareMul.sum),
            EnvGen.ar(Env.perc(0.05, 0.2, 0.2, -4), snareTrig)!2 * 3000 + 30
        ) * EnvGen.ar(Env.perc(0.05, 0.7, 1, -4), snareTrig)!2
    )
    + AllpassN.ar(
        BPF.ar(HPF.ar(WhiteNoise.ar(1), 500), 1500), 0.05, [0.05.rand, 0.05.rand], 4
    ) * EnvGen.ar(Env.perc(0.01, 0.3, 1, -3), snareTrig);
    var tomFreq = snareFreq+66;
    var tom = (
        LPF.ar(
            Pulse.ar(tomFreq, 0.5, snareMul),
            EnvGen.ar(Env.perc(0.05, 0.5, 0.2, -4), tomTrig)!2 * 3000 + 30
        ) * EnvGen.ar(Env.perc(0.05, 0.7, 1, -4), tomTrig)!2
    )
    + AllpassN.ar(
        BPF.ar(HPF.ar(WhiteNoise.ar(0.35), 500), 1500), 0.05, [0.05.rand, 0.05.rand], 4
    ) * EnvGen.ar(Env.perc(0.01, 0.1, 0.5, -6), tomTrig);
    var hat = HPF.ar(
        LPF.ar(
            WhiteNoise.ar(
                TWChoose.ar(rhythmTrig, [
                    Decay2.ar(rhythmTrig * LFNoise1.ar(8, 0.3, 0.5), 0.02, 0.1),
                    Decay2.ar(rhythmTrig * LFNoise1.ar(8, 0.3, 0.5), 0.5, 0.1)
                ], [0.8, 0.2])
            ), 6000
        ),
        TRand.ar(1000, 8000, rhythmTrig)
    );
    var signal = MidEQ.ar(
        hat
        +
        kick
        +
        snare
        +
        tom
        , 14000, 0.7, 3
    );
    var out = Limiter.ar(signal, amp)
    * EnvGen.kr(Env.adsr(att, 0.1, 1, rel, curve:[ca, cr]), gate: gate, doneAction: 2);

    Out.ar(route, out);
}).add;


SynthDef(\drumline_10x16, {
    arg route=0, freq=1, amp=1, gate=1, att=1, rel=1, ca=6, cr= -3;

    var measure = 1/16 ! 10 * freq;
    var num = 60;
    var rhythmTrig = {
        TDuty.ar(Dseq(measure, inf), 0, Dwhite(0.5, 1, 2278)) //inf))
    } ! 2;

    var kickSeq =  [1,   0, 0.2,   0,   0, 0.2,   1,   0,   0,   0];
    var snareSeq = [0,   0,   0,   1,   0,   0,   0,   0,   1,   0];
    var tomSeq =   [0,   0,   0,   0,   0,   1,   0,   1,   0,   1];

    var kickTrig = {
        TDuty.ar(Dseq(measure, inf) * 2, 0,
            Dseq(kickSeq, inf)
            // Dseq([Dwrand([0, 1], [0.2, 0.8], 1), 0, 1, 0, 0, 0, 1, 1, 0, 0], inf)
        )
    } ! 2;

    var snareTrig = {
        TDuty.ar(Dseq(measure, inf) * 2, 0,
            Dseq(snareSeq, inf)
        )
    } ! 2;

    var tomTrig = {
        TDuty.ar(Dseq(measure, inf) * 2, 0,
            Dseq(tomSeq, inf)
        )
    } ! 2;

    var kickFreq = #[58.0936, 47.3074, 10.2712, 57.8168, 75.0203];
	// var kick =
	// (
	// 	BPeakEQ.ar(
	// 		SinOsc.ar(kickFreq, 0, 1/kickFreq.size), 1900, 1, 12.0
	// 	)
	// 	+ SinOsc.ar(
	// 		0,
	// 		(Sweep.ar(kickTrig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi),
	// 		[2, 0.05]
	// 	).mean.tanh
	// );
    var kick = SinOsc.ar(
        0,
        (Sweep.ar(kickTrig, 2pi * [52.8, 740]) + (pi/3)).wrap(-pi, pi),
        [2, 0.05]
    ).mean.tanh
    * EnvGen.ar(Env([0, 0.5, 0.4, 0], [0, 0.2, 0.01], -5), kickTrig.abs)!2
    +
    LPF.ar(WhiteNoise.ar(Decay2.ar(kickTrig * LFNoise1.ar(8, 0.5, 0.5), TRand.ar(0.02, 0.3, kickTrig), 0.1)), 1500);
    var snareFreq = #[ 81.5224, 163, 244.3903, 326.7002, 407.7456 ];
    var snareMul = [0.05, 0.65, 0.1, 0.04, 0.01];
    var snare = (
        LPF.ar(
            Pulse.ar(snareFreq, 0.5, snareMul.sum),
            EnvGen.ar(Env.perc(0.05, 0.3, 0.2, -4), snareTrig)!2 * 3000 + 30
        ) * EnvGen.ar(Env.perc(0.05, 0.2, 1, -4), snareTrig)!2
    )
    + AllpassN.ar(
        BPF.ar(HPF.ar(WhiteNoise.ar(1), 500), 1000), 0.05, [0.05.rand, 0.05.rand], 4
    ) * EnvGen.ar(Env.perc(0.01, 0.3, 1, -3), snareTrig);
    var tomFreq = snareFreq + 66;
    var tom = (
        LPF.ar(
            Pulse.ar(tomFreq, 0.5, snareMul),
            EnvGen.ar(Env.perc(0.05, 0.3, 0.2, -4), tomTrig)!2 * 3000 + 30
        ) * EnvGen.ar(Env.perc(0.05, 0.2, 1, -4), tomTrig)!2
    )
    + AllpassN.ar(
        BPF.ar(HPF.ar(WhiteNoise.ar(0.35), 500), 1500), 0.05, [0.05.rand, 0.05.rand], 4
    ) * EnvGen.ar(Env.perc(0.01, 0.1, 0.5, -6), tomTrig);
    var hat = HPF.ar(
        LPF.ar(
            WhiteNoise.ar(
                TWChoose.ar(rhythmTrig, [
                    Decay2.ar(rhythmTrig * LFNoise1.ar(8, 0.5, 0.5), 0.02, 0.1),
                    Decay2.ar(rhythmTrig * LFNoise1.ar(8, 0.5, 0.5), 0.5, 0.1)
                ], [0.8, 0.2])
            ), 6000
        ),
        TRand.ar(1000, 8000, rhythmTrig)
    );

    var signal = MidEQ.ar(
        hat
        +
        kick
        +
        snare
        +
        tom
        , 14000, 0.7, 8
    );
    var out = Limiter.ar(signal, amp) * EnvGen.kr(
        Env.adsr(att, 0.1, 1, rel, curve:[ca, cr]),
        gate: gate, doneAction: 2
    );
    Out.ar(route, out);
}).add;


SynthDef(\groove_drumline_1, {
    arg tempo=2, route=0, pan=0, amp=1, gate=1, att=1, rel=1, ca=6, cr= -3;
	var trig = TDuty.kr([0.5, 1, 0.25]/tempo, TDuty.kr(Dser([0.75, 0.75, 0.5]/tempo, inf)));
    var kick = Ringz.ar(T2A.ar([trig[0], trig[1]]), [45, 330], [0.5, 0.1], [0.9, 0.1]);
    var pulse = Ringz.ar(T2A.ar(trig[2]), 90, 0.2,2).clip*0.2;
	var env = Env.perc(0, 0.2, 1, -5);
	var hat = HPF.ar(LPF.ar(WhiteNoise.ar(Decay2.ar(LFNoise1.ar(8, 0.3, 0.5), 0.02, 0.1)), 1678), 17774) * EnvGen.kr(env, trig[1]);
    var snare = BPF.ar(LFNoise0.ar(98**2,0.4), 98**2, 1, 0.04) * EnvGen.kr(env, trig[1]);
    var signal = MidEQ.ar(
		kick
		+
		snare
		+
		hat
		+
		pulse
        , 14000, 0.7, 8
    );
    var out = Limiter.ar(signal, amp) * EnvGen.kr(
        Env.adsr(att, 0.1, 1, rel, curve:[ca, cr]),
        gate: gate, doneAction: 2
    );
	Out.ar(route, Pan2.ar(out, pan));
}).add;
)

// guitar preset on Zoom: Eruption (48)
// typical \tempo, 2
c = Synth(\groove_drumline_1, [\route, 0, \tempo, 1.4])
c.free


a = Synth(\drumline_full, [\freq, 2])
a.free

b = Synth(\drumline_10x16, [\freq, 2])
b.free

s.meter