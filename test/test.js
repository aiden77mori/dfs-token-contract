const { expect } = require("chai");
const { ethers } = require("hardhat");

let owner;
let user;
let anotherUser;

let mytoken;
let initialOwnerBalance;
let afterOwnerBalance;
let anotherUserBalance;

beforeEach(async function () {
  [owner, user, anotherUser] = await ethers.getSigners();
});

describe("Deployment", function () {
  it("Deployment should assign the total supply of tokens to the owner", async function () {
    const MyToken = await ethers.getContractFactory("DifinesToken");
    mytoken = await MyToken.deploy();
  });

  it("Should set the right owner", async function () {
    console.log(owner.address);
    console.log(await mytoken.getOwner());
    expect(await mytoken.getOwner()).to.equal(owner.address);
  });

  it("Check total supply and owner's balance when it is minted at first", async function () {
    initialOwnerBalance = await mytoken.balanceOf(owner.address);
    expect(await mytoken.totalSupply()).to.equal(initialOwnerBalance);
    console.log(initialOwnerBalance);
    // expect(initialOwnerBalance).to.equal(10000000000 * 1e18);
  });
});

describe("Transaction", function () {
  it("Should transfer tokens between accounts", async function () {
    await mytoken.transfer(user.address, 100);
    const userBalance = await mytoken.balanceOf(user.address);

    expect(userBalance).to.equal(100);

    await mytoken.connect(user).transfer(anotherUser.address, 50);
    anotherUserBalance = await mytoken.balanceOf(anotherUser.address);

    expect(anotherUserBalance).to.equal(50);
  });

  it("Should update balances after transfer", async function () {
    afterOwnerBalance = await mytoken.balanceOf(owner.address);

    expect(afterOwnerBalance).to.equal(initialOwnerBalance.sub(100));
  });

  it("Should test approve", async function () {
    // let beforeAnotherUserBalance = await mytoken.balanceOf(anotherUser.address);
    let tx = await mytoken.approve(anotherUser.address, 10);
    await tx.wait();
    console.log("approve tx: ", tx.hash);

    let anotherUserAllow = await mytoken.allowance(
      owner.address,
      anotherUser.address
    );
    expect(anotherUserAllow).to.equal(10);
  });

  it("Should call burn function", async function () {
    await mytoken.burn(1000);
    console.log("bal", await mytoken.balanceOf(owner.address));
    let afterTotalSupply = await mytoken.totalSupply();
    console.log(afterTotalSupply);
  });
});

describe("Transfer Ownership", function () {
  it("transfer onwership test", async function () {
    await mytoken.transferOwnership(user.address);
    console.log(await mytoken.getOwner());
  });
});
