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
    2021 - Decode REED London Project Transkribus Tests
    by jamescummings - CC+BY 
      -->
    
    
<xsl:template match="text//text()" mode="pass0">
    <xsl:variable name="start" select="."/> 
    
    <!--Each variable applies templates to the previous variable in 
    order to get each possible output. 
    -->
    
    <!-- Character Combinations
        -->
    <!-- arij $৲€₺ -->
    <xsl:variable name="arij"><xsl:apply-templates select="$start" mode="replaceStrings"><xsl:with-param name="search" select="'\$৲€₺'"/><xsl:with-param name="replace" select="'arij'"/></xsl:apply-templates></xsl:variable>
    <!-- ar  $৲ -->
    <xsl:variable name="ar "><xsl:apply-templates select="$arij" mode="replaceStrings"><xsl:with-param name="search" select="'\$৲'"/><xsl:with-param name="replace" select="'ar'"/></xsl:apply-templates></xsl:variable>
    <!--em £₱-->
    <xsl:variable name="em"><xsl:apply-templates select="$ar" mode="replaceStrings"><xsl:with-param name="search" select="'£₱'"/><xsl:with-param name="replace" select="'em'"/></xsl:apply-templates></xsl:variable>
    <!--er £৲-->
    <xsl:variable name="er"><xsl:apply-templates select="$em" mode="replaceStrings"><xsl:with-param name="search" select="'£৲'"/><xsl:with-param name="replace" select="'er'"/></xsl:apply-templates></xsl:variable>
    <!--es £৳-->
    <xsl:variable name="es"><xsl:apply-templates select="$er" mode="replaceStrings"><xsl:with-param name="search" select="'£৳'"/><xsl:with-param name="replace" select="'es'"/></xsl:apply-templates></xsl:variable>
    <!--ie €£-->
    <xsl:variable name="ie"><xsl:apply-templates select="$es" mode="replaceStrings"><xsl:with-param name="search" select="'€£'"/><xsl:with-param name="replace" select="'ie'"/></xsl:apply-templates></xsl:variable>
    <!--is €৳-->
    <xsl:variable name="is"><xsl:apply-templates select="$ie" mode="replaceStrings"><xsl:with-param name="search" select="'€৳'"/><xsl:with-param name="replace" select="'is'"/></xsl:apply-templates></xsl:variable>
    <!--ium €¥₱-->
    <xsl:variable name="ium"><xsl:apply-templates select="$is" mode="replaceStrings"><xsl:with-param name="search" select="'€¥₱'"/><xsl:with-param name="replace" select="'ium'"/></xsl:apply-templates></xsl:variable>
    <!--min ₱€₭-->
    <xsl:variable name="min"><xsl:apply-templates select="$ium" mode="replaceStrings"><xsl:with-param name="search" select="'₱€₭'"/><xsl:with-param name="replace" select="'min'"/></xsl:apply-templates></xsl:variable>
    <!--orum ¢৲¥₱-->
    <xsl:variable name="orum"><xsl:apply-templates select="$min" mode="replaceStrings"><xsl:with-param name="search" select="'¢৲¥₱'"/><xsl:with-param name="replace" select="'orum'"/></xsl:apply-templates></xsl:variable>
    <!--or ¢৲-->
    <xsl:variable name="or"><xsl:apply-templates select="$orum" mode="replaceStrings"><xsl:with-param name="search" select="'¢৲'"/><xsl:with-param name="replace" select="'or'"/></xsl:apply-templates></xsl:variable>
    <!--ro ৲¢-->
    <xsl:variable name="ro"><xsl:apply-templates select="$or" mode="replaceStrings"><xsl:with-param name="search" select="'৲¢'"/><xsl:with-param name="replace" select="'ro'"/></xsl:apply-templates></xsl:variable>
    <!--sum ৳¥₱-->
    <xsl:variable name="sum"><xsl:apply-templates select="$ro" mode="replaceStrings"><xsl:with-param name="search" select="'৳¥₱'"/><xsl:with-param name="replace" select="'sum'"/></xsl:apply-templates></xsl:variable>
    <!--tum ૱¥₱-->
    <xsl:variable name="tum"><xsl:apply-templates select="$sum" mode="replaceStrings"><xsl:with-param name="search" select="'૱¥₱'"/><xsl:with-param name="replace" select="'tum'"/></xsl:apply-templates></xsl:variable>
    <!--um ¥₱-->
    <xsl:variable name="um"><xsl:apply-templates select="$tum" mode="replaceStrings"><xsl:with-param name="search" select="'¥₱'"/><xsl:with-param name="replace" select="'um'"/></xsl:apply-templates></xsl:variable>
    <!--uo ¥¢-->
    <xsl:variable name="uo"><xsl:apply-templates select="$um" mode="replaceStrings"><xsl:with-param name="search" select="'¥¢'"/><xsl:with-param name="replace" select="'uo'"/></xsl:apply-templates></xsl:variable>
    <!--us ¥৳-->       
    <xsl:variable name="us"><xsl:apply-templates select="$uo" mode="replaceStrings"><xsl:with-param name="search" select="'¥৳'"/><xsl:with-param name="replace" select="'us'"/></xsl:apply-templates></xsl:variable>
    
    <!-- Single Letters -->
    <!--a $-->
    <xsl:variable name="a"><xsl:apply-templates select="$us" mode="replaceStrings"><xsl:with-param name="search" select="'\$'"/><xsl:with-param name="replace" select="'a'"/></xsl:apply-templates></xsl:variable>
    <!--e £-->
    <xsl:variable name="e"><xsl:apply-templates select="$a" mode="replaceStrings"><xsl:with-param name="search" select="'£'"/><xsl:with-param name="replace" select="'e'"/></xsl:apply-templates></xsl:variable>
    <!--i €-->
    <xsl:variable name="i"><xsl:apply-templates select="$e" mode="replaceStrings"><xsl:with-param name="search" select="'€'"/><xsl:with-param name="replace" select="'i'"/></xsl:apply-templates></xsl:variable>
    <!--   o ¢-->
    <xsl:variable name="o"><xsl:apply-templates select="$i" mode="replaceStrings"><xsl:with-param name="search" select="'¢'"/><xsl:with-param name="replace" select="'o'"/></xsl:apply-templates></xsl:variable>
    <!--u ¥-->
    <xsl:variable name="u"><xsl:apply-templates select="$o" mode="replaceStrings"><xsl:with-param name="search" select="'¥'"/><xsl:with-param name="replace" select="'u'"/></xsl:apply-templates></xsl:variable>
    <!--b ₽-->
    <xsl:variable name="b"><xsl:apply-templates select="$u" mode="replaceStrings"><xsl:with-param name="search" select="'₽'"/><xsl:with-param name="replace" select="'b'"/></xsl:apply-templates></xsl:variable>
    <!--c ₯-->
    <xsl:variable name="c"><xsl:apply-templates select="$b" mode="replaceStrings"><xsl:with-param name="search" select="'₯'"/><xsl:with-param name="replace" select="'c'"/></xsl:apply-templates></xsl:variable>
    <!--d ₨-->
    <xsl:variable name="d"><xsl:apply-templates select="$c" mode="replaceStrings"><xsl:with-param name="search" select="'₨'"/><xsl:with-param name="replace" select="'d'"/></xsl:apply-templates></xsl:variable>
    <!--g ₩-->
    <xsl:variable name="g"><xsl:apply-templates select="$d" mode="replaceStrings"><xsl:with-param name="search" select="'₩'"/><xsl:with-param name="replace" select="'g'"/></xsl:apply-templates></xsl:variable>
    <!--h ฿-->
    <xsl:variable name="h"><xsl:apply-templates select="$g" mode="replaceStrings"><xsl:with-param name="search" select="'฿'"/><xsl:with-param name="replace" select="'h'"/></xsl:apply-templates></xsl:variable>
    <!--j ₺-->
    <xsl:variable name="j"><xsl:apply-templates select="$h" mode="replaceStrings"><xsl:with-param name="search" select="'₺'"/><xsl:with-param name="replace" select="'j'"/></xsl:apply-templates></xsl:variable>
    <!--l ₮-->
    <xsl:variable name="l"><xsl:apply-templates select="$j" mode="replaceStrings"><xsl:with-param name="search" select="'₮'"/><xsl:with-param name="replace" select="'l'"/></xsl:apply-templates></xsl:variable>
    <!--m ₱-->
    <xsl:variable name="m"><xsl:apply-templates select="$l" mode="replaceStrings"><xsl:with-param name="search" select="'₱'"/><xsl:with-param name="replace" select="'m'"/></xsl:apply-templates></xsl:variable>
    <!--n ₭-->
    <xsl:variable name="n"><xsl:apply-templates select="$m" mode="replaceStrings"><xsl:with-param name="search" select="'₭'"/><xsl:with-param name="replace" select="'n'"/></xsl:apply-templates></xsl:variable>
    <!--p ₴-->
    <xsl:variable name="p"><xsl:apply-templates select="$n" mode="replaceStrings"><xsl:with-param name="search" select="'₴'"/><xsl:with-param name="replace" select="'p'"/></xsl:apply-templates></xsl:variable>
    <!--q ₦-->
    <xsl:variable name="q"><xsl:apply-templates select="$p" mode="replaceStrings"><xsl:with-param name="search" select="'₦'"/><xsl:with-param name="replace" select="'q'"/></xsl:apply-templates></xsl:variable>
    <!--r ৲-->
    <xsl:variable name="r"><xsl:apply-templates select="$q" mode="replaceStrings"><xsl:with-param name="search" select="'৲'"/><xsl:with-param name="replace" select="'r'"/></xsl:apply-templates></xsl:variable>
    <!--s ৳-->
    <xsl:variable name="s"><xsl:apply-templates select="$r" mode="replaceStrings"><xsl:with-param name="search" select="'৳'"/><xsl:with-param name="replace" select="'s'"/></xsl:apply-templates></xsl:variable>
    <!--t ૱-->
    <xsl:variable name="t"><xsl:apply-templates select="$s" mode="replaceStrings"><xsl:with-param name="search" select="'૱'"/><xsl:with-param name="replace" select="'t'"/></xsl:apply-templates></xsl:variable>
    <!--w ௹-->
    <xsl:variable name="w"><xsl:apply-templates select="$t" mode="replaceStrings"><xsl:with-param name="search" select="'௹'"/><xsl:with-param name="replace" select="'w'"/></xsl:apply-templates></xsl:variable>
<!-- Copy out the final variable -->    
    <xsl:copy-of select="$w"/>
</xsl:template>
    
    
    
    <!-- Root template that kicks everything off.-->
    <xsl:template match="/">
        <!-- Pass 0: replace characters wrapping in <ex> -->
        <xsl:apply-templates mode="pass0"/>
    </xsl:template>

    <!-- Copy everything in every mode -->
    <xsl:template match="@*|node()" mode="pass0 replaceStrings">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
   
    
    <!-- Doing a template on the text() node but only in replaceStrings mode -->
    <xsl:template match="text()" mode="replaceStrings" as="item()*" priority="10">
        <xsl:param name="search"/>
        <xsl:param name="replace"/> 
        <xsl:analyze-string select="." regex="{$search}">
            <xsl:matching-substring><ex n="{$search}"><xsl:value-of select="$replace"/></ex></xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string> 
      
    </xsl:template>
    
    <!-- Have <ex> inside replaceStrings mode only have the character value
<xsl:template match="ex" mode="replaceStrings">
    <ex n="{@n}"><xsl:value-of select="."/></ex>
</xsl:template>-->

    

</xsl:stylesheet>