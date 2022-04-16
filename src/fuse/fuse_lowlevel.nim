import std/posix
import fuse_common, fuse_opt, fuse_wrapper
export fuse_common

const
  FuseRootId* = 1
  FuseSetAttrMode* = 1 shl 0
  FuseSetAttrUid* = 1 shl 1
  FuseSetAttrGid* = 1 shl 2
  FuseSetAttrSize* = 1 shl 3
  FuseSetAttrAtime* = 1 shl 4
  FuseSetAttrMtime* = 1 shl 5
  FuseSetAttrAtimeNow* = 1 shl 7
  FuseSetAttrMtimeNow* = 1 shl 8
  FuseSetAttrCtime* = 1 shl 10

type
  FuseIno* = uint64
  FuseReq* = pointer
  FuseSession* {.bycopy.} = object

  FuseEntryParam* {.bycopy.} = object
    ino*: FuseIno
    generation*: uint64
    attr*: Stat
    attrTimeout*: cdouble
    entryTimeout*: cdouble

  FuseCtx* {.bycopy.} = object
    uid*: Uid
    Gid*: Gid
    pid*: Pid
    umask*: Mode

  FuseForgetData* {.bycopy.} = object
    ino*: FuseIno
    nlookup*: uint64

  FuseLowlevelOps* {.bycopy.} = object
    init*: proc (userdata: pointer; conn: ptr FuseConnInfo)
    destroy*: proc (userdata: pointer)
    lookup*: proc (req: FuseReq; parent: FuseIno; name: cstring)
    forget*: proc (req: FuseReq; ino: FuseIno; nlookup: uint64)
    getattr*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo)
    setattr*: proc (req: FuseReq; ino: FuseIno; attr: ptr Stat; to_set: cint; fi: ptr FuseFileInfo)
    readlink*: proc (req: FuseReq; ino: FuseIno)
    mknod*: proc (req: FuseReq; parent: FuseIno; name: cstring; mode: Mode; rdev: Dev)
    mkdir*: proc (req: FuseReq; parent: FuseIno; name: cstring; mode: Mode)
    unlink*: proc (req: FuseReq; parent: FuseIno; name: cstring)
    rmdir*: proc (req: FuseReq; parent: FuseIno; name: cstring)
    symlink*: proc (req: FuseReq; link: cstring; parent: FuseIno; name: cstring)
    rename*: proc (req: FuseReq; parent: FuseIno; name: cstring; newparent: FuseIno; newname: cstring; flags: cuint)
    link*: proc (req: FuseReq; ino: FuseIno; newparent: FuseIno; newname: cstring)
    open*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo)
    read*: proc (req: FuseReq; ino: FuseIno; size: csize_t; offset: int; fi: ptr FuseFileInfo)
    write*: proc (req: FuseReq; ino: FuseIno; buf: cstring; size: csize_t; offset: int; fi: ptr FuseFileInfo)
    flush*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo)
    release*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo)
    fsync*: proc (req: FuseReq; ino: FuseIno; datasync: cint; fi: ptr FuseFileInfo)
    opendir*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo)
    readdir*: proc (req: FuseReq; ino: FuseIno; size: csize_t; offset: int; fi: ptr FuseFileInfo)
    releasedir*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo)
    fsyncdir*: proc (req: FuseReq; ino: FuseIno; datasync: cint; fi: ptr FuseFileInfo)
    statfs*: proc (req: FuseReq; ino: FuseIno)
    setxattr*: proc (req: FuseReq; ino: FuseIno; name: cstring; value: cstring; size: csize_t; flags: cint)
    getxattr*: proc (req: FuseReq; ino: FuseIno; name: cstring; size: csize_t)
    listxattr*: proc (req: FuseReq; ino: FuseIno; size: csize_t)
    removexattr*: proc (req: FuseReq; ino: FuseIno; name: cstring)
    access*: proc (req: FuseReq; ino: FuseIno; mask: cint)
    create*: proc (req: FuseReq; parent: FuseIno; name: cstring; mode: Mode; fi: ptr FuseFileInfo)
    getlk*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo, lock: ptr Tflock)
    setlk*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo; lock: ptr Tflock; sleep: cint)
    bmap*: proc (req: FuseReq; ino: FuseIno; blocksize: csize_t; idx: uint64)
    when fuseUseVersion < 35:
      ioctl*: proc (req: FuseReq; ino: FuseIno; cmd: cint; arg: pointer;
                     fi: ptr FuseFileInfo; flags: cuint; in_buf: pointer;
                     in_bufsz: csize_t; out_bufsz: csize_t)
    else:
      ioctl*: proc (req: FuseReq; ino: FuseIno; cmd: cuint; arg: pointer;
                     fi: ptr FuseFileInfo; flags: cuint; in_buf: pointer;
                     inBufsz: csize_t; outBufsz: csize_t)
    poll*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo; ph: ptr FusePollhandle)
    writeBuf*: proc (req: FuseReq; ino: FuseIno; bufv: ptr FuseBufvec; offset: int; fi: ptr FuseFileInfo)
    retrieveReply*: proc (req: FuseReq; cookie: pointer; ino: FuseIno; offset: int; bufv: ptr FuseBufvec)
    forgetMulti*: proc (req: FuseReq; count: csize_t; forgets: ptr FuseForgetData)
    flock*: proc (req: FuseReq; ino: FuseIno; fi: ptr FuseFileInfo; op: cint)
    fallocate*: proc (req: FuseReq; ino: FuseIno; mode: cint; offset: int; length: int; fi: ptr FuseFileInfo)
    readdirplus*: proc (req: FuseReq; ino: FuseIno; size: csize_t; offset: int; fi: ptr FuseFileInfo)
    copyFileRange*: proc (req: FuseReq; inoIn: FuseIno; offIn: int;
                          fiIn: ptr FuseFileInfo; inoOut: FuseIno;
                          offOut: int; fiOut: ptr FuseFileInfo; len: csize_t; flags: cint)
    lseek*: proc (req: FuseReq; ino: FuseIno; offset: int; whence: cint; fi: ptr FuseFileInfo)

  FuseCmdlineOpts* {.bycopy.} = object
    singlethread*: cint
    foreground*: cint
    debug*: cint
    nodefault_subtype*: cint
    mountpoint*: cstring
    show_version*: cint
    show_help*: cint
    clone_fd*: cint
    max_idle_threads*: cuint

  FuseInterruptFunc* = proc (req: FuseReq; data: pointer)

