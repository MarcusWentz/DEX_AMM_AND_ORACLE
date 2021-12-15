pragma solidity ^0.8.7;

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeedOil;
    AggregatorV3Interface internal priceFeedGold;
    AggregatorV3Interface internal priceFeedSilver;
    AggregatorV3Interface internal priceFeedETH;

    
    //Rinkeby prices test: https://docs.chain.link/docs/ethereum-addresses/
    constructor() public {
        priceFeedOil = AggregatorV3Interface(0x6292aA9a6650aE14fbf974E5029f36F95a1848Fd);
        priceFeedGold = AggregatorV3Interface(0x81570059A0cb83888f1459Ec66Aad1Ac16730243);
        priceFeedSilver = AggregatorV3Interface(0x9c1946428f4f159dB4889aA6B218833f467e1BfD);
        priceFeedETH =  AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);           
    }

    function getLatestOilPrice() public view returns (int) {
        (
            uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound
        ) = priceFeedOil.latestRoundData();
        return (price);
    }
    function getLatestGoldPrice() public view returns (int) {
        (
            uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound
        ) = priceFeedGold.latestRoundData();
        return (price);
    }
    function getLatestSilverPrice() public view returns (int) {
        (
            uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound
        ) = priceFeedSilver.latestRoundData();
        return (price);
    }
    function getLatestETHPrice() public view returns (int) {
        (
            uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound
        ) = priceFeedETH.latestRoundData();
        return (price);
    }
    
}
