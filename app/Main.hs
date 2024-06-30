module Main
  ( main
  ) where

import Osc.WebSocket.Server

main :: IO ()
main = do
  server <- newOscServer appConfig
  startApp server

appConfig :: OscServerConfig
appConfig =
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

