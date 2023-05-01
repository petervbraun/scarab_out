#!/bin/bash
source wait_cpu_low.sh
wait_cpu_percent=90  # Note postgres uses substantially more memory: 3.6G+ per run

pt_apps="cassandra kafka drupal finagle-chirper finagle-http mediawiki tomcat wordpress clang_new mysql_new python postgres" #redis  mysql verilator_pt
advancement_apps="$pt_apps gcc perlbench deepsjeng"
spec_apps="gcc mcf leela xz xalancbmk perlbench x264 x264_bb deepsjeng exchange2 omnetpp specrand_i"
other_apps="postgres xgboost verilator_pt redis"
all_apps="$pt_apps $spec_apps $other_apps"

baseline_fdip_on="--fdip_enable=1 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=7"

# tagescl, 4K BTB in runExp.sh, 20% chance of data cache missing for PT
# From Apr 25 afternoon, top resteer PWs chosen by resteers instead of resteers_uc_miss
focus_apps=" deepsjeng postgres perlbench"
uoc_capacity=1536  #UC1536 from 4/18 onwards
for app in postgres $advancement_apps; do
    ~/scarab_out/runExp.sh $app $uoc_capacity "" "$baseline_fdip_on " &
    ~/scarab_out/runExp.sh $app $uoc_capacity "_IGNOREBF" "$baseline_fdip_on --ignore_bar_fetch=1" &
    ~/scarab_out/runExp.sh $app $uoc_capacity "_UCQ1" "--uop_queue_length=1" &
    ~/scarab_out/runExp.sh $app $uoc_capacity "_UOP_CACHE_INSERT_ONLY_AFTER_RESTEER_UOP_QUEUE_NOT_FULL" "--uop_cache_insert_only_after_resteer_uop_queue_not_full=1" &
    ~/scarab_out/runExp.sh $app $uoc_capacity "_UOP_CACHE_INSERT_ONLY_AFTER_RESTEER_UOP_QUEUE_NOT_FULL_UCQ1" "--uop_cache_insert_only_after_resteer_uop_queue_not_full=1 --uop_queue_length=1" &
done

for list_type in resteer shared; do #resteer
    for app in deepsjeng $advancement_apps; do
        for stickiness in 90 95 98 99; do
            for num_priority_pws in 100 1000 2000 3000; do
                pw_prio_list_file="/soe/pebraun/notebooks/uc/csvs/top_${list_type}_pws_$app.csv"
                # ~/scarab_out/runExp.sh $app $uoc_capacity "_STICKY${stickiness}_${num_priority_pws}PINNED_$list_type" "$baseline_fdip_on --uop_cache_repl=12 --priority_line_stickiness_percent=$stickiness --num_priority_pws=$num_priority_pws --pw_priority_list_filepath=$pw_prio_list_file" &
                ~/scarab_out/runExp.sh $app $uoc_capacity "_STICKY${stickiness}_${num_priority_pws}PINNED_${list_type}_PLUS_PWS_UNTIL_BSTALL" "--prioritize_pws_after_first_sticky_until_backend_stall=1 $baseline_fdip_on --uop_cache_repl=12 --priority_line_stickiness_percent=$stickiness --num_priority_pws=$num_priority_pws --pw_priority_list_filepath=$pw_prio_list_file" &
            done
            sleep 1
            wait_cpu_low $wait_cpu_percent
        done
    done
done
g