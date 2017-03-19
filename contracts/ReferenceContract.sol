pragma solidity 0.4.9;

library Util {
    struct DstIPv4 {
        uint32 dst_ipv4;
        uint8 dst_mask;
    }

    struct DropIPv4 {
        uint32 expiringBlock;
        uint32 src_ip;
        DstIPv4 dst_ip;
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

    function isExpired(DropIPv4 self) internal returns (bool) {
        return self.expiringBlock > block.number;
    }

    function getUnexpired(DropIPv4[] memory list) internal returns (DropIPv4[] memory) {
        return filter(list, isExpired);
    }
}

contract SDNRulesAS {
    using Util for *;
    Util.DropIPv4[] drop_src_ipv4;
    Util.DstIPv4 dstIPv4;
    bytes certOwnerIPv4;
    address owner;

    mapping (address => Util.DstIPv4) customerIPv4;

    function SDNRulesAS(uint32 dst_ipv4, uint8 dst_ipv4_mask, bytes _certOwnerIPv4) {
        owner = msg.sender;
        certOwnerIPv4 = _certOwnerIPv4;
        dstIPv4 = Util.DstIPv4(dst_ipv4, dst_ipv4_mask);
    }

    function createCustomerIPv4(address customer, uint32 dst_ipv4, uint8 dst_ipv4_mask) {
        if (msg.sender == owner && isInSameIPv4Subnet(dst_ipv4, dst_ipv4_mask)) {
            customerIPv4[customer] = Util.DstIPv4(dst_ipv4, dst_ipv4_mask);
        }
    }

    function isInSameIPv4Subnet(uint32 dst_ipv4, uint8 dst_mask) constant returns (bool) {
        // TODO: calculate
        return true;
    }

    function blockIPv4(uint32[] src, uint32 expiringBlock) {
        if (msg.sender == owner) {
            for (uint i = 0; i < src.length; i++) {
                drop_src_ipv4.push(Util.DropIPv4({
                    expiringBlock: expiringBlock,
                    src_ip: src[i],
                    dst_ip: dstIPv4
                }));
            }
        }
        Util.DstIPv4 customer = customerIPv4[msg.sender];
        if (customer.dst_ipv4 != 0) {
            for (uint j = 0; j < src.length; j++) {
                drop_src_ipv4.push(Util.DropIPv4({
                    expiringBlock: expiringBlock,
                    src_ip: src[j],
                    dst_ip: customer
                }));
            }
        }        
    }

    function blockedIPv4() constant returns (uint32[] src_ipv4, uint32[] dst_ipv4, uint8[] mask) {
        Util.DropIPv4[] memory unexpired = drop_src_ipv4.getUnexpired();
        
        uint32[] memory src = new uint32[](unexpired.length);
        uint32[] memory dst = new uint32[](unexpired.length);
        uint8[] memory msk = new uint8[](unexpired.length);

        for (uint i = 0; i < unexpired.length; i++) {
            src[i] = unexpired[i].src_ip;
            dst[i] = unexpired[i].dst_ip.dst_ipv4;
            msk[i] = unexpired[i].dst_ip.dst_mask;
        }
        return (src, dst, msk);
    }
}
