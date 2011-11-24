let s:save_cpo = &cpo
set cpo&vim

let s:langmap = {
\ 'basic': 'bas',
\ 'brainfuck': 'bl',
\ 'haskell': 'hs',
\ 'javascript': 'js',
\ 'lisp': 'lsp',
\ 'ocaml': 'ml',
\ 'perl6': 'p6',
\ 'perl': 'pl',
\ 'postscript': 'ps',
\ 'python': 'py',
\ 'python3': 'py3',
\ 'ruby': 'rb',
\ 'ruby19': 'rb19',
\ 'scheme': 'scm',
\}

function! lleval#Post(line1, line2)
  let content = join(getline(a:line1, a:line2), "\n")
  let lang = get(s:langmap, &ft, expand('%:e'))
  let res = http#get('http://api.dan.co.jp/lleval.cgi', { 's': content, 'l': lang })
  let msg = len(res.header[0]) > 0 ? res.header[0] : 'Unknown Error'
  if msg !~ '200'
    echohl ErrorMsg | echomsg 'Edit failed: '.msg | echohl None
    return
  endif
  let obj = json#decode(res.content)
  if has_key(obj, 'stderr')
    echohl WarningMsg | echo obj['stderr'] | echohl None
  endif
  if has_key(obj, 'stdout')
    echohl None | echo obj['stdout']
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
