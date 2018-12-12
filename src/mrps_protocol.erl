-module(mrps_protocol).

-behaviour(ranch_protocol).

-export([start_link/4, init/4]).

-define(VERSION, "0.1").

start_link(ListenerPid, Socket, Transport, [Register]) ->
    Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport, Register]),
    {ok, Pid}.

init(ListenerPid, _Socket, Transport, Register) ->
    {ok, Socket} = ranch:handshake(ListenerPid),
    Register:store_client(self()),

    case handshake(Socket, Transport) of
        ok -> loop(Socket, Transport, Register);
        stop -> close(Socket, Transport, Register)
    end.

loop(Socket, Transport, Register) ->
    ok = Transport:setopts(Socket, [{active, once}]),
    receive
        {msg, Message} ->
            Transport:send(Socket, ["Received message:\n", Message]),
            loop(Socket, Transport, Register);
        {tcp, Socket, <<"SEND", Message/binary>>} ->
            Register:for_each(send_msg(Message, self())),
            Transport:send(Socket, <<"Message sent\n">>),
            loop(Socket, Transport, Register);
        {tcp, Socket, <<"COUNT\n">>} ->
            Count = integer_to_binary(Register:count()),
            Transport:send(Socket, [Count, <<"\n">>]),
            loop(Socket, Transport, Register);
        {tcp, Socket, <<"EXIT\n">>} ->
            close(Socket, Transport, Register);
        {tcp, Socket, _Data} ->
            loop(Socket, Transport, Register);           
        {tcp_closed, Socket} ->
            close(Socket, Transport, Register);
        {tcp_closed, Socket, _Reason} ->
            close(Socket, Transport, Register)
	end.

handshake(Socket, Transport) ->
	Transport:send(Socket, ["MRPS server ", ?VERSION, $\n]),
	case Transport:recv(Socket, 0, 5000) of
		{ok, <<"CONNECT\n">>} ->
			Transport:send(Socket, <<"Connected\n">>),
            ok;
		_ -> stop
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
