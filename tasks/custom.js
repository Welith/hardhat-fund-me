const { task } = require("hardhat/config")

task("accounts", "Prints list of all accounts", async (taskArg, hre) => {
    const accounts = await hre.ethers.getSigners()

    for (const account of accounts) {
        console.log(`Account address: ${account.address}`)
    }
})

task(
    "block-number",
    "Prints current provider block number",
    async (taskArg, hre) => {
        const providerBlockNumber = await hre.ethers.provider.getBlockNumber()
        console.log(`Current block number: ${providerBlockNumber}`)
    }
)
