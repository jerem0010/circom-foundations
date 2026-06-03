pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    var sum = 0;
    var pow2 = 1;

    for (var i = 0; i < n; i++) {
        // calcul witness
        out[i] <-- (in >> i) & 1;

        // contrainte booléenne
        out[i] * (out[i] - 1) === 0;

        // reconstruction du nombre
        sum += out[i] * pow2;
        pow2 *= 2;
    }

    sum === in;
}

component main = Num2Bits(32);