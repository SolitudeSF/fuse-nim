import fuse_opt, fuse_wrapper

const
  fuseUseVersion* {.intdefine.} = 35
  fuseMajorVersion* = 3
  fuseMinorVersion* = 10
  fuseVersion* = fuseMajorVersion * 100 + fuseMinorVersion
  fuseCapAsyncRead* = 1 shl 0
  fuseCapPosixLocks* = 1 shl 1
  fuseCapAtomicOTrunc* = 1 shl 3
  fuseCapExportSupport* = 1 shl 4
  fuseCapDontMask* = 1 shl 6
  fuseCapSpliceWrite* = 1 shl 7
  fuseCapSpliceMove* = 1 shl 8
  fuseCapSpliceRead* = 1 shl 9
  fuseCapFlockLocks* = 1 shl 10
  fuseCapIoctlDir* = 1 shl 11
  fuseCapAutoInvalData* = 1 shl 12
  fuseCapReaddirplus* = 1 shl 13
  fuseCapReaddirplusAuto* = 1 shl 14
  fuseCapAsyncDio* = 1 shl 15
  fuseCapWritebackCache* = 1 shl 16
  fuseCapNoOpenSupport* = 1 shl 17
  fuseCapParallelDirops* = 1 shl 18
  fuseCapPosixAcl* = 1 shl 19
  fuseCapHandleKillpriv* = 1 shl 20
  fuseCapCacheSymlinks* = 1 shl 23
  fuseCapNoOpendirSupport* = 1 shl 24
  fuseCapExplicitInvalData* = 1 shl 25
  fuseIoctlCompat* = 1 shl 0
  fuseIoctlUnrestricted* = 1 shl 1
  fuseIoctlRetry* = 1 shl 2
  fuseIoctlDir* = 1 shl 4
  fuseIoctlMaxIov* = 256

type
  FuseFileInfo* {.bycopy.} = object
    flags*: cint
    writepage* {.bitsize: 1.}: cuint
    directIo* {.bitsize: 1.}: cuint
    keepCache* {.bitsize: 1.}: cuint
    flush* {.bitsize: 1.}: cuint
    nonseekable* {.bitsize: 1.}: cuint
    flockRelease* {.bitsize: 1.}: cuint
    cacheReaddir* {.bitsize: 1.}: cuint
    padding* {.bitsize: 25.}: cuint
    padding2* {.bitsize: 32.}: cuint
    fh*: uint64
    lockOwner*: uint64
    pollEvents*: uint32

  FuseLoopConfig* {.bycopy.} = object
    cloneFd*: cint
    maxIdlehreads*: cuint

  FuseConnInfo* {.bycopy.} = object
    protoMajor*: cuint
    protoMinor*: cuint
    maxWrite*: cuint
    maxRead*: cuint
    maxReadahead*: cuint
    capable*: cuint
    want*: cuint
    maxBackground*: cuint
    congestionhreshold*: cuint
    timeGran*: cuint
    reserved*: array[22, cuint]

  FuseSession* {.bycopy.} = object
  FusePollhandle* {.bycopy.} = object
  FuseConnInfoOpts* {.bycopy.} = object

  FuseBufFlags* = enum
    fuseBufIsFd = 1 shl 1
    fuseBufFdSeek = 1 shl 2
    fuseBufFdRetry = 1 shl 3

  FuseBufCopyFlags* = enum
    fuseBufNoSplice = 1 shl 1
    fuseBufForceSplice = 1 shl 2
    fuseBufSpliceMove = 1 shl 3
    fuseBufSpliceNonblock = 1 shl 4

  FuseBuf* {.bycopy.} = object
    size*: csize_t
    flags*: FuseBufFlags
    mem*: pointer
    fd*: cint
    pos*: int

  FuseBufvec* {.bycopy.} = object
    count*: csize_t
    idx*: csize_t
    offset*: csize_t
    buf*: array[1, FuseBuf]

{.push dynlib: fuseLibname.}

proc fuseParseConnInfoOpts*(args: ptr FuseArgs): ptr FuseConnInfoOpts {.importc: "fuse_parse_conn_info_opts".}
proc fuseApplyConnInfoOpts*(opts: ptr FuseConnInfoOpts; conn: ptr FuseConnInfo) {.importc: "fuse_apply_conn_info_opts".}
proc fuseDaemonize*(foreground: cint): cint {.importc: "fuse_daemonize".}
proc getFuseVersion*(): cint {.importc: "fuse_version".}
proc fusePkgversion*(): cstring {.importc: "fuse_pkgversion".}
proc fusePollhandleDestroy*(ph: ptr FusePollhandle) {.importc: "fuse_pollhandle_destroy".}
proc fuseBufSize*(bufv: ptr FuseBufvec): csize_t {.importc: "fuse_buf_size".}
proc fuseBufCopy*(dst: ptr FuseBufvec; src: ptr FuseBufvec; flags: FuseBufCopyFlags): int {.importc: "fuse_buf_copy".}
proc fuseSetSignalHandlers*(se: ptr FuseSession): cint {.importc: "fuse_set_signal_handlers".}
proc fuseRemoveSignalHandlers*(se: ptr FuseSession) {.importc: "fuse_remove_signal_handlers".}

{.pop.}
