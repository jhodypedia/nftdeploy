require("dotenv").config();
const hre = require("hardhat");

async function main() {
  const price = process.env.MINT_PRICE_WEI;
  const payout = process.env.PAYOUT_ADDRESS;
  const meta = process.env.META_URL;

  const ZombiePants = await hre.ethers.getContractFactory("ZombiePants");
  const contract = await ZombiePants.deploy(price, payout, meta);
  await contract.deployed();

  console.log(`✅ ZombiePants deployed to: ${contract.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
