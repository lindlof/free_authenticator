class EntryBase {
  int id;
  String name;
  int position;
  int vault;

  EntryBase(this.id, this.name, this.position, this.vault);

  setPosition(int position, int vault) {
    this.position = position;
    this.vault = vault;
  }
}
