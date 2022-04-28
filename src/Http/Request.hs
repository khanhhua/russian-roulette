module Http.Request where

import qualified Data.ByteString.Char8 as C ( unpack, split, splitAt, lines, elemIndex, breakSubstring, pack, dropWhile )
import Data.ByteString ( ByteString )

data Method
    = POST
    | GET
    | JOIN
    | SHOW
    | ROLL
    | LEAVE
    deriving (Show, Read)

data Request = Request
    { path :: String
    , method :: Method
    , body :: String
    }
    deriving (Show)

-- >>> fromByteString $ C.pack "GET /hello.txt HTTP/1.1\n\nFOO"
-- Request {path = "/hello.txt", method = GET, body = "FOO"}
fromByteString :: ByteString -> Request
fromByteString bytes =
    let (httpHeader, httpBody) = C.breakSubstring "\n\n" bytes
        (line0:_) = C.lines httpHeader
        (rawMethod:rawPath:_) = C.split ' ' line0
    in Request
        { path = C.unpack rawPath
        , method = read $ C.unpack rawMethod :: Method
        , body = C.unpack $ C.dropWhile (== '\n') httpBody
        }
        
