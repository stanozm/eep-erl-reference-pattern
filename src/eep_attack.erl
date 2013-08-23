%% @author Stanislav Chren
%% @doc @todo Add description to eep_attack.


-module(eep_attack).

-include_lib("eep_erl.hrl").

-behaviour(eep_aggregate).

%% aggregate behaviour.
-export([init/0]).
-export([accumulate/2]).
-export([compensate/2]).
-export([emit/1]).

init() ->
  Hosts = sets:new(),
  Users = sets:new(),
  {Hosts,Users}.

accumulate(State, {OccurrenceTime, List}) ->
  NewState = lists:foldl(fun add_host_and_user/2, State, List),
  {NewState, OccurrenceTime}.
  
  
 
			  
%% not implemented, will not work with sliding window yet!
compensate(State,X) ->
  State.

emit({State,OccurrenceTime}) ->
 {Hosts, Users} = State,
 HostsNumber = sets:size(Hosts),
 case  HostsNumber >= 5 of
	 true -> 
	 	JsonTuple = {struct, [{"ComplexEvent",
					 			  {struct, [{"id", OccurrenceTime},
											{"hostname", "processing-agent-XX.fi.muni.cz"},
											{"entity", "cloud1-group"},
											{"type", "cz.muni.fi.ngmon.DISTRIBUOVANY_SL_UTOK"},
											{"http://ngmon.fi.muni.cz/v1.0/...", 
											 	{struct, [{"hostnames", sets:to_list(Hosts)},
														  {"hostsNumber", HostsNumber},
														  {"users", sets:to_list(Users)}
														 ]
												}
											}
										   ]
								  }
							  }
							 ]
					};
	 false ->
		 noevent
 end.
 


add_host_and_user({Host,User}, {Hosts,Users}) ->
	NewHosts = sets:add_element(Host, Hosts),
	NewUsers = sets:add_element(User, Users),
	{NewHosts, NewUsers}.
	
	