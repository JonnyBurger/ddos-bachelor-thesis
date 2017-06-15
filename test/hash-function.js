import test from 'ava';
import promisify from 'es6-promisify';

const deployContract = require('../lib/deploy-contract');
const {BloomFilter} = require('../lib/get-contracts');
const makeBlockchain = require('../lib/get-provider');
const Murmur3 = require('../lib/murmur3');

test.beforeEach(t => {
	const {web3, accounts} = makeBlockchain();
	t.context.web3 = web3;
	t.context.accounts = accounts;
});

test('Should convert characters to byte in the same way', async t => {
	const toTest = 'a';
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		BloomFilter
	);
	const result = await promisify(contract.getSolidityByte)(toTest);
	t.is(toTest.charCodeAt(0), result.toNumber());
});

test('Should compile', async t => {
	await deployContract(
		t.context.web3,
		t.context.accounts[0],
		BloomFilter
	);
	t.pass();
});

test('Should hash correctly', async t => {
	const parameters = ['Ethereum', 1];
	const jsResult = 760066800;
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		BloomFilter
	);
	const hash = await promisify(contract.hashFn)(...parameters);
    t.is(jsResult, hash.toNumber());
});

test('Should hash consistently', async t => {
	const parameters = ['Ethereum', 1];
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		BloomFilter
	);
	const hash = await promisify(contract.hashFn)(...parameters);
	const hash2 = await promisify(contract.hashFn)(...parameters);
    t.is(hash2.toNumber(), hash.toNumber());
});

test('Bloomfilter test', async t => {
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		BloomFilter
	);
	await promisify(contract.clear)(
		{
			from: t.context.accounts[0].address,
			gas: 1000000
		}
	);
	await promisify(contract.addOne)(
		'Eth', {
		from: t.context.accounts[0].address,
		gas: 3000000
	});
	const hash = await (promisify(contract.has)('Eth'));
	t.true(hash);
	const hash2 = await (promisify(contract.has)('Bitcoin'));
	t.false(hash2);
});

// [8, 88, 100, 110, 31, 35, 30]
