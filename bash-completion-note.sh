#!/bin/bash
_note() {
	IFS="$(printf '\n\t')"
	COMPREPLY=( $( note --complete "${COMP_WORDS[@]}" ) )
	return 0;
}

complete -o filenames -F _note note

