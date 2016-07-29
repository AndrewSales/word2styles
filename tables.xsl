<!--*****************************************************************
		*
		* Transforms WordprocessingML to skeleton XML, consisting of 
		* paragraphs, tables and stylenames.
		*
		* (c) 2016 Andrew Sales Digital Publishing Ltd. All rights 
		* reserved.
		* 
		* tables.xsl - converts Word XML to simplified OASIS Exchange 
		* Table Model
		*
		*****************************************************************
		-->

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
	exclude-result-prefixes='w'>

<xsl:template match="w:tbl">
	<table>
		<tgroup cols='{count( w:tblGrid/w:gridCol )}'>
			<!--colspecs-->
			<xsl:apply-templates select='w:tblGrid/w:gridCol'/>
			<!--now the rows-->
			<tbody><xsl:apply-templates select='w:tr'/></tbody>
		</tgroup>
	</table>
</xsl:template>

<!--there is one gridCol per column-->
<xsl:template match="w:tblGrid/w:gridCol">
	<colspec colname='{count(preceding-sibling::w:gridCol) + 1}' 
		colnum='{count(preceding-sibling::w:gridCol) + 1}'
		colwidth='{round((@w:w div sum(../w:gridCol/@w:w)) * 100)}%'/>
</xsl:template>

<xsl:template match="w:tr">
	<row><xsl:apply-templates/></row>
</xsl:template>

<xsl:template match="w:tc">
	<entry>
		<xsl:apply-templates select="w:tcPr"/>
		<xsl:apply-templates/>
	</entry>
</xsl:template>

<!--table cell properties: *spanning*-->
<xsl:template match="w:tcPr">
	<xsl:apply-templates select='w:gridSpan | w:vmerge'/>
</xsl:template>

<!--horizontal spans-->
<xsl:template match="w:gridSpan">	

	<xsl:variable name='colnum'>
		<xsl:call-template name="colnum"/>
	</xsl:variable>
	
	<xsl:call-template name='debug'>
		<xsl:with-param name='msg'>colnum=<xsl:value-of select="$colnum"/></xsl:with-param>
	</xsl:call-template>	

	<xsl:attribute name="namest">
		<xsl:value-of select="$colnum + 1"/>
	</xsl:attribute>

	<xsl:attribute name="nameend">
		<xsl:value-of select="$colnum + @w:val"/>
	</xsl:attribute>
</xsl:template>

<!--@vspan='start' or 'continue' if cell is part of vertical span-->
<xsl:template match="w:vmerge">
	<xsl:attribute name="vspan">
		<xsl:choose>
		  <xsl:when test="@w:val = 'restart'">start</xsl:when>
		  <xsl:otherwise>continue</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
	
	<!--include namest and nameend regardless, to ease onward transformation-->
	<xsl:if test="not( ../w:gridSpan )">	<!--if gridSpan is present, namest and nameend will be provided anyway-->
		<xsl:variable name='colnum'>
			<xsl:call-template name="colnum"/>
		</xsl:variable>	  	
		<xsl:attribute name="namest">
			<xsl:value-of select="$colnum + 1"/>
		</xsl:attribute>
		<xsl:attribute name="nameend">
			<xsl:value-of select="$colnum + 1"/>
		</xsl:attribute>		
	</xsl:if>
	
</xsl:template>

<!--vertical spans: OASIS-style-->
<xsl:template match="w:vmerge" mode='oasis'>
	<xsl:if test='@w:val="restart"'><!--should be topmost cell in vertically-merged range-->
	
		<xsl:attribute name="morerows">
			
			<xsl:variable name='namest'>
				<xsl:call-template name="colnum"/>
			</xsl:variable>			
			
			<xsl:call-template name="morerows">
				<xsl:with-param name="next-row" select="../../../following-sibling::w:tr[1][descendant::w:vmerge]" />
				<xsl:with-param name="namest">
					<xsl:value-of select="$namest"/>
				</xsl:with-param>
				<xsl:with-param name="nameend">
					<xsl:choose>
					  <xsl:when test="../w:gridSpan/@w:val">
					  	<xsl:value-of select="number( ../w:gridSpan/@w:val )"/>					  	
					  </xsl:when>
					  <xsl:otherwise>
					  	<xsl:value-of select="$namest"/>
					  </xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			
		</xsl:attribute>		
	</xsl:if>
</xsl:template>


<!--======================================*NAMED TEMPLATES*======================================-->


<!--* Return the number of cells a vertical span extends down the column.
		* N.B. the context node here is a w:vmerge.
		*-->
