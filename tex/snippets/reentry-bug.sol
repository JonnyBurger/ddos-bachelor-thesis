function withdraw(amount) {
    if (balances[msg.sender] < amount) throw;
    msg.sender.call.value(amount);
    balances[msg.sender] -= amount;
}