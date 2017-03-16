const solc = require('solc');
const {web3, account} = require('./get-provider');
const estimateGas = require('./estimate-gas');

const deployContract = async file => {
    const compiledContract = solc.compile(file, 1);
    const contract = compiledContract.contracts[Object.keys(compiledContract.contracts)[0]];
    const gasEstimate = await estimateGas({data: contract.bytecode});
    const MyContract = web3.eth.contract(JSON.parse(contract.interface));
    return new Promise((resolve, reject) => {
        let i = 0;
        MyContract.new(
            1234,
            123456,
            {
                from: account.address,
                data: contract.bytecode,
                gas: gasEstimate
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
