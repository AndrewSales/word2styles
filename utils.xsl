<!--*****************************************************************
		*
		*(c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		*
		* utils.xsl - general utility templates
		*
		*****************************************************************
		-->

<xsl:stylesheet version='2.0'
	xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
	xmlns:str='http://exslt.org/string'
	exclude-result-prefixes='str'>

<!--taken from exslt.org-->

<xsl:template name="str:split">
   <xsl:param name="string"
              select="''" />
   <xsl:param name="pattern"
              select="' '" />
   <xsl:choose>
      <xsl:when test="not($string)" />
      <xsl:when test="not($pattern)">
         <xsl:call-template name="str:_split-characters">
            <xsl:with-param name="string"
                            select="$string" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name="str:_split-pattern">
            <xsl:with-param name="string"
                            select="$string" />
            <xsl:with-param name="pattern"
                            select="$pattern" />
         </xsl:call-template>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<xsl:template name="str:_split-characters">
   <xsl:param name="string" />
   <xsl:if test="$string">
      <token>
         <xsl:value-of select="substring($string, 1, 1)" />
      </token>
      <xsl:call-template name="str:_split-characters">
         <xsl:with-param name="string"
                         select="substring($string, 2)" />
      </xsl:call-template>
   </xsl:if>
</xsl:template>

<xsl:template name="str:_split-pattern">
   <xsl:param name="string" />
   <xsl:param name="pattern" />
   <xsl:choose>
      <xsl:when test="contains($string, $pattern)">
         <xsl:if test="not(starts-with($string, $pattern))">
            <token>
               <xsl:value-of select="substring-before($string, $pattern)" />
            </token>
         </xsl:if>
         <xsl:call-template name="str:_split-pattern">
            <xsl:with-param name="string"
                            select="substring-after($string, $pattern)" />
            <xsl:with-param name="pattern"
                            select="$pattern" />
         </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
         <token>
            <xsl:value-of select="$string" />
         </token>
      </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!--SAMPLE USAGE
<xsl:template match='split'>
	<xsl:variable name='split'>
		<xsl:call-template name='str:split'>
			 <xsl:with-param name="string" select="." />
				<xsl:with-param name="pattern" select="','" />
		</xsl:call-template>
	</xsl:variable>
	
	<xsl:for-each select='$split/token'><xsl:value-of select='.'/>;</xsl:for-each>
</xsl:template>
-->

<!-- returns string of leading spaces -->
<xsl:template name="utils.leading-spaces">
  <xsl:param name="string"/>
  <xsl:param name="result" select='""'/>

  <xsl:choose>
    <xsl:when test="starts-with($string,' ')">
      <xsl:call-template name="utils.leading-spaces">
        <xsl:with-param name="string" select="substring($string, 2)"/>
        <xsl:with-param name="result" select="concat( $result, ' ')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
    	<xsl:if test="$result !=''">
				<xsl:call-template name='debug'>
					<xsl:with-param name='msg'>stripped <xsl:value-of select="string-length($result)"/> leading spaces: '<xsl:value-of select="."/>'</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
      <xsl:value-of select="$result"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- returns string of trailing spaces -->
<xsl:template name="utils.trailing-spaces">
  <xsl:param name="string"/>
  <xsl:param name="result" select='""'/>

  <xsl:variable name="last-char">
    <xsl:value-of select="substring($string, string-length($string), 1)"/>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="($last-char = ' ')">
      <xsl:call-template name="utils.trailing-spaces">
        <xsl:with-param name="string"
          select="substring($string, 1, string-length($string) - 1)"/>
        <xsl:with-param name="result" select="concat( $result, ' ')"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
    	<xsl:if test="$result !=''">
				<xsl:call-template name='debug'>
					<xsl:with-param name='msg'>stripped <xsl:value-of select="string-length($result)"/> trailing spaces: '<xsl:value-of select="."/>'</xsl:with-param>
				</xsl:call-template>
			</xsl:if>    
      <xsl:value-of select="$result"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--********DEPRECATED: SEE tables.xsl template name='colnum' INSTEAD************
return starting column no.; context node must be an entry
<xsl:template name="utils.colnum">
	<xsl:variable name='colnum'>
		<xsl:choose>
			<xsl:when test="@namest != ''">	<!-already specified->
				<xsl:value-of select="@namest"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="sum( preceding-sibling::entry/@namest )"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:call-template name='debug'>
		<xsl:with-param name='msg'>$colnum=<xsl:value-of select="$colnum"/></xsl:with-param>
	</xsl:call-template>
</xsl:template>-->

<!--given an element node, return its XPath in a processing instruction-->
<xsl:template name="xpath-loc">
	<xsl:param name='node'/>
	<xsl:param name='pi-target' select="'src-xpath-loc'"/>
	
	<xsl:if test='$debug'>
	  <xsl:variable name="xpath">
	    <xsl:for-each select="$node/ancestor-or-self::*">
	      <xsl:variable name="name" select="name(.)"/>
	      <xsl:value-of select="concat('/', name(.), '[', count(preceding-sibling::*[name() = $name]) + 1, ']')"/>
	    </xsl:for-each>
	  </xsl:variable>
      <xsl:choose>
        <xsl:when test="$xpath-location-pis">
          <xsl:processing-instruction name="{$pi-target}" select="$xpath"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="xpath" select="$xpath"/>
        </xsl:otherwise>
      </xsl:choose>
	</xsl:if>
	
	<!--*** DEBUG ***-->
	<xsl:if test="$pi-target='symbol-not-found'">
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>PI=<xsl:value-of select="$pi-target"/>; current node=<xsl:value-of select="name()"/>
				<xsl:for-each select="$node/ancestor-or-self::*">
					<xsl:variable name="name" select="name(.)" />
					<xsl:value-of select="concat( '/', name(.), '[', count(preceding-sibling::*[name() = $name]) + 1, ']' )"/>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<!--prints names of child elements of the current node to stderr-->
<xsl:template name="report-children">
	<xsl:for-each select="*">
		<xsl:message><xsl:value-of select="name()"/></xsl:message>
	</xsl:for-each>
</xsl:template>

<!--MESSAGING TEMPLATES-->

<xsl:template name='debug'>
	<xsl:param name='msg'/>
	<xsl:if test='$debug'>
		<xsl:message>[debug]:<xsl:value-of select='$msg'/></xsl:message>
	</xsl:if>
</xsl:template>

<xsl:template name='info'>
	<xsl:param name='msg'/>
	<xsl:message>[info]:<xsl:value-of select='$msg'/></xsl:message>
</xsl:template>

<xsl:template name='warn'>
	<xsl:param name='msg'/>
	<xsl:message>[warning]:<xsl:value-of select='$msg'/></xsl:message>
</xsl:template>

<xsl:template name='error'>
	<xsl:param name='msg'/>
	<xsl:message>[error]:<xsl:value-of select='$msg'/></xsl:message>
</xsl:template>

<xsl:template name='fatal-error'>
	<xsl:param name='msg'/>
	<xsl:message terminate='yes'>[FATAL]:<xsl:value-of select='$msg'/></xsl:message>
</xsl:template>

</xsl:stylesheet>