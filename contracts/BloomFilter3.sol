pragma solidity 0.4.9;

contract BloomFilter3 {
    int array_size = 512;
    int bits_per_entry = 8;
    int bitcount = 512 * bits_per_entry;
    int hashes = 13;
    uint8[] filter;
    bool whitelist;
    address owner;
    function BloomFilter3(bool white) {
        owner = msg.sender;
        filter = new uint8[](512);
        whitelist = white;
    }
    function add(string s) {
        if (owner != msg.sender) {
            throw;
        }
        var digest = int(sha256(s));

        for (var i = 0; i < hashes; i++) {
            int a = digest & (bitcount - 1);
            filter[uint8(a / bits_per_entry)] |= (2 ** uint8(a % bits_per_entry));
            digest >>= (bits_per_entry / hashes);
        }
    }
    function test(string s) constant returns (bool) {
        var digest = int(sha256(s));
        for (var i = 0; i < hashes; i++) {
            int a = digest & (bitcount - 1);
            if ((filter[uint8(a / bits_per_entry)] & (2 ** uint8(a % bits_per_entry))) <= 0) {
                return false;
            }
            digest >>= (bits_per_entry / hashes);
        }
        return true;
    }
}
