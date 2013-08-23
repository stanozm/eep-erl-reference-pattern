%% @author Stanislav Chren
%% @doc @todo Add description to eep_window_tumbling_login.


-module(eep_window_tumbling_time).

-include_lib("eep_erl.hrl").

-export([start/2]).

%% @private.
-export([tumble/3]).

%%--------------------------------------------------------------------
%% @doc
%% Interval - Size of the window in time
%% ActualTime - time of the last incoming login event
%% LastTime - time of the last emit	
%% @end
%%--------------------------------------------------------------------


start(Mod, Interval) ->
    {ok, EventPid } = gen_event:start_link(),
    spawn(?MODULE, tumble, [Mod, EventPid, Interval]).


tumble(Mod, EventPid, Interval) ->
	tumble(Mod, EventPid, Interval, 0, apply(Mod, init, [])).

tumble(Mod,  EventPid, Interval, LastTime, State) ->
	receive
	{ push, Event } ->
		Result = apply(Mod, accumulate, [State, Event]),
	    case Result of
			{NewState,OccurrenceTime} ->
				%% first initialization of ActualTime
				
				case LastTime of 
					0 -> Time = OccurrenceTime;
					_ -> Time = LastTime
				end,
					 
				case OccurrenceTime-Time >= Interval of
					false ->
		    			tumble(Mod,  EventPid, Interval, Time, NewState);
					true ->		
						%% Do not forget to adjust emit() in handler!
		    			gen_event:notify(EventPid, {emit, apply(Mod, emit, [{NewState,OccurrenceTime}])}),
						tumble(Mod,  EventPid, Interval, OccurrenceTime, apply(Mod, init, []))
	    			end;
			_ ->
				tumble(Mod,  EventPid, Interval, LastTime, State)
		end;
	{ add_handler, Handler, Arr } ->
	    gen_event:add_handler(EventPid, Handler, Arr),
	    tumble(Mod,  EventPid, Interval, LastTime, State);
	{ delete_handler, Handler } ->
	    gen_event:delete_handler(EventPid, Handler),
	    tumble(Mod,  EventPid, Interval, LastTime, State);
	stop ->
	    ok;
	{debug, From} ->
	    From ! {debug, {Mod,  EventPid, Interval, LastTime, State}},
	    tumble(Mod,  EventPid, Interval, LastTime, State)
    end.
