Million Requests per Second
=====

In this project we set up a server that accepts connections from a number of clients, and relays the messages each one sends to the rest of the connected clients.


### Server

Handles client subscription/unsubscription. Echoes messages received from one client to the rest.  



### Client

Sends a message to server every `n` seconds. Receives messages sent from other clients.

### Protocol

TODO

Build
-----

    $ rebar3 compile


* Results
One connection:
- 100000 / (2642493 / 1000000.0) = 38kps

100 tcp connections
- (100 * 100000) / (68789777 / 1000000.0) = 145kps
