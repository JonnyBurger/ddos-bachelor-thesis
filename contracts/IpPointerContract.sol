pragma solidity 0.4.9;

contract IpPointerContract {
    struct Report {
        uint expiringDate;
        string url;
        uint40 dst_ip;
    }

    struct IPAddress  {
        uint128 ip;
        uint8 mask;
    }

    IPAddress ipBoundary;
    address owner;
    mapping (address => bool) public members;
    mapping (address => Report) public reports;

    function IpPointerContract(uint32 ip, uint8 mask) {
        owner = msg.sender;
        ipBoundary = IPAddress({
            ip: ip,
            mask: mask
        });
    }

    function createCustomer(address customer, uint32 ip, uint8 mask) {
        if (msg.sender != owner) {
            throw;
        }
        if (isInSameSubnet(ip, mask)) {
            members[customer] = true;
        }
    }

    function setPointer(string url) {
        if (!members[msg.sender]) {
            throw;
        }
        reports[msg.sender] = Report(now, url, 123456789);
    }

    function isInSameSubnet(uint128 ip, uint8 mask) constant returns (bool) {
        if (mask < ipBoundary.mask) {
            return false;
        }
        return int128(ip) & -1<<(128-ipBoundary.mask) == int128(ipBoundary.ip) & (-1<<(128-ipBoundary.mask));
    }
}
