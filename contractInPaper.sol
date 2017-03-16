pragma solidity 0.4.8;

contract SDNRulesAS {
    struct DstIPv4 {
        uint32 dst_ipv4;
        uint8 dst_mask;
    } DstIPv4 dstIPv4;


    struct DropIPv4 {
        uint32 expiringBlock;
        uint32 src_ip;
        DstIPv4 dst_ip;
    }

    DropIPv4[] drop_src_ipv4;
    bytes certOwnerIPv4;
    address owner;

    mapping (address => DstIPv4) customerIPv4;

    function SDNRulesAS(uint32 dst_ipv4, uint8 dst_ipv4_mask, bytes _certOwnerIPv4) {
        owner = msg.sender;
        certOwnerIPv4 = _certOwnerIPv4;
        dstIPv4 = DstIPv4(dst_ipv4, dst_ipv4_mask);
    }

    function createCustomerIPv4(address customer, uint32 dst_ipv4, uint8 dst_ipv4_mask) {
        if (msg.sender == owner && isInSameIPv4Subnet(dst_ipv4, dst_ipv4_mask)) {
            customerIPv4[customer] = DstIPv4(dst_ipv4, dst_ipv4_mask);
        }
    }

    function isInSameIPv4Subnet(uint32 dst_ipv4, uint8 dst_mask) constant returns (bool) {
        // TODO: calculate
        return true;
    }

    function blockIPv4(uint32[] src, uint32 expiringBlock) {
        if (msg.sender == owner) {
            for (uint i = 0; i < src.length; i++) {
                drop_src_ipv4.push(DropIPv4({
                    expiringBlock: expiringBlock,
                    src_ip: src[i],
                    dst_ip: dstIPv4
                }));
            }
        }
        DstIPv4 customer = customerIPv4[msg.sender];
        if (customer.dst_ipv4 != 0) {
            for (uint j = 0; j < src.length; j++) {
                drop_src_ipv4.push(DropIPv4({
                    expiringBlock: expiringBlock,
                    src_ip: src[j],
                    dst_ip: customer
                }));
            }
        }        
    }

    function blockedIPv4() constant returns (uint32[] src_ipv4, uint32[] dst_ipv4, uint8[] mask) {
        uint32[] memory src;
        uint32[] memory dst;
        uint8[] memory msk;
        for (uint i = 0; i < drop_src_ipv4.length; i++) {
            if (drop_src_ipv4[i].expiringBlock > block.number) {
                src[src.length] = drop_src_ipv4[i].src_ip;
                dst[dst.length] = drop_src_ipv4[i].dst_ip.dst_ipv4;
                dst[msk.length] = drop_src_ipv4[i].dst_ip.dst_mask;
            }
        }
        return (src, dst, msk);
    }
}