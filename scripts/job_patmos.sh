#!/bin/bash

PROJECT=patmos

ROOTDIR=/project/flbr/jobs/
JOBSDIR=${ROOTDIR}
OPTDIR=${JOBSDIR}opt/
PROJECTDIR=${JOBSDIR}${PROJECT}/
BUILDDIR=${JOBSDIR}build/${PROJECT}/
INSTALLDIR=${JOBSDIR}install/${PROJECT}/
BINDIR=${INSTALLDIR}bin/

LOGFILE=${ROOTDIR}logs/${PROJECT}.log
LASTLOGFILE=${ROOTDIR}/logs/${PROJECT}-last.log

TMPSTATUS=${JOBSDIR}tmp/${PROJECT}-status.log

RESULTSIM_FILE=${JOBSDIR}tmp/${PROJECT}-results-sim.log
RESULTRUN_FILE=${JOBSDIR}tmp/${PROJECT}-results-run.log

RESULTDB_FILE=${ROOTDIR}logs/${PROJECT}.sus
LASTRESULTDB_FILE=${ROOTDIR}logs/${PROJECT}-last.sus

RESULTDB_NOSC_FILE=${ROOTDIR}logs/${PROJECT}-nosc.sus
LASTRESULTDB_NOSC_FILE=${ROOTDIR}logs/${PROJECT}-last-nosc.sus

RESULTDB_MDLY_NOSC_FILE=${ROOTDIR}logs/${PROJECT}-mdly-nosc.sus
LASTRESULTDB_MDLY_NOSC_FILE=${ROOTDIR}logs/${PROJECT}-last-mdly-nosc.sus

RESULTDB_MDLY_FILE=${ROOTDIR}logs/${PROJECT}-mdly.sus
LASTRESULTDB_MDLY_FILE=${ROOTDIR}logs/${PROJECT}-last-mdly.sus

RESULTDB_SPLIT_MDLY_FILE=${ROOTDIR}logs/${PROJECT}-split-mdly.sus
LASTRESULTDB_SPLIT_MDLY_FILE=${ROOTDIR}logs/${PROJECT}-last-split-mdly.sus

RESULTTMP_FILE=${ROOTDIR}tmp/${PROJECT}.sus

REPORT_FILE=${JOBSDIR}tmp/${PROJECT}-report.log


PATMOS=${PROJECTDIR}patmos/
PATMOS_SIM=${PATMOS}simulator/
PATMOS_CLANG=${PROJECTDIR}patmos-clang/
PATMOS_LLVM=${PROJECTDIR}patmos-llvm/
PATMOS_GOLD=${PROJECTDIR}patmos-gold/
PATMOS_RT=${PROJECTDIR}patmos-compiler-rt/
PATMOS_NEWLIB=${PROJECTDIR}patmos-newlib/

PATMOS_BENCHMARKS=${PROJECTDIR}patmos-benchmarks/

BUILD_SIM=${BUILDDIR}pasim/
BUILD_LLVM=${BUILDDIR}llvm/
BUILD_GOLD=${BUILDDIR}gold/
BUILD_RT=${BUILDDIR}rt/
BUILD_NEWLIB=${BUILDDIR}newlib/

BUILD_BENCHMARKS=${BUILDDIR}benchmarks/
BUILD_BENCHMARKS_NOSC=${BUILDDIR}benchmarks-nosc/
BUILD_BENCHMARKS_MDLY_NOSC=${BUILDDIR}benchmarks-mdly-nosc/
BUILD_BENCHMARKS_MDLY=${BUILDDIR}benchmarks-mdly/
BUILD_BENCHMARKS_SPLIT_MDLY=${BUILDDIR}benchmarks-split-mdly/

BOOSTDIR=/home/flbr/opt/boost-1.50/

ELFDIR=/home/flbr/opt/elfutils-0.152/
ELFINCLUDE=${ELFDIR}include/
ELFLIB=${ELFDIR}lib/
ELFSO=${ELFLIB}libelf.so

YACC=/home/flbr/opt/bison-2.6/bin/yacc
OBJDUMP=/usr/bin/objdump

EXPLABDIR=/home/flbr/opt/ExpLab-0.7/
SUS2SUS=${EXPLABDIR}bin/sus2sus
SUS2TEXT=${EXPLABDIR}bin/sus2text
TEXT2SUS=${EXPLABDIR}bin/text2sus
TABLE2SUS=${EXPLABDIR}bin/table2sus


