<!--*****************************************************************
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		* word-utils.xsl - utility templates specific to WordML transform
		*
		*****************************************************************
		-->
		
<xsl:stylesheet
  version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
  exclude-result-prefixes='w'>

<xsl:key name="word-chars" match="chars/font/char/word" use="."/>

<!--returns the template-defined name of a Word style
	$styleId - id of an inline/para style as contained in e.g. 
						w:pPr/w:pStyle/@w:val or w:rPr/w:rStyle/@w:val-->
<xsl:template name="get-stylename">
	<xsl:param name="styleId"/>
	<xsl:value-of select="$word-styles[ @w:styleId = $styleId ]/w:name/@w:val"/>
</xsl:template>

<!--Returns Unicode value for a given hex code and font, provided
		the char has a mapping in the lookup table.
		Otherwise a warning is issued and the font and hex code emitted 
		as attributes of empty <symbol> element.
		-->
<xsl:template name="symbol">
	<xsl:param name="font"/>
	<xsl:param name="char"/>
	<xsl:param name="origin-node"/>	<!--the element where this symbol occurred-->

	<xsl:for-each select="$chars">	<!--change current node to the character lookup-->
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>getting value for character <xsl:value-of select="$char"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name='unicode-value' select="key( 'word-chars', $char )[ ../../@name = $font ]/../unicode"/>
		
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>found '<xsl:value-of select="$unicode-value"/>'</xsl:with-param>
		</xsl:call-template>

		<xsl:choose>
			<!--no char found-->
			<xsl:when test='not( $unicode-value )'>
				<xsl:call-template name='warn'>
					<xsl:with-param name='msg'>unmapped symbol: <xsl:value-of select="$char"/>; font=<xsl:value-of select='$font'/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="$origin-node" />
					<xsl:with-param name="pi-target" select="'symbol-not-found'" />
				</xsl:call-template>
				<symbol font='{$font}' value='{$char}'/>			
			</xsl:when>
			<!--char found, but no mapping available-->
			<xsl:when test="$unicode-value = ''">
				<xsl:call-template name='warn'>
					<xsl:with-param name='msg'>unmapped symbol: <xsl:value-of select="$char"/>; font=<xsl:value-of select='$font'/></xsl:with-param>
				</xsl:call-template>
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="$origin-node" />
					<xsl:with-param name="pi-target" select="'unmapped-symbol-omitted'" />
				</xsl:call-template>
				<symbol font='{$font}' value='{$char}'/>
			</xsl:when>
			<!--only output non-empty strings-->
			<xsl:when test="not( $unicode-value/@literal='yes' )">
				<xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
				<xsl:value-of select="$unicode-value"/>
				<xsl:text>;</xsl:text>
			</xsl:when>
			<!--literal output-->
			<xsl:when test="$unicode-value/@literal='yes'">
				<xsl:value-of select="$unicode-value"/>
			</xsl:when>

			<xsl:otherwise>	<!--shouldn't happen-->
				<xsl:call-template name='warn'>
					<xsl:with-param name='msg'>unmapped symbol: <xsl:value-of select="$char"/>; font=<xsl:value-of select='$font'/></xsl:with-param>
				</xsl:call-template>				
				<symbol font='{$font}' value='{$char}'/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:for-each>	

</xsl:template>

<!--If the $generate-stylename-variables global parameter is set, 
emits an alpha-sorted list of styles declared in the WordML document (as children of w:styles), 
grouped into paragraph and character styles, to standard error.
Note that built-in table and list styles are omitted.-->
<xsl:template name='generate-stylename-variables'>
	
	<xsl:message>
		<xsl:comment>BEGIN PARAGRAPH STYLES</xsl:comment>
		<xsl:text>&#xa;</xsl:text>
	</xsl:message>
	<xsl:apply-templates select='w:wordDocument/w:styles/w:style[@w:type="paragraph"]'>
		<xsl:sort select='w:name/@w:val'/>
	</xsl:apply-templates>
	
	<xsl:message>
		<xsl:text>&#xa;</xsl:text>
		<xsl:comment>END PARAGRAPH STYLES</xsl:comment>
		<xsl:text>&#xa;&#xa;</xsl:text>
		<xsl:comment>BEGIN CHARACTER STYLES</xsl:comment>
		<xsl:text>&#xa;</xsl:text>
	</xsl:message>
	<xsl:apply-templates select='w:wordDocument/w:styles/w:style[@w:type="character"]'>
		<xsl:sort select='w:name/@w:val'/>
	</xsl:apply-templates>
</xsl:template>		

</xsl:stylesheet>