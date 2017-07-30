pragma solidity 0.4.9;

contract BloomFilter3 {
    int array_size = 1024;
    int bitcount = 1024 * 8;
    int hashes = 13;
    uint[] filter;
    bool whitelist;
    address owner;
    function BloomFilter3(bool white) {
        owner = msg.sender;
        filter = new uint[](1024);
        whitelist = white;
    }
    function add(string s) {
        if (owner != msg.sender) {
            throw;
        }
        var digest = int(sha256(s));

        for (var i = 0; i < hashes; i++) {
            int a = digest & (bitcount - 1);
            filter[uint(a / 8)] |= (2 ** uint(a % 8));
            digest >>= (256 / hashes);
        }
    }
    function test(string s) constant returns (bool) {
        var digest = int(sha256(s));
        for (var i = 0; i < hashes; i++) {
            int a = digest & (bitcount - 1);
            if ((filter[uint(a / 8)] & (2 ** uint(a % 8))) <= 0) {
                return false;
            }
            digest >>= (256 / hashes);
        }
        return true;
    }
}
