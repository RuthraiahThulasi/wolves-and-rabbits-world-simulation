-module(rabbit_protocol_SUITE).
-include_lib("common_test/include/ct.hrl").

-include_lib("../include/simulation_records.hrl").

-export([ all/0, init_per_testcase/2, end_per_testcase/2 ]).
-export([ rabbit_entity_should_have_world_state_applied/1 ]).

all() ->
    [ rabbit_entity_should_have_world_state_applied ].

init_per_testcase(_TestCase, Config) ->
    WorldParameters = #world_parameters{carrots = 0, rabbits = 0, wolves = 0, width = 5, height = 5},

    simulation_event_stream:start_link(),
    simulation_event_stream:attach_handler(common_test_event_handler),

    {ok, Pid} = simulation_entity_rabbit:start_link({WorldParameters, random}),

    [ {rabbit_entity_pid, Pid}, {world_parameters, WorldParameters} | Config ].

end_per_testcase(_TestCase, Config) ->
    Pid = proplists:get_value(rabbit_entity_pid, Config),
    exit(Pid, normal).

rabbit_entity_should_have_world_state_applied(Config) ->
    WorldParameters = proplists:get_value(world_parameters, Config),
    Pid = proplists:get_value(rabbit_entity_pid, Config),

    {rabbit, born, EntityState} = common_test_event_handler:last_event_of(rabbit, born),

    Pid = EntityState#rabbit.pid,
    WorldParameters = EntityState#rabbit.world.
