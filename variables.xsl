<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		* variables.xsl - global variables
		*
		*****************************************************************
		-->

<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">

<!--GLOBAL VARIABLES-->

<xsl:variable name="css-pi">href='<xsl:value-of select="$debugging-css-sys-id"/>' type='text/css'</xsl:variable>

<!--Word styles-->
<xsl:variable name="styles-doc" select="doc(resolve-uri('styles.xml', base-uri(/)))"/> 	
<xsl:key name='word-styles' match='w:style' use="@w:styleId"/>

<!--font names-->
<xsl:variable name="symbol-font" select="'Symbol'" />
<xsl:variable name="parliamentary-symbols-font" select="'ParliamentarySymbols'" />

<!--character conversion-->
<xsl:variable name="chars" select="document( 'chars.xml' )" />

</xsl:stylesheet>