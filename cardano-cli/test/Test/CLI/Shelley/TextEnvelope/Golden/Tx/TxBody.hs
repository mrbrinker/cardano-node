{-# LANGUAGE OverloadedStrings #-}

module Test.CLI.Shelley.TextEnvelope.Golden.Tx.TxBody
  ( golden_shelleyTxBody
  ) where

import           Cardano.Prelude

import           Cardano.Api.Typed (AsType(..), HasTextEnvelope (..))

import           Hedgehog (Property)
import qualified Hedgehog as H

import           Test.OptParse


-- | 1. We create a 'TxBody Shelley' file.
--   2. Check the TextEnvelope serialization format has not changed.
golden_shelleyTxBody :: Property
golden_shelleyTxBody =
  propertyOnce $ do
    -- Reference keys
    let referenceTxBody = "test/Test/golden/shelley/tx/txbody"

    -- Key filepaths
    let transactionBodyFile = "transaction-body-file"
        createdFiles = [transactionBodyFile]


    -- Create transaction body
    execCardanoCLIParser
      createdFiles
        $ evalCardanoCLIParser [ "shelley","transaction", "build-raw"
                               , "--tx-in", "91999ea21177b33ebe6b8690724a0c026d410a11ad7521caa350abdafa5394c3#0"
                               , "--tx-out", "615dbe1e2117641f8d618034b801a870ca731ce758c3bedd5c7e4429c103149804+100000000"
                               , "--fee", "1000000"
                               , "--ttl", "500000"
                               , "--out-file", transactionBodyFile
                               ]

    assertFilesExist createdFiles

    let txBodyType = textEnvelopeType AsShelleyTxBody

    -- Check the newly created files have not deviated from the
    -- golden files
    checkTextEnvelopeFormat createdFiles txBodyType referenceTxBody transactionBodyFile

    liftIO $ fileCleanup createdFiles
    H.success
