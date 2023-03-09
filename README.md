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
