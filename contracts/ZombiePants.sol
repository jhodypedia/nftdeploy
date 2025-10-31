// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ZombiePants is ERC721Burnable, Ownable, ReentrancyGuard {
    uint256 public nextId = 1;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPriceWei;       
    address public payoutAddress;      
    bool public mintOpen = true;
    mapping(address => bool) public minted;
    string public metadataServer;

    event Minted(address indexed to, uint256 tokenId);

    constructor(uint256 _mintPriceWei, address _payout, string memory _meta)
        ERC721("Zombie Pants", "ZPANTS")
    {
        mintPriceWei = _mintPriceWei;
        payoutAddress = _payout;
        metadataServer = _meta;
    }

    function setMintOpen(bool v) external onlyOwner { mintOpen = v; }
    function setMintPrice(uint256 v) external onlyOwner { mintPriceWei = v; }
    function setPayout(address a) external onlyOwner { payoutAddress = a; }
    function setMetadataServer(string calldata url) external onlyOwner { metadataServer = url; }

    function mintTo(address to) external payable nonReentrant returns (uint256 tokenId) {
        require(mintOpen, "Mint closed");
        require(nextId <= MAX_SUPPLY, "Sold out");
        require(!minted[to], "Already minted");

        if (msg.sender != payoutAddress) {
            require(msg.value >= mintPriceWei, "Insufficient fee");
        }

        minted[to] = true;
        tokenId = nextId++;
        _safeMint(to, tokenId);
        _payoutFunds();
        emit Minted(to, tokenId);
    }

    function _payoutFunds() internal {
        if (payoutAddress != address(0) && address(this).balance > 0) {
            (bool ok, ) = payable(payoutAddress).call{value: address(this).balance}("");
            require(ok, "Payout failed");
        }
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        require(_exists(id), "Not exist");
        return string(abi.encodePacked(metadataServer, _toString(id)));
    }

    function _toString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 j = v; uint256 len;
        while (j != 0) { len++; j /= 10; }
        bytes memory b = new bytes(len);
        uint256 k = len; j = v;
        while (j != 0) { b[--k] = bytes1(uint8(48 + j % 10)); j /= 10; }
        return string(b);
    }
}
