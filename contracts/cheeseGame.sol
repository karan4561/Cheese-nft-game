// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CheeseGame is ERC721Enumerable {
    address owner;
    uint256 duration;
    uint256 counter;

    string _baseTokenURI;

    struct checkpoint {
        uint256 tokenID;
        uint256 lastUsed;
        address owner;
    }

    mapping(uint256=>checkpoint) public checkpoints;
    mapping(address=>uint256) public score;

    constructor(string memory _name, string memory _symbol,string memory _tokenURI)
     ERC721(_name, _symbol){

        owner = msg.sender;
        duration = 1 days;

        _baseTokenURI = _tokenURI;

        _mint(owner,counter);

        checkpoints[counter] = checkpoint(counter,block.timestamp,owner);
        counter++;

    }

    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }

    modifier canCreateCheese(){
        uint256 _counter = counter-1;
        checkpoint memory c = checkpoints[_counter];
        
        require(c.lastUsed + duration < block.timestamp,"Deadline Error");
        _;
    }

    function _baseURI() override view internal returns(string memory){
        return _baseTokenURI;
    }

    function setTokenURI(string memory uri) public onlyOwner{
        _baseTokenURI = uri;
    }

    function _beforeTokenTransfer(
        address to, 
        address from, 
        uint256 tokenID, 
        uint256 batchSize
    ) virtual internal override {

            uint256 _counter = counter-1;
            checkpoint memory c = checkpoints[_counter];
            require(c.lastUsed + duration > block.timestamp,"Time is Up");
            super._beforeTokenTransfer(to,from, tokenID, batchSize);

    } 

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
        ) internal virtual override{

            checkpoints[tokenId] = checkpoint(tokenId, block.timestamp, to);
            super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    function createCheese() public{
        
        score[ownerOf(counter-1)]++;
        _burn(counter-1);

        _mint(msg.sender, counter);

        checkpoints[counter] = checkpoint(counter, block.timestamp, msg.sender); 

        counter++;
    }

    function getCurrentCheckpoint() public view returns(checkpoint memory c){
        return checkpoints[counter-1];
    }

    function totalSupply() public pure override returns(uint256){
        return 1;
    }

    function _mint(address to, uint256 tokenId) internal override{
        require(to!=address(0),"invalid address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to]++;
        _owners[tokenId]=to;

    }

    function _burn(uint256 tokenID) internal override {
        address Owner = ownerOf(tokenID);

        _balances[Owner]--;

        delete _owners[tokenID];
    }

}