import argparse
from crontab import CronTab

def main(name, comment, path=None, command=None):
	print("crontab: ", name, comment, path)
	cron = CronTab(name)
	# search for existing job
	for job in cron:
		if job.comment == comment:
			cron.remove(job)

	if path and command:
		# add the new comment
		job = cron.new("sudo "+ command + " "+path , comment)
		job.every_reboot()
	
	cron.write()

if __name__ == '__main__':
	# Initialize parser
	parser = argparse.ArgumentParser()

	# Adding optional argument
	parser.add_argument("-n", "--Name")
	parser.add_argument("-c", "--Comment")
	parser.add_argument("-p", "--Path")
	parser.add_argument("-d", "--Command")

	# Read arguments from command line
	args = parser.parse_args()
	
	main(args.Name, args.Comment, args.Path, args.Command)
