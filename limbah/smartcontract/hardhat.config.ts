import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
  },
  paths: {
    deployments: "./deployments",
  },
  typechain: {
    outDir: "./typechain",
    target: "ethers-v6",
  },
};

export default config;
