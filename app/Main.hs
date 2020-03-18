{-# LANGUAGE OverloadedStrings #-}
module Main where
import Web.Scotty
main :: IO ()
main = scotty 3000 $ get "/" $ html "<h1>Hello</h1>"
