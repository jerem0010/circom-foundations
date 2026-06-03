pragma circom 2.0.0;

template Bits2Num(n) {
    signal input in[n];
    signal output out;

    var sum = 0;
    var pow2 = 1;

    for (var i = 0; i < n; i++) {
        // chaque bit doit être 0 ou 1
        in[i] * (in[i] - 1) === 0;

        sum += in[i] * pow2;
        pow2 *= 2;
    }

    out <== sum;
}

component main = Bits2Num(32);