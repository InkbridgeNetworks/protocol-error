DRAFT	:= $(basename $(wildcard draft*.md))
VERSION	:= $(shell sed -n -e'/docname/s,.*[^0-9]*-\([0-9]*\).*,\1,p' ${DRAFT}.md )
EXAMPLES =

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	@cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt

#	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.md ${EXAMPLES}
	@kramdown-rfc2629 -3 ${DRAFT}.md > ${DRAFT}.xml
	@xml2rfc --v2v3 ${DRAFT}.xml
	@mv ${DRAFT}.v2v3.xml ${DRAFT}.xml

%.txt: %.xml
	@xml2rfc --text -o $@ $?

%.html: %.xml
	@xml2rfc --html -o $@ $?

submit: ${DRAFT}.xml
	@curl -S -F "user=aland@freeradius.org" -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submission | jq
	@git tag ${DRAFT}-${VERSION}

.PHONY:
version:
	@echo Version: ${VERSION}

.PHONY:
clean:
	@rm -f *.xml *~

.PHONY: tag
tag:
	@git tag ${DRAFT}-${VERSION}

.PHONY: spell
spell: $(DRAFT).md
	aspell -d en_US -c $<

.PRECIOUS: ${DRAFT}.xml
