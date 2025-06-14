#ifndef moonbit_h_INCLUDED
#include "moonbit.h"
typedef int32_t Bool;
#endif

#if defined (_WIN32) || defined (_WIN64)
#else
#pragma clang diagnostic ignored "-Wpointer-sign"
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#endif

#if defined (_WIN32) || defined (_WIN64)
MOONBIT_EXPORT Bool moonbit_os_iswin32() {
    return true;
}
#else
MOONBIT_EXPORT Bool moonbit_os_iswin32() {
    return false;
}
#endif

// Errno related functions
#if defined (_WIN32) || defined (_WIN64)
#else
MOONBIT_EXPORT int32_t moonbit_errno_is_interrupted() {
    return EINTR == errno;
}

MOONBIT_EXPORT moonbit_bytes_t moonbit_errno_get_errmsg() {
    const char* err_msg = strerror(errno);
    int32_t len = strlen(err_msg);
    moonbit_bytes_t err_msg_ret = moonbit_make_bytes(len, 0);
    memcpy(err_msg_ret, err_msg, len);
    return err_msg_ret;
}
#endif 

// FileSystem related functions
#if defined (_WIN32) || defined (_WIN64)
#else

#define FILE int32_t

MOONBIT_EXPORT Bool moonbit_file_is_invalid(FILE file) {
    return -1 == file;
}

MOONBIT_EXPORT FILE moonbit_file_open(moonbit_bytes_t filename) {
    return open(filename, O_RDONLY);
}

MOONBIT_EXPORT FILE moonbit_file_create(moonbit_bytes_t filename) {
    return open(filename, O_WRONLY);
}

// use ArrayView[Byte]
MOONBIT_EXPORT int32_t moonbit_file_read(FILE file, struct moonbit_view_t view, int32_t n) {
    // assert count < view.len
    return read(file, (view.buf + view.start), n);
}

// use ArrayView[Byte]
MOONBIT_EXPORT int32_t moonbit_file_write(FILE file, struct moonbit_view_t view, int32_t n) {
    return write(file, (view.buf + view.start), n);
}

MOONBIT_EXPORT Bool moonbit_file_close(FILE file) {
    return close(file) != -1;
}

typedef struct stat* FILE_STAT;


MOONBIT_EXPORT FILE_STAT moonbit_file_metadata_new() {
    return malloc(sizeof(FILE_STAT));
}

// TODO: use `statx` on Linux if
// defined (LINUX_VERSION_CODE) && defined (__GLIBC__) && LINUX_VERSION_CODE >= KERNEL_VERSION(4, 11, 0) && __GLIBC__ >= 2 && __GLIBC_MINOR__ >= 28
MOONBIT_EXPORT int32_t moonbit_file_metadata(FILE file, FILE_STAT stat) {
    return fstat(file, stat);
}

MOONBIT_EXPORT int32_t moonbit_file_symlink_metadata(moonbit_bytes_t file, FILE_STAT stat) {
    return lstat(file, stat);
}

MOONBIT_EXPORT int32_t moonbit_file_metadata_filesize(FILE_STAT stat) {
    return stat->st_blksize;
}

typedef mode_t FILE_TYPE;

MOONBIT_EXPORT FILE_TYPE moonbit_file_metadata_filetype(FILE_STAT stat) {
    return stat->st_mode;
}

MOONBIT_EXPORT FILE_TYPE moonbit_metadata_filetype_mask(FILE_TYPE filetype) {
    return (filetype & S_IFMT);
}

MOONBIT_EXPORT int32_t moonbit_metadata_filetype_is_dir(FILE_TYPE filetype) {
    return (moonbit_metadata_filetype_mask(filetype) == S_IFDIR);
}

MOONBIT_EXPORT int32_t moonbit_metadata_filetype_is_file(FILE_TYPE filetype) {
    return (moonbit_metadata_filetype_mask(filetype) == S_IFREG);
}

MOONBIT_EXPORT int32_t moonbit_metadata_filetype_is_symlink(FILE_TYPE filetype) {
    return (moonbit_metadata_filetype_mask(filetype) == S_IFLNK);
}

typedef mode_t FILE_PERMISSIONS;

MOONBIT_EXPORT FILE_PERMISSIONS moonbit_file_metadata_permissions(FILE_STAT stat) {
    return stat->st_mode;
}

MOONBIT_EXPORT int32_t moonbit_metadata_permissions_readonly(FILE_PERMISSIONS perm) {
    // 0o222 = (2 × 8^2) + (2 × 8^1) + (2 × 8^0) = 128 + 16 + 2 = 146
    return (perm & 146) == 0;
}

#endif