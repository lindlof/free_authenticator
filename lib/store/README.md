# Store

Architecture of FA is separated to independent and uncoupled components which are orchestrated by `Store`:

```
     DB   Keystore
      ↑    ↑
 UI → Store
  │     ↓
  ┕ → Model
```

`UI` uses `Store` to, for instance, get entries. `Store` will load them from database, decrypt them, instantiate them and return to `UI`.

`Store`'s job is to instantiate components and call them so that individual components remain isolated and free of interdependencies.

Components without interdependencies are low-complexity, easy to test and have low risk of regression bugs.
