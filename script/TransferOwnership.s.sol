// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MagicMachine} from "../src/MagicMachine.sol";

contract TransferOwnershipScript is Script {
    function setUp() public {
    
    }

    function run() public {
        //address machineAddress = address(0xB07b0Cf8305D6b40A9d6EfEbA12Ae81C0FfeFed5); // base
        address machineAddress = address(0xaAb5272670fa89dA30114A8FbE22324FaC96bEb4); // zora
        //address deployer = address(0xA9fD03e154e1B3Cbe88F1b515E7EbDAb2d640b60);
        
        address f = address(0x2D0A6C67dc678E852483924225660ad5a4349335);
    
        MagicMachine mm = MagicMachine(machineAddress);
    
        vm.startBroadcast(vm.envUint("PK"));
        
        mm.transferOwnership(f);
    }
}
