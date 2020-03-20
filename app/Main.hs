{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Control.Monad.IO.Class
import Data.Text
import Data.Text.Read
import Database.MySQL.Base
import Domain.Entity.Dog
import Domain.Entity.User
import Domain.Repository.DogRepository
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
      (i :: Int) <- param "uid"
      liftIO(findById i db) >>= \result -> case result of
        (Just user : _) -> json user
        _ -> status status400 >> text "Bad Request"
    get "/dogs/:did" $ do
      (i :: Int) <- param "did"
      liftIO(findDogById i db) >>= \result -> case result of
        (Just dog : _) -> json dog
        _ -> status status400 >> text "Bad Request"

