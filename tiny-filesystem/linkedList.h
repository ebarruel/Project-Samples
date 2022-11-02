/*this code is pulled directly from Iris' 357 exercise 14 */

/*
 * Provided source - DO NOT MODIFY !!!
 */
#ifndef LINKEDLIST_H
#define LINKEDLIST_H

#include <stdint.h>

typedef uint8_t byte;

typedef struct node
{
  int disk, fd, seek;
  byte inode;
  struct node *next;
} ListNode;

/*
 * Adds the value to the front of the list. Has O(1) performance.
 * 
 * Parameter list: The head of the list, NULL if empty.
 * Parameter value: The value to add to the beginning of the list.
 *
 * Return: The head of the list.
 */ 
ListNode* addHead(ListNode *list, int disk, int fd, int seek, byte inode);

/*
 * Adds the value to the end of the list. Has O(N) performance.
 * 
 * Parameter list: The head of the list, NULL if empty.
 * Parameter value: The value to add to the end of the list.
 *
 * Return: The head of the list.
 */ 
ListNode* addTail(ListNode *list, int disk, int fd, int seek, byte inode);

/*
 * Deletes the node at the specified index. Indexes are zero-base. Reports
 * an error in the index is out-out-bounds (see reference solution behavior
 * for specific text you must match). Has O(N) performance.
 * 
 * Parameter list: The head of the list, NULL if empty.
 * Parameter index: The zero-based index of the value to remove from the list.
 *
 * Return: The head of the list.
 */ 
ListNode* deleteNode(ListNode *list, int index);

/*
 * Prints the values, if any, in the list from beginning to end. Has O(N)
 * performance.
 * 
 * Parameter list: The head of the list, NULL if empty.
 *
 * Return: Nothing. 
 */
void printList(ListNode *list);

/*
 * Looks up the node by its file descriptor in the queue. Has O(N) performance.
 * 
 * Parameter list: The head of the list.
 * Parameter job: The file descriptor of the list (0-indexed).
 *
 * Return: index into list on success, nonzero on failure
 */
int lookupList(ListNode *list, int fd, ListNode **node);

#endif