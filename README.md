### Notice
The code in this repository is provided **solely for research and educational purposes**.  
It has **not been audited**, so **do not** use it in production wallets or any environment that holds real value.  
Use at your own risk.

---

## Running Tests

```bash
npx hardhat test
```

---

## Gas Report

This project leverages Hardhat’s built-in gas reporter.  
Run your tests with gas reporting enabled like this:

    npx hardhat test

---

## Measuring Real-Time Gas Prices

To display real-time gas prices (and fiat values) you need an API key from a gas-price data provider.  
The sample configuration in this repo uses **CoinMarketCap**.

1. Get an API key from CoinMarketCap: <https://coinmarketcap.com/api/>

2. Create or edit **`.env`** (or **`.env.local`**) and add:

   ```dotenv
   COINMARKETCAP_API_KEY=YOUR_COINMARKETCAP_API_KEY
   REPORT_GAS=true
   ```

3. Ensure `hardhat.config.ts` / `hardhat.config.js` includes:

```js
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
     gasReporter: {
       enabled: true,
       currency: "USD",
       token: "ETH",
       coinmarketcap: process.env.COINMARKETCAP_API_KEY,
       // To use a different provider:
       // gasPriceApi: "https://ethgasstation.info/api/ethgasAPI.json"
     },
     // ...other settings
   };
   ```

---

### References
- CoinMarketCap API: <https://coinmarketcap.com/api/>
- Hardhat Documentation: <https://hardhat.org/>
