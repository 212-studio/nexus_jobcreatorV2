ESX = exports.es_extended:getSharedObject()
local json = require("json")


lib.callback.register('jobcreator:getjobs', function(source)
    local response = MySQL.Sync.fetchAll('SELECT * FROM jobs')
    return response
end)

lib.callback.register('jobcreator:getjson', function(source)
    local jobs = LoadResourceFile(GetCurrentResourceName(), 'jobs.json')
    local decoded = json.decode(jobs)
    return decoded
end)

CreateThread(function()
    local jobs = LoadResourceFile(GetCurrentResourceName(), 'jobs.json')
    local decoded = json.decode(jobs)
    for k,v in pairs(decoded) do 
        for a,b in pairs(v.depositi) do 
            exports.ox_inventory:RegisterStash(v.name..a,b.name, tonumber(b.slots), b.peso*1000, false)
        end
    end
end)

RegisterServerEvent('jobcreator:azioni', function(azione, data)
    local diocane = GetPlayerName(source)
    local jobs = LoadResourceFile(GetCurrentResourceName(), 'jobs.json')
    local decoded = json.decode(jobs)
    if azione == 'creadeposito' then
        for b,c in pairs(data) do
            for k,v in pairs(data.depositi) do
                exports.ox_inventory:RegisterStash(data.name..k,v.name, tonumber(v.slots), v.peso*1000, false)
            end
            for i, jobData in ipairs(decoded) do
                if jobData.name == data.name then
                    decoded[i] = data
                    break
                end
            end
            SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
            TriggerClientEvent('registerMarkers', -1)
        end
    elseif azione == 'creabossmenu' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'creacamerino' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'creablip' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'creagarage' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'punto1' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'punto2' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'addveh' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('registerMarkers', -1)
    elseif azione == 'addgrade' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = data
                break
            end
        end
        for k, v in pairs(data.grades) do 
            MySQL.prepare('DELETE FROM job_grades WHERE job_name = ? AND grade = ?', {data.name, v.numgrado})
        end        
        for k, v in pairs(data.grades) do 
            MySQL.prepare('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (?, ?, ?, ?, ?)', {data.name, v.numgrado, v.name, v.label, v.salary})
        end
        Wait(500)
        ESX.RefreshJobs()
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
    elseif azione == 'delete' then 
        for i, jobData in ipairs(decoded) do
            if jobData.name == data.name then
                decoded[i] = nil
                break
            end
        end
        MySQL.prepare('DELETE FROM job_grades WHERE job_name = ?', { data.name })
        MySQL.prepare('DELETE FROM jobs WHERE name = ?', { data.name })
        Wait(500)
        ESX.RefreshJobs()
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        TriggerClientEvent('DeleteFaz', -1, data.name)
    elseif azione == 'creafazione' then 
        table.insert(decoded, data)
        MySQL.insert('INSERT IGNORE INTO jobs (name, label) VALUES (?, ?)', { data.name, data.label })
        for k, v in pairs(data.grades) do 
            MySQL.prepare('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (?, ?, ?, ?, ?)', {data.name, v.numgrado, v.name, v.label, v.salary})
        end
        Wait(500)
        ESX.RefreshJobs()
        SaveResourceFile(GetCurrentResourceName(), "jobs.json", json.encode(decoded, { indent = true }), -1)
        -- LOG CREAFAZIONE
        local embedData = {{["title"] = 'JOB CREATOR',["color"] = '14423100',["footer"] = {["text"] = "| Nexus Logs | " .. os.date(),["icon_url"] = "https://i.ibb.co/WpgYZQ2z/png.png",},},}
        PerformHttpRequest('https://discord.com/api/webhooks/1324819443745816690/_WBhE78MShSxJPGtE7Djp3rPeQpAuQzYwkw5CqJcfcw5UNKaZ3s6wD1MclVItDx-9Y_A',nil,"POST",json.encode({username = "Logs",embeds = embedData,}),{["Content-Type"] = "application/json",})
    end
end)

RegisterServerEvent('creajob', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in pairs(Config.Staffs) do
        if xPlayer.group == v then
            TriggerClientEvent('creajob', source)
        end
    end
end)
