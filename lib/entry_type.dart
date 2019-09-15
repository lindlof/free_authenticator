enum EntryType {
  totp,
  vault,
}

const Map<EntryType, String> EntryTypeName = {
  EntryType.totp: "TOTP",
  EntryType.vault: "Vault",
};

const Map<EntryType, String> EntryTypeDesc = {
  EntryType.totp: "Time-Based One-Time Password",
  EntryType.vault: "Vault",
};
