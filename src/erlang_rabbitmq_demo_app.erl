%%%-------------------------------------------------------------------
%% @doc erlang_rabbitmq_demo public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_rabbitmq_demo_app).

-include_lib("amqp_client/include/amqp_client.hrl").

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    run(),
    erlang_rabbitmq_demo_sup:start_link().

stop(_State) ->
    ok.

run() ->

    application:ensure_started(amqp_client),

    {ok, Connection} =
	amqp_connection:start(#amqp_params_network{host =
						       "192.168.1.200",
						   port = 5672,
						   username = <<"bss">>,
						   password =
						       <<"junfang123">>}),
    io:format("created amqp connection \n"),

    {ok, Channel} = amqp_connection:open_channel(Connection),
    io:format("opened amqp connection channel \n"),

    % Message = "foobar",

    Payload = jsx:encode(#{ name => "jiangxp" }),
    Publish = #'basic.publish'{exchange = <<"t.emqx2">>, routing_key = <<"client.connected">>},
    amqp_channel:cast(Channel, Publish, #amqp_msg{
                                            payload = Payload, 
                                            props=#'P_basic'{
                                                content_type = <<"application/json">>, 
                                                content_encoding = <<"UTF-8">>,
                                                headers = [{"type", longstr, "client.connected"}]
                                            }
                                        }),

    amqp_connection:close(Connection),
    io:format("closed amqp connection \n").
