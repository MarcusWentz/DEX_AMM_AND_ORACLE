// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}

contract swapPoolMATICLINK {
    
    address public immutable Owner;
    uint public testValue;
    
    // ERC20TokenContract tokenObject = ERC20TokenContract(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //Chainlink contract address on Polygon testnet.
    ERC20TokenContract tokenObject = ERC20TokenContract(0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1); //ERC20 contract address on Polygon testnet.

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

    function createMaticLinkPool(uint linkDeposit) public payable senderIsOwner {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        require(poolConstantProduct() == 0, "Pool already created.");
        require(msg.value*linkDeposit > 0, "Matic*Link deposit should be greater than 0!");
        tokenObject.transferFrom(Owner, address(this), linkDeposit); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
    }
    
    function ownerWithdrawPool() public senderIsOwner poolExists  {
        tokenObject.transfer(Owner, poolLinkBalance());
        payable(Owner).transfer(address(this).balance);
    }

    function swapMATICforLINK() public payable poolExists {
        require(maticforLinkBalanced(0) );
        tokenObject.transfer(msg.sender, linkToReceive(0) ); 
    }
    
    function swapLINKforMATIC(uint payLink) public poolExists {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        require(payLink*maticToReceive(payLink) == poolConstantProduct(), "Pool not balanced!");
        uint memoryMaticPayout = maticToReceive(payLink);
        tokenObject.transferFrom(msg.sender, address(this),  payLink ); 
        payable(msg.sender).transfer(memoryMaticPayout); 
    }    

    function poolMaticBalance() public view returns(uint)  {
        return address(this).balance;
    }

    function poolLinkBalance() public view returns(uint)  {
        return tokenObject.balanceOf(address(this));
    }

    function poolConstantProduct() public view returns(uint)  {
        return poolMaticBalance()*poolLinkBalance();
    }

    function maticToReceive(uint payLink) public view returns(uint)  {
        return (poolMaticBalance()-(poolConstantProduct())/(poolLinkBalance()+payLink));
    }

    function linkToReceive(uint payMatic) public view returns(uint)  {
        return (poolLinkBalance()-(poolConstantProduct())/(poolMaticBalance()+payMatic ) ); //msg.value updates balance already. 
    }

    function linkforMaticBalanced(uint payLink) public view returns(bool)  {
        return payLink*maticToReceive(payLink) == poolConstantProduct(); //msg.value updates balance already. 
    }

    function maticforLinkBalanced(uint payMatic) public view returns(bool)  {
        return poolMaticBalance()*linkToReceive(0) == poolConstantProduct(); //msg.value updates balance already. 
    }

}
