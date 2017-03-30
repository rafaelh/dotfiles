"
" .vimrc
"
" Initial settings in required order. The first line removes legacy vi
" compatability, and the second enables the pathogen module manager

set nocompatible
execute pathogen#infect()

" Test Settings
if !has("gui_running")
    set term=xterm
    set t_Co=256
    let &t_AB="\e[48;5;%dm"
    let &t_AF="\e[38;5;%dm"
    colorscheme tender
endif


" === Global Settings ===
colorscheme molokai
set modeline
set encoding=utf-8             " Character Encoding
set ignorecase                 " Searches are case insensitive
set smartcase                  " Unless they contain at least 1 capital letter
set incsearch                  " Incremental searching
set hlsearch                   " Highlight matches
set showcmd                    " Show command in bottom bar
set autoindent                 " Automatically indent lines
set foldenable                 " Enable folding
set foldmethod=indent          " Fold based on indent level
set backspace=indent,eol,start " Backspace through everything
set lazyredraw                 " Redraw only when we need to
set showmatch                  " Highlight matching [{()}]
set clipboard=unnamed          " Don't use a vim-specific clipboard
set autoread                   " Set to autoread if file is updated externally
syntax enable                  " Enable syntax processing
filetype plugin indent on      " load file type plugins + indentation


" Show < or > when characters are not displayed on the left or right.
set list
set list listchars=nbsp:¬,tab:>-,precedes:<,extends:>


" Folding
set foldenable                 " Enable folding
set foldmethod=indent          " Fold based on indent level
set foldlevel=99               " Don't fold automatically
nnoremap <space> za            " Enable folding with the spacebar


" Show More Info in the statusline, without going overboard 
set laststatus=2
set statusline=%<%f\ %m%r%y%=%-35.(Line:\ %l/%L\ [%p%%][Format=%{&ff}]%)


" Use :w!! to write a file when you forget to edit it with sudo
cmap w!! w !sudo tee % >/dev/null


" Wildmenu
set wildmenu
set wildmode=longest,list,full
set wildignore=.svn,CVS,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif


" Allows cursor change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif


" === Coding tweaks ===

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Use UNIX (\n) line endings for new files
au BufNewFile *.vim,*.pl,*.sh set fileformat=unix

" Turn on line numbering for certain files
au BufRead,BufNewFile *.vim,*.pl,*.sh set nu


" === Python ===
let python_highlight_all=1
au BufRead,BufNewFile *.py,*.pyw set textwidth=79
au BufRead,BufNewFile *.py,*.pyw set tabstop=4
""    \ set softtabstop=4
 ""   \ set shiftwidth=4
  ""  \ set expandtab
""    \ set nu
 ""   \ set fileformat=unix
  "  \ match BadWhitespace /^\t\+/ " Tabs at the beginning of a line are bad
 "   \ match BadWhitespace /\s\+$/ " Trailing Whitespace is bad


" === JavaScript, HTML and CSS ===
au BufRead,BufNewFile *.js, *.html, *.css 
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2
    \ set nu


" === C ===
fu Select_c_style()
    if search('^\t', 'n', 150)
        set shiftwidth=8
        set noexpandtab
    el 
        set shiftwidth=4
        set expandtab
    en
endf
au BufRead,BufNewFile *.c,*.h 
    \ call Select_c_style()
    \ set textwidth=79
    \ set softtabstop=4
    \ set formatoptions-=c formatoptions-=o formatoptions-=r
    \ set fileformat=unix
    \ set nu
    \ match BadWhitespace /\s\+$/ " Trailing Whitespace is bad

au BufRead,BufNewFile Makefile* set noexpandtab


