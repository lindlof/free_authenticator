# Factory

Architecture of FA is separated to independent and uncoupled components which are orchestrated by `Factory`:

```
     DB   Keystore
      ↑    ↑
 UI → Factory
  │     ↓
  ┕ → Model
```

`UI` uses `Factory` to, for instance, get entries. `Factory` will load them from database, decrypt them, instantiate them and return to `UI`.

`Factory`'s job is to instantiate components and call them so that individual components remain isolated and free of interdependencies.

Components without interdependencies are low-complexity, easy to test and have low risk of regression bugs.