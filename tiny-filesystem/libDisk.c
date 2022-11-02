#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "libDisk.h"
#include "libTinyFS.h"
#include "TinyFS_errno.h"

static int diskCount = 0;
static Disk allDisks[maxDisk] = {{.diskNum=-1,.fd=-1, .fp=NULL}, 
																	{.diskNum=-1,.fd=-1, .fp=NULL}, 
																	{.diskNum=-1,.fd=-1, .fp=NULL}, 
																	{.diskNum=-1,.fd=-1, .fp=NULL},
																	{.diskNum=-1,.fd=-1, .fp=NULL},
																	{.diskNum=-1,.fd=-1, .fp=NULL},
																	{.diskNum=-1,.fd=-1, .fp=NULL},
																	{.diskNum=-1,.fd=-1, .fp=NULL},
																	{.diskNum=-1,.fd=-1, .fp=NULL},
																	{.diskNum=-1,.fd=-1, .fp=NULL}};


int findOpenDiskSpace() {
  /* return -1 if no open space is found */
	int i;
	for (i = 0; i < maxDisk; i++) {
		if (allDisks[i].diskNum == -1) {
			return i;
		}
	}
	return -1;
}

/* returns index into allDisks if disk is opened
 * returns -1 if not found
 */
int lookupDisk(int diskNum) {
  int i;
  for (i = 0; i < maxDisk; i++) {
    if (allDisks[i].diskNum == diskNum) {
      return i;
    }
  }
  return -1;
}

int checkNames(char* filename)
{
  int i;
  for (i = 0; i < maxDisk; i++)
  {
    if (strcmp(filename, allDisks[i].fileName) == 0)
      return i;
  }
  return -1;
}

/* This functions opens a regular UNIX file and designates the first nBytes of it as space for the emulated disk. nBytes should be a number that is evenly divisible by the block size. If nBytes > 0 and there is already a file by the given filename, that disk is resized to nBytes, and that file’s contents may be overwritten. If nBytes is 0, an existing disk is opened, and should not be overwritten. There is no requirement to maintain integrity of any content beyond nBytes. The return value is -1 on failure or a disk number on success. */
int openDisk(char *filename, int nBytes) {
	FILE *disk;
  int diskNum = diskCount, fd, diskSpace;

  diskCount += 1;
	if (nBytes == 0) {
    // if ((fd = open(filename, O_CREAT)) < 0) {
    //   perror(filename);
    //   return ERR_OPENW;
    // }
    // if (close(fd) < 0) {
    //   perror(filename);
    //   return ERR_EOF;
    // }
		if ((disk = fopen(filename, "r"))) {
			if ((diskSpace = findOpenDiskSpace()) != -1) {
				allDisks[diskSpace].diskNum = diskNum;
				allDisks[diskSpace].fd = fileno(disk);
				allDisks[diskSpace].fp = disk;
				return diskNum;
			}
    }
    perror(filename);
    return ERR_FNOTEXIST;
	}
  else {
		if ((disk = fopen(filename, "rw+"))) {
      fd = fileno(disk);
			if (ftruncate(fd, nBytes) != -1) {
				if ((diskSpace = findOpenDiskSpace()) != -1) {
					allDisks[diskSpace].diskNum = diskNum;
					allDisks[diskSpace].fd = fd;
          allDisks[diskSpace].fp = disk;
          allDisks[diskSpace].numBlocks = nBytes / BLOCKSIZE;
					return diskNum;
				}
			}
		}
    perror(filename);
    return ERR_OPENW;
	}
}
/*
int openDisk(char *filename, int nBytes) {
	FILE *disk;
  int diskSpace;
  int i;

	if (nBytes > 0) {
		if ((i = checkNames(filename)) != -1)
    {
      allDisks[i].numBlocks = nBytes / BLOCKSIZE;
      return allDisks[i].diskNum;
    }
    if ((disk = fopen(filename, "w+"))) {
			if ((diskSpace = findOpenDiskSpace()) != -1) {
        strcpy(allDisks[diskSpace].fileName, filename);
        allDisks[diskSpace].numBlocks = nBytes / BLOCKSIZE;
				allDisks[diskSpace].diskNum = diskSpace;
				allDisks[diskSpace].fd = fileno(disk);
				allDisks[diskSpace].fp = disk;
        diskCount++;
				return diskSpace;
			}
    }
    perror(filename);
    return ERR_OPENR;
	}
  else {
 //   if ((i = checkNames(filename)) == -1)
 //     return ERR_DNOTEXIST;
		if ((disk = fopen(filename, "r"))) {
      return allDisks[i].diskNum;
		}
    perror(filename);
    return ERR_OPENW;
	}
}*/

