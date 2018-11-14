-module(mrps_register).

-export([behaviour_info/1]).
-export([start/2, get_all/1, store/2]).

behaviour_info(callbacks) ->
    [{init, 1}, {store_client, 1}, {get_clients, 0}];
behaviour_info(_) ->
    undefined.

start(Register, Args) ->
    Register:init(Args).

get_all(Register) ->
    Register:get_clients().

store(Register, Client) ->
    Register:store(Client).
    