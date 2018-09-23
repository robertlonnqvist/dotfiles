set nocompatible    " not compatible with the old-fashion vi mode

filetype off        " support plugin loaders

syntax on           " syntax highlight

filetype plugin indent on " enable filetype specific settings

" no beeping
set noerrorbells
set novisualbell
set t_vb=

set showmatch     " cursor shows matching ) and }
set ruler         " show the cursor position all the time
set laststatus=2  " always show status bar
set autoindent    " auto indentation
set scrolloff=3   " always keep the cursor one step above
set nobackup      " no *~ backup files
set noswapfile    " no swap files

set backspace=indent,eol,start " allow backspacing over everything in insert mode

set title         " use window title

" tab settings
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab     " use white spaces instead of tabs

set wildmenu    " available commands above command line when using completion
set showcmd     " show incomplete commands down the bottom

set background=dark

set clipboard=unnamed " use system clipboard by default

set mouse=a " enable mouse support
