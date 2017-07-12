function blocked() constant returns (uint128[] sourceIp, uint8[] sourceMask, uint128[] destinationIp, uint8[] mask) {
    Report[] memory unexpired = getUnexpired(reports);

    uint128[] memory src = new uint128[](unexpired.length);
    uint8[] memory srcmask = new uint8[](unexpired.length);
    uint128[] memory dst = new uint128[](unexpired.length);
    uint8[] memory dstmask = new uint8[](unexpired.length);

    for (uint i = 0; i < unexpired.length; i++) {
        src[i] = unexpired[i].sourceIp.ip;
        srcmask[i] = unexpired[i].sourceIp.mask;
        dst[i] = unexpired[i].destinationIp.ip;
        dstmask[i] = unexpired[i].destinationIp.mask;
    }
    return (src, srcmask, dst, dstmask);
}
