-module(mrps_ets_register).

-behaviour(mrps_register).

-export([init/1, store_client/1, for_each/1]).

init(_Args) ->
    ets:new(clients, [set, named_table]).

store_client(Client) ->
    ets:insert(clients, Client).

for_each(Func) ->
    ets:foldl(
        fun(Client, _Acc) -> Func(Client) end, 
        [],
        clients  
    ).
