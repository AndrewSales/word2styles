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
	xmlns:asdp='http://ns.andrewsales.com/xslt/functions'
	exclude-result-prefixes='w v w10 sl aml wx o dt st1 asdp'>

	<xsl:template name='auto-generate-css'>
		<xsl:result-document href='{$css-sys-id}' method='text'>
			<xsl:text>/* PARAGRAPH STYLES */&#xA;&#xA;</xsl:text>
			<xsl:apply-templates select='w:wordDocument/w:styles/w:style[@w:type="paragraph"]' mode='css'>
				<xsl:sort select='w:name/@w:val'/>
			</xsl:apply-templates>	

			<xsl:text>&#xA;&#xA;/* CHARACTER STYLES */&#xA;&#xA;</xsl:text>
			<xsl:apply-templates select='w:wordDocument/w:styles/w:style[@w:type="character"]' mode='css'>
				<xsl:sort select='w:name/@w:val'/>
			</xsl:apply-templates>			
		</xsl:result-document>
	</xsl:template>
	
	<!--generates CSS *FOR USE WITH SIMPLIFIED WORDML OUTPUT ONLY*, for debugging purposes.
	Simplified WordML cannot use the auto-generated CSS to accompany HTML output because
	it uses <para>, <span> and other inline elements, rather than 'class' attributes to 
	capture stylenames.
	Note also that IE does not support display of XML accompanied by the debugging CSS 
	because the stylename attributes contain spaces.-->
	<xsl:template name="generate-debugging-css">
		<xsl:result-document href='{$debugging-css-sys-id}' method='text'>
			<xsl:text>/*
* This stylesheet is FOR DEBUGGING PURPOSES ONLY and is not designed to give an accurate rendering of content passed in!!
*
*/

doc
{
  padding-left:2.88cm;
  padding-right:2.88cm
}

footnote
{
  display:block
}

symbol:before
{
  content:attr(value);
  background-color:yellow;
  vertical-align:super;
  font-size:x-small;
}

p
{
  display:block
}

/*  S T Y L E  */

span[colour='yellow']
{
  background-color:yellow;
}

span[display='0']
{
  display:none
}
i
{
  font-style:italic;
}

b
{
  font-weight:bold
}

sup
{
  vertical-align:super;
  font-size:x-small;
}

sub
{
  vertical-align:sub;
  font-size:x-small;
}

/*  T A B L E S  */

row
{
  display:table-row;
}

entry
{
  display:table-cell;
  padding:5px
}

table
{
  display:table;
}