/* readBlock() reads an entire block of BLOCKSIZE bytes from the open disk (identified by ‘disk’) and copies the result into a local buffer (must be at least of BLOCKSIZE bytes). The bNum is a logical block number, which must be translated into a byte offset within the disk. The translation from logical to physical block is straightforward: bNum=0 is the very first byte of the file. bNum=1 is BLOCKSIZE bytes into the disk, bNum=n is n*BLOCKSIZE bytes into the disk. On success, it returns 0. -1 or smaller is returned if disk is not available (hasn’t been opened) or any other failures. You must define your own error code system. */
int readBlock(int disk, int bNum, void *block) {
  int offset = bNum * BLOCKSIZE;
	int diskIdx;

  /* check if disk is open */
	if ((diskIdx = lookupDisk(disk)) != -1) {
		/* move seek pointer with fseek */
    if (bNum > allDisks[diskIdx].numBlocks)
    {
      return ERR_NOSPACE;
    }
      
  	if (fseek(allDisks[diskIdx].fp, offset, SEEK_SET) < 0) {
      perror("fseek");
      return ERR_FSEEK;
    }
		/* get block with fread */
  	if (fread(block, 1, BLOCKSIZE, allDisks[diskIdx].fp) < BLOCKSIZE) {
      perror("fread");
      return ERR_FREAD;
    }
    rewind(allDisks[diskIdx].fp);
		return 0;
	}
	/*disk doesn't exist*/
	return ERR_FNOTOPEN;
}

/* writeBlock() takes disk number ‘disk’ and logical block number ‘bNum’ and writes the content of the buffer ‘block’ to that location. BLOCKSIZE bytes will be written from ‘block’ regardless of its actual size. The disk must be open. Just as in readBlock(), writeBlock() must translate the logical block bNum to the correct byte position in the file. On success, it returns 0. -1 or smaller is returned if disk is not available (i.e. hasn’t been opened) or any other failures. You must define your own error code system. */
int writeBlock(int disk, int bNum, void *block) {
	int offset = bNum * BLOCKSIZE;
	int diskIdx;
  
	/* check if disk is open */
	if ((diskIdx = lookupDisk(disk)) != -1) {
    /* Make sure the disk has enough blocks */
    if (bNum > allDisks[diskIdx].numBlocks)
      return ERR_NOSPACE;
		/* move seek pointer with fseek */
  	if (fseek(allDisks[diskIdx].fp, offset, SEEK_SET) < 0) {
      perror("fseek");
      return ERR_FSEEK;
    }
		/* get block with fread */
  	if (fwrite(block, 1, BLOCKSIZE, allDisks[diskIdx].fp) < BLOCKSIZE) {
      perror("fwrite");
      return ERR_FWRITE;
    }
    rewind(allDisks[diskIdx].fp);
		return 0;
	}
	return ERR_FNOTOPEN;
}

/* closeDisk() takes a disk number ‘disk’ and makes the disk closed to further I/O; i.e. any subsequent reads or writes to a closed disk should return an error. Closing a disk should also close the underlying file, committing any writes being buffered by the real OS. */
void closeDisk(int disk) {
	int space = lookupDisk(disk);

	if (space != -1) {
    /* fclose automatically flushes buffer */
    if (fclose(allDisks[space].fp) == EOF) {
      perror(NULL);
      exit(EXIT_FAILURE);
    }
		allDisks[space].fd = -1;
		allDisks[space].diskNum = -1;
		allDisks[space].fp = NULL;
   // diskCount--;
	}
}