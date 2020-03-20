{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Control.Monad.IO.Class
import Data.Text
import Data.Text.Read
import Database.MySQL.Base
import Domain.Entity.User
import Domain.Repository.UserRepository
import Infra.DBConnect
import Network.HTTP.Types.Status
import Web.Scotty
import Text.Read (readMaybe)

main :: IO ()
main = do
  db <- dbIO :: IO (MySQLConn)
  scotty 3000 $ do
    get "/" $ html "<h1>Hello</h1>"
    get "/users/:uid" $ do
      t <- param "uid"
      case readMaybe t of
        Just i -> liftIO(findById i db) >>= \result -> case result of
          (user : _) -> json user
          _ -> status status400 >> text "Bad Request"
        Nothing -> status status400 >> text "Bad Request"
