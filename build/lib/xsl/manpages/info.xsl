<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="date exsl"
                version='1.0'>

<!-- ********************************************************************
     $Id: info.xsl 7087 2007-07-19 07:20:38Z xmldoc $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://docbook.sf.net/release/xsl/current/ for
     copyright and other information.

     ******************************************************************** -->

  <xsl:variable name="blurb-indent">
    <xsl:choose>
      <xsl:when test="not($man.indent.blurbs = 0)">
        <xsl:value-of select="$man.indent.width"/>
      </xsl:when>
      <xsl:when test="not($man.indent.refsect = 0)">
        <!-- * "zq" is the name of a register we set for -->
        <!-- * preserving the original default indent value -->
        <!-- * when $man.indent.refsect is non-zero; -->
        <!-- * "u" is a roff unit specifier -->
        <xsl:text>\n(zqu</xsl:text>
      </xsl:when>
      <xsl:otherwise/> <!-- * otherwise, just leave it empty -->
    </xsl:choose>
  </xsl:variable>

  <!-- ================================================================== -->
  <!-- * About the $info param used in this stylesheet -->
  <!-- * -->
  <!-- * The $info param is a "master info" node set that contains -->
  <!-- * the entire contents of the *info child of the current -->
  <!-- * Refentry, plus the entire contents of the *info children of -->
  <!-- * all ancestors of the current Refentry, in document order. -->
  <!-- * -->
  <!-- * We try to find a "best match" for selecting content from -->
  <!-- * $infor; we look through it in reverse document order until we -->
  <!-- * can find something usable. -->
  <!-- * -->
  <!-- * Specifically what the basic metadata-gathering XPath expression -->
  <!-- * in this stylesheet does is: -->
  <!-- * -->
  <!-- *   1. Look through the entire "master info" node set.-->
  <!-- *   2. Get the last node in the set that contains, for -->
  <!-- *      example, an Author element. That amounts to being the -->
  <!-- *      closest *info node to the Refentry - either its *info -->
  <!-- *      child, or the *info node of its closest ancestor that -->
  <!-- *      contains an Author. -->

  <!-- ================================================================== -->
  <!-- * Get user "refentry metadata" preferences -->
  <!-- ================================================================== -->
  <!-- * The DocBook XSL stylesheets include several user-configurable -->
  <!-- * global stylesheet parameters for controlling refentry metadata -->
  <!-- * gathering. Those parameters are not read directly by the other -->
  <!-- * refentry metadata-gathering templates. Instead, they are read -->
  <!-- * only by the get.refentry.metadata.prefs template, which -->
  <!-- * assembles them into a structure that is then passed to the -->
  <!-- * other refentry metadata-gathering template. -->

  <xsl:variable name="get.refentry.metadata.prefs">
    <!-- * get.refentry.metadata.prefs is in common/refentry.xsl -->
    <xsl:call-template name="get.refentry.metadata.prefs"/>
  </xsl:variable>

  <xsl:variable name="refentry.metadata.prefs"
                select="exsl:node-set($get.refentry.metadata.prefs)"/>
  
  <!-- * ============================================================== -->
  <!-- *    Get content for Author metadata field. -->
  <!-- * ============================================================== -->

  <!-- * The make.roff.metatada.author template and metadata.author -->
  <!-- * mode are used only for populating the Author field in the -->
  <!-- * metadata "top comment" we embed in roff source of each page. -->

  <xsl:template name="make.roff.metadata.author">
    <xsl:param name="info"/>
    <xsl:choose>
      <xsl:when test="$info//author">
        <xsl:apply-templates
            select="(($info[//author])[last()]//author)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//corpauthor">
        <xsl:apply-templates
            select="(($info[//corpauthor])[last()]//corpauthor)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//editor">
        <xsl:apply-templates
            select="(($info[//editor])[last()]//editor)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//corpcredit">
        <xsl:apply-templates
            select="(($info[//corpcredit])[last()]//corpcredit)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//othercredit">
        <xsl:apply-templates
            select="(($info[//othercredit])[last()]//othercredit)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//collab">
        <xsl:apply-templates
            select="(($info[//collab])[last()]//collab)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//orgname">
        <xsl:apply-templates
            select="(($info[//orgname])[last()]//orgname)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:when test="$info//publishername">
        <xsl:apply-templates
            select="(($info[//publishername])[last()]//publishername)[1]"
            mode="metadata.author"/>
      </xsl:when>
      <xsl:otherwise/> <!-- * do nothing, no author info found -->
    </xsl:choose>
  </xsl:template>

  <xsl:template match="author|editor|othercredit|collab" mode="metadata.author">
    <xsl:choose>
      <xsl:when test="collabname">
        <!-- * If this node is a Collab, then it should have a -->
        <!-- * Collabname child, so get that. -->
        <xsl:variable name="contents">
          <xsl:apply-templates select="collabname"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($contents)"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- * Otherwise, this node is not a Collab, but instead -->
        <!-- * an author|editor|othercredit, which must have a name -->
        <!-- * of some kind; so get that name -->
        <xsl:call-template name="person.name.normalized"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test=".//email|address/otheraddr/ulink">
      <xsl:text> </xsl:text>
      <!-- * For each attribution found, use only the first e-mail -->
      <!-- * address or ulink value found -->
      <xsl:apply-templates select="(.//email|address/otheraddr/ulink)[1]"
                           mode="metadata.author"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="email|address/otheraddr/ulink" mode="metadata.author">
    <xsl:text>&lt;</xsl:text>
    <xsl:choose>
      <xsl:when test="self::email">
        <xsl:variable name="contents">
          <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($contents)"/>
      </xsl:when>
      <xsl:when test="self::ulink">
        <xsl:variable name="contents">
          <xsl:apply-templates select="."/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($contents)"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="corpauthor|corpcredit|orgname|publishername" mode="metadata.author">
    <xsl:variable name="contents">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($contents)"/>
  </xsl:template>

  <!-- * ============================================================== -->
  <!-- *     Assemble the AUTHOR/AUTHORS section -->
  <!-- * ============================================================== -->

  <xsl:template name="author.section">
    <xsl:param name="info"/>
    <!-- * The $info param is a "master info" node set that contains -->
    <!-- * the entires contents of the *info child of the current -->
    <!-- * Refentry, plus the entire contents of the *info children of -->
    <!-- * all ancestors of the current Refentry, in document order. -->
    <xsl:choose>
      <xsl:when test="$info//author|$info//editor|$info//collab|
                      $info//corpauthor|$info//corpcredit|
                      $info//othercredit|$info/orgname|
                      $info/publishername|$info/publisher">
        <xsl:variable name="authorcount">
          <xsl:value-of
              select="count(
                      $info//author|$info//editor|$info//collab|
                      $info//corpauthor|$info//corpcredit|
                      $info//othercredit)">
          </xsl:value-of>
        </xsl:variable>
        <xsl:text>.SH "</xsl:text>
        <xsl:call-template name="make.authorsecttitle">
          <xsl:with-param name="authorcount" select="$authorcount"/>
        </xsl:call-template>
        <!-- * Now output all the actual author, editor, etc. content -->
        <xsl:for-each
            select="$info//author|$info//editor|$info//collab|
                    $info//corpauthor|$info//corpcredit|
                    $info//othercredit|$info/orgname|
                    $info/publishername|$info/publisher">
          <xsl:apply-templates select="." mode="authorsect"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise/> <!-- * do nothing, no author info found -->
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make.authorsecttitle">
    <!-- * If we have exactly one attributable person/entity, then output -->
    <!-- * localized gentext for 'Author'; otherwise, output 'Authors'. -->
    <xsl:param name="authorcount"/>
    <xsl:param name="authorsecttitle">
      <xsl:choose>
        <xsl:when test="$authorcount = 1">
          <xsl:text>Author</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Authors</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:call-template name="string.upper">
      <xsl:with-param name="string">
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="$authorsecttitle"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>"&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="author|editor|othercredit" mode="authorsect">
    <xsl:variable name="person-name">
      <xsl:call-template name="person.name.normalized"/>
    </xsl:variable>
    <!-- * If we have a person-name or email or ulink content, then -->
    <!-- * output name and email or ulink content on the same line -->
    <xsl:choose>
      <xsl:when test="not($person-name = '') or .//email or address/otheraddr/ulink">
        <xsl:text>.PP&#10;</xsl:text>
        <!-- * Display person name in bold -->
        <xsl:call-template name="bold">
          <xsl:with-param name="node" select="exsl:node-set($person-name)"/>
          <xsl:with-param name="context" select="."/>
        </xsl:call-template>
        <!-- * Display e-mail address(es) and ulink(s) on same line as name -->
        <xsl:apply-templates select=".//email|address/otheraddr/ulink" mode="authorsect"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>.br&#10;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <!-- * Display affiliation(s) on separate lines -->
    <xsl:apply-templates select="affiliation" mode="authorsect"/>
    <!-- * Display direct-child addresses on separate lines -->
    <xsl:apply-templates select="address" mode="authorsect"/>
    <!-- * Call template for handling various attribution possibilities -->
    <xsl:call-template name="attribution"/>
  </xsl:template>

  <xsl:template match="collab" mode="authorsect">
    <xsl:text>.PP&#10;</xsl:text>
    <xsl:call-template name="bold">
      <xsl:with-param name="node" select="collabname"/>
      <xsl:with-param name="context" select="."/>
    </xsl:call-template>
    <!-- * Display e-mail address(es) and ulink(s) on same line as name -->
    <xsl:apply-templates select=".//email|address/otheraddr/ulink" mode="authorsect"/>
    <xsl:text>&#10;</xsl:text>
    <!-- * Display affilition(s) on separate lines -->
    <xsl:apply-templates select="affiliation" mode="authorsect"/>
  </xsl:template>

  <xsl:template match="corpauthor|corpcredit|orgname|publishername" mode="authorsect">
    <xsl:text>.PP&#10;</xsl:text>
    <xsl:call-template name="bold">
      <xsl:with-param name="node" select="."/>
      <xsl:with-param name="context" select="."/>
    </xsl:call-template>
    <xsl:text>&#10;</xsl:text>
    <xsl:if test="self::publishername">
      <!-- * Display localized "Publisher" gentext -->
      <xsl:call-template name="publisher.attribution"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="publisher" mode="authorsect">
    <xsl:text>.PP&#10;</xsl:text>
    <xsl:call-template name="bold">
      <xsl:with-param name="node" select="publishername"/>
      <xsl:with-param name="context" select="."/>
    </xsl:call-template>
    <!-- * Display e-mail address(es) and ulink(s) on same line as name -->
    <xsl:apply-templates select=".//email|address/otheraddr/ulink" mode="authorsect"/>
    <!-- * Display addresses on separate lines -->
    <xsl:apply-templates select="address" mode="authorsect"/>
    <!-- * Display localized "Publisher" literal -->
    <xsl:call-template name="publisher.attribution"/>
  </xsl:template>

  <xsl:template name="publisher.attribution">
    <xsl:text>&#10;</xsl:text>
    <xsl:text>.sp -1n&#10;</xsl:text>
    <xsl:text>.IP ""</xsl:text> 
    <xsl:if test="not($blurb-indent = '')">
      <xsl:text> </xsl:text>
      <xsl:value-of select="$blurb-indent"/>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <xsl:call-template name="gentext">
      <xsl:with-param name="key" select="'Publisher'"/>
    </xsl:call-template>
    <xsl:text>.&#10;</xsl:text>
  </xsl:template>

  <xsl:template match="email|address/otheraddr/ulink" mode="authorsect">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[descendant-or-self::email]
                      or preceding-sibling::address/otheraddr/ulink
                      or ancestor::address[preceding-sibling::*[descendant-or-self::email]]
                      or ancestor::address[preceding-sibling::address/otheraddr/ulink]">
        <!-- * This is not the first instance, so do nothing. -->
      </xsl:when>
      <xsl:otherwise>
        <!-- * This is first instances of an e-mail address or ulink, -->
        <!-- * so put a space before it. -->
        <xsl:text> </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <!-- * Note that the reason for the \& character after the opening -->
    <!-- * angle bracket and before the closing angle bracket is to -->
    <!-- * prevent groff from inserting a linebreak at those points and -->
    <!-- * outputting a hyphen character where the break occurs -->
    <xsl:text>&lt;\&amp;</xsl:text>
    <xsl:choose>
      <xsl:when test="self::email">
        <xsl:variable name="contents">
          <xsl:apply-templates/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($contents)"/>
      </xsl:when>
      <xsl:when test="self::ulink">
        <xsl:variable name="contents">
          <xsl:apply-templates select="."/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($contents)"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>\&amp;&gt;</xsl:text>
    <xsl:choose>
      <xsl:when test="not(following-sibling::*[descendant-or-self::email]
                      or following-sibling::address/otheraddr/ulink
                      or ancestor::address[following-sibling::*[descendant-or-self::email]]
                      or ancestor::address[following-sibling::address/otheraddr/ulink])">
        <!-- * This is the final instance, so do nothing. -->
      </xsl:when>
      <xsl:otherwise>
        <!-- * Separate multiple e-mail addresses or ulinks with a comma -->
        <xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="affiliation" mode="authorsect">
    <!-- * Get the string value of the contents of this Affiliation. If the -->
    <!-- * affiliation only contains an Address child whose only content is -->
    <!-- * an email address or ulink, then these contents will end up empty. -->
    <xsl:variable name="contents">
      <xsl:apply-templates mode="authorsect"/>
    </xsl:variable>
    <!-- * If contents are actually empty except for an email address -->
    <!-- * or ulink, then output nothing. -->
    <xsl:if test="$contents != ''">
      <xsl:text>.br&#10;</xsl:text>
      <xsl:for-each select="shortaffil|jobtitle|orgname|orgdiv|address">
        <!-- * only display output of nodes other than email or ulink -->
        <xsl:apply-templates select="node()[not(self::email) and not(self::otheraddr/ulink)]"/>
        <xsl:choose>
          <xsl:when test="position() = last()"/> <!-- do nothing -->
          <xsl:otherwise>
            <!-- * only add comma if the node has a child node other than -->
            <!-- * an email address or ulink -->
            <xsl:if test="child::node()[not(self::email) and not(self::otheraddr/ulink)]">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:text>&#10;</xsl:text>
      <xsl:choose>
        <xsl:when test="position() = last()"/> <!-- do nothing -->
        <xsl:otherwise>
          <!-- * put a line break after every Affiliation instance except -->
          <!-- * the last one in the set -->
          <xsl:text>.br&#10;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="address" mode="authorsect">
    <xsl:variable name="contents"
                  select="normalize-space(node()[not(self::email)
                          and not(self::otheraddr/ulink)])"/>
    <!-- * If this contents of this Address do not contain anything except -->
    <!-- * an email address or ulink, then output nothing. -->
    <xsl:if test="$contents != ''">
      <xsl:text>&#10;</xsl:text>
      <xsl:text>.br&#10;</xsl:text>
      <!--* Skip email and ulink descendants of Address (rendered elsewhere) -->
      <xsl:apply-templates select="node()[not(self::email) and not(self::otheraddr/ulink)]"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="attribution">
    <!-- * Determine appropriate attribution for a particular person's role. -->
    <xsl:choose>
      <!-- * if we have a *blurb or contrib, just use that -->
      <xsl:when test="contrib|personblurb|authorblurb">
        <xsl:apply-templates select="contrib|personblurb|authorblurb" mode="authorsect"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:when>
      <!-- * If we have no *blurb or contrib, but this is an Author or -->
      <!-- * Editor, then render the corresponding localized gentext -->
      <xsl:when test="self::author">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>.sp -1n&#10;</xsl:text>
        <xsl:text>.IP ""</xsl:text> 
        <xsl:if test="not($blurb-indent = '')">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$blurb-indent"/>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'Author'"/>
        </xsl:call-template>
        <xsl:text>.&#10;</xsl:text>
      </xsl:when>
      <xsl:when test="self::editor">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>.sp -1n&#10;</xsl:text>
        <xsl:text>.IP ""</xsl:text> 
        <xsl:if test="not($blurb-indent = '')">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$blurb-indent"/>
        </xsl:if>
        <xsl:text>&#10;</xsl:text>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key" select="'Editor'"/>
        </xsl:call-template>
        <xsl:text>.&#10;</xsl:text>
      </xsl:when>
      <!-- * If we have no *blurb or contrib, but this is an Othercredit, -->
      <!-- * check value of Class attribute and use corresponding gentext. -->
      <xsl:when test="self::othercredit">
        <xsl:choose>
          <xsl:when test="@class and @class != 'other'">
            <xsl:text>&#10;</xsl:text>
            <xsl:text>.sp -1n&#10;</xsl:text>
            <xsl:text>.IP ""</xsl:text> 
            <xsl:if test="not($blurb-indent = '')">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$blurb-indent"/>
            </xsl:if>
            <xsl:text>&#10;</xsl:text>
            <xsl:call-template name="gentext">
              <xsl:with-param name="key" select="@class"/>
            </xsl:call-template>
            <xsl:text>.&#10;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- * We have an Othercredit, but not usable value for the Class -->
            <!-- * attribute, so nothing to show, do nothing -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- * We have no *blurb or contrib or anything else we can use to -->
        <!-- * display appropriate attribution for this person, so do nothing -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="personblurb|authorblurb" mode="authorsect">
    <xsl:call-template name="mark.up.blurb.or.contrib"/>
    <!-- * yeah, it's possible for a *blurb to have a "title" -->
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="*[not(self::title)]"/>
  </xsl:template>

  <xsl:template match="personblurb/title|authorblurb/title">
    <!-- * always render period after title -->
    <xsl:variable name="contents">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($contents)"/>
    <xsl:text>.</xsl:text>
    <!-- * render space after Title+period if the title is followed -->
    <!-- * by something element content -->
    <xsl:if test="following-sibling::*[name() != '']">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="contrib" mode="authorsect">
    <xsl:call-template name="mark.up.blurb.or.contrib"/>
    <xsl:variable name="contents">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($contents)"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <xsl:template name="mark.up.blurb.or.contrib">
    <xsl:choose>
      <!-- * If this *blurb has a sibling "name" element of some kind, then -->
      <!-- * we are already outputting the name content, and we need to -->
      <!-- * indent the *blurb content after that. -->
      <xsl:when
          test="../personname|../surname|../firstname
                |../othername|../lineage|../honorific
                |../affiliation|../email|../address">
        <xsl:text>&#10;</xsl:text>
        <xsl:text>.sp -1n&#10;</xsl:text>
        <xsl:text>.IP ""</xsl:text> 
        <xsl:if test="not($blurb-indent = '')">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$blurb-indent"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <!-- * otherwise, we have no "name" content, so don't indent; -->
        <!-- * instead, decide if we need a .PP or just a .br -->
        <xsl:choose>
          <xsl:when test="not(preceding-sibling::*)">
            <!-- * if this *blurb or contrib has no preceding -->
            <!-- * siblings, then we need to start a new paragraph -->
            <xsl:text>.PP</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <!-- * otherwise, this has no preceding siblings, so -->
            <!-- * just put a linebreak -->
            <xsl:text>.br</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- * ============================================================== -->
  <!-- *     Assemble the COPYRIGHT section -->
  <!-- * ============================================================== -->
  <!-- * The COPYRIGHT section is output only if a copyright or -->
  <!-- * legalnotice is found. It contains the copyright contents -->
  <!-- * followed by the legalnotice contents. -->
  <xsl:template name="copyright.section">
    <xsl:param name="info"/>
    <xsl:choose>
      <xsl:when test="$info//copyright|$info//legalnotice">
        <xsl:text>.SH "</xsl:text>
        <xsl:call-template name="string.upper">
          <xsl:with-param name="string">
            <xsl:call-template name="gentext">
              <xsl:with-param name="key">Copyright</xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>"&#10;</xsl:text>
        <!-- * the copyright mode="titlepage.mode" template is -->
        <!-- * imported from the HTML stylesheets -->
        <xsl:for-each select="
          (($info[//copyright])[last()]//copyright)
          | (($info[//legalnotice])[last()]//legalnotice)">
          <xsl:choose>
            <xsl:when test="local-name(.) = 'copyright'">
              <xsl:variable name="contents">
                <xsl:apply-templates select="." mode="titlepage.mode"/>
              </xsl:variable>
              <xsl:value-of select="normalize-space($contents)"/>
              <xsl:text>&#10;</xsl:text>
              <xsl:text>.br&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="titlepage.mode"/>
              <xsl:text>&#10;</xsl:text>
              <xsl:text>.sp&#10;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise/> <!-- * do nothing, no copyright or legalnotice found -->
    </xsl:choose>
  </xsl:template>

  <xsl:template match="legalnotice">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- * ============================================================== -->

  <!-- * suppress refmeta and all *info (we grab what we need from them -->
  <!-- * elsewhere) -->

  <xsl:template match="refmeta"/>

  <xsl:template match="info|refentryinfo|referenceinfo|refsynopsisdivinfo
                       |refsectioninfo|refsect1info|refsect2info|refsect3info
                       |setinfo|bookinfo|articleinfo|chapterinfo|sectioninfo
                       |sect1info|sect2info|sect3info|sect4info|sect5info
                       |partinfo|prefaceinfo|appendixinfo|docinfo"/>

  <!-- ============================================================== -->
  
</xsl:stylesheet>
