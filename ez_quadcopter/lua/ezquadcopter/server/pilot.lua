local dragRatio = 0.97

function easzy.quadcopter.StabilizeQuadcopter(quadcopter)
	local phys = quadcopter:GetPhysicsObject()
	if IsValid(phys) then

		local velocity = phys:GetVelocity()
		local velocityLenght = velocity:Length()

		local angleVelocity = phys:GetAngleVelocity()
		local angleVelocityLenght = angleVelocity:Length()

		phys:SetAngleVelocity(angleVelocity * dragRatio)

        -- Angle when going forward or backward
        local x = math.Remap(velocityLenght, 40, 200, 0, 10)
        x = phys:WorldToLocalVector(velocity).x > 0 and x or -x

		local angles = phys:GetAngles()
		phys:SetAngles(LerpAngle(velocityLenght/2000, angles, Angle(x, angles.y, 0)))

        x = math.abs(x) > 10 and x or 0

        velocity.z = velocity.z + math.abs(x/4)
        if easzy.quadcopter.config.counterGravity then
            velocity.z = velocity.z + easzy.quadcopter.config.counterGravityValue
        end
		phys:SetVelocity(velocity * dragRatio)
	end
end

function easzy.quadcopter.MoveQuadcopter(quadcopter, vector)
	local phys = quadcopter:GetPhysicsObject()
	if IsValid(phys) then
		phys:AddVelocity(vector)
	end
end

function easzy.quadcopter.RotateQuadcopter(quadcopter, vector)
	local phys = quadcopter:GetPhysicsObject()
	if IsValid(phys) then
		phys:AddAngleVelocity(vector)
	end
end

local function ResetMoveType(ply)
    if ply.moveType then
        ply:SetMoveType(ply.moveType)
        ply.moveType = nil
    end
end

local function FreezeMoveType(ply)
    if not ply.moveType then
        ply.moveType = ply:GetMoveType()
        ply:SetMoveType(MOVETYPE_FLYGRAVITY)
    end
end

hook.Add("StartCommand", "ezquadcopter_pilot_StartCommand", function(ply, cmd)
    local up = Vector(0, 0, 0)
    local forward = Vector(0, 0, 0)
    local rotation = Vector(0, 0, 0)

    if not easzy.quadcopter.IsHoldingRadioController(ply) then ResetMoveType(ply) return end

    local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
    if not IsValid(quadcopter) or not quadcopter.on then ResetMoveType(ply) return end

    local quadcopterClass = quadcopter:GetClass()

    -- Speed
    local speedLevel = quadcopter.upgrades["Speed"]
    local speed = easzy.quadcopter.quadcoptersData[quadcopterClass].upgrades["Speed"].levels[speedLevel]

    -- Distance
    local distanceLevel = quadcopter.upgrades["Distance"]
    local maxDistance = easzy.quadcopter.quadcoptersData[quadcopterClass].upgrades["Distance"].levels[distanceLevel]

    local quadcopterPos = quadcopter:GetPos()
    local playerPos = ply:GetPos()
    local distance = quadcopterPos:DistToSqr(playerPos)
    if distance > maxDistance then
        easzy.quadcopter.MoveQuadcopter(quadcopter, (playerPos - quadcopterPos):GetNormalized() * 10 * speed)
    else
        local radioController = easzy.quadcopter.GetRadioController(quadcopter)

        if cmd:KeyDown(IN_JUMP) then
            easzy.quadcopter.AnimViewModel(ply, "top", 1)

            up = up + Vector(0, 0, 10 * speed)

            radioController.idleVertical = CurTime()

        elseif cmd:KeyDown(IN_DUCK) then
            easzy.quadcopter.AnimViewModel(ply, "bottom", 1)

            up = up + Vector(0, 0, -10 * speed)

            radioController.idleVertical = CurTime()

        elseif ((CurTime() - radioController.idleVertical) > 0.5) and not ((CurTime() - radioController.idleHorizontal) < 0.5) then
            easzy.quadcopter.AnimViewModel(ply, "idle", 1)
        end

        if cmd:KeyDown(IN_FORWARD) then
            easzy.quadcopter.AnimViewModel(ply, "forward", 1)

            local temp = Vector(15 * speed, 0, 0)
            temp:Rotate(quadcopter:GetAngles())

            forward = forward + temp

            radioController.idleHorizontal = CurTime()

        elseif cmd:KeyDown(IN_BACK) then
            easzy.quadcopter.AnimViewModel(ply, "backward", 1)

            local temp = Vector(-15 * speed, 0, 0)
            temp:Rotate(quadcopter:GetAngles())

            forward = forward + temp

            radioController.idleHorizontal = CurTime()

        elseif ((CurTime() - radioController.idleHorizontal) > 0.5) and not ((CurTime() - radioController.idleVertical) < 0.5) then
            easzy.quadcopter.AnimViewModel(ply, "idle", 1)
        end

        if cmd:KeyDown(IN_MOVELEFT) then
            easzy.quadcopter.AnimViewModel(ply, "left", 1)

            rotation = rotation + Vector(0, 0, 10)

            radioController.idleHorizontal = CurTime()

        elseif cmd:KeyDown(IN_MOVERIGHT) then
            easzy.quadcopter.AnimViewModel(ply, "right", 1)

            rotation = rotation + Vector(0, 0, -10)

            radioController.idleHorizontal = CurTime()

        elseif ((CurTime() - radioController.idleHorizontal) > 0.5) and not ((CurTime() - radioController.idleVertical) < 0.5) then
            easzy.quadcopter.AnimViewModel(ply, "idle", 1)
        end

        easzy.quadcopter.MoveQuadcopter(quadcopter, up)
        easzy.quadcopter.MoveQuadcopter(quadcopter, forward)
        easzy.quadcopter.RotateQuadcopter(quadcopter, rotation)
    end

    FreezeMoveType(ply)

	-- Clear any default movement
	cmd:ClearMovement()
    cmd:RemoveKey(IN_DUCK)
    cmd:RemoveKey(IN_JUMP)
end)

hook.Add("CanPlayerEnterVehicle", "ezquadcopter_CanPlayerEnterVehicle", function(ply, veh, role)
    if not easzy.quadcopter.IsHoldingRadioController(ply) then return end

    local quadcopter = easzy.quadcopter.GetQuadcopter(ply)
    if not IsValid(quadcopter) then return end

    if quadcopter.on then
        return false
    end
end)
