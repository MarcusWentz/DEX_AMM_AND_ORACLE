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

contract BugTesting {

    ERC20TokenContract public tokenObject;

    constructor(address _token) {
        tokenObject = ERC20TokenContract(_token); //ERC20 token address goes here.
    }

    function transferTest() public {
        tokenObject.transfer(msg.sender, 1 ether);
    }

    function transferFromTest() public {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND Token FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(msg.sender, address(this), 1 ether);
    }

    function transferBothTests() public {     //NEED TO APPROVE EVERY TIME BEFORE YOU SEND Token FROM THE ERC20 CONTRACT!
        tokenObject.transferFrom(msg.sender, address(this), 1 ether);
        tokenObject.transfer(msg.sender, 1 ether );
    }

}
