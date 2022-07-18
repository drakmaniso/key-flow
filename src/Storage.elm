port module Storage exposing (..)

-- To Javascript


port requestItem : String -> Cmd msg


port setItem : ( String, String ) -> Cmd msg



-- From Javascript


port itemChanged : (( String, Maybe String ) -> msg) -> Sub msg
