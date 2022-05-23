pragma circom 2.0.0;

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

/* Number Mastermind - Rules
    - Only Numbers in range [0-9] are allowed. 
    - Repeated Numbers are allowed.
    - Extra clue - sum of numbers is provided
*/
template MastermindVariation() {
    // Public inputs
    signal input pubGuessA;
    signal input pubGuessB;
    signal input pubGuessC;
    signal input pubGuessD;
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubSolnHash;
    signal input pubSumNum;

    // Private inputs
    signal input privSolnA;
    signal input privSolnB;
    signal input privSolnC;
    signal input privSolnD;
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var guess[4] = [pubGuessA, pubGuessB, pubGuessC, pubGuessD];
    var soln[4] =  [privSolnA, privSolnB, privSolnC, privSolnD];
    var j = 0;
    var k = 0;
    component lessThan[8];
    component greaterEqThan[8];
    var equalIdx = 0;

    // Create a constraint that the solution and guess digits are all less than 10 and greater than zero.
    for (j=0; j<4; j++) {
        // Validate guess range: [0-9]
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 10;
        lessThan[j].out === 1;
        greaterEqThan[j] = GreaterEqThan(4);
        greaterEqThan[j].in[0] <== guess[j];
        greaterEqThan[j].in[1] <== 0;
        greaterEqThan[j].out === 1;

        //validate solution range: [0-9]
        lessThan[j+4] = LessThan(4);
        lessThan[j+4].in[0] <== soln[j];
        lessThan[j+4].in[1] <== 10;
        lessThan[j+4].out === 1;
        greaterEqThan[j+4] = GreaterEqThan(4);
        greaterEqThan[j+4].in[0] <== soln[j];
        greaterEqThan[j+4].in[1] <== 0;
        greaterEqThan[j+4].out === 1;
    }

    // Count hit & blow
    var hit = 0;
    var blow = 0;
    component equalHB[16];

    for (j=0; j<4; j++) {
        for (k=0; k<4; k++) {
            equalHB[4*j+k] = IsEqual();
            equalHB[4*j+k].in[0] <== soln[j];
            equalHB[4*j+k].in[1] <== guess[k];
            blow += equalHB[4*j+k].out;
            if (j == k) {
                hit += equalHB[4*j+k].out;
                blow -= equalHB[4*j+k].out;
            }
        }
    }

    var sum = 0;
    //Populate the sum
    for (j=0; j<4; j++) {      
        sum += guess[j];            
    }
    //log(sum);
    // Create a constraint around the number of hit
    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;
    
    // Create a constraint around the number of blow
    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    // Create a contraint around sum of numbers
    component equalSumNum = IsEqual();
    equalSumNum.in[0] <== pubSumNum;
    equalSumNum.in[1] <== sum;
    equalSumNum.out === 1;

    // Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(5);
    poseidon.inputs[0] <== privSalt;
    poseidon.inputs[1] <== privSolnA;
    poseidon.inputs[2] <== privSolnB;
    poseidon.inputs[3] <== privSolnC;
    poseidon.inputs[4] <== privSolnD;
    //log(pubGuessA);
    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;
 }

 component main {public [pubGuessA, pubGuessB, pubGuessC, pubGuessD, pubNumHit, pubNumBlow, pubSolnHash]} = MastermindVariation();

/* INPUT = {
    "pubGuessA": "1",
    "pubGuessB": "2",
    "pubGuessC": "3",
    "pubGuessD": "4",
    "pubNumHit": "4",
    "pubNumBlow": "0",
    "pubSolnHash": "20833920637717064791070027602161194448590159201129289631348459433122020254890",
    "pubSumNum": "10",

    "privSolnA": "1",
    "privSolnB": "2",
    "privSolnC": "3",
    "privSolnD": "4",
    "privSalt": "7"
} */