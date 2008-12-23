#!/bin/sh

export RUBYLIB="../lib:./lib"

export PATH="../bin:./bin:$PATH"

#export LOCKFILE_DEBUG=1

(r=`ruby -e 'p(rand(2))'`; sleep $r; rlock ./lockfile 'sleep 1; printf "\n$$ aquired lock @ `date`\n\n"') &
(r=`ruby -e 'p(rand(2))'`; sleep $r; rlock ./lockfile 'sleep 1; printf "\n$$ aquired lock @ `date`\n\n"') &
(r=`ruby -e 'p(rand(2))'`; sleep $r; rlock ./lockfile 'sleep 1; printf "\n$$ aquired lock @ `date`\n\n"') &

wait
