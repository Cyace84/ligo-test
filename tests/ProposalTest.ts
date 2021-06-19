import { strictEqual, rejects} from "assert";
import { Tezos, Tezos2, deployedContract} from "../client";

async function awaitProposal (contract, before) {
    do {
        let storage = await contract.storage();
        var id_count = storage.id_count.toNumber();
     } while (before ===  id_count )
}

describe('Proposal block test', async function(){
    const testContract =  deployedContract;
    let contract;
    let contract2;
    
    before(async function () {
        contract = await Tezos.contract.at(testContract);
        contract2 = await Tezos2.contract.at(testContract);
    });

    it('Prevents non-admins from creating new proposal', async function () {
        await rejects(
            contract2.methods.newProposal("11").send(),
            (err) => {
                strictEqual(err.message, "This method is for administrators only");
                return true
            }
        );
    });

    it('Prevents the creation of an proposal with a zero period', async function () {
        await rejects(
            contract.methods.newProposal("0").send(),
            (err) => {
                strictEqual(err.message, "The voting period cannot be 0 day");
                return true
            }
        );
    });

    it('Successfully creates a new proposal', async function () {
        var proposalPeriod = 30;
        let storage = await contract.storage();
        let beforeProposalCount = storage.id_count.toNumber();
      
        await contract.methods.newProposal(proposalPeriod).send();
        await awaitProposal(contract, beforeProposalCount);

        storage = await contract.storage();
        let afterProposalCount = await storage.id_count.toNumber();

        strictEqual(beforeProposalCount, afterProposalCount-1)
    });
});
export {}