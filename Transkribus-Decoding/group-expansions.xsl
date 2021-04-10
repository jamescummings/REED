<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:jc="http://james.blushingbunny.net/ns.html"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei jc"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- 
     2021 - Group Expansions for Decoded Files from REED London Project Transkribus Tests
    by jamescummings - CC+BY 
    -->
   
   <!-- copy all -->
   <xsl:template match="@*|node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
        </xsl:template>
        
        
        <!-- For nodes with an ex child group all of these ex elements if there is an ex next to it. -->
  <xsl:template match="node()[ex]">
            <xsl:copy>
                <!--<xsl:apply-templates select="@*" />-->
                <xsl:for-each-group select="node()" group-adjacent="
   string-join(for $x in self::ex return
     concat( namespace-uri(), '|', local-name()),'')">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()" >
                            <xsl:for-each select="current-group()[1]">
                                <xsl:copy>
                                    <!--<xsl:apply-templates select="@* | current-group()/node()" />-->
                                    <xsl:apply-templates select="current-group()/node()" />
                                </xsl:copy>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="current-group()" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:copy>
        </xsl:template>
        
    </xsl:stylesheet>
    