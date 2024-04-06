
const express = require('express');
const {v5} = require('uuid');
// const ipfsClient = require('ipfs-http-client');
const {Web3} = require('web3');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const User =require('./database.js');

require('dotenv').config();

const port = process.env.port || 3000;

const app = express();

// Connect to Ganache
const web3 = new Web3(new Web3.providers.HttpProvider(process.env.RPC_URL));

// Set up IPFS client
// const ipfs = IPFS.create({ host: 'ipfs.infura.io', port: 5001, protocol: 'https' });

// Import the compiled JSON artifact of your smart contract
const MyContract = require("../Smart_Contract/artifacts/contracts/DocuVerse.sol/DocuVerse.json");

// // Get the deployed contract instance
const contractAddress = process.env.CONTRACT_ADDRESS; // Address where your contract is deployed
const myContract = new web3.eth.Contract(MyContract.abi, contractAddress);

// Example function to interact with the contract and IPFS
async function exampleFunction() {
    try {
        // Example: Interact with the smart contract
        const accounts = await web3.eth.getAccounts();
        const contractOwner = accounts[0];

        console.log(contractOwner);

        const methods = await myContract.methods;
        console.log(methods);

        // // Example: Call a contract function
        // const result = await myContract.methods.myFunction().call({ from: contractOwner });
        // console.log('Result from smart contract:', result);

        // // Example: Upload file to IPFS
        // const fileContent = Buffer.from('Hello IPFS!');
        // const ipfsResult = await ipfs.add(fileContent);
        // console.log('File uploaded to IPFS. CID:', ipfsResult.cid.toString());

        // // Example: Get file from IPFS
        // const ipfsFile = await ipfs.cat(ipfsResult.cid.toString());
        // console.log('Content retrieved from IPFS:', ipfsFile.toString());
    } catch (error) {
        console.error('Error:', error);
    }
}

// Run the example function
exampleFunction();


app.post('/createUser',async (req,res)=>{
    const userName = req.body.userName;
    const password = req.body.password;
    try{
        const user= await User.findOne({
            userName: userName
        })
    
        if(user==null){
            const MY_NAMESPACE = '1b671a64-40d5-491e-99b0-da01ff1f3341';
            const newUser = new User( {
                userName: userName,
                password: password,
                userId: v5(userName, MY_NAMESPACE)
            });
            await newUser.save();
            const result = await myContract.methods.addUser(userName,userID);
            console.log("results from smart contract:" +result);
            
        }
        else{
            res.send("UserName is already exist try different user name");
        }
    }
    catch(error){
        console.log(error.message);
    }
    
})

app.post('/addDocument',upload.single('file'),(req,res)=>{

    console.log(req.file);

    res.send("File Uploaded Successfully");
    
})

app.get('/documents',(req,res)=>{

})


app.listen(port,()=>{
    console.log("Server Started At Port:"+port);
});