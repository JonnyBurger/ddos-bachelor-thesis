const solc = require('solc');
const path = require('path');
const fs = require('fs');

test.cb('Greeter should greet', t => {
    t.plan(1); // Expect 1 assertion
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
            // The callback happens twice:
            // Once when submitted, once when mined
            i++;
            if (err) {
                throw err;
            } else if (i === 2) {
                // Call a method
                myContract.greet((err, greeting) => {
                    t.is(greeting, 'Hello!');
                    t.end()
                });
            }
        }
    )
});
