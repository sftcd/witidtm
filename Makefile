# MDCMD=markdown_py 
MDCMD=multimarkdown
# make sure -f is last
# MDOPTS=-f

all: index.html

index.html: README.md
	# $(MDCMD) $(MDOPTS) $(@) > $(<) 
	$(MDCMD) $(MDOPTS) $(<) > $(@) 

lectures/2021-2022/index.html: lectures/2021-2022/README.md
	$(MDCMD) $(MDOPTS) $(<) > $(@) 

upload: index.html
	ssh down.dsg.cs.tcd.ie "(cd /var/www/witidtm;git pull)"
