// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; //Safemath [math operations without overflow] integrated since solidity 0.8.0 https://soliditydeveloper.com/solidity-0.8

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ERC20TokenContractDAI is ERC20('Dai', 'DAI') {}

contract swapPoolDAI_ETH_Order_Book_Oracle{
    
    AggregatorV3Interface internal priceFeedETH;

    constructor() public {
        priceFeedETH =  AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);           
    }

    function getLatestETHPrice() public view returns (uint) {
    (
        uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeedETH.latestRoundData();
        return uint(price*(10**10));
    }
    
    address public LiquidityProviderAddress = 0xc1202e7d42655F23097476f6D48006fE56d38d4f;
    address public DAI_TokenAddressRinkeby = 0x5592EC0cfb4dbc12D3aB100b257153436a1f0FEa;
    
    ERC20TokenContractDAI tokenDAI = ERC20TokenContractDAI(DAI_TokenAddressRinkeby);
    
    modifier LiquidityProviderAddressCheck() {
        require(msg.sender == LiquidityProviderAddress, "ONLY THE ADMIN CAN DO THIS.");
        _;
    }
    
    //NEED TO APPROVE ERC20 DAI CONTRACT BEFORE YOU CAN SEND DAI!
    function Step1A_Add_DAI_To_Pool() public LiquidityProviderAddressCheck {
        tokenDAI.transferFrom(msg.sender, address(this), 3700*(10**18)); 
    }
    
    function Step1B_SellOneETHforDAI() public payable { //0.2% sell fee
         require(msg.value == 1*(10**18), "NEED 1 ETH FOR 'MSG.VALUE'."); 
         require(tokenDAI.balanceOf(address(this)) >= (getLatestETHPrice()*998)/1000, "YOU NEED AT LEAST (getLatestETHPrice()*998)/1000 DAI IN CONTRACT."); 
         tokenDAI.transfer(msg.sender,  (getLatestETHPrice()*998)/1000 ); 
    }
    
    function Step2A_Add_ETH_To_Pool() public payable LiquidityProviderAddressCheck {
        require(msg.value == 1*(10**18), "NEED 1 ETH FOR 'MSG.VALUE'.");
    }
    
    //NEED TO APPROVE ERC20 DAI CONTRACT BEFORE YOU CAN SEND DAI!
    function Step2B_BuyOneETHwithDAI() public { //0.2% buy fee
        require(address(this).balance >=  1*(10**18) , "NEED 1 ETH AT LEAST IN THE POOL");
        tokenDAI.transferFrom(msg.sender, address(this),  (getLatestETHPrice()*1002)/1000 ); 
        payable(msg.sender).transfer(1*(10**18)); 
    }   
    
    function Step3_LP_Withdraw_All_Funds() public LiquidityProviderAddressCheck {   
         require(tokenDAI.balanceOf(address(this)) + address(this).balance > 0, "ETH OR DAI BALANCE MUST BE GREATER THAN 0 TO WITHDRAW FROM POOL!"); // Optional
         payable(msg.sender).transfer(address(this).balance);
         tokenDAI.transfer(msg.sender, tokenDAI.balanceOf(address(this)) );
    }
}
