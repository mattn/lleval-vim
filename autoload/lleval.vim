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

if !exists('g:lleval_browser_command')
  if has('win32') || has('win64')
    let g:lleval_browser_command = "!start rundll32 url.dll,FileProtocolHandler %URL%"
  elseif has('mac')
    let g:lleval_browser_command = "open %URL%"
  elseif executable('xdg-open')
    let g:lleval_browser_command = "xdg-open %URL%"
  else
    let g:lleval_browser_command = "firefox %URL% &"
  endif
endif

function! lleval#PostWithLink(line1, line2)
  let content = join(getline(a:line1, a:line2), "\n")
  let lang = get(s:langmap, &ft, expand('%:e'))
  let data = http#encodeURI({ 'src': content, 'lang': lang, 'save': 'on' })
  let url = 'http://seiitaishougun.com/lleval.cgi'
  let quote = &shellxquote == '"' ?  "'" : '"'

  let command = 'curl -L -s -k -i -X POST '.quote.url.quote
  let file = tempname()
  call writefile(split(data, "\n"), file, "b")
  let res = system(command . " --data-binary @" . quote.file.quote)
  call delete(file)
  let header = split(res, '\r\?\n')
  let loc = matchstr(header, '^Location:')
  if len(loc) == 0
    let msg = len(res.header[0]) > 0 ? res.header[0] : 'Unknown Error'
    if msg !~ '200'
      echohl ErrorMsg | echomsg 'Edit failed: '.msg | echohl None
      return
    endif
  endif
  let loc = matchstr(loc, '^[^:]\+: \zs.*')
  if loc =~ '^/'
    let loc = 'http://seiitaishougun.com'.loc
  endif
  echo loc
  let cmd = substitute(g:lleval_browser_command, '%URL%', loc, 'g')
  if cmd =~ '^!'
    silent! exec cmd
  elseif cmd =~ '^:[A-Z]'
    exec cmd
  else
    call system(cmd)
  endif
endfunction

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
  if has_key(obj, 'error')
    echohl ErrorMsg | echo obj['error'] | echohl None
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et:
