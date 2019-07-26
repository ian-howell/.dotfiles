if exists("b:current_syntax")
    finish
endif

syn region	monkeyCString		start=/\v"/ skip=/\v\\./ end=/\v"/
syn match	monkeyCCharacter	"L\='[^\\]'"
syn keyword	monkeyCBoolean		false true
syn keyword	monkeyCNull		null
syn keyword	monkeyCRepeat		for do while break continue
syn keyword	monkeyCConditional	if else
syn match	monkeyCInclude		"\vToybox(.\u\w+)*[^;]"
syn keyword	monkeyCKeyword		using as extends has instanceof self me
syn keyword	monkeyCStatement	new return hidden public protected private
syn keyword	monkeyCException	try catch throw finally
syn keyword	monkeyCStorageClass	var const
syn keyword	monkeyCStructure	class function module enum

syn keyword	monkeyCType		Graphics System Lang WatchUi Timer Attention
syn keyword	monkeyCType    		Number Float Char Long Double String

syn keyword	monkeyCConstant		COLOR_WHITE COLOR_LT_GRAY COLOR_DK_GRAY COLOR_BLACK COLOR_RED COLOR_DK_RED COLOR_ORANGE COLOR_YELLOW COLOR_GREEN COLOR_DK_GREEN COLOR_BLUE COLOR_DK_BLUE COLOR_PURPLE COLOR_PINK COLOR_TRANSPARENT
syn keyword	monkeyCConstant		FONT_XTINY FONT_TINY FONT_SMALL FONT_MEDIUM FONT_LARGE FONT_NUMBER_MILD FONT_NUMBER_MEDIUM FONT_NUMBER_HOT FONT_NUMBER_THAI_HOT FONT_SYSTEM_XTINY FONT_SYSTEM_TINY FONT_SYSTEM_SMALL FONT_SYSTEM_MEDIUM FONT_SYSTEM_LARGE FONT_SYSTEM_NUMBER_MILD FONT_SYSTEM_NUMBER_MEDIUM FONT_SYSTEM_NUMBER_HOT FONT_SYSTEM_NUMBER_THAI_HOT
syn keyword	monkeyCConstant		TEXT_JUSTIFY_RIGHT TEXT_JUSTIFY_CENTER TEXT_JUSTIFY_LEFT TEXT_JUSTIFY_VCENTER
syn keyword	monkeyCConstant		ARC_COUNTER_CLOCKWISE ARC_CLOCKWISE

syn match	monkeyCOperator		"\v\*"
syn match	monkeyCOperator		"\v/"
syn match	monkeyCOperator		"\v\+"
syn match	monkeyCOperator		"\v-"
syn match	monkeyCOperator		"\v\?"
syn match	monkeyCOperator		"\v\:"
syn match	monkeyCOperator		"\v\%"
syn match	monkeyCOperator		"\v\*\="
syn match	monkeyCOperator		"\v/\="
syn match	monkeyCOperator		"\v\+\="
syn match	monkeyCOperator		"\v-\="
syn match	monkeyCOperator		"\v\="

syn match	monkeyCNumber		"\<\(0[0-7]*\|0[xX]\x\+\|\d\+\)[lL]\=\>"
syn match	monkeyCNumber		"\(\<\d\+\.\d*\|\.\d\+\)\([eE][-+]\=\d\+\)\=[fFdD]\="
syn match	monkeyCNumber		"\<\d\+[eE][-+]\=\d\+[fFdD]\=\>"
syn match	monkeyCNumber		"\<\d\+\([eE][-+]\=\d\+\)\=[fFdD]\>"

syn match	monkeyCLabel		":\w\+"

syn keyword	monkeyCTodo		TODO FIXME XXX TBD contained
syn match	monkeyCComment		"\/\/.*" contains=@Spell,monkeyCTodo
syn region	monkeyCComment		start="/\*" end="\*/" contains=@Spell,monkeyCTodo

" apocryphal
syn keyword	monkeyCDebug		print assert format

hi link	monkeyCString		String
hi link	monkeyCCharacter	Character
hi link	monkeyCBoolean		Constant
hi link	monkeyCNull		Constant
hi link	monkeyCRepeat		Repeat
hi link	monkeyCConditional	Conditional
hi link	monkeyCInclude		Include
hi link	monkeyCKeyword		Keyword
hi link	monkeyCStatement	Statement
hi link	monkeyCException	Exception
hi link	monkeyCStructure	Structure
hi link	monkeyCStorageClass	StorageClass
hi link	monkeyCType		Type
hi link	monkeyCConstant		Constant
hi link	monkeyCFunction		Function
hi link	monkeyCOperator		Operator
hi link	monkeyCNumber		Number
hi link	monkeyCLabel		Label
hi link	monkeyCComment		Comment
hi link	monkeyCTodo		Todo
hi link	monkeyCDebug		Debug

let b:current_syntax = "monkey-c"
