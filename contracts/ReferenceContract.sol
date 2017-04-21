pragma solidity 0.4.9;

contract SDNRulesAS {
    DropIPv4[] drop_src_ipv4;
    DstV4 ipBoundary;
    bytes certOwnerIPv4;
    address owner;
    mapping (address => DstV4) customerIPv4;
    
    struct DstV4  {
        uint32 ip;
        uint8 mask;
    }

    struct DropIPv4 {
        uint expiringDate;
        uint32 src_ip;
        DstV4 dst_ip;
    }

    function filter(DropIPv4[] memory self, function (DropIPv4 memory) returns (bool) f) internal returns (DropIPv4[] memory r) {
        uint j = 0;
        for (uint x = 0; x < self.length; x++) {
            if (f(self[x])) {
                j++;
            }
        }
        DropIPv4[] memory newArray = new DropIPv4[](j);
        uint i = 0;
        for (uint y = 0; y < self.length; y++) {
            if (f(self[y])) {
                newArray[i] = self[y];
                i++;
            }
        }
        return newArray;
    }

    function isNotExpired(DropIPv4 self) internal returns (bool) {
        return self.expiringDate >= now;
    }

    function getUnexpired(DropIPv4[] memory list) internal returns (DropIPv4[] memory) {
        return filter(list, isNotExpired);
    }

    function SDNRulesAS(uint32 ip, uint8 mask, bytes _certOwnerIPv4) {
        owner = msg.sender;
        certOwnerIPv4 = _certOwnerIPv4;
        ipBoundary = DstV4({
            ip: ip,
            mask: mask
        });
    }

    function createCustomerIPv4(address customer, uint32 ip, uint8 mask) {
        if (msg.sender != owner) {
            throw;
        }
        if (!isInSameIPv4Subnet(ip, mask)) {
            throw;
        }
        customerIPv4[customer] = DstV4(ip, mask);
    }

    function isInSameIPv4Subnet(uint32 ip, uint8 mask) constant returns (bool) {
        if (mask < ipBoundary.mask) {
            return false;
        }
        return int32(ip) & -1<<(32-ipBoundary.mask) == int32(ipBoundary.ip) & (-1<<(32-ipBoundary.mask));
    }

    function blockIPv4(uint32[] src, uint expiringDate) {
        if (msg.sender == owner) {
            for (uint i = 0; i < src.length; i++) {
                drop_src_ipv4.push(DropIPv4({
                    expiringDate: expiringDate,
                    src_ip: src[i],
                    dst_ip: ipBoundary
                }));
            }
        }
        DstV4 customer = customerIPv4[msg.sender];
        if (customer.ip != 0) {
            for (uint j = 0; j < src.length; j++) {
                drop_src_ipv4.push(DropIPv4({
                    expiringDate: expiringDate,
                    src_ip: src[j],
                    dst_ip: customer
                }));
            }
        }        
    }

    function blockedIPv4() constant returns (uint32[] src_ipv4, uint32[] ip, uint8[] mask) {
        DropIPv4[] memory unexpired = getUnexpired(drop_src_ipv4);
        
        uint32[] memory src = new uint32[](unexpired.length);
        uint32[] memory dst = new uint32[](unexpired.length);
        uint8[] memory msk = new uint8[](unexpired.length);

        for (uint i = 0; i < unexpired.length; i++) {
            src[i] = unexpired[i].src_ip;
            dst[i] = unexpired[i].dst_ip.ip;
            msk[i] = unexpired[i].dst_ip.mask;
        }
        return (src, dst, msk);
    }
}
