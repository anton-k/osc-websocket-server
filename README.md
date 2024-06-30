# osc-websocket-server

The server is a relay between browser controller app and OSC-app.
It can send and receive OSC messages and cobvert them to WebSocket 
binary data messages.

It's usefull when you have audio app which is controlled over OSC
and you want to write controller in the browser with knobs, sliders, etc.

### Installation

* Install [stack](https://docs.haskellstack.org/en/stable/).
* clone repo with git and navigate to it:

    ```
    git clone https://github.com/anton-k/osc-websocket-server.git
    cd osc-websocket-server
    ```

* run the server:

    ```
    stack run
    ```
