const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("InfoBoardAuction", function () {
  it("InfoBoardAuction Contract ", async function () {
    const Greeter = await ethers.getContractFactory("InfoBoardAuction");
    const greeter = await Greeter.deploy();
    await greeter.deployed();

  });
});
