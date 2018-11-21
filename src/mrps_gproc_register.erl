-module(mrps_gproc_register).

-behaviour(mrps_register).

-export([init/1,
         store_client/1,
         for_each/1,
         remove_client/1,
         count/0]).

-define(GROUP, clients).

init(_Args) ->
  gproc_app:start().

store_client(_Pid) ->
  gproc:reg({p, l, {?MODULE, ?GROUP}}).

for_each(Fun) ->
  Clients = gproc:lookup_pids({p, l, {?MODULE, ?GROUP}}),
  lists:foreach(Fun, Clients).

remove_client(_) ->
  gproc:unreg({p, l, {?MODULE, ?GROUP}}).

count() ->
  Clients = gproc:lookup_pids({p, l, {?MODULE, ?GROUP}}),
  length(Clients).
