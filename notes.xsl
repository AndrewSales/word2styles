<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		* notes.xsl - note-specific templates
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

	<!--NOTES-->

	<xsl:template match="w:footnoteRef">
		<footnoteRef/>
	</xsl:template>

	<xsl:template match="w:endnoteRef">
		<endnoteRef/>
	</xsl:template>

	<xsl:template match="w:footnote">
		<footnote>
			<xsl:if test='@w:suppressRef = "on"'>
				<xsl:attribute name='suppressRef'>1</xsl:attribute>	
			</xsl:if>
			<xsl:apply-templates/>
		</footnote>
	</xsl:template>
	
	<xsl:template match="w:endnote">
		<endnote/>
	</xsl:template>

</xsl:stylesheet>