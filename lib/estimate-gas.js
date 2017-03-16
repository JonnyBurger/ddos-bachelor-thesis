const Web3 = require('web3');
const solc = require('solc');
const promisify = require('es6-promisify');
const TestRPC = require('ethereumjs-testrpc');

const web3 = new Web3(TestRPC.provider());
const estimateGas = promisify(web3.eth.estimateGas);

const estimateContractGas = file => {
    const compiledContract = solc.compile(file, 1);
    const {bytecode} = compiledContract.contracts[Object.keys(compiledContract.contracts)[0]];
    return estimateGas({data: `0x${bytecode}`});
};

module.exports = estimateContractGas;
