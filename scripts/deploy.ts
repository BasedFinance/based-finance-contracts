// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import {ethers} from 'hardhat';
import 'dotenv/config';

const hre = require('hardhat');
let deployedContractArgs: any;
import {contractArgsMap} from './contractArgs';

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy
    const [deployer] = await ethers.getSigners();

    console.log(`Deploying contracts with the account: ${deployer.address}`);
    const balance = await deployer.getBalance();
    console.log(`Account balance: ${balance.toString()}`);

    // Set contract name and get appropriate args
    let deployedContract: string = 'BasedTombZap';
    let deployNetwork: string = 'fantom';
    deployedContractArgs = contractArgsMap.get(deployedContract);

    const Constract = await ethers.getContractFactory(deployedContract);
    const contract = await Constract.deploy(...deployedContractArgs);
    await contract.deployed();
    console.log(`Token address: ${contract.address}`);

    // 50 sec wait
    let timeFrame: number = 30000;
    console.log(`\n==================================================`);
    console.log(`Wating ${timeFrame / 1000} sec before verification`);
    await new Promise((resolve) => setTimeout(resolve, timeFrame));

    // Verify contract
    await hre.run('verify:verify', {
        address: contract.address,
        constructorArguments: [...deployedContractArgs],
        network: deployNetwork,
        /*apiKey: {
            ftmTestnet: process.env.FTMSCAN_API_KEY,
            rinkeby: process.env.ETHERSCAN_API_KEY,
        },*/
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

export {deployedContractArgs};
