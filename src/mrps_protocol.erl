-module(mrps_protocol).

-export([start_link/4,
         init/3]).

-define(IDENTIFIER, 230).
-define(VERSION, 1).

start_link(ListenerPid, Socket, Transport, _Opts) ->
    Pid = spawn_link(?MODULE, init, [ListenerPid, Socket, Transport]),
    {ok, Pid}.

init(ListenerPid, Socket, Transport) ->
    ok = ranch:accept_ack(ListenerPid),
    ok = inet:setopts(Socket, [{nodelay, true}]),
    case Transport:recv(Socket, 0, 30000) of
        {ok, Packet} ->
            Data = remove_header(Packet),
            process(Socket, Transport, Data),
            Time = erlang:timestamp(),
            loop(Socket, Transport, <<>>, Time);
        {error, _} ->
            ok
    end.

loop(Socket, Transport, Buffer, Time) ->
    case Transport:recv(Socket, 0, 30000) of
        {ok, Packet} ->
            Buffer2 = << Buffer/binary, Packet/binary >>,
            Data = remove_header(Buffer2),
            case process(Socket, Transport, Data) of
                {ok, Rest} ->
                    loop(Socket, Transport, Rest, Time);
                close ->
                    EndTime = erlang:timestamp(),
                    Diff = timer:now_diff(EndTime, Time),
                    io:format("TimeDiff ~p~n", [Diff]),
                    Transport:close(Socket)
                end;
        {error, _} ->
            ok
    end.

process(Socket, Transport, <<1, 0>>) ->
    ok = Transport:send(Socket, add_header(<<2, 0>>)),
    {ok, <<>>};
process(Socket, Transport, <<3, 4, Number:32>>) ->
    ok = Transport:send(Socket, add_header(<<4, 4, Number:32>>)),
    {ok, <<>>};
process(Socket, Transport, <<5, 0>>) ->
    ok = Transport:send(Socket, add_header(<<6, 0>>)),
    close;
process(_Socket, _Transport, Data) ->
    io:format("Received malformed package ~p~n", [Data]),
    {ok, <<>>}.

add_header(Data) ->
    <<?IDENTIFIER, ?VERSION, Data/binary>>.

remove_header(Packet) ->
    <<?IDENTIFIER, ?VERSION, Data/binary>> = Packet,
    Data.
