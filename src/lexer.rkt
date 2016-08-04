#lang racket

(provide (rename-out [main-lexer lexer]))

(require parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

; Lexer for line comments
(define comment-lexer
  (lexer
    [#\n  ; or EOF?
     (main-lexer input-port)]

    [any-char
     (comment-lexer input-port)]))

; Lexer for strings literals
(define string-lexer
  (lexer
    ; TODO
    ))

; Lexer for regular expression literals
(define regex-lexer
  (lexer
    ; TODO
    ))

; Lexer for numeric literals
(define numeric-lexer
  (lexer
    ; TODO
    ))

; Lexer for datetime literals
(define datetime-lexer
  (lexer
    ; TODO
    ))

; Lexer for symbols
(define symbol-lexer
  (lexer
    ; TODO
    ))

; Main lexer
(define main-lexer
  (lexer
    ; TODO
    ))
