{-# LANGUAGE OverloadedStrings #-}

module Infra.DBConnect where

import Control.Monad         (forever)
import Database.MySQL.Base

conn = connect
    defaultConnectInfo
        { ciUser = "root"
        , ciPassword = ""
        , ciDatabase = "shih_tzu"
        }
