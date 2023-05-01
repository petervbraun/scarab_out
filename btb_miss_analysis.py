import re
import os
from dataclasses import dataclass

# Held in a map. indexed by op
@dataclass
class BtbMissEvent:
    """Class that describes a BTB miss event."""
    cycle: int
    br_pc: int
    targ: int
    bt: str

base_dir = '/soe/pebraun/scarab_out/'
deepsjeng_path = os.path.join(base_dir, 'deepsjeng5Kinst.out')
dpsjg_90M_path= os.path.join(base_dir, 'deepsjeng90Minst.out')

# Parse debug trace file. -- Now MISPRED

btb_miss_uoc_hit_instr = set()  # Added to set when first seen. 
btb_miss_uoc_hit_count = 0
# UOC hits that occur after a BTB-missing branch has already been seen before
# If this is zero, then the only time we hit in UOC after BTB miss is with a NEW branch
btb_miss_uoc_hit_seen_count = 0
btb_miss = 0
btb_miss_btb_stat = 0
br_types = {}
targ = {}

unfinished_events = {}  # Indexed by TARGET, so we can find it when target is fetched.
incomplete_events = 0

rgx_str_resteer_issued='.*C=([0-9]*).*op_addr=([^,]*), cf_type=([A-Z_]*).*resteer_type=btb_miss.*npc=(.*)$'
rgx_btb_miss='.*btb_miss:1.*'

with open(dpsjg_90M_path) as f:
    while line := f.readline():
        if re.search(rgx_btb_miss, line):
            btb_miss_btb_stat += 1
        match = re.match(rgx_str_resteer_issued, line)
        if match:
            btb_miss += 1
            cycle = int(match.group(1))
            br_addr = int(match.group(2), 16)
            bt = match.group(3)
            # if bt != 'CF_CBR':
            #     continue
            npc = int(match.group(4), 16)
            if npc in unfinished_events:
                prev_event = unfinished_events.pop(npc)  # remove the previous event - maybe it hit the cur_pw so did not show in the trace.
                incomplete_events += 1
                # print(f'Error: npc in unfinished events. cycle={cycle}, br={hex(br_addr)}, npc={hex(npc)}')
                # print(f'Prev Event: cycle={(prev_event.cycle)}, br={hex(prev_event.br_pc)}, npc={hex(prev_event.targ)}')
            else:
                unfinished_events[npc] = BtbMissEvent(cycle, br_addr, npc, bt)

        uoc_access_match = re.match('.*UOC ([^\.]*)\. addr=([^,]*),.*', line)
        if uoc_access_match:
            pc = int(uoc_access_match.group(2), 16)
            if pc in unfinished_events:
                event = unfinished_events.pop(pc)  # removes element
                if re.search('UOC hit', line):
                    if event.br_pc in btb_miss_uoc_hit_instr:
                        btb_miss_uoc_hit_seen_count += 1
                    btb_miss_uoc_hit_instr.add(event.br_pc)
                    btb_miss_uoc_hit_count += 1
                    if event.bt in br_types:
                        br_types[event.bt] += 1
                    else:
                        br_types[event.bt] = 1
                    if npc in targ:
                        targ[npc] += 1
                    else:
                        targ[npc] = 1


# Should have ~200K total BTB misses for deepsjeng.
print(f'seen_bmuh={btb_miss_uoc_hit_seen_count}, total_bmuh={btb_miss_uoc_hit_count}, btb_misses={btb_miss}')
print(f'distinct_bmuh_br={len(btb_miss_uoc_hit_instr)}, distinct_bmuh_targ={len(targ)}')
print(f'br_types_bmuh={br_types}')
print(f'targ_counts={targ.values()}')
print(f'incomplete_events={incomplete_events}')
# Values just for CF_CALLS? If CF_CALLS are the issue, can we verify that it is because it's lots of br with same targets