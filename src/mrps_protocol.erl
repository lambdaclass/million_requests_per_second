-module(mrps_protocol).

-behaviour(gen_server).
-behaviour(ranch_protocol).

%% gen_server
-export([handle_call/3, handle_cast/2, handle_info/2]).

%% ranch_protocol
-export([start_link/4,
         init/4]).

-define(IDENTIFIER, 230).
-define(VERSION, 1).


%% ranch_protocol
init(ListenerPid, _Socket, Transport, _Opts) ->
    ok = proc_lib:init_ack({ok, self()}),
    ok = ranch:accept_ack(ListenerPid),
    {ok, Socket} = ranch:handshake(ListenerPid),
    ok = Transport:setopts(Socket, {nodelay, true}),

    Transport:send(Socket, <<?IDENTIFIER, ?VERSION>>),
    gen_server:enter_loop(?MODULE, [], #{socket => Socket, transport => Transport}).


%% gen_server
start_link(ListenerPid, Socket, Transport, Opts) ->
    proc_lib:start_link(?MODULE, init, [[ListenerPid, Socket, Transport, Opts]]).

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast({msg, Message}, State=#{socket := Socket, transport := Transport}) ->
    Transport:send(Socket, Message),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({tcp, _Socket, <<"SEND", Message/binary>>}, State) ->
    Pids = ranch:procs(mrps, connections),
    [gen_server:cast(Pid, {msg, Message}) || Pid <- Pids],
    {noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
    {stop, normal, State};
handle_info({tcp_error, _Socket, Reason}, State) ->
    {stop, Reason, State};
handle_info(_Info, State) ->
    {noreply, State}.