/* PARAGRAPH STYLES */&#xA;&#xA;</xsl:text>
			<xsl:apply-templates select='w:wordDocument/w:styles/w:style[@w:type="paragraph"]' mode='debugging-css'>
				<xsl:sort select='w:name/@w:val'/>
			</xsl:apply-templates>	

			<xsl:text>&#xA;&#xA;/* CHARACTER STYLES */&#xA;&#xA;</xsl:text>
			<xsl:apply-templates select='w:wordDocument/w:styles/w:style[@w:type="character"]' mode='debugging-css'>
				<xsl:sort select='w:name/@w:val'/>
			</xsl:apply-templates>			
		</xsl:result-document>		
	</xsl:template>

	<!--process a style as a debugging CSS declaration-->
	<xsl:template match='w:wordDocument/w:styles/w:style' mode='debugging-css'>
		<xsl:choose>
		  <xsl:when test="@w:type = 'paragraph'"><xsl:text>p</xsl:text></xsl:when>
		  <xsl:when test="@w:type = 'character'"><xsl:text>span</xsl:text></xsl:when>
		  <xsl:otherwise></xsl:otherwise>
		</xsl:choose>
		
		<xsl:variable name='styleId' select="asdp:get-stylename(/, @w:styleId)"/>
			
		<xsl:value-of select='concat( "[style=&apos;", $styleId, "&apos;]&#xA;" )'/>
		<xsl:text>{&#xA;</xsl:text>
		<xsl:apply-templates mode='css'/>
		<xsl:text>}&#xA;&#xA;</xsl:text>
	</xsl:template>

	<!--process a style as a CSS declaration-->
	<xsl:template match='w:wordDocument/w:styles/w:style' mode='css'>
		<xsl:variable name='name' select='concat( ".", substring( @w:type, 1, 4 ), @w:styleId )'/>
		<xsl:value-of select='$name'/>
		<xsl:text>&#xA;{&#xA;</xsl:text>
		<xsl:apply-templates mode='css'/>
		<xsl:text>}&#xA;&#xA;</xsl:text>
		
		<!--space is not allowed between paras in same style: output another style
			without space before or after
		<xsl:if test="w:pPr/w:contextualSpacing[not(@w:val) or @w:val='on']">
			<xsl:value-of select='concat( $name, "-noSpace" )'/>
			<xsl:text>&#xA;{&#xA;</xsl:text>
			<xsl:apply-templates select='*[not(w:spacing)]' mode='css'/>
			<xsl:text>}&#xA;&#xA;</xsl:text>			
		</xsl:if>-->
	</xsl:template>


	<!-- PARAGRAPH PROPERTIES -->

	<xsl:template match="w:style/w:basedOn" mode="css">	<!--inherited style attributes-->
		<xsl:variable name='base-style' select='@w:val'/>
		<xsl:if test='(../@w:type = "paragraph" and $base-style != "Normal")
									or
									(../@w:type = "character" and $base-style != "DefaultParagraphFont")'>
			<xsl:text>/*based on: </xsl:text>
			<xsl:value-of select='$base-style'/>
			<xsl:text>*/&#xA;</xsl:text>
			<!--include properties set by the base style-->
			<xsl:apply-templates select='../../w:style[ @w:styleId = $base-style ]//*' mode='css'/>
			<!--TODO: remove duplicate or conflicting style props-->
		</xsl:if>
	</xsl:template>

	<xsl:template match="w:style/w:pPr/w:jc[ @w:val = 'left' or @w:val = 'center' or @w:val = 'right' ]" mode="css">	<!--"Represents paragraph alignment."-->
		<xsl:text>text-align:</xsl:text>
		<xsl:value-of select='@w:val'/>
		<xsl:text>;&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="w:style/w:pPr/w:jc[ @w:val = 'both' ]" mode="css">	<!--"Represents paragraph alignment."-->
		<xsl:text>text-align:justify;&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="w:style/w:pPr/w:spacing" mode="css">	<!--"Represents spacing between lines and paragraphs."-->
		<xsl:apply-templates select="@w:before | @w:after" mode='css'/>
	</xsl:template>	
	
	<xsl:template match="w:spacing/@w:before" mode="css">
		<xsl:value-of select="concat( 'padding-top:', . div 20, 'pt;&#xA;' )"/>
	</xsl:template>
	
	<xsl:template match="w:spacing/@w:after" mode="css">
		<xsl:value-of select="concat( 'padding-bottom:', . div 20, 'pt;&#xA;' )"/>
	</xsl:template>	
	
	<xsl:template match="w:style/w:pPr/w:ind" mode="css">
		<!--***TODO:***how to handle NEGATIVE values?-->
		<xsl:apply-templates select='@w:left' mode="css"/>	<!--TODO: only left covered at present-->
	</xsl:template>
	
	<xsl:template match="w:ind/@w:left" mode="css">
		<xsl:value-of select="concat( 'padding-left:', . div 20, 'pt;&#xA;' )"/>
	</xsl:template>


	<!-- RUN PROPERTIES -->
	
	<xsl:template match="w:rPr/wx:font" mode="css">
		<xsl:value-of select="concat( 'font-family:', @wx:val, ';&#xA;' )"/>
	</xsl:template>
	
	<xsl:template match="w:rPr/w:sz" mode="css">
		<xsl:value-of select="concat( 'font-size:', @w:val div 2, 'pt;&#xA;' )"/>
	</xsl:template>	

	<xsl:template match="w:rPr/w:b[ not( @w:val ) or @w:val = 'on' ]" mode="css">
		<xsl:text>font-weight:bold;&#xA;</xsl:text>
	</xsl:template>	
	
	<xsl:template match="w:rPr/w:i[ not( @w:val ) or @w:val = 'on' ]" mode="css">
		<xsl:text>font-style:italic;&#xA;</xsl:text>
	</xsl:template>	
	
	<xsl:template match="w:rPr/w:caps[ not( @w:val ) or @w:val = 'on' ]" mode="css">
		<xsl:text>text-transform:capitalize;&#xA;</xsl:text>
	</xsl:template>	
	
	<xsl:template match="w:rPr/w:smallCaps[ not( @w:val ) or @w:val = 'on' ]" mode="css">
		<xsl:text>font-variant:small-caps;&#xA;</xsl:text>
	</xsl:template>	
	
	<xsl:template match="w:rPr/w:strike[ not( @w:val ) or @w:val = 'on' ]" mode="css">	<!--"Draws a line through the text."-->
		<xsl:text>text-decoration:line-through;&#xA;</xsl:text>
	</xsl:template>		
	
	<xsl:template match="w:rPr/w:u[ not( @w:val ) or @w:val != 'none' ]" mode="css">	<!--"Represents the underline formatting for this run."-->
		<xsl:text>text-decoration:underline;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template match="w:rPr/w:vertAlign[ @w:val = 'superscript' ]" mode="css">	<!--"Adjusts the vertical position of the text relative to the baseline and changes the font size if possible.."-->
		<xsl:text>vertical-align:sup;&#xA;</xsl:text>
	</xsl:template>	
	
	<xsl:template match="w:rPr/w:vertAlign[ @w:val = 'subscript' ]" mode="css">	<!--"Adjusts the vertical position of the text relative to the baseline and changes the font size if possible.."-->
		<xsl:text>vertical-align:sub;&#xA;</xsl:text>
	</xsl:template>		
	
	<xsl:template match="w:rPr/w:vertAlign[ @w:val = 'baseline' ]" mode="css">	<!--"Adjusts the vertical position of the text relative to the baseline and changes the font size if possible.."-->
		<xsl:text>vertical-align:baseline;&#xA;</xsl:text>
	</xsl:template>		
	
	<xsl:template match="w:rPr/w:color[ @w:val != 'auto' ]" mode="css">	<!--"Specifies either an automatic color or a hexadecimal color code for this run."-->
		<xsl:value-of select="concat( 'color:#', @w:val, ';&#xA;' )"/>		
		<!--TODO: handle @w:val='auto'??-->
	</xsl:template>			
	
	<xsl:template match="w:rPr/w:highlight[ @w:val != 'none' ]" mode="css">	<!--"Marks text as highlighted so it stands out from the surrounding text."-->
		<xsl:value-of select="concat( 'background-color:', @w:val, ';&#xA;' )"/>		
	</xsl:template>				
	
	
	
</xsl:stylesheet>