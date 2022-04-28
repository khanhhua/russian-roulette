module Http.Application where
import Http.Response
import Http.Request ( Request, Method )

class Application a where
    route :: Method -> String -> a -> Request -> Response
