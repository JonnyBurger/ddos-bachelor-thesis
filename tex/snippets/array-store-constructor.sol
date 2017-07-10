address owner;
IPAddress ipBoundary;

modifier needsMask(uint8 mask) {
    if (mask == 0) {
        throw;
    }
    _;
}
function ArrayStore(uint128 ip, uint8 mask) needsMask(mask) {
    owner = msg.sender;
    ipBoundary = IPAddress({
        ip: ip,
        mask: mask
    });
}
