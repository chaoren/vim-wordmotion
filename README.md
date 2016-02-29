Customizable word motions for Vim
=================================

Under Vim's definition of a `word`:

```
CamelCaseACRONYMWords_underscore1234 hyphenated-word
w----------------------------------->w-------->ww
e--------------------------------->e--------->ee-->e
b<-----------------------------------b<--------bb<-b
```

With this plugin:

```
CamelCaseACRONYMWords_underscore1234 hyphenated-word
w--->w-->w----->w--->ww-------->w--->w-------->ww
e-->e-->e----->e--->ee-------->e-->e--------->ee-->e
b<---b<--b<-----b<---bb<--------b<---b<--------bb<-b
```

Customization
=============

The default word motion mappings are `w`, `b`, `e`, `ge`, `aw`, and `iw`.

Use `g:wordmotion_prefix` to apply a common prefix to each of the word motion
mappings.  
E.g.,
```
let g:wordmotion_prefix = "\<Leader>"
```

Use `g:wordmotion_mappings` to replace individual word motion mappings.  
E.g.,
```
let g:wordmotion_mappings = { 'w' : 'W', 'b' : 'B' }
```

Define additional `word`s with `g:wordmotion_extra`.  
E.g., to treat `<WordsInAngleBrackets>` and `|WordsInPipes|` as single words:
```
let g:wordmotion_extra = [ "<\a\+>", "|\a\+|" ]
```
NOTE: this takes precedence over any existing `word` definitions.

The existing `word` definitions are:

| `word`                          | Example               |
|:--------------------------------|:----------------------|
| Camel case words                | `[Camel][Case]`       |
| Acronyms                        | `[HTML]And[CSS]`      |
| Uppercase words                 | `[UPPERCASE] [WORDS]` |
| Lowercase words                 | `[lowercase] [words]` |
| Hexadecimal literals            | `[0x00ffFF] [0x0f]`   |
| Binary literals                 | `[0b01] [0b0011]`     |
| Regular Numbers                 | `[1234] [5678]`       |
| Other keywords (`iskeyword`)    | `foo[_]bar`           |
| Other non-whitespace characters | `[~!@#$]`             |

Caveats
=======

There are some special cases with how Vim's word motions work. Not sure if
they should be reproduced in this plugin.  
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
