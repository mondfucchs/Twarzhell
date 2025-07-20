    -- tools
local love = require("love")
local utls = require("tools.utils")
    -- logs
local enms = require("logs.enms")

    -- Instances Manager
local inst = {}

function inst.newSpace()

    local space = {
        -- Actual enemies, bosses and projectiles.
        objects = {},
        -- Not tangible structures that define the space's current behavior.
        managers = {}
    }

    -- Gets space's objects
    function space.getObjects(self)
        return self.objects
    end
    -- Sets space's objects to ```objects```
    function space.setObjects(self, objects)
        self.objects = utls.copyTable(objects)
    end

    -- Gets space's managers
    function space.getManagers(self)
        return self.managers
    end
    -- Sets space's managers
    function space.setManagers(self, managers)
        self.managers = utls.copyTable(managers)
    end


    function space.insertObject(self, enms_declaration)
        table.insert(self.objects, enms_declaration)
    end
    function space.removeObject(self, enms_declaration)
        local is_present, index = utls.searchTable(self.objects, enms_declaration)
        if is_present then
            table.remove(self.objects, index)
        end
    end


    function space.insertManager(self, enms_declaration)
        table.insert(self.managers, enms_declaration)
    end
    function space.removeManager(self, enms_declaration)
        local is_present, index = utls.searchTable(self.managers, enms_declaration)
        if is_present then
            table.remove(self.managers, index)
        end
    end


    function space.clear(self)
        self.objects = {}
        self.managers = {}
    end

    function space.update(self, behavior)
        for i, manager in pairs(self.managers) do
            if not manager:update(self) then
                table.remove(self.managers, i)
            end
        end

        for i, object in pairs(self.objects) do
            if not object:update(self) then
                table.remove(self.objects, i)
            end

            behavior(object, i)
        end
    end
    function space.draw(self)
        for _, object in pairs(self.objects) do
            object:draw()
        end
    end

    return space
end

return inst