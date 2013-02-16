#!/bin/bash
_note() {
	COMPREPLY=( $( note --complete "${COMP_WORDS[@]}" ) )
	return 0;
}

complete -F _note note

