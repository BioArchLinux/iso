"search highlight
set hlsearch
"enable highlight
syntax on 
"line highlight
set cursorline
"show linenumber
set number
"theme
colorscheme gruvbox
set bg=dark
let g:gruvbox_transparent_bg=1
"instantly search highlight
set incsearch
"check spell
set spell
" autocomplete
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap { {}<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
"mouse
set mouse=a
"cross line
set whichwrap=b,s,<,>,[,]
"record mouse
augroup resCur
  autocmd!
  autocmd BufReadPost * call setpos(".", getpos("'\""))
augroup END
"map like office style
vmap <C-c> "+y
 map <C-v> "+p
imap <C-v> <C-r>+
vmap <C-x> "+d
vmap <C-s> <ESC>:w<CR>
nmap <C-s> :w<CR>
imap <C-s> <ESC>:w<CR>
vmap <C-q> <ESC>:wq<CR>
nmap <C-q> :wq<CR>
imap <C-q> <ESC>:wq<CR>
nmap <C-a> ggVG<CR>
imap <C-a> <ESC>ggVR<CR>i
imap <C-f> <ESC>/
nmap <C-f> /
imap <C-z> <ESC>u<CR>i
nmap <C-z> u<CR>
imap <C-y> <ESC>^R<CR>i
nmap <C-y> ^R<CR>
