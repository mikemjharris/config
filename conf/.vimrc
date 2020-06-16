" Specify a directory for plugins
" T onstall plugins https://github.com/junegunn/vim-plug   :PlugInstall
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
"
" Make sure you use single quotes
"
" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Markdown plugin
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'

" Ctrl p for opening files
Plug 'ctrlpvim/ctrlp.vim'

" For searching
Plug 'rking/ag.vim'
Plug 'Chun-Yang/vim-action-ag'
"
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

"
" Multiple Plug commands can be written in a single line using | separators
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
"
" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' } 
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
"
" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

"
" Rails related plugin
Plug 'tpope/vim-rails'
" Rails add comments
Plug 'tomtom/tcomment_vim'

" Ruby better
Plug 'tpope/vim-rbenv'
Plug 'tpope/vim-bundler'

"HTML tag matching 
Plug 'tpope/vim-surround'

" Coffee script syntax
Plug 'kchmck/vim-coffee-script'

" Focus plugin for things like autoupdating files when changed in the
" background
Plug 'tmux-plugins/vim-tmux-focus-events'

" Tab completion
Plug 'ervandew/supertab'

" Match tags
Plug 'Valloric/MatchTagAlways'

" Language support
Plug 'sheerun/vim-polyglot'

" JSX syntax
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

" Styling
Plug 'NLKNguyen/papercolor-theme' "current scheme

" Does lots of stuff like autocompleteion etc.
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Vertical marks
Plug 'Yggdroot/indentLine'

" Initialize plugin system
call plug#end()

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
"
" " Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


""""""""""""""""""""""""""""""""""""""""""""""""""
"
"" Miniml .vimrc that I found on the web - my addional setting at the end
"
""""""""""""""""""""""""""""""""""""""""""""""""""

" Description: A minimal, but feature rich, example .vimrc. If you are a
"              newbie, basing your first .vimrc on this file is a good choice.
"              If you're a more advanced user, building your own .vimrc based
"              on this file is still a good idea.

"------------------------------------------------------------
" Features {{{1
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on


"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" https://jovicailic.org/2017/04/vim-persistent-undo/
set undofile " Maintain undo history between sessions
set undodir=~/tmp/undodir

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

"This shows the column and line you are on
set cursorcolumn
set cursorline

let g:indent_guides_auto_colors = 1

set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
"set shiftwidth=4
"set tabstop=4


"------------------------------------------------------------
" Mappings {{{1
"
" Useful mappings

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Using * finds the word - I want to copy it to the clipboard as often i
" want to use it elsewhere 
nnoremap * yiw*

"------------------------------------------------------------
"


""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Various additional settings I've added over time
"
""""""""""""""""""""""""""""""""""""""""""""""""""

" Set line number to be relative to the line I'm on
set relativenumber
" leader for custom commands
" enter the leader plus the shortcut to run.  
let mapleader = " "

" setup for templatin
autocmd BufNewFile * silent! 0r $HOME/.vim/templates/%:e.skeleton

" Set ejs highlighting the same as html
au BufNewFile,BufRead *.ejs set filetype=html

" https://vi.stackexchange.com/a/13092 for autoreading of files
au FocusGained,BufEnter * :checktime

" For autocompletion - ctr space instead of ctrl x ctrl o http://vim.wikia.com/wiki/Auto_closing_an_HTML_tag
:imap <C-Space> <C-X><C-O>

:nnoremap <leader>sp :setlocal spell! spelllang=en_us <cr>


" Comment out lines (ruby) could extend for other languages. Sometime!
:nnoremap <leader>cc :s/^/#/<cr> :nohl <cr>

" UnComment out lines (ruby) could extend for other languages. Sometime!
:nnoremap <leader>cd :s/^#//<cr> :nohl <cr>

" Ctl p ignore
let g:ctrlp_custom_ignore = '\v[\/](bower|bower_components|node_modules|target|dist|_site|vendor|tmp|build)|(\.(swp|ico|git|svn))$'
map <leader>C :CtrlPClearCache<cr>
"Allow more results for ctrl p https://github.com/kien/ctrlp.vim/issues/187
let g:ctrlp_match_window = 'results:20'

