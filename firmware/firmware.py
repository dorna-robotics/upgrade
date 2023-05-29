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

if __name__ == '__main__':
	# update config.txt
	update_config()
