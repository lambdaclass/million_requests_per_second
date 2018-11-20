-module(mrps_client).

-behaviour(gen_server).

-export([start_link/0, send_message/2, count/1, stop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-define(SERVER, "127.0.0.1").
-define(PORT, 6969).

%% API
start_link() ->
    gen_server:start_link(?MODULE, [], []).

send_message(Client, Message) ->
    gen_server:call(Client, {msg, Message}).

count(Client) ->
    {ok, Count} = gen_server:call(Client, count),
    io:format("Number of connected clients is ~s", [Count]).

stop(Client) ->
    gen_server:call(Client, stop).

%% gen_server
init(_Opts) ->
    connect(?SERVER, ?PORT).

handle_call({msg, Message}, _From, Socket) ->
    ok = gen_tcp:send(Socket, [<<"SEND">>, Message]),
    {reply, ok, Socket};
handle_call(count, _From, Socket) ->
    ok = gen_tcp:send(Socket, <<"COUNT\n">>),
    Response = gen_tcp:recv(Socket, 0, 30000),
    {reply, Response, Socket};
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

connect(Server, Port) ->
    case gen_tcp:connect(Server, Port, [{active, false}, binary, {reuseaddr, true}]) of
        {ok, Socket} ->
            {ok, <<"connected\n">>} = gen_tcp:recv(Socket, 0, 30000),
            {ok, Socket};
        {error, Error} ->
            {error, Error}
    end.
