import test from 'ava';
import promisify from 'es6-promisify';

const deployContract = require('../lib/deploy-contract');
const {HashFunction} = require('../lib/get-contracts');
const makeBlockchain = require('../lib/get-provider');
const Murmur3 = require('../lib/murmur3');

test.beforeEach(t => {
	const {web3, accounts} = makeBlockchain();
	t.context.web3 = web3;
	t.context.accounts = accounts;
});


test('Should convert characters to byte in the same way', async t => {
	const toTest = 'a';
	const parameters = ['xyz', 0];
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		HashFunction,
		parameters
	);
	const result = await promisify(contract.getSolidityByte)(toTest);
	t.is(toTest.charCodeAt(0), result.toNumber())
});

test('Should compile', async t => {
	const parameters = ['ABC', 1];
	await deployContract(
		t.context.web3,
		t.context.accounts[0],
		HashFunction,
		parameters
	);
	t.pass();
});

test('Should hash correctly', async t => {
	const parameters = ['Ethereum', 1];
	const jsResult = new Murmur3('Ethereum', 1).result();
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		HashFunction,
		parameters
	);
	const hash = await promisify(contract.result)();
    t.is(jsResult, hash.toNumber());
});
