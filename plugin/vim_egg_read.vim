" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_vim_egg_read')
    finish
endif

let g:loaded_vim_egg_read = 1

let s:PATH_EXPRESSIONS = ['\(.*egg\)\(.*\)']


" Just because a path is "/foo/bar.egg/thing.py" doesn't mean "bar.egg"
" is definitely an egg file. This function double-checks it.
"
function! s:needs_to_be_uncompressed(path)
    let egg_path = substitute(a:path, "\\(.*\\.egg\\).*" , "\\1", "")

    return filereadable(egg_path)
endfunction


function! s:open_egg_path(path)
    let l:parent_directory = getcwd()

    if !s:needs_to_be_uncompressed(a:path)
        " Reference: https://stackoverflow.com/a/57675675
        "
        " Edit the file
        "
        execute "e" a:path

        " Run the remaining autocommands for the file
        execute "doautocmd BufReadPost" a:path

        return
    endif

    for expression in s:PATH_EXPRESSIONS
        let l:names = matchlist(a:path, expression)

        if empty(l:names)
            continue
        endif

        let l:zip_file_name = l:names[1]
        let l:inner_path = l:names[2]

        if l:zip_file_name !~ "^" . l:parent_directory
            let l:zip_file_name = l:parent_directory . "/" . l:zip_file_name
        endif

        " Before: call zip#Read("/home/username/foo.egg/test.py", "r")
        " After: call zip#Read("zipfile:/home/username/foo.egg::test.py", "r")
        "
        let stripped_inner_path = substitute(l:inner_path, "^/*", "", "")
        " echoerr 'Opening using call zip#Read("zipfile:' . l:zip_file_name . "::" . stripped_inner_path. '", "r")'
        let full_path = "zipfile:" . l:zip_file_name . "::" . stripped_inner_path

        " Rename the current buffer to something that Vim's zip plugin can understand
        execute ":file " . full_path

        " Add the current file's contents into the current buffer
        call zip#Read(full_path, "r")
    endfor
endfunction


function! s:write_egg_path(path)
    if !s:needs_to_be_uncompressed(a:path)
        " Reference: https://stackoverflow.com/a/57675675
        "
        " Edit the file
        "
        execute "w" a:path

        " Run the remaining autocommands for the file
        execute "doautocmd BufWritePost" a:path

        return
    endif

    call zip#Write(a:path)
endfunction


function! s:set_pre(path)
    if s:needs_to_be_uncompressed(a:path)
        set bin
    endif
endfunction


function! s:set_post(path)
    if s:needs_to_be_uncompressed(a:path)
        set nobin
    endif
endfunction


autocmd! BufReadCmd *.egg/* call s:open_egg_path(expand("<amatch>"))
autocmd! BufReadPost,FileReadPost *.egg/* call s:set_post(expand("<amatch>"))
autocmd! BufReadPre,FileReadPre *.egg/* call s:set_pre(expand("<amatch>"))
autocmd! BufWriteCmd *.egg/* call s:write_egg_path(expand("<amatch>"))
