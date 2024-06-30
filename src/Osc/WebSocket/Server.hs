module Osc.WebSocket.Server
  ( startApp
  , OscServerConfig (..)
  , OscConfig (..)
  , OscServerConfig (..)
  , OscServer (..)
  , runOscServer
  , newOscServer
  , closeServer
  ) where

import Servant.API.WebSocket (WebSocket)
import Data.Maybe
import Control.Monad.IO.Class   (MonadIO, liftIO)
import Data.Foldable            (forM_)
import Data.Text                (pack)
import Network.Wai              (Application)
import Network.Wai.Handler.Warp (run)
import Network.WebSockets       (
    Connection,
    forkPingThread,
    sendTextData,
    receive,
    Message (..), DataMessage (..), ControlMessage (..),
    sendBinaryData)
import Servant                  ((:>), Proxy (..), Server, serve)
import Network.Socket
import Data.ByteString.Lazy (ByteString)
import Network.Socket.ByteString.Lazy as SB
import Control.Concurrent.Chan.Unagi
import Control.Concurrent (forkIO, killThread, forkFinally, ThreadId)
import Control.Monad
import Control.Exception
import Network.Run.UDP
import Data.Text.Lazy.Encoding qualified as Text

type WebSocketApi = WebSocket

data OscConfig = OscConfig
  { address :: Maybe String -- Nothing is localhost
  , port :: Int
  }

data OscServerConfig = OscServerConfig
  { port :: Int
  , send :: OscConfig
  , listen :: OscConfig
  }

data OscServer = OscServer
  { port :: Int
  , sendSocket :: Socket
  , listenChan :: InChan ByteString
  , listenProcess :: ThreadId
  }

newOscServer :: OscServerConfig -> IO OscServer
newOscServer config = do
  sendSocket <- getSocket (getWithDefAddress config.send.address) config.send.port
  (listenChan, _outChan) <- newChan
  listenProcess <- forkIO $ runUDPServer config.listen.address (show config.listen.port) $
    \sock -> listenOsc sock listenChan
  let port = config.port
  pure OscServer {..}

getWithDefAddress :: Maybe String -> String
getWithDefAddress = fromMaybe "127.0.0.1"

closeServer :: OscServer -> IO ()
closeServer server = killThread server.listenProcess

greet :: OscServer -> IO ()
greet server =
  putStrLn $ "Starting server on http://localhost:" <> show server.port

startApp :: OscServer -> IO ()
startApp server = do
  greet server
  run server.port (app server)
    `finally` closeServer server

app :: OscServer -> Application
app server = serve api (runOscServer server)

api :: Proxy WebSocketApi
api = Proxy

runOscServer :: OscServer -> Server WebSocketApi
runOscServer ctx conn = liftIO $ do
  close <- listenWebSocket ctx.listenChan conn
  loop close
  where
    loop close = do
      msg <- receive conn
      case msg of
        ControlMessage (Close _ _) -> close
        DataMessage _ _ _ (Binary bs) -> do
          SB.send ctx.sendSocket bs
          loop close
        _ -> loop close

listenWebSocket :: InChan ByteString -> Connection -> IO (IO ())
listenWebSocket inChan conn = do
  forkPingThread conn 10
  outChan <- dupChan inChan
  procThread <- forkIO $ forever $ do
    msg <- readChan outChan
    sendBinaryData conn msg
  pure (killThread procThread)

getSocket :: String -> Int -> IO Socket
getSocket addr port = do
   (a:_) <- getAddrInfo Nothing (Just addr) (Just (show port))
   s <- socket (addrFamily a) Datagram defaultProtocol
   connect s (addrAddress a)
   pure s

listenOsc :: Socket -> InChan ByteString -> IO ()
listenOsc socket inChan = forever $ do
  msg <- recv socket 2048
  writeChan inChan msg

