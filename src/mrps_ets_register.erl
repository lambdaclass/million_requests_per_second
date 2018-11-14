-module(mrps_ets_register).

-behaviour(mrps_register).

-export([init/1, store_client/1, get_clients/0]).

init(_Args) ->
    ets:new(clients, [set, named_table]).

store_client(Client={_Pid, _Socket, _Transport}) ->
    ets:insert(clients, Client).

get_clients() ->
    ets:foldl(
        fun(Client, Acc) -> [Client | Acc] end, 
        [],
        clients  
    ).
