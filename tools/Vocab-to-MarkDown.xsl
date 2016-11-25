<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx"
  xmlns:edm="http://docs.oasis-open.org/odata/ns/edm" exclude-result-prefixes="edmx edm"
>
  <!--
    This style sheet transforms OData 4.0 XML Vocabulary documents into GitHub-Flavored MarkDown (GFM)

    TODO:
    - special annotations: AllowedValues, IsUrl, IsMediaType?
  -->

  <xsl:output method="html" indent="no" encoding="UTF-8" omit-xml-declaration="yes" />

  <xsl:variable name="coreNamespace" select="'Org.OData.Core.V1'" />
  <xsl:variable name="coreAlias"
    select="//edmx:Include[@Namespace=$coreNamespace]/@Alias|//edm:Schema[@Namespace=$coreNamespace]/@Alias" />
  <xsl:variable name="coreDescription" select="concat($coreNamespace,'.Description')" />
  <xsl:variable name="coreDescriptionAliased" select="concat($coreAlias,'.Description')" />
  <xsl:variable name="coreLongDescription" select="concat($coreNamespace,'.LongDescription')" />
  <xsl:variable name="coreLongDescriptionAliased" select="concat($coreAlias,'.LongDescription')" />

  <xsl:variable name="commonNamespace" select="'com.sap.vocabularies.Common.v1'" />
  <xsl:variable name="commonAlias"
    select="//edmx:Include[@Namespace=$commonNamespace]/@Alias|//edm:Schema[@Namespace=$commonNamespace]/@Alias" />
  <xsl:variable name="commonLabel" select="concat($commonNamespace,'.Label')" />
  <xsl:variable name="commonLabelAliased" select="concat($commonAlias,'.Label')" />

  <xsl:template name="Core.Description">
    <xsl:param name="node" />
    <xsl:variable name="description"
      select="$node/edm:Annotation[(@Term=$coreDescription or @Term=$coreDescriptionAliased) and not(@Qualifier)]/@String|$node/edm:Annotation[(@Term=$coreDescription or @Term=$coreDescriptionAliased) and not(@Qualifier)]/edm:String" />
    <xsl:call-template name="escape">
      <xsl:with-param name="string" select="normalize-space($description)" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="Core.LongDescription">
    <xsl:param name="node" />
    <xsl:variable name="description"
      select="$node/edm:Annotation[(@Term=$coreLongDescription or @Term=$coreLongDescriptionAliased) and not(@Qualifier)]/@String|$node/edm:Annotation[(@Term=$coreLongDescription or @Term=$coreLongDescriptionAliased) and not(@Qualifier)]/edm:String" />
    <xsl:call-template name="escape">
      <xsl:with-param name="string" select="normalize-space($description)" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="Core-Annotation">
    <xsl:param name="node" />
    <xsl:param name="term" />
    <xsl:value-of
      select="$node/edm:Annotation[(@Term=concat('Org.OData.Core.V1.',$term) or @Term=concat($coreAlias,'.',$term)) and not(@Qualifier)]|$node/edm:Annotation[(@Term=concat('Org.OData.Core.V1.',$term) or @Term=concat($coreAlias,'.',$term)) and not(@Qualifier)]" />
  </xsl:template>

  <xsl:template name="Common.Label">
    <xsl:param name="node" />
    <xsl:variable name="label"
      select="$node/edm:Annotation[(@Term=$commonLabel or @Term=$commonLabelAliased) and not(@Qualifier)]/@String|$node/edm:Annotation[(@Term=$commonLabel or @Term=$commonLabelAliased) and not(@Qualifier)]/edm:String" />
    <xsl:value-of select="normalize-space($label)" />
  </xsl:template>


  <xsl:template match="edmx:Edmx">
    <xsl:text># </xsl:text>
    <xsl:call-template name="substring-after-last">
      <xsl:with-param name="input">
        <xsl:call-template name="substring-before-last">
          <xsl:with-param name="input" select="//edm:Schema/@Namespace" />
          <xsl:with-param name="marker" select="'.'" />
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="marker" select="'.'" />
    </xsl:call-template>
    <xsl:text> Vocabulary</xsl:text>
    <xsl:text>&#xA;</xsl:text>

    <xsl:text>**Namespace: [</xsl:text>
    <xsl:value-of select="//edm:Schema/@Namespace" />
    <xsl:text>](</xsl:text>
    <xsl:value-of select="//edm:Schema/@Namespace" />
    <xsl:text>.xml)**&#xA;&#xA;</xsl:text>

    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="//edm:Schema" />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>

    <!--
      <p>
      <xsl:call-template name="Core.LongDescription">
      <xsl:with-param name="node" select="//edm:Schema" />
      </xsl:call-template>
      </p>
    -->

    <xsl:apply-templates select="//edm:Term" />

    <xsl:apply-templates select="//edm:ComplexType|//edm:EnumType|//edm:TypeDefinition" />
  </xsl:template>

  <xsl:template match="edm:Term">
    <xsl:if test="position()=1">
      <xsl:text>&#xA;Term|Type|Description</xsl:text>
      <xsl:text>&#xA;----|----|-----------&#xA;</xsl:text>
    </xsl:if>
    <xsl:value-of select="@Name" />
    <xsl:text>|</xsl:text>
    <xsl:call-template name="type-link">
      <xsl:with-param name="type" select="@Type" />
    </xsl:call-template>

    <xsl:text>|</xsl:text>
    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="edm:ComplexType">
    <xsl:text>&#xA;## </xsl:text>
    <a>
      <xsl:attribute name="name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>
    </a>
    <xsl:if test="@Abstract='true'">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:value-of select="@Name" />
    <xsl:if test="@Abstract='true'">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:if test="@BaseType">
      <xsl:text>: </xsl:text>
      <xsl:call-template name="type-link">
        <xsl:with-param name="type" select="@BaseType" />
      </xsl:call-template>
    </xsl:if>
    <xsl:text>&#xA;</xsl:text>

    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>

    <xsl:variable name="namespaceQualifiedName" select="concat(../@Namespace,'.',@Name)" />
    <xsl:variable name="aliasQualifiedName" select="concat(../@Alias,'.',@Name)" />
    <xsl:if test="//edm:ComplexType[@BaseType=$namespaceQualifiedName or @BaseType=$aliasQualifiedName]">
      <xsl:text>&#xA;**Derived Types:**&#xA;</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="//edm:ComplexType[@BaseType=$namespaceQualifiedName or @BaseType=$aliasQualifiedName]"
      mode="inheritance" />

    <!-- TODO
      <xsl:apply-templates select="edm:Property" />
    -->
    <xsl:variable name="properties">
      <xsl:call-template name="properties">
        <xsl:with-param name="complexType" select="." />
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$properties">
      <xsl:text>&#xA;Property|Type|Description</xsl:text>
      <xsl:text>&#xA;--------|----|-----------&#xA;</xsl:text>
      <xsl:value-of select="$properties" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="edm:ComplexType" mode="inheritance">
    <xsl:param name="indent" select="''" />
    <xsl:value-of select="$indent" />
    <xsl:text>- </xsl:text>
    <xsl:if test="@Abstract='true'">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:call-template name="type-link">
      <xsl:with-param name="type" select="concat(../@Namespace,'.',@Name)" />
    </xsl:call-template>
    <xsl:if test="@Abstract='true'">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:text>&#xA;</xsl:text>

    <xsl:variable name="namespaceQualifiedName" select="concat(../@Namespace,'.',@Name)" />
    <xsl:variable name="aliasQualifiedName" select="concat(../@Alias,'.',@Name)" />
    <xsl:apply-templates select="//edm:ComplexType[@BaseType=$namespaceQualifiedName or @BaseType=$aliasQualifiedName]"
      mode="inheritance"
    >
      <xsl:with-param name="indent" select="concat($indent,'  ')" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="properties">
    <xsl:param name="complexType" />
    <xsl:param name="parent" select="false()" />
    <xsl:if test="$complexType/@BaseType">
      <xsl:variable name="qualifier">
        <xsl:call-template name="substring-before-last">
          <xsl:with-param name="input" select="$complexType/@BaseType" />
          <xsl:with-param name="marker" select="'.'" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="name">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="input" select="$complexType/@BaseType" />
          <xsl:with-param name="marker" select="'.'" />
        </xsl:call-template>
      </xsl:variable>
      <!-- recurse to base type -->
      <xsl:call-template name="properties">
        <xsl:with-param name="complexType"
          select="//edm:Schema[@Namespace=$qualifier or @Alias=$qualifier]/edm:ComplexType[@Name=$name]" />
        <xsl:with-param name="parent" select="true()" />
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="$complexType/edm:Property">
      <xsl:with-param name="parent" select="$parent" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="edm:Property">
    <xsl:param name="parent" />
    <xsl:if test="$parent">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:value-of select="@Name" />
    <xsl:if test="$parent">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:text>|</xsl:text>
    <xsl:call-template name="type-link">
      <xsl:with-param name="type" select="@Type" />
    </xsl:call-template>
    <xsl:text>|</xsl:text>
    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="edm:EnumType">
    <xsl:text>&#xA;## </xsl:text>
    <a>
      <xsl:attribute name="name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>
    </a>
    <xsl:value-of select="@Name" />
    <xsl:text>&#xA;</xsl:text>

    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>

    <!-- TODO: @IsFlags, @UnderlyingType? -->

    <xsl:apply-templates select="edm:Member" />
  </xsl:template>

  <xsl:template match="edm:Member">
    <xsl:if test="position()=1">
      <xsl:text>&#xA;Member|Value|Description</xsl:text>
      <xsl:text>&#xA;------|----:|-----------&#xA;</xsl:text>
    </xsl:if>
    <xsl:value-of select="@Name" />
    <xsl:text>|</xsl:text>
    <xsl:choose>
      <xsl:when test="@Value">
        <xsl:value-of select="@Value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="position()-1" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>|</xsl:text>
    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="edm:TypeDefinition">
    <xsl:text>&#xA;## </xsl:text>
    <a>
      <xsl:attribute name="name">
        <xsl:value-of select="@Name" />
      </xsl:attribute>
    </a>
    <xsl:value-of select="@Name" />
    <xsl:text>&#xA;**Type:** </xsl:text>
    <xsl:call-template name="type-link">
      <xsl:with-param name="type" select="@UnderlyingType" />
    </xsl:call-template>
    <xsl:text>&#xA;&#xA;</xsl:text>

    <xsl:call-template name="Core.Description">
      <xsl:with-param name="node" select="." />
    </xsl:call-template>
    <xsl:text>&#xA;</xsl:text>

    <!-- TODO: facets? -->
    <!-- TODO: annotations -->
  </xsl:template>

  <xsl:template name="type-link">
    <xsl:param name="type" />
    <xsl:variable name="collection" select="starts-with($type,'Collection(')" />
    <xsl:variable name="singleType">
      <xsl:choose>
        <xsl:when test="$collection">
          <xsl:value-of select="substring-before(substring-after($type,'('),')')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$type" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="qualifier">
      <xsl:call-template name="substring-before-last">
        <xsl:with-param name="input" select="$singleType" />
        <xsl:with-param name="marker" select="'.'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="type">
      <xsl:call-template name="substring-after-last">
        <xsl:with-param name="input" select="$singleType" />
        <xsl:with-param name="marker" select="'.'" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$collection">
      <xsl:text>\[</xsl:text>
    </xsl:if>
    <!-- TODO: create hyperlink locally or externally -->
    <xsl:choose>
      <xsl:when test="$qualifier='Edm'">
        <xsl:value-of select="$type" />
      </xsl:when>
      <xsl:when test="$qualifier=ancestor::edm:Schema/@Alias or $qualifier=ancestor::edm:Schema/@Namespace">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$type" />
        <xsl:text>](#</xsl:text>
        <xsl:value-of select="$type" />
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="$qualifier=//edmx:Include/@Alias or $qualifier=//edmx:Include/@Namespace">
        <xsl:variable name="namespace">
          <xsl:choose>
            <xsl:when test="$qualifier=//edmx:Include/@Alias">
              <xsl:value-of select="//edmx:Include[@Alias=$qualifier]/@Namespace" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$qualifier" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="$type" />
        <xsl:text>](</xsl:text>
        <xsl:value-of select="$namespace" />
        <xsl:text>.md#</xsl:text>
        <xsl:value-of select="$type" />
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>??</xsl:text>
        <xsl:value-of select="$type" />
        <xsl:text>??</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$collection">
      <xsl:text>\]</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- helper functions -->
  <xsl:template name="substring-before-last">
    <xsl:param name="input" />
    <xsl:param name="marker" />
    <xsl:if test="contains($input,$marker)">
      <xsl:value-of select="substring-before($input,$marker)" />
      <xsl:if test="contains(substring-after($input,$marker),$marker)">
        <xsl:value-of select="$marker" />
        <xsl:call-template name="substring-before-last">
          <xsl:with-param name="input" select="substring-after($input,$marker)" />
          <xsl:with-param name="marker" select="$marker" />
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="substring-after-last">
    <xsl:param name="input" />
    <xsl:param name="marker" />
    <xsl:choose>
      <xsl:when test="contains($input,$marker)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="input" select="substring-after($input,$marker)" />
          <xsl:with-param name="marker" select="$marker" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="escape">
    <xsl:param name="string" />
    <xsl:choose>
      <xsl:when test="contains($string,'|')">
        <xsl:call-template name="escape-one">
          <xsl:with-param name="string" select="$string" />
          <xsl:with-param name="old" select="'|'" />
          <xsl:with-param name="new" select="'\|'" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="escape-one">
    <xsl:param name="string" />
    <xsl:param name="old" />
    <xsl:param name="new" />
    <xsl:call-template name="escape">
      <xsl:with-param name="string" select="substring-before($string,$old)" />
    </xsl:call-template>
    <xsl:value-of select="$new" />
    <xsl:call-template name="escape">
      <xsl:with-param name="string" select="substring-after($string,$old)" />
    </xsl:call-template>
  </xsl:template>


</xsl:stylesheet>