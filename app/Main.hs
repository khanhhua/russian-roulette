{-# LANGUAGE InstanceSigs #-}
module Main where

import System.Directory
import System.FilePath ((</>), takeFileName)
import Server (serve)
import Http.Application (Application (..))
import Http.Response (Response (..), make200)
import Http.Request

type MemberList = [String]

data RussianRoullette
    = Empty
    | ActiveRoom MemberList

main :: IO ()
main = serve $ ActiveRoom ["Tom", "Jerry"]

-- TODO Should look like a dispatcher here
instance Application RussianRoullette where
    route GET "/" = index
    route GET path = serveFile path
    route _ _ = fourOhFour


index :: RussianRoullette -> Request -> IO Response
index app req = pure $
    case app of
        Empty -> Response 200 "empty room"
        ActiveRoom members -> Response 200 $ show (length members)


fourOhFour :: RussianRoullette -> Request -> IO Response
fourOhFour app req = pure $
    Response 404 "Page not found"


serveFile :: String -> RussianRoullette -> Request -> IO Response
serveFile urlPath _ req = make200 <$> readStaticFile
  where
    resolve p = resolveStaticPath
            <$> getCurrentDirectory
            <*> pure p
    readStaticFile = resolve urlPath >>= readFile


resolveStaticPath :: FilePath -> FilePath -> FilePath
resolveStaticPath pwd urlPath = pwd </> "static" </> takeFileName urlPath