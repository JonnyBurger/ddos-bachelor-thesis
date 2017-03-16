pragma solidity 0.4.8;

contract DdosMitigation {
    struct Ipv6Address {
        uint128 ip;
    }
    struct Report {
        address reporter;
        Ipv6Address url;
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