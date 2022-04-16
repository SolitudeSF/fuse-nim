import posix
import fuse_common, fuse_opt, fuse_wrapper
export fuse_common

type
  Fuse* {.bycopy.} = object

  FuseReaddirFlags* = enum
    fuseReadDirPlus = 1 shl 0

  FuseFillDirFlags* = enum
    fuseFillDirPlus = 1 shl 1

  FuseFillDir* = proc (buf: pointer; name: cstring; stbuf: ptr Stat; offset: int; flags: FuseFillDirFlags): cint

  FuseConfig* {.bycopy.} = object
    setGid*: cint
    gid*: cuint
    setUid*: cint
    uid*: cuint
    setMode*: cint
    umask*: cuint
    entryTimeout*: cdouble
    negativeTimeout*: cdouble
    attrTimeout*: cdouble
    intr*: cint
    intrSignal*: cint
    remember*: cint
    hardRemove*: cint
    useIno*: cint
    readdirIno*: cint
    directIo*: cint
    kernelCache*: cint
    autoCache*: cint
    acAttrTimeoutSet*: cint
    acAttrTimeout*: cdouble
    nullpathOk*: cint
    showHelp*: cint
    modules*: cstring
    debug*: cint

  FuseOperations* {.bycopy.} = object
    getattr*: proc (path: cstring, stat: ptr Stat, fi: ptr FuseFileInfo): cint {.cdecl.}
    readlink*: proc (path: cstring, buf: var cstring, size: csize_t): cint {.cdecl.}
    mknod*: proc (path: cstring, mode: Mode, dev: Dev): cint {.cdecl.}
    mkdir*: proc (a1: cstring, a2: Mode): cint {.cdecl.}
    unlink*: proc (a1: cstring): cint {.cdecl.}
    rmdir*: proc (a1: cstring): cint {.cdecl.}
    symlink*: proc (a1: cstring, a2: cstring): cint {.cdecl.}
    rename*: proc (a1: cstring, a2: cstring, flags: cuint): cint {.cdecl.}
    link*: proc (a1: cstring, a2: cstring): cint {.cdecl.}
    chmod*: proc (a1: cstring, a2: Mode, fi: ptr FuseFileInfo): cint {.cdecl.}
    chown*: proc (a1: cstring, a2: Uid, a3: Gid, fi: ptr FuseFileInfo): cint {.cdecl.}
    truncate*: proc (a1: cstring, a2: int, fi: ptr FuseFileInfo): cint {.cdecl.}
    open*: proc (a1: cstring, a2: ptr FuseFileInfo): cint {.cdecl.}
    read*: proc (a1: cstring, a2: cstring, a3: csize_t, a4: int, a5: ptr FuseFileInfo): cint {.cdecl.}
    write*: proc (a1: cstring, a2: cstring, a3: csize_t, a4: int, a5: ptr FuseFileInfo): cint {.cdecl.}
    statfs*: proc (a1: cstring, a2: ptr Statvfs): cint {.cdecl.}
    flush*: proc (a1: cstring, a2: ptr FuseFileInfo): cint {.cdecl.}
    release*: proc (a1: cstring, a2: ptr FuseFileInfo): cint {.cdecl.}
    fsync*: proc (a1: cstring, a2: cint, a3: ptr FuseFileInfo): cint {.cdecl.}
    setxattr*: proc (a1: cstring, a2: cstring, a3: cstring, a4: csize_t, a5: cint): cint {.cdecl.}
    getxattr*: proc (a1: cstring, a2: cstring, a3: cstring, a4: csize_t): cint {.cdecl.}
    listxattr*: proc (a1: cstring, a2: cstring, a3: csize_t): cint {.cdecl.}
    removexattr*: proc (a1: cstring, a2: cstring): cint {.cdecl.}
    opendir*: proc (a1: cstring, a2: ptr FuseFileInfo): cint {.cdecl.}
    readdir*: proc (a1: cstring, a2: pointer, a3: FuseFillDir, a4: int, a5: ptr FuseFileInfo, a6: FuseReaddirFlags): cint {.cdecl.}
    releasedir*: proc (a1: cstring, a2: ptr FuseFileInfo): cint {.cdecl.}
    fsyncdir*: proc (a1: cstring, a2: cint, a3: ptr FuseFileInfo): cint {.cdecl.}
    init*: proc (conn: ptr FuseConnInfo, cfg: ptr FuseConfig): pointer {.cdecl.}
    destroy*: proc (privateData: pointer) {.cdecl.}
    access*: proc (a1: cstring, a2: cint): cint {.cdecl.}
    create*: proc (a1: cstring, a2: Mode, a3: ptr FuseFileInfo): cint {.cdecl.}
    lock*: proc (a1: cstring, a2: ptr FuseFileInfo, cmd: cint, a4: ptr Tflock): cint {.cdecl.}
    utimens*: proc (a1: cstring, tv: array[2, Timespec], fi: ptr FuseFileInfo): cint {.cdecl.}
    bmap*: proc (a1: cstring, blocksize: csize_t, idx: ptr uint64): cint {.cdecl.}
    when fuseUseVersion < 35:
      ioctl*: proc (a1: cstring, cmd: cint, arg: pointer, a4: ptr FuseFileInfo, flags: cuint, data: pointer): cint {.cdecl.}
    else:
      ioctl*: proc (a1: cstring, cmd: cuint, arg: pointer, a4: ptr FuseFileInfo, flags: cuint, data: pointer): cint {.cdecl.}
    poll*: proc (a1: cstring, a2: ptr FuseFileInfo, ph: ptr FusePollhandle, reventsp: ptr cuint): cint {.cdecl.}
    writeBuf*: proc (a1: cstring, buf: ptr FuseBufvec, offset: int, a4: ptr FuseFileInfo): cint {.cdecl.}
    readBuf*: proc (a1: cstring, bufp: ptr ptr FuseBufvec, size: csize_t, offset: int, a5: ptr FuseFileInfo): cint {.cdecl.}
    flock*: proc (a1: cstring, a2: ptr FuseFileInfo, op: cint): cint {.cdecl.}
    fallocate*: proc (a1: cstring, a2: cint, a3: int, a4: int, a5: ptr FuseFileInfo): cint {.cdecl.}
    copyFileRange*: proc (pathIn: cstring, fiIn: ptr FuseFileInfo, offsetIn: int, pathOut: cstring, fiOut: ptr FuseFileInfo, offsetOut: int, size: csize_t, flags: cint): int {.cdecl.}
    lseek*: proc (a1: cstring, offset: int, whence: cint, a4: ptr FuseFileInfo): int {.cdecl.}

  FuseContext* {.bycopy.} = object
    Fuse*: ptr Fuse
    uid*: Uid
    gid*: Gid
    pid*: Pid
    privateData*: pointer
    umask*: Mode

  FuseModuleFactory* = proc (args: ptr FuseArgs; fs: ptr ptr FuseFs): ptr FuseFs

  FuseFs* {.bycopy.} = object


