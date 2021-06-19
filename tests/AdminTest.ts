import { strictEqual, rejects} from "assert";
import { deployedContract, Tezos, Tezos2, faucetB, faucetA} from "../client";

async function awaitNewAdmin(contract, addr) {
    do {
        let storage = await contract.storage();
        var admins = await storage.admins;
     } while ( admins.indexOf(addr) <= -1 )
}

async function awaitRemoveAdmin(contract, addr) {
    do {
        let storage = await contract.storage();
        var admins = await storage.admins;
       
     } while ( admins.indexOf(addr) > -1)
}


describe('Admin test', async function(){
    const testContract = deployedContract;
    const addr = faucetB.pkh
    let contract;
    let contract2;
    
    before(async function () {
        contract = await Tezos.contract.at(testContract);
        contract2 = await Tezos2.contract.at(testContract);
    });


    it('Prevents add admin everyone except the owner', async function () {
        await rejects(
            contract2.methods.addAdmin(addr).send(),
            (err) => {
                strictEqual(err.message, "This method is for the owner only");
                return true
            }
        );
    });

    it('A new administrator is added', async function () {
        let storage = await contract.storage();
        await contract.methods.addAdmin(addr).send();
        await awaitNewAdmin(contract, addr).catch((err)=>{console.log(err)});
        storage = await contract.storage();
        let admins = await storage.admins;
        strictEqual(true, admins.indexOf(addr) > -1)
     });

    it('This address is already an administrator', async function () {
        await rejects(
            contract.methods.addAdmin(addr).send(),
            (err) => {
                strictEqual(err.message, "This address is already an administrator");
                return true
            }
        );
    });

     
    it('Admin is deleted successfully', async function () {
        let storage = await contract.storage();
        await contract.methods.removeAdmin(addr).send();
        await awaitRemoveAdmin(contract, addr);
        storage = await contract.storage();
        let admins = await storage.admins;
        strictEqual(true, admins.indexOf(addr) <= -1)
    });
    
    it('Invalid administrator address', async function () {
        await rejects(
            contract.methods.removeAdmin(addr).send(),
            (err) => {
                strictEqual(err.message, "Invalid administrator address");
                return true
            }
        );
    });
  
});
export {}