mrps
=====

An OTP application

Build
-----

    $ rebar3 compile


* Results
One connection:
- 100000 / (2642493 / 1000000.0) = 38kps

100 tcp connections
- (100 * 100000) / (68789777 / 1000000.0) = 145kps
