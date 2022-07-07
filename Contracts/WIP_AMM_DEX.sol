// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Token', 'TKN') {}

contract Token is ERC20{ 

    address immutable Owner; 

    constructor() ERC20("Token","TKN") { 
        Owner = msg.sender;                                  
        _mint(Owner,                        (1)*(10**18) );
    }
    
}

contract swapPoolMATICLINK {
    
    uint public constantProduct;
    address public immutable Owner;
    
    ERC20TokenContract tokenObject = ERC20TokenContract(0xd9145CCE52D386f254917e481eB44e9943F39138); //ERC20 token address goes here.

    constructor() {
        Owner = msg.sender;
    }

    modifier senderIsOwner () {
        require(Owner == msg.sender, "Only the Owner can access this function.");
        _;
    }

    modifier poolExists() {
        require(constantProduct > 0 , "Pool does not exist yet.");
        _;
    }

    function createMaticLinkPool(uint linkDeposit) public payable senderIsOwner {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        require(constantProduct == 0, "Pool already created.");
        require(msg.value*linkDeposit > 0, "Matic*Link deposit should be greater than 0!");
        tokenObject.transferFrom(Owner, address(this), linkDeposit); //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        constantProduct = poolMaticBalance()*poolLinkBalance();
    }
    
    function ownerWithdrawPool() public senderIsOwner poolExists  {
        tokenObject.transfer(Owner, poolLinkBalance());
        constantProduct = 0;
        payable(Owner).transfer(address(this).balance);
    }

    function swapMATICforLINK() public payable poolExists {
        tokenObject.transfer(msg.sender, linkToReceiveMaticReceived() ); 
    }
    
    function swapLINKforMATIC(uint payLink) public poolExists {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(msg.sender, address(this),  payLink ); 
        payable(msg.sender).transfer(maticToReceiveLinkReceived()); 
    }    

    function poolMaticBalance() public view returns(uint)  {
        return address(this).balance;
    }

    function poolLinkBalance() public view returns(uint)  {
        return tokenObject.balanceOf(address(this));
    }

    function maticToReceive(uint payLink) public view returns(uint)  {
        return (poolMaticBalance()-(constantProduct)/(poolLinkBalance()+payLink));
    }

    function maticToReceiveLinkReceived() public view returns(uint)  {
        return poolMaticBalance()-(constantProduct/((poolLinkBalance())) ) ; //msg.value updates balance already. 
    }

    function linkToReceive(uint payMatic) public view returns(uint)  {
        return poolLinkBalance()-(constantProduct)/(poolMaticBalance()+payMatic); //msg.value updates balance already. 
    }

    function linkToReceiveMaticReceived() public view returns(uint)  {
        return poolLinkBalance()-(constantProduct/((poolMaticBalance())) ) ; //msg.value updates balance already. 
    }

}
