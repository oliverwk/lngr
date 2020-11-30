const cheerio = require('cheerio');
const fetch = require('node-fetch');

exports.GetLingerie = async function() {
    const page = await fetch("https://www.na-kd.com/nl/lingerie--nachtkleding/onderbroeken?sortBy=price");
    console.log(page.status);
    const $ = cheerio.load(await page.text());
    let Lingerie = [];
    $('div.sg-product-card').each((index, element) =>  {
      var slip = {};
      jsonData = JSON.parse($(element).attr('data-tracking-json'))
      img_el = $('img ', '', element)
      slip["prijs"] = parseFloat(jsonData["price"]);
      slip["naam"] =  jsonData["name"];
      slip["url"] = "https://www.na-kd.com"+$('[data-scope-link=true]', element).attr('href');
      slip["img_url"] = img_el.attr('src');
      slip["img_url_sec"] = img_el.attr('src').replace("01j","04k");
      slip["kleur"] = jsonData["variant"];
      Lingerie.push(slip);
    });
    return new Promise(resolve => {
     resolve(Lingerie);
   });
}
