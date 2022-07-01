import { expect } from "chai";
import { ethers } from "hardhat";

let contract: any;

beforeEach(async () => {
  const ABT = await ethers.getContractFactory("AccountBoundTokens");
  contract = await ABT.deploy("Account Bound Tokens", "ABT");
  await contract.deployed();
});

const targetAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

describe("Account Bound Tokens", () => {
  it("metadata", async () => {
    expect(await contract.name()).to.equal("Account Bound Tokens");
    expect(await contract.symbol()).to.equal("ABT");
  });

  it("mint a token and burn token", async () => {
    const tokenId = 110;
    const tokenURI = "https://account-bound-token.com/tokens/110";

    const mintAction = await contract.mint(targetAddress, tokenId, tokenURI);
    await mintAction.wait();

    expect(await contract.tokenURI(tokenId)).to.equal(tokenURI);
    expect(await contract.balanceOf(targetAddress)).to.equal(1);

    const burnAction = await contract.burn(tokenId);
    await burnAction.wait();

    expect(await contract.balanceOf(targetAddress)).to.equal(0);
    await expect(contract.tokenURI(tokenId)).to.be.revertedWith(
      "tokenURI: token doesn't exist"
    );
  });
});
