type id is nat;
type vote is string;

type votes is map(address, vote);
type new_vote is nat * string;

type parameter is
  | Vote of new_vote
  | AddAdmin of address
  | RemoveAdmin of address

type proposal is 
record [
  votes: votes;
  end_date: timestamp
]

type storage is 
record [
  proposals: big_map(id, proposal);
  id_count: nat;
  admins: set(address)
]

type return is list (operation) * storage

const empty_votes_map : votes = map[];

function isAdmin (const admins: set(address)): unit is
  block {
    if Set.mem(Tezos.sender, admins) then skip
    else failwith("This method is for administrators only.")
  } with unit


function getProposal(const prop_id : id; const storage : storage) : proposal is 
case storage.proposals[prop_id] of None -> record [
    votes = empty_votes_map;
    end_date = ("2000-01-01T10:10:10Z" : timestamp)
]
| Some(proposal) -> proposal
end

function newProposal (const end_date: timestamp; var storage : storage) : storage is
  block {
    isAdmin(storage.admins);
    if (end_date > Tezos.now) then skip
    else failwith("Invalid timestamp");

    storage.proposals[storage.id_count] := record [
      votes = empty_votes_map;
      end_date = end_date;
    ];
    storage.id_count := storage.id_count + 1n

  } with storage

function addVote (const vote: new_vote; var storage: storage) : storage is 
  block {
    if (Tezos.amount < 1tez) then skip
    else failwith("One vote costs 1tez");
    if Big_map.mem(vote.0, storage.proposals) then skip
    else failwith("Invalid proposal id");

    var proposal : proposal := getProposal(vote.0, storage);
    if (Tezos.now >= proposal.end_date) then failwith("The voting period is over")
    else skip;

    if Map.mem(Tezos.sender, proposal.votes) then failwith("You have already voted for this proposal");
    else skip;

    proposal.votes := Map.add((Tezos.sender: address), vote.1, proposal.votes);
    storage.proposals[vote.0] := proposal
  } with storage

function addAdmin (const admin: address; var storage: storage) : storage is
  block {
    isAdmin(storage.admins);
    if Set.mem(admin, storage.admins) then failwith("This address is already an administrator")
    else skip;
    storage.admins := Set.add(admin, storage.admins)
} with storage

function removeAdmin (const admin: address; var storage: storage) : storage is 
block {
//   isAdmin(storage.admins);
  if not(Set.mem(admin, storage.admins)) then failwith("Invalid administrator address")
  else skip;
  const admin_count = Set.size(storage.admins);
  if (admin_count = 1n) then failwith("You cannot remove the last admin")
  else skip;
  storage.admins := Set.remove(admin, storage.admins)
} with storage

function main (const action : parameter; const storage : storage) : return is
  case action of
    | Vote(params) -> ((nil : list(operation)), addVote(params, storage))
    | AddAdmin(params) -> ((nil : list(operation)), addAdmin(params, storage))
    | RemoveAdmin(params) -> ((nil : list(operation)), removeAdmin(params, storage))
  end