import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "dotenv";
import "hardhat-deploy";
import "hardhat-prettier";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
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
