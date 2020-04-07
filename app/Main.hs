{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Main where

import Control.Monad.IO.Class
import Data.Aeson (ToJSON)
import Data.Text
import Data.Text.Read
import Database.MySQL.Base
import Domain.Entity.Dog
import Domain.Entity.User
import Domain.Repository.DogRepository
import Domain.Repository.PhotoRepository
import Domain.Repository.UserRepository
import Domain.Service.AuthService
import GHC.Generics
import Infra.DBConnect
import Infra.ErrorResponse
import Network.HTTP.Types.Status
import Web.Scotty
import Text.Read (readMaybe)

data Token = Token {
  token :: Text
} deriving (Show, Generic)

instance ToJSON Token

main :: IO ()
main = do
  db <- dbIO :: IO (MySQLConn)
  scotty 3000 $ do
    get "/" $ html "<h1>Hello</h1>"

    get "/users/:uid" $ do
      (i :: Int) <- param "uid"
      liftIO(findById i db) >>= maybe
        (status status400 >> text "Bad Request")
        json

    post "/users" $ do
      u <- jsonData
      liftIO(transactional db $ createUser u db)
      status status201 >> text "Success"

    post "/signin" $ do
      u <- jsonData
      liftIO(transactional db $ authenticate u db) >>= either
        createAuthErrorResponse
        (\token -> status status200 >> json Token { token })

    get "/auth" $ do
      (token :: Text) <- param "token"
      liftIO(findByToken token db) >>= maybe
        (status status400 >> text "Invalid Token")
        json

    get "/dogs" $ liftIO(findAllDog db) >>= json

    get "/dogs/:did" $ do
      (i :: Int) <- param "did"
      liftIO(findDogById i db) >>= maybe
        (status status400 >> text "Bad Request")
        json

    post "/dogs" $ do
      d <- jsonData
      liftIO(transactional db $ createDog d db)
      status status201 >> text "Success"

    patch "/dogs" $ do
      d <- jsonData
      liftIO(transactional db $ updateDog d db)
      status status204 >> text "Success"

    get "/photos" $ liftIO(findPhotoAll db) >>= json

    get "/users/:uid/photos" $ do
      (i :: Int) <- param "uid"
      photos <- liftIO(findPhotoByUserId i db)
      json photos

    get "/users/:uid/dogs" $ do
      (uid :: Int) <- param "uid"
      liftIO(findDogByUserId uid db) >>= json

    get "/dogs/:did/photos" $ do
      (i :: Int) <- param "did"
      photos <- liftIO(findPhotoByDogId i db)
      json photos

    post "/photos" $ do
      p <- jsonData
      liftIO(transactional db $ createPhoto p db)
      status status201 >> text "success"
