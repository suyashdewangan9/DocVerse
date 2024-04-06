
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
        string userID;
        uint256[] allDocumentIDs;
        mapping(uint256 => Document) documents; // Document ID to document mapping
    }

    mapping(address => User) public users;
    mapping(address => bool) public register;

    modifier onlyOwner(address userAddress) {
        require(msg.sender == userAddress, "Only owner can modify data");
        _;
    }

    function addUser(string memory _userName, string memory _userID) public {

        require(register[msg.sender] == false, "User is already registered");

        users[msg.sender].userName = _userName;
        users[msg.sender].userID = _userID;
        register[msg.sender] = true;

    }

    function addDocument(string memory _ipfsHash, string memory _documentName, uint256 _documentID, string memory _versionRemark) public{

        require(register[msg.sender] == true, "User doesn't exist");

        require(users[msg.sender].allDocumentIDs.length < _documentID, "Document with documentID already present,please use unique documentID");


        users[msg.sender].allDocumentIDs.push(_documentID);

        users[msg.sender].documents[_documentID].documentName = _documentName;
        users[msg.sender].documents[_documentID].latestVersion = 1;
        users[msg.sender].documents[_documentID].allVersionIDs.push(1);
        users[msg.sender].documents[_documentID].versions[1].timestamp = block.timestamp;
        users[msg.sender].documents[_documentID].versions[1].remark = _versionRemark;
        users[msg.sender].documents[_documentID].versions[1].ipfsHash = _ipfsHash;

    }

    function updateDocument(string memory _ipfsHash, uint256 _documentID, string memory _versionRemark) public{

        require(register[msg.sender] == true, "User doesn't exist");

        require(users[msg.sender].allDocumentIDs.length >= _documentID, "Document with documentID doesn't present,please use add document to add new document");

        

        uint256 lVersion = ++users[msg.sender].documents[_documentID].latestVersion;

        users[msg.sender].documents[_documentID].allVersionIDs.push(lVersion);
        users[msg.sender].documents[_documentID].versions[lVersion].timestamp = block.timestamp;
        users[msg.sender].documents[_documentID].versions[lVersion].remark = _versionRemark;
        users[msg.sender].documents[_documentID].versions[lVersion].ipfsHash = _ipfsHash;

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

    function getDocuments() public returns( rdoc[] memory ){

        require(register[msg.sender] == true, "User doesn't exist");

        // users[msg.sender].documents;

        // rdoc[] memory docList;

        rdoc[] memory docList = new rdoc[](users[msg.sender].allDocumentIDs.length);

        for(uint256 i=0;i<users[msg.sender].allDocumentIDs.length;i++){

            rdoc memory curDoc;
            uint256 latestVersion =users[msg.sender].documents[i+1].latestVersion;
            curDoc.versionList= new rvers[] (latestVersion);


            curDoc.docName = users[msg.sender].documents[i+1].documentName;
            curDoc.docID = i+1;


            for(uint256 j=0;j<latestVersion;j++){
                rvers memory curVerse;

                curVerse.timestamp = users[msg.sender].documents[i+1].versions[j+1].timestamp;

                curVerse.remark = users[msg.sender].documents[i+1].versions[j+1].remark;

                curVerse.ipfsHash = users[msg.sender].documents[i+1].versions[j+1].ipfsHash;

                // curDoc.versionList.push(curVerse);
                curDoc.versionList[j] = curVerse;
            }

            docList[i] = curDoc;

        }

        return (docList);
        
    }
}