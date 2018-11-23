A collection of Patmos assembly programs that when tested should not compile because they are erroneous. 
The tests do not look at the actuall error message `patmos-clang` produces, just that the compilation fails.

### Add test

To add an additional assembly program test, just add the program as a `.s` file. The setup will automatically include the file as a test the next time `./misc/build.sh bench` is run.
If a program is edited, the change will have immediate effect.

### Running the tests

To run these test without the rest of the benchmarks, run the following command from the build directory: 
```
ctest -R asm-tests/must-fail
```

To circumvent the build system, you can use the `test_asm.sh` to run a single test. This script will return an error value if the compilation is successful, and a success value if the compilation fails.