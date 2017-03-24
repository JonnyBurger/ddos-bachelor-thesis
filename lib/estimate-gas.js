const solc = require('solc');
const promisify = require('es6-promisify');

const estimateContractGas = (web3, file) => {
    const compiledContract = solc.compile(file, 1);
    if (compiledContract.errors) {
    	throw new Error(compiledContract.errors[0]);
    }
    const {bytecode} = compiledContract.contracts[Object.keys(compiledContract.contracts)[0]];
    return promisify(web3.eth.estimateGas)({data: `0x${bytecode}`});
};

module.exports = estimateContractGas;
