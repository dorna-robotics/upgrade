import subprocess


class firmware(object):
	"""docstring for firmware"""
	def __init__(self, url, path):
		super(firmware, self).__init__()
		self.url = url
		self.path = path

	"""
	firmware.sh
	"""
	def update()
		process = subprocess.Popen(["sudo", "sh", "firmware"],stdout=subprocess.PIPE, shell=True)
		process.wait()
		print("done")
		