import { WasteManagement } from "../typechain";
import { ethers } from "hardhat";

async function main() {
  const wasteMangement = await ethers.getContract("WasteManagement");

  const accounts = await ethers.getSigners();
  const owner = accounts[0];
}

main().catch((error) => {
  console.log("error = ", error);
  process.exitCode = 1;
});
