import { ethers } from "hardhat";
import { amoy } from "./utils/config";

async function main() {

  function sleep(secs: number) {
    return new Promise((resolve) => setTimeout(resolve, secs * 1000));
  }

  // async function board(_router: string, poolId: string, underlyingToken: string, tokenName: string, tokenSymbol: string) {
  //   try {
  //     const router = await ethers.getContractAt("Router", _router);
  //     const routerResp = await router.board(poolId, underlyingToken, tokenName, tokenSymbol);
  //     const resp = await routerResp.wait();
  //     console.log("resp: ", resp)
  //   } catch (error) {
  //     console.log("error: ", error)
  //   }
  // }

  // amoy
  // const routerAddress = "0x2c6b298c148A4DB392f7569a50919508d38752BE";
  // const poolAddress = "0x49f238024463d0ae977c2710eF639C523E74960d";

  // Sepolia
  const routerAddress = "0x12D783173e64Da89A24D916d86217FF0cBEe680C";
  const poolAddress = "0x4Fe6be720124579d88Ec59c740FF2bd46eEE9ad1";

  // TESTNET
  const wallet = new ethers.Wallet(process.env.ADMIN2_PRIVATE_KEY!);
  const account = wallet.address;
  // sepolia
  const underlyingToken = "0xD2F2F9680C94177c5a2cC3c5bc5c33d24bC33c57";
  const qpContract = "0xF39cC9C3A28247E75147CC502F711e31Ce8CdD4F"
  // amoy
  // const underlyingToken = "0x35EE288d7CD66C272d620cB31eA7FB0fc7101BD5";
  // const qpContract = "0x9407CAd400B89B66e8712Df779aaDb6994D482D3"

  // LOCALHOST  
  // const account = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
  // const underlyingToken = "0xD2F2F9680C94177c5a2cC3c5bc5c33d24bC33c57";
  // await deployUnderlying("Tether USD", "USDT");

  // await deployMiddleware("0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7", 1, "0xa9Ff76948c88880dfe8FaFC6F893744DC856BD91");

  // await createPool(routerAddress, "222222", underlyingToken, "Supply USDT", "sUSDT");
  // await sleep(15);
  // await getPool("111111", poolAddress);
  // await getUserPoolData("0x85db92aD7a03727063D58846617C977B3Aaa3036", poolAddress);

  // await approve(underlyingToken, routerAddress, "1000");
  // await getBalances(underlyingToken, account, routerAddress);
  // await approve(underlyingToken, qpContract, "1000");
  // await getBalances(underlyingToken, account, qpContract);

  // await supply(routerAddress, "111111", "10");
  // await supplyPool(account, "111111", "1");

  // await deploySpaceLeapPay();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1; 
});
