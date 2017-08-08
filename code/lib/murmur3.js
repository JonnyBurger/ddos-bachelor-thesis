// https://github.com/jensyt/imurmurhash-js

/**
 * @preserve
 * JS Implementation of incremental MurmurHash3 (r150) (as of May 10, 2013)
 *
 * @author <a href="mailto:jensyt@gmail.com">Jens Taylor</a>
 * @see http://github.com/homebrewing/brauhaus-diff
 * @author <a href="mailto:gary.court@gmail.com">Gary Court</a>
 * @see http://github.com/garycourt/murmurhash-js
 * @author <a href="mailto:aappleby@gmail.com">Austin Appleby</a>
 * @see http://sites.google.com/site/murmurhash/
 */ (function() {
    var cache;

    // Call this function without `new` to use the cached object (good for
    // single-threaded environments), or with `new` to create a new object.
    //
    // @param {string} key A UTF-16 or ASCII string
    // @param {number} seed An optional positive integer
    // @return {object} A MurmurHash3 object for incremental hashing
    function MurmurHash3(key, seed) {
        var m = this instanceof MurmurHash3 ? this : cache;
        m.reset(seed)
        if (typeof key === 'string' && key.length > 0) {
            m.hash(key);
        }

        if (m !== this) {
            return m;
        }
    };

    MurmurHash3.prototype.op1 = function (k1, key, i) {
        switch (this.rem) {
            case 0:
                return k1 ^ ((key.length > i) ? (key.charCodeAt(i++) & 0xffff) : 0);
            case 1:
                return k1 ^ ((key.length > i) ? (key.charCodeAt(i++) & 0xffff) << 8 : 0);
            case 2:
                return k1 ^ ((key.length > i) ? (key.charCodeAt(i++) & 0xffff) << 16 : 0);
            case 3:
                return k1 ^ ((key.length > i) ? (key.charCodeAt(i) & 0xff) << 24 : 0) ^ ((key.length > i) ? (key.charCodeAt(i++) & 0xff00) >> 8 : 0);
            default:
                throw new Error('k1 should be between 0 and 3');
        }
    };

    // Incrementally add a string to this hash
    //
    // @param {string} key A UTF-16 or ASCII string
    // @return {object} this
    MurmurHash3.prototype.hash = function(key) {
        var h1, k1, i, top, len;

        len = key.length;
        this.len += len;

        i = 0;

        k1 = this.op1(this.k1, key, i);

        this.rem = (len + this.rem) & 3; // & 3 is same as % 4
        len -= this.rem;
        if (len > 0) {
            h1 = this.h1;
            while (1) {
                k1 = ((k1 * 0x2d51) + (k1 & 0xffff) * 0xcc9e0000) & 0xffffffff;
                k1 = (k1 << 15) | (k1 >> 17);
                k1 = (k1 * 0x3593 + (k1 & 0xffff) * 0x1b870000) & 0xffffffff;
                h1 ^= k1;
                if ((i + 3) >= len) {
                    break;
                }

                const _int1 = key.charCodeAt(i++);
                const _int2 = key.charCodeAt(i++);
                const _int3 = key.charCodeAt(i++);
                k1 = (_int1 & 0xffff) ^ ((_int2 & 0xffff) << 8) ^ ((_int3 & 0xffff) << 16);
                top = key.charCodeAt(i++);
                k1 ^= ((top & 0xff) << 24) ^ ((top & 0xff00) >> 8);
            }

            k1 = 0;
            switch (this.rem) {
                case 3:
                    k1 ^= (key.charCodeAt(i + 2) & 0xffff) << 16;
                case 2:
                    k1 ^= (key.charCodeAt(i + 1) & 0xffff) << 8;
                case 1:
                    k1 ^= (key.charCodeAt(i) & 0xffff);
            }

            this.h1 = h1;
        }

        this.k1 = k1;
        return this;
    };

    // Get the result of this hash
    //
    // @return {number} The 32-bit hash
    MurmurHash3.prototype.result = function() {
        var k1, h1;
        k1 = this.k1;
        h1 = this.h1;

        if (k1 > 0) {
            k1 = (k1 * 0x2d51 + (k1 & 0xffff) * 0xcc9e0000) & 0xffffffff;
            k1 = (k1 << 15) | (k1 >> 17);
            k1 = (k1 * 0x3593 + (k1 & 0xffff) * 0x1b870000) & 0xffffffff;
            h1 ^= k1;
        }

        h1 ^= this.len;

        h1 ^= h1 >> 16;
        h1 = (h1 * 0xca6b + (h1 & 0xffff) * 0x85eb0000) & 0xffffffff;
        h1 ^= h1 >> 13;
        h1 = (h1 * 0xae35 + (h1 & 0xffff) * 0xc2b20000) & 0xffffffff;
        h1 ^= h1 >> 16;
        return h1 >> 0;
    };

    // Reset the hash object for reuse
    //
    // @param {number} seed An optional positive integer
    MurmurHash3.prototype.reset = function(seed) {
        this.h1 = typeof seed === 'number' ? seed : 0;
        this.rem = this.k1 = this.len = 0;
        return this;
    };

    // A cached object to use. This can be safely used if you're in a single-
    // threaded environment, otherwise you need to create new hashes to use.
    cache = new MurmurHash3();

    if (typeof(module) != 'undefined') {
        module.exports = MurmurHash3;
    } else {
        this.MurmurHash3 = MurmurHash3;
    }
}()); 
