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

By default it starts server on port 9090, listens on 3333 and sends to 3334.
We can change the defaults if we pass the YAML-config file to the server:

```
stack run -- config.yaml
```

Config file example:

```yaml
port: 9090
listen:
    address: 127.0.0.1
    port: 3333
send:
    address: 127.0.0.1
    port: 3334
```

Note that address is optional if missing the `localhost` is used.

