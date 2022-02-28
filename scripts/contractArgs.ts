/* based contract testnet deploy arguments
 * npx hardhat verify --constructor-args scripts/contractArgs.ts  0x9b19319E9bcFf85D106956096286A554a3C43350 --network fantom
 **/
let acropolisAddr: string = '0x4D06f72DdbA5EDaA240e5cc657553e89c2De7944';
let basedTokenAddr: string = '0x8D7d3409881b51466B483B11Ea1B8A03cdEd89ae';
let tombTokenAddr: string = '0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7';
let bShareTokenAddr: string = '0x49C290Ff692149A4E16611c694fdED42C954ab7a';
let daoFundAddr: string = '0xA0e0F462d66De459711BC721cE1fdCC3D9405831';
let pairAddr: string = '0xaB2ddCBB346327bBDF97120b0dD5eE172a9c8f9E';
let bBondTokenAddr: string = '0xe44184F87041C7976fb55e1e27Cd38d887e4cb6F';
let FTMTokenAddr: string = '0x4e15361fd6b4bb609fa63c81a2be19d873717870';
let basedTombLPPairAddrs: string = '0x56106aade67cf41844d6abaacfd90b05ccf6b1a0';
let bShareFTMLPPairAddrs: string = '0xd529bafd74de2a729211667de69fdf58b614184e';
let poolStartTime: number = 1644415200;
let period: number = 21600;

let contractArgsMap = new Map<string, any[]>([
    ['Acropolis', []],
    ['Based', []],
    ['BasedTombZap', [bShareTokenAddr]],
    ['contracts/BshareFtmZap.sol:BShareFtmZap', [basedTokenAddr]],
    ['BShare', []],
    ['BBond', []],
    ['Treasury', []],
    ['BShareRewardPool', [bShareTokenAddr, daoFundAddr, poolStartTime]],
    ['FtmLpRewardPool', [basedTokenAddr, poolStartTime]],
    ['FtmLpBshareRewardPool', [basedTokenAddr]],
    ['FTMRewardPool', [basedTokenAddr, poolStartTime]],
    ['BasedGenesisRewardPool', [basedTokenAddr, daoFundAddr, poolStartTime]],
    ['Oracle', [pairAddr, period, poolStartTime]],
    ['BasedRewardPool', [basedTokenAddr, poolStartTime]],
    ['BasedTombLpZap', [tombTokenAddr]],
    ['Stater', []],
    ['TaxOffice', ['0x5556B03e542EE4f515ba1A15d9640f0C97AdDe12']],
    ['NNTestToken', ['TEAMTOK', 'TEAMTOK']],
    ['Greeter', ['HOLA!']],
    ['BasedRewardPool', [basedTokenAddr, poolStartTime]],
    ['BShareSwapper', [basedTokenAddr, bBondTokenAddr, bShareTokenAddr, FTMTokenAddr, basedTombLPPairAddrs, bShareFTMLPPairAddrs, daoFundAddr]],
]);

export {contractArgsMap};
