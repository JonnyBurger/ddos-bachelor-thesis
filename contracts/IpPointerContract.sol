pragma solidity 0.4.9;

contract IpPointerContract {
    // Don't use IP address struct: would have to be decomposed
    struct Pointer {
        uint expirationDate;
        string url;
        uint128 ip;
        uint8 mask;
        bytes32 _hash;
    }

    struct IPAddress  {
        uint128 ip;
        uint8 mask;
    }

    IPAddress ipBoundary;
    address owner;
    mapping (address => IPAddress) public members;
    mapping (address => Pointer) public pointers;

    function IpPointerContract(uint128 ip, uint8 mask) {
        owner = msg.sender;
        ipBoundary = IPAddress({
            ip: ip,
            mask: mask
        });
    }
    function createCustomer(address customer, uint128 ip, uint8 mask) {
        if (msg.sender != owner) {
            throw;
        }
        if (isInSameSubnet(ip, mask, ipBoundary.ip, ipBoundary.mask)) {
            members[customer] = IPAddress({
                ip: ip,
                mask: mask
            });
        }
    }

    function setPointer(string url, uint128 subnetIp, uint8 subnetMask, uint expirationDate, bytes32 _hash) {
        if (members[msg.sender].ip == 0) {
            throw;
        }
        if (!isInSameSubnet(subnetIp, subnetMask, members[msg.sender].ip, members[msg.sender].mask)) {
            throw;
        }
        if (expirationDate < now) {
            throw;
        }
        pointers[msg.sender] = Pointer({
            expirationDate: expirationDate,
            url: url,
            ip: subnetIp,
            mask: subnetMask,
            _hash: _hash
        });
    }

    function removePointer() {
        if (members[msg.sender].ip == 0) {
            throw;
        }
        delete pointers[msg.sender];
    }

    function isInSameSubnet(uint128 ip, uint8 mask, uint128 boundaryIp, uint8 boundaryMask) constant returns (bool) {
        if (mask < boundaryMask) {
            return false;
        }
        return int128(ip) & -1<<(128-boundaryMask) == int128(boundaryIp) & (-1<<(128-boundaryMask));
    }
}
