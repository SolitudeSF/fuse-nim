import fuse_wrapper

const
  fuseOptKeyOpt* = -1
  fuseOptKeyNonopt* = -2
  fuseOptKeyKeep* = -3
  fuseOptKeyDiscard* = -4

type
  FuseOpt* {.bycopy.} = object
    templ*: cstring
    offset*: culong
    value*: cint

  FuseArgs* {.bycopy.} = object
    argc*: cint
    argv*: cstringArray
    allocated*: cint

  FuseOptProc* = proc (data: pointer; arg: cstring; key: cint; outargs: ptr FuseArgs): cint

{.push dynlib: fuseLibname.}

proc FuseOptParse*(args: ptr FuseArgs; data: pointer; opts: ptr FuseOpt; `proc`: FuseOptProc): cint {.importc: "fuse_opt_parse".}
proc FuseOptAddOpt*(opts: cstringArray; opt: cstring): cint {.importc: "fuse_opt_add_opt".}
proc FuseOptAddOptEscaped*(opts: cstringArray; opt: cstring): cint {.importc: "fuse_opt_add_opt_escaped".}
proc FuseOptAddArg*(args: ptr FuseArgs; arg: cstring): cint {.importc: "fuse_opt_add_arg".}
proc FuseOptInsertArg*(args: ptr FuseArgs; pos: cint; arg: cstring): cint {.importc: "fuse_opt_insert_arg".}
proc FuseOptFreeArgs*(args: ptr FuseArgs) {.importc: "fuse_opt_free_args".}
proc FuseOptMatch*(opts: ptr FuseOpt; opt: cstring): cint {.importc: "fuse_opt_match".}

{.pop.}
