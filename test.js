const nkd = require('./index.js');
const fetch = require('node-fetch');

(async () => {
	let response = await fetch('https://raw.githubusercontent.com/oliverwk/wttpknng/master/SwimWear.json');
  let repsonse_text = await response.text()
  let nkd_page = await nkd.GetLingerie();
  console.log("nkd_page: ", String(nkd_page));
  console.log("repsonse_text: ", String(repsonse_text));
  if (String(nkd_page) != String(repsonse_text))  {
      console.log("The aren't the same");
    } else {
      console.log("The are the same");
    }
})();
