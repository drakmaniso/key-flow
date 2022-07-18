module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E
import Storage
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , settings : Int
    }


type Page
    = Home
    | Settings
    | Error String


route : Url.Url -> Page
route url =
    case url.fragment of
        Nothing ->
            Home

        Just "home" ->
            Home

        Just "settings" ->
            Settings

        Just "error" ->
            Error ""

        Just unknown ->
            Error ("unknown fragment: " ++ unknown)


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { key = key
      , page = route url
      , settings = 0
      }
    , Storage.requestItem "settings"
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | StorageChanged ( String, Maybe String )
    | StorageSet ( String, String )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | page = route url }
            , Cmd.none
            )

        StorageChanged ( key, value ) ->
            if key == "settings" then
                case value of
                    Just val ->
                        case D.decodeString D.int val of
                            Ok v ->
                                ( { model | settings = v }, Cmd.none )

                            Err _ ->
                                ( model, Nav.pushUrl model.key "#error" )

                    Nothing ->
                        ( { model | settings = -1 }, Cmd.none )

            else
                ( model, Cmd.none )

        StorageSet ( key, value ) ->
            ( model, Storage.setItem ( key, value ) )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Storage.itemChanged StorageChanged
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Key Flow"
    , body =
        [ case model.page of
            Home ->
                h1 [] [ text "Home" ]

            Settings ->
                div []
                    [ h1 [] [ text "Settings" ]
                    , p []
                        [ text (" settings = " ++ String.fromInt model.settings) ]
                    , button [ onClick (StorageSet ( "settings", 1 |> E.int |> E.encode 0 )) ]
                        [ text "settings = 1" ]
                    , button [ onClick (StorageSet ( "settings", 2 |> E.int |> E.encode 0 )) ]
                        [ text "settings = 2" ]
                    ]

            Error msg ->
                h1 [] [ text ("Error: " ++ msg) ]
        , ul []
            [ viewLink "#home"
            , viewLink "#settings"
            ]
        ]
    }


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ href path ] [ text path ] ]
