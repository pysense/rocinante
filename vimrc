set nocompatible
set showcmd
set wildmenu
set expandtab
set softtabstop=4
set shiftwidth=4
set autoindent
set backspace=start,eol,indent
set nobackup
set noswapfile
set hlsearch
set incsearch
set cursorline
set history=10
set ruler
set enc=utf8
set fencs=utf-8,utf-16le,chinese,latin-1,ucs-bom
set fenc=chinese
"set viminfo='50,<50,s10,n.viminfo
syntax on
colorscheme desert
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif
