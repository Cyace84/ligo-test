# Description

This is a test task, a smart contract for voting on proposals in the Tezos blockchain

# Requirements

- Installed NodeJS (tested with NodeJS v14+)
- Installed Yarn


- Installed node modules:

```
yarn install

```

# Quick Start

```
yarn deploy

```

or

```
yarn deployTest

```

Addresses of deployed contracts are displayed in terminal and saved to file `./accounts/deployed/contract_latest.json`

NOTE: You can replace the faucetA, faucetB with new faucets `https://faucet.tzalpha.net/`

`./accounts/faucetA.json` `./accounts/faucetB.json`

# Tests

```
yarn test

```

# Contract

The main contract is `Voting` with the following interface:

```
type id is nat;
type vote is string;
type new_vote is nat * string;
type votes is map(address, vote);
type day is nat;
type proposal_period is day;

type parameter is
  | Vote of new_vote
  | AddAdmin of address
  | RemoveAdmin of address
  | NewProposal of proposal_period
  | TransferOwnership of address

type proposal is
record [
  votes: votes;
  votesFor: nat;
  votesAgainst: nat;
  end_date: timestamp
]

type storage is
record [
  owner: address;
  proposals: big_map(id, proposal);
  id_count: nat;
  admins: set(address)
]

```
