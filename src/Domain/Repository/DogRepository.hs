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

createEntity :: [MySQLValue] -> Maybe User
createEntity (MySQLInt32 did : MySQLText name : MySQLText bread : MySQLInt32 ownerId : MySQLText ownerName : _) = 
  Just Dog {
    did = readMaybe $ show did
  , name
  , bread
  , ownerId = readMaybe $ show ownerId
  , ownerName
  }
createEntity _ = Nothing

findDogById :: Int -> MySQLConn -> IO [Maybe User]
findDogById did conn = do
  s <- prepareStmt conn "SELECT dogs.id, dogs.name, dogs.bread, users.id, users.name from dogs inner join users on dogs.owner_id = users.id where dogs.id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral did]
  map createEntity <$> Streams.toList is
