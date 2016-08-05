#lang racket

;(provide (rename-out [main-lexer lexer]))
(provide (all-defined-out))

(require parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

; Lexer for line comments
(define comment-lexer
  (lexer
    [(:or #\newline) ; or EOF?
     (cons `(COMMENT) (main-lexer input-port))]

    [any-char
     (comment-lexer input-port)]))

; Main lexer
(define main-lexer
  (lexer
    [#\#
     (comment-lexer input-port)]

    ; String literals
    ; TODO Remove surrounding quotes
    [(concatenation #\" (:* (char-complement #\")) #\")
     (cons `(STRING ,lexeme) (main-lexer input-port))]

    ; Regex literals
    ; TODO Remove surrounding slashes
    [(concatenation #\/ (:* (char-complement #\/)) #\/)
     (cons `(REGEX ,lexeme) (main-lexer input-port))]

    ; Datetime literals
    ; TODO Remove @-sigil
    [(concatenation #\@ (:+ (char-complement #\space)))
     (cons `(DATETIME ,lexeme) (main-lexer input-port))]

    ; Numeric literals
    ; TODO Make this match our pattern for numeric literals
    [(concatenation (:? #\-) numeric)
     (cons `(NUMERIC ,lexeme) (main-lexer input-port))]

    ; TODO: Plenty of stuff!...

    [any-char
     (cons `(FOO ,(string->symbol lexeme)) (main-lexer input-port))]))
