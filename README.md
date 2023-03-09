# fakkkaef

fetch(url)
  .then(response => response.json())
  .then(data => {
    const maVariable = data;
    // Traitement des données
  })
  .catch(error => {
    console.error('Une erreur est survenue', error);
  });


