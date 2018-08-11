module AllDict exposing (Dict, empty, get, insert, remove, withPredicate, fromList, map)

{-| A dictionary mapping keys to values. This dictionary can use any (non-function) type as a key.
The Dict in the core libraries can only use comparable keys.
AllDict uses regular equality, `(==)` for comparing keys, and thus, works for anything but functions.

Unlike other dictionaries, this implementation allows one to set predicates on the retrieval of values, which allows one to do things like these:

    import AllDict exposing (Dict, withPredicate)

    withDefaultValue10 =
        Dict.empty
            |> Dict.withPredicate (always True) 10
            |> Dict.insert "Another value" 42


    Dict.get "Hey" withDefaultValue10 == Just 10

    Dict.get "Nice!" withDefaultValue10 == Just 10

    Dict.get "Another value" withDefaultValue10 == Just 42

@docs Dict


## Creating

@docs empty, fromList


## Reading

@docs get


## Modifying

@docs insert, remove, withPredicate


## Transforming values

@docs map

-}


{-| A mapping from keys of type `k`, to values of type `v`.
-}
type alias Dict k v =
    k -> Maybe v


{-| Create an empty dictionary.

    import Dict

    Dict.get "Some key" Dict.empty == Nothing

-}
empty : Dict k v
empty _ =
    Nothing


{-| Retrieves a value from a Dict. Returns `Nothing` if the key is not present.

    import Dict

    myDict = Dict.insert "my key" 42 Dict.empty

    Dict.get "my key" myDict == Just 42

-}
get : k -> Dict k v -> Maybe v
get k dict =
    dict k


{-| Inserts a value for a key in a Dict. Overwrites any already set key.

    import Dict

    myDict =
      Dict.empty
        |> Dict.insert "my key" 42
        |> Dict.insert "my key" 88

    Dict.get "my key" myDict == Just 88

-}
insert : k -> v -> Dict k v -> Dict k v
insert k1 v d =
    withPredicate (\k2 -> k1 == k2) v d


{-| Removes the value set for a key.

    import Dict

    myDict =
      Dict.empty
        |> Dict.insert "my key" 42
        |> Dict.remove "my key"

    Dict.get "my key" myDict == Nothing

-}
remove : k -> Dict k v -> Dict k v
remove k1 d =
    \k2 ->
        if k1 == k2 then
            Nothing
        else
            d k2


{-| Adds a predicate with a value to a Dict. If the key satisfies the predicate, that value will be returned.
The predicate can be overwritten for specific keys with subsequent inserts or predicates.

    import Dict

    isShort : String -> Bool
    isShort k = String.length k <= 5

    welcomeMessageDict : Dict String String
    welcomeMessageDict =
      Dict.empty
        |> Dict.withPredicate isShort "This key is pretty short!"
        |> Dict.insert "cats" "I love them!"

    Dict.get "key1" myDict == Just "This key is pretty short!"

    Dict.get "key2" myDict == Just "This key is pretty short!"

    Dict.get "cats" myDict == Just "I love them!"

-}
withPredicate : (k -> Bool) -> v -> Dict k v -> Dict k v
withPredicate pred val dict =
    \k ->
        if pred k then
            Just val
        else
            dict k


{-| Creates a value from a list of key-value pairs.

    import Dict

    myDict =
        Dict.fromList
            [ ( "some key", "some value" )
            , ( "another key", "another value" )
            ]

    Dict.get "some key" myDict == Just "some value"

    Dict.get "another key" myDict == Just "another value"

-}
fromList : List ( k, v ) -> Dict k v
fromList kvs =
    case kvs of
        [] ->
            empty

        ( k, v ) :: rest ->
            insert k v (fromList rest)


{-| Transforms all values in a Dict.

    import Dict exposing (Dict)

    myDict : Dict String String
    myDict =
        Dict.fromList
            [ ( "some key", "some value" )
            , ( "another key", "another value" )
            ]

    myIntDict : Dict String Int
    myIntDict = Dict.map String.length myDict

    Dict.get "some key" myIntDict == Just 10

-}
map : (a -> b) -> Dict k a -> Dict k b
map f d =
    Maybe.map f << d
