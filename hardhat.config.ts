import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
const { MNEMONIC, BASESCAN_API_KEY } = process.env;
console.log('MNEMONIC:', MNEMONIC);
const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    baseSepolia: {
      url: 'https://base-sepolia.g.alchemy.com/v2/Hy5zmgrVw58s4oE8lK7DyWp8iMyMwXNI',
      accounts: {
        mnemonic: "emotion strategy length test adjust staff online check garment oak orbit jump enter note pizza"
      }
    }
  },
  gasReporter: {
    currency: "USD",
    enabled: true,
  },
  etherscan: {
    apiKey: {
      baseSepolia: BASESCAN_API_KEY!,
    },
    customChains: [
      {
        network: 'baseSepolia',
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org"
        },
      }
    ]
  },
  defaultNetwork: 'hardhat',
  
};

export default config;
