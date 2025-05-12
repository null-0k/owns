require("@nomicfoundation/hardhat-toolbox");
require('hardhat-gas-reporter');
// require("hardhat-contract-sizer");

module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.20",
                settings: {
                    optimizer: { enabled: true, runs: 200 },
                    viaIR: true       
                }
            },
            {
                version: "0.8.6",
                settings: { optimizer: { enabled: true, runs: 200 } }
            }
        ],

        // 特定ファイルだけ IR を有効にしたい場合
        overrides: {
            "contracts/libs/BIP39.sol": {
                version: "0.8.20",
                settings: { optimizer: { enabled: true, runs: 200 }, viaIR: true }
            }
        }
    },
    gasReporter: {
        enabled: true,
        currency: 'USD',
        coinmarketcap: process.env.COINMARKETCAP_API_KEY,
        gasPriceApi: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice&apikey=GUKGW45ZAD123P1EEGG4XG4JAIECQ9CBXC",
    }
};