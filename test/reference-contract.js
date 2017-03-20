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
    const parameters = [1234, 123456, 'abc'];
    await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
    t.pass();
});

test.failing('Should not be able to deploy with wrong parameter types', async t => {
    const parameters = [473432984723947023942034324234234, 324732894, 'abc'];
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
    await promisify(contract.blockIPv4)(
        [ip.toLong('123.45.67.89')],
        parseInt(Date.now() / 1000, 10),
        {
            from: t.context.accounts[0].address,
            gas: 1000000
        }
    );
    const ips = await promisify(contract.blockedIPv4)();
    t.is(ip.fromLong(parseInt(ips[0][0], 10)), '123.45.67.89');
});

test('Should be to create customer IPv4 if in same subnet', async t => {
    const parameters = [ip.toLong('123.45.67.89'), 24, 'abc'];
    const contract = await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
    await promisify(contract.createCustomerIPv4)(
        t.context.accounts[1].address,
        ip.toLong('123.45.67.99'),
        28,
        {
            from: t.context.accounts[0].address,
            gas: 1000000
        }
    );
});

test('Should not be able to create customer IPv4 if not owner', async t => {
    const parameters = [ip.toLong('123.45.67.89'), 24, 'abc'];
    const contract = await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
    
    // We expect an error when registering an customer IP
    try {
        await promisify(contract.createCustomerIPv4)(
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

test('Should not be able to create customer IPv4 if not in same subnet', async t => {
    const parameters = [ip.toLong('123.45.67.89'), 24, 'abc'];
    const contract = await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);

    // We expect an error when registering an customer IP
    try {
        await promisify(contract.createCustomerIPv4)(
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
        await deployContract(t.context.web3, t.context.accounts[0], ReferenceContract, parameters);
        t.fail();
    } catch (err) {
        t.pass();
    }
});
