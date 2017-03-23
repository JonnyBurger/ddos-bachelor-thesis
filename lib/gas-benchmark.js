const ip = require('ip');
const promisify = require('es6-promise');
const contracts = require('./get-contracts');
const deployContract = require('./deploy-contract');
const estimateTransactionGas = require('./estimate-transaction-gas');
const {ReferenceContract} = contracts;

const start = async (web3, accounts, HOW_MANY_IP_ADDRESSES = 100) => {
	const input = new Array(HOW_MANY_IP_ADDRESSES)
		.fill(null)
		.map((a, i) => `127.0.0.${i + 1}`)
		.map(ip.toLong);

	const contract = await deployContract(web3, accounts[0], ReferenceContract);
	const gas = await estimateTransactionGas(contract, accounts[1], 'blockIPv4', [input, Math.floor(Date.now() / 1000) + 1000]);
	return `${gas} gas for ${HOW_MANY_IP_ADDRESSES} ip addresses`;
};

module.exports = start;
