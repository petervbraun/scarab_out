#!/bin/bash
source wait_cpu_low.sh

gap_apps="bc bfs pr sssp tc"
pt_apps="cassandra kafka drupal finagle-chirper finagle-http mediawiki tomcat wordpress verilator_pt clang_new mysql_new python" #redis postgres mysql
older_ok_apps="gcc clang perlbench deepsjeng xgboost"
apps="$pt_apps $older_ok_apps"

# What are the "cliffs" in performance?
# i.e. what are the hot code sizes for GAP?
#for app in $gap_apps exchange2; do
#    for uoc_size in 0 8 16 32 64 128 256 512 1024 2048 4096; do
#        ~/scarab_out/runExp.sh $app $uoc_size "" "" &
#    done
#done

# Are there substantial gaps between uop cache and perfect uop cache?
# i.e. is there any opportunity for a prefetcher?
for app in $apps; do
    for uoc_size in 0 1024 2048 4096 8192; do
        ~/scarab_out/runExp.sh $app $uoc_size "" "" &
        ~/scarab_out/runExp.sh $app $uoc_size _PERF_IC "--perfect_icache=1" &
        #~/scarab_out/runExp.sh $app $uoc_size _PACKING_DISABLED "--map_stage_consume_from_icache_and_uoc_same_cycle=0" &
    done
    ~/scarab_out/runExp.sh $app 0 _ORACLE_PERFECT "--oracle_perfect_uop_cache=1" &

    # 1) When the BTB is very large, does misprediction resteer latency start to dominate performance?
    #    State of the art processors have large BTBs. We can leverage PDEDE to argue for even larger state of the art BTBs.
    #    64K / 128K / 256K. Current default is 8K total for BTB/IBP.
    # 2) Any switch from the uop cache to the legacy frontend should cause a performance hit (time to fetch from icache + decode).
    #    With a perfect BP/BTB/IBTB/CRS FDIP will prefetch all bbls into the icache (no icache misses).
    #    We expect that no UOC will provide the same performance as a perfect UOC, and the UOC to IC switches the worse performance.

    for uoc_size in 0 1024 2048 4096; do
        ~/scarab_out/runExp.sh $app $uoc_size _PERF_BP_BTB_IBP_CRS_IC "--perfect_bp=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --perfect_icache=1" &
        ~/scarab_out/runExp.sh $app $uoc_size _PERF_BP_BTB_IBP_CRS "--perfect_bp=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1" &
    done

    ~/scarab_out/runExp.sh $app 0 _PERF_BP_BTB_IBP_CRS_ORACLE_PERFECT "--perfect_bp=1 --perfect_btb=1 --perfect_ibp=1 --perfect_crs=1 --oracle_perfect_uop_cache=1" &

    # Distinguish the different performance effects of the uop cache.
    # Resteer Cycles that were saved or could have been saved if fetching target from UOC
    # Cycles that were lost due to switching from icache to uop cache
    # "Packing efficiency," i.e. a subset of benefit of a uop queue (probably not useful info) 

    sleep 2
    wait_cpu_low 40
done


