// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable{
    
    string _baseTokenURI;

    IWhitelist whitelist;

    bool public presaleStarted;
    uint256 public _price = 0.01 ether;
    uint256 public presaleEnded;

    uint256 public maxTokenIds = 20;
    uint256 public tokenIds;

    bool public _paused;

    
    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI, address whitelistContract) ERC721("Crypto Devs","CD"){
        _baseTokenURI=baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPreSale()  public onlyOwner{
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable{
        require(presaleStarted && block.timestamp<presaleEnded,"presale Ended");
        require(whitelist.whitelistedAddresses(msg.sender),"you are not listed as whitelisted address");
        require(tokenIds<maxTokenIds,"all tokens are minted already");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds+=1;
        _safeMint(msg.sender, tokenIds);

    }

    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }
    
    function _baseURI() internal view  override returns (string memory) {
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

    function _withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "failed to send ether");
    }


    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}