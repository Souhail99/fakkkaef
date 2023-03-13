# fakkkaef

const data = [
  { job: 'Développeur web', address: 'Paris' },
  { job: 'Designer graphique', address: 'Lyon' },
  { job: 'Chef de projet', address: 'Nantes' },
  { job: 'Marketing Manager', address: 'Marseille' },
  { job: 'Ingénieur système', address: 'Toulouse' },
];

localStorage.setItem('myData', JSON.stringify(data));

const myAddress = 'Paris';

// Envoie l'adresse en POST à l'API
fetch('http://monapi.com/maroute', {
  method: 'POST',
  body: JSON.stringify({ address: myAddress }),
  headers: { 'Content-Type': 'application/json' },
})
  .then(response => response.json())
  .then(data => {
    // Vérifie si l'adresse est dans la base de données
    const result = JSON.parse(localStorage.getItem('myData')).find(item => item.address === data.address);
    if (result) {
      console.log('L\'adresse est dans la base de données');
      console.log('Métier associé :', result.job);
    } else {
      console.log('L\'adresse n\'est pas dans la base de données');
    }
  });

const { LocalStorage } = require('node-localstorage');
const localStorage = new LocalStorage('./scratch');

// Remplir la base de données avec 5 lignes
localStorage.setItem('1', JSON.stringify({metier: 'Developpeur', adresse: '10 Rue du Developpeur'}));
localStorage.setItem('2', JSON.stringify({metier: 'Ingenieur', adresse: '20 Rue de l\'Ingenieur'}));
localStorage.setItem('3', JSON.stringify({metier: 'Comptable', adresse: '30 Rue du Comptable'}));
localStorage.setItem('4', JSON.stringify({metier: 'Avocat', adresse: '40 Rue de l\'Avocat'}));
localStorage.setItem('5', JSON.stringify({metier: 'Medecin', adresse: '50 Rue du Medecin'}));

// Fetch la valeur envoyée en POST et vérifier si elle est dans la base de données
const data = localStorage.getItem(key);
if (data) {
  const value = JSON.parse(data);
  const metier = value.metier;
  res.status(200).json({ metier: metier });
} else {
  res.status(404).json({ message: 'Adresse non trouvée' });
}


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address public owner;
    uint public minimumTokensToPropose;
    mapping(address => uint) public balances;
    mapping(uint => Proposal) public proposals;
    uint public numProposals;

    struct Proposal {
        string name;
        string description;
        uint votes;
        bool executed;
    }

    event ProposalCreated(string name, string description);
    event Voted(uint proposalId, address voter);

    constructor(uint _minimumTokensToPropose) {
        owner = msg.sender;
        minimumTokensToPropose = _minimumTokensToPropose;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function createProposal(string memory _name, string memory _description) public {
        require(balances[msg.sender] >= minimumTokensToPropose, "Not enough tokens to propose.");
        numProposals++;
        proposals[numProposals] = Proposal(_name, _description, 0, false);
        emit ProposalCreated(_name, _description);
    }

    function vote(uint _proposalId) public {
        require(balances[msg.sender] > 0, "No tokens to vote.");
        require(_proposalId <= numProposals, "Invalid proposal ID.");
        require(!proposals[_proposalId].executed, "Proposal has already been executed.");
        proposals[_proposalId].votes += balances[msg.sender];
        emit Voted(_proposalId, msg.sender);
    }

    function executeProposal(uint _proposalId) public onlyOwner {
        require(_proposalId <= numProposals, "Invalid proposal ID.");
        require(!proposals[_proposalId].executed, "Proposal has already been executed.");
        require(proposals[_proposalId].votes * 2 > totalSupply(), "Not enough votes to execute proposal.");
        proposals[_proposalId].executed = true;
    }

    function totalSupply() public view returns (uint) {
        uint _totalSupply = 0;
        for (uint i = 0; i < numProposals; i++) {
            _totalSupply += balances[address(i)];
        }
        return _totalSupply;
    }
}