{.push dynlib: fuseLibname.}

proc fuseReplyErr*(req: FuseReq; err: cint): cint {.importc: "fuse_reply_err".}
proc fuseReplyNone*(req: FuseReq) {.importc: "fuse_reply_none".}
proc fuseReplyEntry*(req: FuseReq; e: ptr FuseEntryParam): cint {.importc: "fuse_reply_entry".}
proc fuseReplyCreate*(req: FuseReq; e: ptr FuseEntryParam; fi: ptr FuseFileInfo): cint {.importc: "fuse_reply_create".}
proc fuseReplyAttr*(req: FuseReq; attr: ptr Stat; attr_timeout: cdouble): cint {.importc: "fuse_reply_attr".}
proc fuseReplyReadlink*(req: FuseReq; link: cstring): cint {.importc: "fuse_reply_readlink".}
proc fuseReplyOpen*(req: FuseReq; fi: ptr FuseFileInfo): cint {.importc: "fuse_reply_open".}
proc fuseReplyWrite*(req: FuseReq; count: csize_t): cint {.importc: "fuse_reply_write".}
proc fuseReplyBuf*(req: FuseReq; buf: cstring; size: csize_t): cint {.importc: "fuse_reply_buf".}
proc fuseReplyData*(req: FuseReq; bufv: ptr FuseBufvec; flags: FuseBufCopyFlags): cint {.importc: "fuse_reply_data".}
proc fuseReplyIov*(req: FuseReq; iov: ptr IOvec; count: cint): cint {.importc: "fuse_reply_iov".}
proc fuseReplyStatfs*(req: FuseReq; stbuf: ptr Statvfs): cint {.importc: "fuse_reply_statfs".}
proc fuseReplyXattr*(req: FuseReq; count: csize_t): cint {.importc: "fuse_reply_xattr".}
proc fuseReplyLock*(req: FuseReq; lock: ptr Tflock): cint {.importc: "fuse_reply_lock".}
proc fuseReplyBmap*(req: FuseReq; idx: uint64): cint {.importc: "fuse_reply_bmap".}
proc fuseAddDirentry*(req: FuseReq; buf: cstring; bufsize: csize_t; name: cstring; stbuf: ptr Stat; offset: int): csize_t {.importc: "fuse_add_direntry".}
proc fuseAddDirentryPlus*(req: FuseReq; buf: cstring; bufsize: csize_t; name: cstring; e: ptr FuseEntryParam; offset: int): csize_t {.importc: "fuse_add_direntry_plus".}
proc fuseReplyIoctlRetry*(req: FuseReq; in_iov: ptr IOvec; in_count: csize_t; out_iov: ptr IOvec; out_count: csize_t): cint {.importc: "fuse_reply_ioctl_retry".}
proc fuseReplyIoctl*(req: FuseReq; result: cint; buf: pointer; size: csize_t): cint {.importc: "fuse_reply_ioctl".}
proc fuseReplyIoctlIov*(req: FuseReq; result: cint; iov: ptr IOvec; count: cint): cint {.importc: "fuse_reply_ioctl_iov".}
proc fuseReplyPoll*(req: FuseReq; revents: cuint): cint {.importc: "fuse_reply_poll".}
proc fuseReplyLseek*(req: FuseReq; offset: int): cint {.importc: "fuse_reply_lseek".}
proc fuseLowlevelNotifyPoll*(ph: ptr FusePollhandle): cint {.importc: "fuse_lowlevel_notify_poll".}
proc fuseLowlevelNotifyInvalInode*(se: ptr FuseSession; ino: FuseIno; offset: int; len: int): cint {.importc: "fuse_lowlevel_notify_inval_inode".}
proc fuseLowlevelNotifyInvalEntry*(se: ptr FuseSession; parent: FuseIno; name: cstring; namelen: csize_t): cint {.importc: "fuse_lowlevel_notify_inval_entry".}
proc fuseLowlevelNotifyDelete*(se: ptr FuseSession; parent: FuseIno; child: FuseIno; name: cstring; namelen: csize_t): cint {.importc: "fuse_lowlevel_notify_delete".}
proc fuseLowlevelNotifyStore*(se: ptr FuseSession; ino: FuseIno; offset: int; bufv: ptr FuseBufvec; flags: FuseBufCopyFlags): cint {.importc: "fuse_lowlevel_notify_store".}
proc fuseLowlevelNotifyRetrieve*(se: ptr FuseSession; ino: FuseIno; size: csize_t; offset: int; cookie: pointer): cint {.importc: "fuse_lowlevel_notify_retrieve".}
proc fuseReqUserdata*(req: FuseReq): pointer {.importc: "fuse_req_userdata".}
proc fuseReqCtx*(req: FuseReq): ptr FuseCtx {.importc: "fuse_req_ctx".}
proc fuseReqGetgroups*(req: FuseReq; size: cint; list: ptr Gid): cint {.importc: "fuse_req_getgroups".}
proc fuseReqInterruptFunc*(req: FuseReq; `func`: FuseInterruptFunc; data: pointer) {.importc: "fuse_req_interrupt_func".}
proc fuseReqInterrupted*(req: FuseReq): cint {.importc: "fuse_req_interrupted".}
proc fuseLowlevelVersion*() {.importc: "fuse_lowlevel_version".}
proc fuseLowlevelHelp*() {.importc: "fuse_lowlevel_help".}
proc fuseCmdlineHelp*() {.importc: "fuse_cmdline_help".}
proc fuseParseCmdline*(args: ptr FuseArgs; opts: ptr FuseCmdlineOpts): cint {.importc: "fuse_parse_cmdline".}
proc fuseSessionNew*(args: ptr FuseArgs; op: ptr FuseLowlevelOps; op_size: csize_t; userdata: pointer): ptr FuseSession {.importc: "fuse_session_new".}
proc fuseSessionMount*(se: ptr FuseSession; mountpoint: cstring): cint {.importc: "fuse_session_mount".}
proc fuseSessionLoop*(se: ptr FuseSession): cint {.importc: "fuse_session_loop".}
when fuseUseVersion < 32:
  proc fuseSessionLoopMt31*(se: ptr FuseSession; clone_fd: cint): cint {.importc: "fuse_session_loop_mt_31".}
  template FuseSessionLoopMt*(se, clone_fd: untyped): untyped =
    FuseSessionLoopMt31(se, clone_fd)
