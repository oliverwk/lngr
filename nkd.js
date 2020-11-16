const fetch = require('node-fetch');
//var JSSoup = require('jssoup').default;

(async () => {
  page = await fetch("https://www.na-kd.com/nl/lingerie/onderbroeken?sortBy=price").catch((err) => { console.error(err) });
  pages = await page.text()
  //var soup = new JSSoup(pages);
  console.log(pages.querySelector("#\\32  > div.sg-plp-image-container.qj.qt.qbn > a > div"));
})().catch((err) => { console.error(err) });
