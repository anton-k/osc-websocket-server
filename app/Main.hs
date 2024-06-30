module Main
  ( main
  ) where

import Osc.WebSocket.Server

main :: IO ()
main = do
  server <- newOscServer config
  startApp server

config :: OscServerConfig
config =
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

