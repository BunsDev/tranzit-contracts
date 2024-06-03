import { ethers } from "hardhat";

async function main() {

    const [signer] = await ethers.getSigners();
    const gasOracleContractAddress = "0x7a3F4723b123b38d7340bF786c902f49a1d57B8e";
    const abi = [
        {
            "inputs": [
                {
                    "components": [
                        {
                            "internalType": "uint32",
                            "name": "remoteDomain",
                            "type": "uint32"
                        },
                        {
                            "internalType": "uint128",
                            "name": "tokenExchangeRate",
                            "type": "uint128"
                        },
                        {
                            "internalType": "uint128",
                            "name": "gasPrice",
                            "type": "uint128"
                        }
                    ],
                    "internalType": "struct StorageGasOracle.RemoteGasDataConfig",
                    "name": "_config",
                    "type": "tuple"
                }
            ],
            "name": "setRemoteGasData",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint32",
                    "name": "_destinationDomain",
                    "type": "uint32"
                }
            ],
            "name": "getExchangeRateAndGasPrice",
            "outputs": [
                {
                    "internalType": "uint128",
                    "name": "tokenExchangeRate",
                    "type": "uint128"
                },
                {
                    "internalType": "uint128",
                    "name": "gasPrice",
                    "type": "uint128"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        }
    ]
    const GasOracleContract = new ethers.Contract(gasOracleContractAddress, abi, signer);
    const data = {
        remoteDomain: 11155111,
        tokenExchangeRate: ethers.parseUnits("10", "gwei"), 
        gasPrice: ethers.parseUnits("0.5", "gwei"),
    };
    const resp = await GasOracleContract.setRemoteGasData(data)
    console.log("Transaction submitted:", resp.hash);
    
    // const resp = await GasOracleContract.getExchangeRateAndGasPrice("11155111")
    console.log("Resp:", resp);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
}); 