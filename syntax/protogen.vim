" Vim syntax file
" Language:     protogen - protocol definition file (.fmt) for
"               bbnet/tools/protogen.py
" Maintainer:   skywind3000
" Last Change:  2026 Sep 23
"
" Syntax of .fmt files:
"   packet Name = 0xMID:            packet declaration (MID optional)
"       int32 version = 0x1000      property with optional default
"       map<int32, string> caps     map property
"       array<int32> flags          array property
"   # / ; / //                      line comments
"   @lang code                      inline code, inserted into output
"   ```lang ... ```                 embedded code block (eg. ```cpp)

" quit when a syntax file was already loaded
if exists("b:current_syntax")
	finish
endif

let s:cpo_save = &cpo
set cpo&vim

" embedded cpp code block, include cpp syntax for it
unlet! b:current_syntax
syn include @protogenCpp syntax/cpp.vim

syn case match

" comments: '#' or ';' or '//' start a comment until end of line
syn match protogenComment "#.*$"
syn match protogenComment ";.*$"
syn match protogenComment "//.*$"

" embedded code block: ```cpp ... ``` (must be defined before generic one)
" keepend: the block may contain unbalanced braces (eg. "namespace X {"),
" the closing fence must terminate the block anyway
syn region protogenCppBlock matchgroup=protogenFence
      \ start="^\s*```\s*cpp\s*$" end="^\s*```\s*$" keepend
      \ contains=@protogenCpp

" generic embedded code block: ```lang ... ``` (but not cpp)
syn region protogenCodeBlock matchgroup=protogenFence
      \ start="^\s*```\s*\%(cpp\)\@!\w*\s*$" end="^\s*```\s*$" keepend

" inline directive: "@lang code"
syn match protogenInline "^\s*@.*$"

" strings
syn region protogenString start=+'+ skip=+\\.+ end=+'+ oneline
syn region protogenString start=+"+ skip=+\\.+ end=+"+ oneline

" packet declaration: "packet Name = MID:" (MID is optional)
syn match protogenPacketName "\(^\s*packet\s\+\)\@<=\w\+"
syn match protogenDelimiter "[<>:=@,]"

" keywords and type names, "type name" / "array<type> name" / "map<k,v> name"
" are chained with nextgroup to highlight the property name after the type
syn keyword protogenKeyword packet
syn keyword protogenType uint8 int8 uint16 int16 uint32 int32
      \ uint64 int64 float double string array map
      \ nextgroup=protogenPropName,protogenAngle skipwhite
syn region protogenAngle matchgroup=protogenDelimiter start="<" end=">"
      \ contained contains=protogenType,protogenDelimiter
      \ nextgroup=protogenPropName skipwhite
syn match protogenPropName "\w\+" contained

" numbers
syn match protogenNumber "\<0[xX]\x\+\>"
syn match protogenNumber "\<\d\+\%(\.\d*\)\?\>"

" c.vim sets "syn sync ccomment" on include, override it: fmt files
" are small, parsing from start is the most reliable
syn sync fromstart

" Define the default highlighting
hi def link protogenComment    Comment
hi def link protogenKeyword    Statement
hi def link protogenType       Type
hi def link protogenPacketName Function
hi def link protogenPropName   Identifier
hi def link protogenString     String
hi def link protogenNumber     Number
hi def link protogenDelimiter  Delimiter
hi def link protogenInline     PreProc
hi def link protogenFence      PreProc

let b:current_syntax = "protogen"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sts=4 sw=4 noet
