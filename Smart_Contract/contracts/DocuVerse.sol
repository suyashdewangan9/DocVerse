// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract DocuVerse {

    struct documentVersion {
        uint256 timestamp;
        string remark;
        string ipfsHash;
    }

    struct Document {
        string documentName;
        uint256 latestVersion;
        uint256[] allVersionIDs;
        mapping(uint256 => documentVersion) versions; // Document ID to version mapping
    }

    struct User {
        string userName;
        uint256[] allDocumentIDs;
        mapping(uint256 => Document) documents; // Document ID to document mapping
    }

    mapping(string => User) public users;
    mapping(string => bool) public register;

    // modifier onlyOwner(address userAddress) {
    //     require(_userID == userAddress, "Only owner can modify data");
    //     _;
    // }

    function addUser(string memory _userName, string memory _userID) public {

        require(register[_userID] == false, "User is already registered");

        users[_userID].userName = _userName;
        register[_userID] = true;

    }

    function addDocument(string memory _ipfsHash, string memory _documentName, uint256 _documentID, string memory _versionRemark, string memory _userID) public{

        require(register[_userID] == true, "User doesn't exist");

        require(users[_userID].allDocumentIDs.length < _documentID, "Document with documentID already present,please use unique documentID");


        users[_userID].allDocumentIDs.push(_documentID);

        users[_userID].documents[_documentID].documentName = _documentName;
        users[_userID].documents[_documentID].latestVersion = 1;
        users[_userID].documents[_documentID].allVersionIDs.push(1);
        users[_userID].documents[_documentID].versions[1].timestamp = block.timestamp;
        users[_userID].documents[_documentID].versions[1].remark = _versionRemark;
        users[_userID].documents[_documentID].versions[1].ipfsHash = _ipfsHash;

    }

    function updateDocument(string memory _ipfsHash, uint256 _documentID, string memory _versionRemark, string memory _userID) public{

        require(register[_userID] == true, "User doesn't exist");

        require(users[_userID].allDocumentIDs.length >= _documentID, "Document with documentID doesn't present,please use add document to add new document");

        

        uint256 lVersion = ++users[_userID].documents[_documentID].latestVersion;

        users[_userID].documents[_documentID].allVersionIDs.push(lVersion);
        users[_userID].documents[_documentID].versions[lVersion].timestamp = block.timestamp;
        users[_userID].documents[_documentID].versions[lVersion].remark = _versionRemark;
        users[_userID].documents[_documentID].versions[lVersion].ipfsHash = _ipfsHash;

    }

    struct rvers{
        
        uint256 timestamp;
        string remark;
        string ipfsHash;
        
    }

    struct rdoc{
        uint256 docID;
        string docName;
        rvers[] versionList;
    }

    function getDocuments (string memory _userID) public view returns ( rdoc[] memory){

        require(register[_userID] == true, "User doesn't exist");

        // users[_userID].documents;

        // rdoc[] memory docList;

        rdoc[] memory docList = new rdoc[](users[_userID].allDocumentIDs.length);

        for(uint256 i=0;i<users[_userID].allDocumentIDs.length;i++){

            rdoc memory curDoc;
            uint256 latestVersion =users[_userID].documents[i+1].latestVersion;
            curDoc.versionList= new rvers[] (latestVersion);


            curDoc.docName = users[_userID].documents[i+1].documentName;
            curDoc.docID = i+1;


            for(uint256 j=0;j<latestVersion;j++){
                rvers memory curVerse;

                curVerse.timestamp = users[_userID].documents[i+1].versions[j+1].timestamp;

                curVerse.remark = users[_userID].documents[i+1].versions[j+1].remark;

                curVerse.ipfsHash = users[_userID].documents[i+1].versions[j+1].ipfsHash;

                // curDoc.versionList.push(curVerse);
                curDoc.versionList[j] = curVerse;
            }

            docList[i] = curDoc;

        }

        return (docList);
        
    }
}