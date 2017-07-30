import test from 'ava';
import ip from 'ip';
import promisify from 'es6-promisify';


const deployContract = require('../lib/deploy-contract');
const {BloomFilter3} = require('../lib/get-contracts');
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

test('Test Bloom filter', async t => {
	const contract = await deployContract(
		t.context.web3,
		t.context.accounts[0],
        BloomFilter3,
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
