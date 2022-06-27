import {ethers} from 'hardhat';

async function main(): Promise<string> {
    const [deployer] = await ethers.getSigners();
    if (deployer === undefined) throw new Error('Deployer is undefined.');

    console.log('Account balance:', (await deployer.getBalance()).toString());

    const _layerZeroEndpoint = '0x0000000000000000000000000000000000000000';
    const maxSupply = 10000;

    const GODNFT = await ethers.getContractFactory('GodNFT');
    const GodNFT_Deployed = await GODNFT.deploy(_layerZeroEndpoint, maxSupply);
    return GodNFT_Deployed.address;
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
