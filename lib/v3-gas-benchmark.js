const contracts = require('./get-contracts');
const deployContract = require('./deploy-contract');
const makeNIPs = require('./make-n-ips');

const {BloomFilter3} = contracts;

const start = async (
    web3,
    accounts,
    HOW_MANY_IP_ADDRESSES = 10,
    multiple = false
) => {
    const input = makeNIPs(HOW_MANY_IP_ADDRESSES);

    const contract = await deployContract(
        web3,
        accounts[0],
        BloomFilter3,
        [false]
    );
    if (multiple) {
        const hash = await new Promise((resolve, reject) => {
            contract.addMultiple(
                input,
                {
                    from: accounts[0].address,
                    gas: 4400000
                },
                (err, hash) => {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(hash);
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
        return `${gasUsed} gas for ${HOW_MANY_IP_ADDRESSES} ip addresses (multiple)`;
    }
    const gasCosts = [];
    for (let ip of input) {
        const {gasUsed} = await new Promise((resolve, reject) => {
            contract.add(
                ip,
                {
                    from: accounts[0].address,
                    gas: 1000000
                },
                (err, hash) => {
                    if (err) {
                        reject(err);
                    } else {
                        web3.eth.getTransactionReceipt(hash, (err, data) => {
                            if (err) {
                                reject(err);
                            }
                            resolve(data);
                        });
                    }
                }
            );
        });
        gasCosts.push(gasUsed);
    }
    return `${gasCosts.reduce((a, b) => a + b, 0)} gas for ${HOW_MANY_IP_ADDRESSES} ip addresses`;
};

module.exports = start;
