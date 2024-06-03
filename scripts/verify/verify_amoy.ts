import { run } from "hardhat";
import { amoy } from "../utils/config";
const { expect } = require('chai');
import path from "path";
import { sleep } from "../utils/helpers";

async function main() {

    const pathToDeploymentOutputParameters = path.join(__dirname, '../../deployments/amoy/output.json');
    const deploymentOutputParameters = require(pathToDeploymentOutputParameters);

    try {
        await run(
            'verify:verify',
            {
                address: deploymentOutputParameters.router,
                constructorArguments: [
                    amoy.router_address,
                    amoy.link_address,
                    amoy.chainSelector,
                    amoy.chainId
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
                address: deploymentOutputParameters.TranzitPass
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