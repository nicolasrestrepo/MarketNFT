//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";
import "./AvatarDNA.sol";

// import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

// TODO: receibe eth by nft 

contract Market is ERC721, ERC721Enumerable, AvatarDNA {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenId;

    uint256 public maxSupply;

    mapping (uint256 => uint256) public tokenDNA;

    constructor(
        uint256 _maxSupply
    ) ERC721("MarketNFT", "MNFT")
    {
        maxSupply = _maxSupply;
    }

    function mint() public payable {
        uint256 currentTokenId = _tokenId.current();

        require(currentTokenId < maxSupply, 'No more NFT availables');
        
        tokenDNA[currentTokenId] = deterministicPseudoRandomDNA(currentTokenId, msg.sender);

        _safeMint(msg.sender, currentTokenId);

        _tokenId.increment();
    }

    function _baseURI() internal pure override returns(string memory){
        return "https://avataaars.io/";
    }

    function _paramsURI(uint256 _dna) internal view returns (string memory) {
    string memory params;

    {
        params = string(
            abi.encodePacked(
                "accessoriesType=",
                getAccessoriesType(_dna),
                "&clotheColor=",
                getClotheColor(_dna),
                "&clotheType=",
                getClotheType(_dna),
                "&eyeType=",
                getEyeType(_dna),
                "&eyebrowType=",
                getEyeBrowType(_dna),
                "&facialHairColor=",
                getFacialHairColor(_dna),
                "&facialHairType=",
                getFacialHairType(_dna),
                "&hairColor=",
                getHairColor(_dna),
                "&hatColor=",
                getHatColor(_dna),
                "&graphicType=",
                getGraphicType(_dna),
                "&mouthType=",
                getMouthType(_dna),
                "&skinColor=",
                getSkinColor(_dna)
            )
        );
    }

    return string(abi.encodePacked(params, "&topType=", getTopType(_dna)));
}

    function imageByDNA(uint256 _dna) public view returns(string memory){
        string memory baseURI = _baseURI();
        string memory paramsURI = _paramsURI(_dna);

        return string(abi.encodePacked(baseURI, "?", paramsURI));

    }

    function tokenURI(uint256 tokenId)
            public
            view
            override
            returns (string memory)
        {
            require(
                _exists(tokenId),
                "ERC721 Metadata: URI query for nonexistent token"
            );

            uint256 dna = tokenDNA[tokenId];
            string memory image = imageByDNA(dna);

            string memory jsonURI = Base64.encode(
                abi.encodePacked(
                    '{ "name": "Market #',
                    tokenId.toString(),
                    '", "description": "MarketNFT are randomized Avataaars stored on chain to teach DApp", "image": "',
                    image,
                    '"}'
                )
            );

            return
                string(abi.encodePacked("data:application/json;base64,", jsonURI));
        }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
