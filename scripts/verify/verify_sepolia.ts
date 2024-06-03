import { run } from "hardhat";
import { sepolia } from "../utils/config";
const { expect } = require('chai');
import path from "path";
import { sleep } from "../utils/helpers";

async function main() {

    const pathToDeploymentOutputParameters = path.join(__dirname, '../../deployments/sepolia/output.json');
    const deploymentOutputParameters = require(pathToDeploymentOutputParameters);

    try {
        await run(
            'verify:verify',
            {
                address: deploymentOutputParameters.router,
                constructorArguments: [
                    sepolia.router_address,
                    sepolia.link_address,
                    sepolia.chainSelector,
                    sepolia.chainId,
                    sepolia.subnetId
                ]
            }
        );
    } catch (error: any) {
        console.log(error);
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }

    try {
        await run(
            'verify:verify',
            {
                address: deploymentOutputParameters.pool,
                constructorArguments: [
                    deploymentOutputParameters.router,
                    deploymentOutputParameters.LPTokenFactory
                ]
            }
        );
    } catch (error: any) {
        console.log(error);
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }

    console.log("Sleeping for 10 seconds before resuming verification");
    await sleep(10);

    try {
        await run(
            'verify:verify',
            {
                address: deploymentOutputParameters.SpaceLeapPay,
                constructorArguments: [
                    deploymentOutputParameters.QStoreFactory,
                    deploymentOutputParameters.router,
                    deploymentOutputParameters.pool,
                    sepolia.qPayFee
                ]
            }
        );
    } catch (error: any) {
        console.log(error);
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }    

    try {
        await run(
            'verify:verify',
            {
                address: deploymentOutputParameters.LPTokenFactory,
            }
        );
    } catch (error: any) {
        console.log(error);
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }     

    try {
        await run(
            'verify:verify',
            {
                address: deploymentOutputParameters.QStoreFactory,
            }
        );
    } catch (error: any) {
        console.log(error);
        expect(error.message.toLowerCase().includes('already verified')).to.be.equal(true);
    }


}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });