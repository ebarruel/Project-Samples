#ifndef TINYFS_ERRNO_H
#define TINYFS_ERRNO_H

#define SUCCESS 0

/* this must be -1 */
#define ERR_FNOTOPEN -1

#define ERR_NOSPACE -2
#define ERR_DNOTEXIST -3

#define ERR_OPENR -4
#define ERR_OPENW -5

#define ERR_FSEEK -6
#define ERR_FREAD -7
#define ERR_FWRITE -8

#define ERR_FSTYPE -9

#define ERR_FNOTEXIST -10
#define ERR_FTOOSMALL -11
#define ERR_BADPARAM -12

#define ERR_EOF -13
#define ERR_ISDIR -14
#define ERR_ISNOTDIR -15

#define READ_ONLY_PERMISSION -16

void printErr(int err);
//char* msg does a thing

#endif /* TINYFS_ERRNO_H */