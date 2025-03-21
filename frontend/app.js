const contractAddress = "0x75500cb8B099f45bC2d7344E33a3C65dd75aAE6b";
const contractABI = [[
	{
		"inputs": [
			{
				"internalType": "bytes32[]",
				"name": "proposalNames",
				"type": "bytes32[]"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [],
		"name": "chairperson",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "delegate",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "voter",
				"type": "address"
			}
		],
		"name": "giveRightToVote",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "proposals",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "name",
				"type": "bytes32"
			},
			{
				"internalType": "uint256",
				"name": "voteCount",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "proposal",
				"type": "uint256"
			}
		],
		"name": "vote",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "voters",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "weight",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "voted",
				"type": "bool"
			},
			{
				"internalType": "address",
				"name": "delegate",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "vote",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winnerName",
		"outputs": [
			{
				"internalType": "bytes32",
				"name": "winnerName_",
				"type": "bytes32"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winningProposal",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "winningProposal_",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]]; // Your contract ABI

let web3;
let contract;

async function init() {
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);
        await window.ethereum.request({ method: "eth_requestAccounts" });
        contract = new web3.eth.Contract(contractABI, contractAddress);
    } else {
        alert("Please install MetaMask to use this feature.");
    }
}

async function registerArtist() {
    const name = document.getElementById("artist-name").value;
    const bio = document.getElementById("artist-bio").value;
    const website = document.getElementById("artist-website").value;
    
    const accounts = await web3.eth.getAccounts();
    await contract.methods.registerArtist(name, bio, website).send({ from: accounts[0] });
}

async function registerArtwork() {
    const title = document.getElementById("artwork-title").value;
    const description = document.getElementById("artwork-description").value;
    const ipfsHash = document.getElementById("ipfs-hash").value;
    const metadataHash = document.getElementById("metadata-hash").value;
    const signatureHash = document.getElementById("signature-hash").value;
    
    const accounts = await web3.eth.getAccounts();
    await contract.methods.registerArtwork(title, description, ipfsHash, metadataHash, signatureHash).send({ from: accounts[0] });
}

async function fetchArtworks() {
    const totalArtworks = await contract.methods.getTotalArtworks().call();
    const container = document.getElementById("artwork-container");
    container.innerHTML = "";

    for (let i = 1; i <= totalArtworks; i++) {
        const artwork = await contract.methods.getArtwork(i).call();
        const listItem = document.createElement("li");
        listItem.textContent = `${artwork[1]} - Authenticated: ${artwork[7]}`;
        container.appendChild(listItem);
    }
}

window.onload = init;
