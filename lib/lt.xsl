<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="../static/xsl/fo/docbook.xsl"/>

<xsl:param name="paper.type" select="'A4'"/>
<xsl:param name="toc.section.depth" select="'3'"/>

<xsl:param name="section.autolabel" select="'1'"/>
<xsl:param name="section.label.includes.component.label" select="'1'"/>

<xsl:attribute-set name="toc.line.properties">
<xsl:attribute name="font-weight">
 <xsl:choose>
  <xsl:when test="self::chapter | self::preface | self::appendix">bold</xsl:when>
  <xsl:otherwise>normal</xsl:otherwise>
 </xsl:choose>
</xsl:attribute>
</xsl:attribute-set>

</xsl:stylesheet>

