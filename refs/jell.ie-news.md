
Reading the news without giving up on your privacy
==================================================

[Stephen Farrell](mailto:stephen@tolerantneworks.com)
20170521 (Updated: 20170601)

First - the good news: done right you can [read the news](https://jell.ie/news/) 
more quickly and easily
and be much more privacy friendly than the default, and it's not that hard to
setup. It'll probably take me longer to write this than it took to setup, so
may as well start...

I like to check various news sources a few times a day.  (Probably too many
times, when I'm not busy:-) This article is about how I arranged to read that
news in a more privacy friendly fashion, using the basic [My-Own.Net](https://my-own.net/) customer
facilities.

In the basic test documented below, reading 8 news/tech web sites 
in a default mode chromium browser involved contacting 188 different hosts, for
a total of 1350 http requests, involving 887 attempts to set cookies in the
browser. 
Doing the same in another browser with conservative privacy
settings (FF/NoScript/Cookies-off) still involved contacting
33 different hosts in 312 requests.

I would assume that the 150 or so aditional hosts are purely involved
in advertising and see no reason why they ought know when and what 
news I decide to read.

In contrast, with the news setup from [My-Own.Net](https://my-own.net/) 
on [Jell.ie](https://jell.ie/news/), only one host 
needs to be contacted 41 times to render equivalent, or probably more,
content. (With no annoying ads, but yes it'd be better we figured a
way to not ask 41 times - once should be enough.)

To me, if you care about your privacy, doing something about this
seems like a no-brainer.

Timing-wise,
[Jell.ie News](https://jell.ie/news/), 
when locally accessed,
is way quicker than the slowest individual page display 
for one of the 8 sites with the default browser. Reading
only the last 24-hours worth of stories, rendering
[Jell.ie News](https://jell.ie/news/) takes about 4
seonds, compared to 18 seconds for the worst single
web page when run with a browser in open-kimono (i.e.
default) mode.

So we get privacy and performance, yay!

## Using a server and Simplepie 

The starting point is to have a web server you control. I'll assume
you do, and that you know how to configure that.

The basic idea is to use the RSS/Atom feeds that the web sites we
want offer, and to merge those into one web page that we update
periodically. For that we're using [Simplepie](https://simplepie.org/)
which is a fairly simple PHP framework for handling RSS/Atom feeds.

Note that we could use FF to consume the RSS feeds directly, but
while that would reduce the hosts we contact to just those whose
content we want, the basic browser rendering of RSS isn't really
usable, at least IMO.

So I took a quick look and found a Simplepie PHP script 
that merges different
feeds into one web page by time, which seemed like just what I wanted.
That also uses the SimplePie caching system so that we don't need
to contact the source sites each time we read the news, further
enhancing privacy.

There was one tricky bit with this - handling images. By default
Simplepie serves HTML to the browser that includes images with
the src attribute pointing to the original site. That makes sense,
but reduces privacy as we end up contacting these sites from
our browser. Clearly we're not the only ones who noticed that
as Simplepie also has a built-in image handler, which replaces
the image src attributes with ones that point to the cache on
our own server. To use that though we needed a second PHP scipt
(ih.php)
to be the target for those image src attributes. That one was
pretty trivial but not that obvious, at first.

Lastly, I created two cron files - one to do a fetch (via curl) of our
new page each hour to prime the cache and another to
delete cache entries that are too old, so we don't end up using
too much disk.

## [My-Own.Net](https://my-own.net/) Setup

If you're a [My-Own.Net](https://my-own.net/) customer, you can do all the above by simply
editing your list of feed URLs, in ~/p84-work/feed-urls.txt and then running
~/code/project84/provnode/p84-build-news.sh all as user p84 on your VPS or
gateway.  

As a [My-Own.Net](https://my-own.net/) customer, there are trade-offs on whether to run this on your
VPS or Gatway.  Use the former if you want to read news from anywhere, but at
the cost that the existence, timing and size metadata related to the HTTPS
traffic from your browser to your VPS being visible to whomever is recording traffic
between those hosts or on those networks.

Use the latter (Gateway) if you only want to read news at home and prefer that the
browser to news-server connection not be visible to the Internet. The cost here
though is that the cron job loading the various feeds comes from you home IP
address which is probably much more identifying than your VPS.  (In practice
that is - in principle an attacker who cared could know that your VPS is yours,
but that's far less likely than some ad bureau knowing that your home IP
address is yours.)

Or, you could install on both I guess. For me, putting this on the VPS is fine
and probably better suits what I want, but you'll make up your own mind on
that.

To un-install use: "./p84-build-news.sh clean"

The current sources for those are:
<ul>
<li><a href="https://basil.dsg.cs.tcd.ie/code/tcd/project84/file/7a7d8d8667df/provnode/p84-build-news.sh">p84-build-news.sh</a></li>
<li><a href="https://basil.dsg.cs.tcd.ie/code/tcd/project84/file/7a7d8d8667df/provnode/news.php">news.php</a></li>
<li><a href="https://basil.dsg.cs.tcd.ie/code/tcd/project84/file/7a7d8d8667df/provnode/ih.php">ih.php</a></li>
</ul>

(Note: the above links will likely change to a github repo at some point.)

## Further Work

As to what else might be done, we've considered the following, but haven't
done anything much about any of them so far:-)

- make it multi-user via some kind of gossiping 
between [My-Own.Net](https://my-own.net/) customers, or between them and
some bit of infrastructure we provide (seems a bit too much effort for
the payoff and gossiped content creates potentially new fake-news 
potential)

- add chaff maybe - some feeds we access randomly but don't render, (easily
enough done, but hard to see how much privacy benefit accrues)

- prime the cache on VPS but send that via VPN to Gateway (again, not sure
benefit is worthwhile)

- there is some flakiness in the caching (or I don't fully understand it
yet;-), we see some accesses to original feeds even when things ought be
cached - not sure why (set cache back to 1hr from 3 to see if that's
different)

- maybe make a no-images version that only needs 1 request/response, or
figure some other way to reduce the 41 requests to one

## Measurements

Tests were started on a Sunday morning around 20170521T0845Z. No attempt
was made to control either the local network or the upstream networks. 
At 0847Z Speedtest.net reported a 17ms ping time, 63.65Mbps download (from a
contracted but notional 100) and 10.26 Mbps upload.  IPv6-test.com scores the
testing laptop 20/20, and it's speed test reports 14Mbps/IPv4 and 28.8Mbps/IPv6
in tests to a server in the UK. None of the speeds reported there are
particularly stable, so should only be taken as rough indicators of the state
of the network. IPv6 is native though, not tunneled.

The news/tech sites tested were:

- Outlet, Web site, RSS feed
- Irish Times, [https://irishtimes.com/](https://irishtimes.com), [https://www.irishtimes.com/cmlink/news-1.1319192](https://www.irishtimes.com/cmlink/news-1.1319192)
- Intercept, [https://theintercept.com/](https://theintercept.com/), [https://theintercept.com/feed/?lang=en](https://theintercept.com/feed/?lang=en)
- Washington Post, [https://www.washingtonpost.com/](https://www.washingtonpost.com/), [http://feeds.washingtonpost.com/rss/rss_blogpost](http://feeds.washingtonpost.com/rss/rss_blogpost)
- Engadget, [https://www.engadget.com/](https://www.engadget.com/), [https://www.engadget.com/rss.xml](https://www.engadget.com/rss.xml)
- Guardian, [https://www.theguardian.com/](https://www.theguardian.com/), [https://www.theguardian.com/world/rss](https://www.theguardian.com/world/rss)
- BBC, [http://www.bbc.com/](http://www.bbc.com), [https://feeds.bbci.co.uk/news/rss.xml?edition=int](https://feeds.bbci.co.uk/news/rss.xml?edition=int)
- Slashdot, [https://slashdot.org/](https://slashdot.org/), [http://rss.slashdot.org/Slashdot/slashdotMain](http://rss.slashdot.org/Slashdot/slashdotMain)
- El Reg, [https://www.theregister.co.uk/](https://www.theregister.co.uk/), [https://www.theregister.co.uk/headlines.atom](https://www.theregister.co.uk/headlines.atom)

Note that in some cases, the feeds and web site front pages are not serving the
same content. In cases where there are re-directs (e.g. BBC re-directs from https://bbc.co.uk
to the above http URI), the "final" URL in the chain is used. Probably doesn't
make much difference though.

For each of the sites above, we load the page in Chromium (58) and FF (53).
Both running on Ubuntu 17.04, 64 bit. Chromium runs in incognito mode so
forgets everyting on exit and each URL is loaded after a fresh start, this
means that there are no cases where a user has clicked "ok" to accept cookies,
unlike in "normal" operation. 

For Chromium, we stop recording once the browser icon has stopped "spinning"
(many web sites will load new content periodically making it hard to determine
when the page is "done.") 

FF runs NoScript and doesn't accept cookies, with none of these sites as
exceptions.  In FF, Cached Web Content was cleared before each measurement.

Timing, number of requests and size information is as reported on the
development pane's "network" tab.  (That's accessed via shift-ctrl-i.) Lastly
we save an HTTP archive ([.har](https://en.wikipedia.org/wiki/.har)) file in
each case and from that determine the number of hosts accessed using:

```
			$ grep \"url\" [har-file] | awk -F'/' '{print $3}' | sort | uniq -c | wc
```

Note that the above counts data URLs as hosts, those figures
are separated below, as we don't check from whom the data URLs were received.
The .har files have been  preserved but not published as they contain addresses 
and who knows what other sensitive information in the overall total of 250k or 
so lines;-)

To check how many set-cookies are attempted from har files we use:

```
			$ grep \"cookies\" [har-file]  | grep -v "\[\]" | wc
```

The repo has a bash script (cds.sh) that does the above and a wee bit more.

### Chromium

#### https://www.irishtimes.com/
- test-runtime: 20170321T0955Z
- num-requests: 253 
- MB-transferred: 3.3
- seconds-to-finished: 14.43
- hosts-accessed: 44 
- data-urls: 7
- set-cookie-attempts: 147

#### https://theintercept.com/
- test-runtime: 20170321T1205Z
- num-requests: 26
- MB-transferred: 4.4
- seconds-to-finished: 4.91
- hosts-accessed: 4
- data-urls: 0
- set-cookie-attempts: 22

#### https://www.washingtonpost.com/
- test-runtime: 20170321T1234Z
- num-requests: 343
- MB-transferred: 2.8
- seconds-to-finished: 12.41
- hosts-accessed: 43
- data-urls: 4
- set-cookie-attempts: 369

#### https://www.engadget.com/ 
- test-runtime: 20170321T1254Z
- num-requests: 341
- MB-transferred: 4.8
- seconds-to-finished: 16.42
- hosts-accessed: 19
- data-urls: 1
- set-cookie-attempts: 2

#### https://www.theguardian.com/
- test-runtime: 20170321T1303Z
- num-requests: 177
- MB-transferred: 2.4
- seconds-to-finished: 5.69
- hosts-accessed: 31
- data-urls: 5
- set-cookie-attempts: 35

#### http://www.bbc.com/
- test-runtime: 20170321T1322Z
- num-requests: 193
- MB-transferred: 1.2
- seconds-to-finished: 6.16
- hosts-accessed: 26
- data-urls: 1
- set-cookie-attempts: 19

#### https://slashdot.org/
- test-runtime: 20170321T1331Z
- num-requests: 235
- MB-transferred: 1.1
- seconds-to-finished: 10.70
- hosts-accessed: 56
- data-urls: 17
- set-cookie-attempts: 209

#### https://www.theregister.co.uk/ 
- test-runtime: 20170321T1340Z
- num-requests: 100
- MB-transferred: 0.8
- seconds-to-finished: 5.09
- hosts-accessed: 22
- data-urls: 3
- set-cookie-attempts: 84


### Firefox/NoScript/Cookies-off

#### https://www.irishtimes.com/
- test-runtime: 20170321T1146Z
- num-requests: 97 
- MB-transferred: 1.8
- seconds-to-finished: 7.28
- hosts-accessed: 4 
- data-urls: 0
- set-cookie-attempts: 0

#### https://theintercept.com/
- test-runtime: 20170321T1219Z
- num-requests: 11
- MB-transferred: 3.2
- seconds-to-finished: 3.44
- hosts-accessed: 3
- data-urls: 0
- set-cookie-attempts: 0

#### https://www.washingtonpost.com/
- test-runtime: 20170321T1236Z
- num-requests: 23
- MB-transferred: 2.3
- seconds-to-finished: 4.12
- hosts-accessed: 3
- data-urls: 3
- set-cookie-attempts: 0

#### https://www.engadget.com/ 
- test-runtime: 20170321T1257Z
- num-requests: 29
- MB-transferred: 3.7
- seconds-to-finished: 11.11
- hosts-accessed: 4
- data-urls: 0
- set-cookie-attempts: 0

#### https://www.theguardian.com/
- test-runtime: 20170321T1311Z
- num-requests: 59
- MB-transferred: 2.5
- seconds-to-finished: 5.85
- hosts-accessed: 6
- data-urls: 0
- set-cookie-attempts: 0

#### http://www.bbc.com/
- test-runtime: 20170321T1326Z
- num-requests: 28
- MB-transferred: 0.5
- seconds-to-finished: 3.95
- hosts-accessed: 8
- data-urls: 0
- set-cookie-attempts: 0

#### https://slashdot.org/
- test-runtime: 20170321T1334Z
- num-requests: 20
- MB-transferred: 0.5
- seconds-to-finished: 3.62
- hosts-accessed: 3
- data-urls: 0
- set-cookie-attempts: 0

#### https://www.theregister.co.uk/ 
- test-runtime: 20170321T1342Z
- num-requests: 42
- MB-transferred: 0.5
- seconds-to-finished: 2.3
- hosts-accessed: 3
- data-urls: 0
- set-cookie-attempts: 0

### All in Chromium

- hosts: 188
- data-urls: 38
- set-cookie-attempts: 887
- host-accesses: 1350

```
   Reqs Host
      1 aax.amazon-adsystem.com,
      1 acdn.adnxs.com,
      1 ado.pro-market.net,
      1 ads.pro-market.net,
      1 adx.g.doubleclick.net,
      1 ag.innovid.com,
      1 amplifypixel.outbrain.com,
      1 ams-login.dotomi.com,
      1 apiservices.krxd.net,
      1 api.viafoura.com,
      1 ap.lijit.com,
      1 app-cdn.spot.im,
      1 b.engadget.com,
      1 bidder.criteo.com,
      1 blip.bizrate.com,
      1 c.amazon-adsystem.com,
      1 cc.swiftype.com,
      1 cdn.syndication.twimg.com,
      1 cms.analytics.yahoo.com,
      1 consent-st.truste.com,
      1 consent.truste.com,
      1 d1z2jf7jlzjs58.cloudfront.net,
      1 d3ezl4ajpp2zy8.cloudfront.net,
      1 d.turn.com,
      1 edigitalsurvey.com,
      1 fig.bbc.co.uk,
      1 google.com,
      1 go.theregister.co.uk,
      1 irishtimes.com,
      1 i.viafoura.co,
      1 js-agent.newrelic.com,
      1 js-sec.indexww.com,
      1 kr.ixiaa.com,
      1 l9bjkkhaycw6f8f4.soundcloud.com,
      1 lf.bizx.info,
      1 mab.chartbeat.com,
      1 m.addthis.com,
      1 m.addthisedge.com,
      1 me-cdn.effectivemeasure.net,
      1 me-ssl.effectivemeasure.net,
      1 mongo-good-server.ext.nile.works,
      1 nir.regmedia.co.uk,
      1 pixel.sitescout.com,
      1 plugin.mediavoice.com,
      1 polyfill.guim.co.uk,
      1 prod01-cdn06.cdn.firstlook.org,
      1 pwapi.washingtonpost.com,
      1 pxl.connexity.net,
      1 recirculation.spot.im,
      1 rpxnow.com,
      1 rumds.wpdigital.net,
      1 s.dpmsrv.com,
      1 secure-au.imrworldwide.com,
      1 sp.adbrn.com,
      1 sp.fastclick.net,
      1 s.sa.aol.com,
      1 s.skimresources.com,
      1 s.swiftypecdn.com,
      1 stags.bluekai.com,
      1 static.criteo.net,
      1 stats.irishtimes.com,
      1 style.sndcdn.com,
      1 sync.go.sonobi.com,
      1 sync.mathtag.com,
      1 sync.tidaltv.com,
      1 syndication.twitter.com,
      1 tag.1rx.io,
      1 tag.researchnow.com,
      1 tag-st.contextweb.com,
      1 theintercept.com,
      1 usermatch.krxd.net,
      1 washingtonpost-d.openx.net,
      1 widget.perfectmarket.com,
      1 wis.sndcdn.com,
      1 www.engadget.com,
      1 www.googletagmanager.com,
      1 www.youtube.com,
      2 2677521.fls.doubleclick.net,
      2 aa.agkn.com,
      2 analytics.slashdotmedia.com,
      2 api.viafoura.co,
      2 bam.nr-data.net,
      2 b.scorecardresearch.com,
      2 cdn-api.arcpublishing.com,
      2 code.createjs.com,
      2 d21rhj7n383afu.cloudfront.net,
      2 d3tglifpd8whs6.cloudfront.net,
      2 d.agkn.com,
      2 dev.visualwebsiteoptimizer.com,
      2 emp.bbc.com,
      2 h.parrable.com,
      2 imasdk.googleapis.com,
      2 io.narrative.io,
      2 mybbc.files.bbci.co.uk,
      2 pbid.pro-market.net,
      2 pix04.revsci.net,
      2 p.nexac.com,
      2 scontent.xx.fbcdn.net,
      2 secure-dcr.imrworldwide.com,
      2 smetrics.washingtonpost.com,
      2 ssc.api.bbc.com,
      2 www.bbc.com,
      2 www.googleadservices.com,
      2 www.spot.im,
      3 a.dpmsrv.com,
      3 api-widget.soundcloud.com,
      3 cdn.taboola.com,
      3 connect.facebook.net,
      3 dpm.demdex.net,
      3 emp.bbci.co.uk,
      3 images.washingtonpost.com,
      3 ml314.com,
      3 nav.files.bbci.co.uk,
      3 ping.chartbeat.net,
      3 platform.twitter.com,
      3 ps.eyeota.net,
      3 sa.bbc.co.uk,
      3 search.files.bbci.co.uk,
      3 secure-gl.imrworldwide.com,
      3 tags.bluekai.com,
      3 uploads.guim.co.uk,
      3 www.bbc.co.uk,
      3 www.theguardian.com,
      4 beacon.gu-web.net,
      4 cdn.viafoura.net,
      4 loxodo-ct.ext.nile.works,
      4 pixel.mathtag.com,
      4 s7.addthis.com,
      4 s.effectivemeasure.net,
      4 static.chartbeat.com,
      4 static.theguardian.com,
      5 cm.g.doubleclick.net,
      5 d1o5u7ifbz3swt.cloudfront.net,
      5 execjobs.irishtimes.com,
      5 fonts.googleapis.com,
      5 ib.adnxs.com,
      5 slashdot.org,
      5 static.bbc.co.uk,
      5 stats.g.doubleclick.net,
      5 www.google.ie,
      6 as-sec.casalemedia.com,
      6 bid.contextweb.com,
      6 cdn-gl.imrworldwide.com,
      6 fastlane.rubiconproject.com,
      6 fonts.gstatic.com,
      6 idsync.rlcdn.com,
      6 interactive.guim.co.uk,
      6 match.adsrvr.org,
      6 ophan.theguardian.com,
      6 www.googletagservices.com,
      7 googleads.g.doubleclick.net,
      7 s.blogsmithmedia.com,
      7 w.soundcloud.com,
      8 cdn-social.janrain.com,
      8 ssl.google-analytics.com,
      8 www.gstatic.com,
      9 i1.sndcdn.com,
      9 s.aolcdn.com,
      9 tag.crsspxl.com,
     10 api.nextgen.guardianapps.co.uk,
     10 prod01-cdn07.cdn.firstlook.org,
     10 www.facebook.com,
     10 www.google.com,
     11 js.washingtonpost.com,
     11 pagead2.googlesyndication.com,
     11 prod01-cdn05.cdn.firstlook.org,
     11 sb.scorecardresearch.com,
     12 cdn.krxd.net,
     12 secure.adnxs.com,
     13 assets.guim.co.uk,
     13 s0.2mdn.net,
     14 beacon.krxd.net,
     14 ichef.bbci.co.uk,
     15 login.slashdot.org,
     17 www.google-analytics.com,
     18 securepubads.g.doubleclick.net,
     19 www.theregister.co.uk,
     20 a.fsdn.com,
     24 img.washingtonpost.com,
     26 static.bbci.co.uk,
     27 tpc.googlesyndication.com,
     33 regmedia.co.uk,
     38 ,
     39 www.washingtonpost.com,
     41 i.guim.co.uk,
    100 o.aolcdn.com,
    112 www.irishtimes.com,
    120 adserver-us.adtech.advertising.com,
    142 adserver.adtechus.com
```

### All in FF/NoScript/Cookies-off

- hosts: 33
- data-urls: 3
- set-cookie-attempts: 0
- host-accesses: 312

```
   Reqs Host
      1 analytics.slashdotmedia.com,
      1 irishtimes.com,
      1 mybbc.files.bbci.co.uk,
      1 theintercept.com,
      1 www.bbc.com,
      1 www.engadget.com,
      2 assets.guim.co.uk,
      2 beacon.gu-web.net,
      2 nav.files.bbci.co.uk,
      2 prod01-cdn07.cdn.firstlook.org,
      2 sa.bbc.co.uk,
      2 slashdot.org,
      2 ssc.api.bbc.com,
      3 ,
      3 images.washingtonpost.com,
      3 static.bbc.co.uk,
      3 www.theguardian.com,
      4 fonts.googleapis.com,
      4 interactive.guim.co.uk,
      4 s.blogsmithmedia.com,
      4 static.theguardian.com,
      5 execjobs.irishtimes.com,
      5 s.aolcdn.com,
      7 static.bbci.co.uk,
      8 prod01-cdn05.cdn.firstlook.org,
     10 ichef.bbci.co.uk,
     10 img.washingtonpost.com,
     10 www.washingtonpost.com,
     17 a.fsdn.com,
     17 www.theregister.co.uk,
     19 o.aolcdn.com,
     24 regmedia.co.uk,
     44 i.guim.co.uk,
     88 www.irishtimes.com
```

### Jell.ie News: https://jell.ie/spie/merged.php

#### Chromium

- test-runtime: 20170321T1352Z
- num-requests: 62
- MB-transferred: 30.7
- seconds-to-finished: 17.11
- hosts-accessed: 1
- data-urls: 0
- set-cookie-attempts: 0

#### FF/NoScript/Cookies-off

- test-runtime: 20170321T1355Z
- num-requests: 61
- MB-transferred: 31.8
- seconds-to-finished: 16.21
- hosts-accessed: 1
- data-urls: 0
- set-cookie-attempts: 0

### Jell.ie News: https://jell.ie/news/

This is a re-run after a bit more optimisation

#### Chromium

- test-runtime: 20170601T0712Z
- num-requests: 41
- MB-transferred: 9.1MB
- seconds-to-finished: 4.36
- hosts-accessed: 1
- data-urls: 0
- set-cookie-attempts: 0

#### FF/NoScript/Cookies-off

- test-runtime: 20170601T0713Z
- num-requests: 41
- MB-transferred: 9.4MB
- seconds-to-finished: 4.51
- hosts-accessed: 1
- data-urls: 0
- set-cookie-attempts: 0

