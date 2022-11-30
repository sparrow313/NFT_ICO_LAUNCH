// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    uint256 public constant tokenPrice = 0.001 ether;

    uint256 public constant tokenPerNFT = 10 * 10 ** 18;

    uint256 public constant maxTotalSupply = 10000 * 10 ** 18;

    ICryptoDevs CryptoDevNFT;

    mapping(uint256 => bool) tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("CryptoDevToken", "CD") {
        CryptoDevNFT = ICryptoDevs(_cryptoDevsContract);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = amount * tokenPrice;
        require(
            msg.value <= _requiredAmount,
            "Insufficient amount of ether sent"
        );

        uint256 amountwithdecimals = amount * 10 ** 18;

        require(
            totalSupply() + amountwithdecimals <= maxTotalSupply,
            "Exceeding total supply"
        );

        _mint(msg.sender, amountwithdecimals);
    }

    function claim() public {
        address sender = msg.sender;
        uint256 balance = CryptoDevNFT.balanceOf(sender);
        require(balance > 0, "You dont own any Crypto Dev NFT's");
        uint256 amount = 0;

        for (uint256 i = 0; i > balance; i++) {
            uint256 tokenIds = CryptoDevNFT.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenIds]) amount += 1;
            tokenIdsClaimed[tokenIds] = true;
        }

        require(amount > 0, "You have claimed all the crypto Tokens");
        _mint(msg.sender, amount * tokenPerNFT);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "no available ether");

        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {}

    fallback() external payable {}
}
