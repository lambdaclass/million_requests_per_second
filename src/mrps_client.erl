-module(mrps_client).

-behaviour(gen_server).

-export([start_link/0, stop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-define(SERVER, "127.0.0.1").
-define(PORT, 6969).

%% API
start_link() ->
    gen_server:start_link(?MODULE, [], []).

stop(Client) ->
    gen_server:call(Client, stop).

%% gen_server
init(_Opts) ->
    {ok, Socket} = connect(?SERVER, ?PORT),
    io:format("Connected Succesfully"),
    {ok, Socket}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, Socket) ->
    gen_tcp:close(Socket).

connect(Host, Port) ->
    case gen_tcp:connect(Host, Port, [{active, false}, binary, {reuseaddr, true}]) of
        {ok, Socket} ->
            {ok, <<"connected\n">>} = gen_tcp:recv(Socket, 0, 30000),
            {ok, Socket};
        {error, Error} ->
            {error, Error}
    end.
