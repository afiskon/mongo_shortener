#!/bin/sh

if [ `id -u` != 0 ]; then 
  echo 'This script should be run by root user';
  exit;
fi

export CPANM_INSTALLDEPS_IS_RUNNING=1
cpan App::cpanminus && cpanm --installdeps .
rm MYMETA.json
rm MYMETA.yml
rm Makefile
