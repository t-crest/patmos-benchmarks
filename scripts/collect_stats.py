#!/usr/bin/env python

from datetime import datetime
import sys
import os
import shutil
import re
import argparse
from ConfigParser import RawConfigParser

config = RawConfigParser()
config.read("collect_stats.cfg")

# Build dir of the benchmarks repo
BUILDDIR = config.get("dirs", "builddir")
# Root dir for collected stats files
STATSDIR = config.get("dirs", "statsdir")
# Create subdir per date+time in stats dir?
CREATE_SUBDIRS = config.getboolean("dirs", "create_subdirs")
# Folder to collect final CSV files 
if config.has_option("dirs", "csvdir"):
    COLLECT_CSV_DIR = config.get("dirs", "csvdir")
else:
    COLLECT_CSV_DIR = None


class StatsParser:
    def __init__(self, filename):
	# Map of instruction -> fetched, retired, discared
	self.instructions = { }
	# Map of method -> hits, misses
	self.calls = { }
	self.cycles = 0
	# Regex for matching instruction stats
	self.re_instr = re.compile("^ *(\w+): +(\d+) +(\d+) +(\d+) +(\d+) +(\d+) +(\d+) *(.*)$")
	# Regex for matching method cache stats
	self.re_mc = re.compile("^ *0x([0-9a-fA-F]+): +(\d+) +(\d+) +<.+:([0-9a-zA-Z_]+):.+> *$")
	self._setName(filename)
	self._parse(filename)
    
    def _setName(self, filename):
	self.filename = filename
	name = os.path.basename(filename).replace(".stats", "")
	self.name = name.replace("mibench-", "")

    def _parse(self, filename):
	""" Process filename and append data in the file to the internal maps """
	f = open(filename)
	
	for line in f:
	    if line.startswith("Cyc :"):
		self.cycles = int(line.strip("Cyc: "))
	    if line.startswith("Instruction Statistics:"): 
		break
	for line in f:
	    if line.find("operation:") >= 0:
		continue
	    m = self.re_instr.match(line)
	    if m is None:
		break
	    instr = m.group(1)
	    if instr == "bubbles":
		break
	    
	    fetched = int(m.group(2)) + int(m.group(5))
	    retired = int(m.group(3)) + int(m.group(6))
	    discard = int(m.group(4)) + int(m.group(7))
	    self.instructions[instr] = fetched, retired, discard, m.group(8).strip()
	
	for line in f:
	    if line.startswith("Method Cache Statistics:"):
		break
	for line in f:
	    if line.find("Method:") >= 0:
		break
	for line in f:
	    if line == "\n": 
		break
	    m = self.re_mc.match(line)
	    if m is None:
		continue
	    method = m.group(4)

	    self.calls[method] = int(m.group(2)), int(m.group(3))

	f.close()
	
    
    def getInstructionNames(self):
	return self.instructions.keys()

    def getFunctionNames(self):
	return self.calls.keys()

    def getInstruction(self, instruction):
	try:
	    return self.instructions[instruction]
	except:
	    return 0, 0, 0, ""

    def getCalls(self, method):
	try:
	    return self.calls[method]
	except:
	    return 0, 0

    def getCycles(self):
	return self.cycles

    def getName(self):
	return self.name

    def getBinaryFilename(self):
	filename = os.path.dirname(self.filename) + "/" + self.name
	if os.path.isfile(filename):
	    return filename
	return None

def createStatsDir(d):
    dirname = STATSDIR
    if CREATE_SUBDIRS:
	dirname = dirname + "/" + d.strftime("%Y-%m-%d_%H-%M")
    if os.path.exists(dirname):
	shutil.rmtree(dirname)
    os.makedirs(dirname)
    return dirname

def collectStatFiles(basedir, statsdir):
    statfiles = []
    for root, dirs, files in os.walk(basedir):
	for name in dirs[:]:
	    if os.path.realpath(os.path.join(root,name)) == os.path.realpath(STATSDIR):
		dirs.remove(name)
		break
	for name in files:
	    if not name.endswith(".stats"):
		continue
	    filename = os.path.join(root, name)
	    shutil.copy(filename, statsdir)
	    statfiles.append(filename)

    return statfiles

def mergeInstrStats(totalPairs, stats):
    if stats == "":
	return totalPairs

    # Regex for matching instruction stat name-value-pairs
    re_statpair = re.compile("^ *(.*): (\d+) *$")

    # merge totalStats and stats, assume they are a comma-separated list of "<name>: <number>" pairs
    def mkpairs(s):
	m = re_statpair.match(s)
	if not m:
	    print "Invalid instruction stats: ", s
	    return "Invalid", 0 
	return m.group(1), int(m.group(2))

    statsPairs = map(mkpairs, stats.split(","))
    totalKeys = set([x[0] for x in totalPairs])
    statsKeys = set([x[0] for x in statsPairs])
    merged = []
    
    while len(totalPairs) > 0 or len(statsPairs) > 0:
	if len(totalPairs) == 0:
	    merged.extend(statsPairs)
	    break
	if len(statsPairs) == 0:
	    merged.extend(totalPairs)
	    break
	statsKey, statsValue = statsPairs[0]
	totalKey, totalValue = totalPairs[0]
	if statsKey == totalKey:
	    merged.append( (totalKey, totalValue + statsValue) )
	elif not statsKey in totalKeys:
	    merged.append( (statsKey, statsValue) )
	elif not totalKey in statsKeys:
	    merged.append( (totalKey, totalValue) )
	else:
	    print "Error: Keys in wrong order in " + str(totalPairs) + "; " + str(statsPairs)
	    return merged
	totalPairs = totalPairs[1:]
	statsPairs = statsPairs[1:]

    return merged

