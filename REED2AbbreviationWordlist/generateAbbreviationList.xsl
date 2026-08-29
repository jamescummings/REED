<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:reed="http://reed.utoronto.ca/ns/abbrev-stylesheet" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs map xd tei reed" version="3.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> August 7 2018 but modified many times thereafter</xd:p>
            <xd:p><xd:b>Author:</xd:b> jamesc</xd:p>
            <xd:p><xd:b>Rewritten:</xd:b> more recently as XSLT 3.0, using map()-based
                grouping.</xd:p>
            <xd:p>Convert REED Volumes to a TEI-encoded dictionary of scribal abbreviations.</xd:p>
            <xd:p>Run with (Saxon 9.8 HE or later; requires XPath 3.1 map support): rm
                abbreviations-wordlist.xml ; saxon -xsl:generateAbbreviationList.xsl -it:main
                -o:abbreviations-wordlist.xml [files=some-glob.xml] [recurse=yes] [debug=false]
                [include-editorial-notes=true] [min-frequency=2] [sort-by=frequency] </xd:p>
        </xd:desc>
    </xd:doc>

    <!--          PARAMETERS          -->

    <!-- Which files to load, and whether to recurse into subdirectories. Same semantics
         as the original stylesheet: passed straight through to fn:collection(). -->
    <xsl:param name="dir" select="''" as="xs:string"/>
    <xsl:param name="files" select="'*.xml'" as="xs:string"/>
    <xsl:param name="recurse" select="'no'" as="xs:string"/>

    <!-- If false (the default), <note type="foot"> content, modern editorial commentary,
         not part of the manuscript transcription, is skipped entirely so it can never
         contribute a spurious abbreviation to the wordlist. Set to true() to include it. -->
    <xsl:param name="include-editorial-notes" select="false()" as="xs:boolean"/>

    <!-- Drop entries that occur fewer than this many times. Useful for filtering out
         one-off transcription slips once you trust the pipeline; default (1) keeps everything. -->
    <xsl:param name="min-frequency" select="1" as="xs:integer"/>

    <!-- 'alpha' (default) sorts each language division alphabetically by the attested
         form; 'frequency' sorts most-frequent first. -->
    <xsl:param name="sort-by" select="'alpha'" as="xs:string"/>

    <!-- xml:lang to fall back to when no ancestor declares one. 'und' = BCP 47
         "undetermined", so this is visible in the output rather than silently wrong. -->
    <xsl:param name="default-lang" select="'und'" as="xs:string"/>

    <!-- Emit xsl:message progress/diagnostic output as the transform runs. Turn off for
         a quiet batch run once you've verified the pipeline against your corpus. -->
    <xsl:param name="debug" select="false()" as="xs:boolean"/>

    <!--          COLLECTION LOADING          -->

    <xsl:variable name="path" as="xs:string"
        select="concat('./', $dir, '?select=', $files, ';on-error=warning;recurse=', $recurse)"/>

    <!-- The full set of source REED documents being indexed. -->
    <xsl:variable name="docs" select="collection($path)" as="document-node()*"/>

    <!-- 
         A small lookup table of language-code -> human-readable label, used for
         division headings. Extend as your corpus needs (REED material is
         mostly eng/enm [Middle English]/lat, with occasional Anglo-Norman/fro).
          -->
    <xsl:variable name="lang-labels" as="map(xs:string, xs:string)" select="
            map {
                'ang': 'Old English',
                'eng': 'English',
                'enm': 'Middle English',
                'lat': 'Latin',
                'fro': 'Old French',
                'fra': 'French',
                'frm': 'Middle French',
                'ita': 'Italian',
                'und': 'Undetermined-language'
            }"/>

    <!-- 
         MAIN ENTRY POINT
         Orchestrates the whole pipeline: tokenize -> merge fragments into whole
         orthographic words -> keep only words containing at least one <ex> ->
         group into a map keyed by canonical word-shape, per language -> serialize
         as a TEI dictionary with one <div type="dictionary"> per language.
          -->
    <xsl:template name="main">
        <xsl:if test="$debug">
            <xsl:message select="
                    concat('[reed-abbrev] loading documents matching &quot;', $files,
                    '&quot; (recurse=', $recurse, ')')"/>
            <xsl:message select="concat('[reed-abbrev] ', count($docs), ' document(s) loaded')"/>
        </xsl:if>

        <!-- STEP 1: tokenize. Only div[@type='transcription'] content is visited, so
             headwords, EATS-linked <rs>, labels used purely for header metadata, dates,
             etc. outside the transcription proper never enter the pipeline at all. -->
        <xsl:variable name="raw-tokens" as="node()*">
            <xsl:apply-templates select="$docs//div[@type = 'transcription']" mode="tokenize"/>
        </xsl:variable>

        <!-- STEP 2: merge adjacent <w>/<ex> fragments that belong to one orthographic
             word (e.g. "Ma" + <ex>ies</ex> + "ty") into a single <w> element. -->
        <xsl:variable name="merged" as="element(w)*">
            <xsl:call-template name="merge-fragments">
                <xsl:with-param name="tokens" select="$raw-tokens"/>
            </xsl:call-template>
        </xsl:variable>

        <!-- STEP 3: only words that actually contain an editorially-expanded
             abbreviation are of interest for this wordlist. -->
        <xsl:variable name="abbrev-instances" select="$merged[ex]" as="element(w)*"/>

        <xsl:variable name="languages" select="distinct-values($abbrev-instances/@xml:lang)"
            as="xs:string*"/>

        <xsl:if test="$debug">
            <xsl:message select="
                    concat('[reed-abbrev] ', count($merged),
                    ' orthographic word-tokens assembled; ', count($abbrev-instances),
                    ' contain at least one editorially-supplied abbreviation')"/>
            <xsl:message
                select="concat('[reed-abbrev] languages found: ', string-join($languages, ', '))"/>
            <xsl:if test="count($abbrev-instances[@xml:lang = $default-lang]) gt 0">
                <xsl:message select="
                        concat('[reed-abbrev] WARNING: ',
                        count($abbrev-instances[@xml:lang = $default-lang]),
                        ' instance(s) had no xml:lang in scope and fell back to &quot;', $default-lang, '&quot;')"
                />
            </xsl:if>
        </xsl:if>

        <!-- STEP 4: group instances into a map per language, keyed by canonical word
             shape, in one linear/log-linear pass — see reed:build-index() below.
             This single map is reused both for the header statistics and for the
             division bodies, so the (potentially expensive) grouping is only done once
             per language rather than being recomputed. -->
        <xsl:variable name="lang-indexes" as="map(xs:string, map(xs:string, map(*)))" select="
                map:merge(
                for $l in $languages
                return
                    map {$l: reed:build-index($abbrev-instances[@xml:lang = $l])}
                )"/>

        <xsl:variable name="total-distinct-forms" as="xs:integer" select="
                sum(for $l in $languages
                return
                    map:size(map:get($lang-indexes, $l)))"/>

        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>REED Abbreviation Wordlist</title>
                        <respStmt>
                            <resp>Automatically generated by</resp>
                            <name>generateAbbreviationList.xsl</name>
                        </respStmt>
                    </titleStmt>
                    <extent><xsl:value-of select="count($abbrev-instances)"/> abbreviated word
                        instance(s); <lb/><xsl:value-of select="$total-distinct-forms"/> distinct
                        abbreviated form(s) across <xsl:value-of select="count($languages)"/>
                        language(s).</extent>
                    <publicationStmt>
                        <authority>
                            <persName>James Cummings</persName>
                        </authority>
                        <date when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"/>
                        <availability>
                            <licence target="https://creativecommons.org/licenses/by/4.0/">CC-BY
                                4.0</licence>
                        </availability>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Automatically extracted from the abbreviated word-forms found in the
                            transcription of <xsl:value-of select="count($docs)"/> REED source
                            document(s), listed below by their declared title (falling back to the
                            file's URI if no title could be found). <listBibl>
                                <xsl:for-each select="$docs">
                                    <xsl:variable name="title" select="(.//titleStmt/title[1])[1]"/>
                                    <bibl>
                                        <xsl:choose>
                                            <xsl:when test="exists($title)">
                                                <xsl:value-of
                                                  select="normalize-space(string($title))"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="base-uri(.)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </bibl>
                                </xsl:for-each>
                            </listBibl>
                        </p>

                    </sourceDesc>
                </fileDesc>
                <encodingDesc>
                    <editorialDecl>
                        <p>Word forms are drawn only from div[type="transcription"] elements in each
                            source document.</p>
                        <p>By default, content inside note[type="foot"] (editorial footnotes) is
                            excluded, since footnotes contain modern editorial commentary rather
                            than transcribed text; this run was generated with
                                include-editorial-notes=<xsl:value-of
                                select="$include-editorial-notes"/>.</p>
                        <p>A word is included in this list if it contains at least one ex element,
                            i.e. at least one letter or letters editorially supplied to expand a
                            scribal abbreviation. Runs of word-characters joined by a single
                            apostrophe (straight or curly) are treated as one word, so that
                            contracted or elided forms are not split at the apostrophe.</p>
                        <p>Entries whose only attestations occur inside a supplied element (i.e.
                            text editorially supplied where none survives, rather than merely
                            abbreviated) are marked cert="low" on the entry.</p>
                        <p>Distinct entries are determined by the exact shape of the word, i.e. by
                            both its letters and the position(s) of the editorially supplied
                            portion(s); two words that look identical once expanded but differ in
                            what was actually written by the scribe are listed as separate
                            entries.</p>
                    </editorialDecl>
                </encodingDesc>
                <profileDesc>
                    <langUsage>
                        <xsl:for-each select="$languages">
                            <xsl:sort select="."/>
                            <language ident="{.}">
                                <xsl:value-of select="reed:lang-label(.)"/>
                            </language>
                        </xsl:for-each>
                    </langUsage>
                </profileDesc>
                <revisionDesc>
                    <change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}"> This
                        version of the file was generated. </change>
                </revisionDesc>
            </teiHeader>
            <text>
                <body>
                    <head>REED Abbreviation Wordlist</head>
                    <p>This is an automatically generated index of scribal abbreviations found in
                        the transcribed text of the source documents listed above. <xsl:value-of
                            select="count($abbrev-instances)"/> total abbreviated-word instances
                        were found, representing <xsl:value-of select="$total-distinct-forms"/>
                        distinct abbreviated forms, split below by language.</p>
                    <p>Each entry gives the attested form (with editorially supplied letters marked
                        by <mentioned>ex</mentioned>), its frequency, and a citation back to the
                            <mentioned>xml:id</mentioned> of the manuscript transcription division
                        in which each instance occurs, so any attestation can be checked against its
                        source.</p>

                    <xsl:for-each select="$languages">
                        <xsl:sort select="."/>
                        <xsl:variable name="lang" select="."/>
                        <xsl:variable name="index" select="map:get($lang-indexes, $lang)"/>

                        <xsl:if test="$debug">
                            <xsl:message select="
                                    concat('[reed-abbrev] language &quot;', $lang, '&quot; (',
                                    reed:lang-label($lang), '): ', map:size($index), ' distinct form(s) from ',
                                    count($abbrev-instances[@xml:lang = $lang]), ' instance(s)')"
                            />
                        </xsl:if>

                        <xsl:call-template name="dictionary-division">
                            <xsl:with-param name="lang" select="$lang"/>
                            <xsl:with-param name="index" select="$index"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </body>
            </text>
        </TEI>
    </xsl:template>

    <!-- 
         TOKENIZE mode
         Walks the transcribed content of a REED div[@type='transcription'], turning
         free text into <w>word</w> tokens while leaving <ex> (the editorially
         supplied/expanded letters of an abbreviation) as a distinct sibling element,
         so the next pass can tell exactly which letters the scribe wrote and which
         were supplied editorially. Every <w> and <ex> is stamped with @xml:lang and
         @div at the point it is created, so that provenance travels with it
         through the later merge/group passes without having to re-walk the ancestor
         axis later (the ancestor axis is no longer available once we're working from
         a detached result-tree-fragment).
          -->

    <!-- Split free text into word-tokens. The regex keeps a single apostrophe
         (straight or curly) attached when it joins two runs of word-characters,
         so contractions/elisions like "y'e" or "don't" survive as one token,
         while a stray trailing apostrophe (e.g. a closing quotation mark) is left
         as ordinary punctuation rather than being swallowed into the word. -->
    <xsl:template match="text()" mode="tokenize">
        <xsl:variable name="lang" select="reed:nearest-lang(.)" as="xs:string"/>
        <xsl:variable name="divid" select="reed:transcription-id(.)" as="xs:string?"/>
        <xsl:variable name="supplied" select="exists(ancestor-or-self::supplied)" as="xs:boolean"/>
        <xsl:analyze-string select="." regex="\w+(?:['’]\w+)*">
            <xsl:matching-substring>
                <w xml:lang="{$lang}" div="{$divid}">
                    <xsl:if test="$supplied">
                        <xsl:attribute name="supplied">true</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </w>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <!-- <ex> holds editorially supplied/expanded letters. Its content is copied
         through as a single unbroken run — it must NOT be re-tokenized, or a
         multi-letter expansion like <ex>ies</ex> would itself get split into
         further <w> elements. -->
    <xsl:template match="ex" mode="tokenize">
        <ex xml:lang="{reed:nearest-lang(.)}" div="{reed:transcription-id(.)}">
            <xsl:if test="exists(ancestor-or-self::supplied)">
                <xsl:attribute name="supplied">true</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </ex>
    </xsl:template>

    <!-- Editorial footnotes are excluded by default (see $include-editorial-notes):
         they contain modern editorial commentary, not transcribed manuscript text,
         and can otherwise smuggle in spurious abbreviation "instances". -->
    <xsl:template match="note[@type = 'foot']" mode="tokenize">
        <xsl:choose>
            <xsl:when test="$include-editorial-notes">
                <xsl:apply-templates mode="tokenize"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$debug">
                    <xsl:message select="
                            concat('[reed-abbrev] skipping editorial footnote in ',
                            reed:transcription-id(.))"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Every other element in the transcription (e.g. ab, hi, rs, add, del, damage, gap,
         supplied, pb, lb, handShift, etc.) carries no meaning of its own for word
         extraction, so it is simply unwrapped and its children are processed in turn.
         (gap/pb/lb etc. have no text content, so this is a safe no-op for them.) -->
    <xsl:template match="*" mode="tokenize">
        <xsl:apply-templates mode="tokenize"/>
    </xsl:template>

    <!-- 
         MERGE-FRAGMENTS
         Groups the flat tokenize-mode output back into whole orthographic words.
         Because the source markup places <ex> as a sibling in the middle of a word
         (e.g. text "Ma", element <ex>ies</ex>, text "ty" are three siblings with no
         whitespace between them), any run of adjacent <w>/<ex> elements with no
         intervening text node is, by definition, one orthographic word and gets
         merged into a single outer <w>. Runs of plain text between such element-runs
         (whitespace, punctuation) are discarded here — they were only ever needed
         to mark word boundaries, and are of no further interest once that job is
         done. This whole pass is a single linear scan (no comparisons between
         tokens), unlike the grouping done later in reed:build-index(). If either the
         opening or closing fragment of a merged word is an <ex> (i.e. the
         abbreviation mark fell at the very start or end of the word), the outer
         wrapper's @xml:lang/@div/@supplied are still taken correctly from
         current-group()[1], since that attribute-stamping happened uniformly for
         both <w> and <ex> in the tokenize pass above.
          -->
    <xsl:template name="merge-fragments">
        <xsl:param name="tokens" as="node()*"/>
        <xsl:for-each-group select="$tokens" group-adjacent="boolean(self::text())">
            <xsl:if test="not(current-grouping-key())">
                <xsl:variable name="first" select="current-group()[1]"/>
                <w xml:lang="{$first/@xml:lang}" div="{$first/@div}">
                    <xsl:if test="
                            some $g in current-group()
                                satisfies $g/@supplied = 'true'">
                        <xsl:attribute name="supplied">true</xsl:attribute>
                    </xsl:if>
                    <xsl:for-each select="current-group()">
                        <xsl:choose>
                            <xsl:when test="self::ex">
                                <ex>
                                    <xsl:value-of select="."/>
                                </ex>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </w>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>

    <!-- 
         DICTIONARY DIVISION
         Emits one <div type="dictionary" xml:lang="..."> for a single language,
         from its pre-built index map (see reed:build-index()). Sort order is
         controlled by $sort-by; entries below $min-frequency are skipped.
          -->
    <xsl:template name="dictionary-division">
        <xsl:param name="lang" as="xs:string"/>
        <xsl:param name="index" as="map(xs:string, map(*))"/>

        <div type="dictionary" xml:lang="{$lang}">
            <head><xsl:value-of select="reed:lang-label($lang)"/> Abbreviations</head>

            <xsl:for-each
                select="map:keys($index)[xs:integer(map:get($index, .)?count) ge $min-frequency]">
                <!-- Primary sort by frequency when requested; defaults to 0 otherwise -->
                <xsl:sort select="
                        if ($sort-by = 'frequency') then
                            xs:integer(map:get($index, .)?count)
                        else
                            0" data-type="number" order="descending"/>
                <!-- Secondary/Alphabetical sort by stripped word form -->
                <xsl:sort select="lower-case(reed:sort-text(.))" data-type="text" order="ascending"/>

                <xsl:variable name="v" select="map:get($index, .)"/>
                <entry xml:id="{reed:entry-id($lang, position())}" xml:lang="{$lang}">
                    <xsl:if test="$v?supplied = true()">
                        <xsl:attribute name="cert">low</xsl:attribute>
                    </xsl:if>
                    <form type="attestation">
                        <orth>
                            <xsl:copy-of select="$v?sample/node()"/>
                        </orth>
                    </form>
                    <usg type="frequency">
                        <xsl:value-of select="$v?count"/>
                    </usg>

                    <!-- Single cit block containing the quoted form once, followed by all instance refs -->
                    <cit type="examples">
                        <quote>
                            <xsl:copy-of xml:space="preserve" select="$v?sample/node()"/>
                        </quote>
                        <xsl:for-each select="$v?instances">
                            <xsl:choose>
                                <xsl:when test="string-length(@div) gt 0">
                                    <ref
                                        target="{concat('https://ereed.org/records/', substring-before(@div, '-transcription'))}">
                                        <xsl:value-of
                                            select="substring-before(@div, '-transcription')"/>
                                    </ref>
                                </xsl:when>
                                <xsl:otherwise>
                                    <ref target="#unknown"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </cit>

                </entry>
            </xsl:for-each>
        </div>
    </xsl:template>



    <!-- 
         FUNCTIONS
          -->

    <!-- The nearest declared xml:lang in scope for a node, defaulting to
         $default-lang (and warned about via $debug) if none is found at all. -->
    <xsl:function name="reed:nearest-lang" as="xs:string">
        <xsl:param name="n" as="node()"/>
        <xsl:variable name="langs" select="$n/ancestor::*/@xml:lang"/>
        <xsl:sequence select="
                if (exists($langs)) then
                    string($langs[last()])
                else
                    $default-lang"/>
    </xsl:function>

    <!-- The xml:id of the nearest enclosing div[@type='transcription'], i.e. the
         thing we link citations back to. -->
    <xsl:function name="reed:transcription-id" as="xs:string?">
        <xsl:param name="n" as="node()"/>
        <xsl:sequence select="($n/ancestor::div[@type = 'transcription'])[1]/@xml:id/string()"/>
    </xsl:function>

    <!-- A canonical string "shape" for a merged <w> element: the text is
         concatenated as-is, but each <ex>'s content is wrapped in a pair of
         Private-Use-Area marker characters (U+E000/U+E001) that cannot occur in
         real manuscript text. This lets two words be compared for equality (and
         grouped) with an ordinary string/map key, O(1) hashing rather than an
         O(n) deep-equal per comparison, while still distinguishing e.g.
         "w<ex>i</ex>th" from "wi<ex>t</ex>h", which look identical if silently expanded
         but represent different scribal abbreviations. -->
    <xsl:function name="reed:word-key" as="xs:string">
        <xsl:param name="w" as="element(w)"/>
        <xsl:value-of>
            <xsl:for-each select="$w/node()">
                <xsl:choose>
                    <xsl:when test="self::ex">&#xE000;<xsl:value-of select="string(.)"
                        />&#xE001;</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:value-of>
    </xsl:function>

    <!-- Strips the U+E000/U+E001 markers back out of a word-key, for use as a
         human/alphabetical sort key (so sorting isn't perturbed by the markers). -->
    <xsl:function name="reed:sort-text" as="xs:string">
        <xsl:param name="key" as="xs:string"/>
        <xsl:sequence select="translate($key, '&#xE000;&#xE001;', '')"/>
    </xsl:function>

    <!-- REED Build-Index: builds a map from canonical word-key to a small record map
         holding a representative sample node, the true instance count, the xml:id
         of every transcription division the word was attested in (one entry per
         instance, duplicates included on purpose — every instance gets its own
         citation), and whether any instance fell inside a <supplied> passage.
         -->
    <xsl:function name="reed:build-index" as="map(xs:string, map(*))">
        <xsl:param name="instances" as="element(w)*"/>
        <xsl:map>
            <xsl:for-each-group select="$instances" group-by="reed:word-key(.)">
                <xsl:map-entry key="current-grouping-key()" select="
                        map {
                            'sample': current-group()[1],
                            'count': count(current-group()),
                            'instances': current-group(),
                            'divids': current-group()/@div/string(),
                            'supplied': (some $g in current-group()
                                satisfies $g/@supplied = 'true')
                        }"/>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:function>

    <!-- Human-readable label for a language code, falling back to the raw code
         itself if it isn't in $lang-labels (rather than failing). -->
    <xsl:function name="reed:lang-label" as="xs:string">
        <xsl:param name="code" as="xs:string"/>
        <xsl:sequence select="
                if (map:contains($lang-labels, $code)) then
                    map:get($lang-labels, $code)
                else
                    $code"/>
    </xsl:function>

    <!-- Stable, readable xml:id for an entry, e.g. entry-eng-0001. -->
    <xsl:function name="reed:entry-id" as="xs:string">
        <xsl:param name="lang" as="xs:string"/>
        <xsl:param name="n" as="xs:integer"/>
        <xsl:sequence
            select="concat('entry-', translate($lang, ':', '-'), '-', format-number($n, '0000'))"/>
    </xsl:function>

</xsl:stylesheet>
