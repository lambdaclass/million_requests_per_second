-module(mrps_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ranch:start_listener(mrps, 10,
                         ranch_tcp, [{port, 6969}, {max_connections, infinity}],
                         mrps_protocol, []),
    mrps_sup:start_link().

stop(_State) ->
    ok.
