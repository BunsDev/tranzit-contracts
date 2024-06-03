// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./libraries/DataTypes.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";

abstract contract BaseStorage {

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    error ChainNotAllowlisted(
        uint64 destinationChainSelector,
        address protocolAddress
    ); // Used when the destination or source chain has not been allowlisted by the contract owner.
    
    error NoTransactionInBridgedData(); // Used when the withdrawal of Ether fails.

    // Event emitted when a message is sent to another chain.
    event BridgeMessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        bytes data,
        address token,
        uint256 amount,
        address feeToken,
        uint256 fees
    );

    // Event emitted when a message is received from another chain.
    event MessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        bytes data
    );

    event BridgeSuccess(
        bytes32 messageId,
        uint64 sourceChainSelector,
        address senderContract,
        uint256 indexed transactionId,
        address indexed dstToken,
        uint256 tokenAmount
    );

    address public middlewareAddress;

    mapping(bytes32 => bytes) public receivedBridgeDatas; // Store the list of received Data.

    // Mapping to keep track of allowlisted chains and senders.
    mapping(uint32 chainId => DataTypes.ChainData) public allowlistedChain;

    // Mapping to get protocol address on a given chain (can be a source chain or destination chain)
    mapping(address => mapping(uint64 => bool))
        public allowlistedProtocolAddress;

    mapping(uint32 chainId => uint64 chainSelector) chainSelectorByChainId;

    mapping(address token => mapping(uint32 chainId => bool)) isTokenSupportedInDestChain;

    mapping(address token => mapping(uint32 chainId => uint256)) latestTransactionId;

    mapping(address token => mapping(uint32 chainId => mapping(uint256 transactionId => DataTypes.TransactionData))) transactionData;

    mapping(address token => mapping(uint32 chainId => mapping(uint256 transactionId => uint256))) transactionMessageId;

    mapping (address user => DataTypes.UserData) userData;
    
    address public passTokenAddress ;

    uint8 public boardingInterval = 120;
}
