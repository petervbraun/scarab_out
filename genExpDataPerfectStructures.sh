#!/bin/bash
source wait_cpu_low.sh

wait_cpu_percent=30  # Note postgres uses substantially more memory: 3.6G+ per run

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
pt_apps="cassandra kafka drupal finagle-chirper finagle-http mediawiki tomcat wordpress verilator_pt clang_new mysql_new python" #redis postgres mysql
older_ok_apps="gcc clang perlbench deepsjeng xgboost"
advancement_apps="$pt_apps postgres gcc perlbench deepsjeng"
apps="$pt_apps $older_ok_apps"

for app in $advancement_apps
do
    # for uoc_size in 0 64 128 256 512 1024 2048 4096
    # do
    #     ~/scarab_out/runExp.sh $app $uoc_size _BASE_PERF_BP_BTB_IBP_CRS_IC "$perfect_except_dcache" &
    #     ~/scarab_out/runExp.sh $app $uoc_size _BASE_PERF_BP_BTB_IBP_CRS_IC_UCQ8 "$perfect_except_dcache_ucq8" &
    #     ~/scarab_out/runExp.sh $app $uoc_size _BASE_PERF_BP_BTB_IBP_CRS_IC_UCQ10 "$perfect_except_dcache_ucq10" &
    #     ~/scarab_out/runExp.sh $app $uoc_size _BASE_PERF_BP_BTB_IBP_CRS_IC_UCQ1 "$perfect_ucq1" &
    #     # ~/scarab_out/runExp.sh $app $uoc_size "" "$baseline_flags" &
    #     ~/scarab_out/runExp.sh $app $uoc_size _FDIP "$baseline_fdip_on" &
    #     # ~/scarab_out/runExp.sh $app $uoc_size _PERF_BP_BTB_IBP_CRS "$perfect_bp_btb_ibp_crs" &
    #     # ~/scarab_out/runExp.sh $app $uoc_size _PERF_BP_BTB_IBP_CRS_UCQ1 "$perfect_bp_btb_ibp_crs_ucq1" &
    #     sleep 1
    #     wait_cpu_low $wait_cpu_percent
    # done
    for uoc_size in 0 128 256 512 1024 2048 4096
    do
        # ~/scarab_out/runExp.sh $app $uoc_size _PERF_IC "$baseline_flags --perfect_icache=1" &        
        ~/scarab_out/runExp.sh $app $uoc_size _FDIP_PERF_IC "$baseline_fdip_on --perfect_icache=1" &
        # ~/scarab_out/runExp.sh $app $uoc_size _FDIP_PERF_IC_UCQ1 "--fdip_enable=1 --uop_cache_additional_issue_bandwidth=0 --uop_queue_length=1 --perfect_icache=1" &
    done
    # sleep 1
    # wait_cpu_low $wait_cpu_percent
    
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_ORACLE_PERFECT "$perfect_except_dcache --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_ORACLE_PERFECT_UCQ8 "$perfect_except_dcache_ucq8 --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_ORACLE_PERFECT_UCQ10 "$perfect_except_dcache_ucq10 --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _BASE_PERF_BP_BTB_IBP_CRS_IC_UCQ1_ORACLE_PERFECT "$perfect_ucq1 --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _ORACLE_PERFECT "$baseline_flags --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _FDIP_ORACLE_PERFECT "$baseline_fdip_on --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _PERF_BP_BTB_IBP_CRS_ORACLE_PERFECT "$perfect_bp_btb_ibp_crs --oracle_perfect_uop_cache=1" &
    # ~/scarab_out/runExp.sh $app 0 _PERF_BP_BTB_IBP_CRS_UCQ1_ORACLE_PERFECT "$perfect_bp_btb_ibp_crs_ucq1 --oracle_perfect_uop_cache=1" &

    # sleep 1
    # wait_cpu_low $wait_cpu_percent

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
    for uoc_size in 128 256 512 1024 2048 4096; do
        top_mispred_count_filepath="/soe/pebraun/notebooks/uc/csvs/top_mispred_counts_$app.csv"
        top_mispred_count_uoc_miss_filepath="/soe/pebraun/notebooks/uc/csvs/top_mispred_counts_uoc_miss_${app}_UC${uoc_size}.csv"
        bottom_correct_pred_rate_filepath="/soe/pebraun/notebooks/uc/csvs/bottom_correct_pred_rates_$app.csv"

        # Prefetching in tandem with FDIP
        # This should be the baseline, and also enabled with DP
        # ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF_ZL "$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1" &
        ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF_ZL_PERF_IC "$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --perfect_icache=1" &
        # ~/scarab_out/runExp.sh $app $uoc_size _UOC_PREF "$baseline_fdip_on --uoc_pref=1" 1000000 &

        sleep 1
        wait_cpu_low $wait_cpu_percent
        continue
        
        for n_branches in 1 # 16 #32
        do
            dp_uoc_mispred_count="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_enable=1 --top_mispred_br_resteer_coverage=$n_branches --top_mispred_br_filepath=$top_mispred_count_filepath"
            dp_uoc_mispred_count_uoc_miss="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_enable=1 --top_mispred_br_resteer_coverage=$n_branches --top_mispred_br_filepath=$top_mispred_count_uoc_miss_filepath"
            
            # ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_MISPRED${n_branches}_ZL "$dp_uoc_mispred_count" &
            ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_MISPRED_UOC_MISS${n_branches}_ZL "$dp_uoc_mispred_count_uoc_miss" &
            # ~/scarab_out/runExp.sh $app $uoc_size _DP_UOC_MISPRED_UOC_MISS${n_branches}_ZL_PERF_IC "$dp_uoc_mispred_count_uoc_miss --perfect_icache=1" &
        done
        sleep 1
        wait_cpu_low $wait_cpu_percent
        

        # Miss rate used for both online and offline method.
        # Confusingly, the offline method requires an upper limit, so the csv presents correct-prediction rates 
        # rather than misprediction rates, and the threshold is the max correct prediction rate,
        # where all branches below that rate are prefetch candidates.
        for miss_rate in .99 0.5 #0.4 0.3
        do
            hitrate_max=`bc <<< "1-$miss_rate"`  # hit rate
            dp_uoc_mispred_rate="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_enable=1 --top_mispred_br_resteer_coverage=$hitrate_max --top_mispred_br_filepath=$bottom_correct_pred_rate_filepath"
            dp_uoc_online="$baseline_fdip_on --uoc_zero_latency_pref=1 --uoc_pref=1 --fdip_dual_path_pref_uoc_online_enable=1 --fdip_dual_path_pref_uoc_online_mispred_threshold=$miss_rate"
            
            ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_MISPRED_RATE${miss_rate}_ZL "$dp_uoc_mispred_rate" &
            # Online method uses miss rate as threshold
            ~/scarab_out/runExp.sh $app $uoc_size _UOCPRF_DP_UOC_ONLINE_MR${miss_rate}_ZL "$dp_uoc_online" &
        done
        sleep 1
        wait_cpu_low $wait_cpu_percent
    done
    sleep 1
    wait_cpu_low $wait_cpu_percent
    # compare IPC and UOC hit rate with no DP -- hopefully should be slightly higher.
done
