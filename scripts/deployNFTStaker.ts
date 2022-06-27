import {ethers} from 'hardhat';
import {GodTokenAddress, GodNFTAddress} from './address';

async function main(): Promise<string> {
    const [deployer] = await ethers.getSigners();
    if (deployer === undefined) throw new Error('Deployer is undefined.');

    console.log('Account balance:', (await deployer.getBalance()).toString());

    const NFTStaker = await ethers.getContractFactory('NFTStaker');
    const NFTStaker_Deployed = await NFTStaker.deploy(GodNFTAddress, GodTokenAddress);

    console.log('stakerAddress', NFTStaker_Deployed.address);

    return NFTStaker_Deployed.address;
}

main()
    .then((r: string) => {
        console.log('deployed address:', r);
        return r;
    })
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
