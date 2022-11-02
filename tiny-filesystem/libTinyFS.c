#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>

#include "libTinyFS.h"
#include "libDisk.h"
#include "TinyFS_errno.h"
#include "linkedList.h"
#include "util.h"

/* globals */
int disk = -1;
ListNode *files = NULL;

Superblock superblock_init() {
	Superblock sb;
	memset(&sb, 0, BLOCKSIZE);
	sb.type = TYPE_SUPER;
	sb.magic = MAGIC_NUM;
  return sb;
}

Inode inode_init(unsigned char *filename, byte parent) {
	Inode inode;
	memset(&inode, 0, BLOCKSIZE);
	inode.type = TYPE_INODE;
	inode.magic = MAGIC_NUM;
	inode.parent = parent;
	memcpy(inode.file, filename, MAX_NAME_LEN);
  inode.creationTime = getTime(); //init all times here
  inode.accessTime = inode.creationTime; 
  inode.modificationTime = inode.creationTime;
  inode.writePermission = true; 
	return inode;
}

FileExtent FileExtent_init(int inodeAddr) {
	FileExtent fe;
	memset(&fe, 0, BLOCKSIZE);
	fe.type = TYPE_FILE;
	fe.magic = MAGIC_NUM;
	fe.inode = inodeAddr;
	return fe;
}

Freeblock freeblock_init() {
	Freeblock fb;
	memset(&fb, 0, BLOCKSIZE);
	fb.type = TYPE_FREE;
	fb.magic = MAGIC_NUM;
	return fb;
}

/* looks up a file on the disk by the file names
 * returns the inode (aka fd) if found or an error code if not
 */
fileDescriptor lookupFile(char *file) {
  Inode root, inode;
  int err = SUCCESS, i = 0;

  /* get root inode */
  if ((err = readBlock(disk, 1, &root)) < 0)
    return err;

  /* loop through all inodes under root */
  for (i = 0; root.content[i]; i++) {
    /* check file name in inode */
    if ((err = readBlock(disk,root.content[i], &inode)) < 0) {
      return err;
    }
    if (!strncmp((char *) inode.file, file, MAX_NAME_LEN)) {
      return root.content[i];
    }
  }
  
  return ERR_FNOTEXIST;
}

/* checks whether a file name is within the specifications
 * file name must be at most 8 characters and alphanumerical
 * returns 0 if okay and -1 if not
 */
int checkFName(char *filename) {
  int len = 0, i = 0;
  /* check length */
  if ((len = strlen(filename)) > MAX_NAME_LEN)
    return -1;
    /* check if all characters are alphanumerical */
  for (; i < len; i++) {
    if (!isalnum(filename[i]))
      return -1;
  }
  return 0;
}



/* Makes a blank TinyFS file system of size nBytes on the file specified by ‘filename’. This function should use the emulated disk library to open the specified file, and upon success, format the file to be mountable. This includes initializing all data to 0x00, setting magic numbers, initializing and writing the superblock and inodes, etc. Must return a specified success/error code. */
int tfs_mkfs(char *filename, int nBytes) {
	int diskNum, totalBlocks = nBytes / BLOCKSIZE, i;
	Superblock sb = superblock_init();
	sb.nextFree = 2;
  sb.size = totalBlocks;
	sb.root = 1;
	Inode rootNode = inode_init((unsigned char *)"/", 1);
	rootNode.fileSize = -1;
	Freeblock fb = freeblock_init();

	// check nBytes
	if ((nBytes % 256 != 0) || (nBytes > MAX_DISK_SIZE) || (nBytes < MIN_DISK_SIZE)) {
		return ERR_BADPARAM;
	}

	diskNum = openDisk(filename, nBytes);

	// add superblock
	writeBlock(diskNum, 0, &sb);

	// add dir inode
	writeBlock(diskNum, 1, &rootNode);

	// add file extend till its nBytes long
	for (i = 2; i < totalBlocks; i++) {
		if (i + 1 < nBytes) {
			fb.nextFree = i + 1;
		}
		writeBlock(diskNum, i, &fb);
	}

  disk = diskNum;
  closeDisk(diskNum);
	return SUCCESS;
}

