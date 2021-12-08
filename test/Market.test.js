const { expect } = require("chai");

describe("Market Contract", function () {

  const setup = async ({ maxSupply = 10000}) => {
    const [owner] = await ethers.getSigners();

    const MarketNFT = await ethers.getContractFactory("Market");

    const deployed = await MarketNFT.deploy(maxSupply);

    return {
      owner,
      deployed
    }
  }

  describe("Deployment", async () => {
    it("set max supply to passed param", async () => {
      const maxSupply = 4000;

      const { deployed } = await setup({ maxSupply });

      const returnedMaxSupply = await deployed.maxSupply();

      expect(maxSupply).to.equal(returnedMaxSupply);

    });
  });

  describe("Minting", async () => {
    it("Mint a new token and assingns it to owner", async () => {
      const { owner, deployed } = await setup({});

      await deployed.mint();

      const ownerOfMinted = await deployed.ownerOf(0);

      expect(ownerOfMinted).to.equal(owner.address);

    });

    it("Has a minting limit", async () => {
      const maxSupply = 2;

      const { deployed } = await setup({ maxSupply });
      // mint
      await Promise.all([deployed.mint(), deployed.mint()]);

      await expect(deployed.mint()).to.be.revertedWith('No more NFT availables');
    });
  })

  describe("tokenURI",  () => {
    it("returns valid metadata", async () => {
        const { deployed } = await setup({});

        await deployed.mint();
  
        const tokenURI = await deployed.tokenURI(0);
  
        const stringifiedTokenURI = await tokenURI.toString();
  
        const [_, base64JSON] = stringifiedTokenURI.split(
          "data:application/json;base64"
        );
  
        const stringifiedMetadata = await Buffer.from(
          base64JSON, "base64")
          .toString('ascii');
        
        const metadata = JSON.parse(stringifiedMetadata);
  
        expect(metadata).to.have.all.keys("name", "description", "image");
    })
  })
});
