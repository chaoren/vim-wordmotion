function wordmotion#init()
	let l:_ = {}

	function l:_.get(name, default)
		let l:spaces = get(g:, a:name, a:default)
		if type(l:spaces) == type('')
			let l:spaces = split(l:spaces, '\zs')
		endif
		call uniq(sort(l:spaces))
		if has('patch-7.4.2044')
			call filter(l:spaces, {_, val -> !empty(l:val)})
		else
			call filter(l:spaces, '!empty(v:val)')
		endif
		let l:i = index(l:spaces, '\')
		if l:i != -1
			let l:spaces[l:i] = '\\'
		endif
		for l:i in range(len(l:spaces))
			if len(l:spaces[l:i]) == 1
				let l:spaces[l:i] = '\V'.l:spaces[l:i].'\m'
			endif
		endfor
		return l:spaces
	endfunction

	function l:_.or(list)
		return '\%(\%('.join(a:list, '\)\|\%(').'\)\)'
	endfunction

	function l:_.not(not)
		return '\%('.a:not.'\@!.\)'
	endfunction

	function l:_.between(s, w)
		let l:before = '\%('.a:w.a:s.'*\)\@<='
		let l:after = '\%('.a:s.'*'.a:w.'\)\@='
		return l:before.a:s.l:after
	endfunction

	" [:alpha:] and [:alnum:] are ASCII only
	let l:alpha = '[[:lower:][:upper:]]'
	let l:alnum = '[[:lower:][:upper:][:digit:]]'
	let l:ss = '[[:space:]]'

	let l:hyphen = l:_.between('-', l:alpha)
	let l:underscore = l:_.between('_', l:alnum)
	let l:spaces = l:_.get('wordmotion_spaces', [l:hyphen, l:underscore])
	let s:s = call(l:_.or, [[l:ss] + l:spaces])
	let s:S = l:_.not(s:s)

	let l:uspaces = l:_.get('wordmotion_uppercase_spaces', [])
	let s:us = call(l:_.or, [[l:ss] + l:uspaces])
	let s:uS = l:_.not(s:us)

	let l:a = l:alnum
	let l:d = '[[:digit:]]'
	let l:p = '[[:print:]]'
	let l:l = '[[:lower:]]'
	let l:u = '[[:upper:]]'
	let l:x = '[[:xdigit:]]'

	" set complement
	function l:_.C(set, ...)
		return '\%(\%('.join(a:000, '\|').'\)\@!'.a:set.'\)'
	endfunction

	let l:words = get(g:, 'wordmotion_extra', [])
	call add(l:words, l:u.l:l.'\+')              " CamelCase
	call add(l:words, l:u.'\+'.l:l.'\@!')        " UPPERCASE
	call add(l:words, l:l.'\+')                  " lowercase
	call add(l:words, '#'.l:x.'\+\>')            " #0F0F0F
	call add(l:words, '\<0[xX]'.l:x.'\+\>')      " 0x00 0Xff
	call add(l:words, '\<0[oO][0-7]\+\>')        " 0o00 0O77
	call add(l:words, '\<0[bB][01]\+\>')         " 0b00 0B11
	call add(l:words, l:d.'\+')                  " 1234 5678
	call add(l:words, l:_.C(l:p, l:a, s:s, '#'.l:x).'\+') " other printable characters
	call add(l:words, '\%^')                     " start of file
	call add(l:words, '\%$')                     " end of file
	let s:word = call(l:_.or, [l:words])
endfunction

call wordmotion#init()

function wordmotion#motion(count, mode, flags, uppercase, extra, ...)
	let l:cpo = &cpoptions
	set cpoptions+=c

	let l:flags = a:flags

	if a:mode == 'o' && v:operator == 'c' && l:flags == ''
		" special case (see :help cw)
		let l:flags = 'e'
		let l:cw = 1
	else
		let l:cw = 0
	endif

	if a:mode == 'x'
		normal! gv
	elseif a:mode == 'o' && l:flags =~# 'e'
		" need to make this inclusive for operator pending mode
		normal! v
	endif

	let l:words = a:extra + [a:uppercase ? s:uS.'\+' : s:word]
	if l:flags != 'e' " e does not stop in an empty line
		call add(l:words, '^$')
	endif

	let l:pattern = '\%('.join(l:words, '\|').'\)'

	" save position to see if it moved
	let l:pos = getpos('.')

	let l:count = a:count
	if l:cw
		" cw on the last character of a word will match the cursor position
		call search('\m'.l:pattern, l:flags.'cW')
		let l:count -= 1
	endif
	while l:count > 0
		call search('\m'.l:pattern, l:flags.'W')
		let l:count -= 1
	endwhile

	" dw at the end of a line should not consume the newline or leading white
	" space on the next line
	let l:is_dw = a:mode == 'o' && v:operator == 'd' && l:flags == ''
	let l:next_line = l:pos[1] < getpos('.')[1]
	if l:is_dw && l:next_line
		let l:s = a:uppercase ? s:us : s:s
		" newline, leading whitespace, cursor
		if search('\m\n\%('.l:s.'\)*\%#', 'bW') != 0
			let l:dwpos = getpos('.')
			" need to make range inclusive
			call setpos('.', l:pos)
			normal! v
			call setpos('.', l:dwpos)
		endif
	endif

	" ugly hack for 'w' going forwards at end of file
	" and 'ge' going backwards at beginning of file
	if a:count && l:pos == getpos('.')
		" cursor didn't move
		if l:flags == 'be' && line('.') == 1
			" at first line and going backwards, let's go to the front
			normal! 0
		elseif l:flags == '' && line('.') == line('$')
			" at last line and going forwards, let's go to the back
			if a:mode == 'o'
				" need to include last character if in operator pending mode
				normal! v
			endif
			normal! $
		endif
	endif

	let l:actual_mode = get(a:, 1, a:mode)
	if l:actual_mode == 'n' || l:actual_mode == 'x'
		if &g:foldopen =~# '\%(^\|,\)hor\%(,\|$\)'
			normal! zv
		endif
	endif

	let &cpoptions = l:cpo
endfunction

function wordmotion#object(count, mode, inner, uppercase)
	let l:cpo = &cpoptions
	set cpoptions+=c

	let l:flags = 'e'
	let l:extra = []
	let l:backwards = 0
	let l:count = a:count
	let l:existing_selection = 0
	let l:s = a:uppercase ? s:us : s:s
	let l:S = a:uppercase ? s:uS : s:S

	if a:mode == 'x'
		normal! gv
		if getpos("'<") == getpos("'>")
			" no existing selection, exit visual mode
			execute 'normal!' visualmode()
		else
			let l:existing_selection = 1
			let l:start = getpos('.')
			if l:start == getpos("'<")
				let l:flags = 'b'
				let l:backwards = 1
			endif
		endif
	endif

	if a:inner
		" for inner word, count white spaces too
		call add(l:extra, l:s.'\+')
	else
		if getline('.')[col('.') - 1] =~# l:s
			if !l:existing_selection
				let l:backwards = 1
			endif
			call search('\m'.l:S, 'W')
		endif
	endif

	if !l:existing_selection
		call wordmotion#motion(1, 'n', 'bc', a:uppercase, l:extra, a:mode)
		let l:start = getpos('.')
		normal! v
		call wordmotion#motion(1, 'n', 'ec', a:uppercase, l:extra, a:mode)
		let l:count -= 1
	endif

	call wordmotion#motion(l:count, 'n', l:flags, a:uppercase, l:extra, a:mode)

	if !a:inner
		if col('.') == col('$') - 1
			" at end of line, go back, and consume preceding white spaces
			let l:backwards = 1
		endif

		if l:backwards && !l:existing_selection
			" selection is forwards, but need to extend backwards
			let l:end = getpos('.')
			call cursor(l:start[1], l:start[2])
			call search('\m'.l:s.'\+\%#' , 'bW')
			normal! vv
			call cursor(l:end[1], l:end[2])
		elseif l:backwards
			" selection is actually going backwards
			call search('\m'.l:s.'\+\%#', 'bW')
		else
			" forward selection, consume following white spaces
			call search('\m\%#.'.l:s.'\+', 'eW')
		endif
	endif

	let &cpoptions = l:cpo
endfunction

function wordmotion#current(uppercase)
	let l:cursor = getpos('.')
	call wordmotion#motion(1, 'n', 'ec', a:uppercase, [], 'c')
	let l:end = getpos('.')
	call wordmotion#motion(1, 'n', 'bc', a:uppercase, [], 'c')
	let l:start = getpos('.')
	call cursor(l:cursor)
	let l:lnum = l:cursor[1]
	let l:line = getline(l:lnum)
	let l:space = a:uppercase ? s:us : s:s
	let l:same_line = l:start[1] == l:lnum && l:end[1] == l:lnum
	let l:not_empty = l:end[2] <= len(l:line)
	let l:not_space = l:line[l:end[2]-1] !~# l:space
	if l:same_line && l:not_empty && l:not_space
		return l:line[l:start[2]-1:l:end[2]-1]
	else
		echohl ErrorMsg
		echomsg 'E348: No string under cursor'
		echohl None
		return ''
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
