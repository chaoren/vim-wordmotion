More useful word motions for Vim
=================================

[![Build Status](https://travis-ci.org/chaoren/vim-wordmotion.svg?branch=master)](https://travis-ci.org/chaoren/vim-wordmotion)

Under Vim's definition of a `word`:

```
CamelCaseACRONYMWords_underscore1234
w--------------------------------->w
e--------------------------------->e
b<---------------------------------b
```

With this plugin:

```
CamelCaseACRONYMWords_underscore1234
w--->w-->w----->w---->w-------->w->w
e-->e-->e----->e--->e--------->e-->e
b<---b<--b<-----b<----b<--------b<-b
```

`word` definitions
==================

| `word`                          | Example               |
|:--------------------------------|:----------------------|
| Camel case words                | `[Camel][Case]`       |
| Acronyms                        | `[HTML]And[CSS]`      |
| Uppercase words                 | `[UPPERCASE] [WORDS]` |
| Lowercase words                 | `[lowercase] [words]` |
| Hexadecimal literals            | `[0x00ffFF] [0x0f]`   |
| Binary literals                 | `[0b01] [0b0011]`     |
| Regular numbers                 | `[1234] [5678]`       |
| Other characters                | `[~!@#$]`             |

Customization
=============

The default word motion mappings are `w`, `b`, `e`, `ge`, `aw`, and `iw`.

Use `g:wordmotion_prefix` to apply a common prefix to each of the default word
motion mappings.  
E.g.,
```
let g:wordmotion_prefix = '<Leader>'
```

Use `g:wordmotion_mappings` to individually replace the default word motion
mappings.  
E.g.,
```
let g:wordmotion_mappings = {
\ 'w' : '<M-w>',
\ 'b' : '<M-b>',
\ 'e' : '<M-e>',
\ 'ge' : 'g<M-e>',
\ 'aw' : 'a<M-w>',
\ 'iw' : 'i<M-w>'
\ }
```
Unspecified entries will still use the default mappings.  
Set the value to an empty string to disable the mapping.

NOTE: this overrides `g:wordmotion_prefix`.

Use `g:wordmotion_spaces` (default `'_'`) to designate extra space characters.  
E.g.,
```
let g:wordmotion_spaces = '_-.'
```
will produce the following result:
```
foo_bar-baz.qux
w-->w-->w-->w>w
```

Caveats
=======

There are some special cases with how Vim's word motions work.  
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
This plugin faithfully follows the motion of `w`, while Vim replaces these two
special cases with the behavior of `de` and `ce`, respectively.

Related
=======
[camelcasemotion](http://www.vim.org/scripts/script.php?script_id=1905)
