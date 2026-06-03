pragma circom 2.0.0;

template IsZero() {
    signal input in;
    signal output out;

    signal inv;

    inv <-- in != 0 ? 1 / in : 0;

    out <== 1 - in * inv;

    in * out === 0;
}

component main = IsZero();