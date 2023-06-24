#!/usr/bin/env python3

import os
import sys
from proxy.perldb import PerlDb

# The script can be launched as `python3 script.py`
args_to_skip = 0 if os.path.basename(__file__) == sys.argv[0] else 1
proxy = PerlDb(sys.argv[args_to_skip:])
exitcode = proxy.run()
sys.exit(exitcode)