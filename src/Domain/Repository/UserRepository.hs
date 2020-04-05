{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.UserRepository where

import Crypto.KDF.BCrypt (hashPassword)
import Data.Aeson (FromJSON)
import Data.Text (Text)
-- import Data.Text as T
import Data.Text.Encoding
import Data.Aeson
import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.User
import GHC.Generics
import GHC.Word
import Text.Read (readMaybe)
import Data.ByteString.Char8 (ByteString)
import qualified System.IO.Streams as Streams

data CreateUserDto = CreateUserDto {
  cuName :: Text,
  cuPassword :: Text
} deriving (Show, Generic)

instance FromJSON CreateUserDto

createEntity :: [MySQLValue] -> Maybe User
createEntity (MySQLInt32 uid : MySQLText name : _) = Just User {
  uid = readMaybe $ show uid
, name
}
createEntity _ = Nothing

findById :: Int -> MySQLConn -> IO(Maybe User)
findById uid conn = do
  s <- prepareStmt conn "SELECT * FROM users WHERE id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral uid]
  createEntity . head <$> Streams.toList is

createUser :: CreateUserDto -> MySQLConn -> IO(OK)
createUser user conn = do
  s <- prepareStmt conn "INSERT INTO users (name, password) values (?, ?)"
  passwordHash <- hashPassword 12 . encodeUtf8 $ cuPassword user
  executeStmt conn s [MySQLText $ cuName user, MySQLBytes passwordHash]

getPasswordHash :: [MySQLValue] -> Maybe ByteString
getPasswordHash (MySQLBytes passwordHash : _) = Just passwordHash
getPasswordHash _ = Nothing

findPasswordByName :: Text -> MySQLConn -> IO (Maybe ByteString)
findPasswordByName name conn = do
  s <- prepareStmt conn "SELECT password FROM users WHERE name = ?"
  (defs, is) <- queryStmt conn s [MySQLText name]
  getPasswordHash . head <$> Streams.toList is

setToken :: Text -> Text -> MySQLConn -> IO OK
setToken name token conn = do
  s <- prepareStmt conn "INSERT INTO tokens (user_name, token) VALUES (?, ?)"
  executeStmt conn s [MySQLText name, MySQLText token]

findUserByToken :: Text -> MySQLConn -> IO (Maybe User)
findUserByToken token conn = do
  s <- prepareStmt conn "SELECT users.id, users.name from users INNER JOIN tokens ON tokens.name = users.name where tokens.token = ?"
  (defs, is) <- queryStmt conn s [MySQLText token]
  createEntity . head <$> Streams.toList is
