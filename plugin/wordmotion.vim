if exists('g:loaded_wordmotion')
	finish
endif
let g:loaded_wordmotion = 1

let s:_ = {}

if exists('*wordmotion#init')
	call wordmotion#init()
endif

let s:_.cpo = &cpoptions
set cpoptions-=<

if exists('s:existing')
	for s:_.mapping in s:existing
		let s:_.mode = s:_.mapping['mode']
		let s:_.unmap = s:_.mode . 'unmap'
		let s:_.lhs = s:_.mapping['lhs']
		let s:_.rhs = s:_.mapping['rhs']
		if hasmapto(s:_.rhs, s:_.mode)
			execute s:_.unmap s:_.lhs
		endif
	endfor
endif
let s:existing = []
function s:_.add_existing(mode, lhs, rhs)
	call add(s:existing, {'mode' : a:mode, 'lhs' : a:lhs, 'rhs' : a:rhs})
endfunction

let s:_.prefix = get(g:, 'wordmotion_prefix', '')
let s:_.mappings = get(g:, 'wordmotion_mappings', {})
let s:_.uspaces = get(g:, 'wordmotion_uppercase_spaces', [])
if exists('g:wordmotion_nomap')
	let s:_.nomap = g:wordmotion_nomap
else
	let s:_.nomap = get(g:, 'wordmotion_disable_default_mappings', 0)
endif

let s:_.plug = '<Plug>WordMotion_'
let s:_.flags = {'w' : '', 'e' : 'e', 'b' : 'b', 'ge' : 'be'}

let s:_.motions = ['w', 'e', 'b', 'ge']
if !empty(s:_.uspaces)
	let s:_.motions += ['W', 'E', 'B', 'gE']
endif

for s:_.motion in s:_.motions
	for s:_.mode in ['n', 'x', 'o']
		let s:_.map = s:_.plug . s:_.motion
		let s:_.m = printf("'%s'", s:_.mode)
		let s:_.f = printf("'%s'", s:_.flags[tolower(s:_.motion)])
		let s:_.u = s:_.motion =~# '\u'
		let s:_.args = join(['v:count1', s:_.m, s:_.f, s:_.u, '[]'], ', ')
		let s:_.rhs = printf(':<C-U>call wordmotion#motion(%s)<CR>', s:_.args)
		execute s:_.mode . 'noremap' '<silent>' s:_.map s:_.rhs
		call s:_.add_existing(s:_.mode, s:_.map, s:_.rhs)
		if s:_.nomap
			continue
		endif
		let s:_.lhs = get(s:_.mappings, s:_.motion, s:_.prefix . s:_.motion)
		if !empty(s:_.lhs)
			execute s:_.mode . 'map' '<silent>' s:_.lhs s:_.map
			call s:_.add_existing(s:_.mode, s:_.lhs, s:_.map)
		endif
	endfor
endfor

let s:_.inner = {'aw' : 0, 'iw' : 1}

let s:_.motions = ['aw', 'iw']
if !empty(s:_.uspaces)
	let s:_.motions += ['aW', 'iW']
endif

for s:_.motion in s:_.motions
	for s:_.mode in ['x', 'o']
		let s:_.map = s:_.plug . s:_.motion
		let s:_.m = printf("'%s'", s:_.mode)
		let s:_.i = s:_.inner[tolower(s:_.motion)]
		let s:_.u = s:_.motion =~# '\u'
		let s:_.args = join(['v:count1', s:_.m, s:_.i, s:_.u], ', ')
		let s:_.rhs = printf(':<C-U>call wordmotion#object(%s)<CR>', s:_.args)
		execute s:_.mode . 'noremap' '<silent>' s:_.map s:_.rhs
		call s:_.add_existing(s:_.mode, s:_.map, s:_.rhs)
		if s:_.nomap
			continue
		endif
		let s:_.default = s:_.motion[0] . s:_.prefix . s:_.motion[1]
		let s:_.lhs = get(s:_.mappings, s:_.motion, s:_.default)
		if !empty(s:_.lhs)
			execute s:_.mode . 'map' '<silent>' s:_.lhs s:_.map
			call s:_.add_existing(s:_.mode, s:_.lhs, s:_.map)
		endif
	endfor
endfor

let s:_.motions = ['<C-R><C-W>']
if !empty(s:_.uspaces)
	let s:_.motions += ['<C-R><C-A>']
endif

for s:_.motion in s:_.motions
	let s:_.map = s:_.plug . s:_.motion
	let s:_.mode = 'c'
	let s:_.u = s:_.motion == '<C-R><C-A>'
	let s:_.rhs = printf('wordmotion#current(%d)', s:_.u)
	execute s:_.mode . 'noremap' '<expr>' s:_.map s:_.rhs
	call s:_.add_existing(s:_.mode, s:_.map, s:_.rhs)
	if s:_.nomap
		continue
	endif
	let s:_.lhs = get(s:_.mappings, s:_.motion, s:_.motion)
	if !empty(s:_.lhs)
		execute s:_.mode . 'map' s:_.lhs s:_.map
		call s:_.add_existing(s:_.mode, s:_.lhs, s:_.map)
	endif
endfor

let &cpoptions = s:_.cpo
unlet s:_
