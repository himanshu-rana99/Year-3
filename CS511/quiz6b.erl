-module(quiz6b).
-compile(export_all).

dryCleaner(Clean, Dirty) -> 
	receive
		{dropOffOverall} -> 
			dryCleaner(Clean, Dirty+`1);
		{From, Ref, dryCleanItem} when Dirty>0 -> 
			From!{slef(),Ref,ok}, 
			dryCleaner(Clean+1,Dirty-1); 
		{From, Ref,pickupOverall} when Clean>0 -> 
			From!{self(),Ref,ok}, 
			dryCleaner(Clean-1,Dirty)
		%%calls recursively clean++, dirty-- 
	end.


employee(DC) -> 
	DC!{dropOffOverall}, 
	R = make_ref(), 
	DC!{self(),R,pickupOverall]},
	receive 
		{DC,R, ok} -> 
			done
	end. 

dryCleanMachine(DC) -> 
	R = make_ref(), 
	DC!{self(),R,dryCleanItem},
	receive
		{DC,R,ok} -> 
			timer:sleep(1000), 
			dryCleanMachine(DC)
	end. 



start(E, M) -> 
	DC = spwan(?MODULE,dryCleaner,[0,0]),
	[spawn(?MODULE,employee,[DC]) || _ <- lists:seq(1,E)],
	[spawn(?MODULE,dryCleanMachine,[DC]) || _ <- lists:seq(1,M)].