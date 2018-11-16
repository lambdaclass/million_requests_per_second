-module(mrps_pg2_register).

-behaviour(mrps_register).

-export([init/1,
         store_client/1,
         for_each/1,
         remove_client/1,
         count/0]).

-define(GROUP, clients).

init(_Args) ->
  pg2:create(?GROUP).

store_client(Pid) ->
  pg2:join(?GROUP, Pid).

for_each(Fun) ->
  Clients = pg2:get_members(?GROUP),
  lists:foreach(Fun, Clients).

% No need for remove_client, pg2 does this automatically
remove_client(_) ->
  ok.

count() ->
  Clients = pg2:get_members(?GROUP),
  length(Clients).
