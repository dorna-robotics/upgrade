def update_rc(pattern=["sudo /home/dorna/app/a.out &\n"], path="/etc/rc.local", msg=""):	
	# look for pattern
	with open(path, "r") as f:
		lines = f.readlines()
		pattern_write = [p for p in pattern if all([p[-12:] not in l for l in lines])]

	if pattern_write:
		# search for exit(0)
		i = 0
		for l in lines:
			if "exit 0\n" in l:
				print("yes: ", l)
				break
			else:
				i+=1
		lines = lines[0:i] + [msg+"\n"] + pattern_write + lines[i:]
		with open(path, "w") as f:
			for l in lines:
				f.write(l)

if __name__ == '__main__':
	#update_rc()
	pass