function update()
{
  echo "Updateing ${PROJECT} ..."

  for i in ${PATMOS} ${PATMOS_CLANG} ${PATMOS_LLVM} ${PATMOS_GOLD} \
           ${PATMOS_NEWLIB} ${PATMOS_RT} ${PATMOS_BENCHMARKS}; do

    pushd $i;
      git pull;

      if (($?)); then
        echo "Update failed."
        exit 1;
      fi
      
      git branch -v
    popd;
  done;
}

function build_sim()
{
  # cleanup
  rm -rf ${BUILD_SIM}
  mkdir -p ${BUILD_SIM}
  
  pushd ${BUILD_SIM}
    # configure
    cmake ${PATMOS_SIM} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_INSTALL_PREFIX:PATH=${INSTALLDIR} \
      -DCMAKE_LIBRARY_PATH=${BOOSTDIR} \
      -DBOOST_ROOT=${BOOSTDIR} \
      -DELF:FILEPATH=${ELFSO} \
      -DELF_INCLUDE_DIRS:PATH=${ELFINCLUDE}

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build and install
    make -sj32 && make -s install

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function build_llvm()
{
  # cleanup
  rm -rf ${BUILD_LLVM}
  mkdir -p ${BUILD_LLVM}
  
  pushd ${BUILD_LLVM}
    # configure
    ${PATMOS_LLVM}configure CXX=g++ --prefix=${INSTALLDIR} --disable-optimized \
      --enable-assertions --enable-expensive-checks --enable-debug

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build and install
    make -sj32 && make -s install

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function build_gold()
{
  # cleanup
  rm -rf ${BUILD_GOLD}
  mkdir -p ${BUILD_GOLD}
  
  pushd ${BUILD_GOLD}
    # configure
    ${PATMOS_GOLD}configure YACC=${YACC} --prefix=${INSTALLDIR} --enable-gold=yes \
      --enable-ld=no --program-prefix=patmos-unknown-unknown-elf-

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build and install
    make -sj32 all-gold && make -s install-gold

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function build_newlib()
{
  # cleanup
  rm -rf ${BUILD_NEWLIB}
  mkdir -p ${BUILD_NEWLIB}
  
  pushd ${BUILD_NEWLIB}
    # configure
    ${PATMOS_NEWLIB}configure --prefix=${INSTALLDIR} \
        --target=patmos-unknown-unknown-elf \
        AR_FOR_TARGET=${BINDIR}llvm-ar \
        RANLIB_FOR_TARGET=${BINDIR}llvm-ranlib \
        LD_FOR_TARGET=${BINDIR}llvm-ld \
        CC_FOR_TARGET=${BINDIR}clang \
        CFLAGS_FOR_TARGET="-target patmos-unknown-unknown-elf -O3" \
        --enable-newlib-multithread=no

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build and install
    make -sj32 && make -s install

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function build_rt()
{
  # cleanup
  rm -rf ${BUILD_RT}
  mkdir -p ${BUILD_RT}
  
  pushd ${BUILD_RT}
    # configure
    cmake ${PATMOS_RT} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_INSTALL_PREFIX:PATH=${INSTALLDIR} \
      -DCMAKE_PREFIX_PATH:FILEPATH=${INSTALLDIR}bin/ \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${PATMOS_RT}cmake/patmos-clang-toolchain.cmake

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build and install
    make -s && make -s install

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function build()
{
  echo "Building ${PROJECT} ..."

  build_sim ;

  build_llvm ;

  build_gold ;
  
  build_newlib ;

  build_rt ;
}

function test_compiler()
{
  # cleanup
  rm -rf ${BUILD_BENCHMARKS}
  mkdir -p ${BUILD_BENCHMARKS}
  
  pushd ${BUILD_BENCHMARKS}
    # configure
    cmake ${PATMOS_BENCHMARKS} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_PREFIX_PATH:FILEPATH=${INSTALLDIR}bin/ \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${PATMOS_BENCHMARKS}cmake/patmos-clang-toolchain.cmake \
      -DPASIM_OPTIONS:STRING="-M;lru;-m;64k;-S;block;-s;1k"

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build benchmarks
    make -sj32 -C MiBench

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function test_compiler_nosc()
{
  # cleanup
  rm -rf ${BUILD_BENCHMARKS_NOSC}
  mkdir -p ${BUILD_BENCHMARKS_NOSC}
  
  pushd ${BUILD_BENCHMARKS_NOSC}
    # configure
    cmake ${PATMOS_BENCHMARKS} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING=-mpatmos-disable-stack-cache \
      -DCMAKE_PREFIX_PATH:FILEPATH=${INSTALLDIR}bin/ \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${PATMOS_BENCHMARKS}cmake/patmos-clang-toolchain.cmake \
      -DPASIM_OPTIONS:STRING="-M;lru;-m;64k;-S;block;-s;1k"

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build benchmarks
    make -sj32 -C MiBench

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function test_compiler_mdly_nosc()
{
  # cleanup
  rm -rf ${BUILD_BENCHMARKS_MDLY_NOSC}
  mkdir -p ${BUILD_BENCHMARKS_MDLY_NOSC}
  
  pushd ${BUILD_BENCHMARKS_MDLY_NOSC}
    # configure
    cmake ${PATMOS_BENCHMARKS} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING=-mpatmos-disable-stack-cache \
      -DCMAKE_PREFIX_PATH:FILEPATH=${INSTALLDIR}bin/ \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${PATMOS_BENCHMARKS}cmake/patmos-clang-toolchain.cmake \
      -DPASIM_OPTIONS:STRING="-M;lru;-m;64k;-S;block;-s;1k;-G;10;-D;lru4;-d;8k"

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build benchmarks
    make -sj32 -C MiBench

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function test_compiler_mdly()
{
  # cleanup
  rm -rf ${BUILD_BENCHMARKS_MDLY}
  mkdir -p ${BUILD_BENCHMARKS_MDLY}
  
  pushd ${BUILD_BENCHMARKS_MDLY}
    # configure
    cmake ${PATMOS_BENCHMARKS} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_PREFIX_PATH:FILEPATH=${INSTALLDIR}bin/ \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${PATMOS_BENCHMARKS}cmake/patmos-clang-toolchain.cmake \
      -DPASIM_OPTIONS:STRING="-M;lru;-m;64k;-S;block;-s;1k;-G;10;-D;lru4;-d;8k"

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build benchmarks
    make -sj32 -C MiBench

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function test_compiler_split_mdly()
{
  # cleanup
  rm -rf ${BUILD_BENCHMARKS_SPLIT_MDLY}
  mkdir -p ${BUILD_BENCHMARKS_SPLIT_MDLY}
  
  pushd ${BUILD_BENCHMARKS_SPLIT_MDLY}
    # configure
    cmake ${PATMOS_BENCHMARKS} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -DCMAKE_EXE_LINKER_FLAGS_RELEASE:STRING="-mpatmos-method-cache-size=4096 -mpatmos-disable-function-splitter=false" \
      -DCMAKE_PREFIX_PATH:FILEPATH=${INSTALLDIR}bin/ \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${PATMOS_BENCHMARKS}cmake/patmos-clang-toolchain.cmake \
      -DPASIM_OPTIONS:STRING="-M;lru;-m;4k;-S;block;-s;1k;-G;10;-D;lru4;-d;8k"

    if (($?)); then
      echo "Configure failed."
      exit 1;
    fi
      
    # build benchmarks
    make -sj32 -C MiBench

    if (($?)); then
      echo "Build failed."
      exit 1;
    fi   
  popd
}

function test_sim()
{
  pushd ${BUILD_SIM}
    # run tests
    make -s test
  popd
}

function test_run()
{
  echo "# Running benchmarks ..."
  pushd ${BUILD_BENCHMARKS}
    # run benchmarks
    make -s test
  popd

  echo -e "\n# Running benchmarks (no stack cache) ..."
  pushd ${BUILD_BENCHMARKS_NOSC}
    # run benchmarks
    make -s test
  popd

  echo -e "\n# Running benchmarks (with memory delay, no stack cache) ..."
  pushd ${BUILD_BENCHMARKS_MDLY_NOSC}
    # run benchmarks
    make -s test
  popd

  echo -e "\n# Running benchmarks (with memory delay) ..."
  pushd ${BUILD_BENCHMARKS_MDLY}
    # run benchmarks
    make -s test
  popd

  echo -e "\n# Running benchmarks (with split functions and memory delay) ..."
  pushd ${BUILD_BENCHMARKS_SPLIT_MDLY}
    # run benchmarks
    make -s test
  popd
}

function tests()
{
  test_compiler ;

  test_compiler_nosc ;

  test_compiler_mdly_nosc ;

  test_compiler_mdly ;

  test_compiler_split_mdly ;

  test_sim | tee ${RESULTSIM_FILE};

  test_run | tee ${RESULTRUN_FILE};
}

# Arguments:
# $1 ... build directory of benchmarks, e.g., ${BUILD_BENCHMARKS}
function report_table()
{
  printf "%8s\t%8s\t%15s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n" \
         "date" "time" name cycles textsize rodatasize datasize bsssize \
         dc_rd_hit dc_rd_miss dc_rdb_hit dc_rdb_miss \
         dc_wr_hit dc_wr_miss dc_wrb_hit dc_wrb_miss \
         sc_spill sc_spill_max sc_fill sc_fill_max sc_alloc sc_alloc_max \
         sc_res_max sc_rd sc_rdb sc_wr sc_wrb sc_efree \
         mc_fill mc_fill_max mc_fillb mc_fillb_max mc_hit mc_miss ;

  local date=`date +%D`
  local time=`date +%T`

  for i in `find $1 -name '*.stats'`; do 
    local -i cycles="10#`grep -h "Cyc :" $i | cut -d ':' -f 2 | cut -d ' ' -f 2`";
    local name=`basename $i .stats | cut -d '-' -f 2-`;
    local dir=`dirname $i` ;

    # parse ELF binary information
    local -i textsize="0x`${OBJDUMP} -h ${dir}/${name} | grep '\.text' | cut -c 19-26`" ;
    local -i rodatasize="0x`${OBJDUMP} -h ${dir}/${name} | grep '\.rodata' | cut -c 19-26`" ;
    local -i datasize="0x`${OBJDUMP} -h ${dir}/${name} | grep '\.data[ \t]' | cut -c 19-26`" ;
    local -i bsssize="0x`${OBJDUMP} -h ${dir}/${name} | grep '\.bss' | cut -c 19-26`" ;

    # parse data cache information
    local dc_info=`grep "Data Cache Statistics" -A 5 $i | grep "Reads            :"`;
    local dc_rd_hit=`echo ${dc_info}  | cut -d ' ' -f 4`;
    local dc_rd_miss=`echo ${dc_info} | cut -d ' ' -f 5`;
     
    local dc_info=`grep "Data Cache Statistics" -A 5 $i | grep "Bytes Read"`;
    local dc_rdb_hit=`echo ${dc_info}  | cut -d ' ' -f 5`;
    local dc_rdb_miss=`echo ${dc_info} | cut -d ' ' -f 6`;

    local dc_info=`grep "Data Cache Statistics" -A 5 $i | grep "Writes           :"`;
    local dc_wr_hit=`echo ${dc_info}  | cut -d ' ' -f 4`;
    local dc_wr_miss=`echo ${dc_info} | cut -d ' ' -f 5`;
     
    local dc_info=`grep "Data Cache Statistics" -A 5 $i | grep "Bytes Written"`;
    local dc_wrb_hit=`echo ${dc_info}  | cut -d ' ' -f 5`;
    local dc_wrb_miss=`echo ${dc_info} | cut -d ' ' -f 6`;
     
    # parse stack cache information
    local sc_info=`grep "Stack Cache Statistics" -A 10 $i | grep "Blocks Spilled   :"`;
    local sc_spill=`echo ${sc_info}     | cut -d ' ' -f 4`;
    local sc_spill_max=`echo ${sc_info} | cut -d ' ' -f 5`;

    local sc_info=`grep "Stack Cache Statistics" -A 10 $i | grep "Blocks Filled    :"`;
    local sc_fill=`echo ${sc_info}     | cut -d ' ' -f 4`;
    local sc_fill_max=`echo ${sc_info} | cut -d ' ' -f 5`;

    local sc_info=`grep "Stack Cache Statistics" -A 10 $i | grep "Blocks Allocated :"`;
    local sc_alloc=`echo ${sc_info}     | cut -d ' ' -f 4`;
    local sc_alloc_max=`echo ${sc_info} | cut -d ' ' -f 5`;

    local sc_res_max=`grep "Stack Cache Statistics" -A 10 $i | grep "Blocks Reserved  :" | cut -c 33-`;
    local sc_rd=`grep "Stack Cache Statistics" -A 10 $i      | grep "Reads            :" | cut -c 23-`;
    local sc_rdb=`grep "Stack Cache Statistics" -A 10 $i     | grep "Bytes Read       :" | cut -c 23-`;
    local sc_wr=`grep "Stack Cache Statistics" -A 10 $i      | grep "Writes           :" | cut -c 23-`;
    local sc_wrb=`grep "Stack Cache Statistics" -A 10 $i     | grep "Bytes Written    :" | cut -c 23-`;
    local sc_efree=`grep "Stack Cache Statistics" -A 10 $i   | grep "Emptying Frees   :" | cut -c 23-`;

    # parse method cache information
    local mc_info=`grep "Method Cache Statistics" -A 6 $i | grep "Blocks Transferred"`;
    local mc_fill=`echo ${mc_info}     | cut -d ' ' -f 3`;
    local mc_fill_max=`echo ${mc_info} | cut -d ' ' -f 4`;
   
    local mc_info=`grep "Method Cache Statistics" -A 6 $i | grep "Bytes Transferred"`;
    local mc_fillb=`echo ${mc_info}     | cut -d ' ' -f 4`;
    local mc_fillb_max=`echo ${mc_info} | cut -d ' ' -f 5`;
   
    local mc_hit=`grep "Method Cache Statistics" -A 6 $i  | grep "Cache Hits"   | cut -c 23-`;
    local mc_miss=`grep "Method Cache Statistics" -A 6 $i | grep "Cache Misses" | cut -c 23-`;

    printf "%8s\t%8s\t%15s\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\t%10d\n" \
           ${date} ${time} ${name} ${cycles} ${textsize} ${rodatasize} \
           ${datasize} ${bsssize} \
           ${dc_rd_hit} ${dc_rd_miss} ${dc_rdb_hit} ${dc_rdb_miss} \
           ${dc_wr_hit} ${dc_wr_miss} ${dc_wrb_hit} ${dc_wrb_miss} \
           ${sc_spill} ${sc_spill_max} ${sc_fill} ${sc_fill_max} \
           ${sc_alloc} ${sc_alloc_max} ${sc_res_max} \
           ${sc_rd} ${sc_rdb} ${sc_wr} ${sc_wrb} ${sc_efree} \
           ${mc_fill} ${mc_fill_max} ${mc_fillb} ${mc_fillb_max} \
           ${mc_hit} ${mc_miss} ;
  done;
}

# Arguments
# $1 ... build directory of benchmarks, e.gq., ${BUILD_BENCHMARKS}
# $2 ... last results db file, e.g, ${LASTRESULTDB_FILE}
# $3 ... accumulated results db file, e.g., ${RESULTDB_FILE}
function report_run()
{
  # collect data 
  report_table $1 | ${TABLE2SUS} -i - > $2

  # append to database
  if [ -e $3 ]; then
    ${SUS2SUS} -o ${RESULTTMP_FILE} -i $3 -i $2
    mv ${RESULTTMP_FILE} $3
  else
    cp $2 $3
  fi

  ${SUS2SUS} -i $3 \
      --filter 'float(cycles) > 0'     --filter 'float(textsize) > 0' \
      --filter 'float(rodatasize) > 0' --filter 'float(datasize) > 0' \
      --filter 'float(bsssize) > 0' \
      --sort=name --combine=min \
      name \
      cycles_min=cycles textsize_min=textsize rodatasize_min=rodatasize \
      datasize_min=datasize bsssize_min=bsssize | 
    ${SUS2SUS} -i $2 -i - --sort=name |
    ${SUS2TEXT} -i - \
      --filter 'float(cycles) > 0'     --filter 'float(textsize) > 0' \
      --filter 'float(rodatasize) > 0' --filter 'float(datasize) > 0' \
      --filter 'float(bsssize) > 0' \
      name \
      cycles cycles_rel='savediv(cycles, cycles_min)' \
      textsize textsize_rel='savediv(textsize, textsize_min)' \
      dc_rd_miss_rate='format(savediv(dc_rd_miss, float(dc_rd_hit) + float(dc_rd_miss))*100, digits=2)' \
      dc_loads='int(dc_rd_miss) + int(dc_rd_hit)' \
      dc_load_volume='int(dc_rdb_miss) + int(dc_rdb_hit)' \
      dc_stores='int(dc_wr_miss) + int(dc_wr_hit)' \
      dc_store_volume='int(dc_wrb_miss) + int(dc_wrb_hit)' \
      sc_loads='int(sc_rd)' \
      sc_load_volume='int(sc_rdb)' \
      sc_stores='int(sc_wr)' \
      sc_store_volume='int(sc_wrb)' \
      sc_alloc sc_alloc_max sc_res_max \
      mc_hit mc_miss

#       rodatasize rodatasize_rel='savediv(rodatasize, rodatasize_min)' \
#       datasize datasize_rel='savediv(datasize, datasize_min)' \
#       bsssize bsssize_rel='savediv(bsssize, bsssize_min)'
}

function report()
{
  echo -e "# Benchmark results"
  report_run ${BUILD_BENCHMARKS} ${LASTRESULTDB_FILE} ${RESULTDB_FILE}
  echo -e "\n\n# Benchmark results without stack cache"
  report_run ${BUILD_BENCHMARKS_NOSC} ${LASTRESULTDB_NOSC_FILE} ${RESULTDB_NOSC_FILE}
  echo -e "\n\n# Benchmark results with memory delay without stack cache"
  report_run ${BUILD_BENCHMARKS_MDLY_NOSC} ${LASTRESULTDB_MDLY_NOSC_FILE} ${RESULTDB_MDLY_NOSC_FILE}
  echo -e "\n\n# Benchmark results with memory delay"
  report_run ${BUILD_BENCHMARKS_MDLY} ${LASTRESULTDB_MDLY_FILE} ${RESULTDB_MDLY_FILE}
  echo -e "\n\n# Benchmark results with split functions and memory delay"
  report_run ${BUILD_BENCHMARKS_SPLIT_MDLY} ${LASTRESULTDB_SPLIT_MDLY_FILE} ${RESULTDB_SPLIT_MDLY_FILE}
}

function do_it()
{
  echo "*****************************************************************"
  echo "*****************************************************************"
  echo "*****************************************************************"
  date
  echo "Root: ${ROOTDIR}"
  echo "  Log-File: ${LOGFILE}"
  echo "  Project: ${PROJECT}"
  echo "    Directory: ${PROJECTDIR}"
  echo "    Build-Directory: ${BUILDDIR}"

  update ;
  if (($?)); then
    exit 1;
  fi

  build ;
  if (($?)); then
    exit 1;
  fi

  tests ;
  if (($?)); then
    exit 1;
  fi

  report | tee ${REPORT_FILE} ;

  exit 0;
}

function create_status_mail()
{
  #create status mail
  echo -e "Subject: [PTMS] hms1 test results;"\
          "\nTo: flbr@imm.dtu.dk;" > ${TMPSTATUS}

  if [ "$1" == "--nightly" ]; then
    echo -e "To: daniel@vmars.tuwien.ac.at;"\
            "\nTo: hepp@complang.tuwien.ac.at;"\
            "\nTo: masca@imm.dtu.dk;" >> ${TMPSTATUS}
  fi

  echo -e "Content-Type: Multipart/Mixed;"\
          "\n  boundary=\"Boundary-00=_lE6jL9+i3XICJ6i\"" >> ${TMPSTATUS};

  echo -e "\n--Boundary-00=_lE6jL9+i3XICJ6i"\
          "\nContent-Type: Text/Plain;"\
          "\n  charset=\"UTF-8\";\n" >> ${TMPSTATUS}
}

function send_status_mail()
{
  # attach test results
  cat ${REPORT_FILE} >> ${TMPSTATUS}
  echo -e "\n\n" >> ${TMPSTATUS}
  cat ${RESULTRUN_FILE} >> ${TMPSTATUS}
  echo -e "\n\n" >> ${TMPSTATUS}
  cat ${RESULTSIM_FILE} >> ${TMPSTATUS}
  echo -e "\n\n" >> ${TMPSTATUS}

  # attach log
  echo -e "\n--Boundary-00=_lE6jL9+i3XICJ6i"\
          "\nContent-Type: text/plain;"\
          "\n  charset=\"UTF-8\";"\
          "\n name=\"patmos.log\""\
          "\nContent-Transfer-Encoding: 7bit"\
          "\nContent-Disposition: attachment;"\
          "\n  filename=\"patmos.log\";\n" >> ${TMPSTATUS}

  cat ${LASTLOGFILE} >> ${TMPSTATUS};

  # send status email
  /usr/sbin/sendmail -t < ${TMPSTATUS}
}

rm -f ${RESULTRUN_FILE} ${RESULTSIM_FILE} ${TMPSTATUS} ${REPORT_FILE}

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/home/flbr/opt/boost-1.50/lib/:/home/flbr/opt/elfutils-0.152/lib/

create_status_mail $1;

do_it 2>&1 | tee -a ${LOGFILE} > ${LASTLOGFILE}

send_status_mail >> ${LASTLOGFILE} 2>&1 

exit 0


