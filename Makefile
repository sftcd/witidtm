# MDCMD=markdown_py 
MDCMD=multimarkdown
# make sure -f is last
# MDOPTS=-f

all: index.html

index.html: README.md
	# $(MDCMD) $(MDOPTS) $(@) > $(<) 
	$(MDCMD) $(MDOPTS) $(<) > $(@) 

upload: index.html
	ssh down.dsg.cs.tcd.ie "(cd /var/www/witidtm;git pull)"
