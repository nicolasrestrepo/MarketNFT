async function deployMarket(){
    // ether is in the context
    const [deployer] = await ethers.getSigners();

    console.log('Deploying contract with the account', deployer.address);

    // get info from compilation cache
    const MarketNFT = await ethers.getContractFactory("Market");

    const deployed = await MarketNFT.deploy(5000);

    console.log('MarketNFT is deployed at:', deployed.address);
}

deployMarket()
    .then(() => process.exit(0))
    .catch((error) => {
        console.log('error', error);
        process.exit(1);
    })