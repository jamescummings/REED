<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all">
    
    <!-- Don't Tell the processor to output pure JSON otherwise it double escapes -->
    <xsl:output method="text" indent="yes"/>
    
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
    
  <!--  <xsl:template match="/">
        <!-\- DataTables expects a JSON object with a root "data" array -\->
        <xsl:variable name="json-output" as="map(*)">
            <xsl:map>
                <xsl:map-entry key="'data'">
                    <xsl:array>
                        <xsl:for-each select="//entry">
                            <xsl:map>
                                
                                <!-\- ID -\->
                                <xsl:map-entry key="'id'" select="string(@xml:id)"/>
                                
                                <!-\- Language -\->
                                <xsl:variable name="code" select="string(@xml:lang)"/>
                                <xsl:map-entry key="'language'" select="($lang-labels($code), $code)[1]"/>
                                
                                <!-\- Attestation (Serialize HTML tags like <span class="ex"> to a string) -\->
                                <xsl:variable name="attestationHtml">
                                    <xsl:apply-templates select="form/orth"/>
                                </xsl:variable>
                                <xsl:map-entry key="'attestation'" select="serialize($attestationHtml, map{'method': 'html'})"/>
                                
                                <!-\- Frequency -\->
                                <xsl:map-entry key="'frequency'" select="string(usg[@type='frequency'])"/>
                                
                                <!-\- References (Serialize <a> tags to a string) -\->
                                <xsl:variable name="refsHtml">
                                    <xsl:for-each select="cit/ref">
                                        <a href="{@target}" target="_blank"><xsl:value-of select="."/></a>
                                        <xsl:if test="position() != last()">, </xsl:if>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:map-entry key="'references'" select="serialize($refsHtml, map{'method': 'html'})"/>
                                
                            </xsl:map>
                        </xsl:for-each>
                    </xsl:array>
                </xsl:map-entry>
            </xsl:map>
        </xsl:variable>-->
        
    <xsl:template match="/">
        
        <!-- Construct a sequence of maps, one for each entry -->
        <xsl:variable name="entries" as="map(*)*">
            <xsl:for-each select="//entry">
                <xsl:map>
                    
                    <!-- ID -->
                    <xsl:map-entry key="'id'" select="string(@xml:id)"/>
                    
                    <!-- Language -->
                    <xsl:variable name="code" select="string(@xml:lang)"/>
                    <xsl:map-entry
                        key="'language'"
                        select="($lang-labels($code), $code)[1]"/>
                    
                    <!-- Attestation -->
                    <xsl:variable name="attestationHtml">
                        <xsl:apply-templates select="form/orth"/>
                    </xsl:variable>
                    
                    <xsl:map-entry
                        key="'attestation'"
                        select="serialize($attestationHtml, map{'method': 'html'})"/>
                    
                    <!-- Frequency -->
                    <xsl:map-entry
                        key="'frequency'"
                        select="string(usg[@type='frequency'])"/>
                    
                    <!-- References -->
                    <xsl:variable name="refsHtml">
                        <xsl:for-each select="cit/ref">
                            <a href="{@target}" target="_blank">
                                <xsl:value-of select="."/>
                            </a>
                            <xsl:if test="position() != last()">, </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:map-entry
                        key="'references'"
                        select="serialize($refsHtml, map{'method': 'html'})"/>
                    
                </xsl:map>
            </xsl:for-each>
        </xsl:variable>
        
        <!-- DataTables expects a JSON object with a root "data" array -->
        <xsl:variable name="json-output" as="map(*)">
            <xsl:map>
                <xsl:map-entry
                    key="'data'"
                    select="array { $entries }"/>
            </xsl:map>
        </xsl:variable>
        
        <!-- presumably your existing JSON serialization here -->
        <xsl:value-of
            select="serialize(
            $json-output,
            map{'method': 'json'}
            )"/>
    </xsl:template>
    
    
    
    <!-- Format Expanded Abbreviations -->
    <xsl:template match="ex">
        <span class="ex">(<xsl:apply-templates/>)</span>
    </xsl:template>
    
</xsl:stylesheet>