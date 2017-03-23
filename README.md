## Installation
You need `node` installed: https://nodejs.org/en/. At least v7.7, which is brand new, so make sure it's up to date (`node -v`).

In this folder, run `npm install` to fetch the dependencies. (You also have `npm` if you have `node`). That should be all.

## Run examples

Run the tests (which you can edit in the `test` folder):

```
npm test
```

## CLI

I'm building a CLI.

```sh
> node index.js estimate-gas BasicContract
> node index.js deploy-contract ReferenceContract
```

## Performing benchmarks

Runs a benchmark on `ReferenceContract`.  
The amount of IP addresses to store is configurable.  
For more configuration, you need to open the file `lib/gas-benchmark`.  
The return value is the gas estimate for the transaction cost without the deploy cost.

```sh
node index.js gas-benchmark --count=x # (default x = 100)
```
