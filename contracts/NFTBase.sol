// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTBase is ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 public initialSupply;
    uint256 public mintedSupply;
    bool public initialized = false;
    uint128 public mintFee;
    // string private customName;
    // string private customSymbol;


    constructor(string memory name, string memory symbol, uint256 _initialSupply/*, uint128 _mintFee*/)
        ERC721(name, symbol)
        Ownable(msg.sender)
    {
        initialSupply = _initialSupply;
        // mintFee = _mintFee;
    }

    // function initialize(string memory _name, string memory _symbol, uint256 _initialSupply) external {
    //     require(initialSupply == 0, "Already initialized");
    //     require(!initialized, "Already initialized");
    //     initialized = true;
    //     initialSupply = _initialSupply;
    //     customName = _name;
    //     customSymbol = _symbol;
    //     _setNameAndSymbol(_name, _symbol);
    // }

    function mint(address _to, string memory _tokenURI) public /*payable*/  {
        // require(msg.value >= mintFee, "Insufficient fee for minting");
        uint256 tokenId = mintedSupply + 1;
        _safeMint(_to, tokenId);
        if (bytes(_tokenURI).length > 0) {
            _setTokenURI(tokenId, _tokenURI);
        }
        mintedSupply += 1;
    }

    function batchMint(address _to, string[] memory _tokenURIs) public /*payable*/ {
        // require(msg.value >= mintFee, "Insufficient fee for minting");
        for (uint256 i = 0; i < _tokenURIs.length; i++) {
            require(mintedSupply < initialSupply, "Max supply reached");
            uint256 tokenId = mintedSupply + 1;
            _safeMint(_to, tokenId);
            if (bytes(_tokenURIs[i]).length > 0) {
                _setTokenURI(tokenId, _tokenURIs[i]);
            }
            mintedSupply += 1;
        }
    }

    function setInitialSupply(uint256 _initialSupply) external onlyOwner {
        initialSupply = _initialSupply;
    }

    

    //Helper function
    // function _setNameAndSymbol(string memory _name, string memory _symbol) internal {
    //     assembly {
    //         sstore(0x0, _name)
    //         sstore(0x1, _symbol)
    //     }
    // }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _update(address _to, uint256 _tokenId, address _auth)
        internal
        virtual
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(_to, _tokenId, _auth);
    }

    function _increaseBalance(address _account, uint128 _value) internal virtual override(ERC721, ERC721Enumerable) {
        return super._increaseBalance(_account, _value);
    }
}
