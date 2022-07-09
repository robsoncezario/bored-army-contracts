// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BoredArmyUndead is ERC721, ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private _tokenIds;

  uint256 public constant bauMaxSupply = 10000; 
  uint256 public constant busdFee = 100;
  address public constant busdContractAddress = 0x8a48a073e4F92fdca9A44c557cB88B94FBDf9E53; // This is address is a test token address
  address public receiverAddress = 0x16a5F2608152E4Ea9B1F730b3BabC4B2ad4c4464;
  mapping(address => bool) public claimed;

  constructor() ERC721("Bored Army Undead", "BAU") { }

  function mint(address _account, uint256 _numberOfTokens) public returns (uint256[] memory) {
    require(_numberOfTokens >= 1, "Invalid number of tokens");
    require(_tokenIds.current() + _numberOfTokens <= bauMaxSupply, "Purchase would exceed max supply of Bored Army");
    require(!claimed[msg.sender], "NFT has already been claimed");

    if (msg.sender != owner()) {
      uint256 calculatedFee = (busdFee * _numberOfTokens);

      IERC20 tokenBUSD = IERC20(busdContractAddress);

      require(calculatedFee < tokenBUSD.balanceOf(msg.sender), "You don`t have enough BUSD balance.");
      require(tokenBUSD.transferFrom(msg.sender, receiverAddress, calculatedFee), "Transaction failed");
      claimed[msg.sender] = true;
    }

    uint256[] memory boredArmyList = new uint256[](_numberOfTokens);

    for(uint i = 0; i < _numberOfTokens; i++) {
      _tokenIds.increment();

      uint256 newItemId = _tokenIds.current();
      _mint(_account, newItemId);

      boredArmyList[i] = newItemId;
    }

    if(msg.sender != owner()) {
      claimed[msg.sender] = true;
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
    return "https://boredarmy.nyc3.digitaloceanspaces.com/undead/data/";
  } 

  function setReceiverAddress(address _account) public onlyOwner {
    receiverAddress = _account;
  }
}