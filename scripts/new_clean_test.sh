srcdir=~/src
testdir=hwt
git_archive=hitchwiki-ansible.tar.xz
set -ev
[ -d $srcdir ] || mkdir $srcdir
cd $srcdir
if [ -d $testdir ]
then
  cd $testdir
  ./scripts/vagrant/clean.sh
  cd ..
  rm -rf $testdir
fi
if [ -f $git_archive ]
then mkdir $testdir; cd $testdir; tar xf ../$git_archive
else git clone git@github.com:traumschule/hitchwiki.git -b ansible $testdir
  cd $testdir
  tar cJf ../$git_archive .
fi
git checkout ansible
git pull
[ -d host_vars ] || mkdir host_vars
[ -f ../hitchwiki/host_vars/vagrant ] && cp ../hitchwiki/host_vars/vagrant host_vars
./scripts/vagrant/install.sh
echo "All done. Vagrant test succeeded.
