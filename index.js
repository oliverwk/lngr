const cheerio = require('cheerio');
const fetch = require('node-fetch');

exports.GetLingerie = async function(sort) {

    const page = await fetch("https://www.na-kd.com/nl/lingerie--nachtkleding/onderbroeken?sortBy=price");
    console.log(page.status);
    const $ = cheerio.load(await page.text());
    let Lingerie = [];
    if (!!sort) {
      console.log(sort);
      $('div.sg-product-card').each((index, element) =>  {

        jsonData = JSON.parse($(element).attr('data-tracking-json'))
        img_el = $('img ', '', element)
        var slip = "De "+jsonData["name"]+" Kost "+jsonData["price"]+" in de kleur "+jsonData["variant"]+" hij ziet er uit als "+img_el.attr('src')+" te vinden op "+"https://www.na-kd.com"+$('[data-scope-link=true]', element).attr('href')+".";
        Lingerie.push(slip);
      });
    } else {
      $('div.sg-product-card').each((index, element) =>  {
        var slip = {};
        jsonData = JSON.parse($(element).attr('data-tracking-json'))
        img_el = $('img ', '', element)
        slip["prijs"] = jsonData["price"];
        slip["naam"] =  jsonData["name"];
        slip["url"] = "https://www.na-kd.com"+$('[data-scope-link=true]', element).attr('href');
        slip["img_url"] = img_el.attr('src');
        slip["img_url_sec"] = img_el.attr('src').replace("01j","04k");
        slip["kleur"] = jsonData["variant"];
        Lingerie.push(slip);
      });
    }
    return new Promise(resolve => {
     resolve(Lingerie);
   });
}
