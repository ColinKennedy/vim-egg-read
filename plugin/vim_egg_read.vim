" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_vim_egg_read')
	finish
endif

let g:loaded_vim_egg_read = 1

let s:PATH_EXPRESSIONS = ['\(.*egg\)\(.*\)']


function! OpenEggPath(path)
    let l:parent_directory = getcwd()

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


autocmd! BufReadPre,FileReadPre	*.egg/* set bin
autocmd! BufReadPost,FileReadPost	*.egg/* set nobin
autocmd! BufReadCmd *.egg/* call OpenEggPath(expand("<amatch>"))
autocmd! BufWriteCmd *.egg/* call zip#Write(expand("<amatch>"))
