def update_config(pattern=["dtoverlay=pi3-miniuart-bt\n", "enable_uart=1\n"], path="/boot/config.txt", msg=""):	
	# look for pattern
	with open(path, "r") as f:
		lines = f.readlines()
		pattern_write = [p for p in pattern if p not in lines ]

	if pattern_write:
		lines += [msg+"\n"] + pattern_write
		with open(path, "w") as f:
			for l in lines:
				f.write(l)

# write before exit(0)
def update_rc(pattern=["sudo /home/dorna/app/a.out &\n"], path="/etc/rc.local", msg=""):	
	# look for pattern
	with open(path, "r") as f:
		lines = f.readlines()
		pattern_write = [p for p in pattern if p[-12:] not in lines ]

	if pattern_write:
		# search for exit(0)
		i = 0
		for l in lines:
			if "exit 0\n" in l:
				print("yes: ", l)
				break
			else:
				i+=1
		print(lines[0:i])
		print()
		print(lines[i:])
		lines = lines[0:i] + [msg+"\n"] + pattern_write + lines[i:]
		with open(path, "w") as f:
			for l in lines:
				f.write(l)

if __name__ == '__main__':
	# update config.txt
	update_config()

	# update rc.local
	update_rc()
