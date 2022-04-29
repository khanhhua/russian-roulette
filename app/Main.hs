{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# LANGUAGE LambdaCase #-}
module Main where

import Control.Concurrent.MVar ( newMVar, modifyMVar_, readMVar, MVar )
import System.Directory
import System.FilePath ((</>), takeFileName)
import Server (serve)
import Http.Application (Application (..))
import Http.Response (Response (..), make200)
import Http.Request
import Control.Monad.IO.Class
import Control.Concurrent (withMVar)

type MemberList = [String]

newtype RussianRoullette = RussianRoullette (MVar Room)

data Room
    = Empty
    | ActiveRoom MemberList
    deriving (Show)


main :: IO ()
main = do
    room <- newMVar Empty
    serve $ RussianRoullette room


-- TODO Should look like a dispatcher here
instance Application RussianRoullette where
    route GET "/" = index
    route GET path = serveFile path
    route JOIN "/" = joinWithAlias
    route SHOW "/" = showRoom
    route _ _ = fourOhFour


index :: RussianRoullette -> Request -> IO Response
index = serveFile "/index.html"


joinWithAlias :: RussianRoullette -> Request -> IO Response
joinWithAlias (RussianRoullette mVarRoom) req = do
    let alias = Http.Request.body req

    modifyMVar_ mVarRoom (
        \case
            Empty -> pure (ActiveRoom [alias])
            ActiveRoom members -> pure $ ActiveRoom (alias : members)
        )

    pure $ make200 "ok"


showRoom :: RussianRoullette -> Request -> IO Response
showRoom (RussianRoullette mVarRoom) req = do
    room <- readMVar mVarRoom
    pure $ make200 $ show room


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