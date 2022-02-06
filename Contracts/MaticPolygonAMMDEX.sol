// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract swapPoolMATICLINK{
    
    uint public constantProduct;
    uint public contractMATICBalance;
    uint public contractLINKBalance;
    address public ChainlinkTokenAddressMatic = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressMatic);
    address public immutable Owner;

    constructor() {
        Owner = msg.sender;
    }

    modifier LiquidityProviderAddressCheck() {
        require(Owner == msg.sender, "Only the Owner can access this function.");
        _;
    }

    //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    function Step1_createPool() public payable LiquidityProviderAddressCheck {
        require(constantProduct == 0, "Pool already created.");
        require(msg.value == 4, "Must have 4 MATIC for pool creation!");
        require(tokenObject.balanceOf(address(Owner)) >= 4, "Must have 4*10^-18 LINK for pool creation!");
        require(tokenObject.allowance(Owner,address(this)) >= 4, "Must allow 4 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(Owner, address(this), 4); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        contractMATICBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));
        constantProduct = contractMATICBalance*contractLINKBalance;
    }
    
    function step2_swapMATICforLINK() public payable {
         require(contractLINKBalance == 4 && contractMATICBalance == 4, "Must have 4 MATIC and 4 LINK in the contract to do this.");
         require(msg.value == (((constantProduct)/(contractLINKBalance-2))-contractMATICBalance) , "You need to put 4 MATIC in the value section to do this."); // 4 MATIC from user to contract
         tokenObject.transfer(msg.sender, 2); // 2 LINK from contract to user
         contractMATICBalance = address(this).balance;
         contractLINKBalance = tokenObject.balanceOf(address(this));
    }
    
    //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    function step3_swapLINKforMATIC() public {
        require(contractLINKBalance == 2 && contractMATICBalance == 8, "Must have 8 MATIC and 2 LINK in the contract to do this.");
        require(tokenObject.balanceOf(address(msg.sender)) >= ((constantProduct)/(contractMATICBalance- 4)) - contractLINKBalance  , "You need at least 2 LINK in your account to do this.");
        require(tokenObject.allowance(msg.sender,address(this)) >= ((constantProduct)/(contractMATICBalance- 4)) - contractLINKBalance  , "Must allow 2 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(msg.sender, address(this), ((constantProduct)/(contractMATICBalance- 4)) - contractLINKBalance  ); // 2 LINK from user to contract
        contractMATICBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));
        payable(msg.sender).transfer(4); // 4 MATIC from contract to user
    }    

    function WithdrawAllLINKAndMATIC() public LiquidityProviderAddressCheck  {
         tokenObject.transfer(Owner, contractLINKBalance);
         constantProduct = 0;
         contractMATICBalance = 0;
         contractLINKBalance = 0;
         payable(Owner).transfer(address(this).balance);
    }

}
