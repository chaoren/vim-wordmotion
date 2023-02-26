# More useful word motions for Vim

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

| `word`           | Example               |
| :--------------- | :-------------------- |
| Camel case words | `[Camel][Case]`       |
| Acronyms         | `[HTML]And[CSS]`      |
| Uppercase words  | `[UPPERCASE] [WORDS]` |
| Lowercase words  | `[lowercase] [words]` |
| Hex color codes  | `[#0f0f0f]`           |
| Hex literals     | `[0x00ffFF] [0x0f]`   |
| Octal literals   | `[0o644] [0o0755]`    |
| Binary literals  | `[0b01] [0b0011]`     |
| Regular numbers  | `[1234] [5678]`       |
| Other characters | `[~!@#$]`             |

A `WORD` (uppercase) is any sequence of non-space characters separated by
spaces.

## Customization

Default `word`/`WORD` mappings:

| Mode  |          Mapping          |
| :---: | :-----------------------: |
| `nxo` |          `w`/`W`          |
| `nxo` |          `b`/`B`          |
| `nxo` |          `e`/`E`          |
| `nxo` |         `ge`/`gE`         |
| `xo`  |         `aw`/`aW`         |
| `xo`  |         `iw`/`iW`         |
|  `c`  | `<C-R><C-W>`/`<C-R><C-A>` |

You do **NOT** need any of the mapping customizations below if the default
mappings already work for you.

### `g:wordmotion_prefix`

Use `g:wordmotion_prefix` to apply a common prefix to each of the default word
motion mappings.

### `g:wordmotion_mappings`

Use `g:wordmotion_mappings` to individually replace the default word motion
mappings. `g:wordmotion_mappings` is a dictionary where the keys are the default
mappings and the values are the mappings that you want to replace them with.
Unspecified entries will still use the default mappings. Entries set to an empty
string will be disabled.

### `g:wordmotion_nomap`

Use `g:wordmotion_nomap` to disable all of the default mappings. You can create
your own mappings to the `<Plug>WordMotion_` internal mappings. Since there are
multiple modes involved for many of the mappings, it's probably more convenient
to use `g:wordmotion_prefix` or `g:wordmotion_mappings`.

### `g:wordmotion_spaces`

Use `g:wordmotion_spaces` to designate extra space characters.
`g:wordmotion_spaces` is a list where each item is a regular expression for
a character that you want to treat as a space. You have to make sure the regex
matches a single character. You can use lookaheads and lookbehinds for
context-sensitive space characters.

By default, these are treated as spaces in addition to the actual space
characters:
1. hyphens (`-`) between between alphabetic characters
2. underscores (`_`) between alphanumeric characters

### `g:wordmotion_uppercase_spaces`

Use `g:wordmotion_uppercase_spaces` to designate extra space characters for
uppercase motions. These are separate from `g:wordmotion_spaces`. There are
no extra space characters for uppercase motions by default.
