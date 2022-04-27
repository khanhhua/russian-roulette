module Http.Http where

import qualified Data.ByteString.Char8 as B
import Network.Socket ( Socket, socket )
import Network.Socket.ByteString ( sendAll )
import Http.Response ( Response (..) )
import Http.Request ( Request )


sendResponse :: Socket -> Response -> IO ()
sendResponse sock resp =
    let header = "HTTP/1.1 200 OK"
    in sendAll sock $
        B.pack (header <> "\n\n" <> body resp)

dispatch :: Request -> Response
dispatch _req =
    Response 200 "ok"
