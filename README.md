
Copyright 2015, Miroslav Rovis, http://www.CroatiaFidelis.hr

Released under BSD license, pls. see LICENSE

Before I explain this method let me emphasize that I am not an expert and I am
aware that a few things from my scripts definitely need to be done, and are
usually done in programs, differently, but I currently simply don't know nor
have time to learn to do better.

These first few lines concern the very latest updates.

The scripts are here which I haven't thought out completely about how to use
some of them:

hhmmss2sec

dump_perl_repl.sh

uncenz-ipt_conf_states.sh

dump_dLo.sh

The purpose of each of them is explained inside their own text.

And there is the include functionality, pls. read in the example script:

uncenz-include-vimeo

Now generally about uncenz and how to use it.

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
scripts so thay work on your unix, pls. send me the patches, but be patient for
me to apply them (again: I'm not really a programmer, I take time to do
things...)

Requirements to use uncenz (the scripts themselves you can just unpack into
your /usr/local/bin ) are: FFmpeg, Dumpcap (comes with Wireshark). Surely
Tcpdump could be used instead of the latter, and maybe simply by replacing the
string dumpcap with tcpdump. But I'm in no hurry yet to try and accomodate for
Tcpdump, as Dumpcap is faily good too.

Uncenz is a set of scripts for my method of engaging against censorship by
documenting it to be able to call public or institutional attention, as well as
discovering and documenting intrusion/other attacks to be able to seek help.

The latter is often (not always, can have completely different motives, e.g.
theft, behind it, documenting of which being equally or, some would say, more
useful!) [often] related to the censorship issue since regimatic censorship is
often accompanied with an array of possible attacks deliberate by same or
related parties or purposefully allowed from non-related parties via sly means.
Often those attacks are intentional or allowed by the powerful subjects on the
poor user, such as his/her own provider or possibly beyond.

See topic:
"Postfix smtp/TLS, Backup/Cloning Method, and Documenting Censorship/Intrusion"
http://forums.gentoo.org/viewtopic-t-999436.html

on Gentoo Forums.

Or try and study my collection of (not all censorship related, but most)
screencasts and traces at:
http://www.CroatiaFidelis.hr/foss/cap/

For SSL capturing see:
https://wiki.wireshark.org/SSL

You certainly need to understand and modify a few things if,
say, your display is not 1024x768 or 800x600 (which are offered in the script by
mere uncommenting some lines and commenting out other lines), and probably other
things.

Currently the only way to set up some of the functionality in uncenz for your
environment is: uncommenting and modifying the scripts :-) .

E.g., if you don't use grsecurity hardened kernel, you need to do some
uncommenting. I'll make it an include, some day. (Not in a hurry.)

However, the dumpcap line can now be dealt with via a completely new include of
your own.

And, for complete use, $SSLKEYLOGFILE on Wireshark's Wiki above needs to be
understood and applied. It makes little sense to record the network, without
logging the SSL-keys, so if you can't set your SSL-keys to be logged, there's
little use of uncenz for your either. Set off on the steep learning curve,
Tuxian!

No attempt is made to explain the SSL capturing in this set of scripts, but the
last line from wherever you store your effemeral keys is taken out in all the
scripts that start dumpcamp'ing and is stored, so that later the new keys of
the session can be found more easily and extracted, if presentation of the
session where censorship happened is needed, when the effemeral keys need to be
published.

Pls. also note that with this initial presentation of this program-to-be, or
this idea for a program to develop, you probably will not get any meaningful
results if you try and run concurrent sessions. Limiting it to one session
allowed per minute is confortable for me. Else, delete what uncenz-ts wrote,
and start sooner.

My method (tested only on typical wired connection) cosists of two phases:

phase first)

zero ground) we start from no-connection, the usual should-be state of
for-online computers of the surveillance/other-intrusions-aware poor users,
non-experts, before any prolonged online absolutely not under their complete
control (complete control of own machines is the goal)

first) starting the first phase of uncenz by running the script uncenz-1st
(optionally with the first argument being an include script) which starts
network packet capturing and ffmpeg screencast capturing

