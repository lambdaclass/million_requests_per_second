wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
yes | sudo apt-get update
yes | sudo apt-get install esl-erlang build-essential git gnuplot libtemplate-perl byobu tsung
git clone git@github.com:lambdaclass/million_requests_per_second.git

# https://github.com/processone/tsung/issues/276
ln -s /usr/share /usr/lib/share
ln -s /usr/lib/x86_64-linux-gnu/tsung /usr/lib/tsung
