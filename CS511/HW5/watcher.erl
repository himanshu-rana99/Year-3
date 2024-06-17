%%"I pledge my honor that I have abided by the Stevens Honor System" - Himanshu Rana - hrana2 

-module(watcher).
-compile(export_all).
-author("Himanshu Rana").


%%creates an empty list so that a new watcher can be made 
start2(List) -> 
	startProcess(List, []). 


startProcess(List, SensorTuple) -> 
	case length(List) == 0 of 
		true -> 
			io:fwrite("Watcher #~p starting - ~p~n", [self() ,SensorTuple]),
			watcher(SensorTuple); 
		%%adds a new sensor to the end of the list when the list is not empty 
		false -> 
			[H | T] = List, 
			{SensorPid, _} = spawn_monitor(sensor, manageSensor, [self(), H]), 
			startProcess(T, lists:append(SensorTuple, [{H, SensorPid}]))
		end. 


watcher(SensorTuple) -> 
	receive
		%%writes the measurement of the sensor 
		{SensorPid, Measurement} -> 
			io:fwrite("Sensor ~4p measurement number: ~2p~n", [SensorPid, Measurement]), 
			watcher(SensorTuple);
		%%case for when a sensor dies, prints the sensor that died by locating it 
		%%in the list
		{'DOWN', _, process, Pid, Reason} -> 
			{SensorID, _} = lists:keyfind(Pid, 2, SensorTuple), 
			io:fwrite("Sensor ~4p died: ~2p~n", [SensorID, Reason]), 
			%%calls the restart function because a sensor has died 
			%%deletes the dead sensor from the list 
			restart(lists:delete({SensorID, Pid}, SensorTuple), SensorID)
		end. 

restart(SensorTuple, SensorID) -> 
	%%spawns a new sensor and adds it to the new list and prints that list out
	{NewPid, _} = spawn_monitor(sensor, manageSensor, [self(), SensorID]),
	io:fwrite("Sensor ~p new sensor list: ~w~n", [self(), lists:append(SensorTuple, [{SensorID, NewPid}])]),
	watcher(lists:append(SensorTuple, [{SensorID, NewPid}])).
