import sys
import filecmp
a = sys.argv[1]
b = sys.argv[2]
print filecmp.cmp(a,b)
