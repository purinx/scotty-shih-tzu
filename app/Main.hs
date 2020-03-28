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
import Domain.Repository.PhotoRepository
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

    post "/users" $ do
      u <- jsonData
      liftIO(transactional db $ createUser u db)
      status status201 >> text "Success"

    get "/dogs" $ do
      dogs <- liftIO(findAllDog db)
      json dogs

    get "/dogs/:did" $ do
      (i :: Int) <- param "did"
      liftIO(findDogById i db) >>= \result -> case result of
        (Just dog : _) -> json dog
        _ -> status status400 >> text "Bad Request"

    post "/dogs" $ do
      d <- jsonData
      liftIO(transactional db $ createDog d db)
      status status201 >> text "Success"

    patch "/dogs" $ do
      d <- jsonData
      liftIO(transactional db $ updateDog d db)
      status status204 >> text "Success"

    get "/photos" $ do
      photos <- liftIO(findPhotoAll db)
      json photos

    get "/users/:uid/photos" $ do
      (i :: Int) <- param "uid"
      photos <- liftIO(findPhotoByUserId i db)
      json photos

    get "/dogs/:did/photos" $ do
      (i :: Int) <- param "did"
      photos <- liftIO(findPhotoByDogId i db)
      json photos

    post "/photos" $ do
      p <- jsonData
      liftIO(transactional db $ createPhoto p db)
      status status201 >> text "success"
