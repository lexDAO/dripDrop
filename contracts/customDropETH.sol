pragma solidity ^0.6.0;

contract DropETH {

    function dropETH(uint256[] memory amounts, address payable[] memory recipients) public payable {
        require(amounts.length == recipients.length);
        require(amounts.length <= 50);

        for (uint256 i = 0; i < amounts.length; i++) {
	        for (uint256 j = 0; j < amounts.length; j++) {
	            recipients[i].transfer(amounts[j]);
	        }
        }
    }
}
