import path from "path";
import { writeFile, mkdir } from "fs/promises";
import { validNetworks } from "./types";

export async function saveDeploymentFile(output: object, network: validNetworks) {
    try {
        const filePath = path.join(__dirname, `../../deployments/${network}/output.json`);
        await mkdir(path.dirname(filePath), { recursive: true })
        await writeFile(filePath, JSON.stringify(output, null, 1));
        console.log(`deployment file written to 'deployments/${network}/output.json'`);
    } catch (error) {
        console.log(error)
    }
}

export async function sleep(secs: number) {
    return new Promise((resolve) => setTimeout(resolve, secs * 1000));
}