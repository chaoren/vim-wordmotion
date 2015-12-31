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
		let s:args = join([ 'v:count1', s:m, s:f, '[ ]' ], ', ')
		let s:rhs = ":\<C-U>call \<SID>WordMotion(" . s:args . ")\<CR>"
		execute s:map s:lhs s:rhs
	endfor
endfor " }}}

let s:inner = { 'aw' : 0, 'iw' : 1 }

for s:mode in [ 'x', 'o' ] " {{{
	for s:motion in [ 'aw', 'iw' ]
		let s:map = s:mode . 'noremap'
		let s:lhs = '<silent>' . s:prefix . s:motion
		let s:m = "'" . s:mode . "'"
		let s:i = s:inner[s:motion]
		let s:args = join([ 'v:count1', s:m, s:i ], ', ')
		let s:rhs = ":\<C-U>call \<SID>AOrInnerWordMotion(" . s:args . ")\<CR>"
		execute s:map s:lhs s:rhs
	endfor
endfor " }}}

function! <SID>WordMotion(count, mode, flags, extra) abort " {{{
	if a:mode == 'x'
		normal! gv
	elseif a:mode == 'o' && a:flags =~# 'e'
		" need to make this inclusive for operator pending mode
		normal! v
	endif

	let l:words = a:extra + get(g:, 'wordmotion_extra', [ ])
	call add(l:words, '\u\l\+')                      " CamelCase
	call add(l:words, '\u\+\ze\u\l')                 " ACRONYMS
	call add(l:words, '\a\+')                        " normal words
	call add(l:words, '0[xX]\x\+')                   " 0x00 0Xff
	call add(l:words, '0[bB][01]\+')                 " 0b00 0B11
	call add(l:words, '\d\+')                        " 1234 5678
	call add(l:words, '\%(\%(\a\|\d\)\@!\k\)\+')     " other keywords
	call add(l:words, '\%(\%(\a\|\d\|\k\)\@!\S\)\+') " everything else
	if a:flags != 'e' " e does not stop in an empty line
		call add(l:words, '^$')                      " empty line
	endif

	let l:pattern = '\m\%(' . join(l:words, '\|') . '\)'

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
			normal! 0
		elseif line('.') == line('$') && a:flags !~# 'b'
			" at lastline and going forwards, let's go to the back
			normal! $
		endif
	endif
endfunction " }}}

function! <SID>AOrInnerWordMotion(count, mode, inner) abort " {{{
	let l:extra = [  ]
	if a:inner
		" for inner word, count white spaces too
		let l:extra = [ '\s\+' ]
	endif

	call <SID>WordMotion(1, 'n', 'bc', l:extra)

	" save start position in case we need to go back
	let l:start = getpos('.')

	normal! v

	call <SID>WordMotion(1, 'n', 'ec', l:extra)
	if a:count > 1
		call <SID>WordMotion(a:count - 1, 'n', 'e', l:extra)
	endif

	if !a:inner
		if line('.') != l:start[1] || col('.') == col('$') - 1
			" multi line selection or at end of line
			" go back, and consume white spaces
			normal! vv
			call cursor(l:start[1], l:start[2])
			call search('\s\+\%#', 'bW')
		else
			" single line selection and not at end of line,
			" consume remaining white spaces
			call search('\%#.\s\+', 'eW')
		endif
	endif
endfunction " }}}

" vim:fdm=marker
