#!/usr/bin/env bash

__powerline() {
    # Colorscheme
    RESET='\[$(tput sgr0)\]'
    COLOR_CWD='\[$(tput setaf 7)\]' # white
    COLOR_GIT='\[$(tput setaf 6)\]' # cyan
    COLOR_VIRTUAL_ENV='\[$(tput setaf 5)\]' # magenta
    COLOR_SUCCESS='\[$(tput setaf 2)\]' # green
    COLOR_FAILURE='\[$(tput setaf 1)\]' # red

    SYMBOL_GIT_MODIFIED='*'
    # unicode symbols are comprised of 3 octal code points
    # we escape all but the first code point using \[ and \]
    # to avoid errors when typing long lines in bash
    SYMBOL_GIT_BRANCH='¥' # symbol: ¥
    SYMBOL_GIT_PUSH='!' # symbol: !
    SYMBOL_GIT_PULL='¡' # symbol: ¡
    SYMBOL_VIRTUAL_ENV='@' # symbol: @
    SYMBOL_APPLE='»' # symbol: »

    ps1() {
        # Check the exit code of the previous command and display different
        # colors in the prompt accordingly.
        if [ $? -eq 0 ]; then
            local symbol="$COLOR_SUCCESS $SYMBOL_APPLE $RESET"
        else
            local symbol="$COLOR_FAILURE $SYMBOL_APPLE $RESET"
        fi

        local cwd="$COLOR_CWD\W$RESET"

        if [ -z $VIRTUAL_ENV ]; then
            local virtualenv=""
        else
            local virtualenv=" $COLOR_VIRTUAL_ENV$SYMBOL_VIRTUAL_ENV$(basename $VIRTUAL_ENV)$RESET"
        fi

        # Fetch the git info
        local git_eng="env LANG=C git"   # force git output in English to make our work easier

        # get current branch name
        local ref=$($git_eng symbolic-ref --short HEAD 2>/dev/null)

        if [[ -n "$ref" ]]; then
            # prepend branch symbol
            ref="$SYMBOL_GIT_BRANCH$ref"
        else
            # get tag name or short unique hash
            ref="$($git_eng describe --tags --always 2>/dev/null)"
        fi

        local git=""

        if [[ -n "$ref" ]]; then

            local marks

            # scan first two lines of output from `git status`
            while IFS= read -r line; do
                if [[ $line =~ ^## ]]; then # header line
                    [[ $line =~ ahead\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PUSH${BASH_REMATCH[1]}"
                    [[ $line =~ behind\ ([0-9]+) ]] && marks+=" $SYMBOL_GIT_PULL${BASH_REMATCH[1]}"
                else # branch is modified if output contains more lines after the header line
                    marks="$SYMBOL_GIT_MODIFIED$marks"
                    break
                fi
            done < <($git_eng status --porcelain --branch 2>/dev/null)  # note the space between the two <

            # print the git branch segment without a trailing newline
            local git=" $COLOR_GIT$ref$marks$RESET"
        fi

        PS1="$cwd$virtualenv$git$symbol"
    }

    PROMPT_COMMAND="ps1${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
}

__powerline
unset __powerline
