const Web3 = require('web3');
const TestRPC = require('ethereumjs-testrpc');

const provider = TestRPC.provider({
    total_accounts: 1
});

const {unlocked_accounts} = provider.manager.state;

exports.account = unlocked_accounts[Object.keys(unlocked_accounts)[0]];
exports.web3 = new Web3(provider);
