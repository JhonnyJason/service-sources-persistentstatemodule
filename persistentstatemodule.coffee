persistentstatemodule = {name: "persistentstatemodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["persistentstatemodule"]?  then console.log "[persistentstatemodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion

############################################################
pathModule = require("path")
fs = require("fs")

############################################################
savedMap = {}

############################################################
persistentstatemodule.initialize = () ->
    log "persistentstatemodule.initialize"
    relative = allModules.configmodule.persistentStateRelativeBasePath
    path = pathModule.resolve(process.cwd(), relative)
    fs.mkdirSync(path) unless fs.existsSync(path)
    return

############################################################
#region internalFunctions
getPath = (label) ->
    # log "getPath"
    filename = label+".json"
    relative = allModules.configmodule.persistentStateRelativeBasePath
    path = pathModule.resolve(process.cwd(), relative, filename)
    # log path
    return path

############################################################
#region backupFunctions
getBackupPath = (path) -> path+".backup"

backup = (path) ->
    backupPath = getBackupPath(path)
    try fs.copyFileSync(path, backupPath)
    catch err then log err.stack
    return

loadBackup = (label) ->
    path = getPath(label)
    backupPath = getBackupPath(path)
    state = {}
    try
        contentString = fs.readFileSync(backupPath, "utf-8")
        savedMap[label] = contentString
        state = JSON.parse(contentString)
    catch err
        log err.stack
        delete savedMap[label]
        return {}
    return state
    
#endregion

#endregion

############################################################
#region exposedFunctions
persistentstatemodule.load = (label) ->
    log "persistentstatemodule.load"
    path = getPath(label)
    state = {}
    try
        contentString = fs.readFileSync(path, "utf-8")
        savedMap[label] = contentString
        state = JSON.parse(contentString)
    catch err then return loadBackup(label)
    return state

persistentstatemodule.save = (label, content) ->
    log "persistentstatemodule.save"
    path = getPath(label)
    stringContent = JSON.stringify(content, null, 4)
    if savedMap[label]? and savedMap[label] == stringContent then return
    # log "is being saved.."
    savedMap[label] = stringContent
    fs.writeFile(path, stringContent, () -> backup(path))
    # log "greate success!"
    return

persistentstatemodule.uncache = (label) ->
    delete savedMap[label]
    return

#endregion

module.exports = persistentstatemodule