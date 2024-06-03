import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    amoy: {
      url: process.env.POLYGON_AMOY_RPC_URL,
      accounts: [`0x${process.env.ADMIN_PRIVATE_KEY}`]
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [`0x${process.env.ADMIN_PRIVATE_KEY}`]
    },
    avalancheFuji: {
      url: process.env.AVALNCHE_FUJI_RPC_URL,
      accounts: [`0x${process.env.ADMIN_PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: {
      amoy: `${process.env.POLYGONSCAN_API_KEY}`,
      sepolia: `${process.env.ETHERSCAN_API_KEY}`,
      zkevmTestnet: `${process.env.POLYGONSCAN_ZKEVM_API_KEY}`,
    },
  },
  defaultNetwork: "amoy"
};

export default config;
