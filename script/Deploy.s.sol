// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {NFTFactory} from "../contracts/NFTFactory.sol";

contract Deploy is Script {
    NFTFactory nftContract;

    function run() external {
        vm.startBroadcast();
        nftContract = new NFTFactory(3000);
        vm.stopBroadcast();
        console.log("NFTFactory address at", address(nftContract));
    }
}
