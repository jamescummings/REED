
These XSLT scripts decode an encoder ring of character replacements used by the REED London project in appling HTR to source REED volumes using Transkribus. 

It contains a decoder.xsl which decodes the characters and wraps them in `<ex>` elements and then a group-expansions.xsl which groups neighbouring expanded characters together.

To use it you would take your XML file (here 'decode-test.xml') and do something like this: 

> saxon -s:decode-test.xml -xsl:decode.xsl -o:decoded.xml 

then group them with: 

>  saxon -s:decoded.xml -xsl:group-expansions.xsl -o:decoded-grouped.xml  

