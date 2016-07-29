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
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml">

<!--GLOBAL VARIABLES-->

<xsl:variable name="css-pi">href='<xsl:value-of select="$debugging-css-sys-id"/>' type='text/css'</xsl:variable>

<!--Word styles-->
	<xsl:key name='word-styles' match='/w:wordDocument/w:styles/w:style' use="@w:styleId"/>

<!--font names-->
<xsl:variable name="symbol-font" select="'Symbol'" />
<xsl:variable name="parliamentary-symbols-font" select="'ParliamentarySymbols'" />

<!--character conversion-->
<xsl:variable name="chars" select="document( 'chars.xml' )" />
<xsl:variable name="lower-case" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="upper-case" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
<xsl:variable name="lower-case-chars" select="'&#97;&#98;&#99;&#100;&#101;&#102;&#103;&#104;&#105;&#106;&#107;&#108;&#109;&#110;&#111;&#112;&#113;&#114;&#115;&#116;&#117;&#118;&#119;&#120;&#121;&#122;&#181;&#224;&#225;&#226;&#227;&#228;&#229;&#230;&#231;&#232;&#233;&#234;&#235;&#236;&#237;&#238;&#239;&#240;&#241;&#242;&#243;&#244;&#245;&#246;&#248;&#249;&#250;&#251;&#252;&#253;&#254;&#255;'"/>
<xsl:variable name="upper-case-chars" select="'&#65;&#66;&#67;&#68;&#69;&#70;&#71;&#72;&#73;&#74;&#75;&#76;&#77;&#78;&#79;&#80;&#81;&#82;&#83;&#84;&#85;&#86;&#87;&#88;&#89;&#90;&#924;&#192;&#193;&#194;&#195;&#196;&#197;&#198;&#199;&#200;&#201;&#202;&#203;&#204;&#205;&#206;&#207;&#208;&#209;&#210;&#211;&#212;&#213;&#214;&#216;&#217;&#218;&#219;&#220;&#221;&#222;&#376;'"/>


</xsl:stylesheet>