/*this code is pulled directly from Iris' 357 exercise 14 */

#include <stdlib.h>
#include <stdio.h>
#include "linkedList.h"
/* removed memmon.h form header */

ListNode* addHead(ListNode *list, int disk, int fd, int seek, byte inode) {
   ListNode *head = malloc(sizeof(ListNode));

   if (head == NULL) {
      fprintf(stderr, "malloc failure attempting to add %d\n", fd);
      exit(EXIT_FAILURE);
   }

   head->disk = disk;
   head->fd = fd;
   head->seek = seek;
	 head->inode = inode;
   head->next = list;

   return head;
}

ListNode* addTail(ListNode *list, int disk, int fd, int seek, byte inode) {
   ListNode *tail = malloc(sizeof(ListNode));
   ListNode *current = list;
   
   if (tail == NULL) {
      fprintf(stderr, "malloc failure attempting to add %d\n", fd);
      exit(EXIT_FAILURE);
   }

   tail->disk = disk;
   tail->fd = fd;
   tail->seek = seek;
	 tail->inode = inode;
   tail->next = NULL;

   if (list == NULL)
      return tail;
   
   while (current->next != NULL) 
      current = current->next;
   
   current->next = tail;

   return list;
}

ListNode* deleteNodeHelper(ListNode *lst, ListNode **ptr, ListNode *r, int x) {
   *ptr = (r)->next;
   free(r);
   if (x == 0)
      return *ptr;
   else
      return lst;
}

ListNode* deleteNode(ListNode *list, int index) {
   ListNode *rem = list, *remPrev = list;
   int i = 0;
   
   if (list != NULL && index == 0)
      return deleteNodeHelper(list, &list, rem, 0);
   
   for (i = 0; list != NULL && i < index && rem->next != NULL; i++) {
      remPrev = rem;
      rem = rem->next;
   }

   if (list != NULL && i == index) 
      return deleteNodeHelper(list, &(remPrev->next), rem, 1);

   fprintf(stderr, "Index %d is out of bounds\n", index);
   return list;

}

int lookupList(ListNode *list, int fd, ListNode **node) {
  ListNode *cur = list;
  int i = 0;

  for (i = 0; cur; i++) {
    if (cur->fd == fd) {
			if (node)
				*node = cur;
      return i;
		}
    cur = cur->next;
  }
  return -1;
}