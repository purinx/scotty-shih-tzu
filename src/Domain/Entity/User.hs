{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Domain.Entity.User where

import Data.Aeson
import GHC.Generics

data User = User { 
  uid :: Maybe Int, 
  name :: String, 
  password :: String 
} deriving (Show, Generic)

instance ToJSON User
instance FromJSON User
