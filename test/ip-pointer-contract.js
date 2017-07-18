import test from 'ava';
import ip from 'ip';
import promisify from 'es6-promisify';

const deployContract = require('../lib/deploy-contract');
const {IpPointerContract} = require('../lib/get-contracts');
const makeBlockchain = require('../lib/get-provider');

const makeTransaction = ({contract, name, args, from}) => {
  return promisify(contract[name])(...args, {
    from,
    gas: 1000000
  });
};

const getMapping = ({contract, name, index}) => {
  return promisify(contract[name])(index);
};

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
    IpPointerContract,
    parameters
  );
  t.pass();
});

test('Should be able to get blocked URLs', async t => {
  const parameters = [ip.toLong('123.45.67.89'), 24];
  const contract = await deployContract(
    t.context.web3,
    t.context.accounts[0],
    IpPointerContract,
    parameters
  );

  await makeTransaction({
    name: 'createCustomer',
    args: [t.context.accounts[1].address, ip.toLong('123.45.67.89'), 28],
    from: t.context.accounts[0].address,
    contract
  });

  await makeTransaction({
    name: 'setPointer',
    args: ['http://hithere.com'],
    from: t.context.accounts[1].address,
    contract
  });

  const [, pointer] = await getMapping({
    contract,
    name: 'reports',
    index: t.context.accounts[1].address
  });

  t.is(pointer, 'http://hithere.com');
});
