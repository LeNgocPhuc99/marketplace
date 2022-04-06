require("@nomiclabs/hardhat-waffle");
const fs = require("fs");

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    //  unused configuration commented out for now
    //  mumbai: {
    //    url: "https://rpc-mumbai.maticvigil.com",
    //    accounts: [process.env.privateKey]
    //  }
  },
  solidity: "0.8.4",
};
