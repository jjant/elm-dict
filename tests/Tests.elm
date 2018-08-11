module Tests exposing (..)

import Test exposing (..)
import Fuzz exposing (string, int)
import Expect
import AllDict


empty : Test
empty =
    describe "empty"
        [ fuzz string "returns Nothing for every key" <|
            \s ->
                (AllDict.get s AllDict.empty)
                    |> Expect.equal Nothing
        ]


insert : Test
insert =
    describe "insert"
        [ fuzz2 string int "inserts a key in a given dict" <|
            \k v ->
                let
                    myDict : AllDict.Dict String Int
                    myDict =
                        AllDict.insert k v AllDict.empty
                in
                    AllDict.get k myDict
                        |> Expect.equal (Just v)
        ]


remove : Test
remove =
    describe "remove"
        [ fuzz2 string int "removes a mapping for a key" <|
            \k v ->
                let
                    myDict =
                        AllDict.empty
                            |> AllDict.insert k v
                            |> AllDict.remove k
                in
                    AllDict.get k myDict
                        |> Expect.equal Nothing
        ]


kvList : Fuzz.Fuzzer (List ( String, String ))
kvList =
    Fuzz.list (Fuzz.tuple ( string, string ))


fromList : Test
fromList =
    describe "fromList"
        [ fuzz2 kvList string "creates a dict from a list of key-value pairs" <|
            \kvPairs randomKey ->
                let
                    keys =
                        List.map Tuple.first kvPairs

                    dict =
                        AllDict.fromList kvPairs
                in
                    AllDict.get randomKey dict
                        |> if List.member randomKey keys then
                            Expect.notEqual Nothing
                           else
                            Expect.equal Nothing
        ]
