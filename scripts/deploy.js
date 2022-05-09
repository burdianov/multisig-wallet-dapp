const { ethers } = require('hardhat');

async function main() {
  [account0, account1, account2] = await ethers.getSigners();

  const MultisigWallet = await ethers.getContractFactory('MultisigWallet');

  wallet = await MultisigWallet.deploy(
    [account0.address, account1.address, account2.address],
    2
  );

  await wallet.deployed();

  await account0.sendTransaction({
    to: wallet.address,
    value: 10000
  });

  console.log('MultisigWallet deployed to:', wallet.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
