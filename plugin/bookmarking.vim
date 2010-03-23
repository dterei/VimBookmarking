" ==============================================================================
"        File: bookmarking.vim
"      Author: David Terei <davidterei@gmail.com>
"		    URL: 
" Last Change: Fri Mar 19 12:36:14 EST 2010
"     Version: 1.0
"     License: Distributed under the Vim charityware license.
"     Summary: A bookmaking facility to Vim for marking points of interest.
"
" GetLatestVimScripts: 3022 1 :AutoInstall: bookmarking.vim
"
" Description:
" Add a book marking feature to Vim that allows lines of interest to be marked.
" While similar to marks, you don't need to assign a bookmark to a mark key,
" instead an infinite number of bookmarks can be created and then jumped
" through in sequential order (by line number) with no strain on your memory.
" This is great to use when you are browsing through some source code for the
" first time and need to mark out places of interest to learn how it works.
"
" Installation:
" Normally, this file will reside in your plugins directory and be
" automatically sourced. No changes to your .vimrc are needed unless you want
" to change some default settings.
"
" Uses:
" The bookmark facility provides a number of new commands as well as a default
" mapping of these commands to keys. This mapping can be customised as can the
" bookmarks appearance.
"
" Commands available (with keyboard shortcuts in brackets):
"  * Use the command 'ToggleBookmark' to set or remove a bookmark. (<F3>)
"  * Use the command 'NextBookmark' to jump to the next bookmark. (<F4>)
"  * Use the command 'PreviousBookmark' to jump to the previous bookmark. (<F5>)
"
" Settings:
" The keyboard mapping of the commands can be easily changed by adding new
" mappings to them in your .vimrc. If a mapping is defined in your .vimrc
" then the default mappings won't be added.
"
" You can also alter the appearance of the bookmark itself. The bookmark is
" shown on the screen using Vim's sign feature. To define the sign used for a
" bookmark yourself, include a sign definition in your .vimrc for a sign
" called 'bookmark'.
"
" Examples:
" In your .vimrc:
"
"     map <silent> bb :ToggleBookmark<CR>
"     map <silent> bn :NextBookmark<CR>
"     map <silent> bp :PreviousBookmark<CR>
"
"     define bookmark text=>>
"
" History:
"   Fri Mar 19, 2010 - 0.1:
"     * Initial release.
"

" XXX: An issue with the current design is that the bookmarks cause conflicts if
" used on lines that have Vim signs on them.
" XXX: Also could use a 'ClearBookmarks' command but the current design only
" allows for this to be implemented in a way that would remove all signs from
" the current file.
" TODO: Should convert bookmark from a list of numbers to a list of tuples
" where each tuple contains the sign line number and the sign id. At moment
" we just store sign line number.
"

" Allow disabling and stop reloading
if exists("loaded_bookmarks")
  finish
endif
let loaded_bookmarks = 1

" save and change cpoptions
let s:save_cpo = &cpo
set cpo&vim

" The sign to use for the bookmark
try
	" Don't define if already defined by user
	sign list bookmark
catch
	" default sign
	sign define bookmark text=>>
endtry

" Key Mappings
if !hasmapto(':ToggleBookmark')
	map <silent> <F3> :ToggleBookmark<CR>
endif

if !hasmapto(':NextBookmark')
	map <silent> <F5> :NextBookmark<CR>
endif

if !hasmapto(':PreviousBookmark')
	map <silent> <F4> :PreviousBookmark<CR>
endif

" Menu mapping
noremenu <script> Plugin.Bookmark\ Toggle   s:toggleBookmark
noremenu <script> Plugin.Bookmark\ Next     s:nextBookmark
noremenu <script> Plugin.Bookmark\ Previous s:previousBookmark

" Numeric sort comparator
function s:numericalCompare(i1, i2)
	return a:i1 == a:i2 ? 0 : a:i1 > a:i2 ? 1 : -1
endfunc

" This function creates or destroys a bookmark
function s:toggleBookmark()
	let cpos = line(".")
	if (!exists("b:bookmarks"))
		let b:bookmarks = []
	endif

	let remove = 0
	let newbookmarks = []
	for bpos in b:bookmarks
		if (cpos == bpos)
			let remove = 1
		else
			let newbookmarks = add(newbookmarks, bpos)
		endif
	endfor

	if (!remove)
		let b:bookmarks = sort(add(b:bookmarks, cpos), "s:numericalCompare")
		exe "sign place ".cpos." line=".cpos." name=bookmark file=".expand("%:p")
	else
		let b:bookmarks = newbookmarks
		sign unplace
	endif
endfunction

command ToggleBookmark :call <SID>toggleBookmark()

" This function keeps the bookmarks in sync with changes to the file
function s:keepUpdateBooks()
	if (!exists("b:bookmarks") || empty(b:bookmarks))
		return
	endif

	let epos = line("$")
	let cpos = line("'.")

	if (!exists("b:endoffile"))
		let b:endoffile = epos
	else
		let dif = epos - b:endoffile
		if (dif != 0)
			let newbookmarks = []
			for bpos in b:bookmarks
				if (bpos == cpos && dif == -1)
					exe "sign unplace ".cpos." file=".expand("%:p")
				elseif (bpos >= cpos)
					let newbookmarks = add(newbookmarks, bpos + dif)
				else
					let newbookmarks = add(newbookmarks, bpos)
				endif
			endfor
			let b:bookmarks = newbookmarks
			let b:endoffile = epos
		endif
	endif
endfunction

" Need to bind the update function to the changes autocommand
autocmd! CursorMoved,CursorMovedI *.* :call <SID>keepUpdateBooks()

function s:nextBookmark()
	if (!exists("b:bookmarks") || empty(b:bookmarks))
		return
	endif

	let cpos = line(".")
	for bpos in b:bookmarks
		if (cpos < bpos)
			exe "normal! ".bpos."G"
			echo
			return
		endif
	endfor

	" none found so wrap
	if (len(b:bookmarks) >= 1)
		exe "normal! ".b:bookmarks[0]."G"
		echoh WarningMsg | echom "bookmarking hit BOTTOM, continuing at TOP"
			\| echoh None
	endif
endfunction

command NextBookmark :call <SID>nextBookmark()

function s:previousBookmark()
	if (!exists("b:bookmarks") || empty(b:bookmarks))
		return
	endif

	let cpos = line(".")
	let index = len(b:bookmarks) - 1
	while index >= 0
		let bpos = b:bookmarks[index]
		if (bpos < cpos)
			exe "normal! ".bpos."G"
			echo
			return
		endif
		let index = index - 1
	endwhile

	" none found so wrap
	if (len(b:bookmarks) >= 1)
		exe "normal! ".b:bookmarks[len(b:bookmarks) - 1]."G"
		echoh WarningMsg | echom "bookmarking hit TOP, continuing at BOTTOM"
			\| echoh None
	endif
endfunction

command PreviousBookmark :call <SID>previousBookmark()

" restore cpoptions to original
let &cpo = s:save_cpo

