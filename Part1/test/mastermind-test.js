const chai = require("chai");
const path = require("path");

const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Mastermind Variation test", function () {
    this.timeout(100000000);

    it("Bonus question", async () => {
        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");
        await circuit.loadConstraints();
		const pubSolnHash = "20833920637717064791070027602161194448590159201129289631348459433122020254890";
        const INPUT = {
            "pubGuessA":  "1",
			"pubGuessB":  "2",
			"pubGuessC":  "3",
			"pubGuessD":  "4",
			"pubNumHit":  "4",
			"pubNumBlow": "0",
			"pubSolnHash": pubSolnHash,
			"pubSumNum":  "10",

			"privSolnA": "1",
			"privSolnB": "2",
			"privSolnC": "3",
			"privSolnD": "4",
			"privSalt":  "7"
        }

        const witness = await circuit.calculateWitness(INPUT, true);

        console.log(witness);

        assert(Fr.eq(Fr.e(witness[0]),Fr.e(1)));
        assert(Fr.eq(Fr.e(witness[1]),pubSolnHash));
    });
}); 