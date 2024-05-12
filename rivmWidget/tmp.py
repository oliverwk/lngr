import re
f = open("/Users/mwk/iOS-Projecten/lngr/rivmWidget/qoutes.swift", "r")
txt = f.read()
f.close()

txt = re.sub("^\s", "\"},{\"", txt)

txt = re.sub("^\s", ":"", txt)

print(txt)

"""
{"FF
:"
"},

"""
