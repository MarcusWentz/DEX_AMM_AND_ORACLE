// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{

    address immutable Owner;

    constructor() ERC20("Token","TKN") {
        Owner = msg.sender;
        _mint(Owner,(1000)*(1 ether) );
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
        require(poolSHMBalance()*poolTokenBalance() > 0 , "Pool does not exist yet.");
        _;
    }

    modifier poolEmpty() {
        require(poolSHMBalance()*poolTokenBalance() == 0 , "Pool exists already.");
        _;
    }

    modifier validDeposit(uint TokenDeposit) {
        require(msg.value*TokenDeposit == constantProduct, "SHM*Token must match constant product!");
        _;
    }

    modifier balancedSwapSHMforToken() {
        require(poolSHMBalance()*(poolTokenBalance()-TokenToReceiveSHMReceived()) == constantProduct, "SHM deposit will not balance pool!"); //msg.value updates balance before payable modifier
        _;
    }

    modifier balancedSwapTokenforSHM(uint payToken) {
        require((poolTokenBalance()+payToken)*(poolSHMBalance()-SHMToReceive(payToken)) == constantProduct, "Token deposit will not balance pool!.");
        _;
    }

    function createSHMTokenPool(uint TokenDeposit) public payable senderIsOwner poolEmpty validDeposit(TokenDeposit) {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND Token FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(Owner, address(this), TokenDeposit);
    }

    function ownerWithdrawPool() public senderIsOwner poolExists  {
        tokenObject.transfer(Owner, poolTokenBalance());
        payable(Owner).transfer(address(this).balance);
    }

    function swapSHMforToken() public payable poolExists balancedSwapSHMforToken {
        tokenObject.transfer(msg.sender, TokenToReceiveSHMReceived() );
    }

    function swapTokenforSHM(uint payToken) public poolExists balancedSwapTokenforSHM(payToken) {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND Token FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(msg.sender, address(this),  payToken );
        payable(msg.sender).transfer(SHMToReceiveTokenReceived());
    }

    function poolSHMBalance() public view returns(uint)  {
        return address(this).balance;
    }

    function poolTokenBalance() public view returns(uint)  {
        return tokenObject.balanceOf(address(this));
    }

    function SHMToReceive(uint payToken) public view returns(uint)  {
        return poolSHMBalance()-(constantProduct)/(poolTokenBalance()+payToken);
    }

    function SHMToReceiveTokenReceived() public view returns(uint)  {
        return poolSHMBalance()-(constantProduct/((poolTokenBalance())) ) ;
    }

    function TokenToReceive(uint paySHM) public view returns(uint)  {
        return poolTokenBalance()-(constantProduct)/(poolSHMBalance()+paySHM);
    }

    function TokenToReceiveSHMReceived() public view returns(uint)  {
        return poolTokenBalance()-(constantProduct/((poolSHMBalance())) ) ;
    }

}
