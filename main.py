import subprocess
import shlex

class firmware(object):
	"""docstring for firmware"""
	def __init__(self, url=None, path=None):
		super(firmware, self).__init__()
		self.url = url
		self.path = path

	"""
	firmware.sh
	"""
	def update(self):
		split_cmd = shlex.split("sudo sh firmware")
		process = subprocess.Popen(split_cmd,stdout=subprocess.PIPE, shell=True)
		process.wait()
		print("done")


if __name__ == '__main__':
	f = firmware().update()