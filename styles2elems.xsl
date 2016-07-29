<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		*****************************************************************
		-->

<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
	xmlns:v="urn:schemas-microsoft-com:vml"
	xmlns:w10="urn:schemas-microsoft-com:office:word"
	xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core"
	xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
	xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
	xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
	xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
	exclude-result-prefixes='w v w10 sl aml wx o dt st1'>

<xsl:output indent="no" doctype-system="style-schema.dtd"/>

<!-- MODULES -->

<xsl:include href="block.xsl" />
<xsl:include href="chars.xsl" />
<xsl:include href="css.xsl" />
<xsl:include href="inline.xsl" />
<xsl:include href="notes.xsl" />
<xsl:include href="tables.xsl" />
<xsl:include href="word-utils.xsl" />
<xsl:include href='params.xsl'/>
<xsl:include href='utils.xsl'/>
<xsl:include href='variables.xsl'/>

<xsl:template match="/">
	<Document>
		<xsl:call-template name="xpath-loc">
			<xsl:with-param name="node" select="(w:wordDocument/w:body//w:p)[1]"/>
		</xsl:call-template>
		<!--TODO: <xsl:call-template name='report-missing-stylenames'/> ???-->
		<xsl:if test='$generate-stylename-variables'>
			<xsl:call-template name='generate-stylename-variables'/>
		</xsl:if>

		<!--<xsl:if test='$auto-generate-css'>
			<xsl:call-template name='auto-generate-css'/>
		</xsl:if>
		
		<xsl:if test='$generate-debugging-css'>
			<xsl:call-template name='generate-debugging-css'/>
		</xsl:if>		
				-->
		<xsl:apply-templates select="w:wordDocument/o:SmartTagType[1]"/>
		<xsl:apply-templates select="w:wordDocument/w:body/wx:sect"/>
	</Document>
</xsl:template>

<!--emit style name variable to stderr with the variable name in the format:
	"(para|char).style.StyleName"
where StyleName is the result of removing all spaces from the input 
stylename
	-->
<xsl:template match='w:wordDocument/w:styles/w:style'>
	<xsl:message>
		<xsl:element name='xsl:variable'>
			<xsl:attribute name='name'><xsl:value-of select='substring( @w:type, 1, 4 )'/>.style.<xsl:value-of select='translate( w:name/@w:val, " ", "" )'/></xsl:attribute>
			<xsl:attribute name='select'>'<xsl:value-of select='w:name/@w:val'/>'</xsl:attribute>
		</xsl:element></xsl:message>
</xsl:template>

<xsl:template match="w:body/wx:sect">
	<xsl:if test='w:p/w:pPr/w:sectPr/w:lnNumType'>	<!--line-numbering used?-->
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>+++LINE-NUMBERING USED IN SECTION [<xsl:value-of select='position()'/>]+++</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
		<xsl:choose>
			<xsl:when test="$preserve-section-wrappers">
				<sect>
					<xsl:apply-templates select="w:p/w:pPr/w:sectPr"/>
					<!--include section properties-->
					<xsl:apply-templates/>
				</sect>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
</xsl:template>

<xsl:template match='w:p/w:pPr/w:sectPr'>
	<props><xsl:apply-templates select='w:lnNumType | w:hdr'/></props>
</xsl:template>

<!--SECTION HEADER-->

<xsl:template match='w:p/w:pPr/w:sectPr/w:hdr'>
		<Header type="{@w:type}">
			<xsl:call-template name="xpath-loc">
				<xsl:with-param name="node" select="."/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</Header>
</xsl:template>
	
	<!--SECTION FOOTER-->
	
	<xsl:template match='w:sectPr/w:ftr'>
		<Footer type="{@w:type}">
			<xsl:call-template name="xpath-loc">
				<xsl:with-param name="node" select="."/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</Footer>
	</xsl:template>


<!--LINE NUMBERING-->

<xsl:template match='w:pPr/w:sectPr/w:lnNumType'>	<!--"Represents section properties for section that terminates at this paragraph mark."-->
	<xsl:attribute name='numberLines'>1</xsl:attribute>
	<xsl:apply-templates select='@w:count-by | @w:start | @w:restart'/>
</xsl:template>

<xsl:template match='w:body/w:sectPr/w:lnNumType'>	<!--"Represents the section properties for the very last section in the document."-->
	<!--***TODO***:lnNumType in body-->
</xsl:template>

<xsl:template match='w:lnNumType/@w:count-by | w:lnNumType/@w:start | w:lnNumType/@w:restart'>
	<xsl:attribute name='{local-name()}'><xsl:value-of select='.'/></xsl:attribute>
</xsl:template>

<!--SMART TAGS-->

<!--this node will exist if Smart Tags are switched on-->
<xsl:template match="w:wordDocument/o:SmartTagType[1]">
	<xsl:call-template name="warn">
		<xsl:with-param name="msg" select="'document contains SmartTags'" />
	</xsl:call-template>
	
	<xsl:call-template name="xpath-loc">
		<!--attach it to first non-empty para-->
		<xsl:with-param name="node" select="../w:body/wx:sect/w:p[ normalize-space(.) != '' ][1]" />
		<xsl:with-param name="pi-target" select="'smart-tags-on'" />
	</xsl:call-template>
</xsl:template>

<!--PROOFING ERRORS
		Word still embeds these in WordML, 
		even if they are hidden from view in the application-->
<xsl:template match="w:proofErr[1]">
	<xsl:call-template name="warn">
		<xsl:with-param name="msg" select="'document contains proofing errors'" />
	</xsl:call-template>
	
	<xsl:call-template name="xpath-loc">
		<!--attach it to first non-empty para-->
		<xsl:with-param name="node" select="//w:body/wx:sect/w:p[ normalize-space(.) != '' ][1]" />
		<xsl:with-param name="pi-target" select="'proofing-errs-present'" />
	</xsl:call-template>
</xsl:template>


</xsl:stylesheet>