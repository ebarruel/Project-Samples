#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "TinyFS_errno.h"
#include "libTinyFS.h"
#include "libDisk.h"
#include "linkedList.h"

int main() {
  int test, i;
  int FD[5] = {-1};
  char read = 0;
  char alphabet[26] = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};

  printf("Super Block: %d\n", (int)sizeof(Superblock));
  printf("Inode Block: %d\n", (int)sizeof(Inode));
  printf("Free Block: %d\n", (int)sizeof(Freeblock));
  printf("File Extent Block: %d\n", (int)sizeof(FileExtent));

  printf("Making File System\n");
  test = tfs_mkfs("test.txt", DEFAULT_DISK_SIZE);
  printErr(test);
  printf("Mounting File System\n");
  test = tfs_mount("test.txt");
  printErr(test);
  
  printf("\nOpening Three Files\n");
  FD[0] = tfs_openFile(":-)");
  printErr(FD[0]);
  FD[0] = tfs_openFile("file1");
  printErr(FD[0]);
  FD[1] = tfs_openFile("file4");
  printErr(FD[1]);
  FD[2] = tfs_openFile("file7");
  printErr(FD[2]);
  tfs_readdir();

  printf("\nShowing Initial Time Stamp Data\n");
  tfs_readFileInfo(FD[0]);

  printf("\nRenaming Files\n");
  tfs_rename(FD[0], "Files");
  tfs_rename(FD[1], "Renamed");
  tfs_rename(FD[2], "Yay");
  tfs_readdir();

  printf("\nDeleting File named 'Files'\n");
  tfs_deleteFile(FD[0]);
  tfs_readdir();

  printf("\nWriting alphabet to 'Renamed'\n");
  tfs_writeFile(FD[1], alphabet, 26);
  
  printf("Printing Out 'Renamed' Byte at a Time\n");
  for (i = 0; i < 27; i++)
  {
    test = tfs_readByte(FD[1], &read);
    printf("Byte - %c, ", read);
    printErr(test);
  }

  
  printf("\nMaking 'Renamed' Read Only\n");
  tfs_makeRO("Renamed");
  printf("Trying to write to 'Renamed'\n");
  test = tfs_writeByte(FD[1], 12, '$');
  printErr(test);
  printf("Turning 'Renamed' Back to Read/Write'\n");
  tfs_makeRW("Renamed");
  printf("Trying to write to 'Renamed again\n");
  test = tfs_writeByte(FD[1], 12, '$');
  printErr(test);
  printf("Using seek to move file pointer to start of file\n");
  test = tfs_seek(FD[1], 0);
  printErr(test);
  printf("Printing Out 'Renamed' Byte at a Time\n");
  for (i = 0; i < 27; i++)
  {
    test = tfs_readByte(FD[1], &read);
    printf("Byte - %c, ", read);
    printErr(test);
  }

  printf("\nWaiting 10s\n");
  sleep(10);
  printf("Modifying 'Renamed'\n");
  tfs_writeFile(FD[1], alphabet, 26);
  tfs_readFileInfo(FD[1]);

  printf("\nUnmounting File System\n");
  test = tfs_unmount();
  printErr(test);

  return 0;
}