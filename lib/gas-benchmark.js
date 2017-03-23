const ip = require('ip');
const contracts = require('./get-contracts');
const deployContract = require('./deploy-contract');
const estimateTransactionGas = require('./estimate-transaction-gas');
const {ReferenceContract} = contracts;

const start = async (web3, accounts, HOW_MANY_IP_ADDRESSES = 10) => {
	const input = new Array(HOW_MANY_IP_ADDRESSES)
		.fill(null)
		.map((a, i) => `127.0.0.${i + 1}`)
		.map(ip.toLong);

	const parameters = [ip.toLong('127.0.0.1'), 0, 'abc'];
	const contract = await deployContract(web3, accounts[0], ReferenceContract, parameters);
	await new Promise((resolve, reject) => {
		contract.createCustomerIPv4(
			accounts[1].address,
		    ip.toLong('127.0.0.0'),
		    28,
		    {
		    	from: accounts[0].address,
		    	gas: 1000000
		    }, (err, data) => {
		    	if (err) { reject(err); }
		    	else { resolve(data); }
		    }
		);
	});
	const hash = await new Promise((resolve, reject) => {
		contract.blockIPv4(input, parseInt(Date.now() / 1000, 10), {
			from: accounts[1].address,
			gas: 3140000
		}, (err, data) => {
			if (err) { reject(err); }
			else { resolve(data); }
		});
	});
	const {gasUsed} = await new Promise((resolve, reject) => {
		web3.eth.getTransactionReceipt(hash, (err, data) => {
			if (err) { reject(err); }
			else { resolve(data); }
		});
	});
	return `${gasUsed} gas for ${HOW_MANY_IP_ADDRESSES} ip addresses`;
};

module.exports = start;
