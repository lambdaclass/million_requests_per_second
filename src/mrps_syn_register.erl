-module(mrps_syn_register).

-behaviour(mrps_register).

-export([init/1, store_client/1, remove_client/1, for_each/1, count/0]).

init(_Args) ->
    syn:start(),
    syn:init().

store_client(Client) ->
    syn:join(clients, Client).

remove_client(_Client) ->
    ok.

for_each(Func) ->
    lists:foreach(Func, syn:get_members(clients)).

count() ->
    syn:registry_count().
