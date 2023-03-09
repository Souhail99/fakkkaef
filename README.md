# fakkkaef

useEffect(() => {
    fetch(url)
      .then(response => response.json())
      .then(data => {
        setMaDonnee(data);
      })
      .catch(error => {
        console.error('Une erreur est survenue', error);
      });
  }, []);

  console.log(maDonnee);

