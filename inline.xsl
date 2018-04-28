<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		* 
		* inline.xsl - sub-paragraph level elements
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
	xmlns:asdp='http://ns.andrewsales.com/xslt/functions'
	exclude-result-prefixes='w v w10 sl aml wx o dt st1 asdp'>


<xsl:template match="w:r[ normalize-space() != '' ]">	<!--N.B. NO <w:r>s containing only whitespace are tagged!-->
<!--
Process run properties in this order:

		1. char style (including vanish)
		2. bold
		3. italic
		4. smallCaps
		5. underline
		6. vertical alignment
		7. highlighting
-->

	<xsl:variable name="style" select="asdp:get-stylename(/, w:rPr/w:rStyle/@w:val)"/>

	<xsl:call-template name="inline-styles">
		<xsl:with-param name="style" select="$style"/>
		<xsl:with-param name="bold" select="w:rPr/w:b" />
		<xsl:with-param name="italic" select="w:rPr/w:i"/>
		<xsl:with-param name="sc" select="w:rPr/w:smallCaps[ @w:val = 'on' or not( @w:val ) ]" />
		<xsl:with-param name="ul" select="w:rPr/w:u[ @w:val = 'single' ]" />
		<xsl:with-param name="subSup" select="w:rPr/w:vertAlign/@w:val" />
		<xsl:with-param name="vanish" select="w:rPr/w:vanish[ @w:val = 'on' or not( @w:val ) ]" />
		<xsl:with-param name="highlight" select="w:rPr/w:highlight" />
	</xsl:call-template>
	  
</xsl:template>

<xsl:template name="inline-styles">
	<xsl:param name="style"/>
	<xsl:param name="bold"/>
	<xsl:param name="italic"/>
	<xsl:param name="sc"/>
	<xsl:param name="ul"/>
	<xsl:param name="subSup"/>	
	<xsl:param name="vanish"/>	
	<xsl:param name="highlight"/>	

	<xsl:choose>

	  <xsl:when test="$style != ''">
	  	<xsl:element name="Text.{$style}">
	  		<xsl:if test="$vanish">
	  			<xsl:attribute name='display'>0</xsl:attribute>
	  		</xsl:if>
	  		<!--XPath locator in a PI-->
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="." />
				</xsl:call-template>	
				
				<xsl:call-template name="inline-styles">
					<xsl:with-param name="bold" select="$bold" />
					<xsl:with-param name="italic" select="$italic" />
					<xsl:with-param name="sc" select="$sc" />
					<xsl:with-param name="ul" select="$ul" />
					<xsl:with-param name="subSup" select="$subSup" />
					<xsl:with-param name="highlight" select="$highlight" />
				</xsl:call-template>	  		
	  	</xsl:element>
	  </xsl:when>

	  <xsl:when test="$bold">
	  	<b>
	  		<xsl:if test="$bold/@w:val='off'">
	  			<xsl:attribute name="off">yes</xsl:attribute>
	  		</xsl:if>	  	
	  		<!--XPath locator in a PI-->
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="." />
				</xsl:call-template>	
				
				<xsl:call-template name="inline-styles">
					<xsl:with-param name="italic" select="$italic" />
					<xsl:with-param name="sc" select="$sc" />
					<xsl:with-param name="ul" select="$ul" />
					<xsl:with-param name="subSup" select="$subSup" />
					<xsl:with-param name="highlight" select="$highlight" />
				</xsl:call-template>	  		
	  	</b>
	  </xsl:when>

	  <xsl:when test="$italic">
	  	<i>
	  		<xsl:if test="$italic/@w:val='off'">
	  			<xsl:attribute name="off">yes</xsl:attribute>
	  		</xsl:if>
	  		<!--XPath locator in a PI-->
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="." />
				</xsl:call-template>	
				
				<xsl:call-template name="inline-styles">
					<xsl:with-param name="sc" select="$sc" />
					<xsl:with-param name="ul" select="$ul" />
					<xsl:with-param name="subSup" select="$subSup" />
					<xsl:with-param name="highlight" select="$highlight" />
				</xsl:call-template>	  		
	  	</i>
	  </xsl:when>

	  <xsl:when test="$sc">
	  	<sc>
	  		<!--XPath locator in a PI-->
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="." />
				</xsl:call-template>	
				
				<xsl:call-template name="inline-styles">
					<xsl:with-param name="ul" select="$ul" />
					<xsl:with-param name="subSup" select="$subSup" />
					<xsl:with-param name="highlight" select="$highlight" />
				</xsl:call-template>	  		
	  	</sc>
	  </xsl:when>

	  <xsl:when test="$ul">
	  	<ul>
	  		<!--XPath locator in a PI-->
				<xsl:call-template name="xpath-loc">
					<xsl:with-param name="node" select="." />
				</xsl:call-template>	
				
				<xsl:call-template name="inline-styles">
					<xsl:with-param name="subSup" select="$subSup" />
					<xsl:with-param name="highlight" select="$highlight" />
				</xsl:call-template>	  		
	  	</ul>
	  </xsl:when>

	  <xsl:when test="$subSup">
	  	<xsl:choose>
			  <xsl:when test="$subSup = 'superscript'">
			  	<sup>
					<!--XPath locator in a PI-->
					<xsl:call-template name="xpath-loc">
						<xsl:with-param name="node" select="." />
					</xsl:call-template>	
				
						<xsl:call-template name="inline-styles"/>
					</sup>
			  </xsl:when>
			  <xsl:when test="$subSup = 'subscript'">
			  	<sub>
			   		<!--XPath locator in a PI-->
						<xsl:call-template name="xpath-loc">
							<xsl:with-param name="node" select="." />
						</xsl:call-template>	
						
						<xsl:call-template name="inline-styles">
							<xsl:with-param name='highlight' select='$highlight'/>
						</xsl:call-template>
					</sub>
			  </xsl:when>
			  <!--NOTE: could be 'baseline'...-->
			  <xsl:otherwise/>
			</xsl:choose>
	  </xsl:when>
	  
	  <xsl:when test='$highlight'>
	  	<highlight colour='{$highlight/@w:val}'>
	  		<xsl:call-template name='inline-styles'/>
	  	</highlight>
	  </xsl:when>

	 	 <xsl:otherwise>
	 		<!--***inline formatting complete***-->
	 		<!--***TODO: ensure all child elements are catered for appropriately***-->
  		<xsl:apply-templates select="*[ not( self::w:fldChar ) and not( self::w:instrText ) ]"/>
	  </xsl:otherwise>
	  
	</xsl:choose>
	
</xsl:template>

<xsl:template match="w:t">
	<xsl:apply-templates/>
</xsl:template>

<!--capitalise All Caps-->
<xsl:template match="w:t[ ../w:rPr/w:caps[ @w:val = 'on' or not( @w:val ) ] ]">
	<xsl:value-of select="translate( ., $lower-case-chars, $upper-case-chars )"/>
</xsl:template>

<!--suppress these and use the hex value given in wx:sym instead-->
<xsl:template match="w:t[preceding-sibling::w:rPr[wx:sym]]"/>

<xsl:template match="wx:font">
<!--do we need to handle this?-->
</xsl:template>
	
<xsl:template match="w:hlink">
	<url address='{@w:dest}'>
		<xsl:call-template name="xpath-loc">
			<xsl:with-param name="node" select="." />
		</xsl:call-template>
		<xsl:value-of select="."/>
	</url>
</xsl:template>	

</xsl:stylesheet>