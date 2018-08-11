# Elm Dict

A dictionary mapping keys to values. This dictionary can use any (non-function) type as a key.
The Dict in the core libraries can only use comparable keys.
AllDict uses regular equality, `(==)` for comparing keys, and thus, works for anything but functions.

Unlike other dictionaries, this implementation allows one to set predicates on the retrieval of values, which allows one to do things like these:

```elm
   import AllDict exposing (Dict, withPredicate)

   withDefaultValue10 =
       Dict.empty
           |> Dict.withPredicate (always True) 10
           |> Dict.insert "Another value" 42


   Dict.get "Hey" withDefaultValue10 == Just 10

   Dict.get "Nice!" withDefaultValue10 == Just 10

   Dict.get "Another value" withDefaultValue10 == Just 42
```
