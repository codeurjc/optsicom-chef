#!/usr/bin/env bats

setup() {
	echo "Test file" > test-file.txt
}
@test "can sign" {
	run sudo -u kitchen -H /optsicom-chef/sign.sh
	[ "$status" -eq 0 ]
	[ -f test-file.txt.asc ]
}
teardown() {
	rm test-file.txt
	rm test-file.txt.asc
}