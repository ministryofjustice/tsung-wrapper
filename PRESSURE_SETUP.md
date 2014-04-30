
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