/* tfs_mount(char *filename) “mounts” a TinyFS file system located within ‘filename’. tfs_unmount(void) “unmounts” the currently mounted file system. As part of the mount operation, tfs_mount should verify the file system is the correct type. Only one file system may be mounted at a time. Use tfs_unmount to cleanly unmount the currently mounted file system. Must return a specified success/error code. */
int tfs_mount(char *filename) {
  Superblock super;
  int size = 0;

  /* open disk for reading */
  if ((disk = openDisk(filename, size)) < 0) {
    printf("Disk\n");
    return disk;
  }
  /* get size of disk from superblock */
  if ((size = readBlock(disk, 0, &super)) < 0) {
    printf("Size\n");
    return size;
  }
  size = super.size;
  /* close disk */
  closeDisk(disk);
  /* open disk for writing with size of disk */
  if ((disk = openDisk(filename, size*BLOCKSIZE)) < 0) {
    printf("Second Disk\n");
    return disk;
  }
  /* check type (magic number) of file system */
  if (super.magic != MAGIC_NUM) {
    printf("Type\n");
    return ERR_FSTYPE;
  }
  return SUCCESS;
}

int tfs_unmount(void) {
  ListNode *current = files;
  int err = 0;

  /* close all files */
  while (current) {
    if ((err = tfs_closeFile(current->fd)) < 0) {
      return err;
    }
    current = current->next;
  }
  /* close disk */
  closeDisk(disk);
  /* reset global variables (only disk because files should be closed) */
  disk = -1;

  return SUCCESS;
}

/* Opens a file for reading and writing on the currently mounted file system. Creates a dynamic resource table entry for the file, and returns a file descriptor (integer) that can be used to reference this file while the filesystem is mounted. */
fileDescriptor tfs_openFile(char *name) {
	/* file descriptor is just going to be inode address */
	int err, i;
	fileDescriptor fd;
	Superblock sb;
	Freeblock fb;
  Inode root, inode;

  /* check if file name is okay */
  if (checkFName(name) < 0)
    return ERR_BADPARAM;

  /* check if file exists on system */
  if ((fd = lookupFile(name)) >= 0) {
    /* add file to list of open files */
    files = addHead(files, disk, fd, 0, TYPE_INODE);
    /* return inode as fd */
    return fd;
  }

	/* 1 is passed in for root node (which is the parent node) */
	inode = inode_init((unsigned char *)name, 1);

  /* read superblock to get next free */
	if ((err = readBlock(disk, 0, &sb)) < 0) {
		return err;
	}
	fd = sb.nextFree;
  /* edit root inode to add new child */
  if ((err = readBlock(disk, 1, &root)) < 0) {
    return err;
  }
  for (i = 0; root.content[i]; i++);
  root.content[i] = fd;
  
  if ((err = writeBlock(disk, 1, &root)) < 0) {
    return err;
  }
  /* now edit new file inode */
	if ((err = readBlock(disk, fd, &fb)) < 0) {
		return err;
	}
	if ((err = writeBlock(disk, fd, &inode)) < 0) {
		return err;
	}
	sb.nextFree = fb.nextFree;
	if ((err = writeBlock(disk, 0, &sb)) < 0) {
		return err;
	}

	files = addHead(files, disk, fd, 0, TYPE_INODE);

	return fd;
}

/* Closes the file, de-allocates all system/disk resources, and removes table entry */
int tfs_closeFile(fileDescriptor FD) {
	int idx;
	ListNode *node;

	if ((idx = lookupList(files, FD, &node)) == -1) {
		return ERR_FNOTEXIST;
	}

	files = deleteNode(files, idx);
	return SUCCESS;
}

