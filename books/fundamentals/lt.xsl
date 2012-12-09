<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:import href="../../lib/xsl/fo/docbook.xsl"/>

<xsl:param name="paper.type" select="'A4'"/>

<xsl:param name="toc.section.depth" select="'1'"/>
<xsl:param name="toc.max.depth" select="'2'"/>

<xsl:param name="section.autolabel" select="'1'"/>
<xsl:param name="section.autolabel.max.depth" select="'1'"/>
<xsl:param name="section.label.includes.component.label" select="'1'"/>

<xsl:attribute-set name="toc.line.properties">
<xsl:attribute name="font-weight">
 <xsl:choose>
 <xsl:when test="self::part">bold</xsl:when>
 <xsl:otherwise>normal</xsl:otherwise>
 </xsl:choose>
</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="processing-instruction('hard-pagebreak')">
  <fo:block break-after='page'/>
 </xsl:template>

</xsl:stylesheet>
