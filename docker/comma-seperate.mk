space :=
space += # $space is a space
comma := ,
comma-separate = $(subst ${space},${comma},$(strip $1))
