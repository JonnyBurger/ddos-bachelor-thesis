const fs = require('fs');

const contracts = fs.readdirSync('contracts').filter(file => file.match(/.sol$/));

module.exports = {};

contracts.forEach(c => {
    module.exports[c.match(/([A-Za-z0-9]+).sol$/)[1]] = fs.readFileSync(`contracts/${c}`, 'utf8');
});
