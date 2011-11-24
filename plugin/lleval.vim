command! -nargs=? -range=% LLEval :call lleval#Post(<line1>, <line2>)
command! -nargs=? -range=% LLEvalWithLink :call lleval#PostWithLink(<line1>, <line2>)
