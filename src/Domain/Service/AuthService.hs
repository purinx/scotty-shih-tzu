{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Domain.Service.AuthService where

import Control.Monad.IO.Class
import Crypto.KDF.BCrypt (validatePassword)
import Data.ByteString.Char8 as C8
import Data.Either
import Data.Text (Text)
import Data.Text.Encoding
import Data.UUID (toText, UUID)
import Data.UUID.V1
import Database.MySQL.Base
import Domain.Repository.UserRepository

data AuthError = UserNotFound
               | PasswordInvalid
               | DBError

-- 認証
validate :: Text -> Maybe C8.ByteString -> Either AuthError Bool
validate password = maybe
  (Left UserNotFound)
  (Right . validatePassword (encodeUtf8 password))

generateToken :: IO Text
generateToken = nextUUID >>= maybe generateToken (return . toText)

publishToken :: Text -> MySQLConn -> IO (Either AuthError Text)
publishToken name conn = do
  token <- generateToken
  setToken name token conn
  return (Right token)

authenticate :: CreateUserDto -> MySQLConn -> IO (Either AuthError Text)
authenticate (CreateUserDto cuName cuPassword) conn = do
  passwordHashResult <- findPasswordByName cuName conn
  validationResult <- return(validate cuPassword passwordHashResult)
  case validationResult of
    (Right True) -> publishToken cuName conn
    (Right False) -> return(Left PasswordInvalid)
    (Left e) -> return (Left e)

-- 認可
-- authorize :: Text -> MySQLConn -> Either