/* Writes buffer ‘buffer’ of size ‘size’, which represents an entire file’s contents, to the file system. Sets the file pointer to 0 (the start of file) when done. Returns success/error codes. */
int tfs_writeFile(fileDescriptor FD, char *buffer, int size) {
  int err = 0;
	int bytesWritten = 0;
	int fileBlock = 0;
  ListNode *node;
  Inode inode;
  FileExtent fe = FileExtent_init(FD);
  Superblock super;
  Freeblock fb = freeblock_init();

  /* check if file is open/inode type (filesize != -1) */
  if ((err = lookupList(files, FD, &node)) < 0) {
    return ERR_FNOTOPEN;
  }
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
	}
  if (inode.fileSize == -1) {
		return ERR_ISDIR;
	}
  //check if read only 
  if (inode.writePermission == false){
    printf("This file cannot be written to, it is read only\n");
    return READ_ONLY_PERMISSION;
  }
	
  /* if file contains data (filesize > 0) */
  for (bytesWritten = 0; bytesWritten < size && bytesWritten < inode.fileSize; bytesWritten += MIN(BLOCKINBYTES, size - bytesWritten)) {
    /* overwrite current blocks */
		if ((err = readBlock(disk, inode.content[fileBlock], &fe)) < 0) {
    	return err;
		}
		memcpy(fe.data, buffer + bytesWritten, MIN(BLOCKINBYTES, size - bytesWritten));
		if ((err = writeBlock(disk, inode.content[fileBlock], &fe)) < 0) {
			return err;
		}
		fileBlock += 1;
  }
	/* extra blocks, free them */
	if (bytesWritten == size && size < inode.fileSize) {
		byte curr = inode.content[fileBlock];
		byte next = fe.nextData;
		fe.nextData = 0;
		if ((err = writeBlock(disk, curr, &fe))) {
			return err;
		}
		while (fe.nextData != 0) {
			if ((err = readBlock(disk, next, &fe))) {
				return err;
			}
			if ((err = writeBlock(disk, curr, &fb))) {
				return err;
			}
			curr = next;
			next = fe.nextData;
		}
	}
  /* if more in buffer (size > filesize) */
  else if (bytesWritten < size && size > inode.fileSize) {
    /* add more free blocks from free chain */
    for (; bytesWritten < size; bytesWritten += MIN(BLOCKINBYTES, size - bytesWritten)) {
      /* get next free from superblock */
      if ((err = readBlock(disk, 0, &super)) < 0) {
        return err;
      }
      fileBlock = super.nextFree;
      /* edit file extent block */
      if ((err = readBlock(disk, fileBlock, &fb)) < 0) {
        return err;
      }
      // checks to see if last block in file
      if (bytesWritten <= size && bytesWritten > size - BLOCKINBYTES)
        fe.nextData = 0;
      else
        fe.nextData = fb.nextFree;
      memcpy(fe.data, buffer + bytesWritten, MIN(BLOCKINBYTES, size - bytesWritten));
      /* edit inode to include file extent block */
      inode.content[bytesWritten / BLOCKINBYTES] = fileBlock;
      /* edit superblock for next free */
      super.nextFree = fb.nextFree;
      /* write file extent block to next free block */
      if ((err = writeBlock(disk, fileBlock, &fe)) < 0) {
        return err;
      }
      /* write inode block */
      if ((err = writeBlock(disk, FD, &inode)) < 0) {
        return err;
      }
      /* write superblock */
      if ((err = writeBlock(disk, FD, &super)) < 0) {
        return err;
      }
    }
  }

  node->seek = (fileBlock * BLOCKSIZE) + 5;
  /* edit inode filesize */
  inode.fileSize = size;
  inode.accessTime = getTime();
  inode.modificationTime = getTime();
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
    
  return SUCCESS;
}

