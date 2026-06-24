# circom-foundations

Small Circom building blocks for learning how zero-knowledge circuits are built from low-level constraints.

This repository contains foundational gadgets used in many ZK circuits: boolean checks, equality checks, zero checks, range checks, bit decomposition, and less-than comparison.

## Circuits

```txt
circuits/
├── is_boolean.circom
├── is_zero.circom
├── is_equal.circom
├── num2bits.circom
├── bits2num.circom
├── range_check.circom
└── less_than.circom
```

## What this repo teaches

### Boolean constraints

Force a signal to be either `0` or `1`:

```txt
x * (x - 1) === 0
```

### Bit decomposition

Convert a number into bits and reconstruct it inside the circuit.

This is one of the most important primitives in Circom because comparisons, range checks, and many higher-level gadgets rely on bit decomposition.

### Range checks

Prove that a private value is inside a valid range.

Example:

```txt
0 <= x < 2^n
```

### Less-than comparison

Implement `a < b` using binary decomposition and the classic Circom comparison trick.

## Why this matters

High-level ZK applications are built from small reusable constraints.

Before building private voting, anonymous DAOs, private payments, or identity proofs, you need to understand these primitives deeply.

This repo is my personal foundation layer for that learning process.

## Requirements

Install SnarkJS:

```bash
npm install -g snarkjs
```

You also need Circom installed.

## Compile Example

```bash
mkdir -p build
circom circuits/less_than.circom --r1cs --wasm --sym -o build
```

## Generate Witness

```bash
node build/less_than_js/generate_witness.js \
  build/less_than_js/less_than.wasm \
  input.json \
  build/witness.wtns
```

Example input:

```json
{
  "a": 5,
  "b": 10
}
```

## Learning Notes

This repository is intentionally simple.  
The goal is not to build production circuits, but to understand the constraint logic behind common ZK gadgets.

## Disclaimer

Educational repository only.  
Do not use these circuits in production without formal review and testing.
