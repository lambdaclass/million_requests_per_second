-module(mrps_register).

-export([behaviour_info/1]).
-export([start/2, for_each/2, store/2]).

behaviour_info(callbacks) ->
    [{init, 1}, {store_client, 1}, {for_each, 1}];
behaviour_info(_) ->
    undefined.

start(Register, Args) ->
    Register:init(Args).

store(Register, Client) ->
    Register:store(Client).

for_each(Register, Func) ->
    Register:for_each(Func).

    