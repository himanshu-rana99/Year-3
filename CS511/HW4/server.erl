%%"I pledge my honor that I have abided by the Stevens Honor System" - Himanshu Rana - hrana2 

-module(server).

-export([start_server/0]).

-include_lib("./defs.hrl").

-spec start_server() -> _.
-spec loop(_State) -> _.
-spec do_join(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_leave(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_new_nick(_State, _Ref, _ClientPID, _NewNick) -> _.
-spec do_client_quit(_State, _Ref, _ClientPID) -> _NewState.

start_server() ->
    catch(unregister(server)),
    register(server, self()),
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{server_up, self()}
    end,
    loop(
      #serv_st{
	 nicks = maps:new(), %% nickname map. client_pid => "nickname"
	 registrations = maps:new(), %% registration map. "chat_name" => [client_pids]
	 chatrooms = maps:new() %% chatroom map. "chat_name" => chat_pid
	}
     ).

loop(State) ->
    receive 
	%% initial connection
	{ClientPID, connect, ClientNick} ->
	    NewState =
		#serv_st{
		   nicks = maps:put(ClientPID, ClientNick, State#serv_st.nicks),
		   registrations = State#serv_st.registrations,
		   chatrooms = State#serv_st.chatrooms
		  },
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, join, ChatName} ->
	    NewState = do_join(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, leave, ChatName} ->
	    NewState = do_leave(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to register a new nickname
	{ClientPID, Ref, nick, NewNick} ->
	    NewState = do_new_nick(State, Ref, ClientPID, NewNick),
	    loop(NewState);
	%% client requests to quit
	{ClientPID, Ref, quit} ->
	    NewState = do_client_quit(State, Ref, ClientPID),
	    loop(NewState);
	{TEST_PID, get_state} ->
	    TEST_PID!{get_state, State},
	    loop(State)
    end.

%% executes join protocol from server perspective
do_join(ChatName, ClientPID, Ref, State) ->
	%% If the chatroom does not exist, create it
	ChatRooms = State#serv_st.chatrooms,
	Registrations = State#serv_st.registrations,
	case maps:is_key(ChatName, ChatRooms) of
		true ->
			ChatRoomPID = maps:get(ChatName, ChatRooms),
			NewChatRooms = ChatRooms,
			NewRegistration = maps:update(ChatName, lists:append([ClientPID], maps:get(ChatName, Registrations)), Registrations);

		false ->
			ChatRoomPID = spawn(chatroom, start_chatroom, [ChatName]),
			NewChatRooms = maps:put(ChatName, ChatRoomPID, ChatRooms),
			NewRegistration = maps:put(ChatName, [ClientPID], Registrations)
	end,
	
	ClientNick = maps:get(ClientPID, State#serv_st.nicks),

	%% Send register request to chatroom
	ChatRoomPID!{self(), Ref, register, ClientPID, ClientNick},

	%% return new state
	#serv_st{
	 nicks = State#serv_st.nicks, %% nickname map. client_pid => "nickname"
	 registrations = NewRegistration, %% registration map. "chat_name" => [client_pids]
	 chatrooms = NewChatRooms %% chatroom map. "chat_name" => chat_pid
	}.

%% executes leave protocol from server perspective
do_leave(ChatName, ClientPID, Ref, State) ->
    ChatroomPID = maps:get(ChatName, State#serv_st.chatrooms),
	Registrations = State#serv_st.registrations,
	ChatroomClientsPIDs = maps:get(ChatName, State#serv_st.registrations),
	NewRegistrations = maps:update(ChatName, ChatroomClientsPIDs -- [ClientPID], Registrations),
	ChatroomPID!{self(), Ref, unregister, ClientPID},
	ClientPID!{self(), Ref, ack_leave},
	#serv_st{
		nicks = State#serv_st.nicks,
		registrations = NewRegistrations,
		chatrooms = State#serv_st.chatrooms
	}.
%% -record(serv_st, {nicks, registrations, chatrooms}).
%%registrations: a map from a chatroom’s name (string) as the key to a list of the client processes’ PIDs of clients registered in that chatroom.
%%chatrooms: a map from a chatroom’s name (string) as the key to the chatroom’s corresponding PID as the value.
%% executes new nickname protocol from server perspective
%% breaking when trying to change the nickname the second time
do_new_nick(State, Ref, ClientPID, NewNick) ->
    Nicknames = maps:values(State#serv_st.nicks),
    io:format("Nicknames: ~p~nNewNick: ~p~n",[Nicknames, NewNick]),
    case lists:member(NewNick, Nicknames) of
	true ->
	    io:format("Nickname: ~p~n", [NewNick]),
	    ClientPID!{self(), Ref, err_nick_used},
	    State;
	false ->
	    
	    ChatNames = maps:filter(fun(_Nm, Clients) ->
					    lists:member(ClientPID, Clients)
				    end,
				    State#serv_st.registrations),
	    io:format("Chat Names to send updatenick to: ~p~n", [maps:keys(ChatNames)]),
	    ChatPIDs = maps:filter(fun(Nm, _PID) -> 
					   lists:member(Nm, maps:keys(ChatNames))
				   end, State#serv_st.chatrooms),
	    io:format("Chat PIDS: ~p~n", [maps:values(ChatPIDs)]),
	    Catch = maps:map(fun(_,Chat_PID) ->
				     io:format("Chat PID TO sEND TO: ~p~n", [Chat_PID]),
				     Chat_PID!{self(), Ref, update_nick, ClientPID, NewNick},
				     Chat_PID
			     end, ChatPIDs),
	    NewNicks = maps:update(ClientPID, NewNick, State#serv_st.nicks),
	    ClientPID!{self(), Ref, ok_nick},
	    io:format("NewNicks = ~p~n", [NewNicks]),
	    #serv_st{
	       nicks = NewNicks, 
	       registrations = State#serv_st.registrations,
	       chatrooms = State#serv_st.chatrooms
	      }
    end.

%% executes client quit protocol from server perspective
do_client_quit(State, Ref, ClientPID) ->
    
    ChatNames = maps:filter(fun(_Nm, Clients) ->
				    lists:member(ClientPID, Clients)
			    end,
			    State#serv_st.registrations),
    io:format("Chat Names to send updatenick to: ~p~n", [maps:keys(ChatNames)]),
    ChatPIDs = maps:filter(fun(Nm, _PID) -> 
				   lists:member(Nm, maps:keys(ChatNames))
			   end, State#serv_st.chatrooms),
    io:format("Chat PIDS: ~p~n", [maps:values(ChatPIDs)]),
    Catch = maps:map(fun(_,Chat_PID) ->
			     io:format("Chat PID TO SEND TO: ~p~n", [Chat_PID]),
			     Chat_PID!{self(), Ref, upregister, ClientPID},
			     Chat_PID
		     end, ChatPIDs),
    UpdatedRegistrations = maps:map(fun(_Nm, Clients) ->
					    case lists:member(ClientPID, Clients) of
						true ->
						    lists:delete(ClientPID, Clients);
						false ->
						    Clients
					    end
				    end, State#serv_st.registrations),
    
    ClientPID!{self(), Ref, ack_quit},
    #serv_st{
       nicks = maps:remove(ClientPID,State#serv_st.nicks), 
       registrations = UpdatedRegistrations,
       chatrooms = State#serv_st.chatrooms
      }.