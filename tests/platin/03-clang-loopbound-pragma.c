int main(int argc, char **argv) {
	int ret = 0;

	_Pragma("loopbound min 42 max 42")
	for (int i = 0; i < argc; ++i) {
		ret++;
	}

	return ret;
}
