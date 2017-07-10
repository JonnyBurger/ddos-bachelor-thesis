struct IPAddress  {
    uint128 ip;
    uint8 mask;
}

struct Report {
    uint expirationdate;
    IPAddress sourceIp;
    IPAddress destinationIp;
}
