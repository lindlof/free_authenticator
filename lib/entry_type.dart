enum EntryType {
  totp
}

const Map<EntryType, String> EntryTypeName = {
  EntryType.totp: "TOTP",
};

const Map<EntryType, String> EntryTypeDesc = {
  EntryType.totp: "Time-Based One-Time Password",
};
