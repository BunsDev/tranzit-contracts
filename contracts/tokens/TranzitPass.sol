// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TranzitPass is ERC1155, Ownable {

    string public name = "TranzitPass";
    uint8 public maxTokenId = 3;

    // Mapping of token ID to URI
    mapping(uint256 => string) public tokenURIs;

    constructor() ERC1155("") Ownable(msg.sender) {}

    // Mint function to create new passes
    function mint(address _account, uint256 _tokenId, uint256 _amount) external onlyOwner {
        require(_tokenId > 0 && _tokenId <= 3, "Invalid pass type");
        _mint(_account, _tokenId, _amount, "");
    }

    // Set URI for a specific token type
    function setTokenURI(uint256 _tokenId, string memory _uri) external  {
        require(_tokenId > 0 && _tokenId <= maxTokenId, "Invalid pass type");
        tokenURIs[_tokenId] = _uri;
    }

    // Override URI function to return token specific URI
    function uri(uint256 _tokenId) public view override returns (string memory) {
        return tokenURIs[_tokenId];
    }

    // Burn function to destroy passes (only owner can call)
    function burn(address from, uint256 typeId, uint256 amount) external onlyOwner {
        require(balanceOf(from, typeId) >= amount, "Insufficient balance for burn");
        _burn(from, typeId, amount);
    }
}
