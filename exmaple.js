const nkd = require('nkd');

(async () => {
   let average = 0;
	const lingeries = await nkd.GetLingerie();
    lingeries.forEach(lingerie => {
      console.log(lingerie);
      average += lingerie.prijs
    });
	console.log("The average price is:", average / lingeries.length);
})();
