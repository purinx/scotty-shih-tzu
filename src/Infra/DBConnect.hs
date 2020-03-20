{-# LANGUAGE OverloadedStrings #-}

module Infra.DBConnect where

import Control.Exception
import Control.Monad         (forever)
import Database.MySQL.Base

dbIO = connect
  defaultConnectInfo
    { ciUser = "root"
    , ciPassword = ""
    , ciDatabase = "shih_tzu"
    }

transactional :: MySQLConn -> IO a -> IO a
transactional conn procedure = mask $ \restore -> do
  execute_ conn "BEGIN"
  a <- restore procedure `onException` (execute_ conn "ROLLBACK")
  execute_ conn "COMMIT"
  pure a
