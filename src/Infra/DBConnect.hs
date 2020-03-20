{-# LANGUAGE OverloadedStrings #-}

module Infra.DBConnect where

import Control.Monad         (forever)
import Database.MySQL.Base

dbIO = connect
    defaultConnectInfo
        { ciUser = "root"
        , ciPassword = ""
        , ciDatabase = "shih_tzu"
        }
