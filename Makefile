MDCMD=markdown_py 
# make sure -f is last
MDOPTS=-f

all: indexraw.html

indexraw.html: README.md
	$(MDCMD) -x toc $(MDOPTS) $(@) $(<) 

#Not sure about this upload
#upload: index.html
#	ssh down.dsg.cs.tcd.ie "(cd /var/www/witidtm;git pull)"
