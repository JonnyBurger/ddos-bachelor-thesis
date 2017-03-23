const meow = require('meow');
const deployContract = require('./lib/deploy-contract');
const estimateGas = require('./lib/estimate-gas');
const contracts = require('./lib/get-contracts');
const getProvider = require('./lib/get-provider');
const gasBenchmark = require('./lib/gas-benchmark');

const cli = meow(`
    Commands:
        estimate-gas [contract]
        deploy-contract [contract]
        gas-benchmark --count=x (default x = 100)
`);

const {web3, accounts} = getProvider();

(() => {
    switch (cli.input[0]) {
        case 'estimate-gas':
            return estimateGas(web3, contracts[cli.input[1]]);
        case 'deploy-contract':
            return deployContract(web3, accounts[0], contracts[cli.input[1]]);
        case 'gas-benchmark':
            if (!cli.flags.count && cli.flags.count !== 0) {
                throw new Error('--count flag mandatory');
            }
            return gasBenchmark(web3, accounts, cli.flags.count);
        default:
            return Promise.resolve(cli.help);
    }
})()
.then(output => console.log(output))
.catch(err => console.error(err));
