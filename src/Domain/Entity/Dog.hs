{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Domain.Entity.Dog where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

data Dog = Dog { 
  did :: Maybe Int
, name :: Text
, bread :: Text
, ownerId :: Int
, ownerName :: Text
} deriving (Show, Generic)

instance ToJSON Dog
instance FromJSON Dog
