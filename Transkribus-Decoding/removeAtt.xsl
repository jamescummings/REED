<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common">
    
    <!-- Remove from specified children. -->
    <xsl:variable name="remove">
        <ex n="@"/>
    </xsl:variable>
    
    <!-- Match "value" attribute. -->
    <xsl:template match="TEI/ex/@value">
        <!-- Get child ID. -->
        <xsl:variable name="n" select="current()/parent::node()/@n"/>
        <!-- If there is no match, keep value; otherwise, remove value. -->
        <xsl:if test="not(exsl:node-set($remove)/*[@n = $n])">
            <xsl:copy/>
        </xsl:if>
    </xsl:template>
    
    <!-- Copy all nodes and attributes unless another rule indicates otherwise. -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
