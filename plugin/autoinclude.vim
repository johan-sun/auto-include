"
"
"
"
"Author Sun Yuan syhkiller@163.com

if exists('g:loaded_autoinclude')
    finish
endif
let g:loaded_autoinclude = 1

if !exists('g:auto_include_cursor_invoker')
    let g:auto_include_cursor_invoker = 'i'
endif

let s:auto_include_qf_flg = 0
if ! exists('g:auto_include_guard')
    let g:auto_include_guard = '//auto-include {{{'
endif

if ! exists('g:auto_include_close')
    let g:auto_include_close = '//}}}'
endif

if ! exists('g:auto_include_after_line')
    let g:auto_include_after_line = 0
endif

function s:AppendGuard()
    if &filetype ==? 'c' || &filetype ==? 'cpp'
        call append(g:auto_include_after_line, g:auto_include_guard)
        call append(g:auto_include_after_line+1, g:auto_include_close)
    endif
endfunc
let g:auto_append_guard = 1
if exists('g:auto_append_guard') && g:auto_append_guard == 1
    au bufnewfile * call s:AppendGuard()
endif

"here is example maybe re-design
let g:auto_include_db = {}
let g:auto_include_db['stl'] = { 'cin':'<iostream>', 'cout':'<iostream>','vector':'<vector>' ,}
let g:auto_include_db['posix'] = {'pthread_create':'<pthread.h>' , 'cin':'<xxx>' }
function NeedInclude(inc)
    for line in getline(1, '$')
        if matchstr(line, '#include *' . a:inc ) != ''
            return 0
        endif
    endfor
    return 1
endfunc

function AutoIncludeQuickFix()
    if s:auto_include_qf_flg
        let inc = matchstr(getline('.'), '<.*>')
        cclose
        call setqflist([])
        let s:auto_include_qf_flg = 0
        call AutoInclude(inc)
    endif
endfunc
autocmd BufReadPost quickfix  nnoremap <CR> :call AutoIncludeQuickFix()<CR>
function AutoInclude(inc)
   if NeedInclude( a:inc )
        let lineno = search(g:auto_include_guard, 'n')
        call append(lineno, '#include ' . a:inc)
   endif 
endfunc

function AutoIncludeForkeyword(kwd)
    let result = []
    for eachClass in keys(g:auto_include_db)
        if has_key(g:auto_include_db[eachClass], a:kwd)
            call add(result, g:auto_include_db[eachClass][a:kwd])
        endif
    endfor
    if len(result) == 1
        call AutoInclude(result[0])
    elseif len(result) > 1
        let s:auto_include_qf_flg = 1
        exec "silent! cexpr result"
        bot copen
    endif
endfunc

function AutoIncludeCursor()
    let kwd = expand('<cword>')
    call AutoIncludeForkeyword(kwd)
endfunc

exec "map <silent><leader>".g:auto_include_cursor_invoker . " :call AutoIncludeCursor()<CR>"
