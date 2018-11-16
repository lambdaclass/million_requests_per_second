-module(mrps_register).

-export([behaviour_info/1]).

behaviour_info(callbacks) ->
    [{init, 1}, {store_client, 1}, {remove_client, 1}, {for_each, 1}, {count, 0}];
behaviour_info(_) ->
    undefined.