{.push dynlib: fuseLibname.}

proc fuseLibHelp*(args: ptr FuseArgs) {.importc: "fuse_lib_help".}
when fuseUseVersion == 30:
  proc fuseNew30*(args: ptr FuseArgs; op: ptr FuseOperations; opSize: csize_t; privateData: pointer): ptr Fuse {.importc: "fuse_new30".}
  template fuseNew*(args, op, size, data) = fuseNew30(args, op, size, data)
else:
  proc fuseNew*(args: ptr FuseArgs; op: ptr FuseOperations; opSize: csize_t; privateData: pointer): ptr Fuse {.importc: "fuse_new".}
proc fuseMount*(f: ptr Fuse; mountpoint: cstring): cint {.importc: "fuse_mount".}
proc fuseUnmount*(f: ptr Fuse) {.importc: "fuse_unmount".}
proc fuseDestroy*(f: ptr Fuse) {.importc: "fuse_destroy".}
proc fuseLoop*(f: ptr Fuse): cint {.importc: "fuse_loop".}
proc fuseExit*(f: ptr Fuse) {.importc: "fuse_exit".}
when fuseUseVersion < 32:
  proc fuseLoopMt31*(f: ptr Fuse; cloneFd: cint): cint {.importc: "fuse_loop_mt31".}
  template fuseLoopMt*(f, cloneFd) = fuseLoopMt31(f, cloneFd)
