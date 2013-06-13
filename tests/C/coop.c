#include <setjmp.h>
#include <stdio.h>
 
jmp_buf mainTask, childTask;
 
void call_with_cushion(void);
void child(void);
 
int main(void) {
    if (!setjmp(mainTask)) {
        call_with_cushion(); /* child never returns */ /* yield */
    } /* execution resumes after this "}" after first time that child yields */
    for (;;) {
        printf("Parent\n");
	int rs;
        if (!(rs = setjmp(mainTask))) {
            longjmp(childTask, 1); /* yield - note that this is undefined under C99 */
        }
	if (rs > 1) break;
    }
}
 
void call_with_cushion (void) {
    char space[1000]; /* Reserve enough space for main to run */
    space[999] = 1; /* Do not optimize array out of existence */
    asm volatile ("sres 100"); /* We also take some space on the stack cache */
    child();
}
 
void child (void) {
    int i;
    for (i = 0;; i++) {
        printf("Child loop %d begin\n", i);
        if (!setjmp(childTask)) longjmp(mainTask, 1); /* yield - invalidates childTask in C99 */
 
        printf("Child loop %d end\n", i);
        if (!setjmp(childTask)) longjmp(mainTask, i < 10 ? 1 : 2); /* yield - invalidates childTask in C99 */
    }
    /* Don't return. Instead we should set a flag to indicate that main()
       should stop yielding to us and then longjmp(mainTask, 1) */
}
