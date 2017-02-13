let s:exe_blank_warned = 0
let s:srcdir_bin = {}
let s:hunk_pat = '^@@ -\(\d\+\),\?\(\d*\) +\(\d\+\),\?\(\d*\) @@'

function! s:gofmt_cmd() abort
  let exe = get(g:, 'gofmt_exe', 'gofmt')
  if empty(exe)
    if !s:exe_blank_warned
      let s:exe_blank_warned = 1
      echohl WarningMsg
      echo '[gofmt.vim] g:gofmt_exe is empty'
      echohl None
    endif
    return ''
  endif

  if !executable(exe)
    echohl ErrorMsg
    echo '[gofmt.vim] can''t find command:' exe
    echohl None
    return ''
  endif

  if !has_key(s:srcdir_bin, exe)
    let s:srcdir_bin[exe] = system(exe . ' --help') =~# '-srcdir'
  endif

  let args = '-d'

  if get(s:srcdir_bin, 'exe', 0)
    let args .= printf(' -srcdir "%s"', expand('%:p'))
  endif

  return printf('%s %s', exe, args)
endfunction


function! gofmt#apply() abort
  let cmd = s:gofmt_cmd()
  if empty(cmd)
    return
  endif

  let input = getline(1, '$') + ['']
  let diff = split(system(cmd, input), "\n", 1)
  if v:shell_error != 0
    return
  endif

  let fen = &l:foldenable
  setlocal nofoldenable

  normal! ix
  normal! "_x
  undojoin

  let view = winsaveview()
  let cursor_line_len = len(getline(view.lnum))
  let new_cursor_line = view.lnum
  let cur_line = -1

  for line in diff
    let m = matchlist(line, s:hunk_pat)
    if !empty(m)
      let [l1, c1, l2, c2] =  map(m[1:4], 'str2nr(v:val)')
      if view.lnum >= l1
        let new_cursor_line = view.lnum - (c1 - c2) - (l1 - l2)
      endif
      let cur_line = l2
    elseif line =~# '^\%(+++\|---\|diff\)'
      continue
    elseif cur_line != -1
      if line[0] ==# '+'
        call append(cur_line - 1, line[1:])
        let cur_line += 1
      elseif line[0] ==# '-'
        silent execute cur_line 'delete _'
      else
        let cur_line += 1
      endif
    endif
  endfor

  let view.lnum = new_cursor_line
  let view.col += len(getline(new_cursor_line)) - cursor_line_len
  call winrestview(view)
  let &l:foldenable = fen
endfunction
