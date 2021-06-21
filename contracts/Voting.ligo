type id is nat;
type day is nat;
type proposal_period is day;

type vote is
| For
| Against

type voter is (id * address);
type new_vote is (id * vote)

type parameter is
  | Vote of new_vote
  | AddAdmin of address
  | RemoveAdmin of address
  | NewProposal of proposal_period
  | TransferOwnership of address

type proposal is 
record [
  votesFor: nat;
  votesAgainst: nat;
  end_date: timestamp
]

type storage is 
record [
  owner: address;
  proposals: big_map(id, proposal);
  votes: big_map(voter, vote);
  id_count: nat;
  admins: set(address)
]

type return is list (operation) * storage

// function isAdmin (const admins: set(address)): unit is
//   block {
//     if Set.mem(Tezos.sender, admins) then skip
//     else failwith("This method is for administrators only.")
//   } with unit

function getProposal(const prop_id : id; const s : storage) : proposal is 
case s.proposals[prop_id] of None -> record [
    votesFor =  0n;
    votesAgainst = 0n;
    end_date = ("2000-01-01T10:10:10Z" : timestamp)
]
| Some(proposal) -> proposal
end

function newProposal (const days: day; var s : storage) : storage is
  block {
    if Set.mem(Tezos.sender, s.admins) then skip
    else failwith("This method is for administrators only");
    if days > 0n then skip
    else failwith("The voting period cannot be 0 day");

    const end_date: timestamp = Tezos.now + days * 86_400;
    s.proposals[s.id_count] := record [
      votesFor =  0n;
      votesAgainst = 0n;
      end_date = end_date;
    ];

    s.id_count := s.id_count + 1n
  } with s

function addVote (const prop_id: id; const new_vote: vote; var s: storage) : storage is 
  block {
    if Big_map.mem(prop_id, s.proposals) then skip
    else failwith("Invalid proposal id");

    var proposal : proposal := getProposal(prop_id, s);
    if Tezos.now >= proposal.end_date then failwith("The voting period is over")
    else skip;

    if Map.mem((prop_id, Tezos.sender), s.votes) then failwith("You have already voted for this proposal");
    else skip;

    s.votes := Map.add((prop_id, (Tezos.sender: address)), new_vote, s.votes);
    case new_vote of
        | For -> proposal.votesFor := proposal.votesFor + 1n
        | Against -> proposal.votesAgainst := proposal.votesAgainst + 1n
    end;
    s.proposals[prop_id] := proposal
    } with s

function addAdmin (const admin: address; var s: storage) : storage is
  block {
    if Tezos.sender = s.owner then skip
    else failwith("This method is for the owner only");
    if Set.mem(admin, s.admins) then failwith("This address is already an administrator")
    else skip;
    s.admins := Set.add(admin, s.admins)
} with s

function removeAdmin (const admin: address; var s: storage) : storage is 
  block {
    if (Tezos.sender = s.owner) then skip
    else failwith("This method is for the owner only");
    if not(Set.mem(admin, s.admins)) then failwith("Invalid administrator address")
    else skip;
    s.admins := Set.remove(admin, s.admins)
} with s

function transferContractOwnership (const new_owner: address; var s: storage) : storage is
  block {
    if Tezos.sender = s.owner then skip
    else failwith("This method is for the owner only");
    s.owner := new_owner
  } with s

function main (const action : parameter; const s : storage) : return is
  case action of
    | Vote(params) -> ((nil : list(operation)), addVote(params.0, params.1, s))
    | AddAdmin(params) -> ((nil : list(operation)), addAdmin(params, s))
    | RemoveAdmin(params) -> ((nil : list(operation)), removeAdmin(params, s))
    | NewProposal(params) -> ((nil : list(operation)), newProposal(params, s))
    | TransferOwnership(params) -> ((nil : list(operation)), transferContractOwnership(params, s))
  end