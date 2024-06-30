module Main
  ( main
  ) where

import Osc.WebSocket.Server
import Data.Yaml qualified as Yaml
import System.Environment (getArgs)

main :: IO ()
main = do
  eConfig <- readConfig
  case eConfig of
    Right config -> do
      server <- newOscServer config
      startApp server
    Left err -> putStrLn $ "Failed to read config: " <> err

readConfig :: IO (Either String OscServerConfig)
readConfig = do
  args <- getArgs
  case args of
    [] -> pure $ Right defaultConfig
    file : _ -> do
      eConfig <- Yaml.decodeFileEither file
      case eConfig of
        Right config -> pure $ Right config
        Left err -> pure $ Left $ show err

defaultConfig :: OscServerConfig
defaultConfig =
  OscServerConfig
    { port = 9090
    , send = OscConfig
        { address = Nothing
        , port = 3334
        }
    , listen = OscConfig
        { address = Nothing
        , port = 3333
        }
    }

