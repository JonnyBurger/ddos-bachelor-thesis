const {Address6} = require('ip-address');

const stringRepresentation = new Adress6('::123.456.78.90');
const bigIntegerRepresentation = Address6.fromBigInteger(stringRepresentation);
stringRepresentation === bigIntegerRepresentation; // true
