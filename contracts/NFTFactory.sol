// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NFTBase} from "./NFTBase.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract NFTFactory {
    address public immutable implementationAddress;
    mapping(address => address[]) public UserNFTs;
    uint128 public mintFee;

    event NFTContractDeployed(address indexed user, address nftContract);
    event MintFee(uint128 fee);

    constructor(uint128 _mintFee) {
        implementationAddress = address(new NFTBase("Base", "BASE", 0, _mintFee));
        mintFee = _mintFee;
    }

    function createNFTContract(string memory _name, string memory _symbol, uint256 _initialSupply)
        external
        returns (address)
    {
        address clone = Clones.clone(implementationAddress);
        NFTBase(clone).initialize(_name, _symbol, _initialSupply, msg.sender);

        UserNFTs[msg.sender].push(clone);

        emit NFTContractDeployed(msg.sender, clone);
        return clone;
    }

    function setMintFee(uint128 _mintFee) public {
        mintFee = _mintFee;
        emit MintFee(_mintFee);
    }
}
