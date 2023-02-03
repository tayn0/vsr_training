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
   pooltarget1,
   pooltarget2,
   pooltarget3,
   pooltarget,
   --Bools--
   enemyRecyclerIsAlive = false,
   RecyclerIsAlive = false,
   NotAroundBool = false,
   sc1_alive = false,
   bay_alive = false,
   sc1_healing = false,
   sc1_retreat = false,
   pod_up = false,
   sc1_attacking = false,
   enemyrec_deployed = false,
   pooltarget1_alive = false,
   pooltarget2_alive = false,
   pooltarget3_alive = false,
   loc_curr = 0,
   loc_prev = nil,
   loc_check_prev = 0,
   
   
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
	if IsOdf(h, "ivscout") and GetTeamNum(h) == 6 then
		Mission.sc1 = h
		SetSkill(Mission.sc1,3)
		SetIndependence(Mission.sc1, 1)
		Mission.sc1_healing = false
		Mission.sc1_attacking = false	
		Mission.sc1_alive = true
		PrintConsoleMessage("New sc1 built")
  elseif IsOdf(h, "ibsbay") and GetTeamNum(h) == 6 then
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
		
	elseif IsOdf(h, "ibscav") and GetTeamNum(h) == 1 and Mission.pooltarget1_alive == false then
		if Mission.pooltarget == nil then 
			Mission.pooltarget = h
			PrintConsoleMessage("pool target 1 assigned (addobj)")
		end
		Mission.pooltarget1 = h
		Mission.pooltarget1_alive = true
		PrintConsoleMessage("pooltarget1 ready")
	elseif IsOdf(h, "ibscav") and GetTeamNum(h) == 1 and Mission.pooltarget2_alive == false then
		Mission.pooltarget = h
		Mission.pooltarget2 = h
		Mission.pooltarget2_alive = true
		PrintConsoleMessage("pooltarget2 ready")
	elseif IsOdf(h, "ibscav") and GetTeamNum(h) == 1 and Mission.pooltarget3_alive == false then
		Mission.pooltarget = h
		Mission.pooltarget3 = h
		Mission.pooltarget3_alive = true
		PrintConsoleMessage("pooltarget3 ready")
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
		
		elseif IsOdf(h, "ibscav") then 
		
			if h == Mission.pooltarget1 then
				PrintConsoleMessage("pool target 1 destroyed")
				if IsAround(Mission.pooltarget2) then
					Mission.pooltarget = Mission.pooltarget2
					PrintConsoleMessage("pool target 2 assigned")
				elseif IsAround(Mission.pooltarget3) then
					Mission.pooltarget = Mission.pooltarget3
					PrintConsoleMessage("pool target 3 assigned")
				else
					Mission.pooltarget = nil
					PrintConsoleMessage("no pool target assigned")
				end
				Mission.pooltarget1_alive = false
				Mission.pooltarget1 = nil
				
			elseif h == Mission.pooltarget2 then
				PrintConsoleMessage("pool target 2 destroyed")
				if IsAround(Mission.pooltarget1) then
					Mission.pooltarget = Mission.pooltarget1
					PrintConsoleMessage("pool target 1 assigned")
				elseif IsAround(Mission.pooltarget3) then
					Mission.pooltarget = Mission.pooltarget3
					PrintConsoleMessage("pool target 3 assigned")
				else
					Mission.pooltarget = nil
					PrintConsoleMessage("no pool target assigned")
				end
				Mission.pooltarget2_alive = false
				Mission.pooltarget2 = nil
				
			elseif h == Mission.pooltarget3 then
				PrintConsoleMessage("pool target 3 destroyed")
				if IsAround(Mission.pooltarget1) then
					Mission.pooltarget = Mission.pooltarget1
					PrintConsoleMessage("pool target 1 assigned")
				elseif IsAround(Mission.pooltarget2) then
					Mission.pooltarget = Mission.pooltarget2
					PrintConsoleMessage("pool target 2 assigned")
				else
					Mission.pooltarget = nil
					PrintConsoleMessage("no pool target assigned")
				end
				Mission.pooltarget3_alive = false
				Mission.pooltarget3 = nil
				
				
			end
	  elseif h == Mission.sc1 then
		Mission.sc1 = nil
		Mission.sc1_alive = false
		PrintConsoleMessage("sc1 dead")
	  end
