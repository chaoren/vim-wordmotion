if exists('g:loaded_wordmotion')
	finish
endif
let g:loaded_wordmotion = 1

let s:prefix = get(g:, 'wordmotion_prefix', '')
let s:flags= { 'w' : '', 'e' : 'e', 'b' : 'b', 'ge' : 'be' }

for s:mode in [ 'n', 'x', 'o' ] " {{{
	for s:motion in [ 'w', 'e', 'b', 'ge' ]
		let s:map = s:mode . 'noremap'
		let s:lhs = '<silent>' . s:prefix . s:motion
		let s:m = "'" . s:mode . "'"
		let s:f = "'" . s:flags[s:motion] . "'"
		let s:args = join([ 'v:count1', s:m, s:f ], ', ')
		let s:rhs = ":\<C-U>call \<SID>WordMotion(" . s:args . ")\<CR>"
		execute s:map s:lhs s:rhs
	endfor
endfor " }}}

let s:flags= { 'aw' : 'e', 'iw' : '' }

for s:mode in [ 'x', 'o' ] " {{{
	" TODO: fix for aw
	" for s:motion in [ 'aw', 'iw' ]
	for s:motion in [ 'iw' ]
		let s:map = s:mode . 'noremap'
		let s:lhs = '<silent>' . s:prefix . s:motion
		let s:m = "'" . s:mode . "'"
		let s:f = "'" . s:flags[s:motion] . "'"
		let s:args = join([ 'v:count1', s:m, s:f ], ', ')
		let s:rhs = ":\<C-U>call \<SID>AOrInnerWordMotion(" . s:args . ")\<CR>"
		execute s:map s:lhs s:rhs
	endfor
endfor " }}}

function! <SID>WordMotion(count, mode, flags) abort " {{{
	if a:mode == 'x'
		normal! gv
	endif
	let l:matches = get(g:, 'wordmotion_extra', [ ])
	call add(l:matches, '\u\l\+')                      " CamelCase
	call add(l:matches, '\u\+\ze\u\l')                 " ACRONYMS
	call add(l:matches, '\a\+')                        " normal words
	call add(l:matches, '0[xX]\x\+')                   " 0x00 0Xff
	call add(l:matches, '0[bB][01]\+')                 " 0b00 0B11
	call add(l:matches, '\d\+')                        " 1234 5678
	call add(l:matches, '\%(\%(\a\|\d\)\@!\k\)\+')     " other keywords
	call add(l:matches, '\%(\%(\a\|\d\|\k\)\@!\S\)\+') " everything else
	if a:flags != 'e' " e does not stop in an empty line
		call add(l:matches, '^$')                      " empty line
	endif
	let l:pattern = '\m\%(' . join(l:matches, '\|') . '\)'
	if a:mode == 'o' && a:flags =~# 'e'
		" need to make this inclusive for operator pending mode
		normal! v
	endif
	" save postion to see if it moved
	let l:pos = getpos('.')
	for @_ in range(a:count)
		call search(l:pattern, a:flags . 'W')
	endfor
	if l:pos == getpos('.') && a:flags !~# 'c'
		" cursor didn't move, and it's not because we're selecting the same
		" word under the cursor
		if line('.') == 1 && a:flags =~# 'b'
			" at first line and going backwards, let's go to the front
			execute 'normal!' '0'
		elseif line('.') == line('$') && a:flags !~# 'b'
			" at lastline and going forwards, let's go to the back
			execute 'normal!' '$'
		endif
	endif
endfunction " }}}

function! <SID>AOrInnerWordMotion(count, mode, flags) abort " {{{
	" TODO: implement aw
	"       foo bar baz   -> vaw  -> foo [bar ]baz
	"            ^                           ^
	"       foo bar baz$  -> vaw  -> foo bar[ baz]$
	"                ^                          ^
	"       FooBarBaz     -> vaw  -> Foo[Bar]Baz
	"           ^                          ^
	" TODO: fix for existing selection
	"       foo b[ar b]az -> iw  -> foo [bar b]az
	"             ^                      ^
	"       foo b[ar b]az -> 2iw -> foo[ bar b]az
	"             ^                     ^
	"       foo b[ar b]az -> 3iw -> [foo bar b]az
	"             ^                  ^
	"       fo[o ba]r baz -> iw  -> fo[o bar] baz
	"             ^                        ^
	"       fo[o ba]r baz -> 2iw -> fo[o bar ]baz
	"             ^                         ^
	"       fo[o ba]r baz -> 3iw -> fo[o bar baz]
	"             ^                            ^
	"       Fo[oBa]rBaz   -> iw  -> Fo[oBar]Baz
	"            ^                        ^
	call <SID>WordMotion(1, 'n', 'bc')
	normal! v
	call <SID>WordMotion(1, 'n', 'ec')
	if a:count > 1
		call <SID>WordMotion(a:count - 1, 'n', 'e')
	endif
endfunction " }}}

" vim:fdm=marker
