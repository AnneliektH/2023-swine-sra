srun --account=ctbrowngrp -p med2 -J fmg -t 48:00:00 -c 50 --pty bash
mamba activate branchwater

sourmash scripts fastmultigather \
all_MAG_path.txt \
/group/ctbrowngrp/sourmash-db/gtdb-rs214/gtdb-rs214-k21.zip \
-k 21 --scaled 10000 -m DNA -c 50 \
-o MAG_gtbd_tax.csv 