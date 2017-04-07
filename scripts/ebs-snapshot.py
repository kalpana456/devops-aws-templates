#!/usr/bin/python

'''
Create an elastic block storage snapshot.
'''

import sys, boto3, datetime
from optparse import OptionParser

def main():
	default_description = "Backup " + datetime.datetime.now().isoformat()

	parser = OptionParser(usage="usage: %prog \"vol-xxxxxxx\" [options]", version="%prog 1.0")
	parser.add_option("-v", "--volume",
										dest="volume_id",
										help="The volume ID of the elastic block storage device to take a snapshot of")
	parser.add_option("-d", "--description",
										dest="description",
										default=default_description,
										help="Description of the backup",)
	parser.add_option("-D", "--dryRun",
										action="store_true",
										dest="dry_run",
										default=False,
										help="Do a dry run of the snapshot creation.",)

	(options, args) = parser.parse_args()

	if len(args) != 1:
		parser.print_help()
		parser.error("Wrong number of arguments")

	ec2 = boto3.resource('ec2')
	snapshot = ec2.create_snapshot(VolumeId=args[0], Description=options.description, DryRun=options.dry_run)

main()
