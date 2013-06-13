#!/usr/bin/env python

from datetime import datetime
import sys
import os
import shutil
import re
import csv
from ConfigParser import RawConfigParser

config = RawConfigParser()
config.read("collect_stats.cfg")

# Folder containing collected CSV files 
COLLECT_CSV_DIR = config.get("dirs", "csvdir")
# Folder to generate html output to
HTML_DIR = config.get("dirs", "htmldir")

class HTMLBuilder:
    def writeHeader(self, f, title):
	f.write("<html>\n")
	f.write("<head>\n")
	f.write("<title>" + title + "</title>\n")
	f.write("</head>\n")
	f.write("<body>\n")

    def writeFooter(self, f):
	f.write("</body>\n")
	f.write("</html>\n")

    def writeTableHeader(self, f, headers):
	f.write("<table>\n")
	f.write("<tr>\n  ")
	
	f.write("</tr>\n")

    def writeTableRow(self, f, headers, data):
	f.write("<tr>\n  ")

	f.write("</tr>")

    def writeTableFooter(self, f):
	f.write("</table>\n")

class ReportBuilder(HTMLBuilder):
    def __init__(self, csv):
	self.description = None
	self.cycles = {}
	self.benchmarks = []
	self.csv = []
	self.colPercent = -1
	self._parseCSV(csv)
	
    def _parseCSV(self, csv):
	for row in csv:
	    # find table header
	    if len(row) > 2 and row[0] == "" and len(self.benchmarks) == 0:
		for i in range(1, len(row)-1):
		    if row[i] == "Total":
			self.colPercent = i + 1
			break
		    self.benchmarks.append(row[i])

	    # find description row
	    if len(row) > 1 and row[0] == "Benchmark Setup":
		self.description = row[1]
	    # find total cycles
	    if len(row) > 1 and row[0] == "Cycles":
		self.cycles = row
	    # append row
	    self.csv.append(row)

	    

    def getDescription(self, default="unnamed"):
	if self.description:
	    return self.description
	return default

    def getCyclesMap(self):
	# TODO get map of total cycles per benchmark and total
	pass

    def write(self, htmlfile):
	# TODO open htmlfile, write header, content, footer
	f = open(htmlfile, "w")
	self.writeHeader(f, self.getDescription())
	
	f.write("<h1>Benchmark Report for Setup: " + self.getDescription() + "</h1>\n")

	f.write("<h2>Instructions</h2>\n")

	# write instructions table
	
	
	f.write("<h2>Runtime Function Calls</h2>\n")

	# write function call table

	self.writeFooter(f)
	f.close()


class StatsBuilder:
    def __init__(self):
	self.header = set()
	self.reports = []

    def addReport(self, report, basename):
	# add basename and totals to report list
	pass


    def write(self, statsfile):
	f = open(statsfile, "w")
	
	f.close()

class IndexBuilder(HTMLBuilder, StatsBuilder):

    def write(self, htmlfile):
	f = open(htmlfile, "w")
	self.writeHeader(f, "Reports")

	self.writeFooter(f)
	f.close()
	
if not os.path.exists(HTML_DIR):
    os.makedirs(HTML_DIR)

# rebuild csvdir/stats.csv file containing all total/per-benchmark cycles per instructions.csv file
SB = StatsBuilder()

# rebuild index.html file containing a list of all results with name of setup, date, percentages per benchmark and total to last results (cycles), link to html file
IB = IndexBuilder()

# check all instructions-*.csv file in csvdir, check if htmldir/instructions-*.html exists, rebuild if not
csvfiles = [COLLECT_CSV_DIR + '/' + f for f in os.listdir(COLLECT_CSV_DIR) if f.endswith('.csv')]
for csvfile in csvfiles:
    base = os.path.basename(csvfile)
    name = os.path.splitext(base)[0]

    if name == "stats": continue
    if not name.startswith("instructions"): continue

    with open(csvfile, 'rb') as f:
	csvreader = csv.reader(f, delimiter = ',', quotechar='"')
	
	csvdata = [row for row in csvreader]

	RB = ReportBuilder(csvdata)

	SB.addReport(RB, name)
	IB.addReport(RB, name)

	htmlfile = HTML_DIR + "/" + name + ".html"
	if not os.path.exists(htmlfile):
	    RB.write(htmlfile)

SB.write(COLLECT_CSV_DIR + "/stats.csv")
IB.write(HTML_DIR + "/index.html")

