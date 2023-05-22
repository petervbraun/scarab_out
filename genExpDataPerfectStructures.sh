#!/bin/bash
source wait_cpu_low.sh

wait_cpu_percent=70  # Note postgres uses substantially more memory: 3.6G+ per run

# Flags
baseline_flags="--fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=7"
baseline_fdip_on="--fdip_enable=1 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=7"
perfect_all="$baseline_flags --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1 --perfect_dcache=1"
perfect_except_dcache="$baseline_flags --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1"
perfect_except_dcache_ucq8="--fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1 --uop_queue_length=8"
perfect_except_dcache_ucq10="--fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1 --uop_queue_length=10"
imperfect_bp="$baseline_flags --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1"
perfect_ucq1="--fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=1 --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1"
perfect_ucq1_incl_dcache="--perfect_dcache=1 --fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=1 --perfect_icache=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1"
perfect_bp_btb_ibp_crs="--fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=7 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1"
perfect_bp_btb_ibp_crs_ucq1="--fdip_enable=0 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_bp=1"

gap_apps="bc bfs pr sssp tc"
pt_apps="cassandra kafka drupal finagle-chirper finagle-http mediawiki tomcat wordpress verilator_pt clang_new mysql_new python postgres" #redis  mysql
older_ok_apps="gcc clang perlbench deepsjeng xgboost"
advancement_apps="$pt_apps gcc perlbench deepsjeng"
apps="$pt_apps $older_ok_apps"


# ~/scarab_out/runExp.sh deepsjeng 1536 "_UCQ8" "--uop_queue_length=8" &
# ~/scarab_out/runExp.sh deepsjeng 1536 "_UCQ8_NO_REPL_AFTER_QUEUE_SIZE8" "--uop_queue_length=8 --no_repl_after_queue_size=8" &
# ~/scarab_out/runExp.sh deepsjeng 1536 "_UCQ8_NO_REPL_AFTER_QUEUE_SIZE8" "--uop_queue_length=8 --no_repl_after_queue_size=2" &

# ~/scarab_out/runExp.sh deepsjeng 1536 "" "" 10000000 &
# for min_block in 2 4 6 8 10
# do
    # ~/scarab_out/runExp.sh deepsjeng 1536 "_REPL_LARGE_BLOCKS$min_block" "--uop_cache_insert_block_gt=$min_block" 10000000 &
    # grep IPC ~/scarab_out/deepsjeng_10M_UC1536_REPL_LARGE_BLOCKS$min_block/memory.stat.0.out
# done
# exit

# heiners_uopc3
for cycle_resteer_ratio_exp in 1 2 3 4 5 6 7 8 9 10 11 12
do
    cycle_resteer_ratio=10**$cycle_resteer_ratio_exp
    ~/scarab_out/runExp.sh deepsjeng 1536 "_heiners_uopc3_$cycle_resteer_ratio" "--uop_min_resteer_count=$cycle_resteer_ratio --uop_queue_min_size=0" &
done
exit
# then lets see if 90M did any better. 90M did not do better. suspiciously it did the same as 10M

# --uop_cache_insert_only_high_lookups_after_resteer=1
~/scarab_out/runExp.sh deepsjeng 1536 "" "" 90000000 &
for lookup_cnt in 1 10 100 1000
do
    ~/scarab_out/runExp.sh deepsjeng 1536 "_INS_HIGH_LOOKUP_RESTEER$lookup_cnt" "--uop_cache_insert_only_high_lookups_after_resteer=$lookup_cnt" 90000000 &
done
exit

