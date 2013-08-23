%% @author Stanislav Chren
%% @doc @todo Add description to distributed_attack_test.


-module(distributed_attack_test).

%% ====================================================================
%% API functions
%% ====================================================================

-compile(export_all).


%% ====================================================================
%% Internal functions
%% ====================================================================

start(LogFileName) ->
	spawn(?MODULE,test,[LogFileName,60000, 120000]).

test(LogFileName,Interval1,Interval2) -> 
	%%WindowPid = eep_window_tumbling:start(eep_repeated_login, WindowSize),
	%%WindowPid ! {add_handler, eep_emit_trace, []},

	Window1Pid = eep_window_tumbling_time:start(eep_repeated_login, Interval1),
	Window2Pid = eep_window_tumbling_time:start(eep_attack, Interval2),
	
	DecoderPid = json_parser:start(decode, Window1Pid),
	
	%% Not working now
	%%EncoderPid = json_parser:start(encode, self()),
	
	Window1Pid ! {add_handler, eep_and_handler, Window2Pid},
	Window2Pid ! {add_handler, eep_emit_trace, []},
	
	Logs = parse_log_json:read_log_to_memory(LogFileName),
	parse_log_json:send_logs(Logs, DecoderPid),
	
	receive
		stop ->
			Window1Pid ! stop,
			Window2Pid ! stop,
			DecoderPid ! stop,
			io:fwrite(test_stop_ok)
	end.

