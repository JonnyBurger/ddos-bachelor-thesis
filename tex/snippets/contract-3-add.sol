function add(string ipAddress) {
    if (owner != msg.sender) {
        throw;
    }
    var digest = int(sha256(ipAddress));

    for (var i = 0; i < hashes; i++) {
        int a = digest & (bitcount - 1);
        filter[uint8(a / bits_per_entry)] |= (2 ** uint8(a % bits_per_entry));
        digest >>= (bits_per_entry / hashes);
    }
}
