pragma solidity 0.4.9;

contract BloomFilter {
    uint length = 0;
    uint k1 = 0;
    uint h1 = 0;
    uint rem = 0;
    // Hash Function
    function stringToUint(string s) constant returns (uint result) {
        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
    }
    function getSolidityByte(string s) constant returns (uint result) {
        return uint(bytes(s)[0]);
    }

    function hashFn(string key, uint seed) constant returns (uint ret) {
        reset(seed);
        hash(key);
        return result();
    }

    function charCodeAt(string key, uint index) constant returns (uint result){
        return uint(bytes(key)[index]);
    }

    function op1(uint _k1, string key, uint len, uint i) constant returns (uint newk1) {
        if (rem == 0) {
            return _k1 ^ ((len > i) ? charCodeAt(key, i++) & 0xffff : 0);
        }
        if (rem == 1) {
            return _k1 ^ ((len > i) ? charCodeAt(key, i++) & 0xffff << 8 : 0);
        }
        if (rem == 2) {
            return _k1 ^ ((len > i) ? charCodeAt(key, i++) & 0xffff << 16 : 0);
        }
        if (rem == 3) {
            return _k1 ^ ((len > i) ? charCodeAt(key, i) & 0xff << 24 : 0) ^ ((len > i) ? charCodeAt(key, i++) & 0xff00 >> 8 : 0);
        }

    }

    function hash(string key) {
        uint top;
        uint len = bytes(key).length;
        length = length + len;

        uint _k1 = k1;
        var i = 0;
        _k1 = op1(_k1, key, len, i);

        rem = (len + rem) & 3;
        len -= rem;
        if (len > 0) {
            var _h1 = h1;
            while (true) {
                _k1 = ((_k1 * 0x2d51) + (_k1 & 0xffff) * 0xcc9e0000) & 0xffffffff;
                // Originally _k1 >>> 17 in Javascript
                _k1 = (_k1 << 15) | (_k1 >> 17);
                _k1 = (_k1 * 0x3593 + (_k1 & 0xffff) * 0x1b870000) & 0xffffffff;
                _h1 ^= _k1;
                if ((i + 3) >= len) {
                    break;
                }
                
                _k1 = (charCodeAt(key, i++) & 0xffff) ^
                    ((charCodeAt(key, i++) & 0xffff) << 8) ^
                    ((charCodeAt(key, i++) & 0xffff) << 16);
                top = charCodeAt(key, i++);
                 ((top & 0xff) << 24 ^ ((top & 0xff00) >> 8));
            }
            _k1 = 0;
            if (rem == 3) {
                _k1 ^= (uint(bytes(key)[i + 2]) & 0xffff) << 16;
            }
            if (rem == 2) {
                _k1 ^= (uint(bytes(key)[i + 1]) & 0xffff) << 8;
            }
            if (rem == 1) {
                _k1 ^= uint(bytes(key)[i]) & 0xffff;
            }
            h1 = _h1;
        }

        k1 = _k1;
    }

    function result() constant returns (uint ret) {
        uint _k1 = k1;
        uint _h1 = h1;
        /*
        if (_k1 > 0) {
            _k1 = (_k1 * 0x2d51 + (_k1 & 0xffff) * 0xcc9e0000) & 0xffffffff;
            _k1 = (_k1 << 15) | (_k1 >> 17);
            _k1 = (_k1 * 0x3593 + (_k1 & 0xffff) * 0x1b870000) & 0xffffffff;
            _h1 ^= _k1;
        }

        _h1 ^= length;
        _h1 ^= h1 >> 16;
        _h1 = (_h1 * 0xca6b + (_h1 & 0xffff) * 0x85eb0000) & 0xffffffff;
        _h1 ^= _h1 >> 13;
        _h1 = (_h1 * 0xae35 + (_h1 & 0xffff) * 0xc2b20000) & 0xffffffff;
        _h1 ^= _h1 >> 16;
        */
        return _h1 >> 0;
    }

    function reset(uint seed) {
        h1 = seed;
        rem = 0;
        k1 = 0;
        length = 0;
    }

    uint hashes = 7;
    uint[] seeds = [145,844,423,111,333,7111,9];
    uint bits = 32;
    uint[] buffer;

    function BloomFilter() {
        buffer = new uint[](bits);
    }
    
    function clear() {
        for (uint i = 0; i < bits; i++) {
            buffer[i] = 0;
        }
    }
    
    function setbit(uint bit) {
        var pos = 0;
        var shift = bit;
        while (shift > 7) {
            pos++;
            shift -= 8;
        }

        var bitfield = buffer[pos];
        bitfield |= (0x1 << shift);
        buffer[pos] = bitfield;
    }
    
    function getbit(uint bit) constant returns (bool truthy){
        var pos = 0;
        var shift = bit;
        while (shift > 7) {
            pos++;
            shift -= 8;
        }

        var bitfield = buffer[pos];
        return (bitfield & (0x1 << shift)) != 0;
    }

    function addOne(string str) {
        for (uint i = 0; i < hashes; i++) {
            var _hash = hashFn(str, seeds[i]);
            var bit = _hash % bits;
            setbit(bit);
        }
    }

    function has(string str) constant returns (bool truthy) {
        for (uint i = 0; i < hashes; i++) {
            var _hash = hashFn(str, seeds[i]);
            var bit = _hash % bits;
            var isSet = getbit(bit);
            if (!isSet) {
                return false;
            }
        }
        return true;
    }
}
