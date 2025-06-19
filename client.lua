ESX = exports.es_extended:getSharedObject()
local jsonn = require("json")

RegisterNetEvent('creajob', function()
    MenuCreatejob()
end)

RegisterCommand(Config.Comando, function()
    TriggerServerEvent('creajob')
end)
RegisterKeyMapping(Config.Comando, 'Apri CreaJob', 'keyboard', Config.Tasto)

function MenuCreatejob()
    local callback = lib.callback.await('jobcreator:getjobs')
    local jobs = {}

    for k, v in pairs(callback) do 
        table.insert(jobs, {label = v.label, icon = 'fa-solid fa-users', args = {action = 'jobmenu', name = v.name}})
    end

    table.insert(jobs, {label = 'CREA JOB', icon = 'fa-solid fa-plus', args = {action = 'createjob'}})

    lib.registerMenu({
        id = 'createjob',
        title = 'JOB CREATOR - LISTA',
        position = 'top-right',
        options = jobs
    }, function(selected, scrollIndex, args)
        if args.action == 'createjob' then
            CreateJob()
        else
            JobMenu(args.name)
        end
    end)

    lib.showMenu('createjob')
end

local tabella = {
    name = nil,
    label = nil,
    bossmenu = {},
    depositi = {},
    camerino = {},
    garage = {},
    blips = {},
    grades = {}
}
function CreateJob()
    lib.registerMenu({
        id = 'jobmenu',
        title = 'JOB CREATOR - CREATION',
        position = 'top-right',
        onClose = function(keyPressed)
            MenuCreatejob()
        end,
        options = {
            {label = 'NOME: ' .. (tabella.name or ''), description = 'Nome nel /setjob', args = {action = 'name'}, icon = 'fa-solid fa-user'},
            {label = 'LABEL: ' .. (tabella.label or ''), description = 'Nome visualizzato dal player', args = {action = 'label'}, icon = 'fa-solid fa-user'},
            {label = 'GRADI: ' .. #tabella.grades, description = 'Gradi del lavoro', args = {action = 'grades'}, icon = 'fa-solid fa-user'},
            {label = 'CONFERMA', description = 'Conferma e crea il lavoro', args = {action = 'creafazione'}, icon = 'fa-solid fa-user'}
        }
    }, function(selected, scrollIndex, args)
        if args.action == 'name' then
            local input = lib.inputDialog('NOME LAVORO', {
                {type = 'input', label = 'NOME', description = 'Nome del JOB nel /setjob'}
            })
            if input then
                tabella.name = input[1]
            end
            CreateJob()
        elseif args.action == 'label' then
            local input = lib.inputDialog('JOB LABEL', {
                {type = 'input', label = 'LABEL', description = 'Label del JOB nel /setjob'}
            })
            if input then
                tabella.label = input[1]
            end
            CreateJob()
        elseif args.action == 'grades' then
            GradesMenu()
        elseif args.action == 'creafazione' then
            TriggerServerEvent('jobcreator:azioni', 'creafazione', tabella)
            tabella = {name = nil, label = nil, bossmenu = {}, depositi = {}, camerino = {}, garage = {}, blips = {}, grades = {}}
        end
    end)
    lib.showMenu('jobmenu')
end

function GradesMenu()
    local gradi = tabella.grades
    local menugradi = {}

    for k, v in pairs(gradi) do
        table.insert(menugradi, {label = v.label .. ' - (' .. v.numgrado .. ')', icon = 'fa-solid fa-box', args = {numgrado = v.numgrado}})
    end
    table.insert(menugradi, {label = 'CREA GRADO', icon = 'fa-solid fa-plus', args = {action = 'creagradi'}})

    lib.registerMenu({
        id = 'menugradi',
        title = 'JOB CREATOR - GRADI',
        position = 'top-right',
        onClose = function(keyPressed)
            CreateJob()
        end,
        options = menugradi
    }, function(selected, scrollIndex, args)
        if args.action == 'creagradi' then
            local input = lib.inputDialog('CREA GRADO', {
                {type = 'number', label = 'NUM GRADO', default = #tabella.grades, description = 'Numero del grado nel /setjob'},
                {type = 'input', label = 'NOME GRADO', default = 'grade' .. #tabella.grades, description = 'Nome del grado'},
                {type = 'input', label = 'LABEL GRADO', default = 'Grado ' .. #tabella.grades, description = 'Label del grado'},
                {type = 'number', label = 'STIPENDIO', default = 100, description = 'Stipendio che riceverà il grado'}
            })
            if input then
                table.insert(tabella.grades, {
                    numgrado = input[1],
                    name = input[2],
                    label = input[3],
                    salary = input[4]
                })
                GradesMenu()
            end
        end
    end)
    lib.showMenu('menugradi')
end

function JobMenu(job)
    local json = lib.callback.await('jobcreator:getjson')
    for k, data in pairs(json) do
        if job == data.name then
            local elements = {
                {label = 'BOSSMENU - ('..#data.bossmenu..')', icon = 'fa-solid fa-user', args = {action = 'bossmenu'}},
                {label = 'DEPOSITI - ('..#data.depositi..')', icon = 'fa-solid fa-box', args = {action = 'depositi'}},
                {label = 'CAMERINI - ('..#data.camerino..')', icon = 'fa-solid fa-shirt', args = {action = 'camerino'}},
                {label = 'BLIPS - ('..#data.blips..')', icon = 'fa-solid fa-map-pin', args = {action = 'blips'}},
                {label = 'GARAGE - ('..#data.garage..')', icon = 'fa-solid fa-car', args = {action = 'garage'}},
                {label = 'GRADI - ('..#data.grades..')', icon = 'fa-solid fa-user', args = {action = 'grades'}},
                {label = 'ELIMINA LAVORO', icon = 'fa-solid fa-x', args = {action = 'delete'}}
            }

            lib.registerMenu({
                id = 'jobmenu',
                title = 'JOB CREATOR - '..data.label,
                position = 'top-right',
                onClose = function(keyPressed)
                    MenuCreatejob()
                end,
                options = elements
            }, function(selected, scrollIndex, args)
                Actions(args.action, data.name)
            end)
            
            lib.showMenu('jobmenu')
        end
    end
end


function OpenDepositDetails(v, index, job)
    local deposit = v.depositi[index]

    lib.registerMenu({
        id = 'menudepositidetails',
        title = 'JOB CREATOR - DEPOSIT DETAILS',
        position = 'top-right',
        options = {
            {label = 'TIPPATI', icon = 'fa-solid fa-map-pin', args = {action = 'tippati'}},
            {label = 'MODIFICA POSIZIONE', icon = 'fa-solid fa-gear', args = {action = 'modifica1'}},
            {label = 'MODIFICA IMPOSTAZIONI', icon = 'fa-solid fa-gear', args = {action = 'modifica2'}},
            {label = 'ELIMINA DEPOSITO', icon = 'fa-regular fa-x', args = {action = 'delete'}}
        },
        onClose = function() 
            Actions('depositi', job)
        end
    }, function(selected, scrollIndex, args)
        if args.action == 'tippati' then
            local p = deposit.pos
            SetEntityCoords(GetPlayerPed(-1), vector3(p.x, p.y, p.z))
        elseif args.action == 'modifica1' then
            local coords = GetEntityCoords(cache.ped)
            local alert = lib.alertDialog({
                header = 'MODIFICA POSIZIONE DEPOSITO',
                content = "Sei sicuro di voler modificare la posizione del deposito?\n\n{x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z .. "}",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                deposit.pos = coords
                TriggerServerEvent('jobcreator:azioni', 'creadeposito', v)
                Actions('depositi', job)
            end
        elseif args.action == 'modifica2' then
            local input = lib.inputDialog('MODIFICA DEPOSITO', {
                {type = 'input', default = 'x = ' .. deposit.pos.x .. ', y = ' .. deposit.pos.y .. ', z = ' .. deposit.pos.z, label = 'COORDINATE', disabled = true},
                {type = 'input', label = 'NOME', default = deposit.name, description = 'Nome del deposito'},
                {type = 'number', label = 'SLOTS', default = deposit.slots, description = 'Slots del deposito'},
                {type = 'number', label = 'PESO', default = deposit.peso, description = 'Peso del deposito'},
                {type = 'number', label = 'GRADO MINIMO', default = deposit.mingrade, description = 'Grado minimo per accesso'}
            })
            if input then
                v.depositi[index] = {
                    pos = deposit.pos,
                    name = input[2],
                    slots = input[3],
                    peso = input[4],
                    mingrade = input[5]
                }
                TriggerServerEvent('jobcreator:azioni', 'creadeposito', v)
                Actions('depositi', job)
            end
        elseif args.action == 'delete' then
            -- Delete the deposit
            local alert = lib.alertDialog({
                header = 'ELIMINA DEPOSITO',
                content = "Sei sicuro di voler eliminare il deposito?",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                table.remove(v.depositi, index)
                TriggerServerEvent('jobcreator:azioni', 'creadeposito', v)
                Actions('depositi', job)
            end
        end
    end)
    lib.showMenu('menudepositidetails')
end

function OpenBossMenuDetails(v, index, job)
    local bossmenu = v.bossmenu[index]
    lib.registerMenu({
        id = 'menubossmenudetails',
        title = 'JOB CREATOR - BOSSMENU DETAILS',
        position = 'top-right',
        options = {
            {label = 'TIPPATI', icon = 'fa-solid fa-map-pin', args = {action = 'tippati'}},
            {label = 'MODIFICA POSIZIONE', icon = 'fa-solid fa-gear', args = {action = 'modifica1'}},
            {label = 'MODIFICA IMPOSTAZIONI', icon = 'fa-solid fa-gear', args = {action = 'modifica2'}},
            {label = 'ELIMINA BOSSMENU', icon = 'fa-regular fa-x', args = {action = 'delete'}}
        },
        onClose = function()
            Actions('bossmenu', job)
        end
    }, function(selected, scrollIndex, args)
        if args.action == 'tippati' then
            local p = bossmenu.pos
            SetEntityCoords(GetPlayerPed(-1), vector3(p.x, p.y, p.z))
        elseif args.action == 'modifica1' then
            local coords = GetEntityCoords(cache.ped)
            local alert = lib.alertDialog({
                header = 'MODIFICA POSIZIONE BOSSMENU',
                content = "Sei sicuro di voler modificare la posizione del bossmenu?\n\n{x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z .. "}",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                bossmenu.pos = coords
                TriggerServerEvent('jobcreator:azioni', 'creabossmenu', v)
                Actions('bossmenu', job)
            end
        elseif args.action == 'modifica2' then
            local jsoncoords = "x = " .. bossmenu.pos.x .. ", y = " .. bossmenu.pos.y .. ", z = " .. bossmenu.pos.z
            local input = lib.inputDialog('MODIFICA BOSSMENU', {
                {type = 'input', default = jsoncoords, label = 'COORDINATE', disabled = true},
                {type = 'number', label = 'GRADO MINIMO', default = bossmenu.mingrade, description = 'Grado minimo per l\'accesso'}
            })
            if input then
                bossmenu.mingrade = input[2]
                TriggerServerEvent('jobcreator:azioni', 'creabossmenu', v)
                Actions('bossmenu', job)
            end
        elseif args.action == 'delete' then
            local alert = lib.alertDialog({
                header = 'ELIMINA BOSSMENU',
                content = "Sei sicuro di voler eliminare il bossmenu?",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                v.bossmenu[index] = nil
                TriggerServerEvent('jobcreator:azioni', 'creabossmenu', v)
                Actions('bossmenu', job)
            end
        end
    end)

    lib.showMenu('menubossmenudetails')
end

function OpenCamerinoDetails(v, index, job)
    local camerino = v.camerino[index]
    lib.registerMenu({
        id = 'menucamerinodetails',
        title = 'JOB CREATOR - CAMERINO DETAILS',
        position = 'top-right',
        options = {
            {label = 'TIPPATI', icon = 'fa-solid fa-map-pin', args = {action = 'tippati'}},
            {label = 'MODIFICA POSIZIONE', icon = 'fa-solid fa-gear', args = {action = 'modifica1'}},
            {label = 'MODIFICA IMPOSTAZIONI', icon = 'fa-solid fa-gear', args = {action = 'modifica2'}},
            {label = 'ELIMINA CAMERINO', icon = 'fa-regular fa-x', args = {action = 'delete'}}
        },
        onClose = function()
            Actions('camerino', job)
        end
    }, function(selected, scrollIndex, args)
        if args.action == 'tippati' then
            local p = camerino.pos
            SetEntityCoords(GetPlayerPed(-1), vector3(p.x, p.y, p.z))
        elseif args.action == 'modifica1' then
            local coords = GetEntityCoords(cache.ped)
            local alert = lib.alertDialog({
                header = 'MODIFICA POSIZIONE CAMERINO',
                content = "Sei sicuro di voler modificare la posizione del camerino?\n\n{x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z .. "}",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                camerino.pos = coords
                TriggerServerEvent('jobcreator:azioni', 'creacamerino', v)
                Actions('camerino', job)
            end
        elseif args.action == 'modifica2' then
            local jsoncoords = "x = " .. camerino.pos.x .. ", y = " .. camerino.pos.y .. ", z = " .. camerino.pos.z
            local input = lib.inputDialog('MODIFICA CAMERINO', {
                {type = 'input', default = jsoncoords, label = 'COORDINATE', disabled = true},
                {type = 'number', label = 'GRADO MINIMO', default = camerino.mingrade, description = 'Grado minimo per l\'accesso'}
            })
            if input then
                camerino.mingrade = input[2]
                TriggerServerEvent('jobcreator:azioni', 'creacamerino', v)
                Actions('camerino', job)
            end
        elseif args.action == 'delete' then
            local alert = lib.alertDialog({
                header = 'ELIMINA CAMERINO',
                content = "Sei sicuro di voler eliminare il camerino?",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                v.camerino[index] = nil
                TriggerServerEvent('jobcreator:azioni', 'creacamerino', v)
                Actions('camerino', job)
            end
        end
    end)

    lib.showMenu('menucamerinodetails')
end

function OpenBlipDetails(v, index, job)
    local blip = v.blips[index]
    lib.registerMenu({
        id = 'menublipdetails',
        title = 'JOB CREATOR - BLIP DETAILS',
        position = 'top-right',
        options = {
            {label = 'TIPPATI', icon = 'fa-solid fa-map-pin', args = {action = 'tippati'}},
            {label = 'MODIFICA POSIZIONE', icon = 'fa-solid fa-gear', args = {action = 'modifica1'}},
            {label = 'MODIFICA IMPOSTAZIONI', icon = 'fa-solid fa-gear', args = {action = 'modifica2'}},
            {label = 'ELIMINA BLIP', icon = 'fa-regular fa-x', args = {action = 'delete'}}
        },
        onClose = function()
            Actions('blips', job)
        end
    }, function(selected, scrollIndex, args)
        if args.action == 'tippati' then
            local p = blip.pos
            SetEntityCoords(GetPlayerPed(-1), vector3(p.x, p.y, p.z))
        elseif args.action == 'modifica1' then
            local coords = GetEntityCoords(cache.ped)
            local alert = lib.alertDialog({
                header = 'MODIFICA POSIZIONE BLIP',
                content = "Sei sicuro di voler modificare la posizione del blip?\n\n{x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z .. "}",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                blip.pos = coords
                TriggerServerEvent('jobcreator:azioni', 'creablip', v)
                Actions('blips', job)
            end
        elseif args.action == 'modifica2' then
            local jsoncoords = "x = " .. blip.pos.x .. ", y = " .. blip.pos.y .. ", z = " .. blip.pos.z
            local input = lib.inputDialog('MODIFICA BLIP', {
                {type = 'input', default = jsoncoords, label = 'COORDINATE', disabled = true},
                {type = 'input', label = 'Nome', default = blip.name, description = 'Nome del blip in mappa'},
                {type = 'number', label = 'ID', default = blip.id, description = 'ID del blip in mappa', icon = 'hashtag'},
                {type = 'number', label = 'COLORE', default = blip.color, description = 'Colore del blip in mappa', icon = 'hashtag'},
                {type = 'input', label = 'GRANDEZZA', precision = true, default = blip.scale, description = 'Grandezza del blip in mappa', icon = 'hashtag'},
            })
            if input then
                blip.name = input[2]
                blip.id = input[3]
                blip.color = input[4]
                blip.scale = input[5]
                TriggerServerEvent('jobcreator:azioni', 'creablip', v)
                Actions('blips', job)
            end
        elseif args.action == 'delete' then
            local alert = lib.alertDialog({
                header = 'ELIMINA BLIP',
                content = "Sei sicuro di voler eliminare il blip?",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                v.blips[index] = nil
                TriggerServerEvent('jobcreator:azioni', 'creablip', v)
                Actions('blips', job)
            end
        end
    end)

    lib.showMenu('menublipdetails')
end

function Actions(azione, job)
    local json = lib.callback.await('jobcreator:getjson')
    for k,v in pairs(json) do
        if job == v.name  then
            if azione == 'depositi' then
                local depositi = {}
                for c, e in pairs(v.depositi) do
                    table.insert(depositi, {label = e.name .. ' - (' .. e.slots .. ')', icon = 'fa-solid fa-box', args = {index = c}})
                end
                table.insert(depositi, {label = 'CREA DEPOSIT', icon = 'fa-solid fa-plus', args = {action = 'creadeposito'}})
                lib.registerMenu({
                    id = 'menudepositi',
                    title = 'JOB CREATOR - DEPOSITI',
                    position = 'top-right',
                    options = depositi,
                    onClose = function() 
                        JobMenu(job)
                    end
                }, function(selected, scrollIndex, args)
                    if args.action == 'creadeposito' then
                        local coords = GetEntityCoords(cache.ped)
                        local jsoncoords = "x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z
                        local input = lib.inputDialog('CREA DEPOSIT', {
                            {type = 'input', default = jsoncoords, label = 'COORDINATE', description = 'Coordinate del deposito', disabled = true},
                            {type = 'input', label = 'NOME', default = 'Deposito', description = 'Nome del deposito'},
                            {type = 'number', label = 'SLOTS', default = 100, description = 'Slots del deposito'},
                            {type = 'number', label = 'PESO', default = 1000, description = 'Peso del deposito'},
                            {type = 'number', label = 'GRADO MINIMO', default = 0, description = 'Grado minimo per accesso'}
                        })
                        if input then
                            table.insert(v.depositi, {
                                pos = GetEntityCoords(cache.ped),
                                name = input[2],
                                slots = input[3],
                                peso = input[4],
                                mingrade = input[5]
                            })
                            TriggerServerEvent('jobcreator:azioni', 'creadeposito', v)
                            Actions('depositi', job)
                        else
                            Actions('depositi', job)
                        end
                    else
                        OpenDepositDetails(v, args.index, job)
                    end
                end)
                lib.showMenu('menudepositi')
            elseif azione == 'bossmenu' then
                local bossmenus = {}
                
                for c, e in pairs(v.bossmenu) do
                    table.insert(bossmenus, {label = 'BOSSMENU (' .. c .. ')', icon = 'fa-solid fa-laptop', args = {index = c}})
                end
                table.insert(bossmenus, {label = 'CREA BOSSMENU', icon = 'fa-solid fa-plus', args = {action = 'creabossmenu'}})

                -- Register the bossmenu
                lib.registerMenu({
                    id = 'menubossmenu',
                    title = 'JOB CREATOR - BOSSMENU',
                    position = 'top-right',
                    options = bossmenus,
                    onClose = function()
                        JobMenu(job)
                    end
                }, function(selected, scrollIndex, args)
                    if args.action == 'creabossmenu' then
                        local coords = GetEntityCoords(cache.ped)
                        local jsoncoords = "x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z
                        local input = lib.inputDialog('BOSSMENU', {
                            {type = 'input', default = jsoncoords, label = 'COORDINATE', description = 'Coordinate del bossmenu', disabled = true},
                            {type = 'number', label = 'GRADO MINIMO', default = 0, description = 'Grado minimo per l\'accesso'}
                        })
                        if input then
                            table.insert(v.bossmenu, {
                                pos = coords,
                                mingrade = input[2]
                            })
                            TriggerServerEvent('jobcreator:azioni', 'creabossmenu', v)
                            Actions('bossmenu', job)
                        else
                            Actions('bossmenu', job)
                        end
                    else
                        OpenBossMenuDetails(v, args.index, job)
                    end
                end)

                lib.showMenu('menubossmenu')
            elseif azione == 'camerino' then
                local camerino = {}
                for c, e in pairs(v.camerino) do
                    table.insert(camerino, {label = 'CAMERINO (' .. c .. ')', icon = 'fa-solid fa-shirt', args = {index = c}})
                end
                table.insert(camerino, {label = 'CREA WARDROBE', icon = 'fa-solid fa-plus', args = {action = 'creacamerino'}})
                lib.registerMenu({
                    id = 'menucamerino',
                    title = 'JOB CREATOR - CAMERINO',
                    position = 'top-right',
                    options = camerino,
                    onClose = function()
                        JobMenu(job)
                    end
                }, function(selected, scrollIndex, args)
                    if args.action == 'creacamerino' then
                        local coords = GetEntityCoords(cache.ped)
                        local jsoncoords = "x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z
                        local input = lib.inputDialog('CAMERINO', {
                            {type = 'input', default = jsoncoords, label = 'COORDINATE', description = 'Coordinate del camerino', disabled = true},
                            {type = 'number', label = 'GRADO MINIMO', default = 0, description = 'Grado minimo per l\'accesso'}
                        })
                        if input then
                            table.insert(v.camerino, {
                                pos = coords,
                                mingrade = input[2]
                            })
                            TriggerServerEvent('jobcreator:azioni', 'creacamerino', v)
                            Actions('camerino', job)
                        else
                            Actions('camerino', job)
                        end
                    else
                        OpenCamerinoDetails(v, args.index, job)
                    end
                end)

                lib.showMenu('menucamerino')
            elseif azione == 'blips' then
                local blip = {}
                for a, b in pairs(v.blips) do
                    table.insert(blip, {label = b.name .. ' (' .. a .. ')', icon = 'fa-solid fa-map-pin', args = {index = a}})
                end
                table.insert(blip, {label = 'CREA BLIP', icon = 'fa-solid fa-plus', args = {action = 'creablip'}})

                lib.registerMenu({
                    id = 'menublip',
                    title = 'JOB CREATOR - BLIP',
                    position = 'top-right',
                    options = blip,
                    onClose = function()
                        JobMenu(job)
                    end
                }, function(selected, scrollIndex, args)
                    if args.action == 'creablip' then
                        local coords = GetEntityCoords(cache.ped)
                        local jsoncoords = "x = " .. coords.x .. ", y = " .. coords.y .. ", z = " .. coords.z
                        local input = lib.inputDialog('BLIP', {
                            {type = 'input', default = jsoncoords, label = 'COORDINATE', description = 'Coordinate del blip', disabled = true},
                            {type = 'input', label = 'Nome', default = 'Blip', description = 'Nome del blip in mappa'},
                            {type = 'number', label = 'ID', default = 1, description = 'ID del blip in mappa', icon = 'hashtag'},
                            {type = 'number', label = 'COLORE', default = 1, description = 'Colore del blip in mappa', icon = 'hashtag'},
                            {type = 'input', label = 'GRANDEZZA', precision = true, default = '0.7', description = 'Grandezza del blip in mappa', icon = 'hashtag'},
                        })
                        if input then
                            table.insert(v.blips, {
                                pos = coords,
                                id = input[3],
                                color = input[4],
                                scale = input[5],
                                name = input[2],
                            })
                            TriggerServerEvent('jobcreator:azioni', 'creablip', v)
                            Actions('blips', job)
                        else
                            Actions('blips', job)
                        end
                    else
                        OpenBlipDetails(v, args.index, job)
                    end
                end)

                lib.showMenu('menublip')
            elseif azione == 'garage' then
                OpenGarageMenu(v)
            elseif azione == 'grades' then 
                local function GradesMenu()
                local menugradi = {}
            
                for a, b in pairs(v.grades) do
                    table.insert(menugradi, {label = b.label .. ' - (' .. b.numgrado .. ')', icon = 'fa-solid fa-user', args = {value = a}})
                end
                table.insert(menugradi, {label = 'CREA GRADO', icon = 'fa-solid fa-plus', args = {value = 'addgrade'}})
            
                lib.registerMenu({
                    id = 'grades_menu',
                    title = 'JOB CREATOR - GRADI',
                    position = 'top-right',
                    options = menugradi
                }, function(selected, scrollIndex, args)
                    local value = args.value
            
                    if value == 'addgrade' then
                        local input = lib.inputDialog('DEPOSITO', {
                            {type = 'number', label = 'NUM GRADO', default = #v.grades, description = 'Numero del grado nel /setjob', icon = 'hashtag'},
                            {type = 'input', label = 'NOME GRADO', default = 'grade'..#v.grades, description = 'Nome del grado'},
                            {type = 'input', label = 'LABEL GRADO', default = 'Grado '..#v.grades, description = 'Label del grado'},
                            {type = 'number', label = 'STIPENDIO', default = 100, description = 'Stipendio che riceverà il grado', icon = 'hashtag'},
                        })
                        if input then
                            table.insert(v.grades, {
                                numgrado = input[1],
                                name = input[2],
                                label = input[3],
                                salary = input[4]
                            })
                            TriggerServerEvent('jobcreator:azioni', 'addgrade', v)
                            GradesMenu()
                        end
                    else
                        lib.registerMenu({
                            id = 'grades_actions_menu',
                            title = 'JOB CREATOR - GARAGE',
                            position = 'top-right',
                            options = {
                                {label = 'MODIFICA GRADO', icon = 'fa-solid fa-map-pin', args = {value = 'modifica', grade = value}},
                                {label = 'ELIMINA GRADO', icon = 'fa-solid fa-gear', args = {value = 'elimina', grade = value}},
                            }
                        }, function(selectedAction, scrollIndexAction, actionArgs)
                            local gradeValue = actionArgs.grade
                            local selectedValue = actionArgs.value
            
                            if selectedValue == 'modifica' then
                                local gradeData = v.grades[gradeValue]
                                local input = lib.inputDialog('DEPOSITO', {
                                    {type = 'number', label = 'NUM GRADO', default = gradeData.numgrado, description = 'Numero del grado nel /setjob', icon = 'hashtag'},
                                    {type = 'input', label = 'NOME GRADO', default = gradeData.name, description = 'Nome del grado'},
                                    {type = 'input', label = 'LABEL GRADO', default = gradeData.label, description = 'Label del grado'},
                                    {type = 'number', label = 'STIPENDIO', default = gradeData.salary, description = 'Stipendio che riceverà il grado', icon = 'hashtag'},
                                })
                                if input then
                                    v.grades[gradeValue] = {
                                        numgrado = input[1],
                                        name = input[2],
                                        label = input[3],
                                        salary = input[4]
                                    }
                                    TriggerServerEvent('jobcreator:azioni', 'addgrade', v)
                                end
                            elseif selectedValue == 'elimina' then
                                local alert = lib.alertDialog({
                                    header = 'ELIMINA GRADO',
                                    content = "Sei sicuro di voler eliminare il grado?",
                                    centered = true,
                                    cancel = true
                                })
                                if alert == 'confirm' then
                                    v.grades[gradeValue] = nil
                                    TriggerServerEvent('jobcreator:azioni', 'addgrade', v)
                                end
                            end
                        end)
                        lib.showMenu('grades_actions_menu')
                    end
                end)
            
                lib.showMenu('grades_menu')
            end
            
            GradesMenu()
            
            elseif azione == 'delete' then
                local alert = lib.alertDialog({
                    header = 'ELIMINA FAZIONE',
                    content = "Sei sicuro di voler eliminare il job?",
                    centered = true,
                    cancel = true
                })
                if alert == 'confirm' then
                    TriggerServerEvent('jobcreator:azioni', azione, v)
                else
                    Actions('garage')
                end
            end
        end
    end
end

function OpenGarageMenu(v)
    local garage = {}
    
    for a, b in pairs(v.garage) do
        table.insert(garage, {label = 'GARAGE'..' ('..a..')', icon = 'fa-solid fa-car', args = a})
    end
    table.insert(garage, {label = 'CREA GARAGE', icon = 'fa-solid fa-plus', args = 'creagarage'})

    lib.registerMenu({
        id = 'menugarage',
        title = 'JOB CREATOR - GARAGE',
        position = 'top-right',
        options = garage
    }, function(selected, scrollIndex, args)
        if args == 'creagarage' then
            local input = lib.inputDialog('GARAGE', {
                {type = 'input', label = 'Nome', default = 'GARAGE '..#v.garage + 1, description = 'Nome del garage'},
                {type = 'number', label = 'Grado minimo', default = 0, description = 'Grado minimo per accederci'}
            })
            if input then
                table.insert(v.garage, {
                    name = input[1],
                    mingrade = input[2],
                    listaveicoli = {}
                })
                TriggerServerEvent('jobcreator:azioni', args, v)
            else
                Actions('garage')
            end
        else
            OpenGarageActionsMenu(v, args)
        end
    end)

    lib.showMenu('menugarage')
end

function OpenGarageActionsMenu(v, garageId)
    local options = {
        {label = 'MODIFICA', icon = 'fa-solid fa-map-pin', args = 'modifica'},
        {label = 'ELIMINA GARAGE', icon = 'fa-solid fa-trash', args = 'elimina'}
    }

    lib.registerMenu({
        id = 'menugarageactions',
        title = 'JOB CREATOR - ' .. v.garage[garageId].name,
        position = 'top-right',
        options = options
    }, function(selected, scrollIndex, args)
        if args == 'modifica' then
            OpenModifyGarageMenu(v, garageId)
        elseif args == 'elimina' then
            local alert = lib.alertDialog({
                header = 'ELIMINA GARAGE',
                content = "Sei sicuro di voler eliminare il garage?",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                v.garage[garageId] = nil
                TriggerServerEvent('jobcreator:azioni', 'creagarage', v)
            else
                Actions('garage')
            end
        end
    end)

    lib.showMenu('menugarageactions')
end

function OpenModifyGarageMenu(v, garageId)
    local opt = {
        {label = 'PUNTO DI RITIRO', icon = 'fa-solid fa-map-pin', args = 'punto1'},
        {label = 'PUNTO DI SPAWN', icon = 'fa-solid fa-map-pin', args = 'punto2'},
        {label = 'LISTA VEICOLI', icon = 'fa-solid fa-car', args = 'listaveh'}
    }

    lib.registerMenu({
        id = 'modificagarage',
        title = 'MODIFICA GARAGE - '..v.garage[garageId].name,
        position = 'top-right',
        options = opt
    }, function(selected, scrollIndex, args)
        if args == 'punto1' then
            local coords = GetEntityCoords(cache.ped)
            local alert = lib.alertDialog({
                header = 'PUNTO DI RITIRO',
                content = "Sei sicuro di voler mettere il punto qua?\n\n{ x = "..coords.x..", y = "..coords.y..", z = "..coords.z.." }",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                v.garage[garageId].pos1 = coords
                TriggerServerEvent('jobcreator:azioni', 'punto1', v)
            end
        elseif args == 'punto2' then
            local coords = GetEntityCoords(cache.ped)
            local alert = lib.alertDialog({
                header = 'PUNTO DI SPAWN',
                content = "Sei sicuro di voler mettere il punto qua?\n\n{ x = "..coords.x..", y = "..coords.y..", z = "..coords.z.." }",
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                v.garage[garageId].pos2 = coords
                v.garage[garageId].heading = GetEntityHeading(PlayerPedId())
                TriggerServerEvent('jobcreator:azioni', 'punto2', v)
            end
        elseif args == 'listaveh' then
            OpenVehicleListMenu(v, garageId)
        end
    end)

    lib.showMenu('modificagarage')
end

function OpenVehicleListMenu(v, garageId)
    local vehs = {}
    for a, b in pairs(v.garage[garageId].listaveicoli) do
        table.insert(vehs, {label = b.label..' ('..a..')', icon = 'fa-solid fa-car', args = a})
    end
    table.insert(vehs, {label = 'AGGIUNGI VEICOLO', icon = 'fa-solid fa-plus', args = 'addveh'})

    lib.registerMenu({
        id = 'listaveh',
        title = 'LISTA VEICOLI',
        position = 'top-right',
        options = vehs
    }, function(selected, scrollIndex, args)
        if args == 'addveh' then
            local input = lib.inputDialog('VEICOLO', {
                {type = 'input', label = 'Nome', default = 'blista', description = 'Nome di spawn del veicolo'},
                {type = 'input', label = 'Label', default = 'Veicolo', description = 'Nome visualizzato'},
                {type = 'input', label = 'Targa', default = 'Targa', description = 'Targa del veicolo'},
                {type = 'number', label = 'Grado minimo', default = 0, description = 'Grado minimo per usarlo'},
                {type = 'color', label = 'Colore', format = 'rgba', description = 'Colore del veicolo'},
                {type = 'checkbox', label = 'Fullkit'}
            })
            if input then
                table.insert(v.garage[garageId].listaveicoli, {
                    name = input[1],
                    label = input[2],
                    targa = input[3],
                    mingrade = input[4],
                    color = lib.math.torgba(input[5]),
                    fullkit = input[6]
                })
                TriggerServerEvent('jobcreator:azioni', 'addveh', v)
                OpenVehicleListMenu(v, garageId)
            end
        end
    end)

    lib.showMenu('listaveh')
end

CreateThread(function()
    RegisterMarkers()
end)

RegisterNetEvent('registerMarkers', function()
    RegisterMarkers()
end)


local createdBlips = {}

function RegisterMarkers()
    local json = lib.callback.await('jobcreator:getjson')
    
    for _, blip in pairs(createdBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    createdBlips = {} 
    for k, v in pairs(json) do
        for a, b in pairs(v.depositi) do
            TriggerEvent('gridsystem:unregisterMarker', 'deposito'..v.name..a)
        end
        for a, b in pairs(v.bossmenu) do
            TriggerEvent('gridsystem:unregisterMarker', 'bossmenu'..v.name..a)
        end
        for a, b in pairs(v.camerino) do
            TriggerEvent('gridsystem:unregisterMarker', 'camerino'..v.name..a)
        end
        for a, b in pairs(v.garage) do
            TriggerEvent('gridsystem:unregisterMarker', 'pos1'..v.name..a)
            TriggerEvent('gridsystem:unregisterMarker', 'pos2'..v.name..a)
        end
        if v.blips then
            for a, b in pairs(v.blips) do
                local blip = AddBlipForCoord(b.pos.x, b.pos.y, b.pos.z)
                SetBlipSprite(blip, b.id)
                SetBlipDisplay(blip, 2)
                SetBlipColour(blip, b.color)
                SetBlipAsShortRange(blip, true)
                SetBlipScale(blip, tonumber(b.scale))
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(b.name)
                EndTextCommandSetBlipName(blip)
                
                table.insert(createdBlips, blip)
            end
        end
        if v.depositi then
            for a,b in pairs(v.depositi) do
                TriggerEvent('gridsystem:registerMarker', {
                    name = 'deposito'..v.name..a,
                    pos = vector3(b.pos.x,b.pos.y,b.pos.z),
                    scale = vector3(0.7,0.7,0.7),
                    control = 'E',
                    type = Config.TipoMarker,        
                    drawDistance = 5,
                    interactDistance = 2,
                    msg = 'DEPOSITO',
                    color = { r = 255, g = 255, b = 255 },
                    permission = v.name,
                    jobGrade = b.mingrade,
                    texture = Config.MarkerDeposito,
                    action = function()
                        exports.ox_inventory:openInventory('stash', v.name..a)
                    end,
                })
            end
        end
        if v.bossmenu then
            for a,b in pairs(v.bossmenu) do
                TriggerEvent('gridsystem:registerMarker', {
                    name = 'bossmenu'..v.name..a,
                    pos = vector3(b.pos.x,b.pos.y,b.pos.z),
                    scale = vector3(0.7,0.7,0.7),
                    control = 'E',
                    type = Config.TipoMarker,        
                    drawDistance = 5,
                    interactDistance = 2,
                    msg = 'BOSSMENU '..a,
                    color = { r = 255, g = 255, b = 255 },
                    permission = v.name,
                    jobGrade = b.mingrade,
                    texture = Config.MarkerBossMenu,
                    action = function()
                        local ply = ESX.GetPlayerData()
                        TriggerEvent('es-management:Open', ply.job.name, ply.job.label)
                    end,
                })
            end
        end
        if v.camerino then
            for a,b in pairs(v.camerino) do
                TriggerEvent('gridsystem:registerMarker', {
                    name = 'camerino'..v.name..a,
                    pos = vector3(b.pos.x,b.pos.y,b.pos.z),
                    scale = vector3(0.7,0.7,0.7),
                    control = 'E',
                    type = Config.TipoMarker,        
                    drawDistance = 5,
                    interactDistance = 2,
                    msg = 'CAMERINO '..a,
                    color = { r = 255, g = 255, b = 255 },
                    permission = v.name,
                    jobGrade = b.mingrade,
                    texture = Config.MarkerCamerino,
                    action = function()
                        print('Opencamerino')
                    end,
                })
            end
        end
        if v.garage then
            for a,b in pairs(v.garage) do
                if b.pos1 then
                    TriggerEvent('gridsystem:registerMarker', {
                        name = 'pos1'..v.name..a,
                        pos = vector3(b.pos1.x,b.pos1.y,b.pos1.z),
                        scale = vector3(0.7,0.7,0.7),
                        control = 'E',
                        type = Config.TipoMarker,    
                        drawDistance = 5,
                        interactDistance = 2,
                        msg = 'GARAGE '..a,
                        color = { r = 255, g = 255, b = 255 },
                        permission = v.name,
                        jobGrade = b.mingrade,
                        texture = Config.MarkerGarage,
                        action = function()
                            ApriGarage(v, v.name, v.garage[a])
                        end,
                    })
                end
                if b.pos2 then
                    TriggerEvent('gridsystem:registerMarker', {
                        name = 'pos2'..v.name..a,
                        pos = vector3(b.pos2.x,b.pos2.y,b.pos2.z),
                        scale = vector3(0.7,0.7,0.7),
                        control = 'E',
                        type = Config.TipoMarker,    
                        drawDistance = 5,
                        interactDistance = 2,
                        msg = 'DEPOSITO VEICOLO',
                        color = { r = 255, g = 255, b = 255 },
                        permission = v.name,
                        jobGrade = b.mingrade,
                        texture = Config.MarkerGarage,
                        action = function()
                            if IsPedInAnyVehicle(PlayerPedId()) then
                                ESX.Game.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                ESX.ShowNotification('Veicolo depositato con successo')
                            else
                                ESX.ShowNotification('Non sei in un veicolo')
                            end
                        end,
                    })
                end
            end
        end
    end
end


function ApriGarage(data, job, garage)
    if data.name == job then
        local elements = {}
        for a,dt in pairs(garage.listaveicoli) do
            table.insert(elements, {label = dt.label, args = {model = dt.name, colore = dt.color, targa = dt.targa, grado = dt.mingrade }})
        end
        
        if #elements == 0 then
            table.insert(elements,{label = 'NESSUN VEICOLO DISPONIBILE', model = 'null'})
        end


        lib.registerMenu({
            id = 'job_creator_listaveh',
            title = 'LISTA VEICOLI - '..ESX.GetPlayerData().job.label,
            position = 'top-center',
            options = elements
        }, function(selected, scrollIndex, args)
            print(args)
            if args.model ~= 'null' and args.model ~= nil then
                local PlayerData = ESX.GetPlayerData()
                local gradoJob = tonumber(args.grado) or 0
                if gradoJob <= PlayerData.job.grade then
                    if ESX.Game.IsSpawnPointClear(garage.pos2, 3.5) then
                        ESX.Game.SpawnVehicle(args.model, garage.pos2, garage.heading, function(vehicle)
                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            if args.fullkit then
                                SetVehicleModKit(vehicle, 0)
                                SetVehicleMod(vehicle, 15, 3, false)
                                SetVehicleMod(vehicle, 13, 2, false)
                                SetVehicleMod(vehicle, 11, 3, false)
                                SetVehicleMod(vehicle, 12, 2, false)
                                ToggleVehicleMod(vehicle, 22, true)
                                ToggleVehicleMod(vehicle, 18, true)
                            end
                            if args.targa ~= "" then
                                SetVehicleNumberPlateText(vehicle, args.targa)
                            end
                            if args.colore then
                                SetVehicleCustomPrimaryColour(vehicle, args.colore.x, args.colore.y, args.colore.z)
                                SetVehicleCustomSecondaryColour(vehicle, args.colore.x, args.colore.y, args.colore.z)
                            end
                        end)
                    else
                        lib.notify({
                            title = 'Notifica',
                            description = 'Punto di spawn occupato',
                            type = 'error'
                        })
                    end
                else
                    lib.notify({
                        title = 'Notifica',
                        description = 'Non hai il permesso di spawnare questo veicolo',
                        type = 'error'
                    })
                end
            end
        end)
        
        lib.showMenu('job_creator_listaveh')
        
    end
end

RegisterNetEvent('DeleteFaz', function(nome)
    DeleteFaz(nome)
end)

function DeleteFaz(nome)
    local json = lib.callback.await('jobcreator:getjson')
    for k, v in pairs(json) do
        for a, b in pairs(v.depositi) do
            TriggerEvent('gridsystem:unregisterMarker', 'deposito'..nome..a)
        end
        for a, b in pairs(v.bossmenu) do
            TriggerEvent('gridsystem:unregisterMarker', 'bossmenu'..nome..a)
        end
        for a, b in pairs(v.camerino) do
            TriggerEvent('gridsystem:unregisterMarker', 'camerino'..nome..a)
        end
        for a, b in pairs(v.garage) do
            TriggerEvent('gridsystem:unregisterMarker', 'pos1'..nome..a)
            TriggerEvent('gridsystem:unregisterMarker', 'pos2'..nome..a)
        end
    end
end