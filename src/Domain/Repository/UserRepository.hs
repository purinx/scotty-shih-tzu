{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.UserRepository where

import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.User
import GHC.Word
import Text.Read (readMaybe)
import qualified System.IO.Streams as Streams

createEntity :: [MySQLValue] -> Maybe User
createEntity [MySQLInt32U uid, MySQLText name, MySQLText password] = Just User { 
  uid = readMaybe $ show uid
, name = show name
, password = show password
}
createEntity _ = Nothing

findById :: Int -> MySQLConn -> IO [Maybe User]
findById uid conn = do
    (defs, is) <- query conn "SELECT * FROM users WHERE id = ?" [MySQLInt32U $ fromIntegral uid]
    map createEntity <$> Streams.toList is
