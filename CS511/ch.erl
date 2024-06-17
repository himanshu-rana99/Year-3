-module(ch). 
-compile(export_all).

chain(S,0) -> 
	S!self(), 
	receive
		ok -> 
			exit(oops)
	end; 

chain(S,N) when N>0 -> 
	spawn_link(?MODULE,chain,[S,N-1]),
	receive
		ok -> 
			exit(oopsie)
	end. 

start() -> 
	spawn_link(?MODULE,chain,[self(),5]).


%%monitoring and restarting 

critic() -> 
	receive
		{From, {"Rage Against the Turing Machine", "Unit Testify"}} -> 
			From!{self(),"They are great"};
		{From, {"System of a Downtinme", "Memoize"}} -> 
			From!{self(),"They not are Johnny Crash but they are good"};
		{From, {"Johnny Crash", "The Token Ring of Fire"}} -> 
			From!{self(),"Simply incredible"};
		{From, {_Band, _Album}} -> 
			From!{self(),"They are terrible"}
		end, 
		critic(). 

restarter() -> 
	process_flag(trap_exit,true), 
	C=spawn_link(?MODULE,critic,[]), 
	register(critic,C), 
	receive
		{'Exit',PID,normal} -> 
		ok; 
		{'Exit',PID,shutdown} -> 
		ok; 
		{'Exit',PID,Reason} -> 
		restarter()
	end.

judge(Band,Album) -> 
	critic!{self(),{Band,Album}},
	S = whereis(critic),
	receive
		{S,Criticism} -> 
			Criticism
	end.

startc() -> 
	 
