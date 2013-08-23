%% @author Stanislav Chren
%% @doc @todo Add description to eep_and_handler.


-module(eep_and_handler).

-behaviour(gen_event).

%% behaviour. 
-export([init/1]).
-export([handle_event/2]).
-export([handle_call/2]).
-export([handle_info/2]).
-export([code_change/3]).
-export([terminate/2]).
 
init(OutputPid) ->
  {ok, OutputPid}.
 
handle_event({emit, What}, State) ->
  io:format("Emit: ~p~n", [What]),
  State ! {push, What},
  {ok, State};

handle_event(_, State) ->
  io:format("Unknown event~n", []),
  {ok, State}.
 
handle_call(_, State) ->
  io:format("Unknown call~n", []),
  {ok, ok, State}.
 
handle_info(_, State) ->
  {ok, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
 
terminate(_Reason, _State) ->
  ok.
