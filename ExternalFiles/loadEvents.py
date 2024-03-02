import os
import re


class LogEntry:
    def __init__(self, event_string, event_screen_number, event_time, event_file_name, event_type):
        self.event_string = event_string
        self.event_screen_number = event_screen_number
        self.event_time = event_time
        self.event_file_name = event_file_name
        self.event_type = event_type

    def __hash__(self):
        return hash(self.event_string, self.event_screen_number, self.event_time, self.event_file_name)

    def __eq__(self, other):
        return self.event_string == other.event_string and self.event_screen_number == other.event_screen_number and self.event_time == other.event_time and self.event_file_name == other.event_file_name


listOfFiles = sorted(os.listdir('./input'))
pattern = "*.jpg"

print(listOfFiles)
from datetime import datetime

format_string = "%Y-%m-%d-%H:%M:%S.%f"
comparison_format_string = "%Y-%m-%d-%H:%M:%S"
entry = listOfFiles[0]
event_string = re.search('{(.*)}', entry, re.IGNORECASE).group(1)
event_screen_number = re.search('_(\d)_', entry, re.IGNORECASE).group(1)
event_time = datetime.strptime(entry[0:23], format_string)

entry = listOfFiles[0]
print(event_string)
print(event_screen_number)
print(event_time)

log_entries = []
for entry in listOfFiles:
    event_string = re.search('{(.*)}', entry, re.IGNORECASE).group(1)
    event_screen_number = re.search('_(\d)_', entry, re.IGNORECASE).group(1)
    event_time = datetime.strptime(entry[0:23], format_string)
    event_file_name = entry
    event_type = "mouse" if "mouseDown" in event_string else "keyboard"
    logEntry = LogEntry(event_string, event_screen_number, event_time, event_file_name, event_type)
    log_entries.append(logEntry)


for logEntry in log_entries:
    print(logEntry.event_string)
    print(logEntry.event_screen_number)
    print(logEntry.event_time)
    print(logEntry.event_file_name)
  

print(f"Number of log entries: {len(log_entries)}")

duplicates = set()
filtered_log_entries = []
for logEntry in log_entries:
    event_time_string = datetime.strftime(logEntry.event_time, comparison_format_string)
    if event_time_string not in duplicates:
        filtered_log_entries.append(logEntry)
        duplicates.add(event_time_string)
    print(sorted(duplicates))
print(f"Number of filtered log entries: {len(filtered_log_entries)}")

screen_filtered_log_entries = [logEntry for logEntry in log_entries if logEntry.event_screen_number == "1"]
print(f"Number of screen filtered log entries: {len(screen_filtered_log_entries)}")


for logEntry in sorted(screen_filtered_log_entries, key=lambda logEntry: logEntry.event_time):
    print(logEntry.event_string)

