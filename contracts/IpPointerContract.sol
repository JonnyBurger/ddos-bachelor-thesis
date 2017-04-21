pragma solidity 0.4.9;

contract IpPointerContract {
    struct Drop {
        uint expiringDate;
        string url;
        uint40 dst_ip;
    }

    uint40 ipBoundary;
    address owner;
    mapping (address => bool) public members;
    mapping (address => Drop) public customerIPv4;

    string cache;

    function isNotExpired(Drop self) internal returns (bool) {
        return self.expiringDate >= now;
    }


    function IpPointerContract(uint32 ip, uint8 mask) {
        owner = msg.sender;
        ipBoundary = 1234567890;
    }

    function createCustomerIPv4(address customer, uint32 ip, uint8 mask) {
        if (msg.sender != owner) {
            throw;
        }
        if (isInSameIPv4Subnet(ip, mask)) {
            members[customer] = true;
        }
    }

    function setPointer(string url) {
        if (!members[msg.sender]) {
            throw;
        }
        customerIPv4[msg.sender] = Drop(now, url, 123456789);
    }

    function isInSameIPv4Subnet(uint32 ip, uint8 mask) constant returns (bool) {
        // TODO: Check against IP boundary
        return true;
    }

}
