// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoredArmy is ERC721, ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private _tokenIds;

  uint256 public constant boredArmyPrice = 0.25 ether; 
  uint256 public constant boredArmyMaxSupply = 10; 

  constructor() ERC721("Bored Army Hero", "BAH") {
    
  }

  function mint(address _account, uint256 _numberOfTokens) public payable returns (uint256[] memory) {
    require(_tokenIds.current() + _numberOfTokens <= boredArmyMaxSupply, "Purchase would exceed max supply of Bored Army");

    if (msg.sender != owner()) {
      require(boredArmyPrice * _numberOfTokens < msg.value, "BNB value sent is not correct");
    }

    uint256[] memory boredArmyList = new uint256[](_numberOfTokens);

    for(uint i = 0; i < _numberOfTokens; i++) {
      _tokenIds.increment();

      uint256 newItemId = _tokenIds.current();
      _mint(_account, newItemId);

      boredArmyList[i] = newItemId;
    }
    
    return boredArmyList;
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 _tokenId)  public
    view
    virtual
    override(ERC721, ERC721URIStorage) returns (string memory) {
    string memory baseUrl = _baseURI();
    return string(abi.encodePacked(baseUrl, Strings.toString(_tokenId), ".json"));
  }

  function _baseURI() pure internal override returns (string memory) {
    return "ipfs://QmRyQza4PXHBxVQyAfNcjcKtZFfL1J7tsBQwnMzxeWCGiv/";
  } 

  function withdrawAll() public payable onlyOwner {
    require(payable(owner()).send(address(this).balance));
  }
}