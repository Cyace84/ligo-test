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

type return is list (operation) * storage

// function isAdmin (const admins: set(address)): unit is
//   block {
//     if Set.mem(Tezos.sender, admins) then skip
//     else failwith("This method is for administrators only.")
//   } with unit

function getProposal(const prop_id : id; const s : storage) : proposal is 
case s.proposals[prop_id] of None -> record [
    votes = (map[] : votes);
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
      votes = (map[] : votes);
      votesFor =  0n;
      votesAgainst = 0n;
      end_date = end_date;
    ];

    s.id_count := s.id_count + 1n
  } with s

function addVote (const vote: new_vote; var s: storage) : storage is 
  block {
    const valid_votes = set["for"; "against"];
    if not(Set.mem(vote.1, valid_votes)) then failwith("Invalid vote") 
    else skip;
    if Big_map.mem(vote.0, s.proposals) then skip
    else failwith("Invalid proposal id");

    var proposal : proposal := getProposal(vote.0, s);
    if Tezos.now >= proposal.end_date then failwith("The voting period is over")
    else skip;

    if Map.mem(Tezos.sender, proposal.votes) then failwith("You have already voted for this proposal");
    else skip;

    proposal.votes := Map.add((Tezos.sender: address), vote.1, proposal.votes);
    if vote.1 = "against" then proposal.votesAgainst := proposal.votesAgainst + 1n
    else proposal.votesFor := proposal.votesFor + 1n;
    s.proposals[vote.0] := proposal
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
    | Vote(params) -> ((nil : list(operation)), addVote(params, s))
    | AddAdmin(params) -> ((nil : list(operation)), addAdmin(params, s))
    | RemoveAdmin(params) -> ((nil : list(operation)), removeAdmin(params, s))
    | NewProposal(params) -> ((nil : list(operation)), newProposal(params, s))
    | TransferOwnership(params) -> ((nil : list(operation)), transferContractOwnership(params, s))
  end