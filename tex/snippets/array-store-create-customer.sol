function createCustomer(address customer, uint128 ip, uint8 mask) needsMask(mask) {
    if (msg.sender != owner) {
        throw;
    }
    if (!isInSameSubnet(ip, mask)) {
        throw;
    }
    customers[customer] = IPAddress(ip, mask);
}

function isInSameSubnet(uint128 ip, uint8 mask) constant returns (bool) {
    if (mask < ipBoundary.mask) {
        return false;
    }
    return int128(ip) & -1<<(128-ipBoundary.mask) == int128(ipBoundary.ip) & (-1<<(128-ipBoundary.mask));
}
