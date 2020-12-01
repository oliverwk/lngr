# NKD lngr

## About
I, wanted to have website/app to help me choose Lingrie because there is just so much! yes, this is about Lingrie so be prepared. This module is for lingerie from `nakd` i plan to expand this in the future ; )

## Features

- Easy to use API.
- Out put in `json` or in human readable format
- Use native promise and async functions.
- lightweight

## Installation

Just install with npm
```sh
$ npm install nkd
```

## Loading and configuring the module

```js
// CommonJS
const nkd = require('nkd');

// ES Module
import nkd from 'nkd';
```
##  Usage

NOTE: The documentation below is up-to-date with node 15.1
### JSON

```js
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
```

### Plain human readable text

```js
const nkd = require('nkd');

(async () => {
	const lingeries = await nkd.GetLingerie("human");
	console.log(lingeries);
})();
```
# nkd lngr
