<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:import href="./xsl/fo/docbook.xsl"/>

<xsl:param name="paper.type" select="'A4'"/>

<xsl:param name="title.margin.left">0pt</xsl:param>
<xsl:param name="body.start.indent">15pt</xsl:param>
<xsl:param name="body.end.indent">0pt</xsl:param>

<xsl:param name="toc.section.depth" select="'1'"/>

<xsl:param name="section.autolabel" select="'1'"/>
<xsl:param name="section.autolabel.max.depth" select="'2'"/>
<xsl:param name="section.label.includes.component.label" select="'1'"/>

<xsl:attribute-set name="toc.line.properties">
<xsl:attribute name="font-weight">
 <xsl:choose>
  <xsl:when test="self::chapter | self::preface | self::appendix">bold</xsl:when>
  <xsl:otherwise>normal</xsl:otherwise>
 </xsl:choose>
</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="processing-instruction('hard-pagebreak')">
   <fo:block break-after='page'/>
 </xsl:template>

<!-- screen tags in cyan 
<xsl:param name="shade.verbatim" select="1"/>
<xsl:attribute-set condition="fo" name="shade.verbatim.style">
  <xsl:attribute name="background-color">#E0FFFF</xsl:attribute>
</xsl:attribute-set>
 screen tags in cyan -->

<!-- screen tags in green -->
<xsl:param name="shade.verbatim" select="1"/>
<xsl:attribute-set condition="fo" name="shade.verbatim.style">
  <xsl:attribute name="background-color">#B3FFB3</xsl:attribute>
</xsl:attribute-set>
 <!--screen tags in green -->

<xsl:template match="para">
  <fo:block font-size="12pt">
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

<xsl:template match="screen">
  <fo:block font-size="9pt">
    <xsl:apply-imports/>
  </fo:block>
</xsl:template>

</xsl:stylesheet>
