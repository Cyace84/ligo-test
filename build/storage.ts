import { MichelsonMap, NatValidationError } from "@taquito/michelson-encoder";
const { faucetA } = require("../client")

// const proposalMap = new MichelsonMap({
//  prim: 'bigmap',
//  args: [{ prim: 'nat' }, { prim: 'pair' }],
// });

// const votesMap = new MichelsonMap({
//   prim: 'map',
//   args: [{ prim: 'address' }, { prim: 'nat' }]
// })

// const failedProposal = {
//   votes: votesMap,
//   votesFor: '0',
//   votesAgainst: '0',
//   end_date: '1'
// }

// // KT1MxjRZ213JLupDzCHSruy66RCbGnjMTcCf
// proposalMap.set('0', failedProposal)


// const votingStorage = {
//   owner: faucetA.pkh,
//   proposals: proposalMap,
//   id_count: '1',
//   admins: [faucetA.pkh]
// }

var votingStorage = `
      (Pair (Pair { "${faucetA.pkh}" } 12)
      "${faucetA.pkh}"
      { Elt 0 (Pair (Pair 1 {}) 0 0) ;
        Elt 1 (Pair (Pair 9999999999 {}) 0 0) ;
        Elt 2 (Pair (Pair 9999999999 {}) 0 0);
        Elt 3 (Pair (Pair 9999999999 {}) 0 0);
        Elt 4 (Pair (Pair 9999999999 {}) 0 0);
        Elt 5 (Pair (Pair 9999999999 {}) 0 0);
        Elt 6 (Pair (Pair 9999999999 {}) 0 0);
        Elt 7 (Pair (Pair 9999999999 {}) 0 0);
        Elt 8 (Pair (Pair 9999999999 {}) 0 0);
        Elt 9 (Pair (Pair 9999999999 {}) 0 0);
        Elt 10 (Pair (Pair 9999999999 {}) 0 0);
        Elt 11 (Pair (Pair 9999999999 {}) 0 0);})`
export {votingStorage};