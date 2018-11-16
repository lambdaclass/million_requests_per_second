-module(mrps_app).

-behaviour(application).

-export([start/2, stop/1]).

-define(REGISTER, mrps_ets_register).

start(_StartType, _StartArgs) ->
    ?REGISTER:init([]),
    ranch:start_listener(mrps, 10,
                         ranch_tcp, [{port, 6969}, {max_connections, infinity}],
                         mrps_protocol, [?REGISTER]),
    mrps_sup:start_link().

stop(_State) ->
    ranch:stop_listener(mrps),
    ok.
