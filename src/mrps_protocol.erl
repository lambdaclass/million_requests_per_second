-module(mrps_protocol).

-behaviour(ranch_protocol).

-export([start_link/4,
         init/4]).

-define(IDENTIFIER, 230).
-define(VERSION, 1).

start_link(ListenerPid, Socket, Transport, [Register]) ->
    Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport, Register]),
    {ok, Pid}.

init(ListenerPid, _Socket, Transport, Register) ->
    {ok, Socket} = ranch:handshake(ListenerPid),
    ok = Transport:setopts(Socket, {nodelay, true}),

    Transport:send(Socket, <<?IDENTIFIER, ?VERSION>>),
    loop(Socket, Transport, Register).


loop(Socket, Transport, Register) ->
    case Transport:recv(Socket, 0, 30000) of
        {ok, <<"SEND", Message/binary>>} ->
            Clients = mrps_register:get_all(Register),
            send_msg(Message, Clients, self()),
            loop(Socket, Transport, Register);
        {error, _} ->
            ok
    end.

send_msg(_Message, [], _Sender) ->
    done;
send_msg(Message, [{Sender, _Socket, _Transport} | Rest], Sender) ->
    send_msg(Message, Rest, Sender);
send_msg(Message, [{_Pid, Socket, Transport} | Rest], Sender) ->
    Transport:send(Socket, Message),
    send_msg(Message, Rest, Sender).
