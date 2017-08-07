const {Address6} = require('ip-address');
const contracts = require('./get-contracts');
const deployContract = require('./deploy-contract');
const makeNIPs = require('./make-n-ips');
const {ReferenceContract} = contracts;

const start = async (
	web3,
	accounts,
	HOW_MANY_IP_ADDRESSES = 10,
	multiple = false
) => {
	const input = makeNIPs(HOW_MANY_IP_ADDRESSES);

	const parameters = [new Address6('::127.0.0.1').bigInteger().toString(), 0];
	const contract = await deployContract(
		web3,
		accounts[0],
		ReferenceContract,
		parameters
	);
	await new Promise((resolve, reject) => {
		contract.createCustomer(
			accounts[1].address,
			new Address6('::127.0.0.0').bigInteger().toString(),
			28,
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
	if (multiple) {
		const hash = await new Promise((resolve, reject) => {
			contract.block(
				input,
				input.fill(128),
				parseInt(Date.now() / 1000, 10),
				{
					from: accounts[1].address,
					gas: 3140000
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
		return `${gasUsed} gas for ${HOW_MANY_IP_ADDRESSES} ip addresses (multiple)`;
	}
	const gasCosts = [];
	for (let i of input) {
		const hash = await new Promise((resolve, reject) => {
			contract.block(
				[i],
				[128],
				parseInt(Date.now() / 1000, 10),
				{
					from: accounts[1].address,
					gas: 3140000
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
		gasCosts.push(gasUsed);
	}
	return `${gasCosts.reduce(
		(a, b) => a + b
	)} gas for ${HOW_MANY_IP_ADDRESSES} ip addresses`;
};

module.exports = start;
