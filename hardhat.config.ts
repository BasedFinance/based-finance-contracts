import {HardhatUserConfig} from 'hardhat/types';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-deploy-fake-erc20';
import '@nomiclabs/hardhat-etherscan';
import 'dotenv/config';

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: '0.8.7',
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
            //url: 'https://rpc.testnet.fantom.network/',
            url: 'https://rpc.ftm.tools/',
            accounts: [`${process.env.METAMASK_KEY}`],
            // gasMultiplier: 2,
        },
        rinkeby: {
            url: 'https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
            accounts: [`${process.env.METAMASK_KEY}`],
        },
    },
    etherscan: {
        // Your API key for Etherscan
        // Obtain one at https://etherscan.io/
        apiKey: {
            opera: 'Q74P6QA4NBURP6CA8V4DGFGBPGQ6JPG5WM',
            rinkeby: 'XFAGSFB6UXE9MFTA9AHJMGHMXI8IXRVCHW',
        },
    },
};

export default config;
