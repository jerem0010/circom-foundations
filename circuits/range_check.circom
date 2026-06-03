pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    var sum = 0;
    var pow2 = 1;

    for (var i = 0; i < n; i++) {
        out[i] <-- (in >> i) & 1;

        out[i] * (out[i] - 1) === 0;

        sum += out[i] * pow2;
        pow2 *= 2;
    }

    sum === in;
}

template RangeCheck(n) {
    signal input in;
    signal output valid;

    component bits = Num2Bits(n);

    bits.in <== in;

    valid <== 1;
}

component main = RangeCheck(32);