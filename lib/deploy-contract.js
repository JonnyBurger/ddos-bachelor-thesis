const solc = require('solc');
const estimateGas = require('./estimate-gas');

const deployContract = async (web3, account, file, deployArguments) => {
    const compiledContract = solc.compile(file, 1);
    if (compiledContract.errors) {
        throw new Error(compiledContract.errors[0]);
    }
    const contract = compiledContract.contracts[Object.keys(compiledContract.contracts)[0]];
    const gasEstimate = await estimateGas(web3, file);
    const MyContract = web3.eth.contract(JSON.parse(contract.interface));
    return new Promise((resolve, reject) => {
        let i = 0;
        MyContract.new(
            ...deployArguments,
            {
                from: account.address,
                data: contract.bytecode,
                gas: gasEstimate + 1000000
            },
            (err, myContract) => {
                i++;
                if (err) {
                    reject(err);
                } else if (i === 2) {
                    // The callback happens twice:
                    // Once when submitted, once when mined
                    resolve(myContract);
                }
            }
        );
    });
};

module.exports = deployContract;
