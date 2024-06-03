// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;
import "../interfaces/IBasePolygonZkEVMGlobalExitRoot.sol";
import "../interfaces/IBridgeMessageReceiver.sol";
import "../interfaces/IPolygonZkEVMBridge.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PolygonBridgeMiddleware is Ownable {
    // Zk-EVM Bridge address
    IPolygonZkEVMBridge public immutable polygonZkEVMBridge;
    
    // address public immutable router;
    // uint32 public immutable subnetId;

    // mapping (address => mapping (uint32 => bool)) allowlistedMiddlewareAndSubnet;

    string public bridgeMessage;

    // , uint32 _subnetId, address _router
    constructor(IPolygonZkEVMBridge _polygonZkEVMBridge) Ownable(msg.sender) {
        polygonZkEVMBridge = _polygonZkEVMBridge;
        // subnetId = _subnetId;
        // router = _router;
    }

    function sendBridgeMessage(
        bytes memory messageData,
        bool forceUpdateGlobalExitRoot
    ) external {
        (, uint32 _subnetId, address _middlewareAddress) = abi.decode(
            messageData,
            (string, uint32, address)
        );
        // require(allowlistedMiddlewareAndSubnet[_middlewareAddress][subnetId], "Invalid middleware");
        polygonZkEVMBridge.bridgeMessage(
            _subnetId,
            _middlewareAddress,
            forceUpdateGlobalExitRoot,
            messageData
        );
    }

    function onMessageReceived(
        address originAddress,
        uint32 originNetwork,
        bytes memory data
    ) external payable {
        // Can only be called by the bridge
        require(
            msg.sender == address(polygonZkEVMBridge),
            "TokenWrapped::PolygonBridgeBase: Not PolygonZkEVMBridge"
        );

        (string memory message, uint32 _subnetId, address _middlewareAddress) = abi.decode(
            data,
            (string, uint32, address)
        );

        require(originNetwork == _subnetId && originAddress == _middlewareAddress, "unauthorized sender");
        bridgeMessage = message;
    }
}
