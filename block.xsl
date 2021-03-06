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
  version="1.1"
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


<!--only process paragraphs with content (i.e. w:r children)-->
<xsl:template match="w:p[ w:r ]">
	<p>
		<xsl:apply-templates select='w:pPr/w:pStyle/@w:val'/>
		<!--xpath locator in a PI-->
		<xsl:call-template name="xpath-loc">
			<xsl:with-param name="node" select="." />
		</xsl:call-template>		
		<xsl:apply-templates select='w:pPr'/>
		<xsl:apply-templates select='w:r | w:fldSimple | w:hlink'/>
	</p>
</xsl:template>

<!--exceptions: elements which have no string content, but are required for 
onward transformations-->
<xsl:template match="w:p[ not( w:r ) ]">
	<xsl:variable name="style">
		<xsl:call-template name="get-stylename">
			<xsl:with-param name='styleId' select="w:pPr/w:pStyle/@w:val"/>
		</xsl:call-template>	
	</xsl:variable>
	
	
		<p style='{$style}'/>
	
</xsl:template>

<!--sets the para style-->
<xsl:template match="w:pPr/w:pStyle/@w:val">
	<xsl:attribute name="style">
		<xsl:call-template name="get-stylename">
			<xsl:with-param name='styleId' select="."/>
		</xsl:call-template>
	</xsl:attribute>
</xsl:template>

<xsl:template match="w:pPr">
	<!--do nothing-->
</xsl:template>

<!--OTHER-->

<xsl:template match="w:pict">
	<xsl:if test="v:rect/@o:hr='t'">	<!--horizontal rules: these will appear as child of p-->
		<hr>
			<xsl:copy-of select="v:rect/@style | v:rect/@o:hralign | v:rect/@fillcolor" />
		</hr>
	</xsl:if>
	
	<xsl:if test="$export-binary-data = '1'">
		<xsl:apply-templates select="w:binData"/>
	</xsl:if>
</xsl:template>

<xsl:template match="w:binData">
	<!--<xsl:document href='{substring-after( @w:name, "wordml://" )}' method='text'>
		<xsl:value-of select="."/>
	</xsl:document>-->
</xsl:template>

<xsl:template match='w:fldSimple'>
	<field instr='{@w:instr}'><xsl:apply-templates/></field>
</xsl:template>

</xsl:stylesheet>