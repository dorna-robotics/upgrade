import argparse
from crontab import CronTab

def main(name, comment, path=None):
	print("crontab: ", name, comment, path)
	cron = CronTab(name)
	# search for existing job
	for job in cron:
		if job.comment == comment:
			cron.remove(job)

	if path:
		# add the new comment
		job = cron.new(path , comment)
		job.every_reboot()
	
	cron.write()

if __name__ == '__main__':
	# Initialize parser
	parser = argparse.ArgumentParser()

	# Adding optional argument
	parser.add_argument("-n", "--Name")
	parser.add_argument("-c", "--Comment")
	parser.add_argument("-p", "--Path")

	# Read arguments from command line
	args = parser.parse_args()
	
	main(args.Name, args.Comment, args.Path)