" set paset mode
:nnoremap <leader>p :set paste <cr>

" open up vimrc to edit. $MYVIMRC is the location of vimrc file
:nnoremap <leader>ev :vsplit $MYVIMRC<cr> G

" source vimrc
:nnoremap <leader>sv :source $MYVIMRC<cr>

" ctrl and up and down to move between tabs
:map <C-j> :tabn<cr>
:map <C-k> :tabp<cr>

:map :W :w<cr>
" Copy lines visually selected into the register equivalent to system
" clipboard
map <C-c> "+y

"https://stackoverflow.com/a/39313208
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" Foldable config https://github.com/plasticboy/vim-markdown
let g:vim_markdown_folding_disabled = 1

" https://github.com/Valloric/MatchTagAlways
" Config for matching tags
let g:mta_filetypes = {
    \ 'html' : 1,
    \ 'xhtml' : 1,
    \ 'xml' : 1,
    \ 'jinja' : 1,
    \ 'jsx' : 1,
    \ 'javascript.jsx' : 1,
    \}
let g:mta_use_matchparen_group = 0
let g:mta_set_default_matchtag_color = 0
highlight MatchTag ctermfg=black ctermbg=lightgreen guifg=black guibg=lightgreen


" Nerdtree
" Some tips from (this
" post)[https://medium.com/@victormours/a-better-nerdtree-setup-3d3921abc0b9]
map <C-n> :NERDTreeToggle<CR>
map <C-f> :NERDTreeFind<CR>
"  open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif

" Quit nerdtree on file open
let NERDTreeQuitOnOpen = 1

" Close if last window in buffer 
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

let NERDTreeAutoDeleteBuffer = 1
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" Cursor colour and underline.  TODO need to get proper settings for zsh. Only underline works.
" https://gist.github.com/andyfowler/1195581

if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Other colours
highlight Search ctermbg=DarkMagenta
highlight Search ctermfg=white

" Color scheme
set t_Co=256   " This is may or may not needed.

if strftime("%H") < 18
  set background=light
else
  set background=dark
endif

colorscheme PaperColor

" Toggle cursor center
" https://vim.fandom.com/wiki/Keep_your_cursor_centered_vertically_on_the_screen
:nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR>

" Mike's macros

let @b = 'odebugger'
autocmd BufRead,BufNewFile *.rb  let @b = 'orequire "pry"; binding.pry'
let @p = 'orequire "pry"; binding.pry'
:nnoremap <leader>l  :g/debugger/d <cr>:g/pry-remote/d<cr> :g/binding.pry/d<cr>

" Clear trailing white space
let @c = ':%s/\s\+$//'

" vertically split last pannel 
:nnoremap <leader>s :sp \| b# <cr>

" clear trailng white space on save
autocmd BufWritePre *.{rb,js,erb,json,scss,html} :%s/\s\+$//e
autocmd BufWritePre *.{jsx,rb,js,erb,json,scss,html} :retab

" yml convert tabs to spaces
autocmd BufWritePre *.{yml} :%s/\t/  /e

" copies the current path to the unamed register
let @" = expand("%")

" set path to find files
set path+=**
" Commands
"
" delete buffer and open previous one in it's place.  Useful for keep split
" windows
command Bd bp\|bd \#

function AssignGood(foo)
  let foo_tmp = a:foo
  let foo_tmp = "Yep"
  echom foo_tmp
endfunction

filetype plugin on
au FileType php setl ofu=phpcomplete#CompletePHP
au FileType ruby,eruby setl ofu=rubycomplete#Complete
au FileType html,xhtml setl ofu=htmlcomplete#CompleteTags
au FileType c setl ofu=ccomplete#CompleteCpp
au FileType css setl ofu=csscomplete#CompleteCSS

set backupdir=~/tmp//
set directory=~/tmp//

"Abbreviations
ab exhib exhibition 
