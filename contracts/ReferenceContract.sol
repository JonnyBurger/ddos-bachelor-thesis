pragma solidity 0.4.9;

contract ArrayStore {
    Report[] reports;
    IPAddress ipBoundary;
    address owner;
    mapping (address => IPAddress) customers;
    uint32 _customerCount;
    struct IPAddress  {
        uint32 ip;
        uint8 mask;
    }

    struct Report {
        uint expiringDate;
        uint32 sourceIp;
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
        return self.expiringDate >= now;
    }

    function getUnexpired(Report[] memory list) internal returns (Report[] memory) {
        return filter(list, isNotExpired);
    }

    function ArrayStore(uint32 ip, uint8 mask) {
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
        if (!isInSameIPv4Subnet(ip, mask)) {
            throw;
        }
        customers[customer] = IPAddress(ip, mask);
        _customerCount++;
    }

    function isInSameIPv4Subnet(uint32 ip, uint8 mask) constant returns (bool) {
        if (mask < ipBoundary.mask) {
            return false;
        }
        return int32(ip) & -1<<(32-ipBoundary.mask) == int32(ipBoundary.ip) & (-1<<(32-ipBoundary.mask));
    }

    function block(uint32[] src, uint expiringDate) {
        if (msg.sender == owner) {
            for (uint i = 0; i < src.length; i++) {
                reports.push(Report({
                    expiringDate: expiringDate,
                    sourceIp: src[i],
                    destinationIp: ipBoundary
                }));
            }
        }
        IPAddress customer = customers[msg.sender];
        if (customer.ip != 0) {
            for (uint j = 0; j < src.length; j++) {
                reports.push(Report({
                    expiringDate: expiringDate,
                    sourceIp: src[j],
                    destinationIp: customer
                }));
            }
        }        
    }

    function blocked() constant returns (uint32[] sourceIp, uint32[] destinationIp, uint8[] mask) {
        Report[] memory unexpired = getUnexpired(reports);
        
        uint32[] memory src = new uint32[](unexpired.length);
        uint32[] memory dst = new uint32[](unexpired.length);
        uint8[] memory msk = new uint8[](unexpired.length);

        for (uint i = 0; i < unexpired.length; i++) {
            src[i] = unexpired[i].sourceIp;
            dst[i] = unexpired[i].destinationIp.ip;
            msk[i] = unexpired[i].destinationIp.mask;
        }
        return (src, dst, msk);
    }

    function customerCount() constant returns (uint32 count) {
        return _customerCount;
    }
}
