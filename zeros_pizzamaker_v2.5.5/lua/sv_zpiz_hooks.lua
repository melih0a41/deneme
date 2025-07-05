/*
    Addon id: e226f4ba-3ec8-468a-b615-dd31f974c7f7
    Version: v2.5.5 (stable)
*/

if not SERVER then return end

// Here are some Hooks you can use for Custom Code

// Called when the player sells a Pizza
hook.Add("zpiz_OnPizzaSold", "zpiz_OnPizzaSold_Test", function(ply, earning, pizzaID, isburned)
    /*
    if IsValid(ply) then
        print("-----------")
        print(ply)
        print(earning)
        print(pizzaID)
        print(isburned)
        print("-----------")
    end
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

// Called when a pizza got finished baking in the oven
hook.Add("zpiz_OnPizzaReady", "zpiz_OnPizzaReady_Test", function(pizza, pizzaowner, pizzaID, oven)
    /*
    print("-----------")
    print(pizza)
    print(pizzaowner)
    print(pizzaID)
    print(oven)
    print("-----------")
    */
end)

// Called when a pizza gets burned
hook.Add("zpiz_OnPizzaBurned", "zpiz_OnPizzaBurned_Test", function(pizza, pizzaowner, pizzaID)
    /*
    print("-----------")
    print(pizza)
    print(pizzaowner)
    print(pizzaID)
    print("-----------")
    */
end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ca6c4d6788a5e6ce8b060dd3878a973a3417d38eeec5dc462d2211d26c464eac

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198872838622

// Called when a player eats a Oizza
hook.Add("zpiz_OnPizzaEaten", "zpiz_OnPizzaEaten_Test", function(ply, pizzaID)
    /*
    print("-----------")
    print(ply)
    print(pizzaID)
    print("-----------")
    */
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 24531034901c50a2b71731a6d8b2473d06829ad0d164a0ad65656852f5fe8e47
