var fs = require('fs');
var Web3 = require('web3');
var web3 = new Web3();
var solc = require('solc');

web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

const contract = fs.readFileSync('contractInPaper.sol', 'utf8');

const estimateContractGas = (contract) => {
    const compiledContract = solc.compile(contract, 1);
    const {bytecode} = compiledContract.contracts[Object.keys(compiledContract.contracts)[0]];
    return web3.eth.estimateGas({data: `0x${bytecode}`});
};

console.log(estimateContractGas(contract));
