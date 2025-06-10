module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)

main :: Effect Unit
main = do
  uid <- generate_
  log "🍝 <<<"
  log uid


foreign import generate_ ∷ Effect String

