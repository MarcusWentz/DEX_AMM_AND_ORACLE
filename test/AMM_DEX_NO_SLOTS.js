const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Tests:", function () {

      let ERC20;
      let ERC20Deployed;
      let Contract;
      let ContractDeployed;
      let owner;
      let addr1;
      let addr2;
      let addrs;

      beforeEach(async function () {
        ERC20 = await ethers.getContractFactory("Token");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        ERC20Deployed = await ERC20.deploy();
        Contract = await ethers.getContractFactory("swapMsgValueAndToken");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        ContractDeployed = await Contract.deploy(ERC20Deployed.address);
      });

      describe("Constructor", function () {
          it("poolMatic == 0", async function () {
            poolMatic = await ContractDeployed.poolMaticBalance();
            expect(poolMatic == 0)
          });
          it("poolLink == 0", async function () {
            poolLink = await ContractDeployed.poolLinkBalance();
            expect(poolLink == 0)
          });
       });

       describe("createMaticLinkPool", function () {
           it("not owner", async function () {
             await expect(
               ContractDeployed.connect(addr1).createMaticLinkPool(4 , {value: 4})
                  ).to.be.revertedWith("Only the Owner can access this function.");
           });
           it("pool created", async function () {
             await ERC20Deployed.approve(ContractDeployed.address,4)
             await ContractDeployed.createMaticLinkPool(4 , {value: 4});
             poolMatic = await ContractDeployed.poolMaticBalance();
             poolLink = await ContractDeployed.poolLinkBalance();
             expect(poolMatic*poolLink == ContractDeployed.constantProduct())
           });
           it("pool already created", async function () {
             await ERC20Deployed.approve(ContractDeployed.address,4)
             await ContractDeployed.createMaticLinkPool(4 , {value: 4});
             await expect(
               ContractDeployed.createMaticLinkPool(4 , {value: 4})
             ).to.be.revertedWith("Pool exists already.");           });
           it("constant product not matched", async function () {
             await ERC20Deployed.approve(ContractDeployed.address,4)
             await expect(
               ContractDeployed.createMaticLinkPool(4 , {value: 1})
                  ).to.be.revertedWith("Matic*Link must match constant product!");
           });
        });

        describe("ownerWithdrawPool", function () {
            it("not owner", async function () {
              await expect(
                ContractDeployed.connect(addr1).ownerWithdrawPool()
                   ).to.be.revertedWith("Only the Owner can access this function.");
            });
            it("pool must exist", async function () {
              await expect(
                ContractDeployed.ownerWithdrawPool()
                   ).to.be.revertedWith("Pool does not exist yet.");
            });
            it("constant product not matched", async function () {
              await ERC20Deployed.approve(ContractDeployed.address,4)
              await ContractDeployed.createMaticLinkPool(4 , {value: 4});
              await ContractDeployed.ownerWithdrawPool()
              poolMatic = await ContractDeployed.poolMaticBalance();
              poolLink = await ContractDeployed.poolLinkBalance();
              expect(poolMatic*poolLink == 0)
            });
         });

         describe("swapMATICforLINK", function () {
           it("pool must exist", async function () {
             await expect(
               ContractDeployed.swapMATICforLINK({value: 4})
                  ).to.be.revertedWith("Pool does not exist yet.");
           });
           it("unbalanced swap", async function () {
             await ERC20Deployed.approve(ContractDeployed.address,4)
             await ContractDeployed.createMaticLinkPool(4 , {value: 4});
             await expect(
               ContractDeployed.connect(addr1).swapMATICforLINK({value: 3})
             ).to.be.revertedWith("Matic deposit will not balance pool!");
           });
           it("valid swap", async function () {
             await ERC20Deployed.approve(ContractDeployed.address,4)
             await ContractDeployed.createMaticLinkPool(4 , {value: 4});
             linkToReceive = await ContractDeployed.linkToReceive(4);
             expect(linkToReceive == 2)
             await ContractDeployed.connect(addr1).swapMATICforLINK({value: 4})
             poolMatic = await ContractDeployed.poolMaticBalance();
             poolLink = await ContractDeployed.poolLinkBalance();
             expect(poolMatic*poolLink == ContractDeployed.constantProduct())
           });
          });

          describe("swapLINKforMATIC", function () {
            it("pool must exist", async function () {
              await expect(
                ContractDeployed.swapLINKforMATIC(4)
                   ).to.be.revertedWith("Pool does not exist yet.");
            });
            it("valid two swaps", async function () {
              await ERC20Deployed.approve(ContractDeployed.address,4)
              await ContractDeployed.createMaticLinkPool(4 , {value: 4});
              await ContractDeployed.connect(addr1).swapMATICforLINK({value: 4})
              //Next swap.
              await ERC20Deployed.connect(addr1).approve(ContractDeployed.address,2)
              await ContractDeployed.connect(addr1).swapLINKforMATIC(2)
              poolMatic = await ContractDeployed.poolMaticBalance();
              poolLink = await ContractDeployed.poolLinkBalance();
              expect(poolMatic*poolLink == ContractDeployed.constantProduct())
            });
            it("unbalanced swap", async function () {
              await ERC20Deployed.approve(ContractDeployed.address,4)
              await ContractDeployed.createMaticLinkPool(4 , {value: 4});
              await ContractDeployed.connect(addr1).swapMATICforLINK({value: 4})
              //Next swap.
              await ERC20Deployed.connect(addr1).approve(ContractDeployed.address,1)
              await expect(
                ContractDeployed.connect(addr1).swapLINKforMATIC(1)
              ).to.be.revertedWith("Link deposit will not balance pool!");
            });
           });
});
