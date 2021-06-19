const { TezosToolkit } = require('@taquito/taquito');
const { InMemorySigner } = require('@taquito/signer');

const faucetA = require('./accounts/faucetA.json');
const faucetB = require('./accounts/faucetB.json');
const faucets = [faucetA, faucetB];

const rpc = "https://api.tez.ie/rpc/florencenet";
const Tezos = new TezosToolkit(rpc)
const Tezos2 = new TezosToolkit(rpc)

const signer = InMemorySigner.fromFundraiser(faucetA.email, faucetA.password, faucetA.mnemonic.join(' '));
const signer2 = InMemorySigner.fromFundraiser(faucetB.email, faucetB.password, faucetB.mnemonic.join(' '));

Tezos.setProvider({ rpc, signer });
Tezos2.setProvider( {"signer": signer2, "rpc": rpc});

var deployedContract;

try {
    deployedContract = require('./accounts/deployed/contract_latest.json').address;
} catch (e) {
    console.log(e.message)
}

export {Tezos, faucetA, faucetB, Tezos2, deployedContract }