def writeStatsCSV(outfile, stats, comment):
    f = open(outfile, "w")

    # write names of benchmarks as header, and collect total instruction count
    instrCnt = 0
    for stat in stats:
	if not stat.getName().startswith("torture"):
	    f.write("," + stat.getName())
	fetched, retired, discared, tmp = stat.getInstruction("all")
	instrCnt = instrCnt + fetched
    f.write(",Total,Percent,\"Instruction Stats\"") 
    f.write("\n")

    first = stats[0]
    instructions = first.getInstructionNames()
    instructions.sort()
    try:
	instructions.remove("all")
    except:
	pass
    instructions.append("all")
    
    # write instruction stats, collect totals
    for instr in instructions:
	f.write(instr)
	
	total = 0
	line = ""
	totalStats = ""
	for stat in stats:
	    fetched, retired, discarded, s = stat.getInstruction(instr)
	    total = total + fetched
	    totalStats = mergeInstrStats(totalStats, s)
	    if not stat.getName().startswith("torture"):
		line = line + "," + str(fetched)

	f.write(line)
	f.write("," + str(total) + "," + "%.5f"%(float(total)/instrCnt))
	f.write("," + instr + ",\"" + ", ".join([x[0] + ": " + str(x[1]) for x in totalStats]) + "\"")
	f.write("\n")

    f.write("\n")

    # TODO define a filter function instead, use consistently
    filtered_stats = [x for x in stats if not x.getName().startswith("torture")]

    # Write binary size
    f.write("\"Binary size (KiB)\"")
    for stat in filtered_stats:
	f.write(",")
	filename = stat.getBinaryFilename()
	if filename is None:
	    f.write("0")
	else:
	    filesize = os.path.getsize(filename)
	    f.write("%.2f"%(float(filesize)/1024.0))
    f.write("\n")

    # Write total cycles
    f.write("Cycles")
    for stat in filtered_stats:
	f.write("," + str(stat.getCycles()))
    f.write("\n")

    # Write discarded instructions in %
    f.write("\"Discarded (%)\"")
    for stat in filtered_stats:
	fetched, retired, discarded, tmp = stat.getInstruction("all")
	if fetched > 0:
	    f.write("," + "%.5f"%(float(discarded)/fetched))
	else:
	    f.write(",0")
    f.write("\n")

    f.write("\n")
    
    # Write runtime/libc library call stats
    methods = [
	"__ashldi3", "__lshrdi3", "__clzsi2", "__divsi3", "__divdi3", 
	"__modsi3", "__moddi3", "__umodsi3", "__umoddi3",
	"__muldi3", 
	"__udivsi3", "__udivdi3",
	"__divmodsi4", "__divmoddi4", "__udivmodsi4", "__udivmoddi4",
        "sin", "cos", 
	"__adddf3", "__subdf3", "__divdf3", "__muldf3", "__mulsf3",
	"__unorddf2", "__gedf2", "__eqdf2", "__ltdf2", "__nedf2", "__gtdf2",
	"__fixdfsi", "__floatsidf", "__floatsisf", "__floatunsidf", "__floatunsisf",
	"__extendsfdf2", "__truncdfsf2",
        "malloc", "memmove", "_malloc_r", "_free_r",
	"fopen", "fclose", "__sread", "__swrite", "__sclose", "__sinit", 
	"printf", "_vfprintf_r", "__sprintf_r", 
              ]

    for method in methods:
	f.write(method)
	total = 0
	for stat in stats:
	    hits, misses = stat.getCalls(method)
	    if not stat.getName().startswith("torture"):
		f.write("," + str(hits+misses))
	    total += hits+misses
	f.write(","+str(total))
	f.write("\n")

    # write (optional) comment about setup
    if comment:
	f.write("\n")
	f.write("\"Benchmark Setup\",\"")
	f.write(comment)
	f.write("\"\n")

    f.close()


parser = argparse.ArgumentParser("Collect .stats file from a benchmark evaluation run.")
parser.add_argument("setupdesc", nargs='?', help="Description for the tested benchmark setup.")
parser.add_argument("-c", "--collect", action="store_true", help="Collect result CSV into csvdir.")

args = parser.parse_args()


d = datetime.now()

# Create a new stats dir and collect all stats files
statsdir = createStatsDir(d)
statfiles = collectStatFiles(BUILDDIR, statsdir)

# Collect stats from stats files and write them into a CSV file
stats = [StatsParser(filename) for filename in statfiles]
print "Writing csv file to " + statsdir + "/instructions.csv"
writeStatsCSV(statsdir+"/instructions.csv", stats, args.setupdesc)

if args.collect:
    if not COLLECT_CSV_DIR:
	print "csvdir not set, not collecting csv file."
	sys.exit(1)
    if not os.path.exists(COLLECT_CSV_DIR):
	os.makedirs(COLLECT_CSV_DIR)
    csvfile = COLLECT_CSV_DIR+"/instructions-" + d.strftime("%Y-%m-%d_%H-%M") + ".csv"
    print "Copying csv file to " + csvfile
    shutil.copyfile(statsdir+"/instructions.csv", csvfile)

