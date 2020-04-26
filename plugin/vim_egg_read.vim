" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_vim_egg_read')
	finish
endif

if !get(g:, "loaded_zip")
    echoerr "No zip plugin was loaded. vim-egg-read cannot be used."
endif

let g:loaded_vim_egg_read = 1

let s:PATH_EXPRESSIONS = ['\(.*egg\)\(.*\)']


function! s:open(path)
    echo "Found " . a:path
    " call zip#Read("zipfile:/home/selecaoone/temp/test.zip::test.py", "r")
endfunction

autocmd! BufReadCmd *.egg/* call s:open(expand("<amatch>"))
