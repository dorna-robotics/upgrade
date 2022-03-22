from crontab import CronTab

def main():
	cron = CronTab("dorna")
	# search for existing job
	for job in cron:
		if job.comment == "dorna_lab":
			cron.remove(job)

	# add the new comment
	job = cron.new("sudo python3 /home/dorna/Downloads/dorna_lab/dorna_lab/application.py", "dorna_lab")
	job.every_reboot()
	cron.write()

if __name__ == '__main__':
	main()
