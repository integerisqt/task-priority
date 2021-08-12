local taskModule = {};
local taskMt = {};
taskMt.__index = taskMt;
local runService = game:GetService("RunService");

local function shiftTbl(tbl, from, to)
    local a, b = tbl[from], tbl[to];
    table.remove(tbl, from);
    table.insert(tbl, to, a);
end

function taskModule.new(type, stepLimit)
    local self = setmetatable({}, taskMt);
    self.connectType = runService[type];
    self.stepLimit = stepLimit;
    self.connections = {};
    return self;
end

function taskMt:addTask(name, priority, callback)
    table.insert(self.connections, priority or #self.connections, {
        name = name,
        callback = callback
    });
end

function taskMt:removeTask(name)
    --kinda slow but its not like you're going to call this function every second
    for i = 1, #self.connections do
        if self.connections[i].name == name then
            table.remove(self.connections, i);
            break;
        end
    end
end

function taskMt:changePriority(name, newpriority)
    for i = 1, #self.connections do
        if self.connections[i].name == name then
            shiftTbl(self.connections, i, newpriority);
            break;
        end
    end
end

function taskMt:fireConnections(dt)
    for i = 1, #self.connections do
        local f = self.connections[i];
        f.callback(dt);
    end
end

function taskMt:init()
    local c = 0;
    self.connection = self.connectType:Connect(function(dt)
        c = c + dt;
        if (self.stepLimit and (c >= 1 / self.stepLimit) or not self.stepLimit) then
            c = 0;
            self:fireConnections(dt);
        end
    end);
end

function taskMt:changeType(newType)
    self.connection:Disconnect();
    self.connectType = runService[newType];
    local c = 0;
    self.connection = self.connectType:Connect(function(dt)
        c = c + dt;
        if (self.stepLimit and (c >= 1 / self.stepLimit) or not self.stepLimit) then
            c = 0;
            self:fireConnections(dt);
        end
    end);
end

return taskModule;
