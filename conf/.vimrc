" Specify a directory for plugins
" T onstall plugins https://github.com/junegunn/vim-plug   :PlugInstall
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')
"
" Make sure you use single quotes
"
" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Tab completion
Plug 'metalelf0/supertab'

" Markdown plugin
Plug 'godlygeek/tabular'

" Ctrl p for opening files
Plug 'ctrlpvim/ctrlp.vim'

" For searching
Plug 'rking/ag.vim'
Plug 'Chun-Yang/vim-action-ag'
"
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

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
Plug 'https://github.com/adelarsq/vim-matchit'

"For surrounding elements
Plug 'tpope/vim-surround'

" Coffee script syntax
Plug 'kchmck/vim-coffee-script'

" Match tags
Plug 'Valloric/MatchTagAlways'

" Language support
Plug 'sheerun/vim-polyglot'

" JSX syntax
Plug 'pangloss/vim-javascript'
Plug 'yuezk/vim-js'
Plug 'maxmellon/vim-jsx-pretty'

" Typescript syntax
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

" Does lots of stuff like autocompleteion etc.
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Vertical marks
Plug 'Yggdroot/indentLine'

" History
Plug 'simnalamburt/vim-mundo'

" Zoom in on split window ala tmux
Plug 'troydm/zoomwintab.vim' 

" Show marks in gutter
Plug 'kshenoy/vim-signature'

" Show contents of registers
Plug 'junegunn/vim-peekaboo'

" Vim debugger https://github.com/puremourning/vimspector
Plug 'puremourning/vimspector'

" Copilot - github ai for code completion
" When installing first time run  :Copilot setup and copy 8 digit code in vim
" to browser
Plug 'github/copilot.vim'

" https://www.dailysmarty.com/posts/how-to-setup-prettier-with-vimu
Plug 'prettier/vim-prettier'

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
nnoremap * yiw*N

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

" set typescrpt syntax
au BufRead,BufNewFile *.ts   setfiletype typescript
au BufRead,BufNewFile *.tsx   setfiletype typescriptreact

" For autocompletion - ctr space instead of ctrl x ctrl o http://vim.wikia.com/wiki/Auto_closing_an_HTML_tag
:imap <C-Space> <C-X><C-O>

:nnoremap <leader>sp :setlocal spell! spelllang=en_us <cr>


" Comment out lines (ruby) could extend for other languages. Sometime!
:nnoremap <leader>cc :s/^/#/<cr> :nohl <cr>

" UnComment out lines (ruby) could extend for other languages. Sometime!
:nnoremap <leader>cd :s/^#//<cr> :nohl <cr>

" Ctl p ignore
let g:ctrlp_custom_ignore = '\v[\/](bower|bower_components|node_modules|target|dist|_site|vendor|tmp|build|coverage)|(\.(swp|ico|git|svn))$'
map <leader>C :CtrlPClearCache<cr>
"Allow more results for ctrl p https://github.com/kien/ctrlp.vim/issues/187
let g:ctrlp_match_window = 'results:20'

" set paset mode
:nnoremap <leader>p :set paste <cr>

" open up vimrc to edit. $MYVIMRC is the location of vimrc file - updated 
" to actual path as neovim has different location but sources this
:nnoremap <leader>ev :vsplit ~/.vimrc<cr> G

" source vimrc
:nnoremap <leader>sv :source $MYVIMRC<cr>

" ctrl and up and down to move between tabs
:map <C-j> :tabn<cr>:set showtabline=2<cr>
:map <C-k> :tabp<cr>:set showtabline=2<cr>

:map :W :w<cr>
" Copy lines visually selected into the register equivalent to system
" clipboard
" map <C-c> "+y

"https://stackoverflow.com/a/39313208
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" WSL yank support
" https://superuser.com/a/1557751
let s:clip = '/mnt/c/Windows/System32/clip.exe'
if executable(s:clip)
  augroup WSLYank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
  augroup END
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
let NERDTreeQuitOnOpen = 0

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

" ensure you symlink vim-colors folder to ~/.vim/colors
colorscheme mikecolor 

" Toggle cursor center
" https://vim.fandom.com/wiki/Keep_your_cursor_centered_vertically_on_the_screen
:nnoremap <Leader>zz :let &scrolloff=999-&scrolloff<CR>

" Mike's macros

let @b = 'odebugger'
autocmd BufRead,BufNewFile *.rb  let @b = 'orequire "pry"; binding.pry'
let @p = 'orequire "pry"; binding.pry'
:nnoremap <leader>l  :g/debugger/d <cr>:g/pry-remote/d<cr> :g/binding.pry/d<cr>

" This is a specific work shortcut - this is the new
" syntax for our design system
let @s ='otop: ${({ theme }) => theme.spacing[16]};0'

" Clear trailing white space
let @c = ':%s/\s\+$//'

" vertically split last pannel 
:nnoremap <leader>ss :sp \| b# <cr><cr>

" "+ is system clipboard.
" "% is the filename
" this copies the file name to the clipboard
" TODO https://superuser.com/questions/1291425/windows-subsystem-linux-make-vim-use-the-clipboard
:map <leader>f :let @+=@% <cr>
"
" format file js file with jq
:nnoremap <leader>js :%! jq '.'<cr>

" format file  html file with tidy
:nnoremap <leader>html :!tidy -mi -html -wrap 0 %<cr>

" clear trailng white space on save
autocmd BufWritePre *.{rb,js,erb,json,scss,html,ts,tsx} :%s/\s\+$//e
autocmd BufWritePre *.{jsx,rb,js,erb,json,scss,html,ts,tsx} :retab

let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue PrettierAsync

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

"  vertical line character for ident line plug in
let g:indentLine_char = '⦙'


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

"Alias
:command B Buffers 

" Highlight words as you search
set incsearch

" Set status bar to include git status
set statusline=%{FugitiveStatusline()}\ %f\ %m

let g:coc_global_extensions = ['coc-tsserver']
 autocmd FileType json syntax match Comment +\/\/.\+$+ 


set exrc
" Project specific vimrc files https://andrew.stwrt.ca/posts/project-specific-vimrc/
set secure
if !empty(glob(".vimrc"))
  source .vimrc
endif

" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=number


" map autoselect control to j/k
inoremap <expr> j ((pumvisible())?("\<C-n>"):("j"))
inoremap <expr> k ((pumvisible())?("\<C-p>"):("k"))

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<TAB>"


" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-d> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-d>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

