import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "ethers";

const func: DeployFunction = async ({ deployments, ethers }: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;

  const accounts = await ethers.getSigners();
  const deployer = accounts[0];

  const wasteManagement = await deploy("WasteManagement", {
    contract: "WasteManagement",
    from: deployer.address,
    args: [],
    log: true,
    autoMine: true,
  });
};

export default func;
