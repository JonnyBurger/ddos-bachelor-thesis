contract BloomFilter {
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
}
