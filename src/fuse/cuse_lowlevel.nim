import fuse_lowlevel, fuse_common, fuse_opt, fuse_wrapper

const cuseUnrestrictedIoctl* = 1 shl 0

type
  FuseSession* {.bycopy.} = object
  CuseInfo* {.bycopy.} = object
    devMajor*: cuint
    devMinor*: cuint
    devInfoArgc*: cuint
    devInfoArgv*: cstringArray
    flags*: cuint

  CuseLowlevelOps* {.bycopy.} = object
    init*: proc (userdata: pointer; conn: ptr FuseConnInfo)
    initDone*: proc (userdata: pointer)
    destroy*: proc (userdata: pointer)
    open*: proc (req: FuseReq; fi: ptr FuseFileInfo)
    read*: proc (req: FuseReq; size: csize_t; offset: int; fi: ptr FuseFileInfo)
    write*: proc (req: FuseReq; buf: cstring; size: csize_t; offset: int; fi: ptr FuseFileInfo)
    flush*: proc (req: FuseReq; fi: ptr FuseFileInfo)
    release*: proc (req: FuseReq; fi: ptr FuseFileInfo)
    fsync*: proc (req: FuseReq; datasync: cint; fi: ptr FuseFileInfo)
    ioctl*: proc (req: FuseReq; cmd: cint; arg: pointer; fi: ptr FuseFileInfo;
                flags: cuint; inBuf: pointer; inBufsz: csize_t; outBufsz: csize_t)
    poll*: proc (req: FuseReq; fi: ptr FuseFileInfo; ph: ptr FusePollhandle)

{.push dynlib: fuseLibname.}

proc cuseLowlevelNew*(args: ptr FuseArgs; ci: ptr CuseInfo; clop: ptr CuseLowlevelOps; userdata: pointer): ptr Fusesession {.importc: "cuse_lowlevel_new".}
proc cuseLowlevelSetup*(argc: cint; argv: ptr cstring; ci: ptr CuseInfo; clop: ptr CuseLowlevelOps; multithreaded: ptr cint; userdata: pointer): ptr Fusesession {.importc: "cuse_lowlevel_setup".}
proc cuseLowlevelTeardown*(se: ptr Fusesession) {.importc: "cuse_lowlevel_teardown".}
proc cuseLowlevelMain*(argc: cint; argv: ptr cstring; ci: ptr CuseInfo; clop: ptr CuseLowlevelOps; userdata: pointer): cint {.importc: "cuse_lowlevel_main".}

{.pop.}
