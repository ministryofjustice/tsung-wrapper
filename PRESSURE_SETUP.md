
# Setup of load testing machine 'pressure'

## Update apt

    sudo apt-get update

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

## Install Gnuplot

    sudo apt-get install gnuplot

## Install perl TemplateTookkit

    sudo cpan Template






## Install Evironment to run tsung-wrapper


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



### matplotlib

    sudo apt-get install python-matplotlib


Check that it has been installed OK:

    stephen@ip-172-31-18-183:~$ python
    Python 2.7.3 (default, Feb 27 2014, 19:58:35) 
    [GCC 4.6.3] on linux2
    Type "help", "copyright", "credits" or "license" for more information.
    >>> 
    >>> import matplotlib
    >>> print matplotlib.__version__
    1.1.1rc
    >>> 
    >>> import numpy
    >>> print numpy.__version__
    1.6.1
    >>> 


