import fuse_wrapper

type
  FuseLogLevel* = enum
    fuseLogEmerg, fuseLogAlert, fuseLogCrit, fuseLogErr, fuseLogWarning,
    fuseLogNotice, fuseLogInfo, fuseLogDebug

  FuseLogFunc* = proc (level: FuseLogLevel; fmt: cstring; ap: pointer)

{.push dynlib: fuseLibname.}

proc fuseSetLogFunc*(`func`: FuseLogFunc) {.importc: "fuseSetLogFunc".}
proc fuseLog*(level: FuseLogLevel; fmt: cstring) {.importc: "fuseLog", varargs.}

{.pop.}
