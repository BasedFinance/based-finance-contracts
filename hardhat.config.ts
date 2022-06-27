import {HardhatUserConfig} from 'hardhat/types';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy-fake-erc20';
import '@nomiclabs/hardhat-etherscan';
import 'dotenv/config';
import 'hardhat-deploy';

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: '0.8.9',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 50,
                    },
                },
            },
        ],
    },

    networks: {
        fantom: {
            // url: 'https://rpc.testnet.fantom.network/',
            url: 'https://rpc.ftm.tools/',
            // url: 'https://rpc.fantom.network/',
            // url: 'https://rpc.ankr.com/fantom/',
            accounts: [`${process.env.METAMASK_KEY}`],
            gasPrice: 20000000000,
            gasMultiplier: 2,
        },
        fantomTest: {
            url: 'https://rpc.testnet.fantom.network/',
            accounts: [`${process.env.METAMASK_KEY}`],
            // gasMultiplier: 2,
        },
        rinkeby: {
            url: 'https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
            accounts: [`${process.env.METAMASK_KEY}`],
        },
        avaxfuji: {
            url: 'https://api.avax-test.network/ext/bc/C/rpc',
            accounts: [`${process.env.METAMASK_KEY}`],
        },
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: {
            opera: 'Q74P6QA4NBURP6CA8V4DGFGBPGQ6JPG5WM',
            ftmTestnet: '7EIXPG2UVPYIPNY8IT6MXKEQQWVTWYQD2Y',
            rinkeby: 'XFAGSFB6UXE9MFTA9AHJMGHMXI8IXRVCHW',
            avalancheFujiTestnet: 'WN8CWW97AHIYUBC665Y4HZ4E5V4GUJZR2Y',
        },
    },
};

export default config;
