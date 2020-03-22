{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Domain.Entity.Photo where

import Data.Aeson
import GHC.Generics
import Data.Text (Text)

data Photo = Photo { 
  pid :: Maybe Int
, dogId :: Int
, dogName :: Text
, bread :: Text
, iconUrl :: Text
, title :: Text
, url :: Text
, userId :: Int
, userName :: Text
} deriving (Show, Generic)

instance ToJSON Photo
instance FromJSON Photo
