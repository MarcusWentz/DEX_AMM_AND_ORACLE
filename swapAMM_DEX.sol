// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol';

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract swapPoolWEI_LINK{
    
    uint public constantProduct;
    uint public contractWEIBalance;
    uint public contractLINKBalance;
    address public ChainlinkTokenAddressRinkeby = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;
    address payable public LiquidityProviderAddress = payable(0xc1202e7d42655F23097476f6D48006fE56d38d4f);
    
    ERC20TokenContract tokenObject = ERC20TokenContract(ChainlinkTokenAddressRinkeby);
    
    //Debug admin functions use this to check you are the admin. 
    modifier LiquidityProviderAddressCheck() {
        require(msg.sender == 0xc1202e7d42655F23097476f6D48006fE56d38d4f, "Only the Admin at address 0xc1202e7d42655F23097476f6D48006fE56d38d4f can access this function.");
        _;
    }

    //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    function Step1_createPool() public payable LiquidityProviderAddressCheck {
        require(constantProduct == 0, "Pool already created.");
        require(msg.value == 4, "Must have 4 WEI for pool creation!");
        require(tokenObject.balanceOf(address(LiquidityProviderAddress)) >= 4, "Must have 4*10^-18 LINK for pool creation!");
        require(tokenObject.allowance(LiquidityProviderAddress,address(this)) >= 4, "Must allow 4 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(LiquidityProviderAddress, address(this), 4); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        contractWEIBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));
        constantProduct = contractWEIBalance*contractLINKBalance;
    }
    
    function step2_swapWEIforLINK() public payable {
         require(contractLINKBalance == 4 && contractWEIBalance == 4, "Must have 4 WEI and 4 LINK in the contract to do this.");
         require(msg.value == (((constantProduct)/(contractLINKBalance-2))-contractWEIBalance) , "You need to put 4 WEI in the value section to do this."); // 4 WEI from user to contract
         tokenObject.transfer(msg.sender, 2); // 2 LINK from contract to user
         contractWEIBalance = address(this).balance;
         contractLINKBalance = tokenObject.balanceOf(address(this));
    }
    
    //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    function step3_swapLINKforWEI() public {
        require(contractLINKBalance == 2 && contractWEIBalance == 8, "Must have 8 WEI and 2 LINK in the contract to do this.");
        require(tokenObject.balanceOf(address(msg.sender)) >= ((constantProduct)/(contractWEIBalance- 4)) - contractLINKBalance  , "You need at least 2 LINK in your account to do this.");
        require(tokenObject.allowance(msg.sender,address(this)) >= ((constantProduct)/(contractWEIBalance- 4)) - contractLINKBalance  , "Must allow 2 tokens from your wallet in the ERC20 contract!");
        tokenObject.transferFrom(msg.sender, address(this), ((constantProduct)/(contractWEIBalance- 4)) - contractLINKBalance  ); // 2 LINK from user to contract
        payable(msg.sender).transfer(4); // 4 Wei from contract to user
        contractWEIBalance = address(this).balance;
        contractLINKBalance = tokenObject.balanceOf(address(this));
    }    

    function WithdrawAllLINKAndWEI() public LiquidityProviderAddressCheck  {
         payable(LiquidityProviderAddress).transfer(contractWEIBalance);
         tokenObject.transfer(LiquidityProviderAddress, contractLINKBalance);
         constantProduct = 0;
         contractWEIBalance = 0;
         contractLINKBalance = 0;
    }

}
