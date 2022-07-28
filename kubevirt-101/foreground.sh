export PS1="\[\e[1;33m\]\h $ \[\e[1;36m\]"
trap 'echo -ne "\e[0m"' DEBUG
echo