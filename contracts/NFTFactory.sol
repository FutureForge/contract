// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NFTBase} from "./NFTBase.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract NFTFactory {
    address public immutable implementationAddress;
    mapping(address => address[]) public UserNFTs;

    event NFTContractDeployed(address indexed user, address nftContract);

    constructor() {
        implementationAddress = address(new NFTBase("Base", "BASE", 0));
    }

    function createNFTContract(string memory _name, string memory _symbol, uint256 _initialSupply) external {
        address clone = Clones.clone(implementationAddress);
        NFTBase(clone).initialize(_name, _symbol, _initialSupply, msg.sender);

        UserNFTs[msg.sender].push(clone);

        emit NFTContractDeployed(msg.sender, clone);
    }
}
