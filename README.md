# koms-web
Rewriting web proxy that adds contextual menus to recognized entities.
Use case is to perform operations on online documentation, such as
caching it locally and annotating for QnA, fact extraction, process
extraction etc.

# Overview

You can see the system in operation here:
https://frdcsa.org/~andrewdo/projects/rewriting-proxy.webm

The point of this system is to add all kinds of annotations to web
documents providing functions.  Another bug for the program is that
the system which adds links to noun phrases was messing up earlier
annotations and so was temporarily disabled until I can run successive
annotation stages through their own HTML::Parser entity.  But so this
video is misleading because there will be far more textual entities
having links when it is working correctly.

I have not yet thought of all the actions to take based on duck-typed
entities.  This system relates to IAEC and Universal-Parser in that it
may use them in order to do some of the entity typing.

So it will use a lot of entity typing software, but the point is to
not only annotate natural language, but also syntactic features and
other kinds of objects since HTML is often semistructured.

My use case, to give you an idea, is to help me correctly process the
Debian docs that apply to Debian contributors.  I am trying to become
one, except that the amount of deontic/process information I need to
store exceeds my mental abilities.  So I am working to convert this
information into Prolog.  I want to be able to store newer versions of
the same document, and reannotate them.  The idea is that I could
recognize objects and processes in the documentation and add them to
the debian-rulebase system.

It took me 4 days to write this program, longer since I had to figure
out first that HTTPS encryption was preventing HTTP::Proxy from
working, and then to figure out what to do about that.

I am also creating a system called ESP (Expert System for Packacing) -
the successor to Packager - into which I will encode all the process
information for making packages.  That is the final goal with this
proxy.

But the proxy should be more generally useful.  For instance, I will
use it in other situations.  One such situation could be to organize
research in general, or to help me to package software more quickly
that I find on researcher's web pages, etc.

# How to Run (New)

edit the config.sh file for the appropriate dirs and systems

./start-all.sh

./stop-all.sh

# How to Run (Old)

You can see the setup.sh stuff, it's not perfectly accurate.  You need
to first install mitmproxy.  Then you have to run mitmproxy, so that
it generates the certificates.  Then configure your Firefox or Chrome
proxy to use http://$HOSTNAME:8080 as your proxy for both http and
https traffic, then point your browser to mitm.it and accept the cert.
Then stop mitmproxy.  Make sure you have all the Perl dependencies
installed, then start ./komsweb-rpcxml.pl.  Then make sure you have 
all the Python dependencies installed, then run ./run.sh in a
separate term.  Then you should be able to point your browser anywhere
and it should rewrite the traffic.  In order to execute actions, you
need to run the Mojo app, by cd mojo && ./run.sh
