%% @author Stanislav Chren
%% @doc @todo Add description to json_decoder.


-module(json_parser).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).



%% ====================================================================
%% Internal functions
%% ====================================================================
start(Mode, WherePid) ->
	case Mode of
		decode -> 
			spawn(?MODULE,decode,[WherePid]);
		encode ->
			spawn(?MODULE,encode,[WherePid])
	end.
		

decode(WherePid) ->
	receive
		stop ->
			ok;
		Message ->
			WherePid ! {push, mochijson:decode(Message)},
			decode(WherePid)
		
	end.

encode(WherePid) ->
	receive
		stop ->
			ok;
		Message ->
			%%WherePid ! {mochijson:encode(Message)},
			io:fwrite(mochijson:encode(Message)),
			encode(WherePid)
		
	end.
				   
