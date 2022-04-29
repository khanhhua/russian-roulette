{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# LANGUAGE LambdaCase #-}
module Main where

import Control.Concurrent.MVar ( newMVar, modifyMVar_, readMVar, MVar, newEmptyMVar, tryReadMVar, isEmptyMVar, putMVar )
import System.Directory
import System.FilePath ((</>), takeFileName)
import Server (serve)
import Http.Application (Application (..))
import Http.Response (Response (..), make200, make400)
import Http.Request
import Control.Monad.IO.Class
import Control.Concurrent (withMVar)
import System.Random (getStdRandom, Random (randomR))
import qualified Data.Maybe
import Data.Maybe (fromMaybe)

type MemberList = [String]
type Winner = String

data RussianRoullette = RussianRoullette (MVar Room) (MVar Winner)

data Room
    = Empty
    | ActiveRoom MemberList
    deriving (Show)


main :: IO ()
main = do
    room <- newMVar Empty
    winner <- newEmptyMVar
    serve $ RussianRoullette room winner


-- TODO Should look like a dispatcher here
instance Application RussianRoullette where
    route GET "/" = index
    route GET path = serveFile path
    route JOIN "/" = joinWithAlias
    route SHOW "/" = showRoom
    route ROLL "/" = roll
    route _ _ = fourOhFour


index :: RussianRoullette -> Request -> IO Response
index = serveFile "/index.html"


joinWithAlias :: RussianRoullette -> Request -> IO Response
joinWithAlias (RussianRoullette mVarRoom _) req = do
    let alias = Http.Request.body req

    modifyMVar_ mVarRoom (
        \case
            Empty -> pure (ActiveRoom [alias])
            ActiveRoom members -> pure $ ActiveRoom (alias : members)
        )

    pure $ make200 "ok"


showRoom :: RussianRoullette -> Request -> IO Response
showRoom (RussianRoullette mVarRoom mVarWinner) req = do
    room <- readMVar mVarRoom
    winner <- showMaybe <$> tryReadMVar mVarWinner
    pure $ make200 $ show room <> " Winner: " <> winner

  where
    showMaybe = fromMaybe "No winner"



roll :: RussianRoullette -> Request -> IO Response
roll (RussianRoullette mVarRoom mVarWinner) req = do
    room <- readMVar mVarRoom
    case room of
        Empty ->
            pure $ make400 "Empty room"
        ActiveRoom members -> do
            chosenIndex <- getStdRandom $ randomR (0, length members)
            isWinnerEmpty <- isEmptyMVar mVarWinner
            let winner = members!!chosenIndex

            if isWinnerEmpty then do
                putMVar mVarWinner winner
            else do
                modifyMVar_ mVarWinner (\_ -> pure winner)
            pure $ make200 $ "Winner: " <> winner


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