// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.23; 

import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

///
/// @title Magic Machine
///
/// @notice Distributes random nfts (ERC-721 and/or ERC-1155) based on a vending machine
///         behaviour. Owner must deposit nfts and load the machine before distribution.
///
/// @author J. Valeska (https://github.com/jvaleskadevs/magic-machine).
/// 
contract MagicMachine is Ownable, ERC721Holder, ERC1155Holder {    
    /// @notice That amount of ether must be paid before every random distribution.
    ///
    /// @dev The `owner` may change that `price` with the `setPrices` function.
    uint256 public price = 0.001 ether;
    /// @notice That amount of DEGEN must be paid before every random distribution.
    ///
    /// @dev The `owner` may change that `price` with the `setPrices` function.    
    uint256 public degenPrice = 420 ether;
    /// @notice That amount of TN100X must be paid before every random distribution.
    ///
    /// @dev The `owner` may change that `price` with the `setPrices` function.    
    uint256 public tn100xPrice = 4200 ether;
    /// @notice The percentage discounted from prices on multiple distribution.
    ///
    /// @dev The `owner` may change that `discount` with the `setPrices` function.
    uint256 public discount = 90;    
    
    /// @notice The address of the DEGEN token.
    address public immutable DEGEN = 0x4ed4E862860beD51a9570b96d89aF5E1B0Efefed;
    /// @notice The interface of the DEGEN token.
    IERC20 private immutable IDEGEN;
    
    /// @notice The address of the TN100X token.
    address public immutable TN100X = 0x5B5dee44552546ECEA05EDeA01DCD7Be7aa6144A;
    /// @notice The interface of the TN100X token.
    IERC20 private immutable ITN100X;

    /// @notice The withdrawal address of the F. recipient.
    address public theF = 0x2D0A6C67dc678E852483924225660ad5a4349335;    
    /// @notice The withdrawal address of the J. recipient.
    address public theJ = 0x26281BB0b775A59Db0538b555f161E8F364fd21e;
    /// @notice The withdrawal address of the M. recipient.
    address public theM = 0x1b17A2656E43c16398a4a407Fc38691C61f2DB79;

    /// @notice An enum for the nft states: in or out.
    ///
    /// @dev `In` means inside the contract. `Out` means out of the contract.
    enum State {
        Out,
        In
    }

    /// @notice A wrapper struct for store the nft data: address, ID and state.
    struct NFT {
        /// @dev The contract address of the nft.
        address addr;
        /// @dev The tokenId of the nft.
        uint256 id;
        /// @dev The current state of the nft, IN or OUT contract.
        State state;
    }
    
    /// @notice A mapping including all nfts deposited in the contract.
    mapping(uint256 => NFT) public nfts;
    /// @notice The total count of nfts in the nfts mapping.
    uint256 public totalNfts;
    /// @notice The Index of the last item moved from the nfts mapping to the machine.
    uint256 public lastMappingIndex = 1;    
    /// @notice The list of items available for next random distribution aka the machine.
    uint256[69] public machine;
    /// @notice The total count of nfts loaded in the machine.
    uint256 public totalNftsMachine;
    
    /// @notice Thrown when calling `distributeRandomItem` with a wrong `price`.
    error Price();
    /// @notice Thrown on 'distributeRandomItem' when the machine is empty.
    error EmptyMachine();
    /// @notice Thrown on attempt to call or access non-allowed functions.
    error Forbidden();
    /// @notice Thrown on `deposit` and `withdraw` when the length of arrays is not the same.
    error ArraysMissmatch();
    /// @notice Thrown on 'withdraw' when the recipient is the Zero address.
    error ZeroAddress();
    
    /// @notice Emitted after a successful deposit of an nft into the contract.
    event NewDeposit(address indexed nft, uint256 id);
    /// @notice Emitted after a successful distribution of an nft from the machine.
    event NewDistribution(address indexed nft, uint indexed id, address indexed recipient, uint price);
    /// @notice Emitted after a successful withdraw of an nft from the contract.
    event NewWithdrawal(address indexed nft, uint256 id);
    
    constructor() Ownable(msg.sender) {
        // init interfaces to save users gas
        IDEGEN = IERC20(DEGEN);
        ITN100X = IERC20(TN100X);
    }

    /// @notice Deposits multiple NFTs into the Magic Machine contract.
    ///
    /// @dev Arrays must have the same length and every address index must match the ID index.
    ///
    /// @param tokenAddresses     List of nfts addresses to be deposited.
    /// @param tokenIds           List of nfts IDs to be deposited.
    /// @param shouldLoadMachine  When `true`, calls the `loadMachine` function after deposit.
    function deposit(
        address[] calldata tokenAddresses, 
        uint256[] calldata tokenIds,
        bool shouldLoadMachine
    ) public onlyOwner {
        if (tokenAddresses.length != tokenIds.length) revert ArraysMissmatch();

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            address tokenAddress = tokenAddresses[i];
            uint256 tokenId = tokenIds[i];

            // Transfer the NFT to the contract
            if (isERC1155(tokenAddress)) {
                nfts[++totalNfts] = NFT(tokenAddress, tokenId, State.In);
                IERC1155(tokenAddress).safeTransferFrom(
                    msg.sender, 
                    address(this), 
                    tokenId, 
                    1, 
                    ""
                );
                emit NewDeposit(tokenAddress, tokenId);
            } else if (isERC721(tokenAddress)) {
                nfts[++totalNfts] = NFT(tokenAddress, tokenId, State.In);
                IERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);
                emit NewDeposit(tokenAddress, tokenId);
            }
        }
        
        if (shouldLoadMachine) {
            loadMachine();
        }
    }    

    /// @notice Load the Magic Machine with the nfts in the contract.
    ///
    /// @dev The machine has a total size of 69 slots. Empty slots contain the Zero value.
    function loadMachine() public onlyOwner {
        for (uint256 i = lastMappingIndex; i < lastMappingIndex + 69; i++) {
            if (nfts[i].state == State.In) {
                machine[totalNftsMachine] = i;
                totalNftsMachine++;
                lastMappingIndex = i + 1;
            }
        }
    }
    
    /// @notice Load the Magic Machine starting from a desired index.
    ///
    /// @dev Useful after calling the `resetMachine` function.
    function loadMachineFromIndex(uint256 startingIndex) public onlyOwner {
        if (totalNftsMachine != 0) revert EmptyMachine();
        
        for (uint256 i = startingIndex; i < startingIndex + 69; i++) {                
            if (nfts[i].state == State.In) {
                machine[totalNftsMachine] = i;
                totalNftsMachine++;
                lastMappingIndex = i + 1;
            }
        }        
    }
    
    /// @notice Prune the selected indexes from the Magic Machine.
    ///
    /// @dev Useful after calling `emergencyRecovery` to clean failing transfers.
    ///      When there is no more available nfts, the reload will be safely ignored.
    ///
    /// @param machineIndexes  The list of indexes to remove from the machine array.
    function pruneMachine(uint256[] calldata machineIndexes) public onlyOwner {
        for (uint256 i = 0; i < machineIndexes.length; i++) {
            if (nfts[lastMappingIndex].state == State.In) {
                machine[machineIndexes[i]] = lastMappingIndex;
                lastMappingIndex++;                
            } else if (totalNftsMachine != 0) {
                machine[machineIndexes[i]] = machine[--totalNftsMachine];
            } else {
                machine[machineIndexes[i]] = 0;
            }
        }        
    }
    
    /// @notice Reset ALL indexes from the Magic Machine to the Zero value.
    ///
    /// @param shouldLoadMachine  When `true`, will reload the machine.
    ///
    /// @dev  Useful for hard reloads. Then call the `loadMachineFromIndex`
    function resetMachine(bool shouldLoadMachine) public onlyOwner {
        totalNftsMachine = 0;    
        for (uint256 i = 0; i < 69; i++) {
            machine[i] = 0;
        }
    
        if (shouldLoadMachine) {
            loadMachineFromIndex(0);
        }
    }
    
    /// @notice Distributes a random item from the Magic Machine to the sender and 
    ///         reloads the machine with the next nft from the mapping.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function distributeRandomItem() public payable {
        if(msg.value != price) revert Price();   
        
        _distributeRandomItem(); 
    }
    
    
    /// @notice Distributes a random item from the Magic Machine. Accept DEGEN as payment.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function distributeRandomItemDegen() public payable {
        bool success = IDEGEN.transferFrom(msg.sender, address(this), degenPrice);
        if (!success) revert Price();
        
        _distributeRandomItem(); 
    }
    
    /// @notice Distributes a random item from the Magic Machine. Accept TN100X as payment.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function distributeRandomItemTN100x() public payable {
        bool success = ITN100X.transferFrom(msg.sender, address(this), tn100xPrice);
        if (!success) revert Price();
        
        _distributeRandomItem(); 
    }

    /// @notice Distributes multiple random items from the Magic Machine to the sender and 
    ///         and reloads the machine. 
    ///
    /// @param amount The total amount of random items to be distributed.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function distributeRandomItems(uint256 amount) public payable {
        uint256 amountToBePaid = price * amount * discount / 100;
        if(msg.value != amountToBePaid && amount != 0) revert Price(); 
        
        for (uint256 i = 0; i < amount; i++) {
            _distributeRandomItem();
        }   
    }
    
    /// @notice Distributes multiple random items from the Magic Machine to the sender and 
    ///         and reloads the machine. Accepts DEGEN as payment.
    ///
    /// @param amount The total amount of random items to be distributed.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function distributeRandomItemsDegen(uint256 amount) public payable {
        uint256 amountToBePaid = degenPrice * amount * discount / 100;
        bool success = IDEGEN.transferFrom(msg.sender, address(this), amountToBePaid);
        if (!success) revert Price();
        
        for (uint256 i = 0; i < amount; i++) {
            _distributeRandomItem();
        }   
    }
    
    /// @notice Distributes multiple random items from the Magic Machine to the sender and 
    ///         and reloads the machine. Accepts TN100x as payment.
    ///
    /// @param amount The total amount of random items to be distributed.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function distributeRandomItemsTN100x(uint256 amount) public payable {
        uint256 amountToBePaid = tn100xPrice * amount * discount / 100;        
        bool success = ITN100X.transferFrom(msg.sender, address(this), amountToBePaid);
        if (!success) revert Price();
        
        for (uint256 i = 0; i < amount; i++) {
            _distributeRandomItem();
        }   
    }
    
    /// @notice Distributes a random item from the Magic Machine to the sender and 
    ///         reloads the machine with the next nft from the mapping.
    ///
    /// @dev When there is no more available nfts, the load will be safely ignored.
    function _distributeRandomItem() internal {
        //if(msg.value != price) revert Price();
        if(totalNftsMachine == 0) revert EmptyMachine();
        
        uint256 randomIdx = _getRandomIndex();
        
        // Extract the nft from the random index
        NFT storage nft = nfts[machine[randomIdx]];
        nft.state = State.Out;

        // Load the machine with next nft mapping or last machine index        
        if (nfts[lastMappingIndex].state == State.In) {
            machine[randomIdx] = lastMappingIndex;
            lastMappingIndex++;
        } else if (totalNftsMachine != 0) {
            machine[randomIdx] = machine[--totalNftsMachine];
            machine[totalNftsMachine] = 0;
        } else {
            machine[randomIdx] = 0;
        }


        // Transfer the NFT from the contract to the new recipient
        if (isERC1155(nft.addr)) {
            IERC1155(nft.addr).safeTransferFrom(
                address(this), 
                msg.sender,
                nft.id, 
                1, 
                ""
            );
            
            // Transfer was a success, distribution completed!
            emit NewDistribution(nft.addr, nft.id, msg.sender, price);
        } else if (isERC721(nft.addr)) {
            IERC721(nft.addr).safeTransferFrom(address(this), msg.sender, nft.id);
            
            // Transfer was a success, distribution completed!
            emit NewDistribution(nft.addr, nft.id, msg.sender, price);
        }
    }
    
    function _getRandomIndex() internal view returns (uint256 randomIdx) {
        // Get a random index within the range of the total nfts in the machine
        randomIdx = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    msg.sender
                )
            )
        ) % totalNftsMachine;     
    }
    
    /// @notice Sets the prices that must be paid to call the `distributeRandomItem` functions.
    /// 
    /// @param newPrice The amount of ether for setting as the `price` or Zero.
    /// @param newDegenPrice The amount of DEGEN for setting as the `degenPrice` or Zero.
    /// @param newTn100xPrice The amount of TN100X for setting as the `tn100xPrice` or Zero.
    /// @param newDiscount The percentage amount for setting as the `discount` or Zero.
    function setPrices(uint newPrice, uint newDegenPrice, uint newTn100xPrice, uint newDiscount) public onlyOwner {
        price = newPrice != 0 ? newPrice : price;
        degenPrice = newDegenPrice != 0 ? newDegenPrice : degenPrice;
        tn100xPrice = newTn100xPrice != 0 ? newTn100xPrice : tn100xPrice;
        discount = newDiscount != 0 ? newDiscount : discount;
    }
    
    /// @notice Withdraw multiple NFTs, only for emergencies. Migration, locked nfts..
    // 
    /// @dev It cleans the nft from the machine but does not remove the nft from the nfts mapping,
    ///      the nft could be loaded into the machine and anyone could "win" it but the transaction
    ///      obv, will fail. Calling `pruneMachine` with the right index will solve it.
    function emergencyWithdraw(
        address[] calldata tokenAddresses, 
        uint256[] calldata tokenIds
    ) public onlyOwner {
        if (tokenAddresses.length != tokenIds.length) revert ArraysMissmatch();

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            address tokenAddress = tokenAddresses[i];
            uint256 tokenId = tokenIds[i];

            // Clean or reload the machine
            for (uint256 j = 0; j < 69; j++) {
                NFT memory currentNft = nfts[machine[j]];
                if (currentNft.addr == tokenAddress && currentNft.id == tokenId && machine[j] != 0) {
                    nfts[machine[j]].state = State.Out;
                    // Load the machine with the next nft mapping index or zero        
                    if (nfts[lastMappingIndex].state == State.In) {
                        machine[j] = lastMappingIndex;
                        lastMappingIndex++;
                    } else if (totalNftsMachine != 0) {
                        machine[j] = machine[--totalNftsMachine];
                    } else {
                        machine[j] = 0;
                    }
                }
            }

            // Transfer the NFT from the contract
            if (isERC1155(tokenAddress)) {
                IERC1155(tokenAddress).safeTransferFrom(
                    address(this), 
                    msg.sender,
                    tokenId, 
                    1, 
                    ""
                );
                emit NewWithdrawal(tokenAddress, tokenId);
            } else if (isERC721(tokenAddress)) {
                IERC721(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId);
                emit NewWithdrawal(tokenAddress, tokenId);
            }
        }
    }

    /// @notice Withdraw all the ether from the contract. 
    ///
    /// @dev Balance split between 3 parties, owner -> 70%, J -> 20% and M -> 10%.
    function withdraw() public {
        // compute amounts, 70%, 20%, 10%
        uint256 balance = address(this).balance;
        uint256 amountF = balance * 70 / 100;
        uint256 amountJ = (balance - amountF) * 66 / 100;
        uint256 amountM = balance - amountF - amountJ;
        // transfer the amounts
        (bool success, ) = payable(theJ).call{value: amountJ}("");
        (success, ) = payable(theF).call{value: amountF}("");         
        (success, ) = payable(theM).call{value: amountM}(""); 
    }
    
    /// @notice Withdraw any erc20 token from the contract. 
    ///
    /// @param token The address of the token to withdraw.
    ///
    /// @dev Balance split between 3 parties, owner -> 70%, J -> 20% and M -> 10%.
    function withdrawToken(address token) public {
        if (token != DEGEN && token != TN100X && msg.sender != owner()) revert Forbidden();
        IERC20 i20 = IERC20(token);
        // compute amounts, 70%, 20%, 10%
        uint256 balance = i20.balanceOf(address(this));
        uint256 amountF = balance * 70 / 100;
        uint256 amountJ = (balance - amountF) * 66 / 100;
        uint256 amountM = balance - amountF - amountJ;
        // transfer the amounts
        i20.transfer(theJ, amountJ);
        i20.transfer(theF, amountF);
        i20.transfer(theM, amountM);
    }
    
    /// @notice Set a new `theF` address. Only callable from current `theF`.
    ///
    /// @param newF The address for setting as `theF`. Must be non-zero address.
    function changeTheF(address newF) public {
        if (msg.sender != theF) revert Forbidden();
        if (newF == address(0)) revert ZeroAddress();
        theF = newF;
    }
    
    /// @notice Set a new `theJ` address. Only callable from current `theJ`.
    ///
    /// @param newJ The address for setting as `theJ`. Must be non-zero address.
    function changeTheJ(address newJ) public {
        if (msg.sender != theJ) revert Forbidden();
        if (newJ == address(0)) revert ZeroAddress();
        theJ = newJ;
    }
    
    /// @notice Set a new `theM` address. Only callable from current `theM`.
    ///
    /// @param newM The address for setting as `theM`. Must be non-zero address.
    function changeTheM(address newM) public {
        if (msg.sender != theM) revert Forbidden();
        if (newM == address(0)) revert ZeroAddress();
        theM = newM;
    }
    
    // view functions
    
    /// @notice Checks if the token is an ERC1155
    ///
    /// @param tokenAddress The address of the token to check
    ///
    /// @return `True` when the token is an ERC1155, `False` otherwise
    function isERC1155(address tokenAddress) public view returns (bool) {
        // Check if ERC1155 interface is supported
        if (IERC165(tokenAddress).supportsInterface(type(IERC1155).interfaceId)) {
            return true;
        }
        return false;
    }
    
    /// @notice Checks if the token is an ERC721
    ///
    /// @param tokenAddress The address of the token to check
    ///
    /// @return `True` when the token is an ERC721, `False` otherwise
    function isERC721(address tokenAddress) public view returns (bool) {
        // Check if ERC721 interface is supported
        if (IERC165(tokenAddress).supportsInterface(type(IERC721).interfaceId)) {
            return true;
        }
        return false;
    }  
    
    /// @notice Get the current state of the machine.
    ///
    /// @return The current state of the machine array.
    function getMachine() public view returns(uint[69] memory) {
        return machine;
    }

    /// @dev See {IERC721Receiver-onERC721Received}.
    ///      Always returns `IERC721Receiver.onERC721Received.selector`.
    function onERC721Received(
        address /*operator*/, 
        address /*from*/, 
        uint256 /*tokenId*/, 
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    /// @dev See {IERCReceiver-onERC721Received}.
    /// @dev See {IERC165-supportsInterface}.
    ///      Always returns `IERC721Receiver.onERC721Received.selector`.
    function onERC1155Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*id*/,
        uint256 /*value*/,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

} //
