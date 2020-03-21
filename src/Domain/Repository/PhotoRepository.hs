{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.PhotoRepository where

import Data.Aeson
import Data.Text (Text, pack)
import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.Photo
import GHC.Generics
import GHC.Word
import Text.Read (readMaybe)
import qualified System.IO.Streams as Streams

data CreatePhotoDto = CreatePhotoDto { 
  cpTitle :: Text
, cpDogId :: Int
, cpUserId :: Int
, cpUrl :: Text
} deriving (Show)

createEntity :: [MySQLValue] -> Maybe Photo
createEntity (MySQLInt32 pid : MySQLInt32 dogId : MySQLText dogName : MySQLText bread : MySQLText title : MySQLText url : MySQLInt32 userId : MySQLText userName : _) = 
  Just Photo {
    pid = readMaybe $ show pid
  , dogId = read $ show dogId
  , dogName
  , bread
  , title
  , url
  , userId = read $ show userId
  , userName
  }
createEntity _ = Nothing

findPhotoByUserId :: Int -> MySQLConn -> IO [Maybe Photo]
findPhotoByUserId uid conn = do
  s <- prepareStmt conn "SELECT photos.id, photos.dog_id, dogs.name, dpgs.bread, photos.title, photos.url, photos.user_id, users.name from photos inner join users on photos.user_id = users.id inner join dogs on photos.dog_id = dogs.id where photos.user_id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral uid]
  map createEntity <$> Streams.toList is

findPhotoByDogId :: Int -> MySQLConn -> IO [Maybe Photo]
findPhotoByDogId did conn = do
  s <- prepareStmt conn "SELECT photos.id, photos.dog_id, dogs.name, dogs.bread, photos.title, photos.url, photos.user_id, users.name, from photos inner join users on photos.user_id = users.id inner join dogs photos.dog_id = dogs.id where photos.dog_id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral did]
  map createEntity <$> Streams.toList is

createPhoto :: CreatePhotoDto -> MySQLConn -> IO(OK)
createPhoto photo conn = do
  s <- prepareStmt conn "INSERT INTO pthotos (dog_id, title, url, user_id) values (?, ?, ?, ?)"
  executeStmt conn s [
    MySQLInt32 $ fromIntegral $ cpDogId photo, MySQLText $ cpTitle photo, MySQLText $ cpUrl photo, MySQLInt32 $ fromIntegral $ cpUserId photo]