/* deletes a file and marks its blocks as free on disk. */
int tfs_deleteFile(fileDescriptor FD) {
  Superblock super;
  Inode inode;
  FileExtent ext;
  Freeblock free = freeblock_init();
  ListNode *file;
  int err = 0, idx = lookupList(files, FD, &file), i = 0;
  byte prev = 0;

  /* check that file exists */
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  if (inode.type != TYPE_INODE) {
    return ERR_FNOTEXIST;
  }
  //check if file is read only
  if (inode.writePermission == false){
    printf("This file cannot be deleted, it is read only\n");
    return READ_ONLY_PERMISSION;
  }

	/* save superblock's old nextFree */
  if ((err = readBlock(disk, 0, &super)) < 0) {
    return err;
  }
  prev = super.nextFree;

  /* set superblock's nextFree to beginning of chain-to-free (inode) */
  super.nextFree = FD;
  if ((err = writeBlock(disk, 0, &super)) < 0) {
    return err;
  }

  /* iterate through chain-to-free to change type (not inode) */
  for (i = 0; inode.content[i]; i++) {
    if ((err = readBlock(disk, inode.content[i], &ext)) < 0) {
      return err;
    }

    /* set free block's next to next data or superblock's old next free if eof */
    if (ext.nextData)
      free.nextFree = ext.nextData;
    else
      free.nextFree = prev;

    if ((err = writeBlock(disk, inode.content[i], &free)) < 0) {
      return err;
    }
  }

  /* change inode block to free block */
  free.nextFree = inode.content[0];
  if ((err = writeBlock(disk, FD, &free)) < 0) {
    return err;
  }

  /* remove file from list if exists */
  if (!(idx < 0))
    deleteNode(files, idx);

  return SUCCESS;
}

/* reads one byte from the file and copies it to buffer, using the current file pointer location and incrementing it by one upon success. If the file pointer is already at the end of the file then tfs_readByte() should return an error and not increment the file pointer. */
int tfs_readByte(fileDescriptor FD, char *buffer)
{
  ListNode* node;
  Inode inode;
  int offset, err;
  char buff[BLOCKSIZE];

    
  /* check if file is open */
  if (lookupList(files, FD, &node) == -1)
    return ERR_FNOTOPEN;
  // Get inode for this data
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  /* File pointer is at node->seek */
  /* Make sure node->seek isn't at the end of the file */
  /* Get offset from start of file and compare to filesize */
  offset = node->seek - (inode.content[0] * BLOCKSIZE);
  if (offset >= inode.fileSize + 5)
    return ERR_EOF;
  /* If not read block of file and then get char at the offset */
  if ((err = readBlock(disk, inode.content[0], buff)) < 0) {
    return err;
  }
  *buffer = buff[offset];
  /* Increment node->seek */
  node->seek = node->seek + 1;
  inode.accessTime = getTime();
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  return SUCCESS;
}

/* change the file pointer location to offset (absolute). Returns success/error codes.*/
int tfs_seek(fileDescriptor FD, int offset) {
	ListNode *node;
  Inode inode;
  int err = 0;

  lookupList(files, FD, &node);
  /* calculate absolute offset on disk */
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
	if (offset > inode.fileSize) {
		return ERR_FTOOSMALL;
    /* calculate how many more blocks needed */
    /* add blocks (fill with 0) */
    /* set seek */
	}
  node->seek = (inode.content[offset / BLOCKINBYTES]) * BLOCKSIZE;
  node->seek += (BLOCKSIZE - BLOCKINBYTES) + (offset % BLOCKINBYTES);
  inode.accessTime = getTime();
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  return SUCCESS;
}

//returns local time in a string 
char* getTime(){ 
  time_t time1;
  struct tm *info;
  char * localT = calloc(30, sizeof(char));
  time(&time1);
  info = localtime(&time1);
  strcpy(localT, asctime(info));
  //printf("hello time: %s\n", localT);
  return localT;
}

/*prints out the timestamps for a specific inode*/
int tfs_readFileInfo(fileDescriptor FD){
  int err = 0;
  Inode inode;
  char filename[8];

  /* check that file exists and looks like it assigns inode */
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  if (inode.type != TYPE_INODE) {
    return ERR_FNOTEXIST;
  }

  memcpy(filename, inode.file, MAX_NAME_LEN);

  printf("File name: %s\n", filename);
  printf("Creation Time: %s", inode.creationTime);
  printf("Last Accessed: %s", inode.accessTime);
  printf("Last Modified: %s", inode.modificationTime);

  inode.accessTime = getTime();
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  return SUCCESS;
}

