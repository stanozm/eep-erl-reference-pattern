%% @author Stanislav Chren
%% @doc @todo Add description to eep_stats_login.


-module(eep_repeated_login).

-include_lib("eep_erl.hrl").

-behaviour(eep_aggregate).

%% aggregate behaviour.
-export([init/0]).
-export([accumulate/2]).
-export([compensate/2]).
-export([emit/1]).

init() ->
  dict:new().

accumulate(State,X) ->
  case is_login_event(X) of
	  {true, MainData} -> 
		  OccurrenceTime = proplists:get_value("occurrenceTime", MainData),
		  Host = proplists:get_value("host", MainData),
		  
		  {struct, Payload} = proplists:get_value("_", MainData),
		  User = proplists:get_value("user", Payload),
		  proplists:get_value("success", Payload),
		  
		  case proplists:get_value("success", Payload) of 
			 false -> 
				 {dict:update_counter({Host,User}, 1, State), OccurrenceTime};
			 true ->
				 {State,OccurrenceTime}
		  end;
  	  {false, MainData} ->
		 State
  end.
 
			  
%% not implemented!
compensate(State,X) ->
  State.

emit({State,OccurrenceTime}) ->
 Filtered =  dict:filter(
			  fun(_,Value) ->
				  Value >= 1000
			  end,
			  State),
{OccurrenceTime,dict:fetch_keys(State)}.
 %%{OccurrenceTime,dict:to_list(Filtered)}.


is_login_event(X) ->
	{struct, Obj} = X,
	{struct, MainData} = proplists:get_value("Event", Obj),
	
	case proplists:get_value("type", MainData) of
		"org.ssh.Daemon#Login" ->
			{true,MainData};
		_ ->
			{false, MainData}
	end.
		
	