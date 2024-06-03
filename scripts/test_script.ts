import { ethers } from "hardhat";
// import { polygon } from "./utils/config";
// import path from "path";
// import { writeFile, mkdir } from "fs/promises";
// import { saveDeploymentFile } from "./utils/helpers";

async function main() {

    const testnetBridgeAddress = '0xF6BEEeBB578e214CA9E23B0e9683454Ff88Ed2A7';
    const networkIDPOS = 0;
    const networkIDzkEVM = 1;

    const deployedBridgeAddresses = {
        mumbai: "0x7556ee26E533E1d2a2dd526eA2a000f49B5AF4af",
        zkEVM: "0x979a84F9f8130D2A45E17aE22c2ec35f328A30fB"
    }

    async function deployBridge() {
        const bridge = await ethers.deployContract("PolygonBridgeMiddleware", [testnetBridgeAddress]);
        console.log(bridge.target);
    }

    async function sendBridgeMessage(from:string, to:string, network:number) {
        const bridgeMsg = new ethers.AbiCoder().encode(["string", "uint32", "address"], ["hellooooo", network, to]);
        const bridge = await ethers.getContractAt("PolygonBridgeMiddleware", from);
        const tnx = await bridge.sendBridgeMessage(bridgeMsg, true);
        tnx.wait();
        // console.log(bridgeMsg);
    }

    async function getBridgeMessage(address:string) {
        const bridge = await ethers.getContractAt("PolygonBridgeMiddleware", address);
        const resp = await bridge.bridgeMessage();
        console.log(resp);
    }

    sendBridgeMessage(deployedBridgeAddresses.mumbai, deployedBridgeAddresses.zkEVM, networkIDzkEVM);
    // getBridgeMessage(deployedBridgeAddresses.zkEVM)
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
}); 