pragma solidity ^0.6.0;

contract DropETH { // transfer msg.sender ETH to recipients by weight  per attached drop amount w/ msg.
    event ETHDropped(string indexed message);

    function dropETH(uint256[] memory weights, address payable[] memory recipients, string memory message) public payable {
        require(weights.length == recipients.length);

        uint256 totalAmount = msg.value / 100;
        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = recipients[i].call.value(weights[i] * totalAmount)("");
            require(success, "Transfer failed.");
        }
        emit ETHDropped(message);
    }
}
