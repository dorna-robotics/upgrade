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
		split_cmd = shlex.split("sh firmware")
		self.p = subprocess.Popen(split_cmd,stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
		while True:
			output = self.p.stdout.readline()
			error = self.p.stderr.readline()
			print("error: ", error)
			print("output: ", output)
			if self.p.poll() is not None and output == b'':
			    break
			if output:
				print(output)
			time.sleep(0.001)

		retval = self.p.poll()



if __name__ == '__main__':
	f = firmware().update()