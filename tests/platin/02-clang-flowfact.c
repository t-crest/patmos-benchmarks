int main(int argc, char **argv) {
	int ret = 0;

	_Pragma("platin(@1 - 42 @0 <= 0)");

	//__llvm_pcmarker(0);
	for (int i = 0; i < argc; ++i) {
		//__llvm_pcmarker(1);
		ret++;
	}

	return ret;
}
