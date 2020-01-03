# SQL Store

Saves and loads entries in SQLite database. Entries are encrypted in database because they are highly confidential.

`sql_store` implements `Store` interface from `widget`. Dependency diagram:

```
     DB   Keystore
      ↑    ↑
 UI ← Store
  │     ↓
  ┕ → Model
```

`UI` uses `Store` to, for instance, get entries. `Store` will load them from database, decrypt them, instantiate them and return to `UI`.

`Store`'s job is to instantiate components and call them so that individual components remain isolated and free of interdependencies.
