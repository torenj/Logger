import os, fnmatch
import re

def collectWords(string):
    symbols = ['{', '}', '(', ')', '[', ']', '"', '*','\t','\r','\n', ':', ','] # single-char keywords
    keywords = ['public', 'class', 'void', 'main', 'String', 'int','mouseDown']
    KEYWORDS = symbols + keywords

    white_space = ' '
    lexeme = ''

    for i,char in enumerate(string):
        if char != white_space:
            lexeme += char # adding a char each time
        if (i+1 < len(string)): # prevents error
            if string[i+1] == white_space or string[i+1] in KEYWORDS or lexeme in KEYWORDS: # if next char == ' '
                if lexeme != '':
                    print(lexeme.replace('\n', '<newline>').replace('\r', '<return>').replace('\t', '<tab>'))
                    lexeme = ''

listOfFiles = sorted(os.listdir('./input'))
pattern = "*.jpg"
characters = []
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        char = ''
        if "mouseDown" in entry:
            char = 'mouseDown'
        else:
            char = re.search('{(.*)}', entry, re.IGNORECASE).group(1)
        print (entry)
        characters.append(char)
collectWords("".join(characters))

