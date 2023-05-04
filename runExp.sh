#!/bin/bash

# create folder, run experiment
# Usage: ./runExp.sh appname uopCacheUopCapacity [folderSuffix] [scarabCmdOptions] [instLimit] [scarabPath] [destDir]
# supported apps are in traces dictionary below
# if folder with the experiment name already exists then skip

app=$1
uopCacheUopCapacity=$2  # Number of uops
folderSuffix=$3
scarabCmdOptions=$4
instLimit=$5
instLimit=${instLimit:=90000000}
scarabPath=$6
scarabPath=${scarabPath:="/soe/pebraun/scarab_hlitz/src/scarab"}
destDir=$7
destDir=${destDir:=/soe/pebraun/scarab_out}

cacheLineSize=64
declare -A memtraces=(["gcc"]="/mnt/sdc/gdrive_peter/sdc_traces/drmemtrace.cc1plus.528857.2380.dir/trace/drmemtrace.cc1plus.528857.7678.trace" \
    ["clang"]="/mnt/sdc/gdrive_peter/sdc_traces/drmemtrace.clang.529315.7723.dir/trace/drmemtrace.clang.529315.9674.trace" \
    ["mcf"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/mcf/drmemtrace.mcf_s_base.mytest-m64.24733.9129.dir/trace/drmemtrace.mcf_s_base.mytest-m64.24733.6671.trace" \
    ["leela"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/641.leela_s/run_base_refspeed_mytest-m64.0000/drmemtrace.leela_s_base.mytest-m64.39791.7505.dir/trace/drmemtrace.leela_s_base.mytest-m64.39791.7764.trace" \
    ["xz"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/657.xz_s/run_base_refspeed_mytest-m64.0001/drmemtrace.xz_s_base.mytest-m64.239906.2899.dir/trace/drmemtrace.xz_s_base.mytest-m64.239906.4546.trace" \
    ["xalancbmk"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/623.xalancbmk_s/run_base_refspeed_mytest-m64.0000/drmemtrace.xalancbmk_s_base.mytest-m64.24368.5675.dir/trace/drmemtrace.xalancbmk_s_base.mytest-m64.24368.3037.trace" \
    ["perlbench"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/600.perlbench_s/run/run_base_refspeed_mytest-m64.0001/drmemtrace.perlbench_s_base.mytest-m64.1164615.9363.dir/trace/drmemtrace.perlbench_s_base.mytest-m64.1164615.1549.trace.gz" \
    ["x264"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/drmemtrace.x264.1167728.2947.dir/trace/drmemtrace.x264.1167728.8729.trace.gz" \
    ["x264_bb"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/drmemtrace.x264.1397224.0632.dir/trace/drmemtrace.x264.1397224.1165.trace.gz" \
    ["deepsjeng"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/drmemtrace.deepsjeng.1760967.1399.dir/trace/drmemtrace.deepsjeng.1760967.2802.trace.gz" \
    ["exchange2"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/drmemtrace.exchange2.1762259.2461.dir/trace/drmemtrace.exchange2.1762259.6495.trace.gz" \
    ["omnetpp"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/drmemtrace.omnetpp.1760918.6100.dir/trace/drmemtrace.omnetpp.1760918.9972.trace.gz" \
    ["specrand_i"]="/mnt/sdc/gdrive_peter/traces/spec_memtrace/drmemtrace.specrand_i.1762385.3550.dir/trace/drmemtrace.specrand_i.1762385.1929.trace.gz" \
    ["bc"]="/mnt/sdc/gdrive_peter/traces/gap_memtrace/drmemtrace.bc.2046876.2475.dir/trace/drmemtrace.bc.2046876.6789.trace.gz" \
    ["bfs"]="/mnt/sdc/gdrive_peter/traces/gap_memtrace/drmemtrace.bfs.2046844.4405.dir/trace/drmemtrace.bfs.2046844.4383.trace.gz" \
    ["cc"]="/mnt/sdc/gdrive_peter/traces/gap_memtrace/drmemtrace.cc.2046937.8501.dir/trace/drmemtrace.cc.2046937.6803.trace.gz" \
    ["pr"]="/mnt/sdc/gdrive_peter/traces/gap_memtrace/drmemtrace.pr.2047003.4238.dir/trace/drmemtrace.pr.2047003.7003.trace.gz" \
    ["sssp"]="/mnt/sdc/gdrive_peter/traces/gap_memtrace/drmemtrace.sssp.2046968.2819.dir/trace/drmemtrace.sssp.2046968.7697.trace.gz" \
    ["tc"]="/mnt/sdc/gdrive_peter/traces/gap_memtrace/drmemtrace.tc.2046906.3333.dir/trace/drmemtrace.tc.2046906.3315.trace.gz" \
    ["verilator"]="/mnt/sdc/gdrive_peter/traces/verilator_memtrace/trace/trace.gz" \
    ["xgboost"]="/mnt/sdc/gdrive_peter/traces/xgboost/drmemtrace.mymodel.02818.9325.dir/trace/drmemtrace.mymodel.02818.2704.trace.gz" \
    ["deepsjeng_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.deepsjeng.553743.1618.dir/trace/drmemtrace.deepsjeng.553743.6815.trace.gz" \
    ["exchange2_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.exchange2.553888.1738.dir/trace/drmemtrace.exchange2.553888.0626.trace.gz" \
    ["leela_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.leela_s_base.mytest-m64.555086.8417.dir/trace/drmemtrace.leela_s_base.mytest-m64.555086.2935.trace.gz" \
    ["mcf_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.mcf_s_base.mytest-m64.554166.9011.dir/trace/drmemtrace.mcf_s_base.mytest-m64.554166.7956.trace.gz" \
    ["omnetpp_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.omnetpp.552936.5555.dir/trace/drmemtrace.omnetpp.552936.3514.trace.gz" \
    ["perlbench_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.perlbench_s_base.mytest-m64.554262.0160.dir/trace/drmemtrace.perlbench_s_base.mytest-m64.554262.9223.trace.gz" \
    ["gcc_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.sgcc_base.mytest-m64.555062.6619.dir/trace/drmemtrace.sgcc_base.mytest-m64.555062.3859.trace.gz" \
    ["specrand_i_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.specrand_i.553922.3230.dir/trace/drmemtrace.specrand_i.553922.2837.trace.gz" \
    ["x264_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.x264.555077.8155.dir/trace/drmemtrace.x264.555077.8068.trace.gz" \
    ["xalancbmk_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.xalancbmk_s_base.mytest-m64.555084.9837.dir/trace/drmemtrace.xalancbmk_s_base.mytest-m64.555084.7482.trace.gz" \
    ["xz_cse"]="/mnt/sdc/gdrive_peter/cse220_traces/drmemtrace.xz_s_base.mytest-m64.555088.2223.dir/trace/drmemtrace.xz_s_base.mytest-m64.555088.7681.trace.gz")

# can add bolted apps as well
declare -A pttraces=(["cassandra"]="/mnt/sdc/gdrive_peter/traces/cassandra/trace.gz" \
    ["kafka"]="/mnt/sdc/gdrive_peter/traces/kafka/trace.gz" \
    ["drupal"]="/mnt/sdc/gdrive_peter/traces/drupal/trace.gz" \
    ["finagle-chirper"]="/mnt/sdc/gdrive_peter/traces/finagle-chirper/trace.gz" \
    ["finagle-http"]="/mnt/sdc/gdrive_peter/traces/finagle-http/trace.gz" \
    ["mediawiki"]="/mnt/sdc/gdrive_peter/traces/mediawiki/trace.gz" \
    ["mysql"]="/mnt/sdc/gdrive_peter/traces/mysql/mysql_pt.gz" \
    ["redis"]="/mnt/sdc/gdrive_peter/traces/redis/redis_pt.gz" \
    ["tomcat"]="/mnt/sdc/gdrive_peter/traces/tomcat/trace.gz" \
    ["wordpress"]="/mnt/sdc/gdrive_peter/traces/wordpress/trace.gz" \
    ["verilator_pt"]="/mnt/sdc/gdrive_peter/traces/verilator/trace.gz" \
    ["clang_new"]="/mnt/sdc/gdrive_peter/traces/four-new-traces/clang.gz" \
    ["mysql_new"]="/mnt/sdc/gdrive_peter/traces/four-new-traces/mysql.gz" \
    ["postgres"]="/mnt/sdc/gdrive_peter/traces/four-new-traces/postgres.gz" \
    ["python"]="/mnt/sdc/gdrive_peter/traces/four-new-traces/python.gz")

trace=${memtraces[$app]}
common_scarab_params="--bp_mech=tagescl --perfect_crs=1 --fetch_off_path_ops=1 --perfect_nt_btb=0  --btb_entries=4096 --inst_limit $instLimit --uop_cache_uop_capacity=$uopCacheUopCapacity $scarabCmdOptions "
if [ -z $trace ]; then  # maybe PT trace
    trace=${pttraces[$app]}
    if [ -z $trace ]; then
        echo "Unsupported application $trace. Skipping."
        exit
    fi
    output_cmd="$scarabPath --frontend=pt --cbp_trace_r0=$trace $common_scarab_params"
else  # memtrace
    modules=`echo $trace | sed "s/^\(.*\)\/trace\/.*trace.*/\1\/raw\//"`
    output_cmd="$scarabPath --frontend=memtrace --cbp_trace_r0=$trace --memtrace_modules_log=$modules $common_scarab_params"
fi

destFolder=$destDir/${app}_`expr $instLimit / 1000000`M_UC${uopCacheUopCapacity}${folderSuffix}
if [ -d $destFolder ]; then
    echo "$destFolder already exists. Skipping"
    exit
fi

mkdir $destFolder
cp ~/scarab_out/PARAMS.in $destFolder
cd $destFolder

echo $output_cmd
$output_cmd
