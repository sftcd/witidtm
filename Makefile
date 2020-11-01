REQS=python3-pip make tree
# Requires python-markdown 3.3.3
MDCMD=python3 -m markdown
# make sure -f is last
MDOPTS=-f

all: update pdf_indexes housekeeping indexraw.html

update:
	sudo apt-get update
	sudo apt-get install $(REQS) -y
	python3 -m pip install markdown

housekeeping:
	sed -i '$$d' README.md
	date >> README.md

pdf_indexes:
	tree -a thisyear -H '.' -L 1 --noreport --charset utf-8 -P "*.pdf" > thisyear/index.html

indexraw.html: README.md
	$(MDCMD) -x md_in_html $(MDOPTS) $(@) $(<)

upload: index.html
	ssh down.dsg.cs.tcd.ie "(cd /var/www/witidtm;git pull)"
