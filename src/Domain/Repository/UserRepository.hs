{-# LANGUAGE OverloadedStrings #-}

module Domain.Repository.UserRepository where

import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.User
import GHC.Word
import qualified System.IO.Streams as Streams

createEntity :: [MySQLValue] -> User
createEntity row = User { 
  uid = read $ show (row !! 0)
, name = show (row !! 1)
, password = show (row !! 2) 
}

findById :: Int -> MySQLConn -> IO [User]
findById uid conn = do
    (defs, is) <- query conn "SELECT * FROM users WHERE id = ?" [MySQLInt32U $ fromIntegral uid]
    map createEntity <$> Streams.toList is
