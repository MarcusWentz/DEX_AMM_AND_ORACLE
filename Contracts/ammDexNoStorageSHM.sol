// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{

    address immutable Owner;

    constructor() ERC20("Token","TKN") {
        Owner = msg.sender;
        _mint(Owner,(1)*(10**18) );
    }

}

contract ERC20TokenContract is ERC20('Token', 'TKN') {}

contract swapMsgValueAndToken {

    uint public immutable constantProduct = 16; //Immutable does not use storage slot to save gas for uint at address variables here.
    address public immutable Owner;

    ERC20TokenContract tokenObject;


    constructor(address _token) {
        Owner = msg.sender;
        tokenObject = ERC20TokenContract(_token); //ERC20 token address goes here.
    }

    modifier senderIsOwner () {
        require(Owner == msg.sender, "Only the Owner can access this function.");
        _;
    }

    modifier poolExists() {
        require(poolSHMBalance()*poolLinkBalance() > 0 , "Pool does not exist yet.");
        _;
    }

    modifier poolEmpty() {
        require(poolSHMBalance()*poolLinkBalance() == 0 , "Pool exists already.");
        _;
    }

    modifier validDeposit(uint linkDeposit) {
        require(msg.value*linkDeposit == constantProduct, "SHM*Link must match constant product!");
        _;
    }

    modifier balancedSwapSHMforLink() {
        require(poolSHMBalance()*(poolLinkBalance()-linkToReceiveSHMReceived()) == constantProduct, "SHM deposit will not balance pool!"); //msg.value updates balance before payable modifier
        _;
    }

    modifier balancedSwapLinkforSHM(uint payLink) {
        require((poolLinkBalance()+payLink)*(poolSHMBalance()-SHMToReceive(payLink)) == constantProduct, "Link deposit will not balance pool!.");
        _;
    }

    function createSHMLinkPool(uint linkDeposit) public payable senderIsOwner poolEmpty validDeposit(linkDeposit) {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(Owner, address(this), linkDeposit);
    }

    function ownerWithdrawPool() public senderIsOwner poolExists  {
        tokenObject.transfer(Owner, poolLinkBalance());
        payable(Owner).transfer(address(this).balance);
    }

    function swapSHMforLINK() public payable poolExists balancedSwapSHMforLink {
        tokenObject.transfer(msg.sender, linkToReceiveSHMReceived() );
    }

    function swapLINKforSHM(uint payLink) public poolExists balancedSwapLinkforSHM(payLink) {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND LINK FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(msg.sender, address(this),  payLink );
        payable(msg.sender).transfer(SHMToReceiveLinkReceived());
    }

    function poolSHMBalance() public view returns(uint)  {
        return address(this).balance;
    }

    function poolLinkBalance() public view returns(uint)  {
        return tokenObject.balanceOf(address(this));
    }

    function SHMToReceive(uint payLink) public view returns(uint)  {
        return poolSHMBalance()-(constantProduct)/(poolLinkBalance()+payLink);
    }

    function SHMToReceiveLinkReceived() public view returns(uint)  {
        return poolSHMBalance()-(constantProduct/((poolLinkBalance())) ) ;
    }

    function linkToReceive(uint paySHM) public view returns(uint)  {
        return poolLinkBalance()-(constantProduct)/(poolSHMBalance()+paySHM);
    }

    function linkToReceiveSHMReceived() public view returns(uint)  {
        return poolLinkBalance()-(constantProduct/((poolSHMBalance())) ) ;
    }

}