<xsl:template name="morerows">
	<xsl:param name="next-row"/><!--the next contiguous row in the table containing w:vmerge(s); this will be an empty nodeset if none exists-->
	<xsl:param name="namest"/>
	<xsl:param name="nameend"/>
	<xsl:param name="count" select='0'/>
	
	<xsl:choose>
		<!--does the next row contain vmerges?-->
		<xsl:when test="$next-row">
			<!--check hspan-->
			<xsl:variable name='in-same-column'>
				<xsl:call-template name="has-vmerge-in-same-column">
					<xsl:with-param name="next-row-vmerges" select="$next-row/w:tc/w:tcPr/w:vmerge" />
					<xsl:with-param name="namest" select="$namest" />
					<xsl:with-param name="nameend" select="$nameend" />
				</xsl:call-template>
			</xsl:variable>

			<xsl:message>$in-same-column=<xsl:value-of select="$in-same-column"/></xsl:message>

			<xsl:choose>
				<!--increment and recurse-->
				<xsl:when test="$next-row/following-sibling::w:tr[1][descendant::w:vmerge]
												and
												$in-same-column">
					<xsl:call-template name="morerows">
						<xsl:with-param name="next-row" select="$next-row/following-sibling::w:tr[1][descendant::w:vmerge]" />
						<xsl:with-param name='count' select='$count + 1'/>	<!--incremented-->
						<xsl:with-param name='namest' select='$namest'/>
						<xsl:with-param name='nameend' select='$nameend'/>
					</xsl:call-template>
				</xsl:when>	
				<!--increment and return-->
				<xsl:when test="$in-same-column">
					<xsl:value-of select="$count + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<!--return counter-->
					<xsl:value-of select="$count"/>
				</xsl:otherwise>
			</xsl:choose>

		</xsl:when>
		<xsl:otherwise>
			<!--return counter-->
			<xsl:value-of select="$count"/>
		</xsl:otherwise>
	</xsl:choose>
		
</xsl:template>

<!--* Calculate the column number in which this cell begins
		* N.B. the context node should be a child of tcPr (e.g. gridSpan or vmerge)
		* 
		* The current column number =
		* 	  sum of the gridSpan/@vals on preceding cells
		* 		- number of gridSpan/@vals specified (they're always one over)
		* 		+ number of preceding cells
		*-->	
<xsl:template name="colnum">
	<xsl:variable name="gridspan-sum" select="sum( ../../preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val )" />
	<xsl:variable name="gridspan-count" select="count( ../../preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val )" />
	<xsl:variable name="preceding-cell-count" select="count( ../../preceding-sibling::w:tc )" />
	
	<!--DEBUG-->
	<xsl:call-template name='debug'>
		<xsl:with-param name='msg'>getting colnum for element <xsl:value-of select="name()"/>...</xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name='debug'>
		<xsl:with-param name='msg'>sum of gridSpans=<xsl:value-of select="$gridspan-sum"/></xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name='debug'>
		<xsl:with-param name='msg'>no of gridSpans specified=<xsl:value-of select="$gridspan-count"/></xsl:with-param>
	</xsl:call-template>
	<xsl:call-template name='debug'>
		<xsl:with-param name='msg'>no of preceding cells=<xsl:value-of select="$preceding-cell-count"/></xsl:with-param>
	</xsl:call-template>
	
	<xsl:value-of select="$gridspan-sum	- $gridspan-count + $preceding-cell-count"/>
</xsl:template>

<!--* Whether any of the vmerges in the nodeset passed in
		* begins in the same column.
		* params:
		* 	nodeset of vmerges in next row
		* 	namest for cell at start of vertical span
		* 	nameend for cell at start of vertical span
		*-->
<xsl:template name="has-vmerge-in-same-column">
	<xsl:param name="next-row-vmerges"/>

	<xsl:param name="namest"/>
	<xsl:param name="nameend"/>

	<xsl:for-each select="$next-row-vmerges">
		<xsl:variable name='colnum'>
			<xsl:call-template name="colnum"/>
		</xsl:variable>
		
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>colnum for merged cell in next row=<xsl:value-of select="$colnum"/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>$namest=<xsl:value-of select="$namest"/></xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name='debug'>
			<xsl:with-param name='msg'>$nameend=<xsl:value-of select="$nameend"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:choose>
			<xsl:when test="$colnum >= $namest and $colnum &lt;= $nameend">
				<xsl:value-of select="true()"/>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>

</xsl:template>

<!--suppressed-->
<xsl:template match="w:tblPr | w:tblPrEx">
</xsl:template>

</xsl:stylesheet>