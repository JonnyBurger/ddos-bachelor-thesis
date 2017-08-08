const test = require('ava');
const Web3 = require('web3');
const solc = require('solc');
const path = require('path');
const fs = require('fs');
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

test.cb('Greeter should greet', t => {
    t.plan(1);
    const code = fs.readFileSync(path.join(__dirname,   '../contracts/Greeter.sol'), 'utf8');
    const compiled = solc.compile(code, 1);
    const contract = compiled.contracts[':greeter'];
    const Greeter = t.context.web3.eth.contract(JSON.parse(contract.interface));

    let i = 0;
    Greeter.new(
        'Hello!',
        {
            from: t.context.accounts[0].address,
            data: contract.bytecode,
            gas: 1000000
        },
        (err, myContract) => {
            i++;
            if (err) {
                throw err;
            } else if (i === 2) {
                // The callback happens twice:
                // Once when submitted, once when mined
                myContract.greet((err, greeting) => {
                    t.is(greeting, 'Hello!');
                    t.end()
                });
            }
        }
    )
});
