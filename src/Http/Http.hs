module Http.Http where

import Http.Response ( Response (..) )
import Http.Request ( Request (method, path) )
import Http.Application (Application (route))


dispatch :: Application a => Request -> a -> Request -> IO Response
dispatch req = invoke
  where
    invoke = route (method req) (path req)
