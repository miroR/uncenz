
Copyright 2015, Miroslav Rovis, http://www.CroatiaFidelis.hr

Released under BSD license, pls. see LICENSE

Before I explain this method let me emphasize that I am not an expert and I am
aware that a few things from my scripts definitely need to be done, and are
usually done in programs, differently, but I currently simply don't know nor
have time to learn to do better.

Lest I forgot: while this can surely be rewritten completely and employed under
M$ Windoze (nota bene: similar considerations apply to Schmapple Mac,
the-other-rich-man-who-has-no-more-riches-any-longer OS), I
haven't yet even considered finding (the ample) time to even consider it. But
anybody is welcome to do it, just pls. be aware of the license, and keep to the
free conditions, and mark whence your derivative originates from. Or is it just
a few modifications, and uncenz could be used in M$ Windoze with Cygwin maybe?

For various Unix flavors' users: I can't wait to study Bash and the related
Posix standards, but haven't found that (ample) time either. So if you find I
use bashisms that don't work in your Unix flavor, and are able to modify the
scripts so they work on your \*unix, pls. send me the patches, but be patient for
me to apply them (again: I'm not really a programmer, I take time to do
things...)

Requirements to use uncenz (the scripts themselves you can just unpack into
your /usr/local/bin ) are: FFmpeg, Tcpdump (or Dumpcap which comes with
Wireshark). But for full use of these sets of scripts, you need to modify them
for your own machine.

Uncenz can as be useful in various sorts of network problems analysis
completely unrelated to censorship, but my primary motivation to write it was
uncovering censorship related network problems ;-) .

So Uncenz is a set scripts for, among other uses, my method of engaging
against censorship by documenting it to be able to call public or
institutional attention, as well as discovering and documenting
intrusion/other attacks to be able to seek help.

The latter is often (not always, can have completely different motives, e.g.
theft, behind it, documenting of which being equally or, some would say, more
useful!) [often] related to the censorship issue since regimatic censorship is
often accompanied with an array of possible attacks deliberate by same or
related parties or purposefully allowed to non-related parties via sly means.
Often those attacks are intentional or allowed by the powerful subjects on the
poor user, such as his/her own provider or possibly beyond.

See topic:
"Postfix smtp/TLS, Backup/Cloning Method, and Documenting Censorship/Intrusion"
http://forums.gentoo.org/viewtopic-t-999436.html

on Gentoo Forums.

Or try and study my collection of (not all censorship related, esp. not the
later entries, but some were) screencasts and traces at:
https://www.CroatiaFidelis.hr/foss/cap/

For SSL capturing see:
https://wiki.wireshark.org/SSL

You certainly need to understand and modify a few things if, say, your display
is not 1366x768 (but find more in the uncenz-1st script), and probably other
things.

Currently the only way to set up some of the functionality in uncenz for your
environment is: uncommenting and modifying the scripts :-) .

E.g., if you don't use grsecurity hardened kernel, you need to do some
uncommenting. I'll make it an include, some day. (Not in a hurry.)

And, for complete use, $SSLKEYLOGFILE on Wireshark's Wiki above needs to be
understood and applied. It makes little sense to record the network, without
logging the SSL-keys, so if you can't set your SSL-keys to be logged, there's
little use of uncenz for you either. Set off on the steep learning curve,
Tuxian!

No attempt is made to explain the SSL capturing in this set of scripts, but the
last line from wherever you store your effemeral keys is taken out in all the
scripts that start dumpcamp'ing and is stored, so that later the new keys of
the session can be found more easily and extracted, if presentation of the
session where censorship happened is needed, when the effemeral keys need to be
published.

Pls. also note that with this presentation of this program-that-should-become,
you probably will not get any meaningful results if you try and run concurrent
sessions (of uncenz-1st). Limiting it to one session allowed per minute is
confortable for me.  Else, delete what uncenz-ts wrote, and start sooner.

My method (tested only on typical wired connection) cosists of two phases:

phase first)

zero ground) we start from no-connection, the usual should-be state of
for-online computers of the surveillance/other-intrusions-aware poor users,
non-experts, before any prolonged online absolutely not under their complete
control (complete control of own machines is the goal)

first) starting the first phase of uncenz by running the script uncenz-1st
(optionally with the first argument being an include filter-script) which starts
network packet capturing and ffmpeg screencast capturing, or empty, and a
second arg for additional second-type include (likely another log-extraction
include, but could be other), see the uncenz-1st and uncez-kill for those args.

second) physically connecting to the internet via the provider's router (the
packet capturing being on, and the screencasting being on) by connecting the
socket (get/make a very short extension cable, don't expose the router's socket
to wearing)

third) doing whatever task/visit/other is needed/wished to do online

fourth) physically disconnecting from the internet by unplugging from the
socket

fifth) killing the still running uncenz-1st started processes (never kill it
before first disconnecting physically) by issuing uncenz-kill

phase second)

All these documenting files usually (although it may not be essential to do so)
need to be transferred in some secure air-gapped way off the online system.
They all need to be put in the same empty directory, where then they can be
worked with,

first) the scripts from the workPCAPs (to be able to run on its results the
uncenz-2nd the real second phase of uncenz set of scripts).

For work PCAPs see https://github.com/miroR/workPCAPs . It will make use of
scripts from:
https://github.com/miroR/tshark-streams and
https://github.com/miroR/tshark-hosts-conv 
to do (the tshark-streams) extracting of the streams on your captured trace,
and (the tshark-hosts-conv) a good listing of hosts and conversations as well
as extracting of each conversation to a separate PCAP.

second) the uncenz-2nd. It can, from v0.40, open all documents of the event:
mplayer <the-screencast> in background, open all the PCAPs (just mentioned
above) and view in Vim all the text files that tshark-hosts-conv took, along
with the excerpt of the log file that got written with your logger (rsyslog in
Devuan/Debian) during the event.

There are also other includes/snippets of code that can be uncommented to get
more functionalities to work. Peruse the scripts to get familiar with all that
is offered.

Again, this works on my machines, with programs installed in my machines, such
as extracting from /var/log/kern.log that rsyslog logs into, with my choice of
editor (Vim) and other programs. And in this phase of the project, all those
are hardwired. And almost all of them can be made into variables, which would
then make for a real program, as it could then work with programs of your
choice on your system. But I'd first need to get results of how it was applied
on other systems, and what modifications needed to be made for these set of
scripts to to work on other systems. No planning of doing that myself, at this
time.

That is what this set of scripts currently does/can do. The aim is, however, to
get it to do so more, yet, such as, exampli gratia, list the exact connections
made during a particular session from /var/log/conntrackd-stats.log (for which
conntrack-tools need to be installed and conntrackd run as daemon). And some
other parameters and whatever else might be necessary to make censorship
irrefutably undeniable and intrusions identified and undeniable with as little
effort as possible, and all that workable for non-expert users.

If I make it (which can not happen soon, I'm not so talented). And if others
do, thanks for using my idea (but see paragraph below).

During all the time that I have been slowly progressing toward this point in
time when the idea has been sufficiently shaped to propose it here, I have not
been aware of any similar ideas. But (if you read the topic linked above in
Gentoo Forums) I'm not Schmoog the Surveillance Engine to know it all. Do let
me know if there exists something similar to my idea. Not a good thing
inventing hot water. (And while you're possibly trying to contact me, be aware
of the censorship and related attacks. Use, if you can, the uncenz to document
that you tried to contact me!)
