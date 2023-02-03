--[[

VSR Training Module
HERP
]] --

local Mission = {
   --Integers--
   TPS = 0,
   MissionTimer = 0,
   TurnCounter = 0,
   PlayerTeam = 0,
   --Handles--
   playersrecy,
   enemyrecy,
   Player,
   sc1,
   sc2,
   sc3,
   bay,
   pod,

   --Bools--
   enemyRecyclerIsAlive = false,
   RecyclerIsAlive = false,
   NotAroundBool = false,
   
   
   objectiveOne = "Gain speed and jump off the cliff in front of you.",
   objectiveThree = "You are truly a hovering chad!",
   objectiveFour = "Try again land-lubbing virgin."

}

function Save()
   return Mission
end

function Load(...)
   if select("#", ...) > 0 then
      Mission = ...
   end
end

function AddObject(h) --This function is called when an object appears in the game. --

 	if IsOdf(h, "ibsbay") and GetTeamNum(h) == 6 then
		Mission.bay = h
		Mission.bay_alive = true
		PrintConsoleMessage("Enemy bay is built")
	elseif IsOdf(h, "apserv") and GetTeamNum(h) == 6 then
		Mission.pod = h
		Mission.pod_up = true
		PrintConsoleMessage("Enemy pod is built")
	elseif IsOdf(h, "ivrecy")  and GetTeamNum(h) == 6 then
		PrintConsoleMessage("Enemy rec recognized")
	elseif IsOdf(h, "ivrecy")  and  GetTeamNum(h) == 1 then
		Mission.RecyclerIsAlive = true

	--elseif IsOdf(h, "ispilo") and GetPlayerHandle == h then
		--Mission.Player = BuildObject("ivscout_vsr", PlayerTeam, "Player_1")
		--SetAsUser(Mission.Player, PlayerTeam)

	end
		
end

function DeleteObject(h) --This function is called when an object is deleted in the game.
	  if h == Mission.bay then
		Mission.bay_alive = false
		Mission.bay = nil
	  elseif h == Mission.pod then
		Mission.pod_up = false
		Mission.pod = nil
	  elseif h == Mission.enemyrecy then
		Mission.enemyRecyclerIsAlive = false
		Mission.enemyrecy = nil
	  elseif h == Mission.playersrecy then
		Mission.RecyclerIsAlive = false
		Mission.playersrecy = nil

	  end
		
end

function InitialSetup()
	Mission.TPS = EnableHighTPS()
	AllowRandomTracks(true)
end

function PlayerEjected(h)

	Mission.Player = BuildObject("ivscout_vsr", PlayerTeam, "Player_1")
	SetAsUser(Mission.Player, PlayerTeam)
	GiveWeapon(Mission.Player,"gchainvsr_c")
	GiveWeapon(Mission.Player,"gshadowvsr_c")
	GiveWeapon(Mission.Player,"gproxminvsr")

return 2

end

function Start() --This function is called upon the first frame

	Ally(1,1)
	Ally(6,6)
	UnAlly(1,6)

	SetAutoGroupUnits(false)
	Mission.Player = GetPlayerHandle()

	AddObjective(Mission.objectiveOne, "white", 5.0)

	SetAIP("vsr_train2.aip", 6)
	
	--get player into vsr scout
	PlayerTeam = GetTeamNum(Mission.Player)
	xfrm = GetTransform(Mission.Player)
	RemoveObject(Mission.Player)
	Mission.Player = BuildObject("ivscout_vsr", PlayerTeam, xfrm)
	SetAsUser(Mission.Player, PlayerTeam)
	GiveWeapon(Mission.Player,"gchainvsr_c")
	GiveWeapon(Mission.Player,"gshadowvsr_c")
	GiveWeapon(Mission.Player,"gproxminvsr")
	
	Mission.playersrecy = BuildObject("ivrecy_vsr", 1, "Recycler", 0)
	Mission.enemyrecy = BuildObject("ivrecy_vsr", 6, "RecyclerEnemy", 0)
	Mission.enemyrec_deployed = false
	
	AddScrap(1, 40)
	AddScrap(6, 40)

end



function Update() --This function runs on every frame.
	Mission.TurnCounter = Mission.TurnCounter + 1

	missionCode() --Calling our missionCode function in Update.
end

function missionCode() --

	if GetCurrentCommand(GetPlayerHandle()) == 50 then
		PrintConsoleMessage("Success")
	end

	Mission.Player = GetPlayerHandle()
	
	if Mission.enemyrec_deployed == false and (GetTime() > 5.0) then
		PrintConsoleMessage("Deploying Rec")
		Dropoff(Mission.enemyrecy, "RecyclerEnemy")
		Mission.enemyrec_deployed = true
	end
	
	
--[[ This condition checks the player has destroyed the enemy recycler and enables the win condition. ]] 
	if (Mission.enemyRecyclerIsAlive == true) and (Mission.NotAroundBool == false) and not IsAround(Mission.enemyrecy) then
  -- Destroyed Enemy Recycler.
	   ClearObjectives()
	   AddObjective(Mission.objectiveThree, "green", 15.0)
	   SucceedMission(GetTime() + 10.0, "passed.des" )
	   Mission.NotAroundBool = true
	end
	--[[ This condition checks the enemy has destroyed the player recycler and enables the fail condition.]] 
	if (Mission.RecyclerIsAlive == true) and (Mission.NotAroundBool == false) and not IsAround(Mission.playersrecy) then
  -- Destroyed Recycler.
	   ClearObjectives()
	   AddObjective(Mission.objectiveFour, "red", 15.0)
	   FailMission(GetTime() + 10.0, "failed.des")
	   Mission.NotAroundBool = true
	end
end