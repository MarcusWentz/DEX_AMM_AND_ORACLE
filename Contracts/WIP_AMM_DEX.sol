// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContract is ERC20('Chainlink', 'LINK') {}


contract TruckStopToken is ERC20{ //100 Quattuorvigintillion (10**77) is largest possible supply but not practical for trading [too hard to chart].

    address immutable Owner; // Will add TST to Uniswap pool for trading. Largest supply token at this moment is ELON about 1 Quadrillion (10**15)

    constructor() ERC20("TruckStopToken","TST") { //Fair ICOs like ETH have 80% public sale [We have 82%]. 1 Sextillion tokens (10**21).
        Owner = msg.sender;                                  //Contract deployer is the owner. 
        _mint(Owner,                        (88)*(10**37) ); //Owner will keep 6 but put 82 on Uniswap.
    }
    
}

contract swapPoolMATICLINK {
    
    address public immutable Owner;
    
    //ERC20TokenContract tokenObject = ERC20TokenContract(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); //Chainlink contract address on Polygon testnet.
    ERC20TokenContract tokenObject = ERC20TokenContract(0xd9145CCE52D386f254917e481eB44e9943F39138); //Chainlink contract address on Polygon testnet.
    uint public constantProduct;


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
