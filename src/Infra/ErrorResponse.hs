{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}
module Infra.ErrorResponse where

import Domain.Service.AuthService
import Network.HTTP.Types.Status
import Web.Scotty

createAuthErrorResponse :: AuthError -> ActionM ()
createAuthErrorResponse UserNotFound = status status401 >> text "User not found"
createAuthErrorResponse PasswordInvalid = status status401 >> text "Password invalid"
createAuthErrorResponse _ = status status500 >> text "Internal Server Error"
