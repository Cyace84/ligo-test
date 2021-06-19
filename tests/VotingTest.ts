import { strictEqual, rejects} from "assert";
import { deployedContract, Tezos, Tezos2} from "../client";

async function awaitVote (contract, before, proposalId) {
    do {
        let storage = await contract.storage();
        let proposal = await storage.proposals.get(proposalId);
        var votesFor = proposal.votesFor.toNumber()
     } while ( before ===  votesFor )
}


describe('Voting test', async function(){
    const testContract = deployedContract;
    let contract;
    let contract2;
    
    before(async function () {
        contract = await Tezos.contract.at(testContract);
        contract2 = await Tezos2.contract.at(testContract);
    });

    it('Prevents voting with invalid mark', async function () {
        await rejects(
            contract.methods.vote("1", "cool!!!").send(),
            (err) => {
                strictEqual(err.message, "Invalid vote");
                return true
            }
        );
    });

    it('Prevents voting for non-existent proposals', async function () {
        await rejects(
            contract.methods.vote("9999999", "for").send(),
            (err) => {
                strictEqual(err.message, "Invalid proposal id");
                return true
            }
        );
    });

    it('If the voting period has ended the voting should fail', async function () {
        await rejects(
            contract.methods.vote("0", "against").send(),
            (err) => {
                strictEqual(err.message, "The voting period is over");
                return true
            }
        );
    });

    it('Voting is done by sending the transaction with vote option (for or against)', async function () {
        let storage = await contract.storage();
        let proposalId = 1;
        console.log()
        let beforeProposal = await storage.proposals.get(`${proposalId}`);
        let beforeVotesFor = await beforeProposal.votesFor.toNumber();
        await contract.methods.vote(`${proposalId}`, "for").send()
            .catch(async (err) => {
                if (err.message == "You have already voted for this proposal") {
                    do {
                        try {
                            proposalId += 1;
                            beforeProposal = await storage.proposals.get(`${proposalId}`);
                            beforeVotesFor = await beforeProposal.votesFor.toNumber();
                            await contract.methods.vote(`${proposalId}`, "for").send();
                            break;
                        } catch (err) {
                           
                            if (err.message === "Invalid proposal id") {
                                strictEqual(1, 1)
                            };
                        } 
                    } while (true)   
                }
            });
        
        await awaitVote(contract, beforeVotesFor, `${proposalId}`);
        storage = await contract.storage();
        let afterProposal = await storage.proposals.get(`${proposalId}`);
        let afterVotesFor = await afterProposal.votesFor.toNumber();
        
        strictEqual(beforeVotesFor, afterVotesFor - 1)
    
    });
    it('Prevents voting twice for one proposal', async function () {
        await rejects(
            contract.methods.vote("1", "against").send(),
            (err) => {
                strictEqual(err.message, "You have already voted for this proposal");
                return true
            }
        );
    });

});
export {}