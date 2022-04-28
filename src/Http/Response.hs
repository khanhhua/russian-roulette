module Http.Response where

import qualified Data.ByteString.Char8 as B
import Data.ByteString (ByteString)

data Response = Response
    { status :: Int
    , body :: String
    }

make200 :: String -> Response
make200 = Response 200


toByteString :: Response -> ByteString
toByteString resp =
    let header = "HTTP/1.1 200 OK"
    in B.pack (header <> "\n\n" <> body resp)