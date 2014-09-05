#!/usr/bin/env bash
#
# Cloning CTreffOS Github repository and upload via ftp to CTreffOS website.
#

version="Dr. Peter Voigt - v1.1.0 / 2014-09-05"
ctreffosGithubRepo="https://github.com/CTreffOS/ctreffos-webseite.git"
# Adapt the following variables to your need.
ftpHost=spock.drpetervoigt.private
ftpPort=50100
ftpTargetDir=pub/upload/test
ftpUser=tester
# Insert ftpPasswd into the following file:
ftpPasswdFile=/home/pvoigt/.ctreffos-webseite.passwd
tmpDir=/tmp
githubTmpDir=$tmpDir/ctreffos-webseite
# Next line is optional, if you need SSL.
useSSL=false
# Next line is needed only, if above line is useSSL=true. Otherwise it
# is ignored.
caCertBundle=/usr/local/etc/certs/pvoigt-ca-bundle.crt

function printVersion
{
  echo "`basename $0` - $version"
  echo "INFO: Cloning CTreffOS Github repository and upload via ftp to ctreffos website."
}

function getFtpPasswd
{
  if [ -f $ftpPasswdFile ] ; then
    echo "INFO: Reading ftp password from file $ftpPasswdFile."
    read ftpPasswd < $ftpPasswdFile
  else
    echo "ERROR: Password file $ftpPasswdFile not found."
    echo "ERROR: Program aborted."
    exit 1
  fi
}

function getSslParams
{
  if [ $useSSL ] ; then
    echo "INFO: Using SSL secured FTP connection."
    echo "INFO: Verifying FTP server certificate against $caCertBundle."
  else
    echo "INFO: Using non-SSL secured FTP connection."
    caCertBundle=
  fi
}

function cloneCtreffosGithubrepo
{
  echo "INFO: Cloning CTreffOS Github repository $ctreffosGithubRepo."
  cd $tmpDir
  git clone $ctreffosGithubRepo
}

function uploadToCtreffosWebsite
{  
  echo "INFO: Uploading to CTreffOS website using FTP."
  lftp -d <<END_OF_SESSION
  set ftp:ssl-allow $useSSL
  set ssl:verify-certificate true
  set ftp:ssl-protect-data true
  set ftp:ssl-protect-list true
  set ssl:ca-file $caCertBundle
  set ftp:passive-mode on
  set ftp:fix-pasv-address true
  open -p $ftpPort -u $ftpUser,$ftpPasswd $ftpHost
  pwd
  cd $ftpTargetDir
  lcd $githubTmpDir
  mrm *
  mput *
  close
  quit
END_OF_SESSION
}

function removeTmpDir
{
  if [ -d $githubTmpDir ] ; then
    echo "INFO: Removing $githubTmpDir."
    rm -rf $githubTmpDir
  fi
}

printVersion
getFtpPasswd
getSslParams
cloneCtreffosGithubrepo
uploadToCtreffosWebsite
removeTmpDir

