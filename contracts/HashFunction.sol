pragma solidity 0.4.9;

contract HashFunction {
    uint length = 0;
    uint k1 = 0;
    uint h1 = 0;
    uint rem = 0;
    function bytesToUInt(byte v) constant returns (uint ret) {
        return uint(v);
        /*
        if (v == 0x0) {
            throw;
        }

        uint digit;

        for (uint i = 0; i < 32; i++) {
            digit = uint((uint(v) / (2 ** (8 * (31 - i)))) & 0xff);
            if (digit == 0) {
                break;
            }
            else if (digit < 48 || digit > 57) {
                throw;
            }
            ret *= 10;
            ret += (digit - 48);
        }
        return ret;
        */
    }
    function HashFunction(string key, uint seed) {
        reset(seed);
        hash(key);
    }
    function hash(string key) {
        uint top;
        uint len = bytes(key).length;
        length = length + len;

        var _k1 = k1;
        var i = 0;
        if (rem == 0) {
            _k1 ^= len > i ? bytesToUInt(bytes(key)[i++]) & 0xffff : 0;
        }
        if (rem == 1) {
            _k1 ^= len > i ? (bytesToUInt(bytes(key)[i++]) & 0xffff) << 8 : 0;
        }
        if (rem == 2) {
            _k1 ^= len > i ? (bytesToUInt(bytes(key)[i++]) & 0xffff) << 16 : 0;
        }
        if (rem == 3) {
            k1 ^= len > i ? (bytesToUInt(bytes(key)[i++]) & 0xff) << 24 : 0;
            k1 ^= len > i ? (bytesToUInt(bytes(key)[i++]) & 0xff00) >> 8 : 0;
        }

        rem = (len + rem) & 3;
        len -= rem;
        if (len > 0) {
            var _h1 = h1;
            while (true) {
                _k1 = (_k1 * 0x2d51 + (_k1 & 0xffff) * 0xcc9e0000) & 0xffffffff;
                // Originally _k1 >>> 17 in Javascript
                _k1 = (_k1 << 15) | (_k1 >> 17);
                _k1 = (_k1 * 0x3593 + (_k1 & 0xffff) * 0x1b870000) & 0xffffffff;
                
                _h1 ^= _k1;
                _h1 = (_h1 << 13) | (_h1 >> 19);
                _h1 = (h1 * 5 + 0xe6546b64) & 0xffffffff;

                if (i < len) {
                    break;
                }

                _k1 = (bytesToUInt(bytes(key)[i++]) & 0xffff) ^
                    ((bytesToUInt(bytes(key)[i++]) & 0xffff) << 8) ^
                    ((bytesToUInt(bytes(key)[i++]) & 0xffff) << 16);
                top = bytesToUInt(bytes(key)[i++]);
                _k1 ^= ((top & 0xff) << 24 ^ ((top & 0xff00) >> 8));
            }
            _k1 = 0;

            if (rem == 2) {
                _k1 ^= (bytesToUInt(bytes(key)[i + 1]) & 0xffff) << 8;
            }
            if (rem == 1) {
                _k1 ^= bytesToUInt(bytes(key)[i]) & 0xffff;
            }
            h1 = _h1;
        }

        k1 = _k1;
    }
    function result() constant returns (uint ret) {
        uint _k1 = k1;
        uint _h1 = h1;

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

        return _h1 >> 0;
    }
    function reset(uint seed) {
        h1 = seed;
        rem = 0;
        k1 = 0;
        length = 0;
    }
}
