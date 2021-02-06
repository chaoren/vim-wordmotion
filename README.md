# More useful word motions for Vim [![Build Status][1]][2]

This is one word under Vim's definition:

```
CamelCaseACRONYMWords_underscore1234
w--------------------------------->w
e--------------------------------->e
b<---------------------------------b
```

With this plugin, this becomes six words:

```
CamelCaseACRONYMWords_underscore1234
w--->w-->w----->w---->w-------->w->w
e-->e-->e----->e--->e--------->e-->e
b<---b<--b<-----b<----b<--------b<-b
```

## `word` definitions

A `word` (lowercase) is any of the following:

`word`           | Example
:--------------- | :--------------------
Camel case words | `[Camel][Case]`
Acronyms         | `[HTML]And[CSS]`
Uppercase words  | `[UPPERCASE] [WORDS]`
Lowercase words  | `[lowercase] [words]`
Hex color codes  | `[#0f0f0f]`
Hex literals     | `[0x00ffFF] [0x0f]`
Octal literals   | `[0o644] [0o0755]`
Binary literals  | `[0b01] [0b0011]`
Regular numbers  | `[1234] [5678]`
Other characters | `[~!@#$]`

A `WORD` (uppercase) is any sequence of non-space characters separated by
spaces.

## Customization

Default `word`/`WORD` mappings:

Mode  | Mapping
:---: | :-----------------------:
`nxo` | `w`/`W`
`nxo` | `b`/`B`
`nxo` | `e`/`E`
`nxo` | `ge`/`gE`
`xo`  | `aw`/`aW`
`xo`  | `iw`/`iW`
`c`   | `<C-R><C-W>`/`<C-R><C-A>`

### `g:wordmotion_nomap`

Use `g:wordmotion_nomap` to get `<Plug>` mappings only. \
E.g.,

```vim
let g:wordmotion_nomap = 1
nmap w          <Plug>WordMotion_w
nmap b          <Plug>WordMotion_b
nmap gE         <Plug>WordMotion_gE
omap aW         <Plug>WordMotion_aW
cmap <C-R><C-W> <Plug>WordMotion_<C-R><C-W>
```

### `g:wordmotion_prefix`

Use `g:wordmotion_prefix` to apply a common prefix to each of the default word
motion mappings. \
E.g.,

```vim
let g:wordmotion_prefix = '<Leader>'
```

NOTE: does not apply to the `<C-R><C-W>` and `<C-R><C-A>` mappings. \
NOTE: no effect if `g:wordmotion_nomap` is enabled.

### `g:wordmotion_mappings`

Use `g:wordmotion_mappings` to individually replace the default word motion
mappings. \
E.g.,

```vim
let g:wordmotion_mappings = {
\ 'w' : '<M-w>',
\ 'b' : '<M-b>',
\ 'e' : '<M-e>',
\ 'ge' : 'g<M-e>',
\ 'aw' : 'a<M-w>',
\ 'iw' : 'i<M-w>',
\ '<C-R><C-W>' : '<C-R><M-w>'
\ }
```

Unspecified entries will still use the default mappings. \
Set the value to an empty string to disable the mapping. \
NOTE: this overrides `g:wordmotion_prefix`. \
NOTE: no effect if `g:wordmotion_nomap` is enabled.

### `g:wordmotion_spaces`

Use `g:wordmotion_spaces` to designate extra space character patterns. \
E.g.,

```vim
let g:wordmotion_spaces = ['\w\@<=-\w\@=', '\.']
```

will produce the following result:

```
3. - foo-bar.baz
w->w>w-->w-->w>w
```

NOTE: make sure the regex matches a single character. You can use lookaheads and
lookbehinds for context-sensitive space characters. \
NOTE: the default patterns match 1) hyphens (`-`) between between alphabetic
characters and 2) underscores (`_`) between alphanumeric characters.

### `g:wordmotion_uppercase_spaces`

Use `g:wordmotion_uppercase_spaces` (default empty) to designate extra space
character patterns for uppercase motions. \
E.g.,

```vim
let g:wordmotion_uppercase_spaces = ['-']
```

will produce the following result:

```
foo_bar-baz.qux
W------>W---->W
```

NOTE: if `g:wordmotion_uppercase_spaces` is not set there will not be any
mappings for uppercase motions.

### `wordmotion#reload()`

All options can be updated by reloading the plugin. \
E.g., to disable the `w` mapping:

```vim
let g:wordmotion_mappings['w'] = ''
call wordmotion#reload()
```

then later re-enable it

```vim
let g:wordmotion_mappings['w'] = '<M-w>'
call wordmotion#reload()
```

## Related

[camelcasemotion][3]

[1]: https://travis-ci.com/chaoren/vim-wordmotion.svg?branch=master
[2]: https://travis-ci.com/chaoren/vim-wordmotion
[3]: http://www.vim.org/scripts/script.php?script_id=1905
