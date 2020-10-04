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

| `word`               | Example               |
|:---------------------|:----------------------|
| Camel case words     | `[Camel][Case]`       |
| Acronyms             | `[HTML]And[CSS]`      |
| Uppercase words      | `[UPPERCASE] [WORDS]` |
| Lowercase words      | `[lowercase] [words]` |
| Hexadecimal literals | `[0x00ffFF] [0x0f]`   |
| Octal literals       | `[0o644] [0o0755]`    |
| Binary literals      | `[0b01] [0b0011]`     |
| Regular numbers      | `[1234] [5678]`       |
| Other characters     | `[~!@#$]`             |

A `WORD` (uppercase) is any sequence of non-space characters separated by
spaces.

## Customization

Default `word`/`WORD` mappings:

| Mode  | Mapping                   |
|:-----:|:-------------------------:|
| `nxo` | `w`/`W`                   |
| `nxo` | `b`/`B`                   |
| `nxo` | `e`/`E`                   |
| `nxo` | `ge`/`gE`                 |
| `xo`  | `aw`/`aW`                 |
| `xo`  | `iw`/`iW`                 |
| `c`   | `<C-R><C-W>`/`<C-R><C-A>` |

### `g:wordmotion_nomap`

Use `g:wordmotion_nomap` to get `<Plug>` mappings only.\
E.g.,
```
nmap w          <Plug>WordMotion_w
nmap b          <Plug>WordMotion_b
nmap gE         <Plug>WordMotion_gE
omap aW         <Plug>WordMotion_aW
cmap <C-R><C-W> <Plug>WordMotion_<C-R><C-W>
```

### `g:wordmotion_prefix`

Use `g:wordmotion_prefix` to apply a common prefix to each of the default word
motion mappings.\
E.g.,
```
let g:wordmotion_prefix = '<Leader>'
```
NOTE: does not apply to the `<C-R><C-W>` and `<C-R><C-A>` mappings.\
NOTE: no effect if `g:wordmotion_nomap` is enabled.

### `g:wordmotion_mappings`

Use `g:wordmotion_mappings` to individually replace the default word motion
mappings.\
E.g.,
```
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
Unspecified entries will still use the default mappings.\
Set the value to an empty string to disable the mapping.\
NOTE: this overrides `g:wordmotion_prefix`.\
NOTE: no effect if `g:wordmotion_nomap` is enabled.

### `g:wordmotion_spaces`

Use `g:wordmotion_spaces` (default `['_']`) to designate extra space characters.\
E.g.,
```
let g:wordmotion_spaces = ['_', '-', '.']
```
will produce the following result:
```
foo_bar-baz.qux
w-->w-->w-->w>w
```

### `g:wordmotion_uppercase_spaces`

Use `g:wordmotion_uppercase_spaces` (default empty) to designate extra space
characters for uppercase motions.\
E.g.,
```
let g:wordmotion_uppercase_spaces = ['-']
```
will produce the following result:
```
foo_bar-baz.qux
W------>W---->W
```
If `g:wordmotion_uppercase_spaces` is not set there will not be any mappings for
uppercase motions.

### `wordmotion#reload()`

All options can be updated by reloading the plugin.\
E.g., to disable the `w` mapping:
```
let g:wordmotion_mappings['w'] = ''
call wordmotion#reload()
```
then later re-enable it
```
let g:wordmotion_mappings['w'] = '<M-w>'
call wordmotion#reload()
```

## Caveats

There are some special cases with how Vim's word motions work.\
E.g.,
```
Vim:

	^foo [b]ar$ -> dw -> ^foo[ ]$
	^ baz$               ^ baz$

	^[f]oo bar$ -> cw -> ^[ ]bar$

This plugin:

	^foo [b]ar$ -> dw -> ^foo [b]az$
	^ baz$

	^[f]oo bar$ -> cw -> ^[b]ar$
```
This plugin faithfully follows the motion of `w` when executing `dw` and `cw`,
while Vim replaces these two special cases with the behavior of `de` and `ce`,
respectively.

If you want to restore Vim's special case behavior with `dw` and `cw`, you can
do this:
```
nmap dw de
nmap cw ce
```

If you want the same behavior for uppercase motions (i.e., `dW` and `cW`), you
can set `g:wordmotion_uppercase_spaces`.\
E.g.,
```
let g:wordmotion_uppercase_spaces = [' ']
```
will enable this behavior without adding extra space characters to uppercase
motions.

## Related
[camelcasemotion][3]

[1]: https://travis-ci.com/chaoren/vim-wordmotion.svg?branch=master
[2]: https://travis-ci.com/chaoren/vim-wordmotion
[3]: http://www.vim.org/scripts/script.php?script_id=1905
