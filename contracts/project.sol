// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Digital Art Authentication System
 * @dev A smart contract that allows artists to register and authenticate their digital artwork
 */
contract DigitalArtAuthentication {
    address public owner;
    uint256 private artworkCount;
    
    // Artwork structure
    struct Artwork {
        uint256 id;
        string title;
        string description;
        string ipfsHash;      // Hash of the artwork stored on IPFS
        string metadataHash;  // Hash of metadata stored on IPFS
        uint256 creationTime;
        address artist;
        bool isAuthenticated;
        string signatureHash;  // Artist's cryptographic signature
    }
    
    // Artist structure
    struct Artist {
        address artistAddress;
        string name;
        string bio;
        string website;
        bool isVerified;
        uint256 registrationTime;
        uint256[] artworks;   // IDs of artworks created by this artist
    }
    
    // Mappings
    mapping(uint256 => Artwork) public artworks;
    mapping(address => Artist) public artists;
    mapping(string => bool) public usedIPFSHashes;
    
    // Events
    event ArtistRegistered(address indexed artistAddress, string name);
    event ArtworkRegistered(uint256 indexed artworkId, address indexed artist, string title, string ipfsHash);
    event ArtworkAuthenticated(uint256 indexed artworkId, address indexed authenticator);
    event ArtistVerified(address indexed artistAddress);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }
    
    modifier onlyArtist() {
        require(artists[msg.sender].artistAddress == msg.sender, "Only registered artists can call this function");
        _;
    }
    
    modifier artworkExists(uint256 _artworkId) {
        require(_artworkId > 0 && _artworkId <= artworkCount, "Artwork does not exist");
        _;
    }
    
    /**
     * @dev Constructor sets the contract owner
     */
    constructor() {
        owner = msg.sender;
        artworkCount = 0;
    }
    
    /**
     * @dev Transfer ownership of the contract
     * @param _newOwner address of the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
    
    /**
     * @dev Register a new artist
     * @param _name artist's name
     * @param _bio artist's biography
     * @param _website artist's website
     */
    function registerArtist(string memory _name, string memory _bio, string memory _website) public {
        require(artists[msg.sender].artistAddress == address(0), "Artist already registered");
        
        uint256[] memory emptyArray = new uint256[](0);
        
        artists[msg.sender] = Artist({
            artistAddress: msg.sender,
            name: _name,
            bio: _bio,
            website: _website,
            isVerified: false,
            registrationTime: block.timestamp,
            artworks: emptyArray
        });
        
        emit ArtistRegistered(msg.sender, _name);
    }
    
    /**
     * @dev Register a new artwork
     * @param _title artwork title
     * @param _description artwork description
     * @param _ipfsHash IPFS hash of the artwork
     * @param _metadataHash IPFS hash of the artwork metadata
     * @param _signatureHash cryptographic signature of the artist
     */
    function registerArtwork(
        string memory _title,
        string memory _description,
        string memory _ipfsHash,
        string memory _metadataHash,
        string memory _signatureHash
    ) public onlyArtist {
        require(bytes(_ipfsHash).length > 0, "IPFS hash cannot be empty");
        require(!usedIPFSHashes[_ipfsHash], "This artwork has already been registered");
        
        artworkCount++;
        
        artworks[artworkCount] = Artwork({
            id: artworkCount,
            title: _title,
            description: _description,
            ipfsHash: _ipfsHash,
            metadataHash: _metadataHash,
            creationTime: block.timestamp,
            artist: msg.sender,
            isAuthenticated: false,
            signatureHash: _signatureHash
        });
        
        // Add artwork to artist's collection
        artists[msg.sender].artworks.push(artworkCount);
        
        // Mark IPFS hash as used
        usedIPFSHashes[_ipfsHash] = true;
        
        emit ArtworkRegistered(artworkCount, msg.sender, _title, _ipfsHash);
    }
    
    /**
     * @dev Authenticate an artwork (only contract owner can do this)
     * @param _artworkId ID of the artwork to authenticate
     */
    function authenticateArtwork(uint256 _artworkId) public onlyOwner artworkExists(_artworkId) {
        require(!artworks[_artworkId].isAuthenticated, "Artwork is already authenticated");
        
        artworks[_artworkId].isAuthenticated = true;
        
        emit ArtworkAuthenticated(_artworkId, msg.sender);
    }
    
    /**
     * @dev Verify an artist (only contract owner can do this)
     * @param _artistAddress address of the artist to verify
     */
    function verifyArtist(address _artistAddress) public onlyOwner {
        require(artists[_artistAddress].artistAddress == _artistAddress, "Artist does not exist");
        require(!artists[_artistAddress].isVerified, "Artist is already verified");
        
        artists[_artistAddress].isVerified = true;
        
        emit ArtistVerified(_artistAddress);
    }
    
    /**
     * @dev Get artwork details
     * @param _artworkId ID of the artwork
     */
    function getArtwork(uint256 _artworkId) public view artworkExists(_artworkId) returns (
        uint256 id,
        string memory title,
        string memory description,
        string memory ipfsHash,
        string memory metadataHash,
        uint256 creationTime,
        address artist,
        bool isAuthenticated,
        string memory signatureHash
    ) {
        Artwork memory artwork = artworks[_artworkId];
        
        return (
            artwork.id,
            artwork.title,
            artwork.description,
            artwork.ipfsHash,
            artwork.metadataHash,
            artwork.creationTime,
            artwork.artist,
            artwork.isAuthenticated,
            artwork.signatureHash
        );
    }
    
    /**
     * @dev Get artist details
     * @param _artistAddress address of the artist
     */
    function getArtist(address _artistAddress) public view returns (
        string memory name,
        string memory bio,
        string memory website,
        bool isVerified,
        uint256 registrationTime,
        uint256[] memory artworkIds
    ) {
        require(artists[_artistAddress].artistAddress == _artistAddress, "Artist does not exist");
        
        Artist memory artist = artists[_artistAddress];
        
        return (
            artist.name,
            artist.bio,
            artist.website,
            artist.isVerified,
            artist.registrationTime,
            artist.artworks
        );
    }
    
    /**
     * @dev Get the number of artworks registered by an artist
     * @param _artistAddress address of the artist
     */
    function getArtistArtworkCount(address _artistAddress) public view returns (uint256) {
        require(artists[_artistAddress].artistAddress == _artistAddress, "Artist does not exist");
        
        return artists[_artistAddress].artworks.length;
    }
    
    /**
     * @dev Check if an artwork is authentic
     * @param _artworkId ID of the artwork
     */
    function isArtworkAuthentic(uint256 _artworkId) public view artworkExists(_artworkId) returns (bool) {
        return artworks[_artworkId].isAuthenticated;
    }
    
    /**
     * @dev Verify artwork ownership
     * @param _artworkId ID of the artwork
     * @param _claimedArtist address of the claimed artist
     */
    function verifyArtworkOwnership(uint256 _artworkId, address _claimedArtist) public view artworkExists(_artworkId) returns (bool) {
        return artworks[_artworkId].artist == _claimedArtist;
    }
    
    /**
     * @dev Get total number of registered artworks
     */
    function getTotalArtworks() public view returns (uint256) {
        return artworkCount;
    }
}
