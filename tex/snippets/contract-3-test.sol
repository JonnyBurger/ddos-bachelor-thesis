function test(string ipAddress) constant returns (bool) {
    var digest = int(sha256(ipAddress));
    for (var i = 0; i < hashes; i++) {
        int a = digest & (bitcount - 1);
        if ((filter[uint8(a / bits_per_entry)] & (2 ** uint8(a % bits_per_entry))) <= 0) {
            return false;
        }
        digest >>= (bits_per_entry / hashes);
    }
    return true;
}
