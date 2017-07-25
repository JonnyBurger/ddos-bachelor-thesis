pragma solidity 0.4.9;

contract BloomFilter2 {
    int _m = 1024;
    int _k;
    int[] _buckets;
    int[] _locations;
    
    function ceil(int a) constant returns (int) {
        return int(a + 1);
    }

    function floor(int a) constant returns (uint) {
        return uint(a);
    }

    function BloomFilter(int m) {
        _k = 4;
        _m = 1024;
        uint n = 32;
        uint i = 0;
        _buckets = new int[](n);
        while (i++ < n) {
            _buckets[i] = 0;
        }
        _locations = new int[](uint(_k));
    }

    function locations(string v) returns (int[]) {
        int a = fnv_1a(v);
        int b = fnv_1a_b(a);
        int x = a % _m;
        for (var i = 0; i < _k; ++i) {
            _locations[i] = x < 0 ? (x + _m) : x;
            x = (x + b) % _m;
        }
        return _locations;
    }

    function add(string v) {
        var l = locations(v);
        var k = _k;
        for (var i = 0; i < k; ++i) {
            _buckets[floor(l[i] / 32)] |= 1 << (l[i] % 32);
        }
    }

    function test(string v) constant returns (bool) {
        var l = locations(v);
        for (var i = 0; i < _k; ++i) {
            var b = l[i];
            if ((_buckets[floor(b / 32)] & (1 << (b % 32))) == 0) {
                return false;
            }
        }
        return true;
    }

    function charCodeAt(string key, uint index) constant returns (uint result){
        return uint(bytes(key)[index]);
    }


    function fnv_1a(string v) constant returns (int) {// does it return that?
        int a = 2166136261;
        var n = bytes(v).length;
        for (var i = 0; i < int(n); ++i) {
            int c = int(charCodeAt(v, i));
            int d = c & 0xff00;
            if (d > 0) {
                a = fnv_multiply(a ^ d >> 8);
            }
            //return 2166136261 ^ 65 & 0xff;
            a = fnv_multiply(a ^ c & 0xff);
        }
        return fnv_mix(a);
    }

    function fnv_multiply(int a) constant returns (int) {
        return a + (a << 1) + (a << 4) + (a << 7) + (a << 8) + (a << 24);
    }

    function fnv_1a_b(int a) constant returns (int) { // does it return that?
        return fnv_mix(fnv_multiply(a));
    }

    function fnv_mix(int a) constant returns (int) {
        a += a << 13;
        a ^= a >> 7; // originally >>>
        a += a << 3;
        a ^= a >> 17; // originally >>>
        a += a << 5;
        return a & 0xffffffff;
    }
}