for app in $advancement_apps
do
    # Sweep that only inserts uopc on the onpath.
    ~/scarab_out/runExp.sh $app 1536 "_UOC_INS_ONPATH" "--uop_cache_insert_only_onpath=1" &
    # Attempt at policy to reduce resteers
    # for min_block in 1 2 3 4 5 6 7 10
    #     do
    #         ~/scarab_out/runExp.sh $app 1536 "_REPL_LARGE_BLOCKS" "--uop_cache_insert_block_gt=$min_block" &
    # done

    # for uoc_size in 0 768 1536 3072 6144 12228 24576 49152 98304 196608 393216 786432   #128 256 512 1024 2048 4096 8192 16384 32768 65536 131072
    # do
    #     # Switching plot, showing inverse correlation between switches and IPC.
    #     ~/scarab_out/runExp.sh $app $uoc_size _BASE_PERF_BP_BTB_IBP_CRS_IC_UCQ1_IGNORE_BF "$perfect_ucq1 --ignore_bar_fetch=1" &
    #     ~/scarab_out/runExp.sh $app $uoc_size _BASE_PERF_BP_BTB_IBP_CRS_IC_IGNORE_BF "$perfect_except_dcache --ignore_bar_fetch=1" &
        
    #     wait_cpu_low $wait_cpu_percent
    # done
    
    # Perfect/Inf size UOC vs baseline of 1536 to show performance potential
    for uoc_size in 0 768 1536 3072 6144 12228 24576
    do
        ~/scarab_out/runExp.sh $app $uoc_size "" "$baseline_fdip_on" &
    done

    # For default size, what is perf potential for SERVING from uoc?
    # Probably just multiply resteer count by 7, so no new experiment necessary, just new plot.
    uoc_size=1536
    ~/scarab_out/runExp.sh $app $uoc_size "_PERF_IC_UCQ1" "--perfect_icache=1 --uop_queue_length=1" &
    ~/scarab_out/runExp.sh $app 0 _ORACLE_PERFECT "$baseline_fdip_on --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _INF_SIZE "$baseline_fdip_on --inf_size_uop_cache=1" &

    wait_cpu_low $wait_cpu_percent
    
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_ORACLE_PERFECT "$perfect_except_dcache --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_ORACLE_PERFECT_UCQ8 "$perfect_except_dcache_ucq8 --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_ORACLE_PERFECT_UCQ10 "$perfect_except_dcache_ucq10 --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_UCQ1_ORACLE_PERFECT "$perfect_ucq1 --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _FDIP_ORACLE_PERFECT "$baseline_fdip_on --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _PERF_BP_BTB_IBP_CRS_ORACLE_PERFECT "$perfect_bp_btb_ibp_crs --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _PERF_BP_BTB_IBP_CRS_UCQ1_ORACLE_PERFECT "$perfect_bp_btb_ibp_crs_ucq1 --oracle_perfect_uop_cache=1" &

    # sleep 1
    # wait_cpu_low $wait_cpu_percent
    continue




    ###########################################################################################
    # Dual Path Prefetching. ZL - zero latency uoc prefetch
    # 1) Absolute count of mispredictions. Threshold can be TopK branches - will also give good coverage
    # 2) Overall misprediction rate. Threshold is HIT rate since TopK accepts all br w/ value under certain threshold.
    # 3) Count of mispredictions whose targets MISS in the UOC (actual contributors to resteer penalty)
    #
    # Consider direct branches - when the target is directly encoded, predecode reduces
    # BTB misses as well. (assuming oracle_info.target is correct)
    # So instead of just mispred consider mispred+btb_miss for directs, for both counts and rates.
    # Misfetching direct branches will only happen when aliasing in BTB.
    # Maybe I need to compare total potential cycles I can save with this additional method.
    # First verify that I am indeed getting at least a little speedup with just mispreds.

    # don't forget to regenerate the above plots after rerunning.
    # Ah! the ones w/ uoc miss mean I need to do this for each uoc size.
    for uoc_size in 1024 #256 512 1024 2048 4096
    do
        top_mispred_count_filepath="/soe/pebraun/notebooks/uc/csvs/top_mispred_counts_$app.csv"
        top_mispred_count_uoc_miss_filepath="/soe/pebraun/notebooks/uc/csvs/top_mispred_counts_uoc_miss_${app}_UC${uoc_size}.csv"
        bottom_correct_pred_rate_filepath="/soe/pebraun/notebooks/uc/csvs/bottom_correct_pred_rates_$app.csv"

        # Prefetching in tandem with FDIP
        # This should be the baseline, and also enabled with DP
        # ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF_ZL "$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1" &
        # ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF_ZL_PERF_IC "$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --perfect_icache=1" &
        ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF "$baseline_fdip_on --uoc_pref=1"  &
        # ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF_PERF_IC "$baseline_fdip_on --uoc_pref=1 --perfect_icache=1"  &

        wait_cpu_low $wait_cpu_percent
        
        # for n_branches in 1 # 16 #32
        # do
        #     dp_uoc_mispred_count="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_enable=1 --top_mispred_br_resteer_coverage=$n_branches --top_mispred_br_filepath=$top_mispred_count_filepath"
        #     dp_uoc_mispred_count_uoc_miss="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_enable=1 --top_mispred_br_resteer_coverage=$n_branches --top_mispred_br_filepath=$top_mispred_count_uoc_miss_filepath"
            
        #     # ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_MISPRED${n_branches}_ZL "$dp_uoc_mispred_count" &
        #     ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_MISPRED_UOC_MISS${n_branches}_ZL "$dp_uoc_mispred_count_uoc_miss" &
        #     # ~/scarab_out/runExp.sh $app $uoc_size _DP_UOC_MISPRED_UOC_MISS${n_branches}_ZL_PERF_IC "$dp_uoc_mispred_count_uoc_miss --perfect_icache=1" &
        # done
        # sleep 1
        # wait_cpu_low $wait_cpu_percent
        

        # Miss rate used for both online and offline method.
        # Confusingly, the offline method requires an upper limit, so the csv presents correct-prediction rates 
        # rather than misprediction rates, and the threshold is the max correct prediction rate,
        # where all branches below that rate are prefetch candidates.
        # for miss_rate in .99 0.5 #0.4 0.3
        # do
        #     hitrate_max=`bc <<< "1-$miss_rate"`  # hit rate
        #     dp_uoc_mispred_rate="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_enable=1 --top_mispred_br_resteer_coverage=$hitrate_max --top_mispred_br_filepath=$bottom_correct_pred_rate_filepath"
        #     dp_uoc_online="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_online_enable=1 --fdip_dual_path_pref_uoc_online_mispred_threshold=$miss_rate"
            
        #     ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_MISPRED_RATE${miss_rate}_ZL "$dp_uoc_mispred_rate" &
        #     # Online method uses miss rate as threshold
        #     ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_ONLINE_MR${miss_rate}_ZL "$dp_uoc_online" &
        # done
        # sleep 1
        # wait_cpu_low $wait_cpu_percent
    done
done
