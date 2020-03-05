#!/bin/bash
# $1 = EXE 
# $2 = test name  
# $3 = port 
# $4 = source name
# $5 = single-fitness-file name 
# exit 0 = success

# update on 4/22 based on feedback from Pad - try timeout in test scenario
#ulimit -t 1
echo $1 $2 $3 $4 $5 >> testruns.txt
bin=$1

trap 'kill $(jobs -p)' EXIT

python_ver=$(which python3.7)

# 46         - ARG_1=EXAMPLE_2_FLAG
# the following two lines are from the docker initialization
ARG_1=EXAMPLE_2_FLAG

exe="setarch $(uname -m) -R $bin $ARG_1"
echo $exe > example_server.log 

(stdbuf -oL -eL $exe) >> example_server.log &

EXIT_SCENARIO=0
kill_cmd='kill $(ps -s $$ -o pi=)'
# number of stress runs
NUMRUNS=5


# 2321  python3.7 test.py --invalid 4 EXAMPLE_2_FLAG
# 2322  python3.7 test.py --invalid 3
# 2323  python3.7 test.py --invalid 3 EXAMPLE_2_FLAG
# 2324  python3.7 test.py --checksum EXAMPLE_2_FLAG
# 2325  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2327  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2329  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2336  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2339  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2341  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2345  python3.7 test.py --exploit EXAMPLE_2_FLAG
# 2351  python3.7 test.py --exploit EXAMPLE_2_FLAG


case $2 in
  # Let's walk through the 4 invalid scenarios
  p1) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --invalid 1 $ARG_1 | diff valid.invalid_scenario.log - ) 
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
  done
  ;;
  p2) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --invalid 2 $ARG_1 | diff valid.invalid_scenario.log - )
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
  done
  ;;
  p3) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --invalid 3 $ARG_1 | diff valid.invalid_scenario.log - )
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
  done
  ;;
  p4) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --invalid 4 $ARG_1 | diff valid.invalid_scenario.log - )
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
  done
  ;;

  # and then checksum scenarios
  p5) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --checksum $ARG_1   | diff valid.checksum_scenario.log - )
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
  done
  ;;

  # and then echo scenarios
  p6) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --echo $ARG_1   | diff valid.echo_scenario.log - )
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
  done
  ;;

  p7) 
   timeout 3 $python_ver test.py --stress $ARG_1 >& mylog.txt 
  ( cat mylog.txt  | grep 'test\.py' | egrep -q 'All tests passed')
  EXIT_SCENARIO=$?
  rm mylog.txt
  ;;

  # negative test case / evil back door from code
  # repair vulnerability
  n1) ( timeout 3 $python_ver test.py --exploit $ARG_1  | diff unsuccessful.exploit_scenario.log - ) 
  EXIT_SCENARIO=$?
  ;;

  n2) 
  for i in $(seq 0 $NUMRUNS); do 
    ( timeout 3 $python_ver test.py --exploit $ARG_1  |& tee mylog.txt)
	( cat mylog.txt | diff unsuccessful.exploit_scenario.log - )  
    EXIT_SCENARIO=$EXIT_SCENARIO || $?
	( cat mylog.txt | diff successful.exploit_scenario.log - )  
	if [ $? == 0 ] 
	then
       EXIT_SCENARIO=1
	fi
	if [ "$EXIT_SCENARIO" == "1" ] 
	then
	   break
	fi
	rm mylog.txt
  done
  ;;
  *)
  echo "INVALID TESTCASE"
  EXIT_SCENARIO=1
  ;;


esac 


exit $EXIT_SCENARIO

