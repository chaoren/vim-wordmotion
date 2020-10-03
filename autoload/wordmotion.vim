function wordmotion#init()
	let l:spaces = get(g:, 'wordmotion_spaces', ['_'])
	if type(l:spaces) == type('')
		let l:spaces = split(l:spaces, '\zs')
	endif
	let s:s = '\%([' . join(['[:space:]'] + l:spaces, ']\|[') . ']\)'
	let s:S = '\%(' . s:s . '\@!.\)'

	let l:uspaces = get(g:, 'wordmotion_uppercase_spaces', [])
	if type(l:uspaces) == type('')
		let l:uspaces = split(l:uspaces, '\zs')
	endif
	let s:us = '\%([' . join(['[:space:]'] + l:uspaces, ']\|[') . ']\)'
	let s:uS = '\%(' . s:us . '\@!.\)'

	" [:alnum:] and [:alpha:] are ASCII only
	let l:a = '[[:digit:][:lower:][:upper:]]'
	let l:d = '[[:digit:]]'
	let l:p = '[[:print:]]'
	let l:l = '[[:lower:]]'
	let l:u = '[[:upper:]]'
	let l:x = '[[:xdigit:]]'

	" set complement
	let l:_ = {}
	function l:_.C(set, ...)
		let l:exclude = join(a:000, '\|')
		return '\%(\%(' . l:exclude . '\)\@!' . a:set . '\)'
	endfunction

	let l:words = get(g:, 'wordmotion_extra', [])
	call add(l:words, l:u . l:l . '\+')            " CamelCase
	call add(l:words, l:u . '\+\ze' . l:u . l:l)   " ACRONYMSBeforeCamelCase
	call add(l:words, l:u . '\+')                  " UPPERCASE
	call add(l:words, l:l . '\+')                  " lowercase
	call add(l:words, '0[xX]' . l:x . '\+')        " 0x00 0Xff
	call add(l:words, '0[oO][0-7]\+')              " 0o00 0O77
	call add(l:words, '0[bB][01]\+')               " 0b00 0B11
	call add(l:words, l:d . '\+')                  " 1234 5678
	call add(l:words, l:_.C(l:p, l:a, s:s) . '\+') " other printable characters
	call add(l:words, '\%^')                       " start of file
	call add(l:words, '\%$')                       " end of file
	let s:word = join(l:words, '\|')
endfunction

call wordmotion#init()

function wordmotion#motion(count, mode, flags, uppercase, extra)
	if a:mode == 'x'
		normal! gv
	elseif a:mode == 'o' && a:flags =~# 'e'
		" need to make this inclusive for operator pending mode
		normal! v
	endif

	let l:words = a:extra + [a:uppercase ? s:uS . '\+' : s:word]
	if a:flags != 'e' " e does not stop in an empty line
		call add(l:words, '^$')
	endif

	let l:pattern = '\m\%(' . join(l:words, '\|') . '\)'

	" save position to see if it moved
	let l:pos = getpos('.')

	for @_ in range(a:count)
		call search(l:pattern, a:flags . 'W')
	endfor

	" ugly hack for 'w' going forwards at end of file
	" and 'ge' going backwards at beginning of file
	if a:count && l:pos == getpos('.')
		" cursor didn't move
		if a:flags == 'be' && line('.') == 1
			" at first line and going backwards, let's go to the front
			normal! 0
		elseif a:flags == '' && line('.') == line('$')
			" at last line and going forwards, let's go to the back
			if a:mode == 'o'
				" need to include last character if in operator pending mode
				normal! v
			endif
			normal! $
		endif
	endif
endfunction

function wordmotion#object(count, mode, inner, uppercase)
	let l:flags = 'e'
	let l:extra = []
	let l:backwards = v:false
	let l:count = a:count
	let l:existing_selection = v:false
	let l:s = a:uppercase ? s:us : s:s
	let l:S = a:uppercase ? s:uS : s:S

	if a:mode == 'x'
		normal! gv
		if getpos("'<") == getpos("'>")
			" no existing selection, exit visual mode
			execute 'normal!' visualmode()
		else
			let l:existing_selection = v:true
			let l:start = getpos('.')
			if l:start == getpos("'<")
				let l:flags = 'b'
				let l:backwards = v:true
			endif
		endif
	endif

	if a:inner
		" for inner word, count white spaces too
		call add(l:extra, l:s . '\+')
	else
		if getline('.')[col('.') - 1] =~ l:s
			if !l:existing_selection
				let l:backwards = v:true
			endif
			call search('\m' . l:S, 'W')
		endif
	endif

	if !l:existing_selection
		call wordmotion#motion(1, 'n', 'bc', a:uppercase, l:extra)
		let l:start = getpos('.')
		normal! v
		call wordmotion#motion(1, 'n', 'ec', a:uppercase, l:extra)
		let l:count -= 1
	endif

	call wordmotion#motion(l:count, 'n', l:flags, a:uppercase, l:extra)

	if !a:inner
		if col('.') == col('$') - 1
			" at end of line, go back, and consume preceding white spaces
			let l:backwards = v:true
		endif

		if l:backwards && !l:existing_selection
			" selection is forwards, but need to extend backwards
			let l:end = getpos('.')
			call cursor(l:start[1], l:start[2])
			call search('\m' . l:s . '\+\%#', 'bW')
			normal! vv
			call cursor(l:end[1], l:end[2])
		elseif l:backwards
			" selection is actually going backwards
			call search('\m' . l:s . '\+\%#', 'bW')
		else
			" forward selection, consume following white spaces
			call search('\m\%#.' . l:s . '\+', 'eW')
		endif
	endif
endfunction

function wordmotion#current(uppercase)
	let l:cursor = getpos('.')
	call wordmotion#motion(1, 'n', 'ec', a:uppercase, [])
	let l:end = getpos('.')
	call wordmotion#motion(1, 'n', 'bc', a:uppercase, [])
	let l:start = getpos('.')
	call cursor(l:cursor)
	let l:line = l:cursor[1]
	if l:start[1] != l:line || l:end[1] != l:line ||
				\ len(getline(l:line)) < l:end[2] ||
				\ getline(l:line)[l:end[2]-1] =~ (a:uppercase ? s:us : s:s)
		echohl ErrorMsg
		echomsg 'E348: No string under cursor'
		echohl None
		return ''
	else
		return getline(l:line)[l:start[2]-1:l:end[2]-1]
	endif
endfunction

function wordmotion#reload()
	unlet g:loaded_wordmotion
	runtime plugin/wordmotion.vim
endfunction

function wordmotion#_default()
	unlet! g:wordmotion_nomap
	unlet! g:wordmotion_prefix
	unlet! g:wordmotion_mappings
	unlet! g:wordmotion_spaces
	unlet! g:wordmotion_uppercase_spaces
	call wordmotion#reload()
endfunction
