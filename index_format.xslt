<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
>
    <xsl:output method="html" indent="yes"/>

    <xsl:template match="database">
        <style type="text/css">
          .iacss
          {
          font-family: arial,helvetica;
          }

          .iacss div.columns_disable
          {
          visibility:hidden;
          }

          .iacss h1
          {
          font-size: 18px;
          }
          .iacss h2
          {
          font-size: 18px;
          width:100%;
          border-top: 2px solid #ddd;
          }

          .iacss h3
          {
          font-size: 14px;
          }

          .iacss table
          {
          border-collapse: collapse;
          font-size:8pt;
          }

          .iacss th
          {
          background: rgb(240,240,240);
          vertical-align: bottom;
          text-align: left;
          }

          .iacss th.vert span
          {
          writing-mode: vertical-lr;
          text-orientation: mixed;
          }

          .iacss th.vert3
          {
          transform: rotate(270deg) translate(20px,0px);
          transform-origin: 100% 100%;
          max-width:18px;
          min-height:120px;
          text-align: left;
          vertical-align:bottom;
          }

          .iacss th.vert2
          {
          max-width:18px;
          text-align: left;
          vertical-align:bottom;
          }

          .iacss th
          {
          border: 1px solid #ddd;
          overflow: hidden;
          text-overflow: clip;
          }

          .iacss td
          {
          border: 1px solid #ddd;
          }

          .iacss td.index-name
          {
          max-width: 150px;
          width: 150px;
          overflow: hidden;
          text-overflow: ellipsis;
          }

          .iacss td.flag
          {
          width:18px;
          text-align:center;
          }

          .iacss td.PK { background: rgb(192,0,0); }
          .iacss td.HP { background: rgb(255, 64, 0); }
          .iacss td.CL { background: rgb(255, 192, 0); }
          .iacss td.NC { background: rgb(192, 255, 0); }
          .iacss td.PAD { background: rgb(0, 192, 0); }
          .iacss td.U { background: rgb(128, 224, 255); }
          .iacss td.UK { background: rgb(64, 192, 255); }
          .iacss td.IN { background: rgb(192, 255, 192); }
          .iacss td.UC { background: rgb(255,0,0); }
          .iacss td.RC { background: rgb(64,255,128); }
          .iacss td.PC { background: rgb(128,255,64); }
          .iacss td.F { background: rgb(128,64,255); }
          .iacss td.N { background: rgb(224,255,64); }
          .iacss td.FK1 { background: rgb(255,160,0); }
          .iacss td.FK2 { background: rgb(255,240,228); color: rgb(255,208,160); }

          .iacss td.notnull { font-weight: bold; }

          .iacss td.K1 {background:rgb(255,64,64);}
          .iacss td.K2 {background:rgb(255,96,64);}
          .iacss td.K3 {background:rgb(255,128,64);}
          .iacss td.K4 {background:rgb(255,160,64);}
          .iacss td.K5 {background:rgb(255,192,64);}
          .iacss td.K6 {background:rgb(255,224,64);}
          .iacss td.K7 {background:rgb(255,255,64);}
          .iacss td.K8 {background:rgb(255,255,64);}
          .iacss td.K9 {background:rgb(255,255,64);}
          .iacss td.K10 {background:rgb(255,255,64);}
          .iacss td.K11 {background:rgb(255,255,64);}
          .iacss td.K12 {background:rgb(255,255,64);}
          .iacss td.K13 {background:rgb(255,255,64);}

          .iacss td.I1 {background:rgb(240,240,255);}
          .iacss td.I2 {background:rgb(224,224,255);}
          .iacss td.I3 {background:rgb(208,208,255);}
          .iacss td.I4 {background:rgb(192,192,255);}
          .iacss td.I5 {background:rgb(176,176,255);}
          .iacss td.I6 {background:rgb(160,160,255);}
          .iacss td.I7 {background:rgb(160,160,255);}
          .iacss td.I8 {background:rgb(160,160,255);}
          .iacss td.I9 {background:rgb(160,160,255);}
          .iacss td.I10 {background:rgb(160,160,255);}

        </style>
        <div class="iacss">

            <h1>
                <xsl:value-of select="@database"/>
            </h1>
            <div class="subtitle">
                Extracted from <xsl:value-of select="@server"/> by <xsl:value-of select="@extract_by"/> on <xsl:value-of select="@extract_date"/>
            </div>

            <h3>Table Tree</h3>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Rows</th>
                    <th>Size (MB)</th>
                </tr>
                <xsl:apply-templates mode="fktraverse" select="/database/tables/table[@name='account']">
                    <xsl:with-param name ="level">1</xsl:with-param>
                    <xsl:with-param name ="limit">2</xsl:with-param>
                    <xsl:with-param name="pad"/>
                    <xsl:with-param name="padvalue">&#160;&#160;&#160;</xsl:with-param>
                </xsl:apply-templates>
            </table>


            <h2>Potentially-Redundant Indexes</h2>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Redundant Index</th>
                    <th>Covered By</th>
                </tr>
                <xsl:for-each select="//notes/note[@type='Covered']">
                    <xsl:variable name="table_id" select="@table_id"/>
                    <xsl:variable name="this_index_id" select="@this_index_id"/>
                    <xsl:variable name="other_index_id" select="@other_index_id"/>
                    <tr>
                        <td>
                            <a href="#t_{$table_id}">
                                <xsl:value-of select="/database/tables/table[@id = $table_id]/@name"/>
                            </a>
                        </td>
                        <td>
                            <a href="#i_{$table_id}_{$this_index_id}">
                                <xsl:value-of select="/database/tables/table[@id = $table_id]/indexes/index[@id=$this_index_id]/@name"/>
                            </a>
                        </td>
                        <td>
                            <a href="#i_{$table_id}_{$other_index_id}">
                                <xsl:value-of select="/database/tables/table[@id = $table_id]/indexes/index[@id=$other_index_id]/@name"/>
                            </a>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>

            <xsl:if test="//notes/note[@type='NoOrgID']">
                <h2>Non-clustered indexes without a Tenant ID as first key column</h2>
                <table>
                    <tr>
                        <th>Table</th>
                        <th>Index</th>
                        <th>Key Columns</th>
                    </tr>
                    <xsl:for-each select="//notes/note[@type='NoOrgID']">
                        <xsl:variable name="table_id" select="@table_id"/>
                        <xsl:variable name="this_index_id" select="@this_index_id"/>
                        <tr>
                            <td>
                                <a href="#t_{$table_id}">
                                    <xsl:value-of select="/database/tables/table[@id = $table_id]/@name"/>
                                </a>
                            </td>
                            <td>
                                <a href="#i_{$table_id}_{$this_index_id}">
                                    <xsl:value-of select="/database/tables/table[@id = $table_id]/indexes/index[@id=$this_index_id]/@name"/>
                                </a>
                            </td>
                            <td>
                                <xsl:for-each select="columns/column">
                                    <xsl:if test="position()>1">,</xsl:if>
                                    <xsl:value-of select="@name"/>
                                </xsl:for-each>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:if>

            <h2>Heaps</h2>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Rows</th>
                    <th>Size (MB)</th>
                </tr>
                <xsl:for-each select="//notes/note[@type='Heap']">
                  <xsl:sort select="../../@row_count" data-type="number" order="descending"/>
                    <xsl:variable name="table_id" select="@table_id"/>
                    <tr>
                        <td>
                            <a href="#t_{$table_id}">
                                <xsl:value-of select="/database/tables/table[@id = $table_id]/@name"/>
                            </a>
                        </td>
                      <td align="right">
                        <xsl:value-of select="format-number(../../@row_count,'#,###,###')"/>
                      </td>
                      <td align="right">
                        <xsl:value-of select="format-number(sum(../../../index/@size_mb),'#,###,###')"/>
                      </td>
                    </tr>
                </xsl:for-each>
            </table>

            <h2>Populous Tables (>1m rows)</h2>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Rows</th>
                    <th>Size (MB)</th>
                </tr>
                <xsl:for-each select="tables/table[indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count >= 1000000]">
                    <xsl:sort select="indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count" data-type="number" order="descending"/>
                    <tr>
                        <td>
                            <a href="#t_{@id}">
                                <xsl:value-of select="concat(@schema,'.',@name)"/>
                            </a>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number(indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count,'#,###,###')"/>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number(sum(indexes/index/@size_mb),'#,###,###')"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>

            <h2>Large Tables (>4GB)</h2>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Rows</th>
                    <th>Size (MB)</th>
                </tr>
                <xsl:for-each select="tables/table[sum(indexes/index/@size_mb) >= 4096]">
                    <xsl:sort select="sum(indexes/index/@size_mb)" data-type="number" order="descending"/>
                    <tr>
                        <td>
                            <a href="#t_{@id}">
                                <xsl:value-of select="concat(@schema,'.',@name)"/>
                            </a>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number(indexes/index[@type='CLUSTERED']/@row_count,'#,###,###')"/>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number(sum(indexes/index/@size_mb),'#,###,###')"/>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>

          <h2>Low-Usage Indexes (>100MB)</h2>
          <table>
            <tr>
              <th>Table</th>
              <th>Index</th>
              <th>RelRead</th>
              <th>Seeks</th>
              <th>Scans</th>
              <th>Updates</th>
              <th>PK</th>
              <th>Type</th>
              <th>Pad</th>
              <th>Unq</th>
              <th>UK</th>
              <th>Flt</th>
              <th>FF</th>
              <th>Comp</th>
              <th>FK</th>
              <th>Size (MB)</th>
              <th>Keys</th>
            </tr>
            <xsl:for-each select="tables/table/indexes/index[not(../../@schema='cdc') and @size_mb >= 100 and not(@pk) and @type='NONCLUSTERED' and (@reads div sum(../index/@reads) &lt; 0.01)]">
              <xsl:sort data-type="number" order="ascending" select="@reads div sum(../index/@reads)"/>
              <xsl:sort data-type="number" order="descending" select="@size_mb"/>
              <xsl:variable name="idx" select="."/>
              <tr>
                <td>
                  <a href="#t_{../../@id}">
                    <xsl:value-of select="concat(../../@schema,'.',../../@name)"/>
                  </a>
                </td>
                <td>
                  <a href="#i_{../../@id}_{@id}">
                    <xsl:value-of select="@name"/>
                  </a>
                </td>
                <td align="right">
                  <xsl:value-of select="format-number(@reads div sum(../index/@reads),'#0.0%')"/>
                </td>
                <td align="right">
                  <xsl:value-of select="format-number(@seeks,'###,###')"/>
                </td>
                <td align="right">
                  <xsl:value-of select="format-number(@scans,'###,###')"/>
                </td>
                <td align="right">
                  <xsl:value-of select="format-number(@updates,'###,###')"/>
                </td>
                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="@pk"/>
                  <xsl:with-param name="text">PK</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="@type"/>
                  <xsl:with-param name="text">
                    <xsl:choose>
                      <xsl:when test="@type='HEAP'">HP</xsl:when>
                      <xsl:when test="@type='CLUSTERED'">CL</xsl:when>
                      <xsl:when test="@type='NONCLUSTERED'">NC</xsl:when>
                    </xsl:choose>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="@padded"/>
                  <xsl:with-param name="text">PAD</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="@unique"/>
                  <xsl:with-param name="text">U</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="@unique_constraint"/>
                  <xsl:with-param name="text">UK</xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="@filtered"/>
                  <xsl:with-param name="text">F</xsl:with-param>
                  <xsl:with-param name="alt" select="@filter"/>
                </xsl:call-template>

                <td>
                  <xsl:value-of select="@fill_factor"/>
                </td>
                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag" select="1"/>
                  <xsl:with-param name="text">
                    <xsl:choose>
                      <xsl:when test="@compression='row'">RC</xsl:when>
                      <xsl:when test="@compression='page'">PC</xsl:when>
                      <xsl:otherwise>UC</xsl:otherwise>
                    </xsl:choose>
                  </xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="flagcell">
                  <xsl:with-param name="flag">
                    <xsl:if test="fksupports/fksupport">1</xsl:if>
                  </xsl:with-param>
                  <xsl:with-param name="text">
                    <xsl:choose>
                      <xsl:when test="fksupports/fksupport[@pure_fk_index=1]">FK1</xsl:when>
                      <xsl:when test="fksupports/fksupport">FK2</xsl:when>
                    </xsl:choose>
                  </xsl:with-param>
                </xsl:call-template>
                <td align="right">
                  <xsl:value-of select="format-number(@size_mb,'#,###,###')"/>
                </td>
                <td>
                  <xsl:for-each select="columns/column[@included=0]">
                    <xsl:sort select="@key_ordinal" data-type ="number" order="ascending"/>
                    <xsl:variable name="colid" select="@colid"/>
                    <xsl:if test="position()>1">
                      <xsl:text>, </xsl:text>
                    </xsl:if>
                    <span>
                      <xsl:attribute name="title">
                        <xsl:value-of select="../../../../columns/column[@id=$colid]/@type" />
                      </xsl:attribute>
                      <xsl:value-of select="../../../../columns/column[@id=$colid]/@name"/>
                    </span>
                  </xsl:for-each>
                </td>
              </tr>
            </xsl:for-each>
          </table>


              <h2>Large Indexes (>1GB)</h2>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Index</th>
                    <th>PK</th>
                    <th>Type</th>
                    <th>Pad</th>
                    <th>Unq</th>
                    <th>UK</th>
                    <th>Flt</th>
                    <th>FF</th>
                    <th>Comp</th>
                    <th>Size (MB)</th>
                    <th>b/row</th>
                    <th>Keys</th>
                    <th>Includes</th>
                </tr>
                <xsl:for-each select="tables/table/indexes/index[@size_mb >= 1024]">
                    <xsl:sort select="@size_b" data-type="number" order="descending"/>
                    <tr>
                        <td>
                            <a href="#t_{../../@id}">
                                <xsl:value-of select="concat(../../@schema,'.',../../@name)"/>
                            </a>
                        </td>
                        <td>
                            <a href="#i_{../../@id}_{@id}">
                                <xsl:value-of select="@name"/>
                            </a>
                        </td>
                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@pk"/>
                            <xsl:with-param name="text">PK</xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@type"/>
                            <xsl:with-param name="text">
                                <xsl:choose>
                                    <xsl:when test="@type='HEAP'">HP</xsl:when>
                                    <xsl:when test="@type='CLUSTERED'">CL</xsl:when>
                                    <xsl:when test="@type='NONCLUSTERED'">NC</xsl:when>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@padded"/>
                            <xsl:with-param name="text">PAD</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@unique"/>
                            <xsl:with-param name="text">U</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@unique_constraint"/>
                            <xsl:with-param name="text">UK</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@filtered"/>
                            <xsl:with-param name="text">F</xsl:with-param>
                            <xsl:with-param name="alt" select="@filter"/>
                        </xsl:call-template>

                        <td>
                            <xsl:value-of select="@fill_factor"/>
                        </td>
                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="1"/>
                            <xsl:with-param name="text">
                                <xsl:choose>
                                    <xsl:when test="@compression='row'">RC</xsl:when>
                                    <xsl:when test="@compression='page'">PC</xsl:when>
                                    <xsl:otherwise>UC</xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                        <td align="right">
                            <xsl:value-of select="format-number(@size_mb,'#,###,###')"/>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number(@bytes_per_row,'##,##0.00')"/>
                        </td>
                        <td>
                            <xsl:for-each select="columns/column[@included=0]">
                                <xsl:sort select="@key_ordinal" data-type ="number" order="ascending"/>
                                <xsl:variable name="colid" select="@colid"/>
                                <xsl:if test="position()>1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <span>
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="../../../../columns/column[@id=$colid]/@type" />
                                    </xsl:attribute>
                                    <xsl:value-of select="../../../../columns/column[@id=$colid]/@name"/>
                                </span>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:for-each select="columns/column[@included=1]">
                                <xsl:sort select="@id" data-type ="number" order="ascending"/>
                                <xsl:variable name="colid" select="@colid"/>
                                <xsl:if test="position()>1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <span>
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="../../../../columns/column[@id=$colid]/@type" />
                                    </xsl:attribute>
                                    <xsl:value-of select="../../../../columns/column[@id=$colid]/@name"/>
                                </span>
                            </xsl:for-each>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>

          <h2>Uncompressed Indexes (>10MB)</h2>
          Total uncompressed: <xsl:value-of select="sum(tables/table/indexes/index[not(@compression)]/@size_mb)"/> MB
          <table>
            <tr>
              <th>Script</th>
            </tr>
            <xsl:for-each select="tables/table/indexes/index[@size_mb >= 10 and not(@compression)]">
              <xsl:sort select="@size_b" data-type="number" order="descending"/>
              <tr>
                <td>
                  PRINT 'Compressing [<xsl:value-of select="@name"/>] ON [<xsl:value-of select="../../@schema"/>].[<xsl:value-of select="../../@name"/>] (<xsl:value-of select="format-number(@size_mb,'#,###,###')"/> MB)'<br/>
                  GO<br/>
                  ALTER INDEX [<xsl:value-of select="@name"/>] ON [<xsl:value-of select="../../@schema"/>].[<xsl:value-of select="../../@name"/>] REBUILD WITH (ONLINE = ON ( WAIT_AT_LOW_PRIORITY ( MAX_DURATION = 10 MINUTES, ABORT_AFTER_WAIT = SELF )), DATA_COMPRESSION=PAGE, SORT_IN_TEMPDB=ON, MAXDOP=2)<br/>
                  GO<br/>
                </td>
              </tr>
            </xsl:for-each>
          </table>

          <h2>Unindexed Foreign Keys</h2>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Foreign Key</th>
                    <th>Table Rows</th>
                    <th>Table Size</th>
                    <th>On Update</th>
                    <th>On Delete</th>
                    <th>Suggested Index</th>
                </tr>
                <xsl:for-each select="//notes/note[@type='FKIndex']">
                    <xsl:sort select="../../../../indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count" data-type="number" order="descending"/>
                    <xsl:variable name="table" select="../../../../."/>
                    <xsl:variable name="fk" select="../../."/>
                    <tr>
                        <td>
                            <a href="#t_{$table/@id}">
                                <xsl:value-of select="$table/@name"/>
                            </a>
                        </td>
                        <td>
                            <a href="#t_{$table/@id}_c{$fk/columns/column[@id='1']/@parent_colid}">
                                <xsl:value-of select="$fk/@name"/>
                            </a>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number($table/indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count,'#,###,###')"/>
                        </td>
                        <td align="right">
                            <xsl:value-of select="format-number(sum($table/indexes/index/@size_mb),'#,###,###')"/>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$fk/@on_update = 'no_action'"></xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$fk/@on_update"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$fk/@on_delete = 'no_action'"></xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$fk/@on_delete"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>

          <h2>Large Tables (>=1GB)</h2>
          <xsl:apply-templates select="tables/table[sum(indexes/index/@size_mb) >= 1024]">
            <xsl:sort select="sum(indexes/index/@size_mb)" data-type ="number" order="descending"/>
          </xsl:apply-templates>
          
            <h2>Smaller Tables (&lt;1GB)</h2>
          <xsl:apply-templates select="tables/table[sum(indexes/index/@size_mb) &lt; 1024]">
            <xsl:sort select="sum(indexes/index/@size_mb)" data-type ="number" order="descending"/>
          </xsl:apply-templates>
        </div>
    </xsl:template>


    <xsl:template match="table">
        <xsl:variable name="columns" select="columns"/>
        <xsl:variable name="indexes" select="indexes"/>
        <xsl:variable name="tid" select="@id"/>
        <a name="t_{$tid}"/>
        <h2>
            <xsl:value-of select="concat(@schema,'.',@name)"/>
        </h2>
        <div class="tablestats">
            Size: <xsl:value-of select="format-number(sum(indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count),'###,###')"/> rows, <xsl:value-of select="format-number(round(sum(indexes/index/@size_b) div 1048576),'###,###')"/> MB
        </div>

        <div class="columns">
            <h3>Columns</h3>
            <table>
                <tr>
                    <th>Column</th>
                    <th>Type</th>
                    <th>PK</th>
                    <th>FK</th>
                    <xsl:for-each select="$indexes/index">
                        <th class="vert" title="{@name}">
                            <span>
                                <xsl:value-of select="@name"/>
                            </span>
                        </th>
                    </xsl:for-each>
                </tr>
                <xsl:for-each select="$columns/column">
                  <xsl:sort select="count(../../indexes/index/columns/column[@colid = current()/@id])" data-type="number" order="descending"/>
                  <xsl:variable name="colid" select="@id"/>
                  <!--<xsl:sort select="@id" data-type="number" order="ascending"/>-->
                  <tr>
                        <td>
                            <xsl:attribute name="class">
                                <xsl:if test="not(@nullable)">notnull</xsl:if>
                                <xsl:value-of select="concat(' I',count(../../indexes/index/columns/column[@colid=$colid]))" />
                            </xsl:attribute>
                            <a name="t_{$tid}_c{@id}"/>
                            <xsl:value-of select="@name"/>
                        </td>
                        <td>
                            <xsl:value-of select="@type"/>
                        </td>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="../../indexes/index[@pk='1']/columns/column[@colid=$colid]"/>
                            <xsl:with-param name="text">PK</xsl:with-param>
                        </xsl:call-template>

                        <td>
                            <xsl:for-each select="foreignkeys/foreignkey">
                                <xsl:variable name="rid" select="@referenced_id"/>
                                <xsl:variable name="rcolid" select="@referenced_colid"/>
                                <a href="#t_{@referenced_id}_c{@referenced_colid}">
                                    <xsl:value-of select="/database/tables/table[@id=$rid]/@name"/>(<xsl:value-of select="/database/tables/table[@id=$rid]/columns/column[@id=$rcolid]/@name"/>)
                                </a>
                            </xsl:for-each>
                        </td>
                        <xsl:for-each select="$indexes/index">
                            <td>
                                <xsl:choose>
                                    <xsl:when test="columns/column[@colid=$colid]">
                                        <xsl:attribute name="class">
                                            <xsl:value-of select="concat('flag ',columns/column[@colid=$colid]/@code)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="columns/column[@colid=$colid]/@code"/>
                                    </xsl:when>
                                    <xsl:when test="@type = 'CLUSTERED'">
                                        <xsl:attribute name="class">
                                            <xsl:value-of select="concat('flag ','IN')"/>
                                        </xsl:attribute>
                                        CL
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>

                    </tr>
                </xsl:for-each>
            </table>
        </div>
        <div class="indexes">
            <h3>Indexes</h3>
            <table>
                <tr>
                    <th>Name</th>
                    <th>!</th>
                    <th class="vert">PK</th>
                    <th class="vert">Typ</th>
                    <th class="vert">Pad</th>
                    <th class="vert">Unq</th>
                    <th class="vert">UK</th>
                    <th class="vert">Flt</th>
                    <th class="vert">FF</th>
                    <th class="vert">Cmp</th>
                    <th class="vert">MB</th>
                  <th class="vert">MB%</th>
                  <th class="vert">MB%max</th>
                  <th class="vert">Read</th>
                  <th class="vert">Scan</th>
                  <th class="vert">FK</th>
                  <th class="vert">K1</th>
                    <th class="vert">K2</th>
                    <th class="vert">K3</th>
                    <xsl:for-each select="$columns/column">
                        <th class="vert" title="{@name}">
                            <span>
                                <xsl:value-of select="@name"/>
                            </span>
                        </th>
                    </xsl:for-each>
                </tr>

                <xsl:for-each select="indexes/index">
                  <!--<xsl:sort select="@reads" order="descending" data-type="number"/>-->
                  <xsl:sort select="@type" order="ascending"/>
                  <xsl:sort select="@pk" order="descending"/>
                  <xsl:sort select="columns/column[@key_ordinal='1']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='2']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='3']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='4']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='5']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='6']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='7']/@colid" data-type="number"/>
                  <xsl:sort select="columns/column[@key_ordinal='8']/@colid" data-type="number"/>
                  <xsl:variable name="index" select="."/>
                  <xsl:variable name="maxindex">
                    <xsl:for-each select="../index/.">
                      <xsl:sort select="@size_mb" data-type="number" order="descending"/>
                      <xsl:if test="position()=1">
                        <xsl:value-of select="@size_mb"/>
                      </xsl:if>
                    </xsl:for-each>                  
                  </xsl:variable>
                    <tr>
                        <td class="index-name" title="{@name}">
                            <a name="i_{$tid}_{@id}"/>
                            <xsl:value-of select="@name"/>
                        </td>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="notes/note"/>
                            <xsl:with-param name="text">N</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@pk"/>
                            <xsl:with-param name="text">PK</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@type"/>
                            <xsl:with-param name="text">
                                <xsl:choose>
                                    <xsl:when test="@type='HEAP'">HP</xsl:when>
                                    <xsl:when test="@type='CLUSTERED'">CL</xsl:when>
                                    <xsl:when test="@type='NONCLUSTERED'">NC</xsl:when>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@padded"/>
                            <xsl:with-param name="text">PAD</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@unique"/>
                            <xsl:with-param name="text">U</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@unique_constraint"/>
                            <xsl:with-param name="text">UK</xsl:with-param>
                        </xsl:call-template>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="@filtered"/>
                            <xsl:with-param name="text">F</xsl:with-param>
                            <xsl:with-param name="alt" select="@filter"/>
                        </xsl:call-template>

                        <td>
                            <xsl:value-of select="@fill_factor"/>
                        </td>

                        <xsl:call-template name="flagcell">
                            <xsl:with-param name="flag" select="1"/>
                            <xsl:with-param name="text">
                                <xsl:choose>
                                    <xsl:when test="@compression='row'">RC</xsl:when>
                                    <xsl:when test="@compression='page'">PC</xsl:when>
                                    <xsl:otherwise>UC</xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                        <td align="right">
                            <xsl:value-of select="format-number(@size_mb,'###,###')"/>
                        </td>
                      <td align="right">
                        <xsl:attribute name="style">
                          <xsl:value-of select="concat('background:rgb(',
                                        format-number(255 - ((@size_mb * 255) div sum(../index/@size_mb)),'#0'),',',
                                        format-number(255 - ((@size_mb * 128) div sum(../index/@size_mb)),'#0'),',',
                                        '224);')"/>
                        </xsl:attribute>
                        <xsl:value-of select="format-number(@size_mb div sum(../index/@size_mb),'#0.0%')"/>
                      </td>
                      <td align="right">
                        <xsl:attribute name="style">
                          <xsl:value-of select="concat('background:rgb(',
                                        format-number(255 - ((@size_mb * 255) div $maxindex),'#0'),',',
                                        format-number(255 - ((@size_mb * 128) div $maxindex),'#0'),',',
                                        '224);')"/>
                        </xsl:attribute>
                        <xsl:value-of select="format-number(@size_mb div $maxindex,'#0.0%')"/>
                      </td>
                      <td align="right">
                        <xsl:attribute name="style">
                          <xsl:choose>
                            <xsl:when test="@reads=0">background:red</xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="concat('background:rgb(',
                                        format-number(255 - ((@reads*255) div sum(../index/@reads)),'#0'),',',
                                        format-number(255,'#0'),',',
                                        format-number(255 - ((@reads*255) div sum(../index/@reads)),'#0'),');')"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="format-number(@reads div sum(../index/@reads),'#0.000%')"/>
                      </td>
                      <td align="right">
                        <xsl:value-of select="format-number(@scans,'###,###')"/>
                      </td>
                      <xsl:call-template name="flagcell">
                        <xsl:with-param name="flag">
                          <xsl:if test="fksupports/fksupport">1</xsl:if>
                        </xsl:with-param>
                        <xsl:with-param name="text">
                          <xsl:choose>
                            <xsl:when test="fksupports/fksupport[@pure_fk_index=1]">FK1</xsl:when>
                            <xsl:when test="fksupports/fksupport">FK2</xsl:when>
                          </xsl:choose>
                        </xsl:with-param>
                      </xsl:call-template>
                      <td>
                        <xsl:value-of select="$columns/column[@id=$index/columns/column[@key_ordinal='1']/@colid]/@name"/>
                      </td>
                      <td>
                        <xsl:value-of select="$columns/column[@id=$index/columns/column[@key_ordinal='2']/@colid]/@name"/>
                      </td>
                      <td>
                        <xsl:value-of select="$columns/column[@id=$index/columns/column[@key_ordinal='3']/@colid]/@name"/>
                      </td>
                      
                      <xsl:for-each select="$columns/column">
                            <xsl:variable name="colid" select="@id"/>
                            <td title="{@name}">
                                <xsl:choose>
                                    <xsl:when test="$index/columns/column[@colid=$colid]">
                                        <xsl:attribute name="class">
                                            <xsl:value-of select="concat('flag ',$index/columns/column[@colid=$colid]/@code)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="$index/columns/column[@colid=$colid]/@code"/>
                                    </xsl:when>
                                    <xsl:when test="$index/@type = 'CLUSTERED'">
                                        <xsl:attribute name="class">
                                            <xsl:value-of select="concat('flag ','IN')"/>
                                        </xsl:attribute>
                                        CL
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>

                    </tr>
                </xsl:for-each>

            </table>

            <xsl:if test="indexes/index/notes/note">
                <h3>Notes</h3>
                <table>
                    <tr>
                        <th>Note</th>
                    </tr>
                    <xsl:for-each select="indexes/index/notes/note">
                        <tr>
                            <td>
                                <xsl:value-of select="text()"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>

            </xsl:if>
        </div>
        <div class="parenttables">
            <h3>Parent/Lookup Tables</h3>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Columns</th>
                    <th>Local Columns</th>
                    <th>Foreign Key</th>
                    <th>Supporting Indexes</th>
                </tr>
                <xsl:for-each select="foreignkeys/foreignkey">
                    <xsl:variable name="ref" select="@referenced_id"/>
                    <xsl:variable name="col" select="columns/column[@id=1]"/>
                  <xsl:variable name="fkid" select="@id"/>
                    <tr>
                        <td>
                            <a href="#t_{$ref}">
                                <xsl:value-of select="/database/tables/table[@id=$ref]/@name"/>
                            </a>
                        </td>
                        <td>
                            <xsl:for-each select="columns/column">
                                <xsl:sort data-type="number" order="ascending" select="@id"/>
                                <xsl:variable name="referenced_colid" select="@referenced_colid"/>
                                <xsl:if test="position() > 1">,</xsl:if>
                                <a href="#t_{@referenced_id}_c{@referenced_colid}">
                                    <xsl:value-of select="/database/tables/table[@id=$ref]/columns/column[@id=$referenced_colid]/@name"/>
                                </a>
                            </xsl:for-each>
                        </td>
                        <td>
                          <xsl:for-each select="columns/column">
                            <xsl:sort data-type="number" order="ascending" select="@id"/>
                            <xsl:variable name="parent_colid" select="@parent_colid"/>
                            <xsl:if test="position() > 1">,</xsl:if>
                            <xsl:value-of select="$columns/column[@id=$parent_colid]/@name"/>
                          </xsl:for-each>
                        </td>
                      <td>
                        <xsl:value-of select="@name"/>
                      </td>
                      <td>
                        <xsl:for-each select="../../indexes/index/fksupports/fksupport[@id = $fkid]">
                            <xsl:sort select="@column_overhang" data-type="number" order="ascending"/>
                          <xsl:if test="position() > 1">, </xsl:if>
                          <xsl:choose>
                            <xsl:when test="@pure_fk_index = 1">
                              <strong>
                                <xsl:value-of select="../../@name"/>
                              </strong>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="../../@name"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </td>
                    </tr>
                </xsl:for-each>
            </table>
        </div>
        <div class="childtables">
            <h3>Child Tables</h3>
            <table>
                <tr>
                    <th>Table</th>
                    <th>Column</th>
                </tr>
                <xsl:for-each select="/database/tables/table/foreignkeys/foreignkey[@referenced_id = $tid]">
                    <xsl:variable name="rcolid" select="columns/column[@id=1]/@referenced_colid"/>
                    <tr>
                        <td>
                            <a name="#f_{@id}"/>
                            <a href="#t_{../../@id}">
                                <xsl:value-of select="../../@name"/>
                            </a>
                        </td>
                        <td>
                            <a href="#t_{../../@id}_c{$rcolid}">
                                <xsl:value-of select="$columns/column[@id=$rcolid]/@name"/>
                            </a>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </div>
    </xsl:template>

    <xsl:template match="table" mode="fktraverse">
        <xsl:param name="level">1</xsl:param>
        <xsl:param name="limit">1</xsl:param>
        <xsl:param name="pad"></xsl:param>
        <xsl:param name="padvalue"></xsl:param>
        <xsl:param name="path"></xsl:param>
        <xsl:param name="delete"></xsl:param>
        <xsl:variable name="tid" select="@id"/>

        <xsl:choose>
            <!-- loop breaker -->
            <xsl:when test="contains($path,concat('|',$tid,'|'))">
                <tr>
                    <td colspan="3">
                        <xsl:value-of select="$pad"/>
                        (circular reference to <xsl:value-of select="@name"/>)
                    </td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <!-- display table details -->
                <tr>
                    <td>
                        <xsl:value-of select="$pad"/>
                        <a href="#t_{@id}">
                            <xsl:value-of select="@name"/>
                          <b>
                            <xsl:value-of select="$delete"/>
                          </b>
                        </a>
                    </td>
                    <td align="right">
                        <xsl:value-of select="format-number(indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count,'#,###,###')"/>
                    </td>
                    <td align="right">
                        <xsl:value-of select="format-number(sum(indexes/index/@size_mb),'#,###,###')"/>
                    </td>
                </tr>

                <!-- starting at table_id, what FKs reference this table? -->
                <xsl:if test="$limit &gt; 0">
                    <xsl:apply-templates mode="fktraverse" select="/database/tables/table[foreignkeys/foreignkey[@referenced_id=$tid]]">
                        <xsl:sort select="indexes/index[@type='CLUSTERED' or @type='HEAP']/@row_count" data-type="number" order="descending"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                        <xsl:with-param name="limit" select="$limit - 1"/>
                        <xsl:with-param name="pad" select="concat($pad,$padvalue)"/>
                        <xsl:with-param name="padvalue" select="$padvalue"/>
                        <xsl:with-param name="path" select="concat($path,'|',$tid,'|')"/>
                        <xsl:with-param name="delete" select="foreignkeys/foreignkey[@referenced_id=$tid]/@on_delete"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="repeat">
        <xsl:param name="text">&#160;</xsl:param>
        <xsl:param name="value"/>
        <xsl:param name="length"/>
        <xsl:choose>
            <xsl:when test="$length = 0">
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="repeat">
                    <xsl:with-param name="value" select="concat($value,$text)"/>
                    <xsl:with-param name="text" select="$text"/>
                    <xsl:with-param name="length" select="$length - 1"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="flagcell">
        <xsl:param name="flag"/>
        <xsl:param name="text"/>
        <xsl:param name="alt"/>
        <xsl:variable name="flag2">
            <xsl:choose>
                <xsl:when test="$flag">
                    <xsl:value-of select="$text"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <td>
            <xsl:if test="$alt">
                <xsl:attribute name="title">
                    <xsl:value-of select="$alt"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$flag">
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('flag ',$text)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$flag2"/>
        </td>
    </xsl:template>


</xsl:stylesheet>
