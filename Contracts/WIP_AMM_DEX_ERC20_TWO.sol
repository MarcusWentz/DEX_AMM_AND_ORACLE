// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract swapPoolLinkDai {
    
    address public immutable Owner;
    
    ERC20TokenContract tokenObjectLink = ERC20TokenContract(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //Chainlink contract address on Polygon testnet.
    ERC20TokenContract tokenObjectDai = ERC20TokenContract(0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1); //ERC20 contract address on Polygon testnet.

    constructor() {
        Owner = msg.sender;
    }

    modifier senderIsOwner () {
        require(Owner == msg.sender, "Only the Owner can access this function.");
        _;
    }

    modifier poolExists() {
        require(poolConstantProduct() > 0 , "Pool does not exist yet.");
        _;
    }

    function createMaticLinkPool(uint linkDeposit, uint daiDeposit) public payable senderIsOwner {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        require(poolConstantProduct() == 0, "Pool already created.");
        require(daiDeposit*linkDeposit > 0, "Matic*Link deposit should be greater than 0!");
        tokenObjectLink.transferFrom(Owner, address(this), linkDeposit); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        tokenObjectDai.transferFrom(Owner, address(this), linkDeposit); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    }
    
    function ownerWithdrawPool() public senderIsOwner poolExists  {
        tokenObjectLink.transfer(Owner, poolLinkBalance());
        tokenObjectLink.transfer(Owner, poolDaiBalance());
    }
    
    function swapLINKforDai(uint payLink) public poolExists {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        require(payLink*daiToReceive(payLink) == poolConstantProduct(), "Pool not balanced!");
        uint memoryDaiPayout = daiToReceive(payLink);
        tokenObjectLink.transferFrom(msg.sender, address(this),  payLink ); 
        tokenObjectLink.transferFrom(msg.sender, address(this),  memoryDaiPayout ); 
    }    

    function swapDaiforLink(uint payDai) public poolExists {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        require(payDai*linkToReceive(payDai) == poolConstantProduct(), "Pool not balanced!");
        uint memoryLinkPayout = linkToReceive(payDai);
        tokenObjectLink.transferFrom(msg.sender, address(this),  payDai ); 
        tokenObjectLink.transferFrom(msg.sender, address(this),  memoryLinkPayout ); 
    }   

    function poolLinkBalance() public view returns(uint)  {
        return tokenObjectLink.balanceOf(address(this));
    }

    function poolDaiBalance() public view returns(uint)  {
        return tokenObjectDai.balanceOf(address(this));
    }

    function poolConstantProduct() public view returns(uint)  {
        return poolDaiBalance()*poolLinkBalance();
    }

    function daiToReceive(uint payLink) public view returns(uint)  {
        return (poolDaiBalance()-(poolConstantProduct())/(poolLinkBalance()+ payLink));
    }

    function linkToReceive(uint payDai) public view returns(uint)  {
        return (poolLinkBalance()-(poolConstantProduct())/(poolDaiBalance() + payDai ) ); //msg.value updates balance already. 
    }

    function linkforMaticBalanced(uint payLink) public view returns(bool)  {
        return payLink*daiToReceive(payLink) == poolConstantProduct(); //msg.value updates balance already. 
    }

    function maticforLinkBalanced(uint payDai) public view returns(bool)  {
        return payDai*daiToReceive(payDai) == poolConstantProduct(); //msg.value updates balance already. 
    }

}
