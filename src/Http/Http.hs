module Http.Http where

import Http.Response ( Response (..) )
import Http.Request ( Request )
import Http.Application (Application (route))


dispatch :: Application a => String -> a -> Request -> Response
dispatch path app = invoke
  where
    invoke = route path app
