import test from 'ava';
import ip from 'ip';
import promisify from 'es6-promisify';

const deployContract = require('../lib/deploy-contract');
const {ReferenceContract} = require('../lib/get-contracts');
const makeBlockchain = require('../lib/get-provider');

test.beforeEach(t => {
	const {web3, accounts} = makeBlockchain();
	t.context.web3 = web3;
	t.context.accounts = accounts;
});

test('Should be able to deploy with correct parameters', async t => {
	const parameters = [1234, 123456];
	await deployContract(
		t.context.web3,
		t.context.accounts[0],
		ReferenceContract,
		parameters
	);
	t.pass();
});

test('Should not be able to deploy with wrong parameter types', async t => {
	const parameters = ['yayayyaya', 324732894];
	try {
		await deployContract(
			t.context.web3,
			t.context.accounts[0],
			ReferenceContract,
			parameters
		);
		t.fail();
	} catch (err) {
		t.pass();
	}
});

test('Should be able to get blocked IPs', async t => {
	const HOW_MANY_IP_ADDRESSES = 10;
	const input = new Array(HOW_MANY_IP_ADDRESSES)
		.fill(null)
		.map((a, i) => `127.0.0.${i + 1}`)
		.map(ip.toLong);

	const parameters = [ip.toLong('127.0.0.1'), 0];
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		ReferenceContract,
		parameters
	);
	await promisify(contract.createCustomer)(
		t.context.accounts[1].address,
		ip.toLong('127.0.0.0'),
		28,
		{
			from: t.context.accounts[0].address,
			gas: 1000000
		}
	);
	const hash = await promisify(contract.block)(
		input,
		parseInt(Date.now() / 1000, 10),
		{
			from: t.context.accounts[1].address,
			gas: 1000000
		}
	);
	await promisify(t.context.web3.eth.getTransactionReceipt)(hash);
	const ips = await promisify(contract.blocked)();
	t.is(ip.fromLong(parseInt(ips[0][0], 10)), '127.0.0.1');
	t.is(ips[0].length, HOW_MANY_IP_ADDRESSES);
});

test('Should be to create customer if in same subnet', async t => {
	const parameters = [ip.toLong('123.45.67.89'), 24];
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		ReferenceContract,
		parameters
	);

	await promisify(contract.createCustomer)(
		t.context.accounts[1].address,
		ip.toLong('123.45.67.99'),
		28,
		{
			from: t.context.accounts[0].address,
			gas: 1000000
		}
	);
	const customerCount = await promisify(contract.customerCount)();
	t.is(parseInt(customerCount, 10), 1);
});

test('Should not be able to create customer if not owner', async t => {
	const parameters = [ip.toLong('123.45.67.89'), 24];
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		ReferenceContract,
		parameters
	);

	// We expect an error when registering an customer IP
	try {
		await promisify(contract.createCustomer)(
			t.context.accounts[1].address,
			ip.toLong('123.45.67.99'),
			28,
			{
				from: t.context.accounts[1].address, // <-– illegal, we are not sending it from the owner IP
				gas: 1000000
			}
		);
		t.fail();
	} catch (err) {
		t.pass();
	}
});

test('Should not be able to create customer if not in same subnet', async t => {
	const parameters = [ip.toLong('123.45.67.89'), 24];
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		ReferenceContract,
		parameters
	);

	// We expect an error when registering an customer IP
	try {
		await promisify(contract.createCustomer)(
			t.context.accounts[1].address,
			ip.toLong('123.45.67.99'),
			20, // Subnet too wide
			{
				from: t.context.accounts[0].address,
				gas: 1000000
			}
		);
		t.fail();
	} catch (err) {
		t.pass();
	}
});

test.failing('Should crash when omitting constructor parameters', async t => {
	const parameters = [ip.toLong('123.45.67.89'), 24];
	try {
		await deployContract(
			t.context.web3,
			t.context.accounts[0],
			ReferenceContract,
			parameters
		);
		t.fail();
	} catch (err) {
		t.pass();
	}
});
