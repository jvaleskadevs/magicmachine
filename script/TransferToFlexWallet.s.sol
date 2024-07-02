// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFT721} from "../src/utils/NFT721.sol";
import {MagicMachine} from "../src/MagicMachine.sol";
import {NFT1155} from "../src/utils/NFT1155.sol";

contract TransferScript is Script {
    function setUp() public {
    
    }

    function run() public {
        // dinos
        address nftAddressZora = address(0x6b415D22147bf761f72cD979f8b2C0b67E0978bF);
        //address nftAddress = address(0x5B88F2b1E3c6938e30f6B503EeD0F00C4eE1DCCd);
        
        address deployer = address(0x26281BB0b775A59Db0538b555f161E8F364fd21e);
        address flex = address(0xdcF2188aCbbD2265E6583263b398dd25d4c41295);

        //NFT nft = NFT(nftAddress);
        NFT1155 dinos = NFT1155(nftAddressZora);
        uint totalNfts = 21;
    
        vm.startBroadcast(vm.envUint("PK"));

        dinos.safeTransferFrom(deployer, flex, 1, totalNfts, "");        
    }
}
