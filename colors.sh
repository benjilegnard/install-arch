# colors

BLACK=$(tput setaf 0)
export BLACK

RED=$(tput setaf 1)
export RED

GREEN=$(tput setaf 2)
export GREEN

YELLOW=$(tput setaf 3)
export YELLOW

BLUE=$(tput setaf 4)
export BLUE

PURPLE=$(tput setaf 5)
export PURPLE

CYAN=$(tput setaf 6)
export CYAN

WHITE=$(tput setaf 7)
export WHITE

# bold
B=$(tput bold)
export B

# underline
U=$(tput smul)
export U

# NoColor / reset
NC=$(tput sgr0)
export NC

STANDOUT=$(tput smso)
export STANDOUT

# backgrounds
RED_BG=$(tput setab 1)
export RED_BG

GREEN_BG=$(tput setab 2)
export GREEN_BG

YELLOW_BG=$(tput setab 3)
export YELLOW_BG

BLUE_BG=$(tput setab 4)
export BLUE_BG

# messages symbols
export INFO_SYMBOL="${NC}${B}${BLUE}ℹ${NC}"
export WARN_SYMBOL="${NC}${B}${YELLOW}⚠${NC}"
export CHECK_SYMBOL="${NC}${GREEN}✔${NC}"
export ERROR_SYMBOL="${NC}${RED}✖${NC}"

# message blocks with reversed backgrounds:
export FAIL="${STANDOUT}${RED}${B} FAIL ${NC}"
export DONE="${STANDOUT}${GREEN}${B} DONE ${NC}"
export WARN="${STANDOUT}${YELLOW}${B} WARN ${NC}"
export INFO="${STANDOUT}${BLUE}${B} INFO ${NC}"

printFailure () {
    echo "${FAIL} $*"
}

printInfo () {
    echo "${INFO} $*"
}

printWarning () {
    echo "${WARN} $*"
}

printSuccess () { 
    echo "${DONE} $*"
}


logFailure () {
    echo "${ERROR_SYMBOL} $*"
}

logInfo () {
    echo "${INFO_SYMBOL} $*"
}

logWarning () {
    echo "${WARN_SYMBOL} $*"
}

logSuccess () { 
    echo "${CHECK_SYMBOL} $*"
}
