{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.DogRepository where

import Data.Text (pack)
import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.Dog
import GHC.Word
import Text.Read (readMaybe)
import qualified System.IO.Streams as Streams

createEntity :: [MySQLValue] -> Maybe Dog
createEntity (MySQLInt32 did : MySQLText name : MySQLText bread : MySQLInt32 ownerId : MySQLText ownerName : _) = 
  Just Dog {
    did = readMaybe $ show did
  , name
  , bread
  , ownerId = read $ show ownerId
  , ownerName
  }
createEntity _ = Nothing

findDogById :: Int -> MySQLConn -> IO [Maybe Dog]
findDogById did conn = do
  s <- prepareStmt conn "SELECT dogs.id, dogs.name, dogs.bread, users.id, users.name from dogs inner join users on dogs.owner_id = users.id where dogs.id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral did]
  map createEntity <$> Streams.toList is

createDog :: Dog -> MySQLConn -> IO(OK)
createDog dog conn = do
  s <- prepareStmt conn "INSERT INTO dogs (name, bread, owner_id) values (?, ?, ?)"
  executeStmt conn s [MySQLText $ name dog, MySQLText $ bread dog, MySQLInt32 $ fromIntegral $ ownerId dog]

findAllDog :: MySQLConn -> IO [Maybe Dog]
findAllDog conn = do
  s <- prepareStmt conn "SELECT dogs.id, dogs.name, dogs.bread, users.id, users.name from dogs inner join users on dogs.owner_id = users.id"
  (defs, is) <- queryStmt conn s []
  map createEntity <$> Streams.toList is
