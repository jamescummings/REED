<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd tei #default" version="2.0" >
    <xsl:output indent="yes"/>
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> August 7 2018 but modified many times thereafter</xd:p>
            <xd:p><xd:b>Author:</xd:b> jamesc</xd:p>
            <xd:p>Convert REED Volumes to Abbbreviations wordlist</xd:p>
            <xd:p>
                Run with:
                
                rm abbreviations-wordlist.xml ;
                saxon -xsl:generateAbbreviationList.xsl -it:main -o:abbreviations-wordlist.xml
                
                
            </xd:p>
        </xd:desc>
    </xd:doc>
   
    <!-- files and recurse parameters defaulting to '*.xml' and 'no' respectively -->
    <xsl:param name="files" select="'*.xml'"/>
    <xsl:param name="recurse" select="'no'"/>
    <xsl:variable name="path">
        <xsl:value-of
            select="concat('./?select=', $files,';on-error=warning;recurse=',$recurse)"/>
    </xsl:variable>
    <!-- the main collection of all the documents we are dealing with -->
    <xsl:variable name="docs" select="collection($path)"/>
    
   <!--  --> 
   <xsl:template match="@*|node()" mode="#all">
       <xsl:copy><xsl:apply-templates select="@*|node()" mode="#current"/></xsl:copy>
   </xsl:template>
    
    <xsl:template name="main">
        <!-- Mark Words -->
        <xsl:variable name="pass0">
            <xsl:apply-templates select="$docs" mode="pass0"/>
        </xsl:variable>
        <!-- Group words with abbreviations -->
        <xsl:variable name="pass1">
            <xsl:for-each-group select="$pass0/node()" group-adjacent="boolean(self::text())">
                                <w><xsl:apply-templates select="current-group()" mode="pass1"/></w><xsl:text>
</xsl:text>
            </xsl:for-each-group>
        </xsl:variable>
        <!-- Get rid of extra spaces, punctuation, etc. -->
        <xsl:variable name="pass2"><xsl:apply-templates select="$pass1" mode="pass2"/></xsl:variable>
        <!-- Just abbreviations, deduplicate -->
        <xsl:variable name="pass3">
            <xsl:for-each select="$pass2/w[ex]">
                <xsl:sort/>
                <xsl:copy><xsl:apply-templates mode="pass3"/></xsl:copy><xsl:text>
</xsl:text>                    
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="pass4">
            <xsl:for-each-group select="$pass3/w" group-starting-with="w[not(some $i in following-sibling::w satisfies deep-equal($i, .))]">
<item n="{count(current-group())}"><xsl:apply-templates mode="pass4"/></item><xsl:text>
</xsl:text>
            </xsl:for-each-group>
        </xsl:variable>
        <!--
        
        <w n="128">w<ex>i</ex>th</w>
        <w n="23">w<ex>i</ex>th</w>
        <w n="13">w<ex>i</ex>th</w>
        <w n="9">w<ex>i</ex>th</w>
        -->
<!-- Main document -->

<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>REED Abbreviation Wordlist</title>
            </titleStmt>
            <publicationStmt>
                <authority><persName>James Cummings</persName></authority>
                <availability><licence target="https://creativecommons.org/licenses/by/4.0/">CC+By</licence></availability>
            </publicationStmt>
            <sourceDesc>
                <p>Abbreviation Wordlist from REED staff.xml and berks.xml</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>
    <text>
        <body>
            <p>This is a wordlist of expanded words in REED staff.xml and berks.xml 
                with a count of how many times they appeared total.</p>
            <p>There are <xsl:value-of select="count($pass4/item)"/> expanded words once deep-equal duplicates have been removed 
            from a total of <xsl:value-of select="sum($pass4/item/@n)"/> expanded word instances.</p>
                          
              <list>
                  <xsl:copy-of select="$pass4"/>
              </list>        
        </body>
    </text>
</TEI>
</xsl:template>
    
    
    
    <xsl:template match="text()[not(ancestor-or-self::w)][not(ancestor-or-self::ex)]" mode="pass0"> 
        <xsl:analyze-string regex="(\w+|;,.!:'+)" select=".">
            <xsl:matching-substring><w><xsl:value-of select="."/></w></xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
   
   
    <xsl:template match="*[not(name()='ex')][not(name()='w')]" mode="pass0"><xsl:apply-templates mode="#current"/></xsl:template>
    
    <xsl:template match="ex|w" mode="pass0"><xsl:copy><xsl:apply-templates mode="#current"/></xsl:copy></xsl:template>
    
    <xsl:template match="w" mode="pass1"><xsl:apply-templates mode="#current"/></xsl:template>
    <xsl:template match="w/w" mode="pass2"><xsl:apply-templates mode="#current"/></xsl:template>
    <xsl:template match="w[normalize-space(translate(., '.,;:/?&amp;&lt;&gt;{}[]()-–_=+#~*^%$£!', ''))='']" mode="pass2 pass1"/>
    
</xsl:stylesheet>
