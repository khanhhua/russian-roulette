module Http.Http where

import Http.Response ( Response (..) )
import Http.Request ( Request (method, path) )
import Http.Application (Application (route))


dispatch :: Application a => a -> Request -> Request -> Response
dispatch app req = invoke
  where
    invoke = route (method req) (path req) app
