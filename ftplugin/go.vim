augroup gofmt
  autocmd! BufWritePre <buffer>
        \ if get(g:, 'gofmt_on_save', 1) |
        \   call gofmt#apply() |
        \ endif
augroup END

command! -buffer Gofmt call gofmt#apply()
