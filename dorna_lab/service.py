import argparse
from crontab import CronTab

def main(name, path, comment):
	cron = CronTab(name)
	# search for existing job
	for job in cron:
		if job.comment == comment:
			cron.remove(job)

	# add the new comment
	job = cron.new("sudo python3 "+path , comment)
	job.every_reboot()
	cron.write()

if __name__ == '__main__':
	# Initialize parser
	parser = argparse.ArgumentParser()

	# Adding optional argument
	parser.add_argument("-n", "--Name")
	parser.add_argument("-p", "--Path")
	parser.add_argument("-c", "--Comment")

	# Read arguments from command line
	args = parser.parse_args()
	
	print(args.Name, args.Path, args.Comment)
	main(args.Name, args.Path, args.Comment)
