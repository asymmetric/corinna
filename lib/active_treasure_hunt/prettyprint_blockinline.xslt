<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fb="www.facebook.com">
  <xsl:template match ="para">
    <p><xsl:apply-templates /></p>
  </xsl:template>
  <xsl:template match="bold">
    <b><xsl:apply-templates /></b>
  </xsl:template>
  <xsl:template match="italic">
    <i><xsl:apply-templates /></i>
  </xsl:template>
  <xsl:template match="link">
    <a href="{@href}"><xsl:value-of select="@href"/></a>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="image">
    <xsl:if test="@type = 'inline'"><span><img src="{@src}"/></span></xsl:if>
    <xsl:if test="@type = 'block'"><p><img src="{@src}"/></p></xsl:if>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="location">
    <p>
      <fb:iframe width="650" height="487" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="http://corinna.bucket.mine.nu/maps?lat={@lat}&amp;lng={@long}&amp;z=16"></fb:iframe>
    </p>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="picture">
    <p>
      <xsl:if test="@type = 'flickr'"><fb:iframe src="http://www.elsewhere.org/mbedr/?p={@id}&amp;v" frameborder="0" scrolling="no" height="500" width="500" /></xsl:if>
    </p>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="video">
    <xsl:if test="@type = 'youtube'">
      <p><fb:swf swfbgcolor="000000" imgstyle="border-width:3px; border-color:white;" swfsrc='http://www.youtube.com/v/{@id}' width='480' height='385' /></p>
    </xsl:if>
    <xsl:if test="@type = 'googlevideo'">
      <p><fb:swf swfbgcolor="000000" imgstyle="border-width:3px; border-color:white;" swfsrc='http://video.google.com/videoplay?docid={@id}' width='480' height='385' /></p>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>
  <xsl:template match="article">
    <a href="http://{@lang}.wikipedia.org/wiki/{@id}"><img style="vertical-align: middle;" src="http://upload.wikimedia.org/wikipedia/commons/f/f1/Wikipedia-logo_kucuk.png" alt="Wikipedia logo" /><xsl:value-of select="@id" /></a>
    <xsl:apply-templates />
  </xsl:template>
</xsl:stylesheet>
