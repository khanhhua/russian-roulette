module Http.Application where
import Http.Response
import Http.Request

class Application a where
    route :: String -> a -> Request -> Response
