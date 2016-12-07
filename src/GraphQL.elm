module GraphQL exposing (..)

{-| Todo: Write documentation for this module.

# Todo: Exports
@docs query, queryResult, apply
-}

import Task exposing (Task)
import Json.Decode exposing (..)
import Json.Encode
import Http


{-| Todo: document this
-}
type alias ID =
    String


{-| Todo: document this function.
-}
query : String -> String -> String -> String -> Decoder a -> Task Http.Error a
query url query operation variables decoder =
    fetch "GET" url query operation variables decoder


{-| Todo: document this function.
-}
mutation : String -> String -> String -> String -> Decoder a -> Task Http.Error a
mutation url query operation variables decoder =
    fetch "POST" url query operation variables decoder


{-| Todo: document this function.
-}
fetch : String -> String -> String -> String -> String -> Decoder a -> Task Http.Error a
fetch verb url query operation variables decoder =
    let
        queryParams =
            [ ( "query", query )
            , ( "operationName", operation )
            , ( "variables", variables )
            ]
                |> List.map (\( k, v ) -> k ++ "=" ++ v)
                |> String.join ("&")
    in
        Http.request
            { method = verb
            , headers = [ Http.header "Accept" "application/json" ]
            , url = url ++ "?" ++ queryParams
            , body = Http.emptyBody
            , expect = Http.expectJson (queryResult decoder)
            , timeout = Nothing
            , withCredentials = True
            }
            |> Http.toTask


{-| Todo: document this function.
-}
queryResult : Decoder a -> Decoder a
queryResult decoder =
    -- todo: check for success/failure of the query
    oneOf
        [ at [ "data" ] decoder
        , fail "Expected 'data' field"
          -- todo: report failure reason from server
        ]


{-| Todo: document this function.
https://github.com/elm-community/json-extra/blob/2.0.0/src/Json/Decode/Extra.elm#L51
-}
apply : Decoder (a -> b) -> Decoder a -> Decoder b
apply =
    flip (map2 (|>))


{-| Todo: document this function.
-}
maybeEncode : (a -> Value) -> Maybe a -> Value
maybeEncode e v =
    case v of
        Nothing ->
            Json.Encode.null

        Just a ->
            e a
