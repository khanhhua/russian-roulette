{-# LANGUAGE InstanceSigs #-}
module Main where

import Server (serve)
import Http.Application (Application (..))
import Http.Response (Response (..))
import Http.Request

type MemberList = [String]

data RussianRoullette
    = Empty
    | ActiveRoom MemberList

main :: IO ()
main = serve $ ActiveRoom ["Tom", "Jerry"]

-- TODO Should look like a dispatcher here
instance Application RussianRoullette where
    handle app req =
        case app of
            Empty -> Response 200 "empty room"
            ActiveRoom members -> Response 200 $ show (length members)