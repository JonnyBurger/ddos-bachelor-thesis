import test from 'ava';
import promisify from 'es6-promisify';

const estimateGas = require('../lib/estimate-gas');
const deployContract = require('../lib/deploy-contract');
const {ReferenceContract} = require('../lib/get-contracts');
const makeBlockchain = require('../lib/get-provider');

test.beforeEach(t => {
    const {web3, accounts} = makeBlockchain();
    t.context.web3 = web3;
    t.context.accounts = accounts;
});

test('Should have estimated gas between 700,000 and 800,000', async t => {
    const gasCost = await estimateGas(t.context.web3, ReferenceContract);
    t.true(gasCost < 800000);
    t.true(gasCost > 700000);
});

test('Should be able to deploy with correct parameters', async t => {
    const parameters = [1234, 123456];
    await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
    t.pass();
});

test.failing('Should not be able to deploy with wrong parameter types', async t => {
    const parameters = [473432984723947023942034324234234, 324732894];
    try {
        await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
        t.fail();
    } catch (err) {
        console.log(err);
        t.pass();
    }
});

test('Should be able to get blocked IPs', async t => {
    const parameters = [1234, 123456, 'abc'];
    const contract = await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
    await promisify(contract.blockIPv4)([0x8888], 200, {
        from: t.context.accounts[0].address,
        gas: 1000000
    });
    console.log(await promisify(contract.blockedIPv4)());
});
