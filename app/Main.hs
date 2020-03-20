{-# LANGUAGE OverloadedStrings #-}
module Main where

import Web.Scotty
import Domain.Entity.User
import Domain.Repository.UserRepository
import Infra.DBConnect

main :: IO ()
main = scotty 3000 $ get "/" $ html "<h1>Hello</h1>"
