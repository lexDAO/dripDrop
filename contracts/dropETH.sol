pragma solidity ^0.6.0;

contract DropETH {

    function dropETH(address payable[] memory recipients) public payable {
        uint256 amount = msg.value / recipients.length;

        for (uint256 i = 0; i < recipients.length; i++) {
	        recipients[i].transfer(amount);
        }
    }
}
