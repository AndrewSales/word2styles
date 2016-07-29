<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		* params.xsl - global parameters
		*
		*****************************************************************
		-->

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--GLOBAL PARAMS-->

<xsl:param name="debug" select="false()" />
<xsl:param name="generate-stylename-variables" select="false()" />
<xsl:param name="auto-generate-css" select="true()" />
<xsl:param name="css-sys-id" select="'wordml.css'" />
<xsl:param name="export-binary-data" select="'0'" />
	<xsl:param name="preserve-section-wrappers" select="false()"/>

<!--DEVELOPER USE ONLY: generates CSS associated with the simplified WordML
produced by this transformation-->
<xsl:param name="generate-debugging-css" select="false()" />
<xsl:param name="debugging-css-sys-id" select="'debug-simplified-wordml.css'" />
	<xsl:param name="xpath-location-pis" select="false()"/>

</xsl:stylesheet>