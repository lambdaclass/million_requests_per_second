-module(mrps_protocol).

-behaviour(ranch_protocol).

-export([start_link/4, init/4]).

start_link(ListenerPid, Socket, Transport, [Register]) ->
    Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport, Register]),
    {ok, Pid}.

init(ListenerPid, _Socket, Transport, Register) ->
    {ok, Socket} = ranch:handshake(ListenerPid),
    Register:store_client(self()),
    ok = Transport:setopts(Socket, [{nodelay, true}, {active, once}]),

    Transport:send(Socket, <<"connected\n">>),
    loop(Socket, Transport, Register).

loop(Socket, Transport, Register) ->
    receive
        {msg, Message} ->
            Transport:send(Socket, Message),
            loop(Socket, Transport, Register);
        {tcp, Socket, <<"SEND", Message/binary>>} ->
            Register:for_each(send_msg(Message, self())),
            ok = Transport:setopts(Socket, [{active, once}]),
            loop(Socket, Transport, Register);
        {tcp, Socket, <<"COUNT\n">>} ->
            Count = integer_to_binary(Register:count()),
            Transport:send(Socket, [Count, <<"\n">>]),
            ok = Transport:setopts(Socket, [{active, once}]),
            loop(Socket, Transport, Register);
        {tcp, Socket, <<"PING\n">>} ->
            Transport:send(Socket, <<"PONG\n">>),
            ok = Transport:setopts(Socket, [{active, once}]),
            loop(Socket, Transport, Register);
        {tcp, Socket, _Data} ->
            ok = Transport:setopts(Socket, [{active, once}]),
            loop(Socket, Transport, Register);           
        {tcp_closed, Socket} ->
            close(Socket, Transport, Register);
        {tcp_closed, Socket, _Reason} ->
            close(Socket, Transport, Register)
	end.

send_msg(Message, Sender) ->
    fun (Client) when Client =:= Sender ->
            pass;
        (Client) ->
            Client ! {msg, Message}
    end.

close(Socket, Transport, Register) ->
    ok = Transport:close(Socket),
    Register:remove_client(self()),
    stop.
