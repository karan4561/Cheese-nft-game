const { inputToConfig } = require("@ethereum-waffle/compiler");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { isCallTrace } = require("hardhat/internal/hardhat-network/stack-traces/message-trace");

describe("Cheese Game contract", function () {
    let CheeseGame;
    let hardhatToken;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    beforeEach(async function () {
        Game = await ethers.getContractFactory("CheeseGame");
        [owner, addr1, addr2] = await ethers.getSigners();
        hardhatToken = await Game.deploy("Karan","Aditte","Singh");
    });

    describe("Cheese", () =>{
        it("Contract should be deployed", async function(){
            const address = await Game.address;
            expect(address).not.to.equal(0x0);
        })

        it("it should give the name", async function(){ 
            const _name = await hardhatToken.name();
            expect(_name).to.equal("Karan");
            expect(await hardhatToken.symbol()).to.equal("Aditte");
        })

        it("should initiate the first checkpoint", async function(){
            const c = await hardhatToken.getCurrentCheckpoint();

            expect(c.tokenID).to.equal(0);
            expect(c.owner).to.equal(owner.address);
        })

        it("No one should create cheese until deadline is missed", async function(){
            await hardhatToken.connect(addr1).createCheese();

            const c = await hardhatToken.getCurrentCheckpoint();
            
            expect(c.tokenID).to.equal(1);
            expect(c.owner).to.equal(addr1.address);
            console.log(c.lastUsed);

            await hardhatToken.connect(addr2).createCheese();

            const c1 = await hardhatToken.getCurrentCheckpoint();
            
            expect(c1.tokenID).to.equal(2);
            expect(c1.owner).to.equal(addr2.address);
            console.log(c1.lastUsed);

        })
    })

});