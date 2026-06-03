pragma circom 2.0.0;

template IsBoolean() {
    signal input in;

    in * (in - 1) === 0;
}

component main = IsBoolean();