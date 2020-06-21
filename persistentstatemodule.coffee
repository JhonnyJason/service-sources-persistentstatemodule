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
getPath = (label) ->
    # log "getPath"
    filename = label+".json"
    relative = allModules.configmodule.persistentStateRelativeBasePath
    path = pathModule.resolve(process.cwd(), relative, filename)
    # log path
    return path

############################################################
persistentstatemodule.load = (label) ->
    log "persistentstatemodule.load"
    path = getPath(label)
    state = {}
    try 
        contentString = fs.readFileSync(path, "utf-8")
        savedMap[label] = contentString
        state = JSON.parse(contentString)
    catch err then log err
    return state

persistentstatemodule.save = (label, content) ->
    log "persistentstatemodule.save"
    path = getPath(label)
    stringContent = JSON.stringify(content, null, 4)
    if savedMap[label]? and savedMap[label] == stringContent then return
    # log "is being saved.."
    savedMap[label] = stringContent
    fs.writeFile(path, stringContent, ()->return )
    # log "greate success!"
    return

module.exports = persistentstatemodule