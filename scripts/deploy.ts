import { votingStorage } from "../build/storage";

const { Tezos } = require("../client")
const genericVotingJSONfile = require('../build/Voting.json')
const fse = require('fs-extra');

Tezos.contract
  .originate({
    code: genericVotingJSONfile,
    init: votingStorage,
  })
  .then((originationOp) => {
    console.log(`Waiting for confirmation of origination for ${originationOp.contractAddress}...`);
    let data = {
      address: originationOp.contractAddress
    }

    fse.outputFile('./accounts/deployed/contract_latest.json', JSON.stringify(data), err => {
    if(err) {
      console.log(err);
    } else {
      console.log('The contract address was saved!');
    }
  })
    return originationOp.contract();
  })
  .then((contract) => {
    console.log(`Origination completed.`);
  })
  .catch((error) => console.log(error));