else:
  when (not defined(UCLIBC) and not defined(APPLE)):
    proc fuseSessionLoopMt*(se: ptr FuseSession; config: ptr FuseLoopConfig): cint {.importc: "fuse_session_loop_mt".}
  else:
    proc fuseSessionLoopMt32*(se: ptr FuseSession; config: ptr FuseLoopConfig): cint {.importc: "fuse_session_loop_mt_32".}
    template FuseSessionLoopMt*(se, config: untyped): untyped =
      FuseSessionLoopMt32(se, config)
proc fuseSessionExit*(se: ptr FuseSession) {.importc: "fuse_session_exit".}
proc fuseSessionReset*(se: ptr FuseSession) {.importc: "fuse_session_reset".}
proc fuseSessionExited*(se: ptr FuseSession): cint {.importc: "fuse_session_exited".}
proc fuseSessionUnmount*(se: ptr FuseSession) {.importc: "fuse_session_unmount".}
proc fuseSessionDestroy*(se: ptr FuseSession) {.importc: "fuse_session_destroy".}
proc fuseSessionFd*(se: ptr FuseSession): cint {.importc: "fuse_session_fd".}
proc fuseSessionProcessBuf*(se: ptr FuseSession; buf: ptr FuseBuf) {.importc: "fuse_session_process_buf".}
proc fuseSessionReceiveBuf*(se: ptr FuseSession; buf: ptr FuseBuf): cint {.importc: "fuse_session_receive_buf".}

{.pop.}
