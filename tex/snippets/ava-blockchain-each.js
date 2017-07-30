const test = require('ava');
const Web3 = require('web3');
const TestRPC = require('ethereumjs-testrpc');

const makeBlockchain = () => {
    const provider = TestRPC.provider({total_accounts: 2});
    const {unlocked_accounts} = provider.manager.state;
    
    return {
        web3: new Web3(provider),
        accounts: Object.keys(unlocked_accounts).map(acc => unlocked_accounts[acc])
    };
};

test.beforeEach(t => {
    const {web3, accounts} = makeBlockchain();
    t.context.web3 = web3;
    t.context.accounts = accounts;
});
