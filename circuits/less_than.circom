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

template LessThan(n) {
    signal input a;
    signal input b;
    signal output out;

    // Force a et b à être dans [0, 2^n)
    component aRange = Num2Bits(n);
    component bRange = Num2Bits(n);

    aRange.in <== a;
    bRange.in <== b;

    // Trick standard:
    // si a < b, alors le bit n de 2^n + a - b vaut 0
    // sinon il vaut 1
    component comparison = Num2Bits(n + 1);

    comparison.in <== (1 << n) + a - b;

    out <== 1 - comparison.out[n];
}

component main = LessThan(32);