/* could realloc the old file and use new name to get it
probably change the passed in parameters to include oldname and newname  */ 
int tfs_rename(int fd, char* newName) {
  int err = 0;
  Inode inode;

  if ((err = readBlock(disk, fd, &inode)) < 0) {
    return err;
  }
  if (inode.type != TYPE_INODE) {
    return ERR_FNOTEXIST;
  }

  memset(inode.file, 0, 8);
  memcpy(inode.file, newName, 8);

  if ((err = writeBlock(disk, fd, &inode)) < 0)
  {
    return err;
  }

  inode.accessTime = getTime();
  inode.modificationTime = getTime();
  if ((err = writeBlock(disk, fd, &inode)) < 0) {
    return err;
  }
  return SUCCESS;
}

/* parse through all files and print out their names */
int tfs_readdir() {
  ListNode* current = files;
  Inode inode;

  printf("Files in directory:\n");
  while (current)
  {
    readBlock(disk, current->fd, &inode);
    printf("\t%s\n", inode.file);
    current = current->next;
  }

  return SUCCESS;
}

/*parses through the linked list to find the filename and outputs that files FD*/
int parseNodes(char *filename){
  int err = 0;
  ListNode* current = files;
  Inode inode;

  //parse through all inodes and compares the names, if name matches return the FD 
  while (current) {
    //if there is nothing there just continue and mve past that block 
    if ((err = readBlock(disk, current->fd, &inode)) < 0) {
      continue;
    }
    if (memcmp(inode.file, filename, MAX_NAME_LEN) == 0){
      return current->fd;
    }
    current = current -> next;
  }

  return err;
}

/*makes files RO, all tfs_write and tfs_deleteFile will not work
takes in file name, parses through all files, then makes that file RO*/
int tfs_makeRO(char *name){
  int err = 0;
  Inode inode;
 // char filename[8];
  int FD = parseNodes(name);

  if(FD < 0) {
    printf("There is no file with that name\n");
    return err; 
  }

  /* check that file exists and looks like it assigns inode */
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  if (inode.type != TYPE_INODE) {
    return ERR_FNOTEXIST;
  }

  inode.writePermission = false;

  inode.accessTime = getTime();
  inode.modificationTime = getTime();
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  return SUCCESS;
}

/*makes files RW, reenables the ability to delete and write*/
int tfs_makeRW(char *name){
  int err = 0;
  Inode inode;
 // char filename[8];
  //replace checknames with something else that parses through the linked list
  int FD = parseNodes(name);

  if(FD < 0) {
    printf("There is no file with that name\n");
    return err; 
  }

  /* check that file exists and looks like it assigns inode */
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  if (inode.type != TYPE_INODE) {
    return ERR_FNOTEXIST;
  }

  inode.writePermission = true;

  inode.accessTime = getTime();
  inode.modificationTime = getTime();
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  return SUCCESS;
}

/*writes byte to an exact position based on offset, can do variation that uses the pointer instead of the offset*/
int tfs_writeByte(fileDescriptor FD, int offset, unsigned char data) {
  Inode inode;
  int err = 0, block = 0;
  unsigned char buff[BLOCKSIZE];
  char* timer = getTime();
    
  /* calculate absolute offset on disk */
  if ((err = readBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  /* check to see if file has write permissions */
  if (inode.writePermission == false){
    printf("This file is read only\n");
    return READ_ONLY_PERMISSION;
  }
  /* make sure file is big enough */
  if (offset > inode.fileSize) {
		return ERR_FTOOSMALL;
	}
  /* Get which block of the file it is */
  block = offset / BLOCKSIZE;
  /* Get block of code of the file currently */
  if ((err = readBlock(disk, inode.content[block], buff)) < 0) {
    return err;
  }
  /* modify the right byte */
  offset = (offset % BLOCKSIZE) + 5;
  buff[offset] = data;
  /* Right block back to file system */
  if ((err = writeBlock(disk, inode.content[block], buff)) < 0) {
    return err;
  }

  inode.accessTime = timer;
  inode.modificationTime = timer;
  if ((err = writeBlock(disk, FD, &inode)) < 0) {
    return err;
  }
  /* Modify times */
  return SUCCESS;
} 