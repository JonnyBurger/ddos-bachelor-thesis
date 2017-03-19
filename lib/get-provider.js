const Web3 = require('web3');
const TestRPC = require('ethereumjs-testrpc');

module.exports = () => {
    const provider = TestRPC.provider({
        total_accounts: 2
    });

    const {unlocked_accounts} = provider.manager.state;

    return {
        web3: new Web3(provider),
        accounts: Object.keys(unlocked_accounts).map(acc => unlocked_accounts[acc])
    };
};
