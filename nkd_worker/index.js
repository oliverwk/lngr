var JSSoup = require('jssoup').default;
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})
/**
 * Respond with hello worker text
 * @param {Request} request
 */
async function handleRequest(request) {
  let page = await fetch("https://www.na-kd.com/nl/lingerie--nachtkleding/onderbroeken?sortBy=price").catch((err) => { console.error(err) });
  let pages = await page.text()
  var soup = new JSSoup(pages);
  let products = soup.findAll("div", "sg-product-card");
  let product = soup.find("div", "sg-product-card");
  //console.log("products: "+products);
  console.log(product);
  let data=[]
  for (var i = 0; i < products.length; i++) {
    json_data_el = JSON.parse(products[i]["data-tracking-json"])
    console.log(json_data_el["price"]);
    data.append(json_data_el["price"])
  }
  return new Response(data, {
    headers: { 'content-type': 'text/plain' },
  })
}
