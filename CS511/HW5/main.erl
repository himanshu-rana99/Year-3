%%"I pledge my honor that I have abided by the Stevens Honor System" - Himanshu Rana - hrana2 

-module(main). 
-compile(export_all). 
-author("Himanshu Rana").

start() -> 
	{ok, [ N ]} = io:fread("enter number of sensors>", "~d"),
	if N =< 1 -> 
		io:fwrite("setup: range must be at least 2~n", []);
	true -> 
		Num_watchers = 1 + (N div 10), 
		setup_loop(N, Num_watchers)
	end. 


setup_loop(N, Num_watchers) -> 
	%%id value starts at 0
	manageSetup(N, 0, []). 

manageSetup(N, ID, List) -> 
	%%sensors can only haddle 10 watchers at a time 
	case length(List) == 10 of 
		true ->
			spawn(watcher, start2, [List]),
			manageSetup(N, ID, []);
		false -> 
			case N == 0 of 
			true -> 
				spawn(watcher, start2, [List]);	
			false -> 
				%%creates the id for the number of sensor that the user specifies 
				manageSetup(N - 1, ID + 1, lists:append(List, [ID]))
			end
		end.