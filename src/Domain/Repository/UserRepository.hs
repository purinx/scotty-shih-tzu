{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.UserRepository where

import Data.Aeson (FromJSON)
import Data.Text (Text)
import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.User
import GHC.Generics
import GHC.Word
import Text.Read (readMaybe)
import qualified System.IO.Streams as Streams

data CreateUserDto = CreateUserDto {
  cuName :: Text
} deriving (Show, Generic)

instance FromJSON CreateUserDto

createEntity :: [MySQLValue] -> Maybe User
createEntity (MySQLInt32 uid : MySQLText name : _) = Just User { 
  uid = readMaybe $ show uid
, name
}
createEntity _ = Nothing

findById :: Int -> MySQLConn -> IO [Maybe User]
findById uid conn = do
  s <- prepareStmt conn "SELECT * FROM users WHERE id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral uid]
  map createEntity <$> Streams.toList is

createUser :: CreateUserDto -> MySQLConn -> IO(OK)
createUser user conn = do
  s <- prepareStmt conn "INSERT INTO users (name) values (?)"
  executeStmt conn s [MySQLText $ cuName user]
