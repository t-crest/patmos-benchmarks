add_executable(ebf bf_skey.c bf_ecb.c bf_enc.c bf_cbc.c bf_cfb64.c bf_ofb64.c ebf.c)
add_executable(dbf bf_skey.c bf_ecb.c bf_enc.c bf_cbc.c bf_cfb64.c bf_ofb64.c dbf.c)

run_io(mibench-ebf ${CMAKE_CURRENT_BINARY_DIR}/ebf
        ${PROJECT_SOURCE_DIR}/MiBench/security/blowfish/input_small.asc
        output_small.enc
        ${PROJECT_SOURCE_DIR}/MiBench/security/blowfish/ref_small.enc)
set_tests_properties(mibench-ebf PROPERTIES WILL_FAIL "true")

run_io(mibench-dbf ${CMAKE_CURRENT_BINARY_DIR}/dbf
        ${PROJECT_SOURCE_DIR}/MiBench/security/blowfish/input_small.enc
        output_small.asc
        ${PROJECT_SOURCE_DIR}/MiBench/security/blowfish/ref_small.asc)
set_tests_properties(mibench-dbf PROPERTIES WILL_FAIL "true")
