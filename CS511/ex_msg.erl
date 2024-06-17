-module(ex_msg).
-compile(export_all).


echo() -> 
	receive
		{echo,From,Msg} -> 
			From!{Msg}, 
			echo(); 
		{stop} -> 
			ok
	end. 