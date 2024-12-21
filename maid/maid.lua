local maid = {}
maid.class_name = "maid"

function maid.new()
    return setmetatable({
        tasks = {}
    }, maid)
end

function maid.is_maid(value)
    return type(value) == "table" and value.class_name == "maid"
end

function maid.__index(self, index)
    if maid[index] then
        return maid[index]
    else
        return self.tasks[index]
    end
end

function maid:__newindex(index, new_task)
    if maid[index] ~= nil then
        error(("%s is reserved"):format(tostring(index)), 2)
    end

    local tasks = self.tasks
    local old_task = tasks[index]

    if old_task == new_task then
        return
    end

    tasks[index] = new_task

    if old_task then
        if type(old_task) == "function" then
            old_task()
        elseif typeof(old_task) == "RBXScriptConnection" then
            old_task:Disconnect()
        elseif typeof(old_task) == "table" then
            old_task:Remove()
        elseif typeof(old_task) == "RBXScriptSignal" then
            old_task:Destroy()
        elseif typeof(old_task) == "thread" then
            task.cancel(old_task)
        elseif old_task.Destroy then
            old_task:Destroy()
        end
    end
end

function maid:give_task(task)
    if not task then
        error("Task cannot be false or nil", 2)
    end

    local task_id = #self.tasks + 1
    self[task_id] = task

    return task_id
end

function maid:do_cleaning()
    local tasks = self.tasks

    for index, task in pairs(tasks) do
        if typeof(task) == "RBXScriptConnection" then
            tasks[index] = nil
            task:Disconnect()
        end
    end

    local index, task_data = next(tasks)
  
    while task_data ~= nil do
        tasks[index] = nil
    
        if type(task_data) == "function" then
            task_data()
        elseif typeof(task_data) == "RBXScriptConnection" then
            task_data:Disconnect()
        elseif typeof(task_data) == "RBXScriptSignal" then
            task_data:Destroy()
        elseif typeof(task_data) == "table" then
            task_data:Remove()
        elseif typeof(task_data) == "thread" then
            task.cancel(task_data)
        elseif task_data.Destroy then
            task_data:Destroy()
        end

        index, task_data = next(tasks)
    end
end

maid.destroy = maid.do_cleaning

return maid
