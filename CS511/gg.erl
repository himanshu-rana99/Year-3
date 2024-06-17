-module(gg). 
-complile(export_all). 

server() -> 
	receive
		{From,Ref,start} -> 
			S=spawn(?MODULE,servlet,[From,rand:uniform(20)]),
			From!{self(),Ref,S},
			server()
	end.

		
client(S) -> 
	R = make_ref(),
	S!{self(),R,start}, 
	receive
		{S,R,Servlet} -> 
			client_loop(Servlet,C)
	end.

client_loop(Servlet,C) -> 
	R = make_ref(), 
	Servlet!{self(),R,guess,rand:uniform(20)},
	receive
		{Servlet,R,gotIt} -> 
			io:format("Client ~p guessing in ~w tries~n",[self(),C]);
		{Servlet,R,tryAgain} -> 
			client_loop(Servlet,C+1)
	end.

servlet(Cl,Number) -> 
	receive
		{Cl,Ref,guess,N} when N==Number -> 
			Cl!{self(),Ref,gotIt}; 
		{Cl,Ref,guess,N} -> 
			Cl!{self(),Ref,tryAgain},
			servlet(Cl,Number)
	end.



start() -> 
	spawn(fun server/0). 
