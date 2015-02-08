"
"
"
"
"Author Sun Yuan syhkiller@163.com

if exists('g:loaded_autoinclude')
    finish
endif
let g:loaded_autoinclude = 1


let s:auto_include_qf_flg = 0
let g:auto_include_cursor_invoker = get(g:, 'auto_include_cursor_invoker', 'i')
let g:auto_include_guard = get(g:, 'auto_include_guard', '//auto-include {{{')
let g:auto_include_close = get(g:, 'auto_include_close', '//}}}')
let g:auto_include_after_line = get(g:, 'auto_include_after_line', 0)
let g:auto_append_guard = get(g: ,'auto_append_guard', 1)

let s:autoinclude_file = expand('<sfile>:p')
let s:autoinclude_plugin_dir = expand('<sfile>:p:h:h')
let g:auto_include_db = get(g:, 'auto_include_db', {})
function LoadDB()
python<<EOF
import os
import vim
plugin_dir = vim.eval('s:autoinclude_plugin_dir') + '/db/'
rst = vim.eval('g:auto_include_db')
for catelog in os.listdir(plugin_dir):
    if catelog.startswith('.'):continue
    d = {}
    with open(plugin_dir + catelog) as opf:
        inc = None
        for line in opf.readlines():
            line = line.strip()
            if line.startswith('#'):continue
            if ':' in line:
                inc = line.split(':')[0].strip()
                continue
            d[line] = inc
    rst[catelog] = d
vim.command("let g:auto_include_db = %s"%repr(rst))
EOF
endfunc

function s:AppendGuard()
    if &filetype ==? 'c' || &filetype ==? 'cpp'
        call append(g:auto_include_after_line, g:auto_include_guard)
        call append(g:auto_include_after_line+1, g:auto_include_close)
    endif
endfunc

if g:auto_append_guard == 1
    au bufnewfile * call s:AppendGuard()
endif

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
        if empty(inc) | let inc = matchstr(getline('.'), '".*"') | endif
        cclose
        call setqflist([])
        let s:auto_include_qf_flg = 0
        call AutoInclude(inc)
    endif
endfunc
function AutoInclude(inc)
   if NeedInclude( a:inc )
        let lineno = search(g:auto_include_guard, 'n')
        while matchstr(getline(lineno+1), '#include *<.*>') != ''
            let lineno += 1
        endwhile
        if matchstr(a:inc, '".*"') != ''
            while matchstr(getline(lineno+1), '#include *".*"') != ''
                let lineno += 1
            endwhile
        endif
        call append(lineno, '#include ' . a:inc)
   endif 
endfunc

function AutoMapCR()
    echo 'automapcr'
    if s:auto_include_qf_flg 
        "autocmd! BufReadPost quickfix  nnoremap <CR> :call AutoIncludeQuickFix()<CR>
        nnoremap <buffer> <CR> :call AutoIncludeQuickFix()<CR>
    endif
endfunc

autocmd! BufReadPost quickfix call AutoMapCR()
"auto include for keyword may open quickfix list
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
        "autocmd! BufReadPost quickfix  nnoremap <CR> :call AutoIncludeQuickFix()<CR>
        exec "silent! cexpr result"
        bot copen
    endif
endfunc

function AutoIncludeCursor()
    let kwd = expand('<cword>')
    call AutoIncludeForkeyword(kwd)
endfunc

function AutoIncludeHeaders(headers)
    for header in a:headers
        call AutoInclude(header)
    endfor
endfunc

exec "map <silent><leader>".g:auto_include_cursor_invoker . " :call AutoIncludeCursor()<CR>"
au FileType c,cpp call LoadDB()

command! -nargs=* INC call AutoIncludeHeaders(split('<args>'))
command! -nargs=* IS call AutoIncludeHeaders(map(split('<args>'), '"<". v:val .">"'))
command! -nargs=* IN call AutoIncludeHeaders(map(split('<args>'), '"\"". v:val ."\""'))
