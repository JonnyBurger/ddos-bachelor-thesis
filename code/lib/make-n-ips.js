const {Address6} = require('ip-address');

const makeIPs = n => {
    return new Array(n)
        .fill(null)
        .map((a, i) => new Address6(`::127.0.0.${i + 1}`).bigInteger().toString());
};

module.exports = makeIPs;
