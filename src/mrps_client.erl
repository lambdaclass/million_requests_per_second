-module(mrps_client).

-export([start_link/2,
         client/1]).


start_link(N, M) ->
    [spawn_link(fun() ->
                        ok = client(M)
                end) || _ <- lists:seq(1, N)].

client(M) ->
    case connect() of
        {ok, Socket} ->
            [{ok, _} = send(Socket, I) || I <- lists:seq(1, M)],
            close(Socket);
        {error, Error} ->
            {error, Error}
    end.

connect() ->
    case gen_tcp:connect("127.0.0.1", 6969, [{active, false}, binary, {reuseaddr, true}]) of
        {ok, Sock} ->
            ok = gen_tcp:send(Sock, <<230, 1, 1, 0>>),
            {ok, <<230, 1, 2, 0>>} = gen_tcp:recv(Sock, 0, 30000),
            {ok, Sock};
        {error, Error} ->
            {error, Error}
    end.

close(Socket) ->
    ok = gen_tcp:send(Socket, <<230, 1, 5, 0>>),
    gen_tcp:close(Socket).

send(Socket, Number) ->
    ok = gen_tcp:send(Socket, <<230, 1, 3, 4, Number:32>>),
    {ok, Packet} = gen_tcp:recv(Socket, 0, 30000),
    <<230, 1, 4, 4, Number2:32>> = Packet,
    {ok, Number2}.
