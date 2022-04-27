module Http.Application where
import Http.Response
import Http.Request
import Http.Http

class Application a where
    handle :: a -> Request -> Response
    handle a = dispatch
