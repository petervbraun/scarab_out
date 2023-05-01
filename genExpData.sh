#!/bin/bash
source wait_cpu_low.sh
wait_cpu_percent=75  # Note postgres uses substantially more memory: 3.6G+ per run

pt_apps="cassandra kafka drupal finagle-chirper finagle-http mediawiki tomcat wordpress verilator_pt clang_new mysql_new python" #redis postgres mysql
advancement_apps="$pt_apps postgres gcc perlbench deepsjeng"
spec_apps="gcc mcf leela xz xalancbmk perlbench x264 x264_bb deepsjeng exchange2 omnetpp specrand_i"
other_apps="postgres xgboost verilator_pt redis"
all_apps="$pt_apps $spec_apps $other_apps"

baseline_fdip_on="--fdip_enable=1 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=7"
baseline_fdip_off="--fdip_enable=0 --lookahead_buf_size=0 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=7"

for uoc_size in 0 256 1024; do
    for app in $advancement_apps; do
        
        ~/scarab_out/runExp.sh $app $uoc_size "" "$baseline_fdip_on" &


        sleep 1
        wait_cpu_low $wait_cpu_percent
    done
done
