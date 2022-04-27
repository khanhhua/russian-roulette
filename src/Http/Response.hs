module Http.Response where

data Response = Response
    { status :: Int
    , body :: String
    }