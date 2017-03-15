var Web3 = require('web3');
var web3 = new Web3();
var solc = require('solc');

web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

const contract = `
pragma solidity 0.4.8;

contract DdosMitigation {
    struct Report {
        address reporter;
        string url;
    }

    address public owner;
    Report[] public reports;

    function DdosMitigation() {
        owner = msg.sender;
    }
    
    function report(string url) {
        reports.push(Report({
            reporter: msg.sender,
            url: url
        }));
    }
}
`;

const estimateContractGas = (contract) => {
    const compiledContract = solc.compile(contract, 1);
    const {bytecode} = compiledContract.contracts['DdosMitigation'];
    return web3.eth.estimateGas({data: `0x${bytecode}`});
};

console.log(estimateContractGas(contract));
