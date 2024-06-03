import { ethers } from "hardhat";
import { amoy } from "../utils/config";
import { saveDeploymentFile } from "../utils/helpers";

async function main() {

  // Deploy router (base/main contract)
  const router = await ethers.deployContract("Router", [
    amoy.router_address,
    amoy.link_address,
    amoy.chainSelector,
    amoy.chainId
  ]);
  await router.waitForDeployment();
  console.log(`Router deployed to ${router.target}`);

  // Deploy liquidity pool token factory contract
  const TranzitPass = await ethers.deployContract("TranzitPass");
  await TranzitPass.waitForDeployment();
  console.log(`TranzitPass deployed to ${TranzitPass.target}`);
  
  await TranzitPass.transferOwnership(router.target);
  console.log(`TranzitPass ownership transfered to pool contract`);

  const output = {
    router: router.target,
    TranzitPass: TranzitPass.target,
  }

  await saveDeploymentFile(output, "amoy");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