else:
  proc fuseLoopMt*(f: ptr Fuse; config: ptr FuseLoopConfig): cint {.importc: "fuse_loop_mt".}
proc fuseGetContext*(): ptr FuseContext {.importc: "fuse_get_context".}
proc fuseGetgroups*(size: cint; list: ptr Gid): cint {.importc: "fuse_getgroups".}
proc fuseInterrupted*(): cint {.importc: "fuse_interrupted".}
proc fuseInvalidatePath*(f: ptr Fuse; path: cstring): cint {.importc: "fuse_invalidate_path".}
proc fuseMainReal*(argc: cint; argv: ptr cstring; op: ptr FuseOperations; opSize: csize_t; privateData: pointer): cint {.importc: "fuse_main_real".}
template fuseMain*(argc: cint; argv: ptr cstring; op: ptr FuseOperations; privateData: pointer): cint = fuseMainReal(argc, argv, op, op[].sizeof.csize_t, privateData)
proc fuseStartCleanupThread*(fuse: ptr Fuse): cint {.importc: "fuse_start_cleanup_thread".}
proc fuseStopCleanupThread*(fuse: ptr Fuse) {.importc: "fuse_stop_cleanup_thread".}
proc fuseCleanCache*(fuse: ptr Fuse): cint {.importc: "fuse_clean_cache".}
proc fuseFsGetattr*(fs: ptr FuseFs; path: cstring; buf: ptr Stat; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_getattr".}
proc fuseFsRename*(fs: ptr FuseFs; oldpath: cstring; newpath: cstring; flags: cuint): cint {.importc: "fuse_fs_rename".}
proc fuseFsUnlink*(fs: ptr FuseFs; path: cstring): cint {.importc: "fuse_fs_unlink".}
proc fuseFsRmdir*(fs: ptr FuseFs; path: cstring): cint {.importc: "fuse_fs_rmdir".}
proc fuseFsSymlink*(fs: ptr FuseFs; linkname: cstring; path: cstring): cint {.importc: "fuse_fs_symlink".}
proc fuseFsLink*(fs: ptr FuseFs; oldpath: cstring; newpath: cstring): cint {.importc: "fuse_fs_link".}
proc fuseFsRelease*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_release".}
proc fuseFsOpen*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_open".}
proc fuseFsRead*(fs: ptr FuseFs; path: cstring; buf: cstring; size: csize_t; offset: int; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_read".}
proc fuseFsReadBuf*(fs: ptr FuseFs; path: cstring; bufp: ptr ptr FuseBufvec; size: csize_t; offset: int; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_read_buf".}
proc fuseFsWrite*(fs: ptr FuseFs; path: cstring; buf: cstring; size: csize_t; offset: int; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_write".}
proc fuseFsWriteBuf*(fs: ptr FuseFs; path: cstring; buf: ptr FuseBufvec; offset: int; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_write_buf".}
proc fuseFsFsync*(fs: ptr FuseFs; path: cstring; datasync: cint; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_fsync".}
proc fuseFsFlush*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_flush".}
proc fuseFsStatfs*(fs: ptr FuseFs; path: cstring; buf: ptr Statvfs): cint {.importc: "fuse_fs_statfs".}
proc fuseFsOpendir*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_opendir".}
proc fuseFsReaddir*(fs: ptr FuseFs; path: cstring; buf: pointer; filler: FuseFillDir; offset: int; fi: ptr FuseFileInfo; flags: FuseReaddirFlags): cint {.importc: "fuse_fs_readdir".}
proc fuseFsFsyncdir*(fs: ptr FuseFs; path: cstring; datasync: cint; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_fsyncdir".}
proc fuseFsReleasedir*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_releasedir".}
proc fuseFsCreate*(fs: ptr FuseFs; path: cstring; mode: Mode; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_create".}
proc fuseFsLock*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo; cmd: cint; lock: ptr Tflock): cint {.importc: "fuse_fs_lock".}
proc fuseFsFlock*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo; op: cint): cint {.importc: "fuse_fs_flock".}
proc fuseFsChmod*(fs: ptr FuseFs; path: cstring; mode: Mode; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_chmod".}
proc fuseFsChown*(fs: ptr FuseFs; path: cstring; uid: Uid; gid: Gid; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_chown".}
proc fuseFsTruncate*(fs: ptr FuseFs; path: cstring; size: int; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_truncate".}
proc fuseFsUtimens*(fs: ptr FuseFs; path: cstring; tv: array[2, Timespec]; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_utimens".}
proc fuseFsAccess*(fs: ptr FuseFs; path: cstring; mask: cint): cint {.importc: "fuse_fs_access".}
proc fuseFsReadlink*(fs: ptr FuseFs; path: cstring; buf: cstring; len: csize_t): cint {.importc: "fuse_fs_readlink".}
proc fuseFsMknod*(fs: ptr FuseFs; path: cstring; mode: Mode; rdev: Dev): cint {.importc: "fuse_fs_mknod".}
proc fuseFsMkdir*(fs: ptr FuseFs; path: cstring; mode: Mode): cint {.importc: "fuse_fs_mkdir".}
proc fuseFsSetxattr*(fs: ptr FuseFs; path: cstring; name: cstring; value: cstring; size: csize_t; flags: cint): cint {.importc: "fuse_fs_setxattr".}
proc fuseFsGetxattr*(fs: ptr FuseFs; path: cstring; name: cstring; value: cstring; size: csize_t): cint {.importc: "fuse_fs_getxattr".}
proc fuseFsListxattr*(fs: ptr FuseFs; path: cstring; list: cstring; size: csize_t): cint {.importc: "fuse_fs_listxattr".}
proc fuseFsRemovexattr*(fs: ptr FuseFs; path: cstring; name: cstring): cint {.importc: "fuse_fs_removexattr".}
proc fuseFsBmap*(fs: ptr FuseFs; path: cstring; blocksize: csize_t; idx: ptr uint64): cint {.importc: "fuse_fs_bmap".}
when fuseUseVersion < 35:
  proc fuseFsIoctl*(fs: ptr FuseFs; path: cstring; cmd: cint; arg: pointer; fi: ptr FuseFileInfo; flags: cuint; data: pointer): cint {.importc: "fuse_fs_ioctl".}
else:
  proc fuseFsIoctl*(fs: ptr FuseFs; path: cstring; cmd: cuint; arg: pointer; fi: ptr FuseFileInfo; flags: cuint; data: pointer): cint {.importc: "fuse_fs_ioctl".}
proc fuseFsPoll*(fs: ptr FuseFs; path: cstring; fi: ptr FuseFileInfo; ph: ptr FusePollhandle; reventsp: ptr cuint): cint {.importc: "fuse_fs_poll".}
proc fuseFsFallocate*(fs: ptr FuseFs; path: cstring; mode: cint; offset: int; length: int; fi: ptr FuseFileInfo): cint {.importc: "fuse_fs_fallocate".}
proc fuseFsCopyFileRange*(fs: ptr FuseFs; pathIn: cstring; fiIn: ptr FuseFileInfo; offIn: int; pathOut: cstring; fiOut: ptr FuseFileInfo; offOut: int; len: csize_t; flags: cint): int {.importc: "fuse_fs_copy_file_range".}
proc fuseFsLseek*(fs: ptr FuseFs; path: cstring; offset: int; whence: cint; fi: ptr FuseFileInfo): int {.importc: "fuse_fs_lseek".}
proc fuseFsInit*(fs: ptr FuseFs; conn: ptr FuseConnInfo; cfg: ptr FuseConfig) {.importc: "fuse_fs_init".}
proc fuseFsDestroy*(fs: ptr FuseFs) {.importc: "fuse_fs_destroy".}
proc fuseNotifyPoll*(ph: ptr FusePollhandle): cint {.importc: "fuse_notify_poll".}
proc fuseFsNew*(op: ptr FuseOperations; opSize: csize_t; privateData: pointer): ptr FuseFs {.importc: "fuse_fs_new".}
proc fuseGetSession*(f: ptr Fuse): ptr FuseSession {.importc: "fuse_get_session".}
proc fuseOpenChannel*(mountpoint, options: cstring): cint {.importc: "fuse_open_channel".}

{.pop.}
