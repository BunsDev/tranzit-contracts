// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

/**
 * @title DataTypes
 * @dev Library defining common data structures used in the contracts.
 */
library DataTypes {
    enum ChainDataStatus {
        INACTIVE,
        ACTIVE,
        PAUSED
    }

    /**
     * @dev Data structure representing information about a user
     */
    struct UserData {
        uint256 transactionCount;
        uint256 transactionReward;
        uint256 lastPassUsageTimestamp; // Timestamp of the last transaction where reward pass was used to board.
    }

    /**
     * @dev Data structure representing information about the chain.
     */
    struct ChainData {
        address protocolAddress;
        uint64 ccipChainselector;
        ChainDataStatus status;
    }

    /**
     * @dev Transaction status options
     */
    enum TransactionStatus {
        PARKED,
        BOARDING,
        INTRANSIT,
        BRIDGED,
        ARRIVED
    }

    /**
     * @dev Data structure representing information about Trasanction (recipient and amount) being batched
     */
    struct Transaction {
        address to;
        uint256 amount;
    }

    /**
     * @dev Data structure representing information about the Trasanctions being batched
     */
    struct TransactionData {
        uint256 transactionId;
        address token;
        uint64 chainSelector;
        TransactionStatus status;
        uint256 createdTimestamp;
        uint256 total;

        Transaction[] transactions;
    }

    /**
     * @dev Data structure representing a message used in cross-chain bridging.
     */
    struct BridgeMessageData {
        TransactionData transactionData; // Receiver of tokens on the destination chain.
        uint32 srcChainId;
        uint32 dstChainId;
    }

    struct UpkeepData {
        address token;
        uint32 chainId;
        uint256 transactionId;
    }
}
