import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async ({
  deployments,
  ethers,
}: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;

  const accounts = await ethers.getSigners();
  const deployer = accounts[0];

  const book = await deploy("Book", {
    contract: "Book",
    from: deployer.address,
    args: [],
    log: true,
    autoMine: true,
  });
};

func.tags = ["BookDeploy"];

export default func;
