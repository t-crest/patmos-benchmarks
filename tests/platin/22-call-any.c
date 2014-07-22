
int main(int argc, char **argv) {
	int (*bar)() = (int (*)) argv[1];
	if (argc == 42)
		return bar();
	return 0;
}
