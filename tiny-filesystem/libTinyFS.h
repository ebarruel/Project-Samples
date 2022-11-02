#ifndef LIBTINYFS_H
#define LIBTINYFS_H

#include <stdint.h>
#include <time.h>

typedef uint8_t byte;
typedef enum {false, true} bool;
/* The default size of the disk and file system block */
#define BLOCKSIZE 256 /* in bytes */
#define MIN_BLOCKS 10
#define MAX_BLOCKS 255

/* Your program should use a 10240 Byte disk size giving you 40 blocks total. This is the default size. You must be able to support different possible values */
#define DEFAULT_DISK_SIZE 10240
#define MIN_DISK_SIZE (BLOCKSIZE * MIN_BLOCKS)
#define MAX_DISK_SIZE (BLOCKSIZE * MAX_BLOCKS)

/* use this name for a default disk file name */
#define DEFAULT_DISK_NAME “tinyFSDisk”     
typedef int fileDescriptor;

/* block related macros */
#define MAGIC_NUM 0x45
#define MAX_NAME_LEN 8


/* Makes a blank TinyFS file system of size nBytes on the file specified by ‘filename’. This function should use the emulated disk library to open the specified file, and upon success, format the file to be mountable. This includes initializing all data to 0x00, setting magic numbers, initializing and writing the superblock and inodes, etc. Must return a specified success/error code. */
int tfs_mkfs(char *filename, int nBytes);

/* tfs_mount(char *filename) “mounts” a TinyFS file system located within ‘filename’. tfs_unmount(void) “unmounts” the currently mounted file system. As part of the mount operation, tfs_mount should verify the file system is the correct type. Only one file system may be mounted at a time. Use tfs_unmount to cleanly unmount the currently mounted file system. Must return a specified success/error code. */
int tfs_mount(char *filename);
int tfs_unmount(void);

/* Opens a file for reading and writing on the currently mounted file system. Creates a dynamic resource table entry for the file, and returns a file descriptor (integer) that can be used to reference this file while the filesystem is mounted. */
fileDescriptor tfs_openFile(char *name);

/* Closes the file, de-allocates all system/disk resources, and removes table entry */
int tfs_closeFile(fileDescriptor FD);

/* Writes buffer ‘buffer’ of size ‘size’, which represents an entire file’s contents, to the file system. Sets the file pointer to 0 (the start of file) when done. Returns success/error codes. */
int tfs_writeFile(fileDescriptor FD, char *buffer, int size);

/* deletes a file and marks its blocks as free on disk. */
int tfs_deleteFile(fileDescriptor FD);

/* reads one byte from the file and copies it to buffer, using the current file pointer location and incrementing it by one upon success. If the file pointer is already at the end of the file then tfs_readByte() should return an error and not increment the file pointer. */
int tfs_readByte(fileDescriptor FD, char *buffer);

/* change the file pointer location to offset (absolute). Returns success/error codes.*/
int tfs_seek(fileDescriptor FD, int offset);



//additonal features starts here,,,,,, setting all to int as placeholder

/*timestamps
need creation, modification, and access timestamps for each file in inode block*/

/*returns the time as a string so it can be easily printed
also turns the time to "local time" so it is easier to read*/
char * getTime();

/*returns the creation, access, and mod times  or just the creation time 
return format is up to us, going to try to get it to return "local time"*/
int tfs_readFileInfo(fileDescriptor FD);


/*renaming and directory listing*/

/*renames a file, 
said to pass in the name; possibly (char *oldname, char *newname)*/
int tfs_rename();

/*lists all files and directories on the disk 
doesn't matter where called from, should be the same 
possibly treated like a DFS as we'll likely need to start from the town and work way down through each dir */
int tfs_readdir();


/*read and write bytes, makes files able to be read only 
default should be WR,*/

/*something to parse through the linked list and output the FD*/
int parseNodes(char *filename);

/*makes files RO, all tfs_write and tfs_deleteFile will not work*/
int tfs_makeRO(char *name);

/*makes files RW, reenables the ability to delete and write*/
int tfs_makeRW(char *name);

/*writes to a specific byte, either based on offset or pointer
if pointer based (fileDescriptor FD, unsigned char data), so offset not required*/
int tfs_writeByte(fileDescriptor FD, int offset, unsigned char data);

#define BLOCK_FREE 1
#define BLOCK_USED (~BLOCK_FREE)

typedef struct __attribute__((packed)) {
  byte type;
  byte magic;
  byte nextAddr;
  byte empty;
  byte data[BLOCKSIZE-(4*sizeof(byte))];
} Block;

typedef struct __attribute__((packed)) {
  byte type;
  byte magic;
  byte nextFree;              // points to the next free block
  byte empty;
  byte size;
  byte root;
  byte free[BLOCKSIZE - (6*sizeof(byte))];
} Superblock;
#define TYPE_SUPER 1

typedef struct __attribute__((packed)) {
  byte type;
  byte magic;
  byte parent;                                // parent directory
  byte empty;
  unsigned char file[MAX_NAME_LEN];
  unsigned int fileSize;                      // in bytes, will be -1 if directory
  char* creationTime;  //strings so easier to rint in tfs_readFileInfo 
  char* accessTime;
  char* modificationTime;
  bool writePermission;
  byte content[BLOCKSIZE - (4*sizeof(byte) + (MAX_NAME_LEN)*sizeof(unsigned char) + sizeof(unsigned int) + 3*sizeof(char*) + sizeof(bool))];
} Inode;
#define TYPE_INODE 2

#define BLOCKINBYTES (BLOCKSIZE - 5*sizeof(byte))
typedef struct __attribute__((packed)) {
  byte type;
  byte magic;
  byte nextData;
  byte empty;
  byte inode;
  uint8_t data[BLOCKINBYTES];
} FileExtent;
#define TYPE_FILE 3

typedef struct __attribute__((packed)) {
  byte type;
  byte magic;
  byte nextFree;
  byte empty;
  byte free[BLOCKSIZE-(4*sizeof(byte))];
} Freeblock;
#define TYPE_FREE 4

#endif /* LIBTINYFS_H */