second) physically connecting to the internet via the provider's router (the
packet capturing being on, and the screencasting being on) by connecting the
socket (get/make a very short extension cable, don't expose the router's socket
to wearing)

third) doing whatever task/visit/other is needed/wished to do online

fourth) physically disconnecting from the internet by unplugging from the
socket

fifth) killing the still running uncenz-1st started processes (never kill it
before first disconnecting physically) by issuing uncenz-kill

Now comes the part that is unfinished and/or broken. Just skip to BROKEN-END
(else try to figure out my idea btwn BROKEN-START and BROKEN-END. Should be
realized some day...)

BROKEN-START
( Pls also note that the script in the repo:
hhmmss2sec
is a recent try in this direction)

This first phase gets you files such as Screen_150131_0232_XXX.mkv and
dump_150131_0232_XXX.pcap if uncenz naming is used (where XXX is the first
three letters of your hostname).

This uncenz-2nd script, for now, only does one thing and not too well.

It takes two arguments or assumes their defaults.

$1 is usually previously archived system log --the file that during the time of
screencasting/packet capturing from the first phase was logged into in the
online computer under name of /var/log/messages or other name. If it is not
named "messages" (the default), you need to provide $1

$2 is a list of (timestamp-named) files (given as arg 2, else uncenz-2nd
construes the list if files follow the naming in my method, which they do if
they were produced with uncenz-1st). Haven't yet tested providing arg 2. This
script lists fine the uncenz-1st made files as explained next.

All these documenting files usually need to be transferred in some secure
air-gapped way off the online system. They all need to be put in the same empty
directory, where then they can be worked with this uncenz-2nd, the second phase
of uncenz set of scripts.

So we're not anymore in the online system for the uncenz-2nd, but, say in our
air-gapped system safe off the internet.

uncenz-2nd runs a for loop on the system log (default "messages", the archived
messages from the online system logged into when all the uncenz-1st sessions
were taken) for each of the items in the list of timestamps (the timestamps are
the same as the timestamps made with the uncenz-1st. uncenz-2nd recovers those.

uncenz-2nd first greps for 'ffmpeg -f x11grab' lines containing the timestamp
for each item of the list, and takes, for each item of the list separately (in
the for loop), a number of --after-context lines from there.

uncenz-2nd then, on that portion of the system log stowed temporarily in
$syslog_${i}_leg_tmp.log grep's for only the first occurence of 'carrier lost',
and taking the --before-context, it stows all that was logged in $syslog during
that particular run of uncenz-1st in the final file for each iteration which
it names $syslog_${i}_leg.log
BROKEN-END

That is what this script currently does. The aim is, however, to get it to do
so much more, such as, exampli gratia, list the exact connections made during a
particular session from /var/log/conntrackd-stats.log (for which
conntrack-tools need to be installed and conntrackd run as daemon). And some
other parameters and whatever else might be necessary to make censorship
irrefutably undeniable and intrusions identified and undeniable with as little
effort as possible, and all that workable for non-expert users.

If I make it (which can not happen soon, I'm too busy elsewhere). And if others
do, thanks for using my idea (but see paragraph below).

During all the time that I have been slowly progressing toward this point in
time when the idea has been sufficiently shaped to propose it here, I have not
been aware of any similar ideas. But (if you read the topic linked above in
Gentoo Forums) I'm not Schmoog the Surveillance Engine to know it all. Do let
me know if there exists something similar to my idea. Not a good thing
inventing hot water. (And while you're possibly trying to contact me, be aware
of the censorship and related attacks. Use, if you can, the uncenz to document
that you tried to contact me!)

There is a simple standalone script, separate from the set, that will often be
more practical to use: just dumpcamp'ing. Much simpler, but it's akin to
recording only voice and not picture ;-) . You can't show with blatant evidence
to non-experts (which is very much needed!) the censorship that happened, in
cases where stuff like, e.g.  clickjacking and such visual events happened.

That standalone no-ffmpeg is all in just one standalone script:

uncenz-only-dump.sh
