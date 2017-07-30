import test from 'ava';
import ip from 'ip';
import promisify from 'es6-promisify';

const {fnv_1a} = require('bloomfilter');

const deployContract = require('../lib/deploy-contract');
const {BloomFilter2} = require('../lib/get-contracts');
const makeBlockchain = require('../lib/get-provider');

const makeTransaction = ({contract, name, args, from}) => {
	return promisify(contract[name])(...args, {
		from,
		gas: 1000000
	});
};

test.beforeEach(t => {
	const {web3, accounts} = makeBlockchain();
	t.context.web3 = web3;
	t.context.accounts = accounts;
});

test('Does integer division round down', async t => {
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
		BloomFilter2
	);
	const floored = await promisify(contract.floor)(1.5);
	const ceiled = await promisify(contract.ceil)(1.5);
	t.is(floored.toNumber(), 1);
	t.is(ceiled.toNumber(), 2);
});

test.failing('Hashing is correct', async t => {
    const contract = await deployContract(
        t.context.web3,
        t.context.accounts[0],
        BloomFilter2
    );
    const result = await promisify(contract.fnv_1a)('ABC');
    t.is(result.toNumber(), fnv_1a('ABC'));
    const result2 = await promisify(contract.fnv_1a)('DEF');
    t.is(result2.toNumber(), fnv_1a('DEF'));
    t.pass();
});

test.failing('Test Bloom filter', async t => {
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
        BloomFilter2,
        [1024, 4]
    );
	await makeTransaction({
		name: 'add',
		args: ['Bess'],
		from: t.context.accounts[0].address,
		contract
    });
    const isABCAdded = await (promisify(contract.test))('Bess');
    t.true(isABCAdded);
    const isDEFAdded = await (promisify(contract.test))('Jane');
    t.false(isDEFAdded);
});
