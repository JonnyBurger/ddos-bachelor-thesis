mapping (address => bool) public members;
mapping (address => Pointer) public pointers;

struct Pointer {
    uint expirationDate;
    string url;
    uint128 destinationIp;
    uint8 destinationMask;
    bytes32 _hash;
}

struct IPAddress  {
    uint128 ip;
    uint8 mask;
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
        destinationIp: subnetIp,
        destinationMask: subnetMask,
        _hash: _hash
    });
}
