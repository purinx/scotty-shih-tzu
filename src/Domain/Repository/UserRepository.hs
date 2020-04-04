{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Repository.UserRepository where

import Crypto.KDF.BCrypt (hashPassword, validatePassword)
import Data.Aeson (FromJSON)
import Data.Text (Text)
import Data.Text as T
import Data.Text.Encoding
import Data.Aeson
import Database.MySQL.Base
import Database.MySQL.Protocol.MySQLValue
import Domain.Entity.User
import GHC.Generics
import GHC.Word
import Text.Read (readMaybe)
import qualified Data.ByteString as B
import Data.ByteString.Char8 as C8
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

findById :: Int -> MySQLConn -> IO [Maybe User]
findById uid conn = do
  s <- prepareStmt conn "SELECT * FROM users WHERE id = ?"
  (defs, is) <- queryStmt conn s [MySQLInt32U $ fromIntegral uid]
  Prelude.map createEntity <$> Streams.toList is

createUser :: CreateUserDto -> MySQLConn -> IO(OK)
createUser user conn = do
  s <- prepareStmt conn "INSERT INTO users (name, password) values (?, ?)"
  passwordHash <- hashPassword 12 $ C8.pack $ T.unpack $ cuPassword user
  executeStmt conn s [MySQLText $ cuName user, MySQLBytes passwordHash]
