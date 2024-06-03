// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "./BaseStorage.sol";
import {DataTypes} from "./libraries/DataTypes.sol";
import "./libraries/Math.sol";

/**
 * @title Bridge
 * @dev Base bridge contract
 * @notice In this contract src(source) is treated as the current chain and dst(destination) is treated as the destination chain.
 *         BUT in the _ccipReceive() function src or source is treated as the sender(transaction initiator) chain and dst is treated as the current(receiver) chain.
 */

abstract contract Bridge is BaseStorage, CCIPReceiver, OwnerIsCreator, AutomationCompatibleInterface {
    // link token contract address
    IERC20 private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
    }

    /// @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
    /// @param _chainSelector The chain selector.
    /// @param _protocolAddress The address of the source or destinantion protocol address.
    modifier onlyAllowlistedDestinationChainAndAddress(
        uint64 _chainSelector,
        address _protocolAddress
    ) {
        if (!allowlistedProtocolAddress[_protocolAddress][_chainSelector]) {
            revert ChainNotAllowlisted(_chainSelector, _protocolAddress);
        }
        _;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    )
        internal
        override
        onlyAllowlistedDestinationChainAndAddress(
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address))
        ) // Make sure source chain and sender are allowlisted
    {
        DataTypes.BridgeMessageData memory _bridgeMessage = abi.decode(
            any2EvmMessage.data,
            (DataTypes.BridgeMessageData)
        ); // abi-decoding of the sent data
        require(
            (allowlistedChain[_bridgeMessage.srcChainId].protocolAddress ==
                abi.decode(any2EvmMessage.sender, (address))) &&
                (allowlistedChain[_bridgeMessage.srcChainId]
                    .ccipChainselector == any2EvmMessage.sourceChainSelector),
            "Invalid bridge message"
        );

        receivedBridgeDatas[any2EvmMessage.messageId] = any2EvmMessage.data;

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            any2EvmMessage.data
        );

        DataTypes.TransactionData memory _transactionData = _bridgeMessage
            .transactionData;

        if (_transactionData.transactions.length < 1) {
            revert NoTransactionInBridgedData();
        }

        for (uint256 i = 0; i < _transactionData.transactions.length; i++) {
            DataTypes.Transaction memory _transaction = _transactionData
                .transactions[i];
            IERC20(any2EvmMessage.destTokenAmounts[0].token).transfer(
                _transaction.to,
                _transaction.amount
            );
        }

        emit BridgeSuccess(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)),
            _transactionData.transactionId,
            any2EvmMessage.destTokenAmounts[0].token,
            any2EvmMessage.destTokenAmounts[0].amount
        );
    }

    function _sendBridgeMessage(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount,
        bytes memory _data
    ) internal returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message

        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _token,
            _amount,
            _data,
            400_000,
            address(s_linkToken)
        );

        // Initialize a router client instance to interact with cross-chain router
        IRouterClient router = IRouterClient(this.getRouter());

        // Get the fee required to send the CCIP message
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

        // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        s_linkToken.approve(address(router), fees);

        // approve the Router to spend tokens on contract's behalf.
        IERC20(_token).approve(address(router), _amount);

        // Send the CCIP message through the router and store the returned CCIP message ID
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        // Emit an event with message details
        emit BridgeMessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _data,
            _token,
            _amount,
            address(s_linkToken),
            fees
        );

        // Return the CCIP message ID
        return messageId;
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for sending a text.
    /// @param _receiver The address of the receiver.
    /// @param _data The string data to be sent.
    /// @param _feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        address _token,
        uint256 _amount,
        bytes memory _data,
        uint256 _gasLimit,
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVMTokenAmount[]
            memory _tokenAmounts = new Client.EVMTokenAmount[](1);
        _tokenAmounts[0] = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });

        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: _data, // ABI-encoded string
                tokenAmounts: _tokenAmounts, // Empty array aas no tokens are transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit and non-strict sequencing mode
                    Client.EVMExtraArgsV1({gasLimit: _gasLimit, strict: true})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

    function _getProtocolFee() internal pure returns (uint256) {
        return 5 * 10 ** 18;
    }

    /// @dev Updates the allowlist status of a destination or source chain for transactions.
    /// @param _chainId blockchain chainID of receiver.
    /// @param _chainSelector ccip chain selector for receiver.
    /// @param _protocolAddress receiver protocol address (router contract address).
    function allowlistChainAndProtocolAddress(
        uint32 _chainId,
        uint64 _chainSelector,
        address _protocolAddress
    ) external onlyOwner {
        allowlistedProtocolAddress[_protocolAddress][_chainSelector] = true;
        allowlistedChain[_chainId] = DataTypes.ChainData(
            _protocolAddress,
            _chainSelector,
            DataTypes.ChainDataStatus.ACTIVE
        );
    }

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is sent to the contract without any data.
    receive() external payable {}

    /// @notice Allows the contract owner to withdraw the entire balance of Ether from the contract.
    /// @dev This function reverts if there are no funds to withdraw or if the transfer fails.
    /// It should only be callable by the owner of the contract.
    /// @param _beneficiary The address to which the Ether should be sent.
    function withdrawBridgeNativeFee(address _beneficiary) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawBridgeTokenFee(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
    }
}
