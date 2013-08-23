%% @author Stanislav Chren
%% @doc @todo Add description to parse_log_json.


-module(parse_log_json).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).



%% ====================================================================
%% Internal functions
%% ====================================================================

%%parse_log(FileName) ->
%% {ok, File} = file:open(FileName, [binary,raw,read_ahead]),
%% lists:reverse(parse_line_json(File, [])).	
	


%%parse_line_json(File, Result) ->
%%	case file:read_line(File) of
%%       eof  ->
%%		   file:close(File),
%%		   Result;
%%	   {ok,Line} -> 
%%			case Line of
%%				<<>> -> parse_line_json(File, Result);
%%			    _ ->  Json = mochijson:decode(Line),
%%					  parse_line_json(File, [Json|Result])
%%			end
%%				
%%	end.


read_log_to_memory(FileName) -> 
	{ok,File} = file:read_file(FileName),
	re:split(File, "\r\n").

send_logs(LogLines, WherePid) ->
	lists:foreach(fun(E) ->
						  case E of
							<<>> -> ok;
							_ -> WherePid ! E
						  end
				  end,
				  LogLines),
	io:fwrite(send_logs_ok).