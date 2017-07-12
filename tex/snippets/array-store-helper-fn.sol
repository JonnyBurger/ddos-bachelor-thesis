function filter(Report[] memory self, function (Report memory) returns (bool) f) internal returns (Report[] memory r) {
    uint j = 0;
    for (uint x = 0; x < self.length; x++) {
        if (f(self[x])) {
            j++;
        }
    }
    Report[] memory newArray = new Report[](j);
    uint i = 0;
    for (uint y = 0; y < self.length; y++) {
        if (f(self[y])) {
            newArray[i] = self[y];
            i++;
        }
    }
    return newArray;
}

function isNotExpired(Report self) internal returns (bool) {
    return self.expirationDate >= now;
}

function getUnexpired(Report[] memory list) internal returns (Report[] memory) {
    return filter(list, isNotExpired);
}
