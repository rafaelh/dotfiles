" Vim color file:  zencat.vim
" Last Change: 26 Oct, 2011
" License: public domain
" Maintainer: Rafael Hart <zen.cat.nine AT gmail DOT com>
" Based on Colorful256 by Jagpreet<jagpreetc AT gmail DOT com>
"
" for a 256 color capable terminal
" You must set t_Co=256 in your .vimrc before using this colorscheme 
"
" Color numbers (0-255) see:
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html

if &t_Co != 256 && ! has("gui_running")
    echomsg ""
    echomsg "Colours not loaded. First please \'set t_Co=256\' in your .vimrc"
    echomsg ""
    finish
endif

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "zencat"
syntax match mySymbols "[{}(!@#$%^&*-_+|\/`~)?<>:;=]"

hi mySymbols    cterm=none ctermfg=255 ctermbg=16  gui=none guifg=#eeeeee guibg=#000000
hi Normal       cterm=none ctermfg=250 ctermbg=16  gui=none guifg=#bcbcbc guibg=#000000
hi Special      cterm=none ctermfg=201 ctermbg=16  gui=none guifg=#ff00ff guibg=#000000
hi Comment      cterm=none ctermfg=26  ctermbg=16  gui=none guifg=#005fdf guibg=#000000
hi Constant     cterm=none ctermfg=34  ctermbg=16  gui=none guifg=#00af00 guibg=#000000
hi LineNr       cterm=none ctermfg=244 ctermbg=233 gui=none guifg=#808080 guibg=#000000
hi Number       cterm=none ctermfg=190 ctermbg=16  gui=none guifg=#dfff00 guibg=#000000
hi PreProc      cterm=none ctermfg=34  ctermbg=16  gui=none guifg=#00af00 guibg=#000000
hi Statement    cterm=none ctermfg=32  ctermbg=16  gui=none guifg=#0087df guibg=#000000
hi Type         cterm=none ctermfg=39  ctermbg=16  gui=none guifg=#00afff guibg=#000000
hi Error        cterm=none ctermfg=196 ctermbg=16  gui=none guifg=#ff0000 guibg=#000000
hi Identifier   cterm=none ctermfg=201 ctermbg=16  gui=none guifg=#ff00ff guibg=#000000
hi SpecialKey   cterm=none ctermfg=36  ctermbg=16  gui=none guifg=#00af87 guibg=#000000
hi NonText      cterm=none ctermfg=244 ctermbg=232 gui=none guifg=#808080 guibg=#080808
hi Directory    cterm=none ctermfg=34  ctermbg=16  gui=none guifg=#00af00 guibg=#000000
hi ErrorMsg     cterm=none ctermfg=196 ctermbg=16  gui=none guifg=#ff0000 guibg=#000000
hi MoreMsg      cterm=none ctermfg=226 ctermbg=16  gui=none guifg=#ffff00 guibg=#000000
hi Title        cterm=none ctermfg=199 ctermbg=16  gui=none guifg=#ff00af guibg=#000000
hi WarningMsg   cterm=none ctermfg=196 ctermbg=16  gui=none guifg=#ff0000 guibg=#000000
hi DiffDelete   cterm=none ctermfg=207 ctermbg=16  gui=none guifg=#ff5fff guibg=#000000
hi Search       cterm=none ctermfg=202 ctermbg=16  gui=none guifg=#ff5f00 guibg=#000000
hi Visual       cterm=none ctermfg=202 ctermbg=232 gui=none guifg=#ff5f00 guibg=#080808
hi Cursor       cterm=none ctermfg=16  ctermbg=226 gui=none guifg=#000000 guibg=#ffff00
hi StatusLine   cterm=none ctermfg=255 ctermbg=233 gui=none guifg=#eeeeee guibg=#808080
hi StatusLineNC cterm=none ctermfg=253 ctermbg=232 gui=none guifg=#dadada guibg=#080808
hi Question     cterm=none ctermfg=226 ctermbg=226 gui=none guifg=#ffff00 guibg=#000000
hi Todo         cterm=none ctermfg=166 ctermbg=16  gui=none guifg=#df5f00 guibg=#000000
hi Folded       cterm=none ctermfg=34  ctermbg=16  gui=none guifg=#00af00 guibg=#000000
hi ModeMsg      cterm=none ctermfg=226 ctermbg=16  gui=none guifg=#ffff00 guibg=#000000
hi VisualNOS    cterm=none ctermfg=16  ctermbg=28  gui=none guifg=#000000 guibg=#008700
hi WildMenu     cterm=none ctermfg=16  ctermbg=226 gui=none guifg=#000000 guibg=#ffff00
hi FoldColumn   cterm=none ctermfg=243 ctermbg=16  gui=none guifg=#767676 guibg=#000000
hi SignColumn   cterm=none ctermfg=16  ctermbg=28  gui=none guifg=#000000 guibg=#008700
hi DiffText     cterm=none ctermfg=16  ctermbg=34  gui=none guifg=#000000 guibg=#00af00
hi VertSplit    cterm=none ctermfg=234 ctermbg=234 gui=none guifg=#df8700 guibg=#ffffff
hi User1        cterm=none ctermbg=27  ctermfg=16  gui=none guibg=#005fff guifg=#000000
hi User2        cterm=none ctermbg=26  ctermfg=16  gui=none guibg=#005fdf guifg=#000000
hi User3        cterm=none ctermbg=25  ctermfg=16  gui=none guibg=#005faf guifg=#000000
hi User4        cterm=none ctermbg=24  ctermfg=16  gui=none guibg=#005f87 guifg=#000000
hi User5        cterm=none ctermbg=23  ctermfg=16  gui=none guibg=#005f5f guifg=#000000

" for groups introduced in version 7
if v:version >= 700
    hi Pmenu       cterm=none      ctermfg=240 ctermbg=234 gui=none guifg=#000000 guibg=#df00ff
    hi PmenuSel    cterm=none      ctermfg=16  ctermbg=220 gui=none guifg=#000000 guibg=#ffdf00
    hi PMenuSbar   cterm=none      ctermfg=240 ctermbg=234 gui=none guifg=#000000 guibg=#df00ff
    hi PMenuThumb  cterm=none      ctermfg=237 ctermbg=232 gui=none guifg=#000000 guibg=#df00ff
    hi TabLine     cterm=underline ctermfg=244 ctermbg=232 gui=underline guifg=#808080 guibg=#080808
    hi TabLineSel  cterm=underline ctermfg=255 ctermbg=28  gui=underline guifg=#eeeeee guibg=#008700
    hi TabLineFill cterm=underline ctermfg=244 ctermbg=16  gui=underline guifg=#808080 guibg=#808080
endif

"for taglist plugin
"
if exists('loaded_taglist')
    hi TagListTagName  cterm=none ctermfg=16  ctermbg=28 gui=none guifg=#000000 guibg=#008700
    hi TagListTagScope cterm=none ctermfg=16  ctermbg=28 gui=none guifg=#000000 guibg=#008700
    hi TagListTitle    cterm=none ctermfg=199 ctermbg=16 gui=none guifg=#ff00af guibg=#000000
    hi TagListComment  cterm=none ctermfg=16  ctermbg=28 gui=none guifg=#000000 guibg=#008700
    hi TagListFileName cterm=none ctermfg=15  ctermbg=90 gui=none guifg=#ffffff guibg=#870087
endif
