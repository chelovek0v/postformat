proc Callstack {} {
	set levels [info level]	
	puts levels:$levels
	for {set i 1} {$i <= $levels} {incr i} {
		puts "$i: [info level $i]\n"
	}
}

proc Locals {} {
	uplevel {
		foreach name [info locals]	{
			puts "${name}: [set $name]"		
		}
	}
}

proc Vars {} {
	uplevel {
		foreach name [info vars] {
			if [array exists $name] {
				parray $name	
			} else {
				puts "${name}: [set $name]"		
			}
		}
	}
}

proc NamespaceVars {} {
	uplevel {
		foreach name [info vars [namespace current]::*]	{
			if [array exists $name] {
				parray $name
			} else {
				puts "${name}: [set $name]"		
			}
		}
	}
}

proc Pause {{cond {}} {message {}}} {
	# return
	if {$cond ne {} && ![uplevel [list expr $cond]]} {
		return
	}

	if ![dict exists [info frame -1] proc] {
		return
	}
	
	puts -nonewline "\033\[0;7m"
	puts "\nPaused in [dict get [info frame -1] proc]"
	puts -nonewline "\033\[0m"
	puts $message

	puts -nonewline "> "
	flush stdout

	while {[gets stdin in] && $in ne {}} {
	puts -nonewline "\033\[0;7m"
		catch {uplevel 1 $in} res
		puts ${res}
	puts -nonewline "\033\[0m"
		puts -nonewline "> "
		flush stdout
	}
}


namespace eval debug {
	variable level 0

	proc group {title} {
		variable level
		incr level

		set delim [groupDelimeter $title]

		puts ""
		puts $delim
		puts $title
		puts $delim
	}

	proc groupDelimeter {title} {
		variable level
		set length [string length $title]
		for {set i 0} {$i < $length} {incr i} {
			append result [expr {$level > 1 ? {-} : {=}}]
		}

		return $result
	}

	proc puts {text} {
		variable level
		set levelPrefix ""
		for {set i 0} {$i < ($level - 1)} {incr i} {
			append levelPrefix ".\t"
		}
		::puts stderr $levelPrefix$text
	}

	proc endGroup {} {
		puts === 
		variable level 
		incr level -1
	}
}

