pragma solidity 0.4.9;

contract HashFunction {
    uint length = 0;
    uint k1 = 0;
    uint h1 = 0;
    uint rem = 0;
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
    function HashFunction(string key, uint seed) {
        reset(seed);
        hash(key);
    }
    function hash(string key) {
        uint top;
        uint len = bytes(key).length;
        length = length + len;

        uint _k1 = 0;
        var i = 0;
        if (rem == 0) {
            _k1 ^= (len > i) ? uint(bytes(key)[i++]) & 0xffff : 0;
        }
        if (rem == 1) {
            _k1 ^= (len > i) ? (uint(bytes(key)[i++]) & 0xffff) << 8 : 0;
        }
        if (rem == 2) {
            _k1 ^= (len > i) ? (uint(bytes(key)[i++]) & 0xffff) << 16 : 0;
        }
        if (rem == 3) {
            k1 ^= (len > i) ? (uint(bytes(key)[i]) & 0xff) << 24 : 0;
            k1 ^= (len > i) ? (uint(bytes(key)[i++]) & 0xff00) >> 8 : 0;
        }

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
                _h1 = (_h1 << 13) | (_h1 >> 19);
                _h1 = (h1 * 5 + 0xe6546b64) & 0xffffffff;
                if ((i + 3) >= len) {
                    break;
                }
                
                _k1 = (uint(bytes(key)[i++]) & 0xffff) ^
                    ((uint(bytes(key)[i++]) & 0xffff) << 8) ^
                    ((uint(bytes(key)[i++]) & 0xffff) << 16);
                top = uint(bytes(key)[i++]);
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
        return _k1;
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
