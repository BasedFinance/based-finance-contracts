import {expect} from 'chai';
import {deployments, ethers} from 'hardhat';
import {SignerWithAddress} from '@nomiclabs/hardhat-ethers/signers';

describe('NFT test', function () {
    let owner: SignerWithAddress;
    let minter: SignerWithAddress;

    let godToken: any, godNFT: any, NFTStaker: any;

    before(async () => {
        const signers = await ethers.getSigners();
        owner = signers[0];
        minter = signers[1];

        console.log('owner', owner.address);

        let receipt = await deployments.deploy('GODtoken', {
            from: owner.address,
            args: [],
            log: true,
        });
        console.log('receipt.address', receipt.address);
        godToken = await ethers.getContractAt('GODtoken', receipt.address);
        console.log('godToken', godToken.address);

        receipt = await deployments.deploy('GodNFT', {
            from: owner.address,
            args: ['0x0000000000000000000000000000000000000000', 10000],
            log: true,
        });
        godNFT = await ethers.getContractAt('GodNFT', receipt.address);

        receipt = await deployments.deploy('NFTStaker', {
            from: owner.address,
            args: [godNFT.address, godToken.address],
            log: true,
        });
        NFTStaker = await ethers.getContractAt('NFTStaker', receipt.address);
    });
    describe('Deploy contract', async () => {
        it('should be deployed', async () => {});
    });
    describe('Operation', async () => {
        it('Initialize', async () => {
            await godNFT.setManagerAddress(owner.address);
            await godToken.transfer(NFTStaker.address, 10);
            const stakerBalance = await godToken.balanceOf(NFTStaker.address);
            console.log('stakerBalance', stakerBalance);
        });
        it('Mint NFT', async () => {
            await godNFT.mintFor(owner.address);
            await godNFT.mintFor(owner.address);
            await godNFT.mintFor(owner.address);
            await godNFT.mintFor(minter.address);
            await godNFT.mintFor(minter.address);
            await godNFT.mintFor(minter.address);
            await godNFT.mintFor(minter.address);
        });
        it('Stake NFT', async () => {
            await godNFT.setApprovalForAll(NFTStaker.address, true);
            await godNFT.connect(minter).setApprovalForAll(NFTStaker.address, true);
            await NFTStaker.stake([0, 1]);
            await expect(NFTStaker.stake([3, 4])).to.be.revertedWith('not your token');
            await NFTStaker.connect(minter).stake([3, 4, 5]);
            const stakerBalance = await godToken.balanceOf(NFTStaker.address);
            console.log('stakerBalance', stakerBalance);
        });
        it('See Staked NFT', async () => {
            const stakedNFTs1 = await NFTStaker.batchedStakesOfOwner(owner.address, 0, 100);

            const stakedNFTs2 = await NFTStaker.batchedStakesOfOwner(minter.address, 0, 100);

            const tokenList1 = await godNFT.getTokenList(owner.address);
            const tokenList2 = await godNFT.getTokenList(minter.address);
            console.log('tokenList1', tokenList1);
            console.log('stakedNFTs1', stakedNFTs1);

            console.log('tokenList2', tokenList2);
            console.log('stakedNFTs2', stakedNFTs2);
        });
        it('Unstake NFT', async () => {
            await godToken.approve(NFTStaker.address, 2);
            await expect(NFTStaker.unstake(owner.address, [3, 4])).to.be.reverted;
            await NFTStaker.unstake(owner.address, [0, 1]);
            
            await godToken.connect(minter).approve(NFTStaker.address, 3);
            await NFTStaker.connect(minter).unstake(owner.address, [3, 4, 5]);
        });
    });
});
