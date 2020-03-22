{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
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
} deriving (Show, Generic)

instance FromJSON CreatePhotoDto

createEntity :: [MySQLValue] -> Maybe Photo
createEntity (MySQLInt32 pid : MySQLInt32 dogId : MySQLText dogName : MySQLText bread : MySQLText iconUrl : MySQLText title : MySQLText url : MySQLInt32 userId : MySQLText userName : _) = 
  Just Photo {
    pid = readMaybe $ show pid
  , dogId = read $ show dogId
  , dogName
  , bread
  , iconUrl 
  , title
  , url
  , userId = read $ show userId
  , userName
  }
createEntity _ = Nothing

findPhotoAll :: MySQLConn -> IO [Maybe Photo]
findPhotoAll conn = do 
  s <- prepareStmt conn "SELECT p.id, d.id, d.name, d.bread, d.icon_url, p.title, p.url, u.id, u.name from photos p inner join users u on p.user_id = u.id inner join dogs d on p.dog_id = d.id"
  (defs, is) <- queryStmt conn s []
  map createEntity <$> Streams.toList is

findPhotoByUserId :: Int -> MySQLConn -> IO [Maybe Photo]
findPhotoByUserId uid conn = do
  s <- prepareStmt conn "SELECT p.id, d.id, d.name, d.bread, d.icon_url, p.title, p.url, u.id, u.name from photos p inner join users u on p.user_id = u.id AND u.id = ?  inner join dogs d on p.dog_id = d.id"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral uid]
  map createEntity <$> Streams.toList is

findPhotoByDogId :: Int -> MySQLConn -> IO [Maybe Photo]
findPhotoByDogId did conn = do
  s <- prepareStmt conn "SELECT p.id, d.id, d.name, d.bread, d.icon_url, p.title, p.url, u.id, u.name from photos p inner join users u on p.user_id = u.id inner join dogs d on p.dog_id = d.id AND d.id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral did]
  map createEntity <$> Streams.toList is

createPhoto :: CreatePhotoDto -> MySQLConn -> IO(OK)
createPhoto photo conn = do
  s <- prepareStmt conn "INSERT INTO photos (dog_id, title, url, user_id) values (?, ?, ?, ?)"
  executeStmt conn s [
    MySQLInt32 $ fromIntegral $ cpDogId photo, MySQLText $ cpTitle photo, MySQLText $ cpUrl photo, MySQLInt32 $ fromIntegral $ cpUserId photo]
