if string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 then
    application = 
    {
        content =
        {
            width = 320,
            height = 568,
            scale = "letterBox",
            fps = 30,
            xAlign = "center",
            yAlign = "center"

            --[[
            imageSuffix = 
            {
                ["@2x"] = 2
            }
            --]]
        },
        --[[
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
        --]]
    }

else
    application = {
    	content = {
    		width = 320,
    		height = 480, 
    		scale = "letterBox",
    		fps = 30,
    		
    		--[[
            imageSuffix = {
    		    ["@2x"] = 2,
    		}
    		--]]
    	}
      

        --[[
        -- Push notifications

        notification =
        {
            iphone =
            {
                types =
                {
                    "badge", "sound", "alert", "newsstand"
                }
            }
        }
        --]]    
    }
end