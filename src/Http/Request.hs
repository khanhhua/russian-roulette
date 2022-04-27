module Http.Request where

import Data.ByteString ( ByteString )

data Method
    = POST 
    | GET
    | JOIN
    | SHOW
    | ROLL
    | LEAVE

data Request = Request
    { method :: Method
    , body :: String
    }

fromByteString :: ByteString -> Request
fromByteString _bytes =
    Request
        { method = GET
        , body = "Foobar"
        } 