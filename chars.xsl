<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		* chars.xsl - character-specific templates
		*
		*****************************************************************
		-->
		
<xsl:stylesheet
  version="1.0"
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

	<!--CHARS-->
	
	<xsl:template match="w:br">
		<!--soft return: convert to LINE FEED-->
		<xsl:text>&#x000a;</xsl:text>
	</xsl:template>

	<xsl:template match="w:cr">
		<!--CARRIAGE RETURN-->
		<xsl:text>&#x000d;</xsl:text>
	</xsl:template>

	<xsl:template match="w:tab">
		<xsl:text>&#x0009;</xsl:text>
	</xsl:template>

	<xsl:template match="w:noBreakHyphen">
		<xsl:text>&#x2011;</xsl:text>
	</xsl:template>

	<xsl:template match="w:softHyphen">
		<xsl:text>&#x00ad;</xsl:text>
	</xsl:template>

	<xsl:template match="w:sym">
		<xsl:call-template name="symbol">
			<xsl:with-param name="font" select="@w:font" />
			<xsl:with-param name="char" select="@w:char" />
			<xsl:with-param name="origin-node" select=".." />	<!--generate locator for parent w:r-->
		</xsl:call-template>
	</xsl:template>
	
	<!--wx:sym is *apparently* used for special characters in non-Symbol fonts-->
	<xsl:template match="wx:sym">
		<xsl:call-template name="symbol">
			<xsl:with-param name="font" select="@wx:font" />
			<xsl:with-param name="char" select="@wx:char" />
			<xsl:with-param name="origin-node" select="../.." />	<!--generate locator for grandparent w:r-->
		</xsl:call-template>		  	
	</xsl:template>

</xsl:stylesheet>