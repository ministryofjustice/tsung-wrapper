
# Setup of load testing machine 'pressure'



## Install Erlang

Erlang already installed - nothing to do.


## Install tsung

Download source and compile

    cd /tmp
    wget http://tsung.erlang-projects.org/dist/tsung-1.5.1.tar.gz
    tar zxvf tsung-1.5.1.tar.gz
    cd tsung-1.5.1/
    ./configure
    make 
    sudo make install

##


## Install Evironment to run tsung-wrapper

### Update apt

    sudo apt-get update


### RVM

run the following commands (see https://rvm.io/ for details):

  \curl -sSL https://get.rvm.io | bash -s stable
  source ~/.rvm/scripts/rvm
  rvm requirements




### Install Ruby & rubygems

  rvm install ruby-2.1.0   # this is the version that is specified in tsung-wrapper's Gemfile
  rvm rubygems current     # should already be installed by the preceeding command


### clone tsung-wrapper from git & generate gemset

  git clone git@github.com:ministryofjustice/tsung-wrapper.git
  cd tsung-wrapper
  bundle
