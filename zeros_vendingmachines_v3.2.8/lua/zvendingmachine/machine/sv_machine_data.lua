/*
    Addon id: 0758ce15-60f0-4ef0-95b1-26cf6d4a4ac6
    Version: v3.2.8 (stable)
*/

if CLIENT then return end
zvm = zvm or {}
zvm.Machine = zvm.Machine or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198307194380

/*

	Those net messages get called to Request/Send Data

*/
util.AddNetworkString("zvm_Machine_Data_Request")
util.AddNetworkString("zvm_Machine_Data_Send")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1dcbe51a27c12593bf1156247b19414c1f993da7a79309cb21f9962a29ae0978
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 1fdc9c86cca443b8984aa3d314fab30e9a9c9805278b0ac1ed60a219ed559dfa
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

// Called when a player requests machine data
net.Receive("zvm_Machine_Data_Request", function(len,ply)
	zclib.Debug("zvm_Machine_Data_Request Netlen: " .. len)

	if zclib.Player.Timeout(nil,ply) then return end

	local machine = net.ReadEntity()

	zclib.Debug("zvm_Machine_Data_Request, Entity: " .. machine:EntIndex())
	if IsValid(machine) and machine:GetClass() == "zvm_machine" and zclib.util.InDistance(ply:GetPos(), machine:GetPos(), 500) then
		zvm.Machine.UpdateMachineData(machine,ply)
	end
end)

/*

	Called when the machine got edited and sends the new product list to all players

*/
function zvm.Machine.UpdateMachineData(Machine,ply)
	zclib.Debug("zvm.Machine.UpdateMachineData")

	// We dont need to send the entdata
	local products = table.Copy(Machine.Products) or {}
	for k,v in pairs(products) do
		v.entdata = nil
	end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 705936fcff631091636b99436d9ae6d4b3890a53e3536603fbc30ad118b26ecc

	local data = {
		products = products,
		name = Machine.MachineName,
		moneytype = Machine.MoneyType
	}


	data =  util.TableToJSON(data)
	local dataCompressed = util.Compress(data)

	net.Start("zvm_Machine_Data_Send")
	net.WriteEntity(Machine)
	net.WriteUInt(#dataCompressed, 16)
	net.WriteData(dataCompressed, #dataCompressed)

	if IsValid(ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end
