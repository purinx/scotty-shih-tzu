{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Domain.Entity.User where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

data User = User { 
  uid :: Maybe Int
, name :: Text
} deriving (Show, Generic)

instance ToJSON User
instance FromJSON User
