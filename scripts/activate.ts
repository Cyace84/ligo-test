const { tezos, faucets } = require("../client")


const activateFaucets = async () => {
    for (const faucet of faucets) {
        const {pkh, secret} = faucet;
        const operation = await tezos.tz.activate(pkh, secret);
        await operation.confirmation();
    }
}

(async () => {
    await activateFaucets();
})().catch(e => console.error(e));
