// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./Bridge.sol";
import {DataTypes} from "./libraries/DataTypes.sol";

/**
 * @title Router
 * @notice Base protocol contract users interact with
 * @dev Extension of the Bridge contract with additional functionality.
 */
contract Router is Bridge {
    // Chain selector of the network this contract was deployed in
    uint64 public immutable chainSelector;
    uint32 public immutable chainId;

    /**
     * @dev Constructor initializes the Router with the specified parameters.
     * @param _linkRouter Address of the LINK bridge router contract.
     * @param _linkToken Address of the LINK token contract.
     * @param _chainSelector Chain selector for the deployed network/chain.
     */
    constructor(
        address _linkRouter,
        address _linkToken,
        uint64 _chainSelector,
        uint32 _chainId
    ) Bridge(_linkRouter, _linkToken) {
        chainSelector = _chainSelector;
        chainId = _chainId;
    }

    function board(
        address _recipient,
        uint256 _amount,
        address _token,
        uint32 _dstChainId
    ) external {
        //
        DataTypes.ChainData memory _dstChainData = allowlistedChain[
            _dstChainId
        ];
        require(
            _dstChainData.protocolAddress != address(0),
            "invalid chain ID"
        );

        require(
            _dstChainData.status == DataTypes.ChainDataStatus.ACTIVE,
            "Destination chain is not available at the moment. (Paused or Inactive)"
        );

        require(
            isTokenSupportedInDestChain[_token][_dstChainId],
            "Token not supported in destination chain"
        );

        require(
            latestTransactionId[_token][_dstChainId] > 0,
            "Token is not yet initialized in Destination chain"
        );

        require(
            _amount > _getProtocolFee(),
            "Amount does not cover fee needed to perform bridge operation"
        );
        require(
            IERC20(_token).allowance(msg.sender, address(this)) >= _amount,
            "Allowance exceeded"
        );
        require(
            IERC20(_token).balanceOf(msg.sender) >= _amount,
            "Insufficient token balance"
        );
        bool _token_transfer_success = IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(_token_transfer_success, "Token transfer error");

        if (
            transactionData[_token][_dstChainId][
                latestTransactionId[_token][_dstChainId]
            ].status == DataTypes.TransactionStatus.INTRANSIT
        ) {
            latestTransactionId[_token][_dstChainId] =
                latestTransactionId[_token][_dstChainId] +
                1;
        }
        uint256 transactionId = latestTransactionId[_token][_dstChainId];
        DataTypes.TransactionData storage _transactionData = transactionData[_token][_dstChainId][transactionId];
        if (_transactionData.token == address(0)) {
            _transactionData.token = _token;
            _transactionData.chainSelector = chainSelectorByChainId[
                _dstChainId
            ];
            _transactionData.status = DataTypes.TransactionStatus.BOARDING;
            _transactionData.createdTimestamp = block.timestamp;
        }
        uint256 _sendingAmount = _amount - _getProtocolFee();
        _transactionData.total = _transactionData.total + _sendingAmount;
        _transactionData.transactions.push(
            DataTypes.Transaction(_recipient, _sendingAmount)
        );
        transactionData[_token][_dstChainId][transactionId] = _transactionData;
        DataTypes.UserData memory _userData = userData[msg.sender];
        _userData.transactionCount += 1;
        _userData.transactionReward += 1;
        userData[msg.sender] = _userData;
    }

    /**
     * @notice Bridges tokens from one chain to another.
     * @param _token Amount of tokens to bridge.
     * @param _dstChainId Destination chain ID.
     * @param _transactionId transaction ID of transaction batch.
     */
    function bridge(
        address _token,
        uint32 _dstChainId,
        uint256 _transactionId
    ) internal {
        DataTypes.ChainData memory _dstChainData = allowlistedChain[
            _dstChainId
        ];
        DataTypes.TransactionData memory _transactionData = transactionData[_token][_dstChainId][_transactionId];
        _sendBridgeMessage(
            _dstChainData.ccipChainselector,
            _dstChainData.protocolAddress,
            _transactionData.token,
            _transactionData.total,
            abi.encode(
                DataTypes.BridgeMessageData(
                    _transactionData,
                    chainId,
                    _dstChainId
                )
            )
        );
    }

    function getProtocolFee() external pure returns (uint256) {
        return _getProtocolFee();
    }

    function checkUpkeep(
        bytes calldata checkData
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        DataTypes.UpkeepData memory _checkData = abi.decode(checkData, (DataTypes.UpkeepData));
        DataTypes.TransactionData memory _transactionData = transactionData[_checkData.token][_checkData.chainId][_checkData.transactionId]; 
        upkeepNeeded = ((block.timestamp - _transactionData.createdTimestamp) > boardingInterval) || (_transactionData.transactions.length >= 10);
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override {
        DataTypes.UpkeepData memory _performData = abi.decode(performData, (DataTypes.UpkeepData));
        DataTypes.TransactionData memory _transactionData = transactionData[_performData.token][_performData.chainId][_performData.transactionId]; 
        if (((block.timestamp - _transactionData.createdTimestamp) > boardingInterval)  || (_transactionData.transactions.length >= 10)) {
            bridge(_performData.token, _performData.chainId, _performData.transactionId);
        }
    }
}
