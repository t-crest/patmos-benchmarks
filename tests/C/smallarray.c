
int main(int argc, char **argv) {
    
    int array[2] = { argc, (int)argv };

    for (int i = 0; i < argc; i++) {
	int *ptr = array + (i & 1);
	*ptr = argc + i;
    }

    return array[1];
}
