require("@nomiclabs/hardhat-waffle");
const secret = require("./secret.json");


module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    bsc: {
      url: secret.url,
      accounts: [secret.key],
    },
  },
  solidity: "0.8.4",
};
