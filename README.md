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
