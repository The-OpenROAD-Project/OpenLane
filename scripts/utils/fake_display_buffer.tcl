proc fake_display_buffer {args} {
	set screen :9
	exec Xvfb $screen -screen 0 640x480x24 &
	set ::env(DISPLAY) $screen
}

proc kill_display_buffer {args} {
	exec killall Xvfb
}
