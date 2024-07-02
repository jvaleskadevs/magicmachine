// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MagicMachine} from "../src/MagicMachine.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract DepositDinosScript is Script {
    function setUp() public {
    
    }

    function run() public {
        // IGNORE 
        address machineAddress = address(0xB07b0Cf8305D6b40A9d6EfEbA12Ae81C0FfeFed5); // base
        address machineAddressZora = address(0xaAb5272670fa89dA30114A8FbE22324FaC96bEb4); // zora
        
        address dinosZora = address(0x6b415D22147bf761f72cD979f8b2C0b67E0978bF);
        
        MagicMachine mm = MagicMachine(machineAddressZora);
    
        // TOTAL NUMBER OF NFTS TO BE DEPOSITED
    
        uint totalNfts = 21;

        // NFTS ADDRESSES AND TOKEN IDS         
    
        address[] memory addresses = new address[](totalNfts);
        uint[] memory ids = new uint[](totalNfts);      

   
        for (uint i = 0; i < totalNfts; i++) {
            addresses[i] = dinosZora;
            ids[i] = 1;
        }
        
        // transaction starts here
            
        vm.startBroadcast(vm.envUint("PK"));
        
        IERC1155(dinosZora).setApprovalForAll(address(mm), true);
        
        mm.deposit(addresses, ids, true);
    }
}
