{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.DogRepository where

import Data.Aeson
import Data.Text (Text)
import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.Dog
import GHC.Generics
import GHC.Word
import System.Exit (die)
import Text.Read (readMaybe)
import qualified System.IO.Streams as Streams

data CreateDogDto = CreateDogDto {
  cdName :: Text
, cdBread :: Text
, cdIconUrl :: Text
, cdOwnerId :: Int
, cdBio :: Text
} deriving (Show, Generic)

instance FromJSON CreateDogDto

createEntity :: [MySQLValue] -> Maybe Dog
createEntity (MySQLInt32 did : MySQLText name : MySQLText bread : MySQLText iconUrl : MySQLInt32 ownerId : MySQLText ownerName : MySQLText bio :_) =
  Just Dog {
    did = readMaybe $ show did
  , name
  , bread
  , iconUrl
  , ownerId = read $ show ownerId
  , ownerName
  , bio
  }
createEntity _ = Nothing

findDogById :: Int -> MySQLConn -> IO(Maybe Dog)
findDogById did conn = do
  s <- prepareStmt conn "SELECT dogs.id, dogs.name, dogs.bread, dogs.icon_url, users.id, users.name, dogs.bio from dogs inner join users on dogs.owner_id = users.id where dogs.id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral did]
  createEntity . head <$> Streams.toList is

createDog :: CreateDogDto -> MySQLConn -> IO(OK)
createDog dog conn = do
  s <- prepareStmt conn "INSERT INTO dogs (name, bread, icon_url, owner_id, bio) values (?, ?, ?, ?, ?)"
  executeStmt conn s [MySQLText $ cdName dog, MySQLText $ cdBread dog, MySQLText $ cdIconUrl dog, MySQLInt32 $ fromIntegral $ cdOwnerId dog, MySQLText $ cdBio dog]

findAllDog :: MySQLConn -> IO[Maybe Dog]
findAllDog conn = do
  s <- prepareStmt conn "SELECT dogs.id, dogs.name, dogs.bread, dogs.icon_url, users.id, users.name, dogs.bio from dogs inner join users on dogs.owner_id = users.id"
  (defs, is) <- queryStmt conn s []
  map createEntity <$> Streams.toList is

findDogByUserId :: Int -> MySQLConn -> IO[Maybe Dog]
findDogByUserId uid conn = do
  s <- prepareStmt conn "SELECT dogs.id, dogs.name, dogs.bread, dogs.icon_url, users.id, users.name, dogs.bio from dogs INNER JOIN users ON dogs.owner_id = users.id WHERE users.id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32 $ fromIntegral uid]
  map createEntity <$> Streams.toList is

updateDog :: Dog -> MySQLConn -> IO (OK)
updateDog dog conn = do
  case did dog of
    Nothing -> die "did is undefined"
    Just i -> do
      s <- prepareStmt conn "UPDATE dogs SET name=?, bread=?, icon_url=?, bio=? where id = ?"
      executeStmt conn s [MySQLText $ name dog, MySQLText $ bread dog, MySQLText $ iconUrl dog, MySQLText $ bio dog, MySQLInt32 $ fromIntegral i]