end

function InitialSetup()
	Mission.TPS = EnableHighTPS()
	AllowRandomTracks(true)
end

function Start() --This function is called upon the first frame

	Ally(1,1)
	Ally(6,6)
	UnAlly(1,6)

	SetAutoGroupUnits(false)
	Mission.Player = GetPlayerHandle()

	AddObjective(Mission.objectiveOne, "white", 5.0)

	SetAIP("vsr_train.aip", 6)
	
	--get player into vsr scout
	PlayerTeam = GetTeamNum(Mission.Player)
	xfrm = GetTransform(Mission.Player)
	RemoveObject(Mission.Player)
	Mission.Player = BuildObject("ivscout_vsr", PlayerTeam, xfrm)
	SetAsUser(Mission.Player, PlayerTeam)
	
	Mission.playersrecy = BuildObject("ivrecy", 1, "Recycler", 0)
	Mission.enemyrecy = BuildObject("ivrecy", 6, "RecyclerEnemy", 0)
	
	AddScrap(1, 40)
	AddScrap(6, 40)

end

function Update() --This function runs on every frame.
	Mission.TurnCounter = Mission.TurnCounter + 1

	missionCode() --Calling our missionCode function in Update.
end

function missionCode() --
	if Mission.enemyrec_deployed == false and (GetTime() > 5.0) then
		PrintConsoleMessage("Deploying Rec")
		Dropoff(Mission.enemyrecy, "RecyclerEnemy")
		Mission.enemyrec_deployed = true
	end
	
	
	if Mission.sc1_alive == true then
	
		--fail safe. if the scout is sitting still for 3 secs, reset
		if GetTime() > Mission.loc_check_prev + 3 then
			--PrintConsoleMessage("checking loc")
			PrintConsoleMessage("Pool target is")
			PrintConsoleMessage(tostring(Mission.pooltarget))

			if Mission.loc_prev ~= nil and GetDistance(Mission.sc1, Mission.loc_prev)  < 5 and (Mission.pooltarget  ~= nil and GetDistance(Mission.sc1, Mission.pooltarget) > 50) then
				Mission.sc1_attacking = false
				Mission.sc1_retreat = false
				Mission.sc1_healing = false
				PrintConsoleMessage("sc1 reset")
			end
	
			Mission.loc_check_prev = GetTime()
			Mission.loc_prev = GetTransform(Mission.sc1)
			--PrintConsoleMessage("Previous loc updated")

		end
		--if the pod gets stolen while the scout is going to collect it.
		if Mission.sc1_healing == true and Mission.pod_up == false then
			Mission.sc1_healing = false
			PrintConsoleMessage("pod reset")
		end	
		-- If the scout falls below 80% health or 5% ammo, it will attempt to heal with pods
		if (GetHealth(Mission.sc1) < 0.8 or GetAmmo(Mission.sc1) < 0.05) and Mission.sc1_healing == false then 		
			if  Mission.pod_up == true then
				SetIndependence(Mission.sc1, 0)
				Goto(Mission.sc1, Mission.pod)	
				PrintConsoleMessage("Healing initiated")
				Mission.sc1_attacking = false
				Mission.sc1_retreat = false
				Mission.sc1_healing = true		
			end	
			if Mission.pod_up == false and Mission.sc1_retreat == false then
				Mission.sc1_retreat = true
				SetIndependence(Mission.sc1, 0)
				Goto(Mission.sc1, Mission.enemyrecy)				
				PrintConsoleMessage("Retreat Initiated")
			end		
		end		
		if (GetHealth(Mission.sc1) >= 0.9 and GetAmmo(Mission.sc1) >= 0.9) and Mission.sc1_healing == true then
			SetIndependence(Mission.sc1,1)
			Mission.sc1_healing = false
			PrintConsoleMessage("healing ended")
		
		elseif Mission.sc1_healing == false and Mission.pooltarget ~= nil and Mission.sc1_attacking == false then
			SetIndependence(Mission.sc1,1)
			Attack(Mission.sc1, Mission.pooltarget, 1)
			Mission.sc1_attacking = true
			PrintConsoleMessage("Attacking pool")
			PrintConsoleMessage(tostring(Mission.pooltarget))
		end
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