// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NFTBase} from "./NFTBase.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract NFTFactory is Ownable {
    mapping(address => address[]) internal  UserNFTs;
    uint128 public mintFee;

    event NFTContractDeployed(address indexed user, address nftContract);
    event MintFee(uint128 fee);

    constructor(uint128 _mintFee) 
    Ownable(msg.sender) 
    {
        mintFee = _mintFee;
    }

    function createNFTContract(string memory _name, string memory _symbol, uint256 _initialSupply)
        external payable 
        returns (address)
    {
        require(msg.value >= mintFee, "Insufficient mint fee");
        bytes memory bytecode = abi.encodePacked(
            type(NFTBase).creationCode,
            abi.encode(_name, _symbol, _initialSupply, mintFee)
        );

        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(deployed) { revert(0, 0) }
        }

        UserNFTs[msg.sender].push(deployed);

        emit NFTContractDeployed(msg.sender, deployed);
        return deployed;
    }

    function mintNFT(
        address _nftContract,
        address _to,
        string memory _tokenURI
    ) external /*payable*/ {
        // require(msg.value >= mintFee, "Insufficient mint fee");

        // Validate the caller owns the NFT contract
        bool isOwner = false;
        address[] memory userNFTs = UserNFTs[msg.sender];
        for (uint256 i = 0; i < userNFTs.length; i++) {
            if (userNFTs[i] == _nftContract) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not the owner of this NFT contract");

        // Call the mint function on the cloned contract
        NFTBase(_nftContract).mint(_to,_tokenURI);
    }

    function batchMint(
        address _nftContract,
        address _to,
        string[] memory _tokenURIs
    ) external /*payable*/ {
        // require(msg.value >= mintFee, "Insufficient mint fee");

        // Validate the caller owns the NFT contract
        bool isOwner = false;
        address[] memory userNFTs = UserNFTs[msg.sender];
        for (uint256 i = 0; i < userNFTs.length; i++) {
            if (userNFTs[i] == _nftContract) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not the owner of this NFT contract");

        // Call the mint function on the cloned contract
        NFTBase(_nftContract).batchMint(_to, _tokenURIs);
    }

    function setMintFee(uint128 _mintFee) public {
        mintFee = _mintFee;
        emit MintFee(_mintFee);
    }

    function getUserNFT (address user) public view returns (address[] memory){
        return UserNFTs[user];
    }

    //helper function
    // function transferFeeToOwner (address payable _to, uint256 _amount, uint256 _percentage) internal returns(bool) {
    //     require(_percentage >0 && _percentage <=100, "Percenteage must be between 1 and 100");
    //     require(_amount > 0,  "No funds sent");
    //     //Calculate ammount to send to user
    //     uint256 amountToSend = (_amount * _percentage)/100;

    //     // Transfer Calculated ammount
    //     (bool success,) = _to.call{value:amountToSend}("");

    //     require(success,"Transfer Failed");
    //     return  success;
    // }

    function withdrawFees() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // IERC721 utility functions
    function balanceOf(address _nftContract, address owner) external view returns (uint256) {
        return IERC721(_nftContract).balanceOf(owner);
    }

    function ownerOf(address _nftContract, uint256 tokenId) external view returns (address) {
        return IERC721(_nftContract).ownerOf(tokenId);
    }

    function approve(address _nftContract, address to, uint256 tokenId) external {
        require(_isOwnerOfNFTContract(msg.sender, _nftContract), "Not authorized to approve");
        IERC721(_nftContract).approve(to, tokenId);
    }

    function getApproved(address _nftContract, uint256 tokenId) external view returns (address) {
        return IERC721(_nftContract).getApproved(tokenId);
    }

    function isApprovedForAll(address _nftContract, address owner, address operator) 
        external 
        view 
        returns (bool) 
    {
        return IERC721(_nftContract).isApprovedForAll(owner, operator);
    }

    function transferFrom(
        address _nftContract,
        address from,
        address to,
        uint256 tokenId
    ) external {
        require(_isOwnerOfNFTContract(msg.sender, _nftContract), "Not authorized to transfer");
        IERC721(_nftContract).transferFrom(from, to, tokenId);
    }

    function _isOwnerOfNFTContract(address user, address nftContract) internal view returns (bool) {
        address[] memory userNFTs = UserNFTs[user];
        for (uint256 i = 0; i < userNFTs.length; i++) {
            if (userNFTs[i] == nftContract) {
                return true;
            }
        }
        return false;
    }
    function getNFTDetails(address _nftContract)
        external
        view  
        returns (string memory, string memory,uint256)
    {
        return (
            NFTBase(_nftContract).name(),
            NFTBase(_nftContract).symbol(),
            NFTBase(_nftContract).initialSupply()
        );
    }
}
