{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Domain.Entity.Dog where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

data User = Dog { 
  did :: Maybe Int
, name :: Text
, bread :: Text
, ownerId :: Maybe Int
, ownerName :: Text
} deriving (Show, Generic)

instance ToJSON User
instance FromJSON User
