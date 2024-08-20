#!/usr/bin/env python
import os
import re

import fire

version_filepath = os.path.join('.', 'pubspec.yaml')
# version_pattern = re.compile(fr'^version:\s*\d+.\d+.\d+\+(\d+)?$')
regex = r"^version:\s*\d+.\d+.\d+\+(\d+)?$"


def write_version_file(fileContent):
    with open(version_filepath, 'w') as version_file:
        version_file.write(fileContent)


def increment():
    version_lines = ""
    with open(version_filepath, 'r') as version_file:
        version_lines = version_file.read()

    matches = re.finditer(regex, version_lines, re.MULTILINE)

    for matchNum, match in enumerate(matches, start=1):

        print("Match {matchNum} was found at {start}-{end}: {match}".format(
            matchNum=matchNum, start=match.start(), end=match.end(), match=match.group()))

        for groupNum in range(0, len(match.groups())):
            groupNum = groupNum + 1
            print("Group {groupNum} found at {start}-{end}: {group}".format(groupNum=groupNum,
                  start=match.start(groupNum), end=match.end(groupNum), group=match.group(groupNum)))
            buildNumber = match.group(groupNum)
            newBuildNumber = int(buildNumber) + 1
            newVersionString = match.group().removesuffix(buildNumber) + str(newBuildNumber)
            print(newVersionString)

            write_version_file(version_lines.replace(
                match.group(), newVersionString))
            exit(0)


if __name__ == "__main__":
    increment()
