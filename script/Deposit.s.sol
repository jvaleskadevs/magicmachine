// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {MagicMachine} from "../src/MagicMachine.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";

contract DepositScript is Script {
    function setUp() public {
    
    }

    function run() public {
        // IGNORE 
        address machineAddress = address(0xB07b0Cf8305D6b40A9d6EfEbA12Ae81C0FfeFed5); // base
        address machineAddressZora = address(0xaAb5272670fa89dA30114A8FbE22324FaC96bEb4); // zora
        
        MagicMachine mm = MagicMachine(machineAddressZora);
    
        // TOTAL NUMBER OF NFTS TO BE DEPOSITED
    
        uint totalNfts = 15;
    
        address[] memory addresses = new address[](totalNfts);
        uint[] memory ids = new uint[](totalNfts);
            
        
        // NFTS ADDRESSES AND TOKEN IDS         

        addresses[0] = 0x40dd9fc8b5b3d9e239926a4ea6ed2cc3dfadcb84;
        addresses[1] = 0x605ac7331abc154df3f888e4e7ad0a61314a8e3e;
        addresses[2] = 0xc6fcfec90c9ef70915a75d8da426f84ec04f4f3f;
        addresses[3] = 0xd00e15f17533007d914ae802da83e32f18f4856f;
        addresses[4] = 0x44bdad543228941b38325c933f32b8bef1b52f4b;
        addresses[5] = 0x6d6df6718fb6faf5b94bfce2db2d6fb36d1f3c9a;
        addresses[6] = 0x276cbd0d4fd590b777ee4b51853504c60761c9fe;
        addresses[7] = 0x276cbd0d4fd590b777ee4b51853504c60761c9fe;
        addresses[8] = 0x6d6df6718fb6faf5b94bfce2db2d6fb36d1f3c9a;
        addresses[9] = 0x6d6df6718fb6faf5b94bfce2db2d6fb36d1f3c9a;
        addresses[10] = 0x6d6df6718fb6faf5b94bfce2db2d6fb36d1f3c9a;
        addresses[11] = 0xaf613577bb7c74c4da8c7d03a34222ed08032de4;
        addresses[12] = 0xa0710c994af5f724b60d8a3ab9697cfbb31111d6;
        addresses[13] = 0x6d6df6718fb6faf5b94bfce2db2d6fb36d1f3c9a;
        addresses[14] = 0x276cbd0d4fd590b777ee4b51853504c60761c9fe;

        ids[0] = 1;    
        ids[1] = 662;
        ids[2] = 5;    
        ids[3] = 6;
        ids[4] = 2;    
        ids[5] = 269;
        ids[6] = 82;   
        ids[7] = 80;
        ids[8] = 48;   
        ids[9] = 81;
        ids[10] = 292; 
        ids[11] = 9;
        ids[12] = 7;   
        ids[13] = 352;
        ids[14] = 83;
/*      
        addresses[0] = 0x08944A25da2046009b19c9EC5503Bdc8B50B0a6E;
        ids[0] = 1;
       
        addresses[1] = 0x692093a200ed707Dd303C6B21DED0FB24795F75a;
        ids[1] = 1;
        
        addresses[2] = 0xC61965e1B881F194a900FDf266023a43e21f526D;
        ids[2] = 1;
        
        addresses[3] = 0x3F82aF2BDc26201513319b14D741CfB0353eb4a3;
        ids[3] = 4;
        
        addresses[4] = 0xFdb192FB0213d48eCDf580C1821008d8c46bdBd7;
        ids[4] = 1;
        
        addresses[5] = 0x2AD8Eb820B5bdb8fE6fb4da9DB4ba624b83E7D29;
        ids[5] = 2;
        
        addresses[6] = 0x6d4db18b59c487844dE34eB6eA527775add4b616;
        ids[6] = 2249;
        
        addresses[7] = 0xfD30F72365faF966e7c4Cce7D5cAF7eb582c5793;
        ids[7] = 2;
        
        addresses[8] = 0xE58741CEe4Ab62f0b27E1D8F79744ae76cb99FC7;
        ids[8] = 137;
        
        addresses[9] = 0xC7b47122603dc51a877576FAb697A5285d22C503;
        ids[9] = 6;
        
        addresses[10] = 0x8Cf16E05C80A67D7ff424C2492402aD88693959B;
        ids[10] = 195;
        
        addresses[11] = 0xF459d16Ae779eE1137224dd78FdC2D08201Ef9Fb;
        ids[11] = 1;
        
        addresses[12] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[12] = 85;
        
        addresses[13] = 0xf28E3df4aa597548AED89694228Ff8A67e4D4170;
        ids[13] = 30;
        
        addresses[14] = 0x28D0cd5C6E2419630433B195802789A68Bb710D3;
        ids[14] = 1;
        
        addresses[15] = 0x51637EC3F6ABB4b64E944DBB91FB891a2579Cb56;
        ids[15] = 6;
        
        addresses[16] = 0x66087F29EA734C2cAF76A61A93AB41395dCA15A6;
        ids[16] = 2;
        
        addresses[17] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[17] = 106;
        
        addresses[18] = 0xE1E715c6151a453c4eBE358110F57102C85BED95;
        ids[18] = 362;
        
        addresses[19] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[19] = 83;
        
        addresses[20] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[20] = 109;
        
        addresses[21] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[21] = 110;
        
        addresses[22] = 0xB2Eef6Dd45E13fdEdadCb39BDD2c2a1665822F8F;
        ids[22] = 5;
        
        addresses[23] = 0xcBDE9C100655C0541B50Aad9D0B86BCa73d8620d;
        ids[23] = 3;
        
        addresses[24] = 0x0d7ee10a5aED568a7B1769B92A434B677B35953a;
        ids[24] = 2;
        
        addresses[25] = 0x2ad08B1132cB4f969361FD0Aa9beeB8e55776Bbc;
        ids[25] = 4;
        
        addresses[26] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[26] = 81;
        
        addresses[27] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[27] = 30;
        
        addresses[28] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[28] = 54;
        
        addresses[29] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[29] = 104;
        
        addresses[30] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[30] = 100;
        
        addresses[31] = 0xFBf325585DD8153F722923fBd31095E4694650E9;
        ids[31] = 84;    
*/    
        vm.startBroadcast(vm.envUint("PK"));
        
        for (uint i = 0; i < totalNfts; i++) {
            if (IERC165(addresses[i]).supportsInterface(type(IERC1155).interfaceId)) {
                IERC1155(addresses[i]).setApprovalForAll(address(mm), true);
            } else if (IERC165(addresses[i]).supportsInterface(type(IERC721).interfaceId)) {
                IERC721(addresses[i]).setApprovalForAll(address(mm), true);
            }
        }
        
        mm.deposit(addresses, ids, true);
    }
}
