#!/usr/bin/python

'''
Helper method to count how many application versions your account has, or how many there are for a given application.
Usage:
	>>> python countApplicationVersions.py
	650
	>>> python countApplicationVersions.py "samsung-prototype"
	223

	Can be used along with elastic beanstalk "labs" API to delete old versions. (note this CLI API requires awsebcli tools: sudo pip install awsebcli)
	AWS has an elastic beanstalk application version limit, defaults to 500, so programmatic deletion is necessary.
	>>> eb labs cleanup-versions --older-than 3 --num-to-leave 30 "samsung-prototype" --debug
'''

import sys, os, boto3

def main():
	try:
		application = sys.argv[1]
	except:
		application = None

	eb = boto3.client('elasticbeanstalk')

	versions = eb.describe_application_versions();

	if application:
		count = 0
		for version in versions['ApplicationVersions']:
			if version['ApplicationName'] == application:
				count += 1
		print count

	else:
		print len(versions['ApplicationVersions'])

main()
