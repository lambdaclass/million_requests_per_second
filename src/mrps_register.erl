-module(mrps_register).

-export([behaviour_info/1]).
-export([start/2, get_all/1, store/2]).

behaviour_info(callbacks) ->
    [{init, 1}, {store_client, 1}, {get_clients, 0}];
behaviour_info(_) ->
    undefined.

start(Module, Args) ->
    erlang:apply(Module, init, Args).

get_all(Module) ->
    erlang:apply(Module, get_clients, []).

store(Module, Client) ->
    erlang:apply(Module, store_client, [Client]).
    