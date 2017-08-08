const {Address6} = require('ip-address');
const contracts = require('./get-contracts');
const deployContract = require('./deploy-contract');

const {IpPointerContract} = contracts;

const start = async (
    web3,
    accounts
) => {
    const contract = await deployContract(
        web3,
        accounts[0],
        IpPointerContract,
        [new Address6('::127.0.0.1').bigInteger().toString(), 128]
    );

    await new Promise((resolve, reject) => {
        contract.createCustomer(
            accounts[1].address,
            new Address6('::127.0.0.1').bigInteger().toString(),
            128,
            {
                from: accounts[0].address,
                gas: 1000000
            },
            (err, data) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(data);
                }
            }
        );
    });
    const hash = await new Promise((resolve, reject) => {
        contract.setPointer(
            'http://csg.uzh.ch',
            new Address6('::127.0.0.1').bigInteger().toString(),
            128,
            (Date.now() / 1000) + 50000,
            '9b96a1fe1d548cbbc960cc6a0286668fd74a763667b06366fb2324269fcabaa4',
            {
                from: accounts[1].address,
                gas: 1000000
            },
            (err, data) => {
                if (err) {
                    reject(err);
                } else {
                    resolve(data);
                }
            }
        );
    });
    const {gasUsed} = await new Promise((resolve, reject) => {
        web3.eth.getTransactionReceipt(hash, (err, data) => {
            if (err) {
                reject(err);
            } else {
                resolve(data);
            }
        });
    });
    return `${gasUsed} to update pointer`;
};

module.exports = start;
