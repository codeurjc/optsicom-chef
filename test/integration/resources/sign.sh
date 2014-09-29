#!/bin/bash

/usr/bin/expect -c 'spawn gpg -u "Optsicom Test" -ab test-file.txt
		expect "Enter passphrase: "
		send "optsicom\r"
		expect eof'