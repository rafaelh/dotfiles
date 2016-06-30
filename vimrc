set nocompatible " Must be the first line

" === Global Settings ===
set background=dark
set modeline
set encoding=utf-8
set ignorecase
set smartcase
set foldenable
set foldmethod=syntax 
set t_Co=256
set backspace=indent,eol,start 
set incsearch
set lazyredraw
set showmatch
"setlocal spell spelllang=en

"if has("mouse")
"    set mouse=a
"    set mousehide
"endif

" Syntax Highlighting & auto-indent
let python_highlight_all=1
syntax on
set ofu=syntaxcomplete#Complete
colorscheme desert 
set antialias
filetype on
filetype plugin on 
filetype indent on
set autoindent

" Wildmenu
set wildmenu
set wildmode=longest,list,full
set wildignore=.svn,CVS,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif

map <F2> :NERDTreeToggle<CR>

" Show < or > when characters are not displayed on the left or right.
set list
set list listchars=nbsp:¬,tab:>-,precedes:<,extends:>

" Set to auto read when a file is changed from the outside
set autoread

" Show More Info in the statusline, without going overboard 
set laststatus=2
set statusline=%<%f\ %m%r%y%=%-35.(Line:\ %l/%L\ [%p%%][Format=%{&ff}]%)

" Use :w!! to write a file when you forget to edit it with sudo
cmap w!! w !sudo tee % >/dev/null

" === Coding tweaks ===
" All setting are protected by 'au' ('autocmd') statements.  Only files ending
" in .py or .pyw will trigger the Python settings while files ending in *.c or
" *.h will trigger the C settings. 

au BufRead,BufNewFile *py,*pyw,*.c,*.h set tabstop=4
au BufRead,BufNewFile *py,*pyw,*.c,*.h set softtabstop=4
au BufRead,BufNewFile *.py,*pyw set shiftwidth=4
au BufRead,BufNewFile *.py,*.pyw set expandtab

fu Select_c_style()
    if search('^\t', 'n', 150)
        set shiftwidth=8
        set noexpandtab
    el 
        set shiftwidth=4
        set expandtab
    en
endf
au BufRead,BufNewFile *.c,*.h call Select_c_style()
au BufRead,BufNewFile Makefile* set noexpandtab

" Use the below highlight group when displaying bad whitespace is desired.
highlight BadWhitespace ctermbg=red guibg=red

" Display tabs at the beginning of a line in Python mode as bad.
au BufRead,BufNewFile *.py,*.pyw match BadWhitespace /^\t\+/

" Make trailing whitespace be flagged as bad.
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" Wrap text after a certain number of characters
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h set textwidth=79

" Turn off settings in 'formatoptions' relating to comment formatting.
" - c : do not automatically insert the comment leader when wrapping based on
"    'textwidth'
" - o : do not insert the comment leader when using 'o' or 'O' from command mode
" - r : do not insert the comment leader when hitting <Enter> in insert mode
" Python: not needed, C: prevents insertion of '*' at the beginning of every line in a comment
au BufRead,BufNewFile *.c,*.h set formatoptions-=c formatoptions-=o formatoptions-=r

" Use UNIX (\n) line endings.
" Only used for new files so as to not force existing files to change their line endings.
au BufNewFile *.py,*.pyw,*.c,*.h,*.vim,*.pl,*.sh set fileformat=unix

" Turn on line numbering for certain files
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h,*.vim,*.pl,*.sh set nu
