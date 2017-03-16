pragma solidity 0.4.8;

contract DdosMitigation {
    struct Report {
        address reporter;
        uint128 ip;
    }

    address public owner;
    Report[] public reports;

    function DdosMitigation() {
        owner = msg.sender;
    }

    function report(uint128 ip) {
        reports.push(Report({
            reporter: msg.sender,
            ip: ip
        }));
    }
}