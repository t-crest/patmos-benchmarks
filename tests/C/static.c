#include <stdio.h>
 
void func() {
    static int x;
    static int y = 3;
    printf("%d %d\n", x, y);
    x = x + 1;
    y = y + 1;
}
 
int main(int argc, char *argv[]) {
    func();
    func();
    func();
    return 0;
}

