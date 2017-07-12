function block(uint128[] src, uint8[] srcmask, uint expirationDate) {
    if (src.length != srcmask.length) {
        throw;
    }
    IPAddress destination = msg.sender == owner ? ipBoundary : customers[msg.sender];
    if (destination.ip == 0) {
        throw;
    }
    for (uint i = 0; i < src.length; i++) {
        if (!isInSameSubnet(src[i], srcmask[i])) {
            throw;
        }
        reports.push(Report({
            expirationDate: expirationDate,
            sourceIp: IPAddress({ip: src[i], mask: srcmask[i]}),
            destinationIp: destination
        }));
    }
}
