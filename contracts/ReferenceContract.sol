pragma solidity 0.4.9;

contract ArrayStore {
    Report[] reports;
    IPAddress ipBoundary;
    address owner;
    mapping (address => IPAddress) customers;
    uint128 _customerCount;

    struct IPAddress  {
        uint128 ip;
        uint8 mask;
    }

    struct Report {
        uint expirationDate;
        IPAddress sourceIp;
        IPAddress destinationIp;
    }

    function filter(Report[] memory self, function (Report memory) returns (bool) f) internal returns (Report[] memory r) {
        uint j = 0;
        for (uint x = 0; x < self.length; x++) {
            if (f(self[x])) {
                j++;
            }
        }
        Report[] memory newArray = new Report[](j);
        uint i = 0;
        for (uint y = 0; y < self.length; y++) {
            if (f(self[y])) {
                newArray[i] = self[y];
                i++;
            }
        }
        return newArray;
    }

    function isNotExpired(Report self) internal returns (bool) {
        return self.expirationDate >= now;
    }

    function getUnexpired(Report[] memory list) internal returns (Report[] memory) {
        return filter(list, isNotExpired);
    }

    modifier needsMask(uint8 mask) {
        if (mask == 0) {
            throw;
        }
        _;
    }
    function ArrayStore(uint128 ip, uint8 mask) {
        owner = msg.sender;
        ipBoundary = IPAddress({
            ip: ip,
            mask: mask
        });
    }

    function createCustomer(address customer, uint128 ip, uint8 mask) needsMask(mask) {
        if (msg.sender != owner) {
            throw;
        }
        if (!isInSameSubnet(ip, mask)) {
            throw;
        }
        customers[customer] = IPAddress(ip, mask);
        _customerCount++;
    }

    function isInSameSubnet(uint128 ip, uint8 mask) constant returns (bool) {
        if (mask < ipBoundary.mask) {
            return false;
        }
        return int128(ip) & -1<<(128-ipBoundary.mask) == int128(ipBoundary.ip) & (-1<<(128-ipBoundary.mask));
    }

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

    function customerCount() constant returns (uint128 count) {
        return _customerCount;
    }
}
