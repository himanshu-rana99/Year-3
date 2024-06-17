%%"I pledge my honor that I have abided by the Stevens Honor System" - Himanshu Rana - hrana2 

-module(sensor).
-compile(export_all).
-author("Himanshu Rana").

manageSensor(WatcherPID, SensorID) -> 
	Measurement = rand:uniform(11), 
	case Measurement == 11 of 
		%%if the measurement is 11 then the sensor dies/crashes 
		true -> exit("anamolous reading"); 
		%%otherwise it reports the random measurement with the id of the sensor
		false -> WatcherPID!{SensorID, Measurement}
	end, 
	Sleep_time = rand:uniform(10000), 
	timer:sleep(Sleep_time), 
	manageSensor(WatcherPID, SensorID). 