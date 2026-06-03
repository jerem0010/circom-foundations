# Circom Workflow Cheat Sheet

Petit mémo pour compiler un circuit Circom, générer un witness, vérifier les contraintes, et inspecter les outputs.

---

## 1. Structure du repo

```text
circom-foundations/
├── circuits/
│   ├── is_boolean.circom
│   ├── is_zero.circom
│   ├── is_equal.circom
│   ├── bits2num.circom
│   ├── num2bits.circom
│   ├── range_check.circom
│   └── less_than.circom
│
├── inputs/
│   └── is_zero/
│       ├── zero.json
│       └── non_zero.json
│
├── build/
├── test/
├── notes/
│   └── workflow.md
│
└── exploits/
```

---

## 2. Compiler un circuit

Exemple avec `is_zero.circom` :

```bash
circom circuits/is_zero.circom --r1cs --wasm --sym -o build
```

Cette commande génère :

```text
build/is_zero.r1cs
build/is_zero.sym
build/is_zero_js/is_zero.wasm
build/is_zero_js/generate_witness.js
```

À quoi ça sert :

```text
.r1cs              -> les contraintes du circuit
.sym               -> mapping entre labels/signals et wires
.wasm              -> programme qui calcule le witness
generate_witness.js -> script JS pour générer le witness
```

---

## 3. Inspecter les contraintes

```bash
npx snarkjs r1cs info build/is_zero.r1cs
```

Ça affiche :

```text
# of Wires
# of Constraints
# of Private Inputs
# of Public Inputs
# of Outputs
```

Pour afficher les contraintes en détail :

```bash
npx snarkjs r1cs print build/is_zero.r1cs build/is_zero.sym
```

---

## 4. Créer un input

Exemple pour `in = 0` :

```bash
mkdir -p inputs/is_zero

cat > inputs/is_zero/zero.json << 'EOF'
{
  "in": "0"
}
EOF
```

Exemple pour `in = 42` :

```bash
cat > inputs/is_zero/non_zero.json << 'EOF'
{
  "in": "42"
}
EOF
```

Le fichier input doit correspondre aux `signal input` du circuit.

Exemple :

```circom
signal input in;
```

Donc l’input JSON doit être :

```json
{
  "in": "42"
}
```

---

## 5. Générer le witness

Pour `in = 0` :

```bash
node build/is_zero_js/generate_witness.js \
  build/is_zero_js/is_zero.wasm \
  inputs/is_zero/zero.json \
  build/is_zero_zero.wtns
```

Format général :

```bash
node build/<circuit>_js/generate_witness.js \
  build/<circuit>_js/<circuit>.wasm \
  inputs/<circuit>/<input>.json \
  build/<name>.wtns
```

Le witness contient :

```text
constant 1
outputs
public inputs
private inputs
internal signals
```

---

## 6. Vérifier que le witness satisfait les contraintes

```bash
npx snarkjs wtns check build/is_zero.r1cs build/is_zero_zero.wtns
```

Si tout est bon :

```text
WITNESS IS CORRECT
```

Ça veut dire :

```text
les valeurs calculées dans le witness respectent toutes les contraintes du circuit
```

---

## 7. Exporter le witness en JSON

```bash
npx snarkjs wtns export json build/is_zero_zero.wtns build/is_zero_zero_witness.json
cat build/is_zero_zero_witness.json
```

Exemple pour `in = 0` :

```json
[
 "1",
 "1",
 "0",
 "0"
]
```

Interprétation pour `IsZero` :

```text
[constant, out, in, inv]
```

Donc :

```text
constant = 1
out      = 1
in       = 0
inv      = 0
```

Exemple pour `in = 42` :

```json
[
 "1",
 "0",
 "42",
 "15113310554365213843932042062201451846854823038382499903982093366921391580307"
]
```

Interprétation :

```text
constant = 1
out      = 0
in       = 42
inv      = 1 / 42 dans le field
```

---

## 8. Workflow complet résumé

```bash
# 1. Compiler
circom circuits/is_zero.circom --r1cs --wasm --sym -o build

# 2. Voir les infos R1CS
npx snarkjs r1cs info build/is_zero.r1cs

# 3. Créer un input
mkdir -p inputs/is_zero

cat > inputs/is_zero/non_zero.json << 'EOF'
{
  "in": "42"
}
EOF

# 4. Générer le witness
node build/is_zero_js/generate_witness.js \
  build/is_zero_js/is_zero.wasm \
  inputs/is_zero/non_zero.json \
  build/is_zero_non_zero.wtns

# 5. Vérifier le witness
npx snarkjs wtns check build/is_zero.r1cs build/is_zero_non_zero.wtns

# 6. Exporter le witness lisible
npx snarkjs wtns export json build/is_zero_non_zero.wtns build/is_zero_non_zero_witness.json

# 7. Lire le witness
cat build/is_zero_non_zero_witness.json
```

---

## 9. Mental model

Un circuit Circom n’est pas un programme classique.

```text
Programme classique:
input -> calcul -> output

Circuit Circom:
input -> witness -> contraintes -> check
```

Le prover peut choisir des valeurs internes, mais il doit satisfaire les contraintes.

Donc la vraie question en audit est toujours :

```text
Est-ce que les contraintes empêchent le prover de mentir ?
```

---

## 10. Assignations importantes

### `<==`

```circom
out <== a * b;
```

Signifie :

```text
calcule out
et ajoute la contrainte out === a * b
```

C’est généralement safe.

---

### `<--`

```circom
inv <-- 1 / in;
```

Signifie :

```text
calcule inv pour le witness
mais n’ajoute pas automatiquement une contrainte suffisante
```

Il faut toujours vérifier qu’une contrainte vient ensuite.

Exemple safe :

```circom
inv <-- in != 0 ? 1 / in : 0;
out <== 1 - in * inv;
in * out === 0;
```

---

### `===`

```circom
a * b === c;
```

Signifie :

```text
ajoute une contrainte
```

---

## 11. Checklist rapide d’audit

À chaque circuit, demander :

```text
1. Est-ce que tous les signals importants sont contraints ?
2. Est-ce que chaque `<--` est suivi de contraintes suffisantes ?
3. Est-ce que les bits sont bien forcés à être 0 ou 1 ?
4. Est-ce que les comparaisons ont des range checks ?
5. Est-ce qu’un output peut être choisi librement par le prover ?
6. Est-ce que les inputs publics/privés sont bien ceux attendus ?
```

---

## 12. Commande utile pour nettoyer le build

```bash
rm -rf build/*
```

Puis recompiler :

```bash
circom circuits/is_zero.circom --r1cs --wasm --sym -o build
```

---

## 13. Exemple : tester `IsZero`

Input :

```json
{
  "in": "0"
}
```

Output attendu :

```text
out = 1
```

Input :

```json
{
  "in": "42"
}
```

Output attendu :

```text
out = 0
```

Si `in != 0` et `out = 1`, le circuit est cassé.

---

## 14. À retenir

```text
input.json donne les inputs
generate_witness.js calcule le witness
wtns check vérifie les contraintes
wtns export json permet de lire le witness
r1cs info montre la taille du circuit
r1cs print montre les contraintes
```
