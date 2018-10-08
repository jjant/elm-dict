module AllDict exposing (Dict, empty, get, insert, remove, withPredicate, fromList, map)

{-| A dictionary mapping keys to values. This dictionary can use any (non-function) type as a key.
The Dict in the core libraries can only use comparable keys.
AllDict uses regular equality, `(==)` for comparing keys, and thus, works for anything but functions.

Unlike other dictionaries, this implementation allows one to set predicates on the retrieval of values, which allows one to do things like these:

    import AllDict exposing (Dict, withPredicate)

    withDefaultValue10 =
        AllDict.empty
            |> AllDict.withPredicate (always True) 10
            |> AllDict.insert "Another value" 42


    AllDict.get "Hey" withDefaultValue10 == Just 10

    AllDict.get "Nice!" withDefaultValue10 == Just 10

    AllDict.get "Another value" withDefaultValue10 == Just 42

This dictionary is based in this [article](http://fho.f12n.de/posts/2014-05-07-dont-fear-the-cat.html).


## Creating

@docs Dict

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

    import AllDict

    AllDict.get "Some key" AllDict.empty == Nothing

-}
empty : Dict k v
empty _ =
    Nothing


{-| Retrieves a value from a Dict. Returns `Nothing` if the key is not present.

    import AllDict

    myDict = AllDict.insert "my key" 42 AllDict.empty

    AllDict.get "my key" myDict == Just 42

This applies the key to the dictionary "function," though, so remember that this lookup time is O(n) for n the number of operations on the table, including initial inserts.

-}
get : k -> Dict k v -> Maybe v
get k dict =
    dict k


{-| Inserts a value for a key in a Dict. Overwrites any already set key.

    import AllDict

    myDict =
      AllDict.empty
        |> AllDict.insert "my key" 42
        |> AllDict.insert "my key" 88

    AllDict.get "my key" myDict == Just 88

-}
insert : k -> v -> Dict k v -> Dict k v
insert k1 v d =
    withPredicate (\k2 -> k1 == k2) v d


{-| Removes the value set for a key.

    import AllDict

    myDict =
      AllDict.empty
        |> AllDict.insert "my key" 42
        |> AllDict.remove "my key"

    AllDict.get "my key" myDict == Nothing

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

    import AllDict

    isShort : String -> Bool
    isShort k = String.length k <= 5

    welcomeMessageDict : Dict String String
    welcomeMessageDict =
      AllDict.empty
        |> AllDict.withPredicate isShort "This key is pretty short!"
        |> AllDict.insert "cats" "I love them!"

    AllDict.get "key1" myDict == Just "This key is pretty short!"

    AllDict.get "key2" myDict == Just "This key is pretty short!"

    AllDict.get "cats" myDict == Just "I love them!"

-}
withPredicate : (k -> Bool) -> v -> Dict k v -> Dict k v
withPredicate pred val dict =
    \k ->
        if pred k then
            Just val
        else
            dict k


{-| Creates a value from a list of key-value pairs.

    import AllDict

    myDict =
        AllDict.fromList
            [ ( "some key", "some value" )
            , ( "another key", "another value" )
            ]

    AllDict.get "some key" myDict == Just "some value"

    AllDict.get "another key" myDict == Just "another value"

-}
fromList : List ( k, v ) -> Dict k v
fromList kvs =
    case kvs of
        [] ->
            empty

        ( k, v ) :: rest ->
            insert k v (fromList rest)


{-| Transforms all values in a Dict.

    import AllDict exposing (Dict)

    myDict : Dict String String
    myDict =
        AllDict.fromList
            [ ( "some key", "some value" )
            , ( "another key", "another value" )
            ]

    myIntDict : Dict String Int
    myIntDict = AllDict.map String.length myDict

    AllDict.get "some key" myIntDict == Just 10

-}
map : (a -> b) -> Dict k a -> Dict k b
map f d =
    Maybe.map f << d
