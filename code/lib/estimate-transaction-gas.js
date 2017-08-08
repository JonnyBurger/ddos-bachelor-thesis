const promisify = require('es6-promisify');

const estimateTransactionGas = async (contract, account, method, arguments) => {
	const response = await promisify(contract[method].estimateGas)(...arguments, {
		from: account.address
	});
	return response;
};

module.exports = estimateTransactionGas;
