module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
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
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Key Flow"
    , body =
        [ case model.page of
            Home ->
                h1 [] [ text "Home" ]

            Settings ->
                h1 [] [ text "Settings" ]

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
