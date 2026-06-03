pragma circom 2.0.0;

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? 1 / in : 0;

    out <== 1 - in * inv;

    in * out === 0;
}

template IsEqual() {
    signal input a;
    signal input b;
    signal output out;

    component isZero = IsZero();

    isZero.in <== a - b;

    out <== isZero.out;
}

component main = IsEqual();