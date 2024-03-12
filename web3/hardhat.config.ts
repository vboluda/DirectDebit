import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

const DUMMY_PK:string     = "0x0000000000000000000000000000000000000000000000000000000000000000";
console.log("PK "+ process.env.DEV_PK_MUMBAI);

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {version: "0.8.20"}
    ]
  },
  paths: {
    deploy: 'deploy',
    deployments: 'deployments',
    imports: 'imports'
  },
  namedAccounts: {
    deployer: {
        default: 0, 
        137: 0, 
        80001: 0, 
    }
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
  },
  etherscan: {
    apiKey: "4XEX8ASQ6CQXE44V4VQSSC2CV34CWE3XPK",
  },
  networks: {
    hardhat: {
      chainId: 1337,
      live:false,
      blockGasLimit:10000000000,
      jackpot:{
        STO_NAME:"TEST001",
        STO_SYMBOL:"T001",
        INITIAL_SUPPLY:"1000000000000000000000000", //1M
        VRF_COORDINATOR:"0x0000000000000000000000000000000000000000",
        VRF_SUBSCRIPTION_ID:10,
        VRF_KEY_HASH:"0x1111111111111111111111111111111111111111111111111111111111111111",
        VRF_AUTO_ADD:false,
        REQUEST_CONFIRMARTIONS:3,
        CALL_BACK_GAS_LIMIT:100000,
        TREASURY_ADDRESS: "DEPLOY",
        TREASURY_FEE:500,
        BET_AMOUNT: "0050000000000000000",
        PRIZE_MULT0: 50,
        PRIZE_MULT1: 5,
        BONUS_AMOUNT:"0010000000000000000",
        VERIFY:false
      }
    },
    mumbai: {
      url: "https://rpc.ankr.com/polygon_mumbai",
      accounts: [`0xeaed8e9bd2f74af2a294e19184cc98e23a2db445f354b174383743c55297b3db`],
      chainId: 80001,
      jackpot:{
        STO_NAME:"TEST001",
        STO_SYMBOL:"T001",
        INITIAL_SUPPLY:"1000000000000000000000000", //1M
        VRF_COORDINATOR:"0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed",
        VRF_SUBSCRIPTION_ID:848,
        VRF_KEY_HASH:"0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f",
        VRF_AUTO_ADD:true,
        REQUEST_CONFIRMARTIONS:3,
        CALL_BACK_GAS_LIMIT:100000,
        TREASURY_ADDRESS: "DEPLOY",
        TREASURY_FEE:500,
        BET_AMOUNT: "0050000000000000000",
        PRIZE_MULT0: 50,
        PRIZE_MULT1: 5,
        BONUS_AMOUNT:"0010000000000000000",
        VERIFY:true,
        GENERATE:true
      }
    },  
  }
};

export default config;
