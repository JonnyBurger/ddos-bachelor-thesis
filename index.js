const meow = require('meow');
const deployContract = require('./lib/deploy-contract');
const estimateGas = require('./lib/estimate-gas');
const contracts = require('./lib/get-contracts');
const getProvider = require('./lib/get-provider');

const cli = meow(`
    Commands:
        estimate-gas [contract]
        deploy-contract [contract]
`);

const {web3} = getProvider();

(() => {
    switch (cli.input[0]) {
        case 'estimate-gas':
            return estimateGas(web3, contracts[cli.input[1]]);
        case 'deploy-contract':
            return deployContract(web3, contracts[cli.input[1]]);
        default:
            return Promise.resolve(cli.help);
    }
})()
.then(output => console.log(output))
.catch(err => console.error(